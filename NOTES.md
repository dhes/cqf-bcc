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

2024-01-22

As an example, this creates a symlink for the `overdue` and `up-to-date` test patients when executed from the `input/tests/library/BreastCancerScreeningCDS` directory:

```
ln -s ../BreastCancerElements/overdue ./overdue
ln -s ../BreastCancerElements/up-to-date ./overdue/up-to-date
```

2024-01-26

This is from ChatGPT:

>To create a relative symlink in macOS that populates the `CDS` directory with all files from its sibling directory `Elements`, you will need to use the Terminal and the `ln` command. The steps below assume that `CDS` and `Elements` are sibling directories within the same parent directory. Here's how you can do it:
>
>1. **Open Terminal**: You can do this by searching for Terminal in Spotlight or accessing it from the Applications/Utilities folder.
>
>2. **Navigate to the Parent Directory**: Use the `cd` command to navigate to the parent directory that contains both the `CDS` and `Elements` directories. For example, if the parent directory is named `ParentDirectory`, you would type:
>
>   ```bash
>    cd path/to/ParentDirectory
>    ```
>
>3. **Create Symlinks for All Files in `Elements` Inside `CDS`**:
>    - You'll want to loop through each file in `Elements` and create a relative symlink in the `CDS` directory pointing to it.
>    - You can use a shell loop for this. Assuming you're in the parent directory of both `CDS` and `Elements`, the commands would look something like this:
>
>    ```bash
>    for file in Elements/*; do
>        ln -s ../$file CDS/
>    done
>    ```
>
>    Let's break this down:
>    - `for file in Elements/*; do`: This starts a loop over all files in the `Elements` directory.
>    - `ln -s ../$file CDS/`: This creates a symbolic link in the `CDS` directory. The `../` is used to ensure the path is relative, pointing back to the `Elements` directory.
>    - `done`: This ends the loop.
>
>After running these commands, the `CDS` directory should contain symlinks to all files in the `Elements` directory. These symlinks are relative, meaning they should continue to work as long as the relative positions of `CDS`, `Elements`, and their parent directory don't change.
>
>Remember that these symlinks are just pointers to the files in `Elements`, not copies. Any changes made to the files via the `CDS` directory symlinks will actually be affecting the files in the `Elements` directory.

In my case I guess this would mean I `cd` to `input/tests/library` and run

```
for file in BreastCancerElements/*; do
    ln -s ../$file BreastCancerScreeningCDS/
done
```

Or maybe more like this. Once again with pwd as `input\tests\library`:

```
find BreastCancerElements -type d -mindepth 1 -maxdepth 1 -exec sh -c '(cd BreastCancerScreeningCDS && ln -s "../$0" "$(basename "$0")")' {} \;
```
That works fine! 

2024-02-06

Let's try to load the current libraries to the HAPI server. 

```
curl -d "@input/resources/library/BreastCancerConcepts.json" -H "Content-Type: application/json" -X POST http://localhost:8080/r4/cds/fhir
```
and
```
curl -d "@input/resources/library/BreastCancerScreeningCDS.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
and
```
curl -d "@input/resources/plandefinition/BreastCancerScreeningCDS.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

Running the first one produces: 
```
{
  "resourceType": "OperationOutcome",
  "issue": [ {
    "severity": "error",
    "code": "processing",
    "diagnostics": "HAPI-0450: Failed to parse request body as JSON resource. Error was: HAPI-1814: Incorrect resource type found, expected \"Bundle\" but found \"Library\""
  } ]
}
```
Guess I need to put it in a bundle. I see a bundle folder but nothing useful in it, even after running _refresh. Let's try `bash _genonce.sh`

Try this:

```
curl -d "@bundles/BreastCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
That worked. Now what shows up on the server? It's there. 

Try:
```
curl -d "@bundles/BreastCancerScreeningCDS-plan-definition.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

That worked too. 

2024-02-07

Having uploaded that stuff, querying like this
```
http://localhost:8080/fhir/PlanDefinition/BreastCancerConcepts/$apply?subject=Patient/heslinga-dan
```
returns
```
{
  "resourceType": "CarePlan",
  "id": "BreastCancerConcepts",
  "contained": [ {
    "resourceType": "RequestGroup",
    "id": "BreastCancerConcepts",
    "extension": [ {
      "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-messages",
      "valueReference": {
        "reference": "#apply-outcome-BreastCancerConcepts"
      }
    } ],
    "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
    "status": "draft",
    "intent": "proposal",
    "subject": {
      "reference": "Patient/heslinga-dan"
    }
  }, {
    "resourceType": "OperationOutcome",
    "id": "apply-outcome-BreastCancerConcepts",
    "issue": [ {
      "severity": "error",
      "code": "exception",
      "diagnostics": "Condition expression Recommendation is applicable encountered exception: Could not resolve expression reference 'Recommendation is applicable' in library 'BreastCancerScreeningCDS'."
    } ]
  } ],
  "extension": [ {
    "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-messages",
    "valueReference": {
      "reference": "#apply-outcome-BreastCancerConcepts"
    }
  } ],
  "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
  "status": "draft",
  "intent": "proposal",
  "subject": {
    "reference": "Patient/heslinga-dan"
  },
  "activity": [ {
    "reference": {
      "reference": "#RequestGroup/BreastCancerConcepts"
    }
  } ]
}
```
Note the `Could not resolve expression reference 'Recommendation is applicable' in library 'BreastCancerScreeningCDS'`. Troubleshoot. 

