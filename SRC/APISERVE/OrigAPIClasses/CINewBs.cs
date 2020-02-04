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
*  20060818-015-01   DAR   03/28/08    Initial implementation
*  20060818-015-03   DAR   06/03/08    Add YEI properties for NB Credit Insurance.
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services  
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;



namespace PDMA.LifePro
{
    /// <summary>
    /// The LifePRO Credit Insurance New Business object 
    /// </summary>

    public class CINewBs :  ICINewBs
    {
        OCINEWBS apiCINB ;

        public static OAPPLICA apiApp ;
        public string UserType ;

        public BaseResponse Init (string userType)
        {
            UserType = userType ;
            apiCINB = new OCINEWBS(apiApp, UserType);

            BaseResponse outProps = new BaseResponse() ;
            outProps.ReturnCode = apiCINB.getReturnCode() ;
            outProps.ErrorMessage = apiCINB.getReturnMessage() ;
            return outProps;   

        }
        public void Dispose()
        {
            apiCINB.Dispose();
            apiCINB = null ;
        }


        public CreditInsuranceNewBusinessResponse InitiateApplication(CreditInsuranceNewBusinessRequest inProps)
        {
            setInput(inProps);
            apiCINB.InitiateApplication();
            CreditInsuranceNewBusinessResponse outProps = setOutput();
            return outProps;
        }

        public CreditInsuranceNewBusinessResponse QuoteApplication(CreditInsuranceNewBusinessRequest inProps)
        {
            setInput(inProps);
            apiCINB.QuoteApplication();
            CreditInsuranceNewBusinessResponse outProps = setOutput();
            return outProps;
        }

