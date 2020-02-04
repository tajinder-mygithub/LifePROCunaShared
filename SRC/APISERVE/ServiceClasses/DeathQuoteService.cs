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
*  20131010-019-01  DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Death Quote Service object, which allows a Death quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class DeathQuoteClient : System.ServiceModel.ClientBase<PDMA.LifePro.IDthQuote>, PDMA.LifePro.IDthQuote
    {


        public DeathQuoteClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.DeathQuoteResponse RunQuote(PDMA.LifePro.DeathQuoteRequest inProps)
        {
            return base.Channel.RunQuote(inProps);
        }
    }
    
    
    public class DeathQuoteService : IDeathQuoteService
	{
		
        public static APIListener api32HH; 
        public DeathQuoteClient client; 

		public DeathQuoteResponse RunQuote (DeathQuoteRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            DeathQuoteResponse outProps = new DeathQuoteResponse();
            try
            {

                Log.AddDetailedLogEntry("HTTP Death Quote RunQuote call received");

                assignedPort = DeathQuoteInitSteps(inProps, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;

                    if (assignedPort == 0)
                        return outProps;   //  Cannnot execute Dispose and End Session, since no port assigned.  

                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Death Quote Client Created, about to call Internal RunQuote");
                    outProps = client.RunQuote(inProps);
                    Log.AddDetailedLogEntry("HTTP Death Quote Internal RunQuote completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);
                Log.AddDetailedLogEntry("HTTP Death Quote RunQuote Call Returning");  

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Death Quote - RunQuote - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);

            }
			
			return outProps ; 
		
		}

        private int DeathQuoteInitSteps(DeathQuoteRequest inProps, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            if (rc != 0)
            {
                output.ReturnCode = rc;
                output.ErrorMessage = message;
                Log.AddDetailedLogEntry("HTTP Deposit Allocation NO PORTS AVAILABLE Error - Exiting");
                return 0; 
            }


            Log.AddDetailedLogEntry("HTTP Deposit Allocation TCP port assigned: " + assignedPort.ToString());  

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "DthQuote", out selectBinding, out selectEndPoint);

            client = new DeathQuoteClient(selectBinding, selectEndPoint);

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
                    client = new DeathQuoteClient(selectBinding, selectEndPoint);
                    attempts++;
                    if (attempts > 19)
                    {
                        output.ReturnCode = 99000;
                        output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                        Log.AddDetailedLogEntry("HTTP Deposit Allocation - Failed to Create Connection to APISessn - Exiting.   System message is: " + ex.Message);
                    }

                }
            }

            return assignedPort;
        }
	

	
	}
}
