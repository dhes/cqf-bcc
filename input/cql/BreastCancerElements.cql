library BreastCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include BreastCancerConcepts called Bx

parameter "Measurement Period" Interval<DateTime>
default Interval[Now() - 1 year, Now()]

//Code '7771000' from "SNOMEDCT" //Left (qualifier value)'
code "Left (qualifier value)":
  '7771000' from FC."SNOMEDCT" display 'Left (qualifier value)'

// Concept {
//   Code '7771000' from FC."SNOMEDCT"
// } display "Left (qualifier value)"

// code "Left breast":
//   '80248007 ' from FC."SNOMEDCT" display 'Left breast'

// code "Right breast":
//   // '80248007 ' from FC."SNOMEDCT" display 'Left breast'

context Patient

define "Is female":
  Patient.gender in Bx."Female Gender"

define AsOf:
  end of "Measurement Period"

// pointInTime is not defined
// define "Global.NormalizeInterval(pointInTime DateTime, period Interval<DateTime>)":
//   if pointInTime is NOT null then Interval[pointInTime, pointInTime]
//   else if period is NOT null then period
//   else null AS Interval<DateTime>

define "Bilateral Mastectomy Procedure":
  [Procedure: Bx."Bilateral Mastectomy"] BilateralMastectomyPerformed // the procedure
    where BilateralMastectomyPerformed.status='completed'
//  and Global."NormalizeInterval" ( BilateralMastectomyPerformed.relevantDatetime, BilateralMastectomyPerformed.relevantPeriod ) ends on or before
// end of "Measurement Period"

define "Bilateral Mastectomy Diagnosis":
  [Condition: Bx."History of bilateral mastectomy"] BilateralMastectomyHistory // the condition
    where BilateralMastectomyHistory.clinicalStatus in FC."Active Condition"
  and BilateralMastectomyHistory.verificationStatus ~ FC."confirmed"
// WHERE BilateralMastectomyHistory.prevalencePeriod starts on or before
// end of "Measurement Period"

define "Left Mastectomy Procedure":
  [Procedure: Bx."Unilateral Mastectomy Left"] UnilateralMastectomyLeftPerformed // the procedure
    where UnilateralMastectomyLeftPerformed.status='completed'
//  and Global."NormalizeInterval" ( UnilateralMastectomyLeftPerformed.relevantDatetime, UnilateralMastectomyLeftPerformed.relevantPeriod ) ends on or before
// end of "Measurement Period"

// Left/Right Mastectomy Diagnosis is in a hack stage at present. 
// the bodySite condition produces ELM transation errors so I have left it out for now
// However the overall logic is that a unilateral mastectomy whichever side takes you out of the denominator
// Whether the laterality is know is unimportant in the measure score. 
// It might be better form to created another exclusion "Unilateral Mastectomy"
// Better yet, sort out the error. 
define "Left Mastectomy Diagnosis":
  ( [Condition: Bx."Left Mastectomy Diagnosis"] 
    union ( [Condition: Bx."Unilateral Mastectomy, Unspecified Laterality, Diagnosis"] // UnilateralMastectomyDiagnosis
      // where UnilateralMastectomyDiagnosis.bodySite ~ code '7771000' from FC."SNOMEDCT"
    ) 
  ) LeftMastectomy
where LeftMastectomy.clinicalStatus in FC."Active Condition"
  and LeftMastectomy.verificationStatus ~ FC."confirmed"
// WHERE LeftMastectomy.prevalencePeriod starts on or before
// end of "Measurement Period"

define "Right Mastectomy Procedure":
  [Procedure: Bx."Unilateral Mastectomy Right"] UnilateralMastectomyRightPerformed
    where UnilateralMastectomyRightPerformed.status='completed'
//  and Global."NormalizeInterval" ( UnilateralMastectomyRightPerformed.relevantDatetime, UnilateralMastectomyRightPerformed.relevantPeriod ) ends on or before
// end of "Measurement Period"

define "Right Mastectomy Diagnosis":
  ( [Condition: Bx."Right Mastectomy Diagnosis"] 
     union  ( [Condition: Bx."Unilateral Mastectomy, Unspecified Laterality, Diagnosis"] UnilateralMastectomyDiagnosis
      //  where UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ code '24028007' from FC."SNOMEDCT"
    )
) RightMastectomy
  where RightMastectomy.clinicalStatus in FC."Active Condition"
  and RightMastectomy.verificationStatus ~ FC."confirmed"
// WHERE RightMastectomy.prevalencePeriod starts on or before
// end of "Measurement Period"

define "Bilateral Mastectomy Performed":
  ( ( exists ( Bx."Right Mastectomy Diagnosis" )
 or exists ( "Right Mastectomy Procedure" )
)
 and ( exists ( Bx."Left Mastectomy Diagnosis" )
 or exists ( "Left Mastectomy Procedure" )
)
)
 or exists "Bilateral Mastectomy Diagnosis"
 or exists "Bilateral Mastectomy Procedure"

define "Mammography Performed":
[Procedure: Bx."Mammography"] Mammogram
where Mammogram.status = 'completed'

define function MostRecent(procedures List<Procedure>, asOf DateTime):
  First(
    procedures P
      sort by start of FC.ToInterval(performed)
  )

define "Most Recent Mammogram":
  MostRecent("Mammography Performed", AsOf)

define "Mammography Performed Within 27 Months":
"Mammography Performed" P
where FC.ToInterval(P.performed) ends 27 months or less on or before AsOf

define "Has Appropriate Breast Cancer Screening":
exists "Mammography Performed Within 27 Months"
