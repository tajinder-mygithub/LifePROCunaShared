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
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// LifePRO Premium Quote API, which produces a premium quote given a policy and other inputs 
	/// </summary>

	public class PrmQuote :  IPrmQuote  
	{
		OPRMQUOT apiQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 


		public BaseResponse Init(string userType)
		{
			UserType = userType ; 
			apiQuote = new OPRMQUOT(apiApp, UserType);  

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

		public PremiumQuoteResponse RunQuote (PremiumQuoteRequest inProps ) 
		{
			apiQuote.setCompanyCode(inProps.CompanyCode);
			apiQuote.setPolicyNumber(inProps.PolicyNumber);
			apiQuote.setEffectiveDate(inProps.EffectiveDate);
			apiQuote.setFunction(inProps.Function);
			apiQuote.setInputSpecialMode(inProps.InputSpecialMode);
			apiQuote.setInputForm(inProps.InputForm);
			apiQuote.setInputMode(inProps.InputMode);
			apiQuote.setInputModePremium(inProps.InputModePremium);

			apiQuote.RunQuote() ; 
			PremiumQuoteResponse quoteOutput = new PremiumQuoteResponse() ; 
			quoteOutput.ReturnCode = apiQuote.getReturnCode();  
			quoteOutput.ErrorMessage = apiQuote.getErrorMessage();  

			quoteOutput.EffectiveDateUsed = apiQuote.getEffectiveDateUsed();
			quoteOutput.CurrentMode = apiQuote.getCurrentMode();
			quoteOutput.CurrentSpecialMode = apiQuote.getCurrentSpecialMode();
			quoteOutput.CurrentForm = apiQuote.getCurrentForm();
			quoteOutput.CurrentModePremium = apiQuote.getCurrentModePremium();
			quoteOutput.BilledToDate = apiQuote.getBilledToDate();
			quoteOutput.PaidToDate = apiQuote.getPaidToDate();
			quoteOutput.PolicyFee = apiQuote.getPolicyFee();
			quoteOutput.ModePremiumAnnual = apiQuote.getAnnualModePremium();
			quoteOutput.ModePremiumQuarterly = apiQuote.getQuarterlyModePremium();
			quoteOutput.ModePremiumSemiAnnual = apiQuote.getSemiAnnualModePremium();
			quoteOutput.ModePremiumMonthly = apiQuote.getMonthlyModePremium();
			quoteOutput.ModePremiumNinethly = apiQuote.getNinethlyModePremium();
			quoteOutput.ModePremiumTenthly = apiQuote.getTenthlyModePremium();
			quoteOutput.ModePremium26Pay = apiQuote.get26PayModePremium();
			quoteOutput.ModePremium52Pay = apiQuote.get52PayModePremium();
			quoteOutput.ModePremium13thly = apiQuote.get13thlyModePremium();
			quoteOutput.ModePremiumBiweekly = apiQuote.getBiweeklyModePremium();
			quoteOutput.ModePremiumWeekly = apiQuote.getWeeklyModePremium();
			quoteOutput.ModePremiumCalendar = apiQuote.getCalendarModePremium();
			quoteOutput.CalendarFlag = apiQuote.getCalendarFlag();
				
			return quoteOutput ; 
		}


	}
}