I had to delete the url PlanDefinition/BreastCancerConcepts. It should be PlanDefinition/BreastCancerScreening CDS. PUT a new PlanDefinition, again using
```
curl -d "@bundles/BreastCancerScreeningCDS-plan-definition.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
There's a PUT request in the bundle so it's idempotent. 

Now again try the apply like so:
```
http://localhost:8080/fhir/PlanDefinition/BreastCancerScreeningCDS/$apply?subject=Patient/heslinga-dan
```
Now I've assembled the three valueset in a bundle and will push them to the server. 
```
curl -d "@bundles/BreastCancerScreeningCDS-valuesets.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

That seemed to go well. 

Rerunning the $apply operation:
```
http://localhost:8080/fhir/PlanDefinition/BreastCancerScreeningCDS/$apply?subject=Patient/heslinga-dan
```
this time yields a CarePlan (without errors)
```
{
  "resourceType": "CarePlan",
  "id": "BreastCancerScreeningCDS",
  "contained": [ {
    "resourceType": "RequestGroup",
    "id": "BreastCancerScreeningCDS",
    "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
    "status": "draft",
    "intent": "proposal",
    "subject": {
      "reference": "Patient/heslinga-dan"
    }
  } ],
  "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
  "status": "draft",
  "intent": "proposal",
  "subject": {
    "reference": "Patient/heslinga-dan"
  },
  "activity": [ {
    "reference": {
      "reference": "#RequestGroup/BreastCancerScreeningCDS"
    }
  } ]
}
```

I wonder what I would get with a female patient. All patients on the server at present are male. Let's upload one of the female test patients. I created a new test patient from bcc-CQL-Testing-Framework.
```
curl -d "@bundles/overdue-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```

Whooopee! We have a response with a `CarePlan` containe a `RequestGroup` with an `action` attribute with all of the appropriate `title`, `description` and `documentation`and `condition` attributes. But don't get too excited. There are errors. 

```{
  "resourceType": "CarePlan",
  "id": "BreastCancerScreeningCDS",
  "contained": [ {
    "resourceType": "RequestGroup",
    "id": "BreastCancerScreeningCDS",
    "extension": [ {
      "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-messages",
      "valueReference": {
        "reference": "#apply-outcome-BreastCancerScreeningCDS"
      }
    } ],
    "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
    "status": "draft",
    "intent": "proposal",
    "subject": {
      "reference": "Patient/309"
    },
    "action": [ {
      "title": "Breast Cancer Screening",
      "description": "The U.S. Preventive Services Task Force (2016) recommends screening for Breast cancer starting at age 50 years and continuing until age 75 years. This is a Grade A recommendation (U.S. Preventive Services Task Force, 2016).",
      "documentation": [ {
        "type": "documentation",
        "display": "U.S. Preventive Services Task Force Final Recommendation Statement Breast Cancer: Screening",
        "url": "https://www.uspreventiveservicestaskforce.org/uspstf/recommendation/breast-cancer-screening"
      } ],
      "condition": [ {
        "kind": "applicability",
        "expression": {
          "language": "text/cql-identifier",
          "expression": "Due for screening mammogram"
        }
      } ]
    } ]
  }, {
    "resourceType": "OperationOutcome",
    "id": "apply-outcome-BreastCancerScreeningCDS",
    "issue": [ {
      "severity": "error",
      "code": "exception",
      "diagnostics": "DynamicValue expression Get Card Detail encountered exception: Unable to resolve path $this."
    }, {
      "severity": "error",
      "code": "exception",
      "diagnostics": "DynamicValue expression Get Card Summary encountered exception: Unable to resolve path $this."
    }, {
      "severity": "error",
      "code": "exception",
      "diagnostics": "DynamicValue expression Get Card Indicator encountered exception: Unable to resolve path $this."
    } ]
  } ],
  "extension": [ {
    "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-messages",
    "valueReference": {
      "reference": "#apply-outcome-BreastCancerScreeningCDS"
    }
  } ],
  "instantiatesCanonical": [ "http://fhir.org/guides/dhes/bcc/PlanDefinition/BreastCancerScreeningCDS|0.1.0" ],
  "status": "draft",
  "intent": "proposal",
  "subject": {
    "reference": "Patient/309"
  },
  "activity": [ {
    "reference": {
      "reference": "#RequestGroup/BreastCancerScreeningCDS"
    }
  } ]
}
```

Post an updated plandefinition to try to address this error. 
```
curl -d "@bundles/BreastCancerScreeningCDS-plan-definition.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir
```
So now I have a fresh download of the hipa jpaserver. Of course it has no Plandefinition resources. I'l try uploading the cqf-ccc CDS bundle and see what I get. (from the cql-ccc root!)
```
curl -d "@bundles/plandefinition/ColorectalCancerScreeningCDS/ColorectalCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST http://localhost:8080/fhir

```