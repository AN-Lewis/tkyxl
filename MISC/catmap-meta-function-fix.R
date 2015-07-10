 if (tau2 <= 0) {
        return (list(comvarlogOR=comvarlogOR, combinedLogOR=combinedLogOR, combinedOR=combinedOR, combinedSeLogOR=combinedSeLogOR, 
               weight=weight, logOR=logOR, combinedVarLogOR=combinedVarLogOR, combinedChisq=combinedChisq, combinedValue=combinedValue, 
               combinedPvalue=combinedPvalue, lbci=lbci, ubci=ubci, combinedCI=combinedCI, SeLogOR=SeLogOR, 
               lbci.fe=lbci.fe, ubci.fe=ubci.fe, het.df=het.df, chisqHet=chisqHet, combinedHetValue=combinedHetValue, 
               heterogeneityPvalue=heterogeneityPvalue, tau2=tau2, studyname=studyname, a1=a1, quantilenorm=quantilenorm, 
               ci=ci, dataset=dataset))
    }
    if (tau2 > 0) {
        return(list(comvarlogOR=comvarlogOR, combinedLogOR=combinedLogOR, combinedOR=combinedOR, combinedSeLogOR=combinedSeLogOR, 
                    weight=weight, logOR=logOR, combinedVarLogOR=combinedVarLogOR, combinedChisq=combinedChisq, combinedValue=combinedValue, 
                    combinedPvalue=combinedPvalue, lbci=lbci, ubci=ubci, combinedCI=combinedCI, SeLogOR=SeLogOR, 
                    lbci.fe=lbci.fe, ubci.fe=ubci.fe, het.df=het.df, chisqHet=chisqHet, combinedHetValue=combinedHetValue, 
                    heterogeneityPvalue=heterogeneityPvalue, tau2=tau2, studyname=studyname, a1=a1, quantilenorm=quantilenorm, 
                    ci=ci, dataset=dataset, weight.dsl=weight.dsl, logOR.dsl=logOR.dsl, OR.dsl=OR.dsl, seLogOR.dsl=seLogOR.dsl, 
                    varLogOR.dsl=varLogOR.dsl, lbci.dsl=lbci.dsl, ubci.dsl=ubci.dsl, ci.dsl=ci.dsl, chisq.dsl=chisq.dsl, 
                    value.dsl=value.dsl, pvalue.dsl=pvalue.dsl))
    }