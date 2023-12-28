library BreastCancerScreeningCDS version '0.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

include BreastCancerElements called BCE

// QUESTION: Should this be a single timepoint, or is a period required?
//parameter AsOf DateTime default Now()

/*
NOTE: Introduced Measurement Period as the parameter here for demonstration purposes
so it will run on the current implementations.
*/
parameter "Measurement Period" Interval<DateTime>
  default Interval[Now() - 2 years, Now()]

context Patient

define "Is Recommendation Applicable":
  AgeInYearsAt(start of "Measurement Period") between 50 and 75
    and not BCE."Has Appropriate Breast Cancer Screening"
    // and not BCE."Has Active Malignant Neoplasm"
    and not exists (BCE."Bilateral Mastectomy Performed")

define "Get Card Summary":
  if "Is Recommendation Applicable" then
    'Recommend appropriate breast cancer screening'
  else
    'Patient has appropriate breast cancer screening'

define "Get Card Detail":
  if "Is Recommendation Applicable" then
    'Patient meets the inclusion criteria for appropriate breast cancer screening, but has ' + Rationale + '.'
  else
    'Patient has appropriate breast cancer screening: ' + Rationale + '.'

define "Rationale":
  Coalesce({
    'most recent mammogram performed on ' + ToString(date from CCE."Most Recent Mammogram".performed),
    // 'most recent FIT DNA issued on ' + ToString(date from CCE."Most Recent Fecal Immunochemical Test DNA Result".issued),
    // 'most recent CT Colonography performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent CT Colonography Performed".performed)),
    // 'most recent Flexible Sigmoidoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Flexible Sigmoidoscopy Performed".performed)),
    // 'most recent Colonoscopy performed on ' + ToString(date from start of FC.ToInterval(CCE."Most Recent Colonoscopy Performed".performed)),
    'no evidence of appropriate screening'
  })

define "Get Card Indicator":
  if "Is Recommendation Applicable" then
    'asap'
  else
    'routine'
