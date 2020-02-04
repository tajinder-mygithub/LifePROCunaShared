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
*  20111205-001-01   DAR   02/14/12    Initial implementation  
*  20111117-006-01   DAR   05/25/12    Retrofit 20111205-001-01
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20131122-010-01   JWS   11/17/14    Add new suspense option.
*/


using System;
using LPNETAPI ;
using System.Data;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for TerminatePolicyBenefit.
	/// </summary>

	public class TerminatePolicyBenefit : MarshalByRefObject, ITerminatePolicyBenefit
	{
		OTERMNTE apiTerminate ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init(string userType)
		{
			UserType = userType ; 
			apiTerminate = new OTERMNTE(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiTerminate.getReturnCode() ; 
			outProps.ErrorMessage = apiTerminate.getErrorMessage() ;
            return outProps;   

		}

		public void Dispose() 
		{
			apiTerminate.Dispose(); 
			apiTerminate = null ; 
		}

		public TerminatePolicyBenefitResponse ExecuteTermination (TerminatePolicyBenefitRequest inProps ) 
		{
			apiTerminate.setCompanyCode(inProps.CompanyCode); 
			apiTerminate.setPolicyNumber(inProps.PolicyNumber);
            apiTerminate.setNameID(inProps.NameID);
            apiTerminate.setEffectiveDate(inProps.EffectiveDate);
            apiTerminate.setRequestType(inProps.RequestType);
            apiTerminate.setSurrenderValueOption(inProps.SurrenderValueOption);
            apiTerminate.setReasonCode(inProps.ReasonCode);
            apiTerminate.setBenefitSequence(inProps.BenefitSequence);   

            // PolicyNotes ... maybe should be one string that we "chop" up?  
            int noteLen = 76;
            int processedLen = 0;
            short row = 0; 
            while (processedLen < inProps.PolicyNotes.Length)
            {
                string oneLine = "";
                if (inProps.PolicyNotes.Substring(processedLen).Length > noteLen)
                    oneLine = inProps.PolicyNotes.Substring(processedLen, noteLen);
                else
                    oneLine = inProps.PolicyNotes.Substring(processedLen);  

                short sub = (short) (row + 1);   
                apiTerminate.setPolicyNoteLine(sub, oneLine);
                processedLen = processedLen + noteLen;
                row++;   
            }

			apiTerminate.ExecuteTermination()  ; 

			TerminatePolicyBenefitResponse outProps = new TerminatePolicyBenefitResponse() ; 
			outProps.ReturnCode = apiTerminate.getReturnCode();  
			outProps.ErrorMessage = apiTerminate.getErrorMessage();

            outProps.PaidToDate = apiTerminate.getPaidToDate();
            outProps.StatusEffectiveDate = apiTerminate.getStatusEffectiveDate();
            outProps.ContractCode = apiTerminate.getContractCode();
            outProps.OutReasonCode = apiTerminate.getOutReasonCode();
            outProps.Suspense = apiTerminate.getSuspense();
            outProps.SurrenderValue = apiTerminate.getSurrenderValue();

            DataTable benefitsTab = new DataTable("Benefits");   
            benefitsTab.Columns.Add("BenefitSequence", typeof(short));
            benefitsTab.Columns.Add("PlanCode", typeof(string));
            benefitsTab.Columns.Add("CoverageDescription", typeof(string));
            benefitsTab.Columns.Add("FaceAmount", typeof(double));
            benefitsTab.Columns.Add("IssueDate", typeof(int));
            benefitsTab.Columns.Add("StatusCode", typeof(string));
            benefitsTab.Columns.Add("StatusEffectiveDate", typeof(int));
            benefitsTab.Columns.Add("ProcessedToDate", typeof(int));
            benefitsTab.Columns.Add("PayUpDate", typeof(int));
            benefitsTab.Columns.Add("MatureExpireDate", typeof(int));

            int maxBenefit = 100;
            for (short i = 0; i < maxBenefit; i++)
            {


                if (apiTerminate.getBenListSeq(i + 1) != 0)
                {
                    DataRow rowBen = benefitsTab.NewRow();
                    rowBen["BenefitSequence"] = apiTerminate.getBenListSeq(i + 1);
                    rowBen["PlanCode"] = apiTerminate.getBenListPlanCode(i + 1);
                    rowBen["CoverageDescription"] = apiTerminate.getBenListCoverageDescription(i + 1);
                    rowBen["FaceAmount"] = apiTerminate.getBenListFaceAmount(i + 1);
                    rowBen["IssueDate"] = apiTerminate.getBenListIssueDate(i + 1);
                    rowBen["StatusCode"] = apiTerminate.getBenListStatusCode(i + 1);
                    rowBen["StatusEffectiveDate"] = apiTerminate.getBenListStatusEffectiveDate(i + 1);
                    rowBen["ProcessedToDate"] = apiTerminate.getBenListProcessedToDate(i + 1);
                    rowBen["PayUpDate"] = apiTerminate.getBenListPayUpDate(i + 1);   
                    rowBen["MatureExpireDate"] = apiTerminate.getBenListMatureExpireDate(i + 1);

                    benefitsTab.Rows.Add(rowBen);

                }
                else
                    break;
            }

            outProps.Benefits = benefitsTab;

            DataTable multInsTab = new DataTable("MultipleInsureds");
            multInsTab.Columns.Add("BenefitSequence", typeof(short));
            multInsTab.Columns.Add("NameID", typeof(int));
            multInsTab.Columns.Add("InsuredName", typeof(string));
            multInsTab.Columns.Add("InsuredPrefix", typeof(string));
            multInsTab.Columns.Add("InsuredFirst", typeof(string));
            multInsTab.Columns.Add("InsuredMiddle", typeof(string));
            multInsTab.Columns.Add("InsuredLast", typeof(string));
            multInsTab.Columns.Add("InsuredSuffix", typeof(string));

            multInsTab.Columns.Add("StartDate", typeof(int));
            multInsTab.Columns.Add("StopDate", typeof(int));
           

            int maxInsured = 500;
            for (short i = 0; i < maxInsured; i++)
            {

                if (apiTerminate.getMuinListNameID(i + 1) != 0)
                {
                    DataRow rowMuin = multInsTab.NewRow();
                    rowMuin["BenefitSequence"] = apiTerminate.getMuinListSeq(i + 1);
                    rowMuin["NameID"] = apiTerminate.getMuinListNameID(i + 1);
                    rowMuin["InsuredName"] = apiTerminate.getMuinListFormattedName(i + 1);
                    rowMuin["InsuredPrefix"] = apiTerminate.getMuinListIndividualPrefix(i + 1);
                    rowMuin["InsuredFirst"] = apiTerminate.getMuinListIndividualFirst(i + 1);
                    rowMuin["InsuredMiddle"] = apiTerminate.getMuinListIndividualMiddle(i + 1);
                    rowMuin["InsuredLast"] = apiTerminate.getMuinListIndividualLast(i + 1);
                    rowMuin["InsuredSuffix"] = apiTerminate.getMuinListIndividualSuffix(i + 1);   
                    rowMuin["StartDate"] = apiTerminate.getMuinListStartDate(i + 1);
                    rowMuin["StopDate"] = apiTerminate.getMuinListStopDate(i + 1);

                    multInsTab.Rows.Add(rowMuin);
                }
                else
                    break;   
            }


            outProps.MultipleInsureds = multInsTab;  
			
			return outProps ; 
		}


	
	}
}
