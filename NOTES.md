This is the effect of _refresh.sh:

```
java -jar tooling-cli-2.4.0.jar -RefreshIG -ini=/Users/danheslinga/cqf-bcc/ig.ini -d -p -t
```

2023-01-16

Take note of [this](https://www.hl7.org/fhir/us/breast-radiology/2020May/CodeSystem-BiRadsAssessmentCategoriesCS.html) FHIR Birads document. 

PPT from Bryn Rhodes discussion [RefreshIG](https://docs.google.com/presentation/d/1wFKnmg0G2Ge7JIgMbcDTTLBkw4Fx6wss/edit#slide=id.p20)

Link re [ReFreshIG](https://github.com/cqframework/cqf-tooling/issues/273) from Paul Denning. 

2024-01-20

I'm doing some symlinking so I don't have to keep so may copies of test files. The source tests will reside in the library directory that represents them. input/tests/planDefinition holds the tests for BreastCancerScreeningCDS and input/tests/measure/BreastCancerScreeningCQM. Here are the symlink commands:

|command|source|target|
|:---|:---|:---|
|ln -s|/Users/danheslinga/cqf-bcc/input/tests/plandefinition/BreastCancerScreeningCDS/should-not-screen|/Users/danheslinga/cqf-bcc/input/tests/cdshooks/BreastCancerScreeningCDS/should-not-screen/resources|
|ln -s|/Users/danheslinga/cqf-bcc/input/tests/plandefinition/BreastCancerScreeningCDS/should-screen|/Users/danheslinga/cqf-bcc/input/tests/cdshooks/BreastCancerScreeningCDS/should-screen/resources|
|ln -s|/Users/danheslinga/cqf-bcc/input/tests/measure/BreastCancerScreeningCQM/should-not-screen|/Users/danheslinga/cqf-bcc/input/tests/cdshooks/BreastCancerScreeningCQM/should-not-screen/resources|
|ln -s|/Users/danheslinga/cqf-bcc/input/tests/measure/BreastCancerScreeningCQM/should-screen|/Users/danheslinga/cqf-bcc/input/tests/cdshooks/BreastCancerScreeningCQM/should-screen/resources|

You might ask why these files need to be in so many places. I might say I don't know. Maybe for now there can just be one copy! The problem is that `Execute CQL` runs the tests in the first matching directory it finds and then stops. But no matter which directory you run it from, it's the same test. I'm just going to put them in input/tests/plandefinition/BreastCancerScreeningCDS and input/tests/measure/BreastCancerScreeningCQM for now. 

Or maybe since BreastCancerElements is common to BreastCancerCDS and BreastCancerCQM I'll house the test files there and link to the rest. 

