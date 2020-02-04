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
*  20050504-004-01   DAR   02/16/06    Initial implementation  
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20140220-005-01   DAR   03/26/14    Add Override Future Edits capability
*/


using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro
{
	/// <summary>
	/// LifePRO API to produce a loan quote 
	/// </summary>
	public class LonQuote :  ILonQuote 
	{
		OLONQUOT apiQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init(string userType)
		{
			UserType = userType ; 
			apiQuote = new OLONQUOT(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiQuote.getReturnCode() ; 
			outProps.ErrorMessage = apiQuote.getErrorMessage() ;
            return outProps; 

		}

		public void Dispose() 
		{
			apiQuote.Dispose(); 
			apiQuote = null ; 
		}

		public LoanQuoteResponse RunQuote (LoanQuoteRequest inProps ) 
		{
			apiQuote.setCompanyCode(inProps.CompanyCode); 
			apiQuote.setPolicyNumber(inProps.PolicyNumber);  
			apiQuote.setEffectiveDate(inProps.EffectiveDate); 

            if (inProps.OverrideFutureDateEdits)
                apiQuote.setOverrideFutureDateEdits("Y");
            else
                apiQuote.setOverrideFutureDateEdits("N"); 

			apiQuote.RunQuote() ; 
			LoanQuoteResponse outProps = new LoanQuoteResponse() ; 
			outProps.ReturnCode = apiQuote.getReturnCode();  
			outProps.ErrorMessage = apiQuote.getErrorMessage();  

			outProps.EffectiveDateUsed = apiQuote.getEffectiveDateUsed();
			outProps.DividendsAccums = apiQuote.getDividendsAccums();
			outProps.CashValuePaidup = apiQuote.getCashValuePaidup();
			outProps.CurLoanBalance = apiQuote.getCurLoanBalance();
			outProps.FundOrCashValue = apiQuote.getFundOrCashValue();
			outProps.SurrenderCharge = apiQuote.getSurrenderCharge();
			outProps.AccruedInterest = apiQuote.getAccruedInterest();
			outProps.PremiumDue = apiQuote.getPremiumDue();
			outProps.MaxLoanAvail = apiQuote.getMaxLoanAvail();
			outProps.InterestToAnniv = apiQuote.getInterestToAnniv();
			outProps.NetLoanAvail = apiQuote.getNetLoanAvail();
			outProps.LoanInterestRate = apiQuote.getLoanInterestRate();
			outProps.InterestMethod = apiQuote.getInterestMethod();
			outProps.InterestType = apiQuote.getInterestType();
			outProps.LastAccruedDate = apiQuote.getLastAccruedDate();
			outProps.FundOrCash = apiQuote.getFundOrCash();
			outProps.MinEquityText = apiQuote.getMinEquityText();
			outProps.IntAdjustText = apiQuote.getIntAdjustText();
			
			return outProps ; 
		}


	}

}
