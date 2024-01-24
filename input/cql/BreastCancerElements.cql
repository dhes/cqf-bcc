library BreastCancerElements version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include BreastCancerConcepts called Bx

// parameter "Measurement Period" Interval<DateTime>
// default Interval[Now() - 1 year, Now()]

// for tests, fix the date
// in production, make it Now()
parameter "Reference Date" DateTime 
  default  @2024-01-01T00:00:00-06:00
  // default Now()

// //Code '7771000' from "SNOMEDCT" //Left (qualifier value)'
// code "Left (qualifier value)":
//   '7771000' from FC."SNOMEDCT" display 'Left (qualifier value)'

// define "what day is it":
//   "Reference Date"

// Concept {
//   Code '7771000' from FC."SNOMEDCT"
// } display "Left (qualifier value)"

// code "Left breast":
//   '80248007 ' from FC."SNOMEDCT" display 'Left breast'

// code "Right breast":
//   // '80248007 ' from FC."SNOMEDCT" display 'Left breast'

context Patient

// obsolescense candidate
// define "Is female":
//   // Patient.gender in Bx."Female Gender"
//   Patient.gender = 'female'

define Woman:
  Patient.gender = 'female'

define "Todays date":
  "Reference Date"

define BirthDate:
  ToString(Patient.birthDate)

define Age:
  AgeInYearsAt("Reference Date")
  // AgeInYearsAt(Today()) // production

// These revisions align the CQL variables with USPSTF language
// ...new...
// CDS version
define "aged 50 to 74 y inclusive":
  Age between 50 and 74 // `between` is inclusive
// CQM version
define "aged 52 to 74 y inclusive": // AKA "Initial Population"
  Age between 52 and 74 // `between` is inclusive

//...new...
// ...CDS...
// define "Woman aged 50 to 74 y inclusive":
//   Woman and "aged 50 to 74 y inclusive"
// ...CQM...
// define "Woman aged 52 to 74 y inclusive":
//   Woman and "aged 52 to 74 y inclusive"

// define AsOf:
//   end of "Measurement Period"

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
     union  ( [Condition: Bx."Unilateral Mastectomy, Unspecified Laterality, Diagnosis"] // UnilateralMastectomyDiagnosis
      //  where UnilateralMastectomyDiagnosis.anatomicalLocationSite ~ code '24028007' from FC."SNOMEDCT"
    )
) RightMastectomy
  where RightMastectomy.clinicalStatus in FC."Active Condition"
  and RightMastectomy.verificationStatus ~ FC."confirmed"
// WHERE RightMastectomy.prevalencePeriod starts on or before
// end of "Measurement Period"

define "Bilateral Mastectomy Performed":
  ( 
		(
			exists ( "Right Mastectomy Diagnosis" )
			or exists ( "Right Mastectomy Procedure" )
		)
			and 
		(
			exists ( "Left Mastectomy Diagnosis" )
			or exists ( "Left Mastectomy Procedure" )
		)
	)
				or exists "Bilateral Mastectomy Diagnosis"
				or exists "Bilateral Mastectomy Procedure"

define "Mammography Performed":
[Observation: Bx."Mammography"] Mammogram
where Mammogram.status = 'final'

define function MostRecent(observations List<Observation>, asOf DateTime):
  First(
    observations O
      sort by start of FC.ToInterval(issued)
  )

define "Most Recent Mammogram":
  MostRecent("Mammography Performed", "Reference Date")

define "Mammography Performed Within 27 Months": // relative to end of measurment period
"Mammography Performed" P
where FC.ToInterval(P.issued) ends 27 months or less on or before "Reference Date"

define "Mammography Performed Within 24 Months": // relative to end of measurment period
"Mammography Performed" P
where FC.ToInterval(P.issued) ends 24 months or less on or before "Reference Date"

// define "Has Appropriate Breast Cancer Screening":
// exists "Mammography Performed Within 27 Months"

define "Mammogram within 24 months":
  exists "Mammography Performed" P
  where P.issued >= ("Reference Date" - 2 years)

define "Mammogram within 27 months": // this may not be all that useful
  exists "Mammography Performed" P
  where P.issued >= ("Reference Date" - 27 months)
