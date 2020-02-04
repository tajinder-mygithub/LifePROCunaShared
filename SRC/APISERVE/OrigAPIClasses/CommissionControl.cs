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
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20141010-004-01   DAR   08/04/16    Add state license addition support   
*/


using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for CommissionControl.
	/// </summary>

	public class CommissionControl :  ICommissionControl  
	{
		OCOMCTRL apiComm ; 

		public static OAPPLICA apiApp ; 
		public string UserType ;

    private int agentMax = 10;  // There can be no more than 10 agents per split record.  


		public BaseResponse Init (string userType) 
		{
			UserType = userType ; 
			apiComm = new OCOMCTRL(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiComm.getReturnCode() ; 
			outProps.ErrorMessage = apiComm.getErrorMessage() ;
            return outProps; 

		}

		public void Dispose() 
		{
			apiComm.Dispose(); 
			apiComm = null ; 
		}

		public CommissionControlResponse RetrieveCommissionSplits (CommissionControlRequest inProps ) 
		{

			apiComm.setCompanyCode(inProps.CompanyCode); 
			apiComm.setPolicyNumber(inProps.PolicyNumber);
            apiComm.setSplitControl(inProps.SplitControl);
            apiComm.setIssueDate(inProps.IssueDate);
            apiComm.setEffectiveDate(inProps.EffectiveDate);
            apiComm.RetrieveCommissionSplits(); 

			CommissionControlResponse outProps = new CommissionControlResponse() ; 
			outProps.ReturnCode = apiComm.getReturnCode();  
			outProps.ErrorMessage = apiComm.getErrorMessage();


            if (outProps.ReturnCode == 0)
            {

                int count = apiComm.getOutLastSplitEntry();  
                outProps.SplitControl = new short[count];
                outProps.IssueDate = new int[count];
                outProps.EffectiveDate = new int[count];
                outProps.EndDate = new int[count];
                outProps.RateOverrideFlag = new string[count];
                outProps.ReferralFlag = new string[count];
                outProps.ProdCrFlag = new string[count];
                outProps.AttainedAge = new short[count];
                outProps.PremiumIncrease = new string[count];
                outProps.OverrideFlag = new string[count];   
                outProps.CoderId = new string[count]; 

                outProps.AgentNumber = new string[count][]; 
                outProps.CommissionPercent = new double[count][]; 
                outProps.ProductionPercent = new double[count][]; 
                outProps.ServiceAgentIndicator = new string[count][]; 
                outProps.MarketCode = new string[count][]; 
                outProps.AgentLevel = new string[count][];

                for (int i = 0; i < outProps.SplitControl.Length;i++)
                {

                    outProps.SplitControl[i] = apiComm.getOutSplitControl(i + 1);
                    outProps.IssueDate[i] = apiComm.getOutIssueDate(i + 1);
                    outProps.EffectiveDate[i] = apiComm.getOutEffectiveDate(i + 1);
                    outProps.EndDate[i] = apiComm.getOutEndDate(i + 1);
                    outProps.RateOverrideFlag[i] = apiComm.getOutRateOverrideFlag(i + 1);
                    outProps.ReferralFlag[i] = apiComm.getOutReferralFlag(i + 1);
                    outProps.ProdCrFlag[i] = apiComm.getOutProdCrFlag(i + 1);
                    outProps.AttainedAge[i] = apiComm.getOutAttainedAge(i + 1);
                    outProps.PremiumIncrease[i] = apiComm.getOutPremiumIncrease(i + 1);
                    outProps.OverrideFlag[i] = apiComm.getOutOverrideFlag(i + 1); 
                    outProps.CoderId[i] = apiComm.getOutCoderId(i + 1);

                    outProps.AgentNumber[i] = new string[agentMax]; 
                    outProps.CommissionPercent[i]= new double[agentMax]; 
                    outProps.ProductionPercent[i]= new double[agentMax]; 
                    outProps.ServiceAgentIndicator[i] = new string[agentMax]; 
                    outProps.MarketCode[i] = new string[agentMax]; 
                    outProps.AgentLevel[i] = new string[agentMax];


                    for (int x = 0; x < agentMax; x++)
                    {
                        outProps.AgentNumber[i][x] = apiComm.getOutAgent(i + 1, x + 1);
                        outProps.CommissionPercent[i][x] = apiComm.getOutCommPcnt(i + 1, x + 1);
                        outProps.ProductionPercent[i][x] = apiComm.getOutProdPcnt(i + 1, x + 1);
                        outProps.ServiceAgentIndicator[i][x] = apiComm.getOutServiceAgentInd(i + 1, x + 1);
                        outProps.MarketCode[i][x] = apiComm.getOutMarketCode(i + 1, x + 1);
                        outProps.AgentLevel[i][x] = apiComm.getOutAgentLevel(i + 1, x + 1);

                    }

                }
            }

			
			return outProps ; 
		}


        public BaseResponse AddNewCommissionSplit(CommissionControlRequest inProps)
        {

            apiComm.setCompanyCode(inProps.CompanyCode);
            apiComm.setPolicyNumber(inProps.PolicyNumber);
            apiComm.setSplitControl(inProps.SplitControl);
            apiComm.setIssueDate(inProps.IssueDate);
            apiComm.setEffectiveDate(inProps.EffectiveDate);
            apiComm.setUpdateRelationshipsFlag( inProps.UpdateRelationships  ? "Y" : "N");
            apiComm.setAddStateLicense(inProps.AddStateLicense ? "Y" : "N");  

            apiComm.setAddRateOverrideFlag(inProps.RateOverrideFlag);
            apiComm.setAddReferralFlag(inProps.ReferralFlag);
            apiComm.setAddProdCrFlag(inProps.ProdCrFlag);
            apiComm.setAddAttainedAge(inProps.AttainedAge);
            apiComm.setAddPremiumIncrease(inProps.PremiumIncrease);
            apiComm.setAddOverrideFlag(inProps.OverrideFlag); 

            // Override errors that could occur since web servie calls do not require initialization
            // of arrays.  
            try 
            {
                for (int i = 0; i < inProps.AgentNumber.Length; i++)
                    apiComm.setAddAgent(i + 1, inProps.AgentNumber[i]);
            } 
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.CommissionPercent.Length; i++)
                    apiComm.setAddCommPcnt(i + 1, inProps.CommissionPercent[i]);
            }
            catch {}  
            
            
            try 
            {
                for (int i = 0; i < inProps.ProductionPercent.Length; i++)
                    apiComm.setAddProdPcnt(i + 1, inProps.ProductionPercent[i]);
            }
            catch {}  
               
            try 
            {
                for (int i = 0; i < inProps.ServiceAgentIndicator.Length; i++)
                    apiComm.setAddServiceAgentInd(i + 1, inProps.ServiceAgentIndicator[i]);
            }
            catch {}  

            try 
            {
                for (int i = 0; i < inProps.MarketCode.Length; i++)
                    apiComm.setAddMarketCode(i + 1, inProps.MarketCode[i]);
            }
            catch {}  
               

            try 
            {
                for (int i = 0; i < inProps.AgentLevel.Length; i++)
                    apiComm.setAddAgentLevel(i + 1, inProps.AgentLevel[i]);   
            }
            catch {}

            try
            {
                for (int i = 0; i < inProps.LicenseState.Length; i++)
                    apiComm.setLicenseState(i + 1, inProps.LicenseState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseStatus.Length; i++)
                    apiComm.setLicenseStatus(i + 1, inProps.LicenseStatus[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseReasonCode.Length; i++)
                    apiComm.setLicenseReasonCode(i + 1, inProps.LicenseReasonCode[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseGrantedDate.Length; i++)
                    apiComm.setLicenseGrantedDate(i + 1, inProps.LicenseGrantedDate[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseExpiresDate.Length; i++)
                    apiComm.setLicenseExpiresDate(i + 1, inProps.LicenseExpiresDate[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseResidentCode.Length; i++)
                    apiComm.setLicenseResidentCode(i + 1, inProps.LicenseResidentCode[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseNASD.Length; i++)
                    apiComm.setLicenseNASD(i + 1, inProps.LicenseNASD[i]);
            }
            catch { }  
            
            try
            {
                for (int i = 0; i < inProps.LicenseLife.Length; i++)
                    apiComm.setLicenseLife(i + 1, inProps.LicenseLife[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseHealth.Length; i++)
                    apiComm.setLicenseHealth(i + 1, inProps.LicenseHealth[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseAnnuity.Length; i++)
                    apiComm.setLicenseAnnuity(i + 1, inProps.LicenseAnnuity[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseBasicLTC.Length; i++)
                    apiComm.setLicenseBasicLTC(i + 1, inProps.LicenseBasicLTC[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseBasicLastRenewalDate.Length; i++)
                    apiComm.setLicenseBasicLastRenewal(i + 1, inProps.LicenseBasicLastRenewalDate[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseBasicNextRenewalDate.Length; i++)
                    apiComm.setLicenseBasicNextRenewal(i + 1, inProps.LicenseBasicNextRenewalDate[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseNumber.Length; i++)
                    apiComm.setLicenseNumber(i + 1, inProps.LicenseNumber[i]);
            }
            catch { }  

            try
            {
                for (int i = 0; i < inProps.LicenseType.Length; i++)
                    apiComm.setLicenseType(i + 1, inProps.LicenseType[i]);
            }
            catch { }  
            

            apiComm.AddNewCommissionSplit(); 

            BaseResponse outProps = new BaseResponse();

            outProps.ReturnCode = apiComm.getReturnCode();
            outProps.ErrorMessage = apiComm.getErrorMessage();   

            return outProps; 

        }

	}
}
