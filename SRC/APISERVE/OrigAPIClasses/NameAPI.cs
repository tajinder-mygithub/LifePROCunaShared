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
*  20151221-010-01   SAP   06/28/16    Added Foreign Tax ID
*  20161201-003-01   ABH   01/02/17    Added field Personal and Business Emails
*   
*/


using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Name API object, which allows inquiry and updates of the PNAME and related tables.  
	/// </summary>
	public class NameAPI : INameAPI  
	{
		ONAMEAPI apiName ; 
		public static OAPPLICA apiApp ; 
		
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiName = new ONAMEAPI(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiName.getReturnCode() ; 
			outProps.ErrorMessage = apiName.getErrorMessage() ;
            return outProps;  


		}
		public void Dispose() 
		{
			apiName.Dispose(); 
			apiName = null ; 
		}

		public NameResponse RunNameFunction (NameRequest inProps ) 
		{
			apiName.setNameID(inProps.NameID); 
			apiName.setUpdateQueryFlag(inProps.UpdateQueryFlag);  

			apiName.setUpdateIndividualPrefix(inProps.UpdateIndividualPrefix);
			apiName.setUpdateIndividualFirstName(inProps.UpdateIndividualFirstName);
			apiName.setUpdateIndividualMiddleName(inProps.UpdateIndividualMiddleName);
			apiName.setUpdateIndividualLastName(inProps.UpdateIndividualLastName);
			apiName.setUpdateIndividualSuffix(inProps.UpdateIndividualSuffix);
			apiName.setUpdateIndividualSSN(inProps.UpdateIndividualSSN);
			apiName.setUpdateBusinessPrefix(inProps.UpdateBusinessPrefix);
			apiName.setUpdateBusinessName(inProps.UpdateBusinessName);
			apiName.setUpdateBusinessSuffix(inProps.UpdateBusinessSuffix);
			apiName.setUpdateBusinessTaxID(inProps.UpdateBusinessTaxID);
			apiName.setUpdateNameDateOfBirth(inProps.UpdateNameDateOfBirth);
			apiName.setUpdateNameGender(inProps.UpdateNameGender);
            apiName.setUpdateForeignTaxID(inProps.UpdateForeignTaxID);
            //20161201-003-01
            apiName.setUpdatePersonalEmail(inProps.UpdatePersonalEmail);
            apiName.setUpdateBusinessEmail(inProps.UpdateBusinessEmail);
            //20161201-003-01

			apiName.RunNameFunction(); 

			NameResponse outProps = new NameResponse() ; 
			outProps.ReturnCode = apiName.getReturnCode();  
			outProps.ErrorMessage = apiName.getErrorMessage().Trim();  

			outProps.NameType = apiName.getNameType().Trim(); 
			outProps.IndividualPrefix = apiName.getIndividualPrefix().Trim(); 
			outProps.IndividualFirstName = apiName.getIndividualFirstName().Trim(); 
			outProps.IndividualMiddleName = apiName.getIndividualMiddleName().Trim(); 
			outProps.IndividualLastName = apiName.getIndividualLastName().Trim(); 
			outProps.IndividualSuffix = apiName.getIndividualSuffix().Trim(); 
			outProps.IndividualReverse = apiName.getIndividualReverse().Trim(); 
			outProps.IndividualSSN = apiName.getIndividualSSN(); 
			outProps.BusinessPrefix = apiName.getBusinessPrefix().Trim(); 
			outProps.BusinessName = apiName.getBusinessName().Trim();
			outProps.BusinessSuffix = apiName.getBusinessSuffix().Trim(); 
			outProps.BusinessTaxID = apiName.getBusinessTaxID().Trim(); 
			outProps.FormatName = apiName.getFormatName().Trim(); 
			outProps.NameDateOfBirth = apiName.getNameDateOfBirth(); 
			outProps.NameGender = apiName.getNameGender().Trim(); 
			outProps.TaxStatus = apiName.getTaxStatus().Trim(); 
			outProps.DeceasedFlag = apiName.getDeceasedFlag().Trim(); 
			outProps.DateOfDeath = apiName.getDateOfDeath(); 
			outProps.TaxWithholdingFlag = apiName.getTaxWithholdingFlag().Trim(); 
			outProps.TaxCertificationCode = apiName.getTaxCertificationCode().Trim(); 
			outProps.TaxCertificationDate = apiName.getTaxCertificationDate();
            outProps.ForeignTaxID = apiName.getForeignTaxID().Trim();
            //20161201-003-01
            outProps.PersonalEmail = apiName.getPersonalEmail().Trim();
            outProps.BusinessEmail = apiName.getBusinessEmail().Trim();
            //20161201-003-01
			
			return outProps ; 
		
		}
	
	
	}
}
