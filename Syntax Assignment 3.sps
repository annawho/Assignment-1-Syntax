* Encoding: UTF-8.
*create dummy.
SPSSINC CREATE DUMMIES VARIABLE=sex 
ROOTNAME1=sex_female 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

*Null model.
MIXED pain BY sex_female WITH age STAI_trait pain_cat cortisol_serum mindfulness 
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE) 
  /FIXED=| SSTYPE(3) 
  /METHOD=REML 
  /PRINT=SOLUTION 
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC).

*Recode Hospital.
AUTORECODE VARIABLES=hospital 
  /INTO hospital_recoded 
  /PRINT. 
 
 *ANOVA Pain and Groups (hospital). 
ONEWAY pain BY hospital_recoded 
  /MISSING ANALYSIS.

*Random intercept model. 
MIXED pain BY sex_female WITH age STAI_trait pain_cat cortisol_serum mindfulness 
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE) 
  /FIXED=sex_female age STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3) 
  /METHOD=REML 
  /PRINT=SOLUTION 
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC) 
  /SAVE=PRED RESID FIXPRED.

*Homoscedasticity test across clusters.
SPSSINC CREATE DUMMIES VARIABLE=hospital 
ROOTNAME1=hospital_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.
COMPUTE resid_sq=RESID_3 * RESID_3. 
EXECUTE.
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT resid_sq 
  /METHOD=ENTER hospital_dummy_2 hospital_dummy_3 hospital_dummy_4 hospital_dummy_5 
    hospital_dummy_6 hospital_dummy_7 hospital_dummy_8 hospital_dummy_9 hospital_dummy_10.

*Multicollinearity test for fixed predictors. 
CORRELATIONS
/VARIABLES=sex_female age STAI_trait pain_cat cortisol_serum mindfulness /PRINT=TWOTAIL NOSIG
/MISSING=PAIRWISE.

*Multiple Linear Regression, Theory-based model. 
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT pain 
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_female.

*Model assessment on new dataset. 
COMPUTE pred_mixed=1.85 - 0.38 * sex_dum_1 - 0.03 * age - 0.01 * STAI_trait + 0.08 * pain_cat + 
    0.53 * cortisol_serum - 0.24 * mindfulness. 
EXECUTE. 
COMPUTE resid=pain - pred_mixed. 
EXECUTE. 
COMPUTE res_sq=resid * resid. 
EXECUTE.
DESCRIPTIVES VARIABLES=pain 
  /STATISTICS=MEAN STDDEV MIN MAX
  COMPUTE pain_res=pain - 4.99. 
EXECUTE. 
COMPUTE tot_sq=pain_res * pain_res. 
EXECUTE. 
DESCRIPTIVES VARIABLES=tot_sq res_sq 
  /STATISTICS=MEAN SUM.



