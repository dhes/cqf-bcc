// As in cqf-bcc I have begun with the CQL posted at
// https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS125v12.html,
// then modified the code in a similar fashion as apparently done by Alphora in cqf-bcc.
// The modification consist of simplifications and migration of some code snippets into
// an elements library, here called BreastCancerElements.cql

// This quality measure does not appear to have an exclusion for a diagnosis of Malignant Neoplasm of breast
// Evidently the reasoning is "If you haven't had a mastectomy you don't have breast cancer". 

// This is the modified version of the CMS125 code

include BreastCancerScreeningCQM version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

// Proposed change to CQL to support binding of parameters of included libraries:
// https://jira.hl7.org/browse/FHIR-33126
include BreasCancerElements called BCE

/*
NOTE: Introduced Measurement Period as the parameter here for demonstration purposes
so it will run on the current implementations.
*/
parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 1 year, Now()]

context Patient

define "Initial Population":
exists ( ["Patient Characteristic Sex": "Female"] )
 AND AgeInYearsAt(date from end of "Measurement Period"
) IN Interval[52, 74]
//  AND exists AdultOutpatientEncounters."Qualifying Encounters"

define "Denominator":
"Initial Population"

define "Denominator Exclusions":
// Hospice."Has Hospice Services"
( ( exists ( "Right Mastectomy Diagnosis" )
 OR exists ( "Right Mastectomy Procedure" )
)
 AND ( exists ( "Left Mastectomy Diagnosis" )
 OR exists ( "Left Mastectomy Procedure" )
)
)
 OR exists "Bilateral Mastectomy Diagnosis"
 OR exists "Bilateral Mastectomy Procedure"
//  OR AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
//  OR AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
//  OR PalliativeCare."Has Palliative Care in the Measurement Period"

define "Numerator":
exists ( ["Diagnostic Study, Performed": "Mammography"] Mammogram
WHERE ( Global."NormalizeInterval" ( Mammogram.relevantDatetime, Mammogram.relevantPeriod ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period",
end of "Measurement Period"]
)
)

// Numerator Exclusions
// None

// Denominator Exceptions
// None

// Stratification
// None

// Definitions

// define "AdultOutpatientEncounters.Qualifying Encounters":
// ( ["Encounter, Performed": "Office Visit"]
// UNION ["Encounter, Performed": "Annual Wellness Visit"]
// UNION ["Encounter, Performed": "Preventive Care Services Established Office Visit, 18 and Up"]
// UNION ["Encounter, Performed": "Preventive Care Services Initial Office Visit, 18 and Up"]
// UNION ["Encounter, Performed": "Home Healthcare Services"]
// UNION ["Encounter, Performed": "Online Assessments"]
// UNION ["Encounter, Performed": "Telephone Visits"] ) ValidEncounter
// WHERE ValidEncounter.relevantPeriod during day of "Measurement Period"

// define "AIFrailLTCF.Has Criteria Indicating Frailty":
// exists ( ["Device, Order": "Frailty Device"] FrailtyDeviceOrder
// WHERE FrailtyDeviceOrder.authorDatetime during day of "Measurement Period"
// )
//  OR exists ( ["Assessment, Performed": "Medical equipment used"] EquipmentUsed
// WHERE EquipmentUsed.result IN "Frailty Device"
//  AND Global."NormalizeInterval" ( EquipmentUsed.relevantDatetime, EquipmentUsed.relevantPeriod ) ends during day of "Measurement Period"
// )
//  OR exists ( ["Diagnosis": "Frailty Diagnosis"] FrailtyDiagnosis
// WHERE FrailtyDiagnosis.prevalencePeriod overlaps "Measurement Period"
// )
//  OR exists ( ["Encounter, Performed": "Frailty Encounter"] FrailtyEncounter
// WHERE FrailtyEncounter.relevantPeriod overlaps "Measurement Period"
// )
//  OR exists ( ["Symptom": "Frailty Symptom"] FrailtySymptom
// WHERE FrailtySymptom.prevalencePeriod overlaps "Measurement Period"
// )

// define "AIFrailLTCF.Has Dementia Medications IN Year Before OR During Measurement Period"
// exists (["Medication, Active": "Dementia Medications"] DementiaMedication
// WHERE Global."NormalizeInterval" ( DementiaMedication.relevantDatetime, DementiaMedication.relevantPeriod ) overlaps Interval[start of "Measurement Period" - 1 year,
// end of "Measurement Period"])

