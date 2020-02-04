/*@*****************************************************
/*@** 
/*@** Licensed Materials - Property of
/*@** ExlService Holdings, Inc.
/*@**  
/*@** (C) 1983-2016 ExlService Holdings, Inc.  All Rights Reserved.
/*@** 
/*@** Contains confidential and trade secret information.  
/*@** Copyright notice is precautionary only and does not
/*@** imply publication.
/*@** 
/*@*****************************************************

/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20150311-012-32  DAR    09/27/2016   Created to return trace "screen" values, along with select GW Rider values.  
 */


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// Disclosure API, produces a variety of calculated values given a set of new business inputs (not an existing policy) 
	/// </summary>

	public class ValueRetrieve :  IValueRetrieve
	{
		OVALUAPI apiValueRetrieve ;

		public static OAPPLICA apiApp ;
		public string UserType ;

		public BaseResponse Init (string userType)
		{
			UserType = userType ;
			apiValueRetrieve = new OVALUAPI(apiApp, UserType);

			BaseResponse outProps = new BaseResponse() ;
            outProps.ReturnCode = 0;
            try
            {
                outProps.ReturnCode = apiValueRetrieve.getReturnCode();
            }
            catch { }

            outProps.ErrorMessage = apiValueRetrieve.getErrorMessage();
            return outProps;  

		}
		public void Dispose()
		{
			apiValueRetrieve.Dispose();
			apiValueRetrieve = null ;
		}


		public ValueRetrieveResponse RetrieveTraceValues (ValueRetrieveRequest inProps )
		{
            apiValueRetrieve.setValueWanted(inProps.ValueWanted);
            apiValueRetrieve.setEffectiveDate(inProps.EffectiveDate);
            apiValueRetrieve.setCoverageId(inProps.CoverageID);
            apiValueRetrieve.setSuppCoverageId(inProps.SuppCoverageID);
            apiValueRetrieve.setDateOfBirth(inProps.DateOfBirth);
            apiValueRetrieve.setIssueAge(inProps.IssueAge);
            apiValueRetrieve.setCurrentAge(inProps.CurrentAge);
            apiValueRetrieve.setGender(inProps.Gender);
            apiValueRetrieve.setUwcls(inProps.Uwcls);
            apiValueRetrieve.setTable(inProps.Table);
            apiValueRetrieve.setPercentRating(inProps.PercentRating);
            apiValueRetrieve.setPercentRatingDur(inProps.PercentRatingDur);
            apiValueRetrieve.setFlatExtra(inProps.FlatExtra);
            apiValueRetrieve.setFlatExtraDur(inProps.FlatExtraDur);
            apiValueRetrieve.setSecondDateOfBirth(inProps.SecondDateOfBirth);
            apiValueRetrieve.setSecondIssueAge(inProps.SecondIssueAge);
            apiValueRetrieve.setSecondCurrentAge(inProps.SecondCurrentAge);
            apiValueRetrieve.setSecondGender(inProps.SecondGender);
            apiValueRetrieve.setSecondUwcls(inProps.SecondUwcls);
            apiValueRetrieve.setSecondTable(inProps.SecondTable);
            apiValueRetrieve.setSecondPercentRating(inProps.SecondPercentRating);
            apiValueRetrieve.setSecondPercentRatingDur(inProps.SecondPercentRatingDur);
            apiValueRetrieve.setSecondFlatExtra(inProps.SecondFlatExtra);
            apiValueRetrieve.setSecondFlatExtraDur(inProps.SecondFlatExtraDur);
            apiValueRetrieve.setBillingMode(inProps.BillingMode);
            apiValueRetrieve.setBillingForm(inProps.BillingForm);
            apiValueRetrieve.setIssueDate(inProps.IssueDate);
            apiValueRetrieve.setPaidToDate(inProps.PaidToDate);
            apiValueRetrieve.setDuration(inProps.Duration);
            apiValueRetrieve.setFaceUnitsOrAmount(inProps.FaceUnitsOrAmount);
            apiValueRetrieve.setFaceType(inProps.FaceType);
            apiValueRetrieve.setLoanOutstanding(inProps.LoanOutstanding);
            apiValueRetrieve.setAuxiliaryIssueAge(inProps.AuxiliaryIssueAge);
            apiValueRetrieve.setPremium(inProps.Premium);
            apiValueRetrieve.setCashValueRequested(inProps.CashValueRequested);
            apiValueRetrieve.setDeathBenefitRequested(inProps.DeathBenefitRequested);
            apiValueRetrieve.setSurrenderChargeRequested(inProps.SurrenderChargeRequested);
            apiValueRetrieve.setDividendRequested(inProps.DividendRequested);
            apiValueRetrieve.setDividendAdjustmentRequested(inProps.DividendAdjustmentRequested);
            apiValueRetrieve.setPaidUpAdditionsRequested(inProps.PaidUpAdditionsRequested);
            apiValueRetrieve.setReducedPaidUpRequested(inProps.ReducedPaidUpRequested);
            apiValueRetrieve.setRateUpAge(inProps.RateUpAge);
            apiValueRetrieve.setSecondRateUpAge(inProps.SecondRateUpAge);
            apiValueRetrieve.setValuePerUnit(inProps.ValuePerUnit);
            apiValueRetrieve.setProcessTypeIndicator(inProps.ProcessTypeIndicator);
            apiValueRetrieve.setCompanyCode(inProps.CompanyCode);
            apiValueRetrieve.setPolicyNumber(inProps.PolicyNumber);
            apiValueRetrieve.setBenefitSeq(inProps.BenefitSeq);
            apiValueRetrieve.setBenefitType(inProps.BenefitType);
            apiValueRetrieve.setLastResetDate(inProps.LastResetDate);
            apiValueRetrieve.setLastResetDate(inProps.LastResetDate);
            apiValueRetrieve.setExpirationDate(inProps.ExpirationDate);

            apiValueRetrieve.setFunction("R");  

			apiValueRetrieve.RunTrace();

			ValueRetrieveResponse outProps = new ValueRetrieveResponse() ;
            outProps.ReturnCode = apiValueRetrieve.getReturnCode();
            outProps.ErrorMessage = apiValueRetrieve.getErrorMessage();
            if (outProps.ReturnCode == 0)
            {
                outProps.ValuePerUnit = apiValueRetrieve.getOutValuePerUnit();
                outProps.Premium = apiValueRetrieve.getOutPremium();
                outProps.DirectAnnualPremium = apiValueRetrieve.getOutDirectAnnualPremium();
                outProps.DirectSemiAnnualPremium = apiValueRetrieve.getOutDirectSemiAnnualPremium();
                outProps.DirectQuarterlyPremium = apiValueRetrieve.getOutDirectQuarterlyPremium();
                outProps.DirectMonthlyPremium = apiValueRetrieve.getOutDirectMonthlyPremium();
                outProps.DirectNinethlyPremium = apiValueRetrieve.getOutDirectNinethlyPremium();
                outProps.DirectTenthlyPremium = apiValueRetrieve.getOutDirectTenthlyPremium();
                outProps.Direct26PayPremium = apiValueRetrieve.getOutDirect26PayPremium();
                outProps.Direct52PayPremium = apiValueRetrieve.getOutDirect52PayPremium();
                outProps.Direct13thlyPremium = apiValueRetrieve.getOutDirect13thlyPremium();
                outProps.DirectWeeklyPremium = apiValueRetrieve.getOutDirectWeeklyPremium();
                outProps.DirectBiWeeklyPremium = apiValueRetrieve.getOutDirectWeeklyPremium();
                outProps.DirectAnnualPolicyFee = apiValueRetrieve.getOutDirectAnnualPolicyFee();
                outProps.NextPremiumDate = apiValueRetrieve.getOutNextPremiumDate();
                outProps.PaidUpDate = apiValueRetrieve.getOutPaidUpDate();
                outProps.ExpirationDate = apiValueRetrieve.getOutExpirationDate();
                outProps.ExtendedTermYears = apiValueRetrieve.getOutExtendedTermYears();
                outProps.ExtendedTermDays = apiValueRetrieve.getOutExtendedTermDays();
                outProps.ExtendedTermExpirationDate = apiValueRetrieve.getOutExpirationDate();  
            }


			return outProps ;
		}


        public ValueRetrieveGWResponse RetrieveGWValues(ValueRetrieveGWRequest inProps)
        {
            apiValueRetrieve.setCompanyCode(inProps.CompanyCode);
            apiValueRetrieve.setPolicyNumber(inProps.PolicyNumber);   
            apiValueRetrieve.setEffectiveDate(inProps.EffectiveDate);

            apiValueRetrieve.setFunction("G");  

			apiValueRetrieve.RunTrace();

			ValueRetrieveGWResponse outProps = new ValueRetrieveGWResponse() ;
            outProps.ReturnCode = apiValueRetrieve.getReturnCode();
            outProps.ErrorMessage = apiValueRetrieve.getErrorMessage();
            if (outProps.ReturnCode == 0)
            {
                outProps.GWRiderFeeRate = apiValueRetrieve.getGWRiderFeeRate();
                outProps.GWRiderMERate = apiValueRetrieve.getGWRiderMERate();  
            }

            return outProps;  

        }


	}
}
