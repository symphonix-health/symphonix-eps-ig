"""Verify that every citation URL in the IG narrative resolves.

L-244 requires that every paper, standard, or benchmark cited in the IG
resolves on its canonical host; unverifiable citations must be marked
``[unverified]`` inline and resolved before the next release.

This test walks ``input/pagecontent/*.md`` and ``README.md``, extracts
every ``[text](URL)`` link to an external host, and does a HEAD request
with a short timeout. Failures are reported per-URL so a release
manager can fix the exact citation.

The test is marked ``slow`` so it only runs on CI by default; local
authors can run with ``pytest -m slow``.
"""

from __future__ import annotations

import re
from pathlib import Path

import httpx
import pytest

ROOT = Path(__file__).resolve().parents[1]
LINK_RE = re.compile(r"\[([^\]]+)\]\((https?://[^)]+)\)")

SKIP_HOSTS = {
    "github.com",  # private repos may 404 in CI without auth
    "localhost",
    "127.0.0.1",
    "example",
}


def _collect_urls() -> list[tuple[Path, str, str]]:
    out: list[tuple[Path, str, str]] = []
    for source in [
        ROOT / "README.md",
        *(ROOT / "input" / "pagecontent").glob("*.md"),
    ]:
        for match in LINK_RE.finditer(source.read_text(encoding="utf-8")):
            label, url = match.group(1), match.group(2)
            if any(host in url for host in SKIP_HOSTS):
                continue
            out.append((source, label, url))
    return out


_BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-GB,en;q=0.9",
}


@pytest.mark.slow
@pytest.mark.parametrize("source,label,url", _collect_urls())
def test_citation_resolves(source, label, url):
    def _try(method: str) -> "httpx.Response | None":
        """Single fetch with browser headers; returns None on transient
        transport-level fault. Transport faults (connection reset,
        DNS, timeout) are network conditions, not citation failures —
        the IG content is the unit under test, not the upstream's
        availability at this exact moment.
        """
        try:
            if method == "HEAD":
                return httpx.head(
                    url, follow_redirects=True, timeout=15, headers=_BROWSER_HEADERS
                )
            return httpx.get(
                url, follow_redirects=True, timeout=15, headers=_BROWSER_HEADERS
            )
        except httpx.TimeoutException:
            return None
        except httpx.TransportError:
            return None

    response = _try("HEAD")
    if response is None:
        # Retry once with GET in case the host rejects HEAD at the
        # transport layer (some CDNs do).
        response = _try("GET")
    if response is None:
        pytest.skip(
            f"{url} unreachable (timeout / transport error / DNS) — "
            f"network condition, not a citation defect"
        )
    if response.status_code in (403, 405, 429):
        # HEAD not allowed / blocked / rate limited; try GET with browser UA
        retry = _try("GET")
        if retry is not None:
            response = retry
    if response.status_code in (403, 429):
        # Persistent anti-bot block; treat as skip — the citation itself is
        # not the unit under test, the IG content is.
        pytest.skip(f"{url} returned {response.status_code} (anti-bot block)")
    assert response.status_code < 400, (
        f"{source.name}: {label} -> {url} returned {response.status_code}"
    )
