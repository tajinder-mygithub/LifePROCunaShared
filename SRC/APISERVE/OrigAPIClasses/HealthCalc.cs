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
*  20070806-001-01   KAM   02/12/08    Initial implementation  
*  20100301-001-01   JWS   05/19/10    Add accum days, allow neg remaining days
*  20111117-006-01   DAR   05/18/12    Retrofit in 20110621-005-01 and 20110202-002-01
*  20121210-001-01   DAR   02/01/13    Return Benefit Code table
*  20121101-001-01   DAR   05/21/13    Shared Care Enhancement
*  20130311-003-01   DAR   07/01/13    Addition of new Benefit sequence values
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.Data; 
using System.ServiceModel.Description;  



namespace PDMA.LifePro 
{
	/// <summary>
	/// LifePRO API which calculates benefit amounts for health policies 
	/// </summary>

	public class HealthCalc : IHealthCalc  
	{
		OHLTHCAL apiHealthCalc ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiHealthCalc = new OHLTHCAL(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiHealthCalc.getReturnCode() ; 
			outProps.ErrorMessage = apiHealthCalc.getErrorMessage() ;
            return outProps; 

		}
		public void Dispose() 
		{
			apiHealthCalc.Dispose(); 
			apiHealthCalc = null ; 
		}


		public HealthBenefitQuoteResponse RunQuote (HealthBenefitQuoteRequest inProps ) 
		{
			apiHealthCalc.setCompanyCode(inProps.CompanyCode);
			apiHealthCalc.setPolicyNumber(inProps.PolicyNumber);
			apiHealthCalc.setEffectiveDate(inProps.EffectiveDate);
            apiHealthCalc.setBenefitSeq(inProps.BenefitSeq);
            apiHealthCalc.setBenefitCode(inProps.BenefitCode);  

			apiHealthCalc.RunQuote(); 

			HealthBenefitQuoteResponse outProps = new HealthBenefitQuoteResponse() ;

            outProps.EffectiveDateUsed = apiHealthCalc.getEffectiveDateUsed();
            outProps.ReturnCode = apiHealthCalc.getReturnCode();  
			outProps.ErrorMessage = apiHealthCalc.getErrorMessage();  

            // 20121101-001-01 - Linked Policy items for Shared Care
            outProps.LinkedPolicyType = apiHealthCalc.getLinkedPolicyType().Trim();
            outProps.LinkedCompanyCode = apiHealthCalc.getLinkedCompanyCode().Trim();
            outProps.LinkedPolicyNumber = apiHealthCalc.getLinkedPolicyNumber().Trim();
            outProps.LinkedPolicyStatus = apiHealthCalc.getLinkedPolicyStatus().Trim();
            outProps.LinkedPolicyType = apiHealthCalc.getLinkedPolicyType().Trim();  
            // end 20121101-001-01 

			int count = outProps.InsCount = apiHealthCalc.getInsCount();

            outProps.NameID = new int[count];
            outProps.Name = new string[count];
            outProps.BenBenefitCode = new string[count];
            outProps.BenBenefitCodeDesc = new string[count];
            outProps.BenBenefitAmount = new double[count];
            outProps.BenAccumClaimPays = new double[count];

            // 20121101-001-01 - Shared Benefit Additions 
            outProps.BenTransferredBenefitAmount = new double[count];
            outProps.BenSharedBenefitRemaining = new double[count];
            // end 20121101-001-01 

            outProps.BenRemainLifeMax = new double[count];
            outProps.BenRemainLifeDaysFlag = new string[count];
            outProps.BenAccumLifeDays = new double[count];
            outProps.BenRemainLifeDays = new double[count];
            outProps.BenInflateSelectDescription = new string[count];
            outProps.BenInflateSelectState = new string[count];
            outProps.BenInflateDailyRate = new double[count];
            outProps.BenInflateLifetimeRate = new double[count]; 
            outProps.BenDailyNFOFlag = new string[count];
            outProps.BenLifeNFOFlag = new string[count];
            outProps.BenAdjCount = new int[count];
            outProps.BenErrorCode = new int[count];
            outProps.BenErrorMessage = new string[count];

            outProps.BenSeq = new int[count] [];
            outProps.BenIssueDate = new int[count] [];
            outProps.BenDMBAdj = new double[count] [];
            outProps.BenLMBAdj = new double[count] [];
            outProps.BenAllocatedReserve = new double[count] [];    
            outProps.BenPortfolioRate = new double[count] []; 
            outProps.BenGuaranteeRate = new double[count] []; 
            outProps.BenPriorNegativeCredit = new double[count] []; 
            outProps.BenExcessEarnings = new double[count] []; 
            outProps.BenNetSinglePremiumPerDollar = new double[count] []; 
            outProps.BenAutomaticBenefitIncrease = new double[count] []; 
            
			for (int i=1;i<=count;i++) 
			{
				
                int adjcount = outProps.BenAdjCount[i - 1] = apiHealthCalc.getBenAdjCount(i);

                outProps.NameID[i-1] = apiHealthCalc.getNameID(i);
                outProps.Name[i-1] = apiHealthCalc.getName(i).Trim();
                outProps.BenBenefitCode[i-1] = apiHealthCalc.getBenefitCode(i).Trim();
                outProps.BenBenefitCodeDesc[i-1] = apiHealthCalc.getBenefitDesc(i).Trim();
                outProps.BenBenefitAmount[i-1] = apiHealthCalc.getBenefitAmount(i);
                outProps.BenAccumClaimPays[i-1] = apiHealthCalc.getAccumClaimPayments(i);
                outProps.BenTransferredBenefitAmount[i - 1] = apiHealthCalc.getTransferredBenefitAmount(i);
                outProps.BenSharedBenefitRemaining[i - 1] = apiHealthCalc.getSharedBenefitRemaining(i);  
                outProps.BenRemainLifeMax[i-1] = apiHealthCalc.getRemainLifeMax(i);
                outProps.BenRemainLifeDaysFlag[i-1] = apiHealthCalc.getRemainLifeDaysFlag(i);
                outProps.BenAccumLifeDays[i-1] = apiHealthCalc.getAccumLifeDays(i);
                outProps.BenRemainLifeDays[i-1] = apiHealthCalc.getRemainLifeDays(i);
                outProps.BenInflateSelectDescription[i - 1] = apiHealthCalc.getBenInflateSelectDescription(i);
                outProps.BenInflateSelectState[i - 1] = apiHealthCalc.getBenInflateSelectState(i);
                outProps.BenInflateDailyRate[i - 1] = apiHealthCalc.getBenInflateDailyRate(i);
                outProps.BenInflateLifetimeRate[i - 1] = apiHealthCalc.getBenInflateLifetimeRate(i); 
                outProps.BenDailyNFOFlag[i - 1] = apiHealthCalc.getDailyNFOFlag(i);
                outProps.BenLifeNFOFlag[i - 1] = apiHealthCalc.getLifeNFOFlag(i);
                outProps.BenAdjCount[i - 1] = apiHealthCalc.getBenAdjCount(i);
                outProps.BenErrorCode[i-1] = apiHealthCalc.getBenErrorCode(i);
                outProps.BenErrorMessage[i-1] = apiHealthCalc.getBenErrorMessage(i).Trim();
                
                //outProps.BenSeq = new int[count, adjcount];
                //outProps.BenIssueDate = new int[count, adjcount];
                //outProps.BenDMBAdj = new double[count, adjcount];
                //outProps.BenLMBAdj = new double[count, adjcount];


                outProps.BenSeq[i-1] = new int[adjcount];
                outProps.BenIssueDate[i - 1] = new int[adjcount];
                outProps.BenDMBAdj[i - 1] = new double[adjcount];
                outProps.BenLMBAdj[i - 1] = new double[adjcount];
                outProps.BenAllocatedReserve[i - 1] = new double[adjcount];
                outProps.BenPortfolioRate[i - 1] = new double[adjcount];
                outProps.BenGuaranteeRate[i - 1] = new double[adjcount];
                outProps.BenPriorNegativeCredit[i - 1] = new double[adjcount];
                outProps.BenExcessEarnings[i - 1] = new double[adjcount];
                outProps.BenNetSinglePremiumPerDollar[i - 1] = new double[adjcount];
                outProps.BenAutomaticBenefitIncrease[i - 1] = new double[adjcount];


                for (int j = 1; j <= adjcount; j++)
                {
                    outProps.BenSeq[i-1][j-1] = apiHealthCalc.getBenSeq(i,j);
                    outProps.BenIssueDate[i-1][j-1] = apiHealthCalc.getBenIssueDate(i, j);
                    outProps.BenDMBAdj[i-1][j-1] = apiHealthCalc.getBenDMBAdj(i, j);
                    outProps.BenLMBAdj[i-1][j-1] = apiHealthCalc.getBenLMBAdj(i, j);
                    outProps.BenAllocatedReserve[i-1][j-1] = apiHealthCalc.getBenAllocatedReserve(i, j);
                    outProps.BenPortfolioRate[i-1][j-1] = apiHealthCalc.getBenPortfolioRate(i, j);
                    outProps.BenGuaranteeRate[i-1][j-1] = apiHealthCalc.getBenGuaranteeRate(i, j);
                    outProps.BenPriorNegativeCredit[i-1][j-1] = apiHealthCalc.getBenPriorNegativeCredit(i, j);
                    outProps.BenExcessEarnings[i-1][j-1] = apiHealthCalc.getBenExcessEarnings(i, j);
                    outProps.BenNetSinglePremiumPerDollar[i-1][j-1] = apiHealthCalc.getBenNetSinglePremPerDollar(i, j);
                    outProps.BenAutomaticBenefitIncrease[i-1][j-1] = apiHealthCalc.getBenAutomaticBenefitIncrease(i, j);  

                }
			}

            outProps.AllBenefitsTable = new System.Data.DataTable("AllBenefits");
            DataTable benTab = outProps.AllBenefitsTable;

            benTab.Columns.Add("BenefitCode", typeof(System.String));
            benTab.Columns.Add("GroupID", typeof(System.String));
            benTab.Columns.Add("BenefitSequence", typeof(System.Int16));
            benTab.Columns.Add("AccumulateFlag", typeof(System.String));
            benTab.Columns.Add("CalcRule", typeof(System.String));
            benTab.Columns.Add("DefaultDescription", typeof(System.String));
            benTab.Columns.Add("EOBDescription", typeof(System.String));
            benTab.Columns.Add("DaysCalcFlag", typeof(System.String));
            benTab.Columns.Add("DaysCalcDescription", typeof(System.String));
            benTab.Columns.Add("PTDEdit", typeof(System.String));
            benTab.Columns.Add("RestoreBenefitFlag", typeof(System.String));

            int lastBen = apiHealthCalc.getBenefitTableCount();
            for (int x = 0; x < lastBen; x++)
            {
                DataRow r = benTab.NewRow();
                r["BenefitCode"] = apiHealthCalc.getBenTabBenefitCode(x + 1);
                r["GroupID"] = apiHealthCalc.getBenTabGroupID(x + 1);
                r["BenefitSequence"] = apiHealthCalc.getBenTabBenefitSeq(x + 1);
                r["AccumulateFlag"] = apiHealthCalc.getBenTabAccumFlag(x + 1);
                r["CalcRule"] = apiHealthCalc.getBenTabCalcRule(x + 1);
                r["DefaultDescription"] = apiHealthCalc.getBenTabDefaultDescription(x + 1);
                r["EOBDescription"] = apiHealthCalc.getBenTabEOBDescription(x + 1);
                r["DaysCalcFlag"] = apiHealthCalc.getBenTabDaysCalcFlag(x + 1);
                r["DaysCalcDescription"] = apiHealthCalc.getBenTabDaysCalcDesc(x + 1);
                r["PTDEdit"] = apiHealthCalc.getBenTabPTDEdit(x + 1);
                r["RestoreBenefitFlag"] = apiHealthCalc.getBenTabRestoreBenFlag(x + 1);

                benTab.Rows.Add(r);  
            }

		
			return outProps ; 
		}


	}
}
