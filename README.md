This is my cqf-bcc. It is modeled after cqf-bcc. I have started with the eCQI resources on Breast Cancer and worked from there. 

To load to HAPI FHIR JPA server, execute this at the command line. 
```
curl -d "@bundles/plandefinition/BreastCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```