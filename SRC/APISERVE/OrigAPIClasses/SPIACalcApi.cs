/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20140129-005-01   JWS   03/05/14    SPIA Calculator
*/

using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro
{
    public class SPIACalcApi : ISPIACalc
    {
		OSPIACAL apiSPIACalc ; 

		public static OAPPLICA apiApp ; 
		public string UserType ;

 		public BaseResponse Init (string userType ) {
			UserType = userType ; 
			apiSPIACalc = new OSPIACAL(apiApp, UserType);

            BaseResponse outProps = new BaseResponse(); 
			outProps.ReturnCode = apiSPIACalc.getReturnCode() ; 
			outProps.ErrorMessage = apiSPIACalc.getErrorMessage() ; 
            return outProps; 
		}

		public void Dispose() {
			apiSPIACalc.Dispose(); 
			apiSPIACalc = null ; 
		}

        public BaseResponse RunQuote(ref SPIACalcInput inProps)
        {
            apiSPIACalc.setCoverageID(inProps.CoverageID);
            apiSPIACalc.setIssueDate(inProps.IssueDate);
            apiSPIACalc.setStartDate(inProps.StartDate);
            apiSPIACalc.setFunction(inProps.Function);
            apiSPIACalc.setLives(inProps.Lives);
            apiSPIACalc.setFedWthdRate(inProps.FedWthdRate);
            apiSPIACalc.setStWthdRate(inProps.StWthdRate);
            apiSPIACalc.setWaivePolFee(inProps.WaivePolFee);
            apiSPIACalc.setWaiveLoads(inProps.WaiveLoads);
            apiSPIACalc.setAnnuitantSex01(inProps.AnnuitantSex01);
            apiSPIACalc.setAnnuitantDOB01(inProps.AnnuitantDOB01);
            apiSPIACalc.setIssueAge01(inProps.IssueAge01);
            apiSPIACalc.setRateYears01(inProps.RateYears01);
            apiSPIACalc.setUWCLS01(inProps.UWCLS01);
            apiSPIACalc.setSurvivorPct01(inProps.SurvivorPct01);
            apiSPIACalc.setAnnuitantSex02(inProps.AnnuitantSex02);
            apiSPIACalc.setAnnuitantDOB02(inProps.AnnuitantDOB02);
            apiSPIACalc.setIssueAge02(inProps.IssueAge02);
            apiSPIACalc.setRateYears02(inProps.RateYears02);
            apiSPIACalc.setUWCLS02(inProps.UWCLS02);
            apiSPIACalc.setSurvivorPct02(inProps.SurvivorPct02);
            apiSPIACalc.setTerminationType(inProps.TerminationType);
            apiSPIACalc.setCalcType(inProps.CalcType);
            apiSPIACalc.setInputAmount(inProps.InputAmount);
            apiSPIACalc.setPre86Basis(inProps.Pre86Basis);
            apiSPIACalc.setPst86Basis(inProps.Pst86Basis);
            apiSPIACalc.setMode(inProps.Mode);
            apiSPIACalc.setMethod(inProps.Method);
            apiSPIACalc.setCertainPeriod(inProps.CertainPeriod);
            apiSPIACalc.setTemporaryPeriod(inProps.TemporaryPeriod);
            apiSPIACalc.setConstIncrPct(inProps.ConstIncrPct);
            apiSPIACalc.setPercentIncreaseType(inProps.PercentIncreaseType);
            apiSPIACalc.setAmtIncr(inProps.AmtIncr);
            for (int i = 0; i < 200; i++)
            {
                apiSPIACalc.setModalPayments(i+1, inProps.ModalPayments[i]);
                apiSPIACalc.setPctIncreases(i+1, inProps.PctIncreases[i]);
                apiSPIACalc.setLumpPaytDate(i+1, inProps.LumpPaytDate[i]);
                apiSPIACalc.setLumpSumPayts(i+1, inProps.LumpSumPayts[i]);
            }
            apiSPIACalc.setResult(inProps.Result);
            apiSPIACalc.setExclusionRatio(inProps.ExclusionRatio);
            apiSPIACalc.setIssueState(inProps.IssueState);
            apiSPIACalc.setQualified(inProps.Qualified);
            apiSPIACalc.setValCode(inProps.ValCode);
            apiSPIACalc.setValueDate(inProps.ValueDate);
            apiSPIACalc.setCompanyCode(inProps.CompanyCode);
            apiSPIACalc.setPolicyNumber(inProps.PolicyNumber);
            apiSPIACalc.setPurchaseBasis(inProps.PurchaseBasis);
            apiSPIACalc.setInterestRateOverride(inProps.InterestRateOverride);
            apiSPIACalc.setCalcMethod(inProps.CalcMethod);

            apiSPIACalc.RunQuote(); 

            inProps.CoverageID = apiSPIACalc.getCoverageID();
            inProps.IssueDate = apiSPIACalc.getIssueDate();
            inProps.StartDate = apiSPIACalc.getStartDate();
            inProps.Function = apiSPIACalc.getFunction();
            inProps.Lives = apiSPIACalc.getLives();
            inProps.FedWthdRate = apiSPIACalc.getFedWthdRate();
            inProps.StWthdRate = apiSPIACalc.getStWthdRate();
            inProps.WaivePolFee = apiSPIACalc.getWaivePolFee();
            inProps.WaiveLoads = apiSPIACalc.getWaiveLoads();
            inProps.AnnuitantSex01 = apiSPIACalc.getAnnuitantSex01();
            inProps.AnnuitantDOB01 = apiSPIACalc.getAnnuitantDOB01();
            inProps.IssueAge01 = apiSPIACalc.getIssueAge01();
            inProps.RateYears01 = apiSPIACalc.getRateYears01();
            inProps.UWCLS01 = apiSPIACalc.getUWCLS01();
            inProps.SurvivorPct01 = apiSPIACalc.getSurvivorPct01();
            inProps.AnnuitantSex02 = apiSPIACalc.getAnnuitantSex02();
            inProps.AnnuitantDOB02 = apiSPIACalc.getAnnuitantDOB02();
            inProps.IssueAge02 = apiSPIACalc.getIssueAge02();
            inProps.RateYears02 = apiSPIACalc.getRateYears02();
            inProps.UWCLS02 = apiSPIACalc.getUWCLS02();
            inProps.SurvivorPct02 = apiSPIACalc.getSurvivorPct02();
            inProps.TerminationType = apiSPIACalc.getTerminationType();
            inProps.CalcType = apiSPIACalc.getCalcType();
            inProps.InputAmount = apiSPIACalc.getInputAmount();
            inProps.Pre86Basis = apiSPIACalc.getPre86Basis();
            inProps.Pst86Basis = apiSPIACalc.getPst86Basis();
            inProps.Mode = apiSPIACalc.getMode();
            inProps.Method = apiSPIACalc.getMethod();
            inProps.CertainPeriod = apiSPIACalc.getCertainPeriod();
            inProps.TemporaryPeriod = apiSPIACalc.getTemporaryPeriod();
            inProps.ConstIncrPct = apiSPIACalc.getConstIncrPct();
            inProps.PercentIncreaseType = apiSPIACalc.getPercentIncreaseType();
            inProps.AmtIncr = apiSPIACalc.getAmtIncr();
            int count = 200;
            inProps.ModalPayments = new double[count];
            inProps.PctIncreases = new double[count];
            inProps.LumpPaytDate = new int[count];
            inProps.LumpSumPayts = new double[count];
            for (int j = 0; j < count; j++)
            {
                inProps.ModalPayments[j] = apiSPIACalc.getModalPayments(j + 1);
                inProps.PctIncreases[j] = apiSPIACalc.getPctIncreases(j + 1);
                inProps.LumpPaytDate[j] = apiSPIACalc.getLumpPaytDate(j + 1);
                inProps.LumpSumPayts[j] = apiSPIACalc.getLumpSumPayts(j + 1);
            }
            inProps.Result = apiSPIACalc.getResult();
            inProps.ExclusionRatio = apiSPIACalc.getExclusionRatio();
            inProps.IssueState = apiSPIACalc.getIssueState();
            inProps.Qualified = apiSPIACalc.getQualified();
            inProps.ValCode = apiSPIACalc.getValCode();
            inProps.ValueDate = apiSPIACalc.getValueDate();
            inProps.CompanyCode = apiSPIACalc.getCompanyCode();
            inProps.PolicyNumber = apiSPIACalc.getPolicyNumber();
            inProps.PurchaseBasis = apiSPIACalc.getPurchaseBasis();
            inProps.InterestRateOverride = apiSPIACalc.getInterestRateOverride();
            inProps.CalcMethod = apiSPIACalc.getCalcMethod();

            BaseResponse outProps = new BaseResponse();
            outProps.ErrorMessage = apiSPIACalc.getErrorMessage();
            outProps.ReturnCode = apiSPIACalc.getReturnCode();

            return outProps;
        }
    }
}
