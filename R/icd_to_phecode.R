icd_to_phecode = function(icd=NULL,
                          concept_type=NULL,
                          mapping=icd.phecode.map){
  
  ### concept_type must be either "DIAG-ICD9" or "DIAG-ICD10"
  id.keep=which(mapping$icdcode == icd & mapping$concept_type == concept_type)
  phecode=as.character(mapping[id.keep,"phecode"])
  return(phecode)
         
}



