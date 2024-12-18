library BreastCancerScreeningCDS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

// include BreastCancerElements called BCE
include BreastCancerConcepts called Bx

// QUESTION: Should this be a single timepoint, or is a period required?
//parameter AsOf DateTime default Now()

/*
NOTE: Introduced Measurement Period as the parameter here for demonstration purposes
so it will run on the current implementations.
*/
// parameter "Measurement Period" Interval<DateTime>
//   default Interval[Now() - 2 years, Now()]

// parameter "Null Patient.deceased assumed to mean alive" Boolean default false 

code "MG Breast Screening": '24606-6' from FC."LOINC" display 'MG Breast Screening' // AKA 2D mammogram
code "DBT Breast - bilateral screening": '72142-3' from FC."LOINC" display 'DBT Breast - bilateral screening' // AKA 3D mammogram
concept "Mammography screening": { "MG Breast Screening", "DBT Breast - bilateral screening" } display 'Mammography screening'

// High risk breast biopsy. The first two are considered equivalent. The last two have no corresponding ICD10. 
codesystem "ICD10": 'http://hl7.org/fhir/sid/icd-10'
code "Atypical ductal hyperplasia of the breast": 'D05.10' from "ICD10" display 'Atypical ductal hyperplasia (ADH) of the breast'
code "Atypical hyperplasia of lactiferous duct (disorder)": '427785007' from FC."SNOMEDCT" display 'Atypical hyperplasia of lactiferous duct (disorder)'
code "Atypical lobular hyperplasia of breast (disorder)": '450697004' from FC."SNOMEDCT" display 'Atypical lobular hyperplasia of breast (disorder)'
code "Lobular carcinoma in situ of breast (disorder)": '109888004' from FC."SNOMEDCT" display 'Lobular carcinoma in situ of breast (disorder)'
concept "High risk biopsy": { 
	"Atypical ductal hyperplasia of the breast",
	"Atypical hyperplasia of lactiferous duct (disorder)", 
	"Atypical lobular hyperplasia of breast (disorder)",
	"Lobular carcinoma in situ of breast (disorder)"
}

code "Genetic susceptibility to malignant neoplasm of breast": 'Z15.01' from "ICD10" display 'Genetic susceptibility to malignant neoplasm of breast'
code "Hereditary breast and ovarian cancer syndrome (disorder)": '718220008' from FC."SNOMEDCT" display 'Hereditary breast and ovarian cancer syndrome (disorder)'
concept "Genetic susceptibility": {
	"Genetic susceptibility to malignant neoplasm of breast",
	"Hereditary breast and ovarian cancer syndrome (disorder)"
}

parameter "Reference dateTime" DateTime
  // default  @2024-01-01// for testing with ExecuteCQL
  default Today() // for testing within a CQL Testing Framework project

context Patient

define ReferenceDate:
  date from "Reference dateTime"

// First and foremost, are you alive? Are you an active patient? 

define `1-note`:
  ( singleton from ( Patient.extension E
        where E.url = 'http://example.org/fhir/StructureDefinition/patient-annotation'
    )
  ).value.value

// define `2-summary`:
//   "Alive"
//   and "Active"
  // and "Woman aged 40 to 74 years inclusive" 
  // and not Excluded // with bilateral mastectomy or has breast cancer
  // and not "Mammogram within 24 months"

define "Alive": 
  case 
    when Patient.deceased = false then true
    when Patient.deceased is null then true
    else false
  end

define Active: 
  if Patient.active = true then true
	else false

define Woman:
  Patient.gender = 'female'

define Age:
  // AgeInYears()
  AgeInYearsAt(ReferenceDate)

define AgeToString:
  ToString(Age)

define "aged 40 to 74 years inclusive": 
  Age between 40 and 74 // `between` is inclusive

define "aged 40 to 74 years inclusive ToString": 
  ToString("aged 40 to 74 years inclusive")

define "Woman aged 40 to 74 years inclusive":
  Woman and "aged 40 to 74 years inclusive"

define "Bilateral Mastectomy Procedure":
  [Procedure: Bx."Bilateral Mastectomy"] BilateralMastectomyPerformed // the procedure
    where BilateralMastectomyPerformed.status~'completed'

define "Bilateral Mastectomy Diagnosis":
  [Condition: Bx."History of bilateral mastectomy"] BilateralMastectomyHistory // the condition
  where BilateralMastectomyHistory.verificationStatus ~ FC."confirmed"

define "History of bilateral mastectomy":
  "Bilateral Mastectomy Performed"

define "Bilateral Mastectomy Performed":
	exists "Bilateral Mastectomy Diagnosis"
	or exists "Bilateral Mastectomy Procedure"

define "Breast Cancer Diagnosis":
  exists ([Condition: Bx."Breast Cancer Diagnoses"] Dx
  where Dx.verificationStatus ~ FC."confirmed"
  and Dx.clinicalStatus ~ FC."active")

define "History of high risk biopsy":
	exists ([Condition: "High risk biopsy"] C
		where C.verificationStatus ~ FC."confirmed"
		and C.clinicalStatus ~ FC."active")

define "Genetic susceptibility history":
	exists ([Condition: "Genetic susceptibility"] C
		where C.verificationStatus ~ FC."confirmed"
		and C.clinicalStatus ~ FC."active")

define "Excluded":
  "History of bilateral mastectomy"
  or "Breast Cancer Diagnosis"
  or "History of high risk biopsy"
	or "Genetic susceptibility history"

define "Mammography Performed":
// This worked with the old valueset "Mammogram"
// [Observation: Bx."Mammography"] Mammogram
//   where Mammogram.status = 'final'
  [Observation: "Mammography screening"] O
// where O.code in BreastCancerScreeningLOINCCodes
// where O.status = 'final'
// and O.code ~ "Mammography screening"

define function MostRecent(observations List<Observation>, asOf Date):
  Last(
    observations O
      // where O.effective is FHIR.dateTime
        // and O.effective <= asOf
    sort by effective
  )

define "Most recent mammogram":
  MostRecent("Mammography Performed", ReferenceDate)

define "Most recent mammogram date":
  date from "Most recent mammogram".effective

define "Months elapsed":
  months between "Most recent mammogram date" and ReferenceDate

define "Mammogram within 24 months":
  exists "Mammography Performed" P
  // where P.issued >= (ReferenceDate - 2 years)
  where "Months elapsed" <= 23

define "Due for screening mammogram": //"applicable" in the sense that this patient is eligible and due. 
  "Alive"
  and "Active"
  and "Woman aged 40 to 74 years inclusive" 
  and not Excluded // with bilateral mastectomy or has breast cancer
  and not "Mammogram within 24 months"

define "Get Card Summary":
  if "Due for screening mammogram" then
    'Due for screening mammogram'
  else
    null

define "Get Card Indicator":
  // if "Is Recommendation Applicable" then
  if "Due for screening mammogram"
  then 'asap'
  else null

define "Get Card Detail":
  if "Due for screening mammogram" then
    'This patient is due for mammogram, with ' + Rationale + '.'
  else
    null

define Rationale:
  if "Due for screening mammogram"
  then Coalesce({
    ' the most recent mammogram performed on ' + ToString(date from "Most recent mammogram date") + '.',
    ' no mammogram on file'
  })
  else null


