This is my cqf-bcc. It is modeled after cqf-bcc. I have started with the eCQI resources on Breast Cancer and worked from there. 

To load to HAPI FHIR JPA server, execute this at the command line. 
```
curl -d "@bundles/plandefinition/BreastCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

2024-12-13

Edges for testing

|Edge|Complement|
|---|---|
|Alive|base-case|
|Active|base-case|
|Gender|base-case|
|Lower age + |just-old-enough|
|Lower age - |too-young|
|Upper age + |just-young-enough| 
|Upper age - |too-old| 
|Bilateral mastectomy|base-case|
|Breast cancer|base-case|

Base-case is a 57 y.o. woman who has never had a mammogram. By definition a base case is the simplest positive case. A positive case is defined as a case that is due for intervention (in the context, a mammogram).
is due. Typically if there is an age range, the birthday is set so that the age is near the middle of the age range. The base case is used to create the simplest negative cases, such as base case (inactive) or base case (deceased). 