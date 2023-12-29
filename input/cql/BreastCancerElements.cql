library BreastCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include BreastCancerConcepts called Bx

// QUESTION: Should this be a single timepoint, or is a period required?
//parameter AsOf DateTime default Now()

/*
NOTE: Introduced Measurement Period as the parameter here for demonstration purposes
so it will run on the current implementations.
*/
parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 1 year, Now()]

context Patient

define "Has Appropriate Breast Cancer Screening":
exists ( ["Diagnostic Study, Performed": "Mammography"] Mammogram
WHERE ( Global."NormalizeInterval" ( Mammogram.relevantDatetime, Mammogram.relevantPeriod ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period",
end of "Measurement Period"]
)
)

define "Bilateral Mastectomy Performed":
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

define AsOf:
  end of "Measurement Period"

// TODO (but not required)
// this is from bcc
// it's not present in the official quality measures
// it probably should be in the CDS (and the CQM)
// define "Active Malignant Neoplasm":
  // [Condition: Cx."Malignant Neoplasm of Colon"] BreastCancer
  //   where BreastCancer.clinicalStatus in FC."Active Condition"
  //     and BreastCancer.verificationStatus ~ FC."confirmed"
// consider something analagous here, like
// define "Active Malignant Neoplasm":
  // [Condition: Cx."Malignant Neoplasm of Breast"] BreastCancer
  //   where BreastCancer.clinicalStatus in FC."Active Condition"
  //     and BreastCancer.verificationStatus ~ FC."confirmed"

define "Bilateral Mastectomy Diagnosis":
["Diagnosis": "History of bilateral mastectomy"] BilateralMastectomyHistory
WHERE BilateralMastectomyHistory.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Bilateral Mastectomy Procedure":
["Procedure, Performed": "Bilateral Mastectomy"] BilateralMastectomyPerformed
WHERE Global."NormalizeInterval" ( BilateralMastectomyPerformed.relevantDatetime, BilateralMastectomyPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

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

// This seems redundant
// define "Numerator":
// exists ( ["Diagnostic Study, Performed": "Mammography"] Mammogram
// WHERE ( Global."NormalizeInterval" ( Mammogram.relevantDatetime, Mammogram.relevantPeriod ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period",
// end of "Measurement Period"]
// )
// )

define "October 1 Two Years Prior to the Measurement Period":
DateTime((year from start of "Measurement Period" - 2), 10, 1, 0, 0, 0, 0, 0)

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

// this doesn't seem be used
//
// define "SDE Sex":
// ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Global.NormalizeInterval(pointInTime DateTime, period Interval<DateTime>)":
if pointInTime is NOT null then Interval[pointInTime, pointInTime]
else if period is NOT null then period
else null AS Interval<DateTime>