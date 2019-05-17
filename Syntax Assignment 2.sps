* Encoding: UTF-8.
*Initial model. 
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness weight sex_dummy_1
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.  
  
  *Stepwise regression, backward exclusion.
  REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT pain
  /METHOD=BACKWARD age STAI_trait pain_cat cortisol_serum mindfulness weight sex_dummy_1
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.

*Backward model, final version. 
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT pain
  /METHOD=ENTER age pain_cat cortisol_serum mindfulness sex_dummy_1
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.

*Likelihood Ratio Test of Backward Model and Initial model.
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA CHANGE 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT pain 
  /METHOD=ENTER age cortisol_serum mindfulness sex_dummy_1 pain_cat 
  /METHOD=ENTER STAI_trait weight.

*Breusch-Pagan test of Backward Model.
COMPUTE backward_resid_squared=BACK_RES_1 * BACK_RES_1.
EXECUTE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT backward_resid_squared
  /METHOD=ENTER age pain_cat cortisol_serum mindfulness sex_dummy_1
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE COOK RESID.

*Theory-Based Model.
REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE SELECTION 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT pain 
  /METHOD=ENTER sex_dummy_1 age 
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum mindfulness 
  /SCATTERPLOT=(*ZRESID ,*ZPRED) 
  /RESIDUALS NORMPROB(ZRESID) 
  /SAVE PRED COOK RESID.

*Likelihood Ratio Test of Backward Model and Theory-Based Model.
  REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT pain 
  /METHOD=ENTER age cortisol_serum mindfulness sex_dummy_1 pain_cat 
  /METHOD=ENTER STAI_trait.

*Transformations of variables to test model performance on new dataset.
DATASET ACTIVATE DataSet1.
SPSSINC CREATE DUMMIES VARIABLE=sex 
ROOTNAME1=sex_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

COMPUTE back_pred=4.36 - 0.07 * age + 0.07 * pain_cat + 0.43 * cortisol_serum - 0.27 * mindfulness 
    - 0.34 * sex_dummy_1.
EXECUTE.

COMPUTE error_backward=pain - back_pred. 
EXECUTE.

COMPUTE backw_sq=error_backward * error_backward. 
EXECUTE.

COMPUTE theo_pred=4.21 - 0.35 * sex_dummy_1 - 0.07 * age + 0.01 * STAI_trait + 0.06 * pain_cat + 
    0.41 * cortisol_serum - 0.26 * mindfulness.
EXECUTE.

COMPUTE err_theo=pain - theo_pred. 
EXECUTE.

COMPUTE the_sq=err_theo * err_theo. 
EXECUTE.

COMPUTE pain_res=pain - 4.99. 
EXECUTE.

COMPUTE tot_sq=pain_res * pain_res.
EXECUTE.