        private void setInput (CreditInsuranceNewBusinessRequest inProps) {

            apiCINB.setCompanyCode(inProps.CompanyCode);
            apiCINB.setPolicyNumber(inProps.PolicyNumber);
            apiCINB.setProductId(inProps.ProductId);
            apiCINB.setTransactionDate(inProps.TransactionDate);
            apiCINB.setLoanNumber(inProps.LoanNumber);
            apiCINB.setLoanDate(inProps.LoanDate);
            apiCINB.setLanguagePreference(inProps.LanguagePreference);
            apiCINB.setBranchNumber(inProps.BranchNumber);
            apiCINB.setRescissionDate(inProps.RescissionDate);
            apiCINB.setLoanTerm(inProps.LoanTerm);
            apiCINB.setLoanMaturityDate(inProps.LoanMaturityDate);
            apiCINB.setNextLoanPaymentDate(inProps.NextLoanPaymentDate);
            apiCINB.setLoanDueDay(inProps.LoanDueDay);
            apiCINB.setBranchState(inProps.BranchState);
            apiCINB.setIndividualOrJoint(inProps.IndividualOrJoint);
            apiCINB.setMonthlyPayment(inProps.MonthlyPayment);
            apiCINB.setPrincipalAmount(inProps.PrincipalAmount);
            apiCINB.setInterestRate(inProps.InterestRate);
            apiCINB.setAmountFinanced(inProps.AmountFinanced);
            apiCINB.setAPR(inProps.APR);
            apiCINB.setInceptionDate(inProps.InceptionDate);
            apiCINB.setIssueState(inProps.IssueState);
            apiCINB.setCoverageTerm(inProps.CoverageTerm);
            apiCINB.setLifeInsuranceAmount(inProps.LifeInsuranceAmount);
            apiCINB.setDICoverageAmount(inProps.DICoverageAmount);
            apiCINB.setReportingOnly(inProps.ReportingOnly);


            // For web service calls, allow for the fact that input arrays may not be initialized properly 
            // if they are not needed.  Avoid crashing on null references, improper lengths.   
            try
            {
                for (int i = 0; i < inProps.Feature.Length; i++)
                    apiCINB.setFeature(i + 1, inProps.Feature[i]);
            }
            catch { } 

           
            try 
            {
                for (int i = 0; i < inProps.ApplicantFirstName.Length; i++)
                {
                    apiCINB.setApplicantFirstName(i + 1, inProps.ApplicantFirstName[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantMiddleName.Length; i++)
                {
                    apiCINB.setApplicantMiddleName(i + 1, inProps.ApplicantMiddleName[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantLastName.Length; i++)
                {
                    apiCINB.setApplicantLastName(i + 1, inProps.ApplicantLastName[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantAddressLine1.Length; i++)
                {
                    apiCINB.setApplicantAddressLine1(i + 1, inProps.ApplicantAddressLine1[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantAddressLine2.Length; i++)
                {
                    apiCINB.setApplicantAddressLine2(i + 1, inProps.ApplicantAddressLine2[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantAddressLine3.Length; i++)
                {
                    apiCINB.setApplicantAddressLine3(i + 1, inProps.ApplicantAddressLine3[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantCity.Length; i++)
                {
                    apiCINB.setApplicantCity(i + 1, inProps.ApplicantCity[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantState.Length; i++)
                {
                    apiCINB.setApplicantState(i + 1, inProps.ApplicantState[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantZip.Length; i++)
                {
                    apiCINB.setApplicantZip(i + 1, inProps.ApplicantZip[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantBoxNumber.Length; i++)
                {
                    apiCINB.setApplicantBoxNumber(i + 1, inProps.ApplicantBoxNumber[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantZipExtension.Length; i++)
                {
                    apiCINB.setApplicantZipExtension(i + 1, inProps.ApplicantZipExtension[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantSSN.Length; i++)
                {
                    apiCINB.setApplicantSSN(i + 1, inProps.ApplicantSSN[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantPhone.Length; i++)
                {
                    apiCINB.setApplicantPhone(i + 1, inProps.ApplicantPhone[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantDOB.Length; i++)
                {
                    apiCINB.setApplicantDOB(i + 1, inProps.ApplicantDOB[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantGender.Length; i++)
                {
                    apiCINB.setApplicantGender(i + 1, inProps.ApplicantGender[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantUWCLS.Length; i++)
                {
                    apiCINB.setApplicantUWCLS(i + 1, inProps.ApplicantUWCLS[i]);
                }
            }
            catch {}


            try
            {
                for (int i = 0; i < inProps.ApplicantBorrowerType.Length; i++)
                {
                    apiCINB.setApplicantBorrowerType(i + 1, inProps.ApplicantBorrowerType[i]);
                }
            }
            catch { }  


            try 
            {
                for (int i = 0; i < inProps.ApplicantCreditLife.Length; i++)
                {
                    apiCINB.setApplicantCreditLife(i + 1, inProps.ApplicantCreditLife[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantCreditDisability.Length; i++)
                {
                    apiCINB.setApplicantCreditDisability(i + 1, inProps.ApplicantCreditDisability[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantUnemployment.Length; i++)
                {
                    apiCINB.setApplicantUnemployment(i + 1, inProps.ApplicantUnemployment[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantOccupationCode.Length; i++)
                {
                    apiCINB.setApplicantOccupationCode(i + 1, inProps.ApplicantOccupationCode[i]);
                }
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.ApplicantEmploymentStatus.Length; i++)
                {
                    apiCINB.setApplicantEmploymentStatus(i + 1, inProps.ApplicantEmploymentStatus[i]);
                }
            }
            catch {}  


            try 
            {
                for (int i = 0; i < inProps.ApplicantHoursWorked.Length; i++)
                {
                    apiCINB.setApplicantHoursWorked(i + 1, inProps.ApplicantHoursWorked[i]);
                }
            }
            catch {}  

        }


        private CreditInsuranceNewBusinessResponse setOutput () {

           CreditInsuranceNewBusinessResponse  outProps = new CreditInsuranceNewBusinessResponse();

            outProps.ReturnCode = apiCINB.getReturnCode();
            outProps.ErrorMessage = apiCINB.getReturnMessage();

            outProps.LastError = apiCINB.getLastError();

            int count = outProps.LastError ;
            outProps.ErrorNumber = new int[count];
            outProps.ErrorType = new string[count];
            outProps.ErrorCoverageType = new string[count];
            outProps.ErrorDetailMessage = new string[count];

            for (int i=1;i<=count;i++)
            {
                outProps.ErrorNumber[i-1] = apiCINB.getErrorNumber(i);
                outProps.ErrorType[i-1] = apiCINB.getErrorType(i);
                outProps.ErrorCoverageType[i-1] = apiCINB.getErrorCoverageType(i).Trim();
                outProps.ErrorDetailMessage[i-1] = apiCINB.getErrorMessage(i).Trim();
            }

            count = 2; // Number of coverages is fixed to 2
            outProps.CoverageAmount = new double[2];
            outProps.TermOfCoverage = new int[2];
            outProps.PremiumType = new string[2];
            outProps.MonthlySinglePremium = new double[2];
            outProps.MonthlyJointPremium = new double[2];
            outProps.MonthlyBilledPremium = new double[2];
            outProps.AllSinglePremium = new double[2];
            outProps.AllJointPremium = new double[2];
            outProps.AllBilledPremium = new double[2];

            for (int i = 1; i <= 2; i++)
            {
                outProps.CoverageAmount[i - 1] = apiCINB.getCoverageAmount(i);
                outProps.TermOfCoverage[i - 1] = apiCINB.getTermOfCoverage(i);
                outProps.PremiumType[i - 1] = apiCINB.getPremiumType(i);
                outProps.MonthlySinglePremium[i - 1] = apiCINB.getMonthlySinglePremium(i);
                outProps.MonthlyJointPremium[i - 1] = apiCINB.getMonthlyJointPremium(i);
                outProps.MonthlyBilledPremium[i - 1] = apiCINB.getMonthlyBilledPremium(i);
                outProps.AllSinglePremium[i - 1] = apiCINB.getAllSinglePremium(i);
                outProps.AllJointPremium[i - 1] = apiCINB.getAllJointPremium(i);
                outProps.AllBilledPremium[i - 1] = apiCINB.getAllBilledPremium(i);
            }

            outProps.TotalMonthlySinglePremium = apiCINB.getTotalMonthlySinglePremium();
            outProps.TotalMonthlyJointPremium = apiCINB.getTotalMonthlyJointPremium();
            outProps.TotalMonthlyBilledPremium = apiCINB.getTotalMonthlyBilledPremium();
            outProps.TotalAllSinglePremium = apiCINB.getTotalAllSinglePremium();
            outProps.TotalAllJointPremium = apiCINB.getTotalAllJointPremium();
            outProps.TotalAllBilledPremium = apiCINB.getTotalAllBilledPremium();

            outProps.YEIRequested = new string[2][]; 
            outProps.YEIAllowed = new string[2] [];

            for (int i = 1; i <= 2; i++)
            {
                outProps.YEIRequested[i - 1] = new string[2]; 
                outProps.YEIAllowed[i - 1] = new string[2];

                for (int i2 = 1; i2 <= 2; i2++)
                {
                    outProps.YEIRequested[i - 1] [i2 - 1] = apiCINB.getYEIRequested(i, i2);
                    outProps.YEIAllowed[i - 1] [i2 - 1] = apiCINB.getYEIAllowed(i, i2);
                }
            }

            return outProps ;


        }


    }
}

