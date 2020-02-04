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
*  20101008-003-01  DAR   07/14/2010    Initial implementation  
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for PremIllus.
	/// </summary>

	public class PremIllus : IPremIllus  
	{
		OPRMILLU apiPrem ; 

		public static OAPPLICA apiApp ; 
		public string UserType ;

        public const int MaxInsureds = 10;
        public const int MaxCoverages = 5;
        public const int MaxSupp = 3;  

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiPrem = new OPRMILLU(apiApp, UserType);  

                
            BaseResponse outProps = new BaseResponse() ;
            outProps.ReturnCode = apiPrem.getContReturnCode();
            outProps.ErrorMessage = apiPrem.getContMessage();
            return outProps;   

		}
		public void Dispose() 
		{
			apiPrem.Dispose(); 
			apiPrem = null ; 
		}


		public PremiumIllustrationResponse RunQuote (PremiumIllustrationRequest inProps ) 
		{
            apiPrem.setBillingForm(inProps.BillingForm);
            apiPrem.setBillingMode(inProps.BillingMode);
            apiPrem.setIssueState(inProps.IssueState);
            apiPrem.setIssueDate(inProps.IssueDate); 
            apiPrem.setEffectiveDate(inProps.EffectiveDate);
            apiPrem.setCompanyCode(inProps.CompanyCode);

            // With web service calls we cannot assume input arrays will be initialized properly, or have the correct 
            // lengths.  Put in safeguards to avoid null or array limit exceptions.  

            // Make sure COBOL elements are initialized to the end of their length no matter the size of input arrays.  
            for (int x1 = 0; x1 < MaxInsureds; x1++)
            {

                apiPrem.setIssueAge(x1 + 1, 0);
                apiPrem.setDob(x1 + 1, 0);
                apiPrem.setIssueAge(x1 + 1, 0);
                apiPrem.setGender(x1 + 1, " ");
                apiPrem.setUwcls(x1 + 1, " ");

                for (int x2 = 0; x2 < MaxCoverages; x2++)
                {
                    apiPrem.setCovName(x1 + 1, x2 + 1, "");
                    apiPrem.setCovFaceAmount(x1 + 1, x2 + 1, 0);
                    apiPrem.setCovUnits(x1 + 1, x2 + 1, 0);
                    apiPrem.setCovTable(x1 + 1, x2 + 1, "  ");
                    apiPrem.setCovPctRating(x1 + 1, x2 + 1, 0);
                    apiPrem.setCovPctRatingDur(x1 + 1, x2 + 1,0);
                    apiPrem.setCovFlatExtra(x1 + 1, x2 + 1, 0);
                    apiPrem.setCovFlatExtraDur(x1 + 1, x2 + 1, 0);

                    for (int x3 = 0; x3 < MaxSupp; x3++)
                    {

                        apiPrem.setSuppName(x1 + 1, x2 + 1, x3 + 1, "");
                        apiPrem.setSuppFaceAmount(x1 + 1, x2 + 1, x3 + 1, 0);
                        apiPrem.setSuppUnits(x1 + 1, x2 + 1, x3 + 1, 0);
                        apiPrem.setSuppTable(x1 + 1, x2 + 1, x3 + 1, "  ");
                        apiPrem.setSuppPctRating(x1 + 1, x2 + 1, x3 + 1, 0);
                        apiPrem.setSuppPctRatingDur(x1 + 1, x2 + 1, x3 + 1, 0);
                        apiPrem.setSuppFlatExtra(x1 + 1, x2 + 1, x3 + 1, 0);
                        apiPrem.setSuppFlatExtraDur(x1 + 1, x2 + 1, x3 + 1, 0);

                    }
                }
            }


            for (int x1 = 0; x1 < MaxInsureds; x1++)
            {
                // given the complexity of the "stepped" 3-D arrays, we'll use try/catch to protect against 
                // null array references or invalid lengths.  We've already initialized COBOL inputs to 
                // blanks, zeroes, so an invalid reference here results in no additional action.  

                try
                {
                    apiPrem.setIssueAge(x1 + 1, inProps.IssueAge[x1]);
                }
                catch { }

                try
                {
                    apiPrem.setDob(x1 + 1, inProps.IssueAge[x1]);
                }
                catch { }

                try
                {
                    apiPrem.setGender(x1 + 1, inProps.Gender[x1]);
                }
                catch { }

                try
                {
                    apiPrem.setUwcls(x1 + 1, inProps.Uwcls[x1]);
                }
                catch { }  

                for (int x2 = 0; x2 < MaxCoverages; x2++)
                {
                    try
                    {
                        apiPrem.setCovName(x1 + 1, x2 + 1, inProps.CoverageID[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovFaceAmount(x1 + 1, x2 + 1, inProps.CovFaceAmount[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovUnits(x1 + 1, x2 + 1, inProps.CovUnits[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovTable(x1 + 1, x2 + 1, inProps.CovTable[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovPctRating(x1 + 1, x2 + 1, inProps.CovPctRating[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovPctRatingDur(x1 + 1, x2 + 1, inProps.CovPctRatingDur[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovFlatExtra(x1 + 1, x2 + 1, inProps.CovFlatExtra[x1][x2]);
                    }
                    catch { }

                    try
                    {
                        apiPrem.setCovFlatExtraDur(x1 + 1, x2 + 1, inProps.CovFlatExtraDur[x1][x2]);
                    }
                    catch { } 


                    for (int x3 = 0; x3 < MaxSupp; x3++)
                    {
                        try
                        {
                            apiPrem.setSuppName(x1 + 1, x2 + 1, x3 + 1, inProps.SuppCoverageID[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppFaceAmount(x1 + 1, x2 + 1, x3 + 1, inProps.SuppFaceAmount[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppUnits(x1 + 1, x2 + 1, x3 + 1, inProps.SuppUnits[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppTable(x1 + 1, x2 + 1, x3 + 1, inProps.SuppTable[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppPctRating(x1 + 1, x2 + 1, x3 + 1, inProps.SuppPctRating[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppPctRatingDur(x1 + 1, x2 + 1, x3 + 1, inProps.SuppPctRatingDur[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppFlatExtra(x1 + 1, x2 + 1, x3 + 1, inProps.SuppFlatExtra[x1][x2][x3]);
                        }
                        catch { }

                        try
                        {
                            apiPrem.setSuppFlatExtraDur(x1 + 1, x2 + 1, x3 + 1, inProps.SuppFlatExtraDur[x1][x2][x3]);
                        }
                        catch { }  

                    }
                }
            }



			apiPrem.RunQuote(); 

			PremiumIllustrationResponse outProps = new PremiumIllustrationResponse() ;
            outProps.ReturnCode = apiPrem.getContReturnCode();

            outProps.ErrorMessage = apiPrem.getContMessage();
            
            outProps.ContReturnCode = apiPrem.getContReturnCode();
            outProps.ContMessage = apiPrem.getContMessage();
            outProps.ContPolicyFee = apiPrem.getContPolicyFee();
            outProps.ContAnnualPrem = apiPrem.getContAnnualPrem();
            outProps.ContSemiAnnPrem = apiPrem.getContSemiAnnPrem();
            outProps.ContQtrlyPrem = apiPrem.getContQtrlyPrem();
            outProps.ContMonthlyPrem = apiPrem.getContMonthlyPrem();
            outProps.ContBiweeklyPrem = apiPrem.getContBiweeklyPrem();
            outProps.ContWeeklyPrem = apiPrem.getContWeeklyPrem();

            //outProps.CovReturnCode = new int[MaxInsureds, MaxCoverages];
            //outProps.CovMessage = new string[MaxInsureds, MaxCoverages];
            //outProps.CovAnnualPrem = new double[MaxInsureds, MaxCoverages];
            //outProps.CovSemiAnnlPrem = new double[MaxInsureds, MaxCoverages];
            //outProps.CovQtrlyPrem = new double[MaxInsureds, MaxCoverages];
            //outProps.CovMonthlyPrem = new double[MaxInsureds, MaxCoverages];
            //outProps.CovBiweeklyPrem = new double[MaxInsureds, MaxCoverages];
            //outProps.CovWeeklyPrem = new double[MaxInsureds, MaxCoverages];

            outProps.CovReturnCode = new int[MaxInsureds][];  
            outProps.CovMessage = new string[MaxInsureds] [];
            outProps.CovAnnualPrem = new double[MaxInsureds] [];
            outProps.CovSemiAnnlPrem = new double[MaxInsureds] [];
            outProps.CovQtrlyPrem = new double[MaxInsureds] [];
            outProps.CovMonthlyPrem = new double[MaxInsureds] [];
            outProps.CovBiweeklyPrem = new double[MaxInsureds] [];
            outProps.CovWeeklyPrem = new double[MaxInsureds] [];


            //outProps.SuppReturnCode = new int[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppMessage = new string[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppAnnualPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppSemiAnnlPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppQuarterlyPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppMonthlyPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppBiweeklyPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];
            //outProps.SuppWeeklyPrem = new double[MaxInsureds, MaxCoverages, MaxSupp];  

            outProps.SuppReturnCode = new int[MaxInsureds][] [];
            outProps.SuppMessage = new string[MaxInsureds][] [];
            outProps.SuppAnnualPrem = new double[MaxInsureds][] [];
            outProps.SuppSemiAnnlPrem = new double[MaxInsureds][] [];
            outProps.SuppQuarterlyPrem = new double[MaxInsureds][] [];
            outProps.SuppMonthlyPrem = new double[MaxInsureds][] [];
            outProps.SuppBiweeklyPrem = new double[MaxInsureds][] [];
            outProps.SuppWeeklyPrem = new double[MaxInsureds][] [];

            for (int x1 = 0; x1 < MaxInsureds; x1++)
            {
                outProps.CovReturnCode[x1] = new int[MaxCoverages];
                outProps.CovMessage[x1] = new string[MaxCoverages];
                outProps.CovAnnualPrem[x1] = new double[MaxCoverages];
                outProps.CovSemiAnnlPrem[x1] = new double[MaxCoverages];
                outProps.CovQtrlyPrem[x1] = new double[MaxCoverages];
                outProps.CovMonthlyPrem[x1] = new double[MaxCoverages];
                outProps.CovBiweeklyPrem[x1] = new double[MaxCoverages];
                outProps.CovWeeklyPrem[x1] = new double[MaxCoverages];

                outProps.SuppReturnCode[x1] = new int[MaxCoverages][];
                outProps.SuppMessage[x1] = new string[MaxCoverages][];
                outProps.SuppAnnualPrem[x1] = new double[MaxCoverages][];
                outProps.SuppSemiAnnlPrem[x1] = new double[MaxCoverages][];
                outProps.SuppQuarterlyPrem[x1] = new double[MaxCoverages][];
                outProps.SuppMonthlyPrem[x1] = new double[MaxCoverages][];
                outProps.SuppBiweeklyPrem[x1] = new double[MaxCoverages][];
                outProps.SuppWeeklyPrem[x1] = new double[MaxCoverages][];
                
                for (int x2 = 0; x2 < MaxCoverages; x2++)
                {
                    outProps.CovReturnCode[x1] [x2] = apiPrem.getCovReturnCode(x1 + 1, x2 + 1);
                    outProps.CovMessage[x1] [x2] = apiPrem.getCovMessage(x1 + 1, x2 + 1);
                    outProps.CovAnnualPrem[x1] [x2] = apiPrem.getCovAnnualPrem(x1 + 1, x2 + 1);
                    outProps.CovSemiAnnlPrem[x1] [x2] = apiPrem.getCovSemiAnnlPrem(x1 + 1, x2 + 1);
                    outProps.CovQtrlyPrem[x1] [x2] = apiPrem.getCovQtrlyPrem(x1 + 1, x2 + 1);
                    outProps.CovMonthlyPrem[x1] [x2] = apiPrem.getCovMonthlyPrem(x1 + 1, x2 + 1);
                    outProps.CovBiweeklyPrem[x1] [x2] = apiPrem.getCovBiweeklyPrem(x1 + 1, x2 + 1);
                    outProps.CovWeeklyPrem[x1] [x2] = apiPrem.getCovWeeklyPrem(x1 + 1, x2 + 1);

                    outProps.SuppReturnCode[x1] [x2] = new int[MaxSupp];
                    outProps.SuppMessage[x1] [x2] = new string[MaxSupp];
                    outProps.SuppAnnualPrem[x1] [x2] = new double[MaxSupp];  
                    outProps.SuppSemiAnnlPrem[x1] [x2] = new double [MaxSupp];
                    outProps.SuppQuarterlyPrem[x1] [x2] = new double[MaxSupp];
                    outProps.SuppMonthlyPrem[x1] [x2] = new double[MaxSupp];
                    outProps.SuppBiweeklyPrem[x1] [x2] = new double[MaxSupp];
                    outProps.SuppWeeklyPrem[x1] [x2] = new double[MaxSupp];


                    for (int x3 = 0; x3 < MaxSupp; x3++)
                    {
                        outProps.SuppReturnCode[x1] [x2] [x3] = apiPrem.getSuppReturnCode(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppMessage[x1] [x2] [x3] = apiPrem.getSuppMessage(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppAnnualPrem[x1] [x2] [x3] = apiPrem.getSuppAnnualPrem(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppSemiAnnlPrem[x1] [x2] [x3] = apiPrem.getSuppSemiAnnlPrem(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppQuarterlyPrem[x1] [x2] [x3] = apiPrem.getSuppQuarterlyPrem(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppMonthlyPrem[x1] [x2] [x3] = apiPrem.getSuppMonthlyPrem(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppBiweeklyPrem[x1] [x2] [x3] = apiPrem.getSuppBiweeklyPrem(x1 + 1, x2 + 1, x3 + 1);
                        outProps.SuppWeeklyPrem[x1] [x2] [x3] = apiPrem.getSuppWeeklyPrem(x1 + 1, x2 + 1, x3 + 1);
                    }
                }
            }
		
			return outProps ; 
		}


	}
}
