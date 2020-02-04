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
*  20131010-019-01  DAR   10/17/16    Support additional methods for Balance Inquiry for sub-functions
*  20131010-019-01  DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*  
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Surrender Quote Service object, which allows a full surrender quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class BalanceInquiryClient : System.ServiceModel.ClientBase<PDMA.LifePro.IBalInqu>, PDMA.LifePro.IBalInqu
    {


        public BalanceInquiryClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.BalanceInquiryResponse RunInquiry(PDMA.LifePro.BalanceInquiryRequest inProps)
        {
            return base.Channel.RunInquiry(inProps);
        }

        public PDMA.LifePro.BalanceInquiryQuoteResponse RunQuoteOnly(PDMA.LifePro.BalanceInquiryRequest inProps)
        {
            return base.Channel.RunQuoteOnly(inProps);
        }

        public PDMA.LifePro.BalanceInquiryGuaranteedWithdrawalResponse GetGuaranteedWithdrawalValues(PDMA.LifePro.BalanceInquiryRequest inProps)
        {
            return base.Channel.GetGuaranteedWithdrawalValues(inProps);
        }

        public PDMA.LifePro.BalanceInquiryGuaranteedRetirementResponse GetGuaranteedRetirementValues(PDMA.LifePro.BalanceInquiryRequest inProps)
        {
            return base.Channel.GetGuaranteedRetirementValues(inProps);
        }

    
    
    }
    
    
    public class BalanceInquiryService : IBalanceInquiryService
	{
		
        public static APIListener api32HH; 
        public BalanceInquiryClient client; 

		public BalanceInquiryResponse RunInquiry (BalanceInquiryRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            BalanceInquiryResponse outProps = new BalanceInquiryResponse();
            try
            {
                Log.AddDetailedLogEntry("HTTP Balance Inquiry RunInquiry call received");

                int rc = api32HH.StartSession(out assignedPort, out message);

                if (rc != 0)
                {
                    outProps.ReturnCode = rc;
                    outProps.ErrorMessage = message;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry NO PORTS AVAILABLE Error - Exiting");

                    return outProps;  
                }

                Log.AddDetailedLogEntry("HTTP Balance Inquiry TCP port assigned: " + assignedPort.ToString());  
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "BalInqu", out selectBinding, out selectEndPoint);   

                client = new BalanceInquiryClient(selectBinding, selectEndPoint);

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
                        client = new BalanceInquiryClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                            Log.AddDetailedLogEntry("HTTP Balance Inquiry - Failed to Create Connection to APISessn - Exiting");
                            
                        }

                    }
                }


                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);  
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Client Created, about to call RunInquiry");
                    outProps = client.RunInquiry(inProps);
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry RunInquiry Completed");  

                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

                Log.AddDetailedLogEntry("HTTP Balance Inquiry RunInquiry Call Completed");  

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;

                Log.AddDetailedLogEntry("HTTP Balance Inquiry - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);
            }
			
			return outProps ; 
		
		}


        public BalanceInquiryQuoteResponse RunQuoteOnly(BalanceInquiryRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            BalanceInquiryQuoteResponse outProps = new BalanceInquiryQuoteResponse();
            try
            {

                Log.AddDetailedLogEntry("HTTP Balance Inquiry RunInquiry call received");

                int rc = api32HH.StartSession(out assignedPort, out message);


                if (rc != 0)
                {
                    outProps.ReturnCode = rc;
                    outProps.ErrorMessage = message;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry NO PORTS AVAILABLE Error - Exiting");

                    return outProps;
                }

                Log.AddDetailedLogEntry("HTTP Balance Inquiry TCP port assigned: " + assignedPort.ToString());  


                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "BalInqu", out selectBinding, out selectEndPoint);

                client = new BalanceInquiryClient(selectBinding, selectEndPoint);

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
                        client = new BalanceInquiryClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                            Log.AddDetailedLogEntry("HTTP Balance Inquiry - Failed to Create Connection to APISessn - Exiting.   System message is: " + ex.Message);
                        }

                    }
                }

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Client Created, about to call Internal RunQuoteOnly");
                    outProps = client.RunQuoteOnly(inProps);
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Internal RunQuoteOnly Completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

                Log.AddDetailedLogEntry("HTTP Balance Inquiry RunQuoteOnly Call Returning");  

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Balance Inquiry - RunQuoteOnly - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);
            }

            return outProps;

        }

        public BalanceInquiryGuaranteedWithdrawalResponse GetGuaranteedWithdrawalValues(BalanceInquiryRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            BalanceInquiryGuaranteedWithdrawalResponse outProps = new BalanceInquiryGuaranteedWithdrawalResponse();
            try
            {

                Log.AddDetailedLogEntry("HTTP Balance Inquiry GetGuaranteedWithdrawalValues call received");

                int rc = api32HH.StartSession(out assignedPort, out message);

                if (rc != 0)
                {
                    outProps.ReturnCode = rc;
                    outProps.ErrorMessage = message;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry NO PORTS AVAILABLE Error - Exiting");

                    return outProps;
                }


                Log.AddDetailedLogEntry("HTTP Balance Inquiry TCP port assigned: " + assignedPort.ToString());  

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "BalInqu", out selectBinding, out selectEndPoint);

                client = new BalanceInquiryClient(selectBinding, selectEndPoint);

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
                        client = new BalanceInquiryClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                            Log.AddDetailedLogEntry("HTTP Balance Inquiry - Failed to Create Connection to APISessn - Exiting.   System message is: " + ex.Message);
                        }

                    }
                }

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Client Created, about to call Internal GetGuaranteedWithdrawalValues");
                    outProps = client.GetGuaranteedWithdrawalValues(inProps);
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Internal GetGuaranteedWithdrawalValues Completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

                Log.AddDetailedLogEntry("HTTP Balance Inquiry GetGuaranteedWithdrawalValues Call Returning");  


            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Balance Inquiry - GetGuaranteedWithdrawalValues - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);

            }

            return outProps;

        }


        public BalanceInquiryGuaranteedRetirementResponse GetGuaranteedRetirementValues(BalanceInquiryRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            BalanceInquiryGuaranteedRetirementResponse outProps = new BalanceInquiryGuaranteedRetirementResponse();
            try
            {

                Log.AddDetailedLogEntry("HTTP Balance Inquiry GetGuaranteedRetirementValues call received");

                int rc = api32HH.StartSession(out assignedPort, out message);

                if (rc != 0)
                {
                    outProps.ReturnCode = rc;
                    outProps.ErrorMessage = message;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry NO PORTS AVAILABLE Error - Exiting");

                    return outProps;
                }


                Log.AddDetailedLogEntry("HTTP Balance Inquiry TCP port assigned: " + assignedPort.ToString());  

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "BalInqu", out selectBinding, out selectEndPoint);

                client = new BalanceInquiryClient(selectBinding, selectEndPoint);

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
                        client = new BalanceInquiryClient(selectBinding, selectEndPoint);
                        attempts++;
                        if (attempts > 19)
                        {
                            output.ReturnCode = 99000;
                            output.ErrorMessage = "Internal Communication error on Application Server.  A connection with an APISessn.exe instance could not be established.  Check configuration, re-start environment using the Thin Service Controller, and try again.  System error is: " + ex.Message;
                            Log.AddDetailedLogEntry("HTTP Balance Inquiry - Failed to Create Connection to APISessn - Exiting.   System message is: " + ex.Message);
                        }

                    }
                }

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Client Created, about to call Internal GetGuaranteedRetirementValues");
                    outProps = client.GetGuaranteedRetirementValues(inProps);
                    Log.AddDetailedLogEntry("HTTP Balance Inquiry Internal GetGuaranteedRetirementValues Completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

                Log.AddDetailedLogEntry("HTTP Balance Inquiry GetGuaranteedRetirementValues Call Returning");  


            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Balance Inquiry - GetGuaranteedRetirementValues - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);

            }

            return outProps;

        }






	}
}
