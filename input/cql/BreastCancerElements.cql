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

define AsOf:
  end of "Measurement Period"

// TODO
// this is from ccc
// it's not present in the official quality measures
// it probably should be in the CDS (and the CQM)
// define "Active Malignant Neoplasm":
  // [Condition: Cx."Malignant Neoplasm of Colon"] ColorectalCancer
  //   where ColorectalCancer.clinicalStatus in FC."Active Condition"
  //     and ColorectalCancer.verificationStatus ~ FC."confirmed"
// consider something analagous here, like
// define "Active Malignant Neoplasm":
  // [Condition: Cx."Malignant Neoplasm of Breast"] BreastCancer
  //   where BreastCancer.clinicalStatus in FC."Active Condition"
  //     and BreastCancer.verificationStatus ~ FC."confirmed"




