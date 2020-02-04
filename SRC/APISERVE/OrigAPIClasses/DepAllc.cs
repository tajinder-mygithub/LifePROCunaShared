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
*  20121106-004-01   DAR   10/26/12    Add "Edit Only" method to bypass update but still perform 
*                                      all edits. 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20121115-004-02   DAR   06/26/15    Add Model Allocations 
*  20151130-001-01   GWT   02/25/16    Add Model/Sub-Model/Profile info  
*  20131010-019-01   DAR   08/29/16    Add terminated fund info and allow fund refresh only ignoring models. 
*  20131010-019-01   DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*/

using System;
using LPNETAPI ; 
using System.Runtime.Remoting.Lifetime;
using System.ServiceModel;
using System.ServiceModel.Description;

namespace PDMA.LifePro 
{
	/// <summary>
	/// Deposit Allocation LifePRO API, which allows the setting and returning of fund allocation information 
	/// </summary>

	public class DepAllc :  IDepAllc 
	{
		ODEPALLC apiAllocation ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
            Log.AddDetailedLogEntry("In TCP Deposit Allocation Init Call.  About to Init ODEPALLC");  
			UserType = userType ; 
			apiAllocation = new ODEPALLC(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiAllocation.getReturnCode() ; 
			outProps.ErrorMessage = apiAllocation.getErrorMessage() ;

            Log.AddDetailedLogEntry("In TCP Deposit Allocation Init Call.  About to exit with Return Code: " + outProps.ReturnCode.ToString());  

            return outProps;  

		}
		public void Dispose() 
		{
			apiAllocation.Dispose(); 
			apiAllocation = null ; 
		}


		public DepositAllocationResponse RetrieveAllocations (ref DepositAllocationRequest inProps ) 
		{
			// We use "ref" above since with .NET Remoting, ref is the only way to force
			// an object to copy back to the caller.  Without Remoting, the "ref" would not 
			// be necessary because it is normally an object reference that passes anyway.  
			// Here, we update certain input properties so we must send the inProps parameter
			// back to the client.  

            Log.AddDetailedLogEntry("Starting TCP Deposit Allocation RetrieveAllocations Call.  Call is for policy " + inProps.PolicyNumber);  

			// Only these inputs are necessary for RetrieveAllocations 
			apiAllocation.setCompanyCode(inProps.CompanyCode);
			apiAllocation.setPolicyNumber(inProps.PolicyNumber);
			apiAllocation.setEffectiveDate(inProps.EffectiveDate);
            apiAllocation.setShowFundsOnlyFlag(inProps.ShowFundsOnly ? "Y":"N");

            Log.AddDetailedLogEntry("TCP TCP Deposit Allocation RetrieveAllocations Call.  Just before ODEPALLC RetrieveAllocations for policy  " + inProps.PolicyNumber);  
			apiAllocation.RetrieveAllocations();
            Log.AddDetailedLogEntry("TCP TCP Deposit Allocation RetrieveAllocations Call.  Just after ODEPALLC RetrieveAllocations for policy  " + inProps.PolicyNumber);  


			DepositAllocationResponse outProps = new DepositAllocationResponse() ; 

			loadDepositAllocationResponse(inProps, outProps) ;  // Share with other routines that need the same output 

            Log.AddDetailedLogEntry("TCP Deposit Allocation RetrieveAllocations Call.  Returning from RetrieveAllocations now for policy  " + inProps.PolicyNumber);  

			return outProps ; 
		}

		public DepositAllocationResponse RefreshAvailability (ref DepositAllocationRequest inProps ) 
		{
			// Only these inputs are necessary for RefreshAvailability 
            Log.AddDetailedLogEntry("Starting TCP Deposit Allocation RefreshAvailability Call.  Call is for policy " + inProps.PolicyNumber);  

            apiAllocation.setCompanyCode(inProps.CompanyCode);
			apiAllocation.setPolicyNumber(inProps.PolicyNumber);
			apiAllocation.setEffectiveDate(inProps.EffectiveDate);
            apiAllocation.setShowFundsOnlyFlag(inProps.ShowFundsOnly ? "Y" : "N");

            Log.AddDetailedLogEntry("TCP TCP Deposit Allocation RefreshAvailability Call.  Just before ODEPALLC RefreshAvailability for policy  " + inProps.PolicyNumber);  
            apiAllocation.RefreshAvailability();
            Log.AddDetailedLogEntry("TCP TCP Deposit Allocation RefreshAvailability Call.  Just after ODEPALLC RefreshAvailability for policy  " + inProps.PolicyNumber);  

			DepositAllocationResponse outProps = new DepositAllocationResponse() ; 

			loadDepositAllocationResponse(inProps, outProps) ;  // Share with other routines that need the same output 

            Log.AddDetailedLogEntry("TCP Deposit Allocation RefreshAvailability Call.  Returning from RefreshAvailability now for policy  " + inProps.PolicyNumber);  
			return outProps ; 
		}

