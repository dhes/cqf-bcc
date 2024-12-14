This is my cqf-bcc. It is modeled after cqf-bcc. I have started with the eCQI resources on Breast Cancer and worked from there. 

To load to HAPI FHIR JPA server, execute this at the command line. 
```
curl -d "@bundles/plandefinition/BreastCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

2024-12-13

Edges for testing

|Edge|Complement|id|passes Execute CQL?|
|---|---|---|---|
|Base||up-to-date|true|
|Alive - |base|deceased|true|
|Alive null |base|deceased-null|FALSE|
|Active - |base|inactive|true|
|Active null |base||||
|Gender - |base|male|true|
|Gender null |base||||
|Lower age + |||||
|Lower age - ||too-young|true|
|Upper age + |||||
|Upper age - |base||||
|age null |||age-null||
|Bilateral mastectomy -|base-case|mastectomy||true|
|Breast cancer|base-case|||true|
|Overdue + ||overdue||
|Overdue - ||||


Base-case is a 57 y.o. woman who has never had a mammogram. By definition a base case is the simplest positive case. A positive case is defined as a case that is due for intervention (in the context, a mammogram).
is due. Typically if there is an age range, the birthday is set so that the age is near the middle of the age range. The base case is used to create the simplest negative cases, such as base case (inactive) or base case (deceased). 

There are strategic decisions to be taken here. One is -- how to deal with test cases where information is missing. They will return 'null' and therefore fail the 'applicable' test in the PlanDefinition. That means there will be no reminder and the user might have no awareness that information is missing. This would apply for example to Patient.active, Patient.birthDate, Patient.gender; but it may not apply to Patient.deceased. In my opinion it would be too laborious to try to create CQL that works around this issue. It would be better to create a different CQL/Plandefinition that returns something like: "The $apply definition cannot be used in the patient because ... is missing [e.g. Patient.birthdate]". 

So for now we might discuss these test cases, but not address them in CQL - except for this: it is understood that for our purposes Patient.active, Patient.birthDate, Patient.gender are required elements; and that Patient.deceased is optional, and the CQL be written such that patient is considered alive if Patient.deceased is null. Is there a profile for that? US Core enforces gender but not the other two. You could create a profile for this very purpose, I guess, and then validate against it as another option for pre-testing you patient set before $apply. 