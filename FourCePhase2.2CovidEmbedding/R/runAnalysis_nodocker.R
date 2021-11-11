
runAnalysis_nodocker=function(siteid, dir.input){
  data(icd.phecode.map, package="FourCePhase2.2CovidEmbedding")
  data(Labs_4CE, package="FourCePhase2.2CovidEmbedding")
  
  dat.po0=read.csv(paste0(dir.input,"/Phase22_LocalPatientObservations.csv"))
  dat.cc0=read.csv(paste0(dir.input,"/Phase22_LocalPatientClinicalCourse.csv"))
  dat.dem0=read.csv(paste0(dir.input,"/Phase22_LocalPatientSummary.csv"))
  dat.race0=read.csv(paste0(dir.input,"/Phase22_LocalPatientRace.csv"))
  
  patient_num.keep=unique(dat.po0[dat.po0$concept_code=="covidpos","patient_num"])
  dat.po=dat.po0[dat.po0$patient_num%in%patient_num.keep,]
  dat.cc=dat.cc0[dat.cc0$patient_num%in%patient_num.keep,]
  dat.dem=dat.dem0[dat.dem0$patient_num%in%patient_num.keep,]
  dat.myrace=dat.race0[dat.race0$patient_num%in%patient_num.keep,]
  
  ## covid test
  dat.event1=dat.po[dat.po$concept_type=="COVID-TEST",c("patient_num", "days_since_admission", "concept_code")]
  ## ICD
  #dat.event1$concept_code=gsub("covidU071","U07.1",dat.event1$concept_code)
  ## severity and death
  dat.event2=dat.cc[,c("patient_num", "days_since_admission", "in_hospital", "severe", "in_icu", "dead")]
  head(dat.event2)
  
  ###
  cat("event event admission \n")
  dat.event2.admission=do.call(rbind,
                               lapply(unique(dat.event2$patient_num), function(ll){
                                 data.frame(patient_num=ll, days_since_admission=min(dat.event2[dat.event2$patient_num==ll&dat.event2$in_hospital==1,"days_since_admission"]))}))
  dat.event2.admission=data.frame(dat.event2.admission, concept_code="hospitalized")
  
  ###
  cat("event death \n")
  dat.event2.death=dat.event2[dat.event2$dead==1,]
  dat.event2.death=do.call(rbind,
                           lapply(unique(dat.event2.death$patient_num), function(ll){
                             data.frame(patient_num=ll, days_since_admission=min(dat.event2.death[dat.event2.death$patient_num==ll&dat.event2.death$dead==1,"days_since_admission"]))}))
  dat.event2.death=data.frame(dat.event2.death, concept_code="death")
  
  ###
  cat("event severe \n")
  dat.event2.severe=dat.event2[dat.event2$severe==1,]
  dat.event2.severe=do.call(rbind,
                            lapply(unique(dat.event2.severe$patient_num), function(ll){
                              data.frame(patient_num=ll, days_since_admission=min(dat.event2.severe[dat.event2.severe$patient_num==ll&dat.event2.severe$severe==1,"days_since_admission"]))}))
  dat.event2.severe=data.frame(dat.event2.severe, concept_code="severity")
  
  ###
  cat("event icu \n")
  dat.event2.icu=dat.event2[dat.event2$in_icu==1,]
  dat.event2.icu=do.call(rbind,
                         lapply(unique(dat.event2.icu$patient_num), function(ll){
                           data.frame(patient_num=ll, days_since_admission=min(dat.event2.icu[dat.event2.icu$patient_num==ll&dat.event2.icu$in_icu==1,"days_since_admission"]))}))
  dat.event2.icu=data.frame(dat.event2.icu, concept_code="icu")
  
  ###
  cat("combine all events \n")
  dat.event=rbind(dat.event1, dat.event2.admission, dat.event2.death, dat.event2.severe, dat.event2.icu)
  
  ###
  cat("age and gender \n")
  
  dat.summary=dat.dem[,c("patient_num","age_group", "sex")]
  day.list=sort(unique(c(dat.cc$days_since_admission, dat.po$days_since_admission)))
  patient.list=sort(unique(dat.summary$patient_num))
  
  tmp.mtx=expand.grid(patient.list, day.list)
  colnames(tmp.mtx)=c("patient_num", "days_since_admission")
  dat.age=left_join(tmp.mtx, dat.summary[,c("patient_num", "age_group")], by="patient_num")
  dat.sex=left_join(tmp.mtx, dat.summary[,c("patient_num", "sex")], by="patient_num")
  colnames(dat.age)[3]=colnames(dat.sex)[3]="concept_code"
  
  ###
  cat("race \n")
  dat.race=NULL
  tryCatch({
  dat.race=dat.myrace[,c("patient_num","race_4ce")]
  dat.race=left_join(tmp.mtx, dat.race, by="patient_num")
  }, error=function(e) print(e))
  colnames(dat.race)[3]="concept_code"
  
  ###
  cat("icd \n")
  dat.icd=dat.po[grepl("DIAG-ICD",dat.po$concept_type),c("patient_num", "days_since_admission", "concept_code")]
  icd.phecode.map=icd.phecode.map[,c(1:2)]
  colnames(icd.phecode.map)[1]="concept_code"
  dat.icd=left_join(dat.icd, icd.phecode.map, by="concept_code")
  dat.icd=dat.icd[,setdiff(colnames(dat.icd),"concept_code")]
  colnames(dat.icd)[colnames(dat.icd)=="phecode"]="concept_code"
  dat.icd=dat.icd[complete.cases(dat.icd),]
  dat.icd=dat.icd[duplicated(dat.icd)!=1,]
  dat.icd$concept_code=paste0("PheCode:", dat.icd$concept_code)
  
  ###
  cat("other codes \n")
  dat.others=dat.po[grepl("DIAG-ICD",dat.po$concept_type)!=1 & 
                      dat.po$concept_type!="COVID-TEST",c("patient_num", "days_since_admission", "concept_code")]
  
  ###
  ## double check lab reference files
  ## do we keep the other labs in the data? 
  cat("labs \n")
  dat.labs.ref = dat.lab.ref[,c('LOINC', 'Reference Low', 'Reference High')]
  dat.labs=dat.po%>%filter(concept_type=='LAB-LOINC')%>%
    select(patient_num, days_since_admission, concept_code, value)
  dat.labs=left_join(dat.labs, dat.labs.ref, by=c('concept_code'='LOINC'))

  dat.labs$flag=case_when(value<ref.l ~ 'L',
                          value>ref.h ~ 'H',
                          TRUE ~ 'N')
  
  dat.labs$concept_code_new = paste0(dat.labs$concept_code_new,'',dat.labs$flag)
  
  dat.labs=dat.labs[,c("patient_num", "days_since_admission", "concept_code_new")]
  ###
  cat("combine all \n")
  dat.final=rbind(dat.event,dat.age, dat.sex, dat.race, dat.icd, dat.others, dat.labs)
  dat.final=dat.final[order(dat.final$patient_num, dat.final$days_since_admission),]
  
  map.concept.code=unique(dat.final$concept_code)
  map.concept.code=sort(map.concept.code)
  map.concept.code=data.frame(concept_code=map.concept.code, index=1:length(map.concept.code))
  
  map.date=unique(dat.final$days_since_admission)
  map.date=sort(map.date)
  map.date=data.frame(days_since_admission=map.date, date=1:length(map.date))
  
  dat.final=left_join(dat.final, map.concept.code, by="concept_code")
  dat.final=left_join(dat.final, map.date, by="days_since_admission")
  dat.final=dat.final[,setdiff(colnames(dat.final), c("concept_code", "days_since_admission"))]
  dat.final=dat.final[,c("patient_num", "date", "index")]
  list(dat.final=dat.final, map.concept.code=map.concept.code, map.date=map.date)
}



