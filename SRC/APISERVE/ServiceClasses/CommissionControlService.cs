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
	/// The LifePRO Illustration Input Service object, which allows retrieval of available coverage information.  This is designed 
	// to be used in conjunction with the Proposal Service or API.  
	/// </summary>

    public partial class CommissionControlClient : System.ServiceModel.ClientBase<PDMA.LifePro.ICommissionControl>, PDMA.LifePro.ICommissionControl
    {


        public CommissionControlClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.CommissionControlResponse RetrieveCommissionSplits(PDMA.LifePro.CommissionControlRequest inProps)
        {
            return base.Channel.RetrieveCommissionSplits(inProps);
        }

        public PDMA.LifePro.BaseResponse AddNewCommissionSplit(PDMA.LifePro.CommissionControlRequest inProps)
        {
            return base.Channel.AddNewCommissionSplit(inProps);
        }

    }
    
    
    public class CommissionControlService : ICommissionControlService
	{
		
        public static APIListener api32HH; 
        public CommissionControlClient client; 

		public CommissionControlResponse RetrieveCommissionSplits (CommissionControlRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            CommissionControlResponse outProps = new CommissionControlResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "CommissionControl", out selectBinding, out selectEndPoint);   

                client = new CommissionControlClient(selectBinding, selectEndPoint);

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
                        client = new CommissionControlClient(selectBinding, selectEndPoint);
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
                    outProps = client.RetrieveCommissionSplits(inProps);

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


		public BaseResponse AddNewCommissionSplit (CommissionControlRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "CommissionControl", out selectBinding, out selectEndPoint);   

                client = new CommissionControlClient(selectBinding, selectEndPoint);

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
                        client = new CommissionControlClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  An APISessn.exe instance could not start.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                        }

                    }
                }

                if (output.ReturnCode == 0)
                {
                    output = client.AddNewCommissionSplit(inProps);
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                output.ReturnCode = 9999;
                output.ErrorMessage = ex.Message;

            }
			
			return output ; 
		
		}

	
	
	}
}
