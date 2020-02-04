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
	/// The LifePRO Deposit Allocation Service object, which allows inquiry on and update of Deposit Allocation information.  
	/// </summary>

    public partial class MultipleInsuredQuoteClient : System.ServiceModel.ClientBase<PDMA.LifePro.IMultQuote>, PDMA.LifePro.IMultQuote
    {


        public MultipleInsuredQuoteClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.MultipleInsuredQuoteRequest LoadExistingBenefits(string company, string policy, int effectivedate, out int returncode, out string message)
        {
            return base.Channel.LoadExistingBenefits(company, policy, effectivedate, out returncode, out message);
        }

        public PDMA.LifePro.MultipleInsuredQuoteRequest LoadWithTarget(string company, string policy, int effectivedate, string[] targetBenefitCode, double[] targetDMB, out int returncode, out string message)
        {
            return base.Channel.LoadWithTarget(company, policy, effectivedate, targetBenefitCode, targetDMB, out returncode, out message);
        }


        public PDMA.LifePro.MultipleInsuredQuoteResponse RunRequote(PDMA.LifePro.MultipleInsuredQuoteRequest inProps)
        {
            return base.Channel.RunRequote(inProps);
        }

    }
    
    
    public class MultipleInsuredQuoteService : IMultipleInsuredQuoteService
	{
		
        public static APIListener api32HH; 
        public MultipleInsuredQuoteClient client; 

    
		public MultipleInsuredQuoteRequest LoadExistingBenefits (string usertype, string company, string policy, int effectivedate, out int returncode, out string message ) 
		{

            int assignedPort; 
            message = "";
            BaseResponse output = new BaseResponse();
            MultipleInsuredQuoteRequest outProps = new MultipleInsuredQuoteRequest();
            try
            {

                assignedPort = MultipleInsuredQuoteInitSteps(usertype, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    returncode = output.ReturnCode;
                    message = output.ErrorMessage;
                }
                else 
                    outProps = client.LoadExistingBenefits(company, policy, effectivedate, out returncode, out message);

                outProps.UserType = usertype; 
                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                returncode = 9999; 
                message = ex.Message;  
            }
			
			return outProps ; 
		
		}



		public MultipleInsuredQuoteRequest LoadWithTarget (string usertype, string company, string policy, int effectivedate, string[] targetBenefitCode, double[] targetDMB, out int returncode, out string message ) 
		{

            int assignedPort; 
            message = "";
            BaseResponse output = new BaseResponse();
            MultipleInsuredQuoteRequest outProps = new MultipleInsuredQuoteRequest();
            try
            {

                assignedPort = MultipleInsuredQuoteInitSteps(usertype, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    returncode = output.ReturnCode;
                    message = output.ErrorMessage;
                }
                else 
                    outProps = client.LoadWithTarget(company, policy, effectivedate, targetBenefitCode, targetDMB, out returncode, out message);

                outProps.UserType = usertype; 
                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                returncode = 9999;
                message = ex.Message;

            }
			
			return outProps ; 
		
		}



		public MultipleInsuredQuoteResponse RunRequote (MultipleInsuredQuoteRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            MultipleInsuredQuoteResponse outProps = new MultipleInsuredQuoteResponse();
            try
            {

                assignedPort = MultipleInsuredQuoteInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.RunRequote(inProps);

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

        private int MultipleInsuredQuoteInitSteps(string userType, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "MultQuote", out selectBinding, out selectEndPoint);

            client = new MultipleInsuredQuoteClient(selectBinding, selectEndPoint);

            bool isAvailable = false;
            int attempts = 0;
            while (!isAvailable && attempts < 20)
            {
                try
                {
                    output = client.Init(userType);
                    isAvailable = true;
                }

                catch (Exception ex)
                {
                    client = new MultipleInsuredQuoteClient(selectBinding, selectEndPoint);
                    attempts++;
                    if (attempts > 19)
                    {
                        output.ReturnCode = 99000;
                        output.ErrorMessage = "Internal Communication error on Application Server.  An APISessn.exe instance could not start.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                    }

                }
            }

            return assignedPort;
        }


	
	
	}
}
