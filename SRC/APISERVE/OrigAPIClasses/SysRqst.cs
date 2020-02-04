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
*  20130104-002-01   DAR   01/07/13    Enhancements to Transfers 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20141010-004-01   DAR   02/17/15    Add retrieval of Transfer Count/Limit
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for SysRqst.
	/// </summary>

	public class SysRqst : ISysRqst  
	{
		OSYSRQST apiSystematic ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiSystematic = new OSYSRQST(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiSystematic.getReturnCode() ; 
			outProps.ErrorMessage = apiSystematic.getErrorMessage() ;
            return outProps;   
		}

		public void Dispose() 
		{
			apiSystematic.Dispose(); 
			apiSystematic = null ; 
		}


		// This is identical to RunInquiry of BalInqu, and we use the same input/output
		// classes, etc.  
		public BalanceInquiryResponse RunInquiry (BalanceInquiryRequest inProps ) 
		{
			apiSystematic.setCompanyCode(inProps.CompanyCode);
			apiSystematic.setPolicyNumber(inProps.PolicyNumber);
			apiSystematic.setEffectiveDate(inProps.EffectiveDate);

			apiSystematic.RunInquiry(); 

			BalanceInquiryResponse outProps = new BalanceInquiryResponse() ; 
			outProps.ReturnCode = apiSystematic.getReturnCode();  
			outProps.ErrorMessage = apiSystematic.getErrorMessage();  

			outProps.ActiveRequests = apiSystematic.getActiveRequests().Trim();
			outProps.MultipleLoans = apiSystematic.getMultipleLoans().Trim();
			outProps.QuoteDate = apiSystematic.getQuoteDate();
			outProps.ProcessToDate = apiSystematic.getProcessToDate();
			outProps.LastValuationDate = apiSystematic.getLastValuationDate();
			outProps.GrossDeposits = apiSystematic.getGrossDeposits();
			outProps.GrossWithdrawals = apiSystematic.getGrossWithdrawals();
			outProps.LoanBalance = apiSystematic.getLoanBalance();
			outProps.TotalFundBalance = apiSystematic.getTotalFundBalance();
			outProps.RowCount = apiSystematic.getRowCount();

			int count = outProps.RowCount ; 
			//outProps.MoneySource = new string[count];  -- not applicable for systematic
			outProps.FundID = new string[count]; 
			outProps.ShortDescription = new string[count];  
			outProps.LongDescription = new string[count]; 
			outProps.FundType = new string[count];  
			outProps.Units = new double[count];  
			outProps.UnitValue = new double[count]; 
			//outProps.UnitValueDate = new int[count];  -- not applicable for systematic
			outProps.FundBalance = new double[count];  

			for (int i=1;i<=count;i++) 
			{
				outProps.FundID[i-1] = apiSystematic.getFundID(i).Trim();  
				outProps.ShortDescription[i-1] = apiSystematic.getShortDescription(i).Trim();  
				outProps.LongDescription[i-1] = apiSystematic.getLongDescription(i).Trim();  
				outProps.FundType[i-1] = apiSystematic.getFundType(i).Trim();  
				outProps.Units[i-1] = apiSystematic.getUnits(i);  
				outProps.UnitValue[i-1] = apiSystematic.getUnitValue(i);  
				outProps.FundBalance[i-1] = apiSystematic.getFundBalance(i);  
			}
		
			return outProps ; 
		}


        public BaseResponse PerformEditsOnly(SystematicRequest inProps)
        {
            apiSystematic.setEditOnlyFlag("Y");
            apiSystematic.setSystematicFunction("A"); 
            SystematicResponse tempOut = PerformProcessing(inProps);

            BaseResponse outBase = new BaseResponse();
            outBase.ReturnCode = tempOut.ReturnCode;
            outBase.ErrorMessage = tempOut.ErrorMessage;
            return outBase;   

        }
        
		public SystematicResponse SaveSystematic (SystematicRequest inProps ) 
		{

            apiSystematic.setEditOnlyFlag("N");
            apiSystematic.setSystematicFunction("A"); 
            return PerformProcessing(inProps); 

		}


        public BaseResponse CancelSystematic(SystematicRequest inProps) 
        {

            apiSystematic.setSystematicFunction("C");
            SystematicResponse tempOut = PerformProcessing(inProps,true);

            BaseResponse outBase = new BaseResponse();
            outBase.ReturnCode = tempOut.ReturnCode;
            outBase.ErrorMessage = tempOut.ErrorMessage;
            return outBase;   



        }

        public SystematicResponse GetTransferCount (SystematicRequest inProps)
        {

            apiSystematic.setSystematicFunction("T");
            return  PerformProcessing(inProps, true);

        }



        private SystematicResponse PerformProcessing(SystematicRequest inProps, bool skipNonCancelItems = false)
        {

			apiSystematic.setSystematicType(inProps.SystematicType);
            apiSystematic.setDateAdded(inProps.DateAdded);   
            apiSystematic.setTimeAdded(inProps.TimeAdded);  
			apiSystematic.setCompanyCode(inProps.CompanyCode);
			apiSystematic.setPolicyNumber(inProps.PolicyNumber);
			apiSystematic.setEffectiveDate(inProps.EffectiveDate);

            if (!skipNonCancelItems)
            {
                apiSystematic.setProcessingFee(inProps.ProcessingFee);
                apiSystematic.setWithdrawalAmount(inProps.WithdrawalAmount);
                apiSystematic.setLoanAmount(inProps.LoanAmount);
                apiSystematic.setDistributionCode(inProps.DistributionCode);
                apiSystematic.setLoanTerm(inProps.LoanTerm);
                apiSystematic.setRepaymentMode(inProps.RepaymentMode);
                apiSystematic.setLoanPurpose(inProps.LoanPurpose);

                apiSystematic.setTransferInType(inProps.TransferInType);
                
                // Web service calls may not initialize input arrays.  Skip if errors occur.  
                try 
                {
                  for (int i = 0; i < inProps.TransferOutPercent.Length; i++)
                      apiSystematic.setTransferOutPercent(i + 1, inProps.TransferOutPercent[i]);
                }
                catch {}  
                
                try 
                {
                for (int i = 0; i < inProps.TransferOutAmount.Length; i++)
                    apiSystematic.setTransferOutAmount(i + 1, inProps.TransferOutAmount[i]);
                }
                catch {}  
                
                
                try 
                {  
                for (int i = 0; i < inProps.TransferIn.Length; i++)
                    apiSystematic.setTransferIn(i + 1, inProps.TransferIn[i]);
                }
                catch {}  
                
            }


			apiSystematic.SaveSystematic();  

			SystematicResponse outProps = new SystematicResponse();  

			outProps.ReturnCode = apiSystematic.getReturnCode();
			outProps.ErrorMessage = apiSystematic.getErrorMessage().Trim();
            outProps.TransferCount = apiSystematic.getTransferCount();
            outProps.TransferLimit = apiSystematic.getTransferLimit(); 
			outProps.ConfirmationNumber = apiSystematic.getConfirmationNumber().Trim();
			
			return outProps ; 

		}	

	
	}
}