        public BaseResponse PerformEditsOnly(DepositAllocationRequest inProps)
        {
            apiAllocation.setEditOnlyFlag("Y");
            BaseResponse errorInfo = PerformProcessing(inProps);
            return errorInfo; 
        }
		public BaseResponse UpdateAllocations (DepositAllocationRequest inProps ) 
		{
            apiAllocation.setEditOnlyFlag("N");
            BaseResponse errorInfo = PerformProcessing(inProps);
            return errorInfo; 

		}

        private BaseResponse PerformProcessing(DepositAllocationRequest inProps)
        {

            Log.AddDetailedLogEntry("Starting TCP Deposit Allocation PerformProcessing (for Edits or Update)  Call.  Call is for policy " + inProps.PolicyNumber);  

            apiAllocation.setCompanyCode(inProps.CompanyCode);
			apiAllocation.setPolicyNumber(inProps.PolicyNumber);
			apiAllocation.setEffectiveDate(inProps.EffectiveDate);

            // ShowFundsOnly input does not matter for this call.  

			for (int i=0;i<inProps.DepositAllocation.Length;i++) 
				apiAllocation.setDepositAllocation(i+1, inProps.DepositAllocation[i]); 

            // UpdateAllocations, within ODEPALLC.COB, will only perform edits 
            // if EditOnly flag is "Y".  Otherwise performs all udpates.  

            Log.AddDetailedLogEntry("TCP Deposit Allocation Edits/UpdateAllocations Call.  Just before ODEPALLC UpdateAllocations for policy  " + inProps.PolicyNumber);  
			apiAllocation.UpdateAllocations();
            Log.AddDetailedLogEntry("TCP Deposit Allocation Edits/UpdateAllocations Call.  Just after ODEPALLC UpdateAllocations for policy  " + inProps.PolicyNumber);  

			
			// In this case, we only need to return error code and message info.  
			// All other information is not refreshed, so we simply return an BaseResponse instance. 

			BaseResponse errorInfo = new BaseResponse(); 
			errorInfo.ReturnCode = apiAllocation.getReturnCode(); 
			errorInfo.ErrorMessage = apiAllocation.getErrorMessage();

            Log.AddDetailedLogEntry("TCP Deposit Allocation PerformProcessing (for Edits or Update) Call.  Returning from PerformProcessing now for policy  " + inProps.PolicyNumber);  


			return errorInfo ; 
		}

