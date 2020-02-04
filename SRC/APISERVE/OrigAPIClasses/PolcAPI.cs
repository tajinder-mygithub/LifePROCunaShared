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
*  20150108-001-01   DAV   04/20/15    Add IBA flex modal and annual premiums.
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for PolcAPI.
	/// </summary>

	public class PolcAPI : IPolcAPI 
	{
		OPOLCAPI apiPolicy ; 

		public static OAPPLICA apiApp ; 

		public string UserType ; 

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiPolicy = new OPOLCAPI(apiApp, UserType);  

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

		public PolicyInquiryResponse GetPolcInfo (PolicyInquiryRequest inProps ) 
		{
			apiPolicy.setCompanyCode(inProps.CompanyCode); 
			apiPolicy.setPolicyNumber(inProps.PolicyNumber);  

			apiPolicy.GetPolcInfo() ; 
			PolicyInquiryResponse outProps = new PolicyInquiryResponse() ; 
			outProps.ReturnCode = apiPolicy.getReturnCode();  
			outProps.ErrorMessage = apiPolicy.getErrorMessage().Trim();  

			outProps.OwnerID = apiPolicy.getOwnerID();
			outProps.InsuredID = apiPolicy.getInsuredID();
			outProps.Annuitant1ID = apiPolicy.getAnnuitant1ID();
			outProps.Annuitant2ID = apiPolicy.getAnnuitant2ID();
			outProps.Annuitant3ID = apiPolicy.getAnnuitant3ID();
			outProps.ProductID = apiPolicy.getProductID().Trim();
			outProps.ProductDesc = apiPolicy.getProductDesc().Trim();
			outProps.IssueDate = apiPolicy.getIssueDate();
			outProps.FaceAmount = apiPolicy.getFaceAmount();
			outProps.NumberOfUnits = apiPolicy.getNumberOfUnits();
			outProps.Status = apiPolicy.getStatus().Trim();
			outProps.PaidToDate = apiPolicy.getPaidToDate();
			outProps.ModePremium = apiPolicy.getModePremium();
			outProps.BillingFrequency = apiPolicy.getBillingFrequency();
			outProps.BillingMethod = apiPolicy.getBillingMethod().Trim();
			outProps.ServiceAgentID = apiPolicy.getServiceAgentID();
            outProps.FlexModalPrem = apiPolicy.getFlexModalPrem();
            outProps.FlexAnnualPrem = apiPolicy.getFlexAnnualPrem();
			
			return outProps ; 
		}

	}
}
