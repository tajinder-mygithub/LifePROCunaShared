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
	/// The LifePRO Surrender Quote Service object, which allows a full surrender quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class SurrenderQuoteClient : System.ServiceModel.ClientBase<PDMA.LifePro.ISurQuote>, PDMA.LifePro.ISurQuote
    {


        public SurrenderQuoteClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.SurrenderQuoteResponse RunQuote(PDMA.LifePro.SurrenderQuoteRequest inProps)
        {
            return base.Channel.RunQuote(inProps);
        }
    }
    
    
    public class SurrenderQuoteService : ISurrenderQuoteService
	{
		
        public static APIListener api32HH; 
        public SurrenderQuoteClient client; 

		public SurrenderQuoteResponse RunQuote (SurrenderQuoteRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            SurrenderQuoteResponse outProps = new SurrenderQuoteResponse();
            try
            {
                Log.AddDetailedLogEntry("HTTP Surrender Quote call received");  

                int rc = api32HH.StartSession(out assignedPort, out message);

                if (rc != 0)
                {
                    outProps.ReturnCode = rc;
                    outProps.ErrorMessage = message;
                    Log.AddDetailedLogEntry("HTTP Surrender Quote NO PORTS AVAILABLE Error - Exiting");
                    return outProps;
                }


                Log.AddDetailedLogEntry("HTTP Surrender Quote TCP port assigned: " + assignedPort.ToString());  

                
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "SurQuote", out selectBinding, out selectEndPoint);   

                client = new SurrenderQuoteClient(selectBinding, selectEndPoint);

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
                        client = new SurrenderQuoteClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                            Log.AddDetailedLogEntry("HTTP Surrender Qutoe - Failed to Create Connection to APISessn - Exiting.   System message is: " + ex.Message);
                        }

                    }
                }


                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Surrender Quote - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Surrender Quote Client Created, about to call Internal RunQuote");
                    outProps = client.RunQuote(inProps);
                    Log.AddDetailedLogEntry("HTTP Surrender Quote Internal RunQuote Completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);
                Log.AddDetailedLogEntry("HTTP Surrender Quote RunQuote Call Returning");  


            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Surrender Quote - RunQuote - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);
            }
			
			return outProps ; 
		
		}
	
	
	}
}
