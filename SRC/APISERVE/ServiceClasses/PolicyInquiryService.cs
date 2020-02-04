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
*  20131015-001-01  DAR   10/28/13    Support WCF and Web Services
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Surrender Quote Service object, which allows a full surrender quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class PolicyInquiryClient : System.ServiceModel.ClientBase<PDMA.LifePro.IPolcAPI>, PDMA.LifePro.IPolcAPI
    {


        public PolicyInquiryClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
            base(binding, remoteAddress)
        {
        }

        public PDMA.LifePro.BaseResponse Init(string userType)
        {
            return base.Channel.Init(userType);
        }

        public void Dispose()
        {
            base.Channel.Dispose();
        }

        public PDMA.LifePro.PolicyInquiryResponse GetPolcInfo(PDMA.LifePro.PolicyInquiryRequest inProps)
        {
            return base.Channel.GetPolcInfo(inProps);
        }
    }
    
    
    public class PolicyInquiryService : IPolicyInquiryService
	{
		
        public static APIListener api32HH; 
        public PolicyInquiryClient client; 

		public PolicyInquiryResponse GetPolcInfo (PolicyInquiryRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            PolicyInquiryResponse outProps = new PolicyInquiryResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "PolcAPI", out selectBinding, out selectEndPoint);   

                client = new PolicyInquiryClient(selectBinding, selectEndPoint);

                bool isAvailable = false;
                int attempts = 0;
                while (!isAvailable && attempts < 20)
                {
                    try
                    {
                        output = client.Init(inProps.UserType);
                        isAvailable = true;
                    }

                    catch (Exception ex)
                    {
                        client = new PolicyInquiryClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  An APISessn.exe instance could not start.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                        }

                    }
                }

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.GetPolcInfo(inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;

            }
			
			return outProps ; 
		
		}
	
	
	}
}