		private void loadDepositAllocationResponse(DepositAllocationRequest inProps, DepositAllocationResponse outProps) 
		{
			outProps.ReturnCode = apiAllocation.getReturnCode();  
			outProps.ErrorMessage = apiAllocation.getErrorMessage();  


            outProps.AssetAllocationModelFlag = apiAllocation.getAssetAllocationModelFlag().Trim();
            outProps.AssetAllocationModelStatus = apiAllocation.getAssetAllocationModelStatus().Trim();  
            outProps.ModelAllocEffectiveDate = apiAllocation.getAllocEffectiveDate();
            outProps.ProfileID = apiAllocation.getProfileID().Trim();
            outProps.ProfileDescription = apiAllocation.getProfileDescription().Trim();  

            int modelCount = apiAllocation.getModelCount();
            outProps.ModelName = new string[modelCount];
            outProps.ModelVersion = new int[modelCount];
            outProps.ModelDescription = new string[modelCount];
            outProps.ModelAvailableRank = new short[modelCount];
            outProps.ModelMinPercent = new double[modelCount];
            outProps.ModelMaxPercent = new double[modelCount];
            outProps.ModelSelectionPercent = new double[modelCount];
            outProps.ModelMappingIndicator = new short[modelCount];

            for (int i = 1; i <= modelCount; i++)
            {
                outProps.ModelName[i - 1] = apiAllocation.getModelName(i).Trim();
                outProps.ModelVersion[i - 1] = apiAllocation.getModelVersion(i);
                outProps.ModelDescription[i - 1] = apiAllocation.getModelDescription(i);
                outProps.ModelAvailableRank[i - 1] = apiAllocation.getModelAvailableRank(i);
                outProps.ModelMinPercent[i - 1] = apiAllocation.getModelMinPercent(i);
                outProps.ModelMaxPercent[i - 1] = apiAllocation.getModelMaxPercent(i);
                outProps.ModelSelectionPercent[i - 1] = apiAllocation.getModelSelectionPercent(i);  
                outProps.ModelMappingIndicator[i - 1] = apiAllocation.getModelMappingIndicator(i);
            }

            int subModelCount = apiAllocation.getSubModelCount();

            outProps.SubModelModelTableIndex = new int[subModelCount];
            outProps.SubModelModelName = new string[subModelCount];
            outProps.SubModelModelVersion = new int[subModelCount];
            outProps.SubModelName = new string[subModelCount];
            outProps.SubModelDescription = new string[subModelCount];
            outProps.SubModelPercentFlag = new string[subModelCount];
            outProps.SubModelConstantPercent = new double[subModelCount];
            outProps.SubModelMinPercent = new double[subModelCount];
            outProps.SubModelMaxPercent = new double[subModelCount];
            outProps.SubModelSelectionPercent = new double[subModelCount]; 
            outProps.SubModelMappingIndicator = new short[subModelCount];

            for (int i = 1; i <= subModelCount; i++)
            {
                outProps.SubModelModelTableIndex[i - 1] = apiAllocation.getSubModelModelTableIndex(i);
                outProps.SubModelModelName[i - 1] = apiAllocation.getSubModelModelName(i).Trim();
                outProps.SubModelModelVersion[i - 1] = apiAllocation.getSubModelModelVersion(i);
                outProps.SubModelName[i - 1] = apiAllocation.getSubModelName(i);
                outProps.SubModelDescription[i - 1] = apiAllocation.getSubModelDescription(i);
                outProps.SubModelPercentFlag[i - 1] = apiAllocation.getSubModelPercentFlag(i);
                outProps.SubModelConstantPercent[i - 1] = apiAllocation.getSubModelConstantPercent(i);
                outProps.SubModelMinPercent[i - 1] = apiAllocation.getSubModelMinPercent(i);
                outProps.SubModelMaxPercent[i - 1] = apiAllocation.getSubModelMaxPercent(i);   
                outProps.SubModelSelectionPercent[i - 1] = apiAllocation.getSubModelSelectionPercent(i);  
                outProps.SubModelMappingIndicator[i - 1] = apiAllocation.getSubModelMappingIndicator(i);
            }

            int categoryCount = apiAllocation.getCategoryCount();

            outProps.CategoryModelTableIndex = new int[categoryCount];
            outProps.CategoryModelName = new string[categoryCount];
            outProps.CategoryModelVersion = new int[categoryCount];
            outProps.CategoryName = new string[categoryCount];
            outProps.CategoryPercentFlag = new string[categoryCount];
            outProps.CategoryConstantPercent = new double[categoryCount];
            outProps.CategoryMinPercent = new double[categoryCount];
            outProps.CategoryMaxPercent = new double[categoryCount]; 

            for (int i = 1; i <= categoryCount; i++)
            {
                outProps.CategoryModelTableIndex[i - 1] = apiAllocation.getCategoryModelTableIndex(i);
                outProps.CategoryModelName[i - 1] = apiAllocation.getCategoryModelName(i).Trim();
                outProps.CategoryModelVersion[i - 1] = apiAllocation.getCategoryModelVersion(i);
                outProps.CategoryName[i - 1] = apiAllocation.getCategoryName(i);
                outProps.CategoryPercentFlag[i - 1] = apiAllocation.getCategoryPercentFlag(i);
                outProps.CategoryConstantPercent[i - 1] = apiAllocation.getCategoryConstantPercent(i);
                outProps.CategoryMinPercent[i - 1] = apiAllocation.getCategoryMinPercent(i);
                outProps.CategoryMaxPercent[i - 1] = apiAllocation.getCategoryMaxPercent(i);   
            }


			int count = apiAllocation.getRowCount(); 
            
            outProps.FundModelTableIndex = new int[count];
            outProps.FundCategoryTableIndex = new int[count];   
            outProps.FundModelName = new string[count]; 
            outProps.FundModelVersion = new int[count]; 
            outProps.InvestedInThisModel = new bool[count];   
    		outProps.FundID = new string[count]; 
			outProps.FundAvailable = new string[count]; 
            outProps.FundApprovalIndicator = new string[count];
            outProps.TerminatedAlternateFundID = new string[count]; 
			outProps.ShortDescription = new string[count];  
			outProps.LongDescription = new string[count]; 
			outProps.FundType = new string[count];
            outProps.CusipNumber = new string[count];
            outProps.FundModelPercentFlag = new string[count];
            outProps.FundModelConstantPercent = new double[count];
            outProps.FundModelMinPercent = new double[count];
            outProps.FundModelMaxPercent = new double[count];  
            outProps.FundSubModelTableIndex = new int[count];
            outProps.FundSubModelName = new string[count]; 
            outProps.FundSubModelDescription = new string[count];
            outProps.FundModelAllocation = new double[count];
            outProps.FundSubModelAllocation = new double[count];
           
			outProps.RowCount = count ;  
		
			inProps.EffectiveDate = apiAllocation.getEffectiveDate(); 
			inProps.DepositAllocation = new double[count];  

			for (int i=1;i<=count;i++) 
			{
                outProps.FundModelTableIndex[i - 1] = apiAllocation.getFundModelTableIndex(i);
                outProps.FundCategoryTableIndex[i - 1] = apiAllocation.getFundCategoryTableIndex(i);   
                outProps.FundModelName[i - 1] = apiAllocation.getFundModelName(i).Trim();
                outProps.FundModelVersion[i - 1] = apiAllocation.getFundModelVersion(i);
                outProps.InvestedInThisModel[i - 1] = (apiAllocation.getInvestedInThisModel(i) == "Y") ? true : false; 
				outProps.FundID[i-1] = apiAllocation.getFundID(i).Trim();  
				outProps.FundAvailable[i-1] = apiAllocation.getFundAvailable(i).Trim();  
                outProps.FundApprovalIndicator[i - 1] = apiAllocation.getFundApprovalIndicator(i).Trim();
                outProps.TerminatedAlternateFundID[i - 1] = apiAllocation.getTerminatedAlternateFundID(i).Trim(); 
				outProps.ShortDescription[i-1] = apiAllocation.getShortDescription(i).Trim();  
				outProps.LongDescription[i-1] = apiAllocation.getLongDescription(i).Trim();  
				outProps.FundType[i-1] = apiAllocation.getFundType(i).Trim();
                outProps.CusipNumber[i - 1] = apiAllocation.getCusipNumber(i).Trim();
                outProps.FundModelPercentFlag[i - 1] = apiAllocation.getFundModelPercentFlag(i).Trim();
                outProps.FundModelConstantPercent[i - 1] = apiAllocation.getFundModelConstantPercent(i);
                outProps.FundModelMinPercent[i - 1] = apiAllocation.getFundModelMinPercent(i);
                outProps.FundModelMaxPercent[i - 1] = apiAllocation.getFundModelMaxPercent(i);   
				inProps.DepositAllocation[i-1] = apiAllocation.getDepositAllocation(i); 
				outProps.FundSubModelTableIndex[i - 1] = apiAllocation.getFundSubModelTableIndex(i);
				outProps.FundSubModelName[i - 1] = apiAllocation.getFundSubModelName(i).Trim();
				outProps.FundSubModelDescription[i - 1] = apiAllocation.getFundSubModelDescription(i).Trim();
				outProps.FundModelAllocation[i - 1] = apiAllocation.getFundModelAllocation(i);
				outProps.FundSubModelAllocation[i - 1] = apiAllocation.getFundSubModelAllocation(i);

			}
		}


	}
}
