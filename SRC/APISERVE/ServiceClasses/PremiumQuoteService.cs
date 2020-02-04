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
	/// The LifePRO Premium Quote Service object, which allows a full premium quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class PremiumQuoteClient : System.ServiceModel.ClientBase<PDMA.LifePro.IPrmQuote>, PDMA.LifePro.IPrmQuote
    {


        public PremiumQuoteClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.PremiumQuoteResponse RunQuote(PDMA.LifePro.PremiumQuoteRequest inProps)
        {
            return base.Channel.RunQuote(inProps);
        }
    }
    
    
    public class PremiumQuoteService : IPremiumQuoteService
	{
		
        public static APIListener api32HH; 
        public PremiumQuoteClient client; 

		public PremiumQuoteResponse RunQuote (PremiumQuoteRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            PremiumQuoteResponse outProps = new PremiumQuoteResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "PrmQuote", out selectBinding, out selectEndPoint);   

                client = new PremiumQuoteClient(selectBinding, selectEndPoint);

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
                        client = new PremiumQuoteClient(selectBinding, selectEndPoint);
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
	
	
	}
}
