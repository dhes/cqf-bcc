library BreastCancerConcepts version '0.1.0'

using FHIR version '4.0.1'

// codesystem "LOINC": 'http://loinc.org'
// code "MG Breast Screening": '24606-6' from "LOINC" display 'MG Breast Screening' // AKA 2D mammogram
// code "DBT Breast - bilateral screening": '72142-3' from "LOINC" display 'DBT Breast - bilateral screening' // AKA 3D mammogram

// valueset "Female Gender": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.560.100.2'
valueset "Bilateral Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005' // this valueset contains ICD10PCS and SNOMET codes but no CPT. Its total colectomy companion in cqf-ccc contains all three. That's a problem. To see for yourself search VASC for `mastectomy` with steward = NCQA and code system = [ICD10PCS, SNOMEDCT and CPT]. The only group with CPT codes are unilateral mastectomy. 
// Here is a design decision. I will consider CPT codes not essential because the use case is a primary care office, which does not perform mastectomies and therefore would not have use for the CPT code. 
// If that is acceptable then the above "Bilaterl Mastectomy" valueset is sufficient. Because ICD10 is more familiar to most US realm physicians I will use ICD10PCS code in the text examples. 
valueset "History of bilateral mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1068'
// valueset "Unilateral Mastectomy Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1133'
// valueset "Left Mastectomy Diagnosis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1069'
// valueset "Unilateral Mastectomy Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1134'
// valueset "Right Mastectomy Diagnosis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1070'
// valueset "Unilateral Mastectomy, Unspecified Laterality, Diagnosis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1071'
// valueset "Mammography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018'
// The next line replaces the "Mammography" valueset, which is too broad
// concept "Mammography screening": { "MG Breast Screening", "DBT Breast - bilateral screening" } display 'Mammography screening'
valueset "Breast Cancer Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.185'
// valueset "ONC Administrative Sex" 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
// valueset "Outpatient" 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1087'