// define "AIFrailLTCF.Has Inpatient Encounter WITH Advanced Illness":
// exists( ["Encounter, Performed": "Acute Inpatient"] InpatientEncounter
// WHERE exists ( InpatientEncounter.diagnoses Diagnosis
// WHERE Diagnosis.code IN "Advanced Illness"
// )
//  AND InpatientEncounter.relevantPeriod starts during day of Interval[start of "Measurement Period" - 1 year,
// end of "Measurement Period"])

// define "AIFrailLTCF.Has Two Outpatient Encounters WITH Advanced Illness on Different Dates of Service":
// exists (
// from
// "Outpatient Encounters with Advanced Illness" OutpatientEncounter1,
// "Outpatient Encounters with Advanced Illness" OutpatientEncounter2
// WHERE OutpatientEncounter2.relevantPeriod ends 1 day OR more after day of
// end of OutpatientEncounter1.relevantPeriod
// RETURN OutpatientEncounter1
// )

// define "AIFrailLTCF.Is Age 66 OR Older Living Long Term IN a Nursing Home":
// ( AgeInYearsAt(date from
// end of "Measurement Period"
// )>= 66
// )
//  AND ( ( Last(["Assessment, Performed": "Housing status"] HousingStatus
// WHERE Global."NormalizeInterval"(HousingStatus.relevantDatetime, HousingStatus.relevantPeriod)ends on OR before
// end of "Measurement Period"
// sort by
// end of Global."NormalizeInterval"(relevantDatetime, relevantPeriod)asc
// )) LastHousingStatus
// WHERE LastHousingStatus.result ~ "Lives in a nursing home (finding)"
// ) is NOT null

// define "AIFrailLTCF.Is Age 66 OR Older WITH Advanced Illness AND Frailty":
// ( AgeInYearsAt(date from
// end of "Measurement Period"
// )>= 66
//  AND "Has Criteria Indicating Frailty"
//  AND ( "Has Two Outpatient Encounters with Advanced Illness on Different Dates of Service"
//  OR "Has Inpatient Encounter with Advanced Illness"
//  OR "Has Dementia Medications in Year Before or During Measurement Period"
// )
// )

// define "AIFrailLTCF.Outpatient Encounters WITH Advanced Illness":
// ( ["Encounter, Performed": "Outpatient"]
// UNION ["Encounter, Performed": "Observation"]
// UNION ["Encounter, Performed": "Emergency Department Evaluation and Management Visit"]
// UNION ["Encounter, Performed": "Nonacute Inpatient"] ) OutpatientEncounter
// WHERE exists ( OutpatientEncounter.diagnoses Diagnosis
// WHERE Diagnosis.code IN "Advanced Illness"
// )
//  AND OutpatientEncounter.relevantPeriod starts during day of Interval[start of "Measurement Period" - 1 year,
// end of "Measurement Period"]

