// ---------------------------------------------------------------------------
// Symphonix EPS CapabilityStatements
// ---------------------------------------------------------------------------
// Defines the REST surface each simulator MUST expose.

Instance: EtpsTransportServer
InstanceOf: CapabilityStatement
Title: "ETPS Transport Server Capability Statement"
Usage: #definition
* url = "https://symphonix.health/fhir/eps/CapabilityStatement/etps-transport-server"
* name = "EtpsTransportServer"
* status = #active
* kind = #requirements
* date = "2026-04-24"
* fhirVersion = #4.0.1
* format = #json
* rest.mode = #server
* rest.messaging.endpoint.protocol = #http
* rest.messaging.endpoint.protocol.coding.system = "http://terminology.hl7.org/CodeSystem/message-transport"
* rest.messaging.endpoint.address = "https://etps.example/FHIR/R4/$process-message"
* rest.messaging.supportedMessage[+].mode = #receiver
* rest.messaging.supportedMessage[=].definition = "https://symphonix.health/fhir/eps/MessageDefinition/eps-prescribe"
* rest.messaging.supportedMessage[+].mode = #receiver
* rest.messaging.supportedMessage[=].definition = "https://symphonix.health/fhir/eps/MessageDefinition/eps-dispense"
* rest.messaging.supportedMessage[+].mode = #receiver
* rest.messaging.supportedMessage[=].definition = "https://symphonix.health/fhir/eps/MessageDefinition/eps-cancel"
* rest.resource[+].type = #Task
* rest.resource[=].profile = "https://symphonix.health/fhir/eps/StructureDefinition/eps-task"
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "https://symphonix.health/fhir/eps/StructureDefinition/eps-audit-event"
* rest.resource[=].interaction[+].code = #search-type

Instance: EpsClinicalServer
InstanceOf: CapabilityStatement
Title: "EPS Clinical-Workflow Server Capability Statement"
Usage: #definition
* url = "https://symphonix.health/fhir/eps/CapabilityStatement/eps-clinical-server"
* name = "EpsClinicalServer"
* status = #active
* kind = #requirements
* date = "2026-04-24"
* fhirVersion = #4.0.1
* format = #json
* rest.mode = #server
* rest.resource[+].type = #MedicationRequest
* rest.resource[=].profile = "https://symphonix.health/fhir/eps/StructureDefinition/eps-medication-request"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[+].type = #MedicationDispense
* rest.resource[=].profile = "https://symphonix.health/fhir/eps/StructureDefinition/eps-medication-dispense"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[+].type = #AllergyIntolerance
* rest.resource[=].profile = "https://symphonix.health/fhir/eps/StructureDefinition/eps-allergy-intolerance"
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #read
* rest.resource[=].interaction[+].code = #search-type
