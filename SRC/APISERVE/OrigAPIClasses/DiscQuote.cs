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
*  20101008-003-01  WAR   07/16/2010    Initial implementation
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
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

	public class DiscQuote :  IDiscQuote
	{
		ODISQUOT apiDiscQuote ;

		public static OAPPLICA apiApp ;
		public string UserType ;

		public BaseResponse Init (string userType)
		{
			UserType = userType ;
			apiDiscQuote = new ODISQUOT(apiApp, UserType);

			BaseResponse outProps = new BaseResponse() ;
            outProps.ReturnCode = 0;
            try
            {
                outProps.ReturnCode = apiDiscQuote.getReturnCode();
            }
            catch { }

            outProps.ErrorMessage = apiDiscQuote.getErrorMessage();
            return outProps;  

		}
		public void Dispose()
		{
			apiDiscQuote.Dispose();
			apiDiscQuote = null ;
		}


		public DisclosureQuoteResponse RunQuote (DisclosureQuoteRequest inProps )
		{
            apiDiscQuote.setFunction(inProps.Function);
            apiDiscQuote.setCoverageId(inProps.CoverageId);
            apiDiscQuote.setSuppCoverageId(inProps.SuppCoverageId);
            apiDiscQuote.setBenefitType(inProps.BenefitType);
            apiDiscQuote.setBenefitSubType(inProps.BenefitSubType);
            apiDiscQuote.setCompanyCode(inProps.CompanyCode);
            apiDiscQuote.setPolicyNumber(inProps.PolicyNumber);
            apiDiscQuote.setBenefitSeq(inProps.BenefitSeq);
            apiDiscQuote.setParentBenefitSeq(inProps.ParentBenefitSeq);
            apiDiscQuote.setSubstandardSeq(inProps.SubstSeq);
            apiDiscQuote.setIssueDate(inProps.IssueDate);
            apiDiscQuote.setEffDate(inProps.EffectiveDate);
            apiDiscQuote.setForm(inProps.BillingForm);
            apiDiscQuote.setMode(inProps.BillingMode);
            apiDiscQuote.setFaceUnitsOrAmount(inProps.FaceUnitsOrAmount);
            apiDiscQuote.setFaceType(inProps.FaceType);
            apiDiscQuote.setPremBasedOnDate(inProps.PremBasedOnDate);
            apiDiscQuote.setPremiumRank(inProps.PremiumRank);
            apiDiscQuote.setRatingRank(inProps.RatingRank);
            apiDiscQuote.setCurrPercent(inProps.CurrPercent);
            apiDiscQuote.setGuarPercent(inProps.GuarPercent);
            apiDiscQuote.setCurrBasis(inProps.CurrBasis);
            apiDiscQuote.setGuarBasis(inProps.GuarBasis);
            apiDiscQuote.setInputIssueState(inProps.InputIssueState);

            // Modify handling of inputs to not assume anything about arrays, as they now come from web service, and may 
            // be null or not set to the correct number of occurrences.  
            int maxInsureds = 2 ;
            for (int x = 0; x < maxInsureds; x++)
            {
                apiDiscQuote.setGender(x + 1, " ");
                apiDiscQuote.setUwcls(x + 1, " ");
                apiDiscQuote.setDob(x + 1, 0);
                apiDiscQuote.setIssueAge(x + 1, 0);
                apiDiscQuote.setTable(x + 1, "  ");
                apiDiscQuote.setPercentRating(x + 1, 0);
                apiDiscQuote.setPercentRatingDur(x + 1, 0);
                apiDiscQuote.setFlatExtra(x + 1, 0);
                apiDiscQuote.setFlatExtraDur(x + 1, 0); 

            }
            if (inProps.Gender != null) 
                for (int x = 0; x < inProps.Gender.Length && x < maxInsureds; x++)
                    apiDiscQuote.setGender(x + 1, inProps.Gender[x]);

            if (inProps.Uwcls != null) 
                for (int x = 0; x < inProps.Uwcls.Length && x < maxInsureds; x++)
                    apiDiscQuote.setUwcls(x + 1, inProps.Uwcls[x]);


            if (inProps.Dob != null)
                for (int x = 0; x < inProps.Dob.Length && x < maxInsureds; x++)
                    apiDiscQuote.setDob(x + 1, inProps.Dob[x]);

            if (inProps.IssueAge != null)
                for (int x = 0; x < inProps.IssueAge.Length && x < maxInsureds; x++)
                    apiDiscQuote.setIssueAge(x + 1, inProps.IssueAge[x]);

            if (inProps.RatingTable != null)
                for (int x = 0; x < inProps.RatingTable.Length && x < maxInsureds; x++)
                    apiDiscQuote.setTable(x + 1, inProps.RatingTable[x]);


            if (inProps.PercentRating != null)
                for (int x = 0; x < inProps.PercentRating.Length && x < maxInsureds; x++)
                    apiDiscQuote.setPercentRating(x + 1, inProps.PercentRating[x]);


            if (inProps.PercentRatingDur != null)
                for (int x = 0; x < inProps.PercentRatingDur.Length && x < maxInsureds; x++)
                    apiDiscQuote.setPercentRatingDur(x + 1, inProps.PercentRatingDur[x]);


            if (inProps.FlatExtra != null)
                for (int x = 0; x < inProps.FlatExtra.Length && x < maxInsureds; x++)
                    apiDiscQuote.setFlatExtra(x + 1, inProps.FlatExtra[x]);


            if (inProps.FlatExtraDur != null)
                for (int x = 0; x < inProps.FlatExtraDur.Length && x < maxInsureds; x++)
                    apiDiscQuote.setFlatExtraDur(x + 1, inProps.FlatExtraDur[x]);


			apiDiscQuote.RunQuote();

			DisclosureQuoteResponse outProps = new DisclosureQuoteResponse() ;
            try
            {
                outProps.ReturnCode = apiDiscQuote.getReturnCode();
            }
            catch { }

            outProps.ErrorMessage = apiDiscQuote.getErrorMessage();
            outProps.PriReturnCode = apiDiscQuote.getPriReturnCode();
            outProps.PriReturnMessage = apiDiscQuote.getPriErrorMessage();
            outProps.PrrReturnCode = apiDiscQuote.getPrrReturnCode();
            outProps.PrrReturnMessage = apiDiscQuote.getPrrErrorMessage();
            outProps.GpiReturnCode = apiDiscQuote.getGpiReturnCode();
            outProps.GpiReturnMessage = apiDiscQuote.getGpiErrorMessage();
            outProps.CviReturnCode = apiDiscQuote.getCviReturnCode();
            outProps.CviReturnMessage = apiDiscQuote.getCviErrorMessage();
            outProps.DbiReturnCode = apiDiscQuote.getDbiReturnCode();
            outProps.DbiReturnMessage = apiDiscQuote.getDbiErrorMessage();
            outProps.DviReturnCode = apiDiscQuote.getDviReturnCode();
            outProps.DviReturnMessage = apiDiscQuote.getDviErrorMessage();
            outProps.RpuReturnCode = apiDiscQuote.getRpuReturnCode();
            outProps.RpuReturnMessage = apiDiscQuote.getRpuErrorMessage();
            outProps.EtiReturnCode = apiDiscQuote.getEtiReturnCode();
            outProps.EtiReturnMessage = apiDiscQuote.getEtiErrorMessage();
            outProps.SpiReturnCode = apiDiscQuote.getSpiReturnCode();
            outProps.SpiReturnMessage = apiDiscQuote.getSpiErrorMessage();
            outProps.SgiReturnCode = apiDiscQuote.getSgiReturnCode();
            outProps.SgiReturnMessage = apiDiscQuote.getSgiErrorMessage();
            outProps.DatePaidUp = apiDiscQuote.getDatePaidUp();
            outProps.ExpirationDate = apiDiscQuote.getExpirationDate();
            outProps.NextPremDate = apiDiscQuote.getNextPremiumDate();
            outProps.NextPremDur = apiDiscQuote.getNextPremiumDur();
            outProps.Description = apiDiscQuote.getDescription();
            outProps.IssueState = apiDiscQuote.getIssueState();
            outProps.DirectMonthlyPrem = apiDiscQuote.getDirMonthlyPrem();
            outProps.DirectQuarterlyPrem = apiDiscQuote.getDirQuarterlyPrem();
            outProps.DirectSemiAnnualPrem = apiDiscQuote.getDirSemiAnnualPrem();
            outProps.AnnualPolicyFee = apiDiscQuote.getAnnualPolicyFee();
            outProps.NetCurrIndex05 = apiDiscQuote.get05thNetCurrIndex();
            outProps.NetCurrIndex10 = apiDiscQuote.get10thNetCurrIndex();
            outProps.NetCurrIndex20 = apiDiscQuote.get20thNetCurrIndex();
            outProps.NetCurrIndex25 = apiDiscQuote.get25thNetCurrIndex();
            outProps.NetGuarIndex05 = apiDiscQuote.get05thNetGuarIndex();
            outProps.NetGuarIndex10 = apiDiscQuote.get10thNetGuarIndex();
            outProps.NetGuarIndex20 = apiDiscQuote.get20thNetGuarIndex();
            outProps.NetGuarIndex25 = apiDiscQuote.get25thNetGuarIndex();
            outProps.SurrCurrIndex05 = apiDiscQuote.get05thSurrCurrIndex();
            outProps.SurrCurrIndex10 = apiDiscQuote.get10thSurrCurrIndex();
            outProps.SurrCurrIndex20 = apiDiscQuote.get20thSurrCurrIndex();
            outProps.SurrCurrIndex25 = apiDiscQuote.get25thSurrCurrIndex();
            outProps.SurrGuarIndex05 = apiDiscQuote.get05thSurrGuarIndex();
            outProps.SurrGuarIndex10 = apiDiscQuote.get10thSurrGuarIndex();
            outProps.SurrGuarIndex20 = apiDiscQuote.get20thSurrGuarIndex();
            outProps.SurrGuarIndex25 = apiDiscQuote.get25thSurrGuarIndex();
            outProps.EquivCurrIndex10 = apiDiscQuote.get10thEquivCurrIndex();
            outProps.EquivCurrIndex20 = apiDiscQuote.get20thEquivCurrIndex();
            outProps.EquivCurrIndex25 = apiDiscQuote.get25thEquivCurrIndex();
            outProps.EquivGuarIndex10 = apiDiscQuote.get10thEquivGuarIndex();
            outProps.EquivGuarIndex20 = apiDiscQuote.get20thEquivGuarIndex();
            outProps.EquivGuarIndex25 = apiDiscQuote.get25thEquivGuarIndex();
            outProps.CalifCurrIndex05 = apiDiscQuote.get05thCalifCurrIndex();
            outProps.CalifCurrIndex10 = apiDiscQuote.get10thCalifCurrIndex();
            outProps.CalifCurrIndex20 = apiDiscQuote.get20thCalifCurrIndex();
            outProps.CalifCurrIndex25 = apiDiscQuote.get25thCalifCurrIndex();
            outProps.CalifGuarIndex05 = apiDiscQuote.get05thCalifGuarIndex();
            outProps.CalifGuarIndex10 = apiDiscQuote.get10thCalifGuarIndex();
            outProps.CalifGuarIndex20 = apiDiscQuote.get20thCalifGuarIndex();
            outProps.CalifGuarIndex25 = apiDiscQuote.get25thCalifGuarIndex();
            outProps.InitModalPremCnt = apiDiscQuote.getInitModalPremCnt();
            outProps.InitPremCnt = apiDiscQuote.getInitPremCnt();
            outProps.RenewalPremCnt = apiDiscQuote.getRenewalPremCnt();
            outProps.GuarPremCnt = apiDiscQuote.getGuarPremCnt();
            outProps.CashValuesCnt = apiDiscQuote.getCashValuesCnt();
            outProps.DeathBenefitCnt = apiDiscQuote.getDeathBenefitCnt();
            outProps.DivAtIssueCnt = apiDiscQuote.getDivAtIssueCnt();
            outProps.RpuCnt = apiDiscQuote.getRpuCnt();
            outProps.EtiYearsCnt = apiDiscQuote.getEtiYearsCnt();
            outProps.EtiDaysCnt = apiDiscQuote.getEtiDaysCnt();
            outProps.SubstCurrCnt = apiDiscQuote.getSubstCurrCnt();
            outProps.SubstGuarCnt = apiDiscQuote.getSubstGuarCnt();

            outProps.InitialModalPrem = new double [200];
            outProps.InitialPrem = new double[200];
            outProps.RenewalPrem = new double[200];
            outProps.GuarPrem = new double[200];
            outProps.CashValue = new double[200];
            outProps.DeathBenefit = new double[200];
            outProps.DivAtIssue = new double[200];
            outProps.RpuValue = new double[200];
            outProps.EtiYear = new double[200];
            outProps.EtiDay = new double[200];
            outProps.SubstCurr = new double[200];
            outProps.SubstGuar = new double[200];

            for (int x1 = 0; x1 < 200; x1++)
            {
                outProps.InitialModalPrem[x1] = apiDiscQuote.getInitialModalPrem(x1 + 1);
                outProps.InitialPrem[x1] = apiDiscQuote.getInitialPrem(x1 + 1);
                outProps.RenewalPrem[x1] = apiDiscQuote.getRenewalPrem(x1 + 1);
                outProps.GuarPrem[x1] = apiDiscQuote.getGuarPrem(x1 + 1);
                outProps.CashValue[x1] = apiDiscQuote.getCashValue(x1 + 1);
                outProps.DeathBenefit[x1] = apiDiscQuote.getDeathBenefit(x1 + 1);
                outProps.DivAtIssue[x1] = apiDiscQuote.getDivAtIssue(x1 + 1);
                outProps.RpuValue[x1] = apiDiscQuote.getRpuValue(x1 + 1);
                outProps.EtiYear[x1] = apiDiscQuote.getEtiYear(x1 + 1);
                outProps.EtiDay[x1] = apiDiscQuote.getEtiDay(x1 + 1);
                outProps.SubstCurr[x1] = apiDiscQuote.getSubstCurr(x1 + 1);
                outProps.SubstGuar[x1] = apiDiscQuote.getSubstGuar(x1 + 1);
            }

			return outProps ;
		}

	}
}
