// As in cqf-bcc I have begun with the CQL posted at
// https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS125v12.html,
// then modified the code in a similar fashion as apparently done by Alphora in cqf-bcc.
// The modification consist of simplifications and migration of some code snippets into
// an elements library, here called BreastCancerElements.cql

// This quality measure does not appear to have an exclusion for a diagnosis of Malignant Neoplasm of breast
// Evidently the reasoning is "If you haven't had a mastectomy you don't have breast cancer".

// This is the modified version of the CMS125 code

library BreastCancerScreeningCQM version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

include BreastCancerElements called BCE

parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 1 year, Now()]

context Patient

define "Age":
  AgeInYearsAt(start of "Measurement Period")

define "Age between 52 and 75":
  "Age" between 52 and 75

define "Woman aged 52 to 74 y inclusive":
  BCE.Woman and BCE."aged 52 to 74 y inclusive"

// define "Is female":
//   BCE."Is female"

define "Initial Population":
  BCE."Is female"
  and "Age between 52 and 75"

define "Denominator":
"Initial Population"

define "Numerator":
  BCE."Has Appropriate Breast Cancer Screening"

define "Denominator Exclusions":
  BCE."Bilateral Mastectomy Performed"

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


// define "SDE Ethnicity":
// ["Patient Characteristic Ethnicity": "Ethnicity"]

// define "SDE Payer":
// ["Patient Characteristic Payer": "Payer"]

// define "SDE Race":
// ["Patient Characteristic Race": "Race"]



// Functions


