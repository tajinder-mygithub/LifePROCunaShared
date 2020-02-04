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

    public partial class HealthBenefitQuoteClient : System.ServiceModel.ClientBase<PDMA.LifePro.IHealthCalc>, PDMA.LifePro.IHealthCalc
    {


        public HealthBenefitQuoteClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.HealthBenefitQuoteResponse RunQuote(HealthBenefitQuoteRequest inProps)
        {
            return base.Channel.RunQuote(inProps);
        }

    }
    
    
    public class HealthBenefitQuoteService : IHealthBenefitQuoteService
	{
		
        public static APIListener api32HH; 
        public HealthBenefitQuoteClient client; 


		public HealthBenefitQuoteResponse RunQuote (HealthBenefitQuoteRequest inProps) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            HealthBenefitQuoteResponse outProps = new HealthBenefitQuoteResponse();
            try
            {

                assignedPort = HealthBenefitQuoteInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.RunQuote(inProps);

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


        private int HealthBenefitQuoteInitSteps(string userType, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "HealthCalc", out selectBinding, out selectEndPoint);

            client = new HealthBenefitQuoteClient(selectBinding, selectEndPoint);

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
                    client = new HealthBenefitQuoteClient(selectBinding, selectEndPoint);
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
