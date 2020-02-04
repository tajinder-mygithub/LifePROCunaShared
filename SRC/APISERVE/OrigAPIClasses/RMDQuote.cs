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
*  20111013-006-07  DAR   10/17/12    Initial implementation  
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20140220-005-01   DAR   03/26/14    Add Override Future Edits capability
*  20130323-002-01   DAR   10/08/14    Return Adjusted Benefit Value related items
*  20141110-007-08   TJO   12/04/15    Add ABV description   
*  20131010-019-01   DAR   06/17/16    Add optional override input parameters.  
*  20131010-019-01   DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*  
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for RMDQUOTe.
	/// </summary>

	public class RMDQuote : MarshalByRefObject, IRMDQuote  
	{
		ORMDQUOT apiQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ;


        public BaseResponse Init(string userType)
		{
            Log.AddDetailedLogEntry("In TCP RMD Quote Init Call.  About to Init ORMDQUOT");  

            UserType = userType;
            apiQuote = new ORMDQUOT(apiApp, UserType);

            BaseResponse outProps = new BaseResponse();
            outProps.ReturnCode = apiQuote.getReturnCode();
            outProps.ErrorMessage = apiQuote.getErrorMessage();

            Log.AddDetailedLogEntry("In TCP RMD Quote Init Call.  About to exit with Return Code: " + outProps.ReturnCode.ToString());  

            return outProps;  
			
		}

		public void Dispose() 
		{
			apiQuote.Dispose(); 
			apiQuote = null ; 
		}

		public RMDQuoteResponse RunQuote (RMDQuoteRequest inProps ) 
		{
            Log.AddDetailedLogEntry("Starting TCP RMD Quote RunQuote Call.  Call is for policy " + inProps.PolicyNumber);  
			apiQuote.setCompanyCode(inProps.CompanyCode);
			apiQuote.setPolicyNumber(inProps.PolicyNumber);
			apiQuote.setEffectiveDate(inProps.EffectiveDate);

            if (inProps.OverrideFutureDateEdits)
                apiQuote.setOverrideFutureDateEdits("Y");
            else
                apiQuote.setOverrideFutureDateEdits("N"); 

            // If the user leaves these blank/zero, defaults will be used.  
            apiQuote.setDeferredAmountInInitRMD(inProps.OverrideDeferredAmountInInitRMD);
            apiQuote.setLifeExpectencyMethod(inProps.OverrideLifeExpectencyMethod);  

            Log.AddDetailedLogEntry("TCP RMD Quote RunQuote Call.  Just before ORMDQUOT RunQuote for policy  " + inProps.PolicyNumber);  
			apiQuote.RunQuote() ;
            Log.AddDetailedLogEntry("TCP RMD Quote RunQuote Call.  Just after ORMDQUOT RunQuote for policy  " + inProps.PolicyNumber);  

            
			RMDQuoteResponse quoteOutput = new RMDQuoteResponse() ; 
			quoteOutput.ReturnCode = apiQuote.getReturnCode();  
			quoteOutput.ErrorMessage = apiQuote.getErrorMessage();  

			quoteOutput.EffectiveDateUsed = apiQuote.getEffectiveDateUsed();
            quoteOutput.RMDTaxYear = apiQuote.getRMDTaxYear(); 
            quoteOutput.PriorYearEndValue = apiQuote.getPriorYearEndValue();
            string tempFlag = apiQuote.getAdjustedBenefitValueFlag();   
            //quoteOutput.AdjustedBenefitValue = (apiQuote.getAdjustedBenefitValueFlag() == "Y") ?  true : false;
            quoteOutput.AdjustedBenefitValue = (tempFlag == "Y" ||
                                                tempFlag == "F" ||
                                                tempFlag == "G" ||
                                                tempFlag == "R") ? true : false;
            quoteOutput.AdjustedBenefitValueDesc = apiQuote.getAdjustedBenefitValueDesc();  
            quoteOutput.LifeExpectencyMethodCode = apiQuote.getLifeExpectencyMethodCode(); 
            quoteOutput.LifeExpectencyMethodDesc = apiQuote.getLifeExpectencyMethodDesc(); 
            quoteOutput.RMDFactor = apiQuote.getRMDFactor(); 
            quoteOutput.RMDAmount = apiQuote.getRMDAmount();
            quoteOutput.WithdrawalsYTD = apiQuote.getWithdrawalsYTD(); 
            quoteOutput.RMDRemainingAmount = apiQuote.getRMDRemainingAmount(); 
            quoteOutput.RMDDeferredAmount = apiQuote.getRMDDeferredAmount(); 
            quoteOutput.DeferredAmtInitRmd = (apiQuote.getDeferredAmtInitRmdFlag() == "Y") ? true : false; 
            quoteOutput.ActiveRMDRequest = (apiQuote.getActiveRMDRequestFlag() == "Y") ? true : false; 

            //20130323-002-01: Begin  
            quoteOutput.AdjustedBenefitValueAmount = apiQuote.getAdjustedBenefitValueAmount();
            quoteOutput.AdjustedBenefitValueExemptionFloor = apiQuote.getAdjustedBenValExemptFloor();
            quoteOutput.AdjustedBenefitValueExemptionPercentage = apiQuote.getAdjustedBenValExemptionPct();  
            quoteOutput.SumDiscountedAdditionalBenefits = apiQuote.getSumDiscountedAdditionalBens(); 
            // 20130323-002-01: End 


            Log.AddDetailedLogEntry("TCP RMD Quote RunQuote Call.  Returning from RunQuote now for policy  " + inProps.PolicyNumber);  
			return quoteOutput ; 
		}


	}
}
