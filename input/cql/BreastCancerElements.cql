library BreastCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include BreastCancerConcepts called Bx

parameter "Measurement Period" Interval<DateTime>
default Interval[Now() - 1 year, Now()]

context Patient

define AsOf:
end of "Measurement Period"

define "Global.NormalizeInterval(pointInTime DateTime, period Interval<DateTime>)":
if pointInTime is NOT null then Interval[pointInTime, pointInTime]
else if period is NOT null then period
else null AS Interval<DateTime>

define "Left Mastectomy Procedure":
[Procedure: "Unilateral Mastectomy Left"] UnilateralMastectomyLeftPerformed
WHERE UnilateralMastectomyLeftPerformed.status='completed'
 AND Global."NormalizeInterval" ( UnilateralMastectomyLeftPerformed.relevantDatetime, UnilateralMastectomyLeftPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

define "Right Mastectomy Procedure":
[Procedure: "Unilateral Mastectomy Right"] UnilateralMastectomyRightPerformed
WHERE UnilateralMastectomyRightPerformed.status='completed'
 AND Global."NormalizeInterval" ( UnilateralMastectomyRightPerformed.relevantDatetime, UnilateralMastectomyRightPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

define "Bilateral Mastectomy Procedure":
[Procedure, : "Bilateral Mastectomy"] BilateralMastectomyPerformed
WHERE BilateralMastectomyPerformed.status='completed'
 AND Global."NormalizeInterval" ( BilateralMastectomyPerformed.relevantDatetime, BilateralMastectomyPerformed.relevantPeriod ) ends on OR before
end of "Measurement Period"

define "Left Mastectomy Diagnosis":
( ["Diagnosis": "Status Post Left Mastectomy"]
UNION ( ["Diagnosis": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
WHERE UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ "Left (qualifier value)"
) ) LeftMastectomy
WHERE LeftMastectomy.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Right Mastectomy Diagnosis":
( ["Diagnosis": "Status Post Right Mastectomy"] RightMastectomyProcedure
UNION ( ["Diagnosis": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
WHERE UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ "Right (qualifier value)"
) ) RightMastectomy
WHERE RightMastectomy.prevalencePeriod starts on OR before
end of "Measurement Period"

define "Bilateral Mastectomy Diagnosis":
["Diagnosis": "History of bilateral mastectomy"] BilateralMastectomyHistory
WHERE BilateralMastectomyHistory.prevalencePeriod starts on OR before
end of "Measurement Period"

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

define "Mammography Performed":
[Procedure: Bx."Mammography"] Mammogram
WHERE Mammogram.status = 'completed'

define "Mammography Performed Within 27 Months":
"Mammography Performed" P
WHERE FC.ToInterval(P.performed) ends 27 months OR less on OR before AsOf

define "Has Appropriate Breast Cancer Screening":
exists "Mammography Performed Within 27 Months"
