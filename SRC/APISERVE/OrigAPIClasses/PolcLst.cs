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
using System.Threading ; 
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// The Policy List LifePRO API.  for a given Name ID and set of "included" relationship indicators, returns all policies that match given criteria. 
	/// </summary>

	public class PolcLst :  IPolcLst 
	{
		OPOLCLST apiPolicy ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiPolicy = new OPOLCLST(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiPolicy.getReturnCode() ; 
			outProps.ErrorMessage = apiPolicy.getErrorMessage() ;
            return outProps;   

		}
		public void Dispose() 
		{
			apiPolicy.Dispose(); 
			apiPolicy = null ; 
		}

		public void ClearRelationships()
		{
			apiPolicy.ClearRelationships(); 	
		}

		public PolicyListResponse GetPolcList (PolicyListRequest inProps ) 
		{

			apiPolicy.setCurrentNameID(inProps.CurrentNameID);
			apiPolicy.setIncAccountant(inProps.IncAccountant);
			apiPolicy.setIncAffiliate(inProps.IncAffiliate);
			apiPolicy.setIncAssignee(inProps.IncAssignee);
			apiPolicy.setIncAttorney(inProps.IncAttorney);
			apiPolicy.setIncBeneficiary1(inProps.IncBeneficiary1);
			apiPolicy.setIncBeneficiary2(inProps.IncBeneficiary2);
			apiPolicy.setIncCorporation(inProps.IncCorporation);
			apiPolicy.setIncPACBank(inProps.IncPACBank);
			apiPolicy.setIncGroup(inProps.IncGroup);
			apiPolicy.setIncGuardian(inProps.IncGuardian);
			apiPolicy.setIncInsured(inProps.IncInsured);
			apiPolicy.setIncJointEqual(inProps.IncJointEqual);
			apiPolicy.setIncJointInsured(inProps.IncJointInsured);
			apiPolicy.setIncMiscellaneous(inProps.IncMiscellaneous);
			apiPolicy.setIncAdditionalOwner(inProps.IncAdditionalOwner);
			apiPolicy.setIncAdditionalPayor(inProps.IncAdditionalPayor);
			apiPolicy.setIncPayor(inProps.IncPayor);
			apiPolicy.setIncPayee(inProps.IncPayee);
			apiPolicy.setIncPolicyOwner(inProps.IncPolicyOwner);
			apiPolicy.setIncPartner(inProps.IncPartner);
			apiPolicy.setIncPowerOfAttorney(inProps.IncPowerOfAttorney);
			apiPolicy.setIncServicingAgent(inProps.IncServicingAgent);
			apiPolicy.setIncTrustee(inProps.IncTrustee);
			apiPolicy.setIncTemporaryOwner(inProps.IncTemporaryOwner);
			apiPolicy.setIncWritingAgent(inProps.IncWritingAgent);
			apiPolicy.setIncMultInsured(inProps.IncMultInsured);
			apiPolicy.setIncGroupInsured(inProps.IncGroupInsured);
			apiPolicy.setIncAuthorizedInfo(inProps.IncAuthorizedInfo);
			apiPolicy.setIncLegalInterest(inProps.IncLegalInterest);
			apiPolicy.setIncSubowner(inProps.IncSubowner);
			apiPolicy.setIncCustodian(inProps.IncCustodian);
			apiPolicy.setIncGroupEmployer(inProps.IncGroupEmployer);
			apiPolicy.setIncAnnuitant1(inProps.IncAnnuitant1);
			apiPolicy.setIncAnnuitant2(inProps.IncAnnuitant2);
			apiPolicy.setIncReplInsurer(inProps.IncReplInsurer);
			apiPolicy.setIncDependInsured(inProps.IncDependInsured);
			apiPolicy.setIncMasterPolicy(inProps.IncMasterPolicy);
			apiPolicy.setIncContact1(inProps.IncContact1);
			apiPolicy.setIncContact2Addl(inProps.IncContact2Addl);
			apiPolicy.setIncContact3Addl(inProps.IncContact3Addl);
			apiPolicy.setIncContact4Addl(inProps.IncContact4Addl);

			apiPolicy.GetPolcList(); 

			PolicyListResponse outProps = new PolicyListResponse() ; 
			outProps.ReturnCode = apiPolicy.getReturnCode();  
			outProps.ErrorMessage = apiPolicy.getErrorMessage();  

			outProps.NumberOfRecordsFound = apiPolicy.getNumberOfRecordsFound();
			int count = outProps.NumberOfRecordsFound ; 
			outProps.CompanyCodeFromList = new string[count];  
			outProps.PolicyNumberFromList = new string[count]; 
			outProps.RelateCodeFromList = new string[count]; 
			outProps.LOBFromList = new string[count]; 
			outProps.StatusFromList = new string[count]; 
			outProps.ProductIDFromList = new string[count];
			outProps.ProductDescFromList = new string[count];
			outProps.FaceAmountFromList = new double[count];  
			outProps.NumberOfUnitsFromList = new double[count];  
			outProps.InsuredIDFromList = new int[count]; 
			outProps.OwnerIDFromList = new int[count];  

			for (int i=1;i<=count;i++) 
			{
				outProps.CompanyCodeFromList[i-1] = apiPolicy.getCompanyCodeFromList(i); 
				outProps.PolicyNumberFromList[i-1] = apiPolicy.getPolicyNumberFromList(i); 
				outProps.RelateCodeFromList[i-1] = apiPolicy.getRelateCodeFromList(i); 
				outProps.LOBFromList[i-1] = apiPolicy.getLOBFromList(i); 
				outProps.StatusFromList[i-1] = apiPolicy.getStatusFromList(i); 
				outProps.ProductIDFromList[i-1] = apiPolicy.getProductIDFromList(i); 
				outProps.ProductDescFromList[i-1] = apiPolicy.getProductDescFromList(i); 
				outProps.FaceAmountFromList[i-1] = apiPolicy.getFaceAmountFromList(i); 
				outProps.NumberOfUnitsFromList[i-1] = apiPolicy.getNumberOfUnitsFromList(i); 
				outProps.InsuredIDFromList[i-1] = apiPolicy.getInsuredIDFromList(i); 
				outProps.OwnerIDFromList[i-1] = apiPolicy.getOwnerIDFromList(i); 
			}
		
			return outProps ; 
		}

	}
}
