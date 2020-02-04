/*@*****************************************************
/*@** 
/*@** Licensed Materials - Property of
/*@** ExlService Holdings, Inc.
/*@**  
/*@** (C) 1983-2013 ExlService Holdings, Inc.  All Rights Reserved.
/*@** 
/*@** Contains confidential and trade secret information.  
/*@** Copyright notice is precautionary only and does not
/*@** imply publication.
/*@** 
/*@*****************************************************

/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20070730-003-01   DAR   10/24/08    Reprojection enhancements. 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20140220-005-01   DAR   03/26/14    Add Override Future Edits capability
*  20140220-006-01   DAR   03/28/14    Add Guaranteed Mininum values 
*  20131208-001-01   TJO   07/10/2014  NFO Quoting Additions                                      
*  20140318-009-01   TJO   04/13/15    Add GWBN amounts to Death Quote API  
*  20131010-019-01   DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// The Death Quote LifePRO API, which calculates death quote information for various inputs 
	/// </summary>

	public class DthQuote :  IDthQuote  
	{
		ODTHQUOT apiQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ;
        public const int AllowedBenefits = 20; 
        public const int AllowedGMBValues = 10; 

		public BaseResponse Init(string userType)
		{
            Log.AddDetailedLogEntry("In TCP Death Quote Init Call.  About to Init ODTHQUOT");  

			UserType = userType ; 
			apiQuote = new ODTHQUOT(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiQuote.getReturnCode() ; 
			outProps.ErrorMessage = apiQuote.getErrorMessage() ;

            Log.AddDetailedLogEntry("In TCP Death Quote Init Call.  About to exit with Return Code: " + outProps.ReturnCode.ToString());  
            return outProps;  

		}

		public void Dispose() 
		{
			apiQuote.Dispose(); 
			apiQuote = null ; 
		}

		public DeathQuoteResponse RunQuote (DeathQuoteRequest inProps ) 
		{

            Log.AddDetailedLogEntry("Starting TCP Death Quote RunQuote Call.  Call is for policy " + inProps.PolicyNumber);  
			apiQuote.setCompanyCode(inProps.CompanyCode); 
			apiQuote.setPolicyNumber(inProps.PolicyNumber);  
			apiQuote.setEffectiveDate(inProps.EffectiveDate);
            apiQuote.setInputNameId(inProps.InputNameId);
            apiQuote.setInputBenefitSeq(inProps.InputBenefitSeq); 

            if (inProps.OverrideFutureDateEdits)
                apiQuote.setOverrideFutureDateEdits("Y");
            else
                apiQuote.setOverrideFutureDateEdits("N");

            Log.AddDetailedLogEntry("TCP Death Quote Call.  Just before ODTHQUOT RunQuote for policy  " + inProps.PolicyNumber);  
			apiQuote.RunQuote() ;
            Log.AddDetailedLogEntry("TCP Death Quote Call.  Just after ODTHQUOT RunQuote for policy  " + inProps.PolicyNumber);  


			DeathQuoteResponse outProps = new DeathQuoteResponse(); 
			outProps.ReturnCode = apiQuote.getReturnCode();  
			outProps.ErrorMessage = apiQuote.getErrorMessage();
            outProps.EffectiveDateUsed = apiQuote.getEffectiveDateUsed();
            outProps.LoanPrincipal = apiQuote.getLoanPrincipal();
            outProps.LoanInterest = apiQuote.getLoanInterest();
            outProps.LoanWriteoff = apiQuote.getLoanWriteOff();
            outProps.LoanBalance = apiQuote.getLoanBalance();
            outProps.UnappliedCash = apiQuote.getUnappliedCash();
            outProps.Iba01Amt = apiQuote.getIba01Amt();
            outProps.Iba02Amt = apiQuote.getIba02Amt();
            outProps.Iba04Amt = apiQuote.getIba04Amt();
            outProps.AdbFaceAmt = apiQuote.getAdbFaceAmt();
            outProps.FundTax = apiQuote.getFundTax();
            outProps.DeferedPremTax = apiQuote.getDeferedPremTax();
            outProps.RefundPremTax = apiQuote.getRefundPremTax();
            outProps.NumberOfInsureds = apiQuote.getNumberOfInsureds();
            outProps.ReturnOfPremium = apiQuote.getReturnOfPremium();

            int count = outProps.NumberOfInsureds;
            int i; 
		 	outProps.InsuredNameId = new int[count];
            outProps.InsuredRelateCode = new string[count];
            outProps.InsuredRelateSeq = new int[count];
            outProps.TotDeathBenefit = new double[count];
            outProps.TotFaceAmt = new double[count];
            outProps.TotPuaFaceAmt = new double[count];
            outProps.TotOytFaceAmt = new double[count];
            outProps.TotEtiFaceAmt = new double[count];
            outProps.TotRpuFaceAmt = new double[count];
            outProps.TotDivAccums = new double[count];
            outProps.TotDivAdjust = new double[count];
            outProps.TotPremRefund = new double[count];
            outProps.TotSpecifiedAmt = new double[count];
            outProps.TotUlDeathBenefit = new double[count];
            outProps.TotUlFundValue = new double[count];
            outProps.UlDeathBenefitOpt = new string[count];
            outProps.UlDeathBenefitOptDesc = new string[count];
            outProps.TotArFundValue = new double[count];
            outProps.NumberOfBenefits = new int[count];
            outProps.AnnuitizationBenefit = new double[count];
            outProps.AnnuitizationAnnualAmt = new double[count];
            outProps.AnnuitizationNumberYears = new int[count];
            outProps.LumpSumBenefit = new double[count];
            outProps.GWBNWaitPeriodFlag = new string[count];

            outProps.NumberOfGMB = new int[count];  
            outProps.GMBDescription = new string[count][];
            outProps.GMBCoverageID = new string[count][];
            outProps.GMBGrossAmount = new double[count][];
            outProps.GMBPremiumTax = new double[count][];
            outProps.GMBLoanAmount = new double[count][];
            outProps.GMBNetAmount = new double[count][];
            outProps.GMBEarningsEnhancement = new double[count][];  
            outProps.GMBLumpSum = new double[count][];
            outProps.GMBAnnuitized = new double[count][];  


            // WCF - requires "jagged" arrays, instead of multi-dimensional. 
            //outProps.BenefitSeq = new int[count, 20];
            //outProps.BenefitType = new string[count, 20];
            //outProps.BenefitPlanCode = new string[count, 20];
            //outProps.BenefitDescription = new string[count, 20];
            //outProps.BenefitDeathBenefit = new double[count, 20];
            //outProps.BenefitFaceAmt = new double[count, 20];
            //outProps.BenefitPuaFaceAmt = new double[count, 20];
            //outProps.BenefitOytFaceAmt = new double[count, 20];
            //outProps.BenefitEtiFaceAmt = new double[count, 20];
            //outProps.BenefitRpuFaceAmt = new double[count, 20];
            //outProps.BenefitDivAccums = new double[count, 20];
            //outProps.BenefitDivAdjust = new double[count, 20];
            //outProps.BenefitPremRefund = new double[count, 20];
            //outProps.BenefitSpecifiedAmt = new double[count, 20];
            //outProps.BenefitUlDeathBenefit = new double[count, 20];
            //outProps.BenefitUlFundValue = new double[count, 20];
            //outProps.BenefitUlDeathBenOpt = new string[count, 20];
            //outProps.BenefitUlDeathBenOptDesc = new string[count, 20];
            //outProps.BenefitArFundValue = new double[count, 20];
            //outProps.BenefitFundTax = new double[count, 20];


            outProps.BenefitSeq = new int[count] [];
            outProps.BenefitType = new string[count] [];
            outProps.BenefitPlanCode = new string[count] [];
            outProps.BenefitDescription = new string[count] [];
            outProps.BenefitDeathBenefit = new double[count] [];
            outProps.BenefitFaceAmt = new double[count] [];
            outProps.BenefitPuaFaceAmt = new double[count] [];
            outProps.BenefitOytFaceAmt = new double[count] [];
            outProps.BenefitEtiFaceAmt = new double[count] [];
            outProps.BenefitRpuFaceAmt = new double[count] [];
            outProps.BenefitDivAccums = new double[count] [];
            outProps.BenefitDivAdjust = new double[count] [];
            outProps.BenefitPremRefund = new double[count] [];
            outProps.BenefitSpecifiedAmt = new double[count] [];
            outProps.BenefitUlDeathBenefit = new double[count] [];
            outProps.BenefitUlFundValue = new double[count] [];
            outProps.BenefitUlDeathBenOpt = new string[count] [];
            outProps.BenefitUlDeathBenOptDesc = new string[count] [];
            outProps.BenefitArFundValue = new double[count] [];
            outProps.BenefitFundTax = new double[count] [];


            for (i = 1; i <= count; i++)
            {
                outProps.InsuredNameId[i - 1] = apiQuote.getInsuredNameId(i);
                outProps.InsuredRelateCode[i - 1] = apiQuote.getInsuredRelateCode(i);
                outProps.InsuredRelateSeq[i - 1] = apiQuote.getInsuredRelateSeq(i);
                outProps.TotDeathBenefit[i - 1] = apiQuote.getTotDeathBenefit(i);
                outProps.TotFaceAmt[i - 1] = apiQuote.getTotFaceAmt(i);
                outProps.TotPuaFaceAmt[i - 1] = apiQuote.getTotPuaFaceAmt(i);
                outProps.TotOytFaceAmt[i - 1] = apiQuote.getTotOytFaceAmt(i);
                outProps.TotEtiFaceAmt[i - 1] = apiQuote.getTotEtiFaceAmt(i);
                outProps.TotRpuFaceAmt[i - 1] = apiQuote.getTotRpuFaceAmt(i);
                outProps.TotDivAccums[i - 1] = apiQuote.getTotDivAccums(i);
                outProps.TotDivAdjust[i - 1] = apiQuote.getTotDivAdjust(i);
                outProps.TotPremRefund[i - 1] = apiQuote.getTotPremRefund(i);
                outProps.TotSpecifiedAmt[i - 1] = apiQuote.getTotSpecifiedAmt(i);
                outProps.TotUlDeathBenefit[i - 1] = apiQuote.getTotUlDeathBenefit(i);
                outProps.TotUlFundValue[i - 1] = apiQuote.getTotUlFundValue(i);
                outProps.UlDeathBenefitOpt[i - 1] = apiQuote.getUlDeathBenefitOpt(i);
                outProps.UlDeathBenefitOptDesc[i - 1] = apiQuote.getUlDeathBenefitOptDesc(i);
                outProps.TotArFundValue[i - 1] = apiQuote.getTotArFundValue(i);
                outProps.AnnuitizationBenefit[i - 1] = apiQuote.getAnnuitizationBenefit(i);
                outProps.AnnuitizationAnnualAmt[i - 1] = apiQuote.getAnnuitizationAnnualAmt(i);
                outProps.AnnuitizationNumberYears[i - 1] = apiQuote.getAnnuitizationNumberYears(i);
                outProps.LumpSumBenefit[i - 1] = apiQuote.getLumpSumBenefit(i);
                outProps.GWBNWaitPeriodFlag[i - 1] = apiQuote.getGWBNWaitPeriodFlag(i);


                int count2 = apiQuote.getGMBCount(i);
                outProps.NumberOfGMB[i - 1] = count2;
                outProps.GMBDescription[i - 1] = new string[AllowedGMBValues];
                outProps.GMBCoverageID[i - 1] = new string[AllowedGMBValues];
                outProps.GMBGrossAmount[i - 1] = new double[AllowedGMBValues];
                outProps.GMBPremiumTax[i - 1] = new double[AllowedGMBValues];
                outProps.GMBLoanAmount[i - 1] = new double[AllowedGMBValues];
                outProps.GMBNetAmount[i - 1] = new double[AllowedGMBValues];
                outProps.GMBEarningsEnhancement[i - 1] = new double[AllowedGMBValues];
                outProps.GMBLumpSum[i - 1] = new double[AllowedGMBValues];
                outProps.GMBAnnuitized[i - 1] = new double[AllowedGMBValues];


                int i2;
                for (i2 = 1; i2 <= count2; i2++)
                {
                    outProps.GMBDescription[i - 1] [i2 - 1] = apiQuote.getGMBDescription(i, i2) ;
                    outProps.GMBCoverageID[i - 1][i2 - 1] = apiQuote.getGMBCoverageID(i, i2);
                    outProps.GMBGrossAmount[i - 1][i2 - 1] = apiQuote.getGMBGrossAmount(i, i2);
                    outProps.GMBPremiumTax[i - 1][i2 - 1] = apiQuote.getGMBPremiumTax(i, i2);
                    outProps.GMBLoanAmount[i - 1][i2 - 1] = apiQuote.getGMBLoanAmount(i, i2);
                    outProps.GMBNetAmount[i - 1][i2 - 1] = apiQuote.getGMBNetAmount(i, i2);
                    outProps.GMBEarningsEnhancement[i - 1][i2 - 1] = apiQuote.getGMBEarningsEnhancement(i, i2);  
                    outProps.GMBLumpSum[i - 1][i2 - 1] = apiQuote.getGMBLumpSum(i, i2);
                    outProps.GMBAnnuitized[i - 1][i2 - 1] = apiQuote.getGMBAnnuitized(i, i2);  
                }

                
                outProps.NumberOfBenefits[i - 1] = apiQuote.getNumberOfBenefits(i);
                outProps.BenefitSeq[i - 1] = new int[AllowedBenefits];
                outProps.BenefitType[i - 1] = new string[AllowedBenefits];
                outProps.BenefitPlanCode[i - 1] = new string[AllowedBenefits];
                outProps.BenefitDescription[i - 1] = new string[AllowedBenefits];
                outProps.BenefitDeathBenefit[i - 1] = new double[AllowedBenefits];
                outProps.BenefitFaceAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitPuaFaceAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitOytFaceAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitEtiFaceAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitRpuFaceAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitDivAccums[i - 1] = new double[AllowedBenefits];
                outProps.BenefitDivAdjust[i - 1] = new double[AllowedBenefits];
                outProps.BenefitPremRefund[i - 1] = new double[AllowedBenefits];
                outProps.BenefitSpecifiedAmt[i - 1] = new double[AllowedBenefits];
                outProps.BenefitUlDeathBenefit[i - 1] = new double[AllowedBenefits];
                outProps.BenefitUlFundValue[i - 1] = new double[AllowedBenefits];
                outProps.BenefitUlDeathBenOpt[i - 1] = new string[AllowedBenefits];  
                outProps.BenefitUlDeathBenOptDesc[i - 1] = new string[AllowedBenefits];
                outProps.BenefitArFundValue[i - 1] = new double[AllowedBenefits];
                outProps.BenefitFundTax[i - 1] = new double[AllowedBenefits]; 


                count2 = outProps.NumberOfBenefits[i - 1];
                for (i2 = 1; i2 <= count2; i2++)
                {
                    outProps.BenefitSeq[i - 1] [i2 - 1] = apiQuote.getBenefitSeq(i, i2);
                    outProps.BenefitType[i - 1] [i2 - 1] = apiQuote.getBenefitType(i, i2);
                    outProps.BenefitPlanCode[i - 1] [i2 - 1] = apiQuote.getBenefitPlanCode(i, i2);
                    outProps.BenefitDescription[i - 1] [i2 - 1] = apiQuote.getBenefitDescription(i, i2);
                    outProps.BenefitDeathBenefit[i - 1] [i2 - 1] = apiQuote.getBenefitDeathBenefit(i, i2);
                    outProps.BenefitFaceAmt[i - 1] [i2 - 1] = apiQuote.getBenefitFaceAmt(i, i2);
                    outProps.BenefitPuaFaceAmt[i - 1] [i2 - 1] = apiQuote.getBenefitPuaFaceAmt(i, i2);
                    outProps.BenefitOytFaceAmt[i - 1] [i2 - 1] = apiQuote.getBenefitOytFaceAmt(i, i2);
                    outProps.BenefitEtiFaceAmt[i - 1] [i2 - 1] = apiQuote.getBenefitEtiFaceAmt(i, i2);
                    outProps.BenefitRpuFaceAmt[i - 1] [i2 - 1] = apiQuote.getBenefitRpuFaceAmt(i, i2);
                    outProps.BenefitDivAccums[i - 1] [i2 - 1] = apiQuote.getBenefitDivAccums(i, i2);
                    outProps.BenefitDivAdjust[i - 1] [i2 - 1] = apiQuote.getBenefitDivAdjust(i, i2);
                    outProps.BenefitPremRefund[i - 1] [i2 - 1] = apiQuote.getBenefitPremRefund(i, i2);
                    outProps.BenefitSpecifiedAmt[i - 1] [i2 - 1] = apiQuote.getBenefitSpecifiedAmt(i, i2);
                    outProps.BenefitUlDeathBenefit[i - 1] [i2 - 1] = apiQuote.getBenefitUlDeathBenefit(i, i2);
                    outProps.BenefitUlFundValue[i - 1] [i2 - 1] = apiQuote.getBenefitUlFundValue(i, i2);
                    outProps.BenefitUlDeathBenOpt[i - 1] [i2 - 1] = apiQuote.getBenefitUlDeathBenOpt(i, i2);
                    outProps.BenefitUlDeathBenOptDesc[i - 1] [i2 - 1] = apiQuote.getBenefitUlDeathBenOptDesc(i, i2);
                    outProps.BenefitArFundValue[i - 1] [i2 - 1] = apiQuote.getBenefitArFundValue(i, i2);
                    outProps.BenefitFundTax[i - 1] [i2 - 1] = apiQuote.getBenefitFundTax(i, i2);
                }
            }

            Log.AddDetailedLogEntry("TCP Death Quote RunQuote Call.  Returning from RunQuote now for policy  " + inProps.PolicyNumber);  
			return outProps ;
        }

        public ODTHQUOT ReturnDthQuoteObj()
        {
            return apiQuote;
        }

	
	}
}