define "Bilateral Mastectomy Diagnosis":
["Diagnosis": "History of bilateral mastectomy"] BilateralMastectomyHistory
WHERE BilateralMastectomyHistory.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Bilateral Mastectomy Procedure":
["Procedure, Performed": "Bilateral Mastectomy"] BilateralMastectomyPerformed
WHERE Global."NormalizeInterval" ( BilateralMastectomyPerformed.relevantDatetime, BilateralMastectomyPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

define "Denominator":
"Initial Population"

define "Denominator Exclusions":
// Hospice."Has Hospice Services"
( ( exists ( "Right Mastectomy Diagnosis" )
 OR exists ( "Right Mastectomy Procedure" )
)
 AND ( exists ( "Left Mastectomy Diagnosis" )
 OR exists ( "Left Mastectomy Procedure" )
)
)
 OR exists "Bilateral Mastectomy Diagnosis"
 OR exists "Bilateral Mastectomy Procedure"
//  OR AIFrailLTCF."Is Age 66 or Older with Advanced Illness and Frailty"
//  OR AIFrailLTCF."Is Age 66 or Older Living Long Term in a Nursing Home"
//  OR PalliativeCare."Has Palliative Care in the Measurement Period"

// define "Hospice.Has Hospice Services":
// exists ( ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
// WHERE ( InpatientEncounter.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
//  OR InpatientEncounter.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
// )
//  AND InpatientEncounter.relevantPeriod ends during day of "Measurement Period"
// )
//  OR exists ( ["Encounter, Performed": "Hospice Encounter"] HospiceEncounter
// WHERE HospiceEncounter.relevantPeriod overlaps day of "Measurement Period"
// )
//  OR exists ( ["Assessment, Performed": "Hospice care [Minimum Data Set]"] HospiceAssessment
// WHERE HospiceAssessment.result ~ "Yes (qualifier value)"
//  AND Global."NormalizeInterval" ( HospiceAssessment.relevantDatetime, HospiceAssessment.relevantPeriod ) overlaps day of "Measurement Period"
// )
//  OR exists ( ["Intervention, Order": "Hospice Care Ambulatory"] HospiceOrder
// WHERE HospiceOrder.authorDatetime during day of "Measurement Period"
// )
//  OR exists ( ["Intervention, Performed": "Hospice Care Ambulatory"] HospicePerformed
// WHERE Global."NormalizeInterval" ( HospicePerformed.relevantDatetime, HospicePerformed.relevantPeriod ) overlaps day of "Measurement Period"
// )
//  OR exists ( ["Diagnosis": "Hospice Diagnosis"] HospiceCareDiagnosis
// WHERE HospiceCareDiagnosis.prevalencePeriod overlaps day of "Measurement Period"
// )

// Redundant, right? But it's in the spec!
// define "Initial Population":
// exists ( ["Patient Characteristic Sex": "Female"] )
//  AND AgeInYearsAt(date from
// end of "Measurement Period"
// ) IN Interval[52, 74]
//  AND exists AdultOutpatientEncounters."Qualifying Encounters"

define "Left Mastectomy Diagnosis":
( ["Diagnosis": "Status Post Left Mastectomy"]
UNION ( ["Diagnosis": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
WHERE UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ "Left (qualifier value)"
) ) LeftMastectomy
WHERE LeftMastectomy.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Left Mastectomy Procedure":
["Procedure, Performed": "Unilateral Mastectomy Left"] UnilateralMastectomyLeftPerformed
WHERE Global."NormalizeInterval" ( UnilateralMastectomyLeftPerformed.relevantDatetime, UnilateralMastectomyLeftPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

define "Numerator":
exists ( ["Diagnostic Study, Performed": "Mammography"] Mammogram
WHERE ( Global."NormalizeInterval" ( Mammogram.relevantDatetime, Mammogram.relevantPeriod ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period",
end of "Measurement Period"]
)
)

define "October 1 Two Years Prior to the Measurement Period":
DateTime((year from start of "Measurement Period" - 2), 10, 1, 0, 0, 0, 0, 0)

// define "PalliativeCare.Has Palliative Care IN the Measurement Period":
// exists ( ["Assessment, Performed": "Functional Assessment of Chronic Illness Therapy - Palliative Care Questionnaire (FACIT-Pal)"] PalliativeAssessment
// WHERE Global."NormalizeInterval" ( PalliativeAssessment.relevantDatetime, PalliativeAssessment.relevantPeriod ) overlaps day of "Measurement Period"
// )
//  OR exists ( ["Diagnosis": "Palliative Care Diagnosis"] PalliativeDiagnosis
// WHERE PalliativeDiagnosis.prevalencePeriod overlaps day of "Measurement Period"
// )
//  OR exists ( ["Encounter, Performed": "Palliative Care Encounter"] PalliativeEncounter
// WHERE PalliativeEncounter.relevantPeriod overlaps day of "Measurement Period"
// )
//  OR exists ( ["Intervention, Performed": "Palliative Care Intervention"] PalliativeIntervention
// WHERE Global."NormalizeInterval" ( PalliativeIntervention.relevantDatetime, PalliativeIntervention.relevantPeriod ) overlaps day of "Measurement Period"
// )

define "Right Mastectomy Diagnosis":
( ["Diagnosis": "Status Post Right Mastectomy"] RightMastectomyProcedure
UNION ( ["Diagnosis": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
WHERE UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ "Right (qualifier value)"
) ) RightMastectomy
WHERE RightMastectomy.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Right Mastectomy Procedure":
["Procedure, Performed": "Unilateral Mastectomy Right"] UnilateralMastectomyRightPerformed
WHERE Global."NormalizeInterval" ( UnilateralMastectomyRightPerformed.relevantDatetime, UnilateralMastectomyRightPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

// define "SDE Ethnicity":
// ["Patient Characteristic Ethnicity": "Ethnicity"]

// define "SDE Payer":
// ["Patient Characteristic Payer": "Payer"]

// define "SDE Race":
// ["Patient Characteristic Race": "Race"]

define "SDE Sex":
["Patient Characteristic Sex": "ONC Administrative Sex"]

// Functions

define "Global.NormalizeInterval(pointInTime DateTime, period Interval<DateTime>)":
if pointInTime is NOT null then Interval[pointInTime, pointInTime]
else if period is NOT null then period
else null AS Interval<DateTime>
