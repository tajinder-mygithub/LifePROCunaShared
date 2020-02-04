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
*  SR#              INIT  DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20140611-015-01  SAP   10/10/16    Added new Ens API
*/

using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;

namespace PDMA.LifePro
{
    public class EnsAPI : IEnsAPI
    {
        OENSEAPI apiEnse;
        public static OAPPLICA apiApp;

        public string UserType;

        public BaseResponse Init(string userType)
        {
            UserType = userType;
            apiEnse = new OENSEAPI(apiApp, UserType);

            BaseResponse outProps = new BaseResponse();
            outProps.ReturnCode = apiEnse.getReturnCode();
            outProps.ErrorMessage = apiEnse.getErrorMessage();
            return outProps;

        }
        public void Dispose()
        {
            apiEnse.Dispose();
            apiEnse = null;
        }

        public EnsResponse RunENSFunction(EnsRequest inProps)
        {
            apiEnse.setAgentNumber(inProps.AgentNumber);
            apiEnse.setClaimsNumber(inProps.ClaimNumber);
            apiEnse.setCompanyCode(inProps.CompanyCode);
            apiEnse.setPolicyNumber(inProps.PolicyNumber);
            apiEnse.setFunctionFlag(inProps.FunctionFlag);


            //for update, insert or delete the following fields are set
            apiEnse.setEventCode(inProps.EventCode);
            apiEnse.setEventDate(inProps.EventDate);
            apiEnse.setEventSequence(inProps.EventSequence);
            apiEnse.setUpdateCmpDate(inProps.UpdateCmpDate);
            apiEnse.setUpdateCmpOperId(inProps.UpdateCmpOperID);
            apiEnse.setUpdateLine1(inProps.UpdateLine1);
            apiEnse.setUpdateLine2(inProps.UpdateLine2);
            apiEnse.setUpdateLine3(inProps.UpdateLine3);

            apiEnse.RunENSFunction();

            EnsResponse outProps = new EnsResponse();
            outProps.ReturnCode = apiEnse.getReturnCode();
            outProps.ErrorMessage = apiEnse.getErrorMessage().Trim();
            outProps.NumOfRecords = apiEnse.getNumOfRecords();
            int count = outProps.NumOfRecords;

            if (inProps.FunctionFlag == "C")
            {
                outProps.EventCode = new string[count];
                outProps.Description = new string[count];

                for (int num = 1; num <= count; num++)
                {
                    outProps.Description[num - 1] = apiEnse.getENSDescription(num).Trim();
                    outProps.EventCode[num - 1] = apiEnse.getEventCode(num).Trim();
                }
            }
            else
            {
                outProps.CmpDate = new int[count];
                outProps.CmpOperID = new string[count];
                outProps.OrgDate = new int[count];
                outProps.OrgOperID = new string[count];
                outProps.EventCode = new string[count];
                outProps.EventDate = new int[count];
                outProps.EventSequence = new int[count];
                outProps.Line1 = new string[count];
                outProps.Line2 = new string[count];
                outProps.Line3 = new string[count];
                outProps.Description = new string[count];

                for (int num = 1; num <= count; num++)
                {
                    outProps.CmpDate[num - 1] = apiEnse.getCmpDate(num);
                    outProps.CmpOperID[num - 1] = apiEnse.getCmpOperId(num).Trim();
                    outProps.Description[num - 1] = apiEnse.getENSDescription(num).Trim();
                    outProps.EventCode[num - 1] = apiEnse.getEventCode(num).Trim();
                    outProps.EventDate[num - 1] = apiEnse.getEventDate(num);
                    outProps.EventSequence[num - 1] = apiEnse.getEventSequence(num);
                    outProps.OrgDate[num - 1] = apiEnse.getOrgDate(num);
                    outProps.OrgOperID[num - 1] = apiEnse.getOrgOperId(num);
                    outProps.Line1[num - 1] = apiEnse.getLine1(num);
                    outProps.Line2[num - 1] = apiEnse.getLine2(num);
                    outProps.Line3[num - 1] = apiEnse.getLine3(num);
                }
            }

            return outProps;

        }
    }
}
