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
	/// The LifePRO Deposit Allocation Service object, which allows inquiry on and update of Deposit Allocation information.  
	/// </summary>

    public partial class DepositAllocationClient : System.ServiceModel.ClientBase<PDMA.LifePro.IDepAllc>, PDMA.LifePro.IDepAllc
    {


        public DepositAllocationClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.DepositAllocationResponse RetrieveAllocations(ref PDMA.LifePro.DepositAllocationRequest inProps)
        {
            return base.Channel.RetrieveAllocations(ref inProps);
        }

        public PDMA.LifePro.DepositAllocationResponse RefreshAvailability(ref  PDMA.LifePro.DepositAllocationRequest inProps)
        {

            // We must precede a refresh with a Retrieve Allocations.  
            DepositAllocationRequest tempInput = new DepositAllocationRequest();
            tempInput.CompanyCode = (string)inProps.CompanyCode.Clone();
            tempInput.DepositAllocation = (double[])inProps.DepositAllocation.Clone();
            tempInput.EffectiveDate = inProps.EffectiveDate;
            tempInput.PolicyNumber = (string)inProps.PolicyNumber.Clone();
            tempInput.UserType = (string)inProps.UserType.Clone();

            DepositAllocationResponse retrieveResponse = base.Channel.RetrieveAllocations (ref tempInput);
            if (retrieveResponse.ReturnCode == 0)
                return base.Channel.RefreshAvailability(ref inProps);
            else
            {
                return retrieveResponse; 
            }

        }

        public PDMA.LifePro.BaseResponse PerformEditsOnly (PDMA.LifePro.DepositAllocationRequest inProps)
        {
          // Because of stateless nature of calls, must re-do Retrieve so that server is initialized.  


            // We create a temporary input block that can be discarded.  The actual udpate should attempt 
            // to use the inputs the user provided.  
            DepositAllocationRequest tempInput = new DepositAllocationRequest();
            tempInput.CompanyCode = (string) inProps.CompanyCode.Clone();
            tempInput.DepositAllocation = (double []) inProps.DepositAllocation.Clone();
            tempInput.EffectiveDate = inProps.EffectiveDate;
            tempInput.PolicyNumber = (string) inProps.PolicyNumber.Clone();
            tempInput.UserType = (string)inProps.UserType.Clone();   

            DepositAllocationResponse retrieveResponse = base.Channel.RetrieveAllocations (ref tempInput);
            if (retrieveResponse.ReturnCode == 0)
                return base.Channel.PerformEditsOnly(inProps);
            else
            {
                BaseResponse response = new BaseResponse();
                response.ReturnCode = retrieveResponse.ReturnCode;
                response.ErrorMessage = retrieveResponse.ErrorMessage;
                return response;   
            }
        }




        public PDMA.LifePro.BaseResponse UpdateAllocations(PDMA.LifePro.DepositAllocationRequest inProps)
        {
          // Because of stateless nature of calls, must re-do Retrieve so that server is initialized.  


            // We create a temporary input block that can be discarded.  The actual udpate should attempt 
            // to use the inputs the user provided.  
            DepositAllocationRequest tempInput = new DepositAllocationRequest();
            tempInput.CompanyCode = (string) inProps.CompanyCode.Clone();
            tempInput.DepositAllocation = (double []) inProps.DepositAllocation.Clone();
            tempInput.EffectiveDate = inProps.EffectiveDate;
            tempInput.PolicyNumber = (string) inProps.PolicyNumber.Clone();
            tempInput.UserType = (string)inProps.UserType.Clone();   

            DepositAllocationResponse retrieveResponse = base.Channel.RetrieveAllocations (ref tempInput);
            if (retrieveResponse.ReturnCode == 0)
                return base.Channel.UpdateAllocations(inProps);
            else
            {
                BaseResponse response = new BaseResponse();
                response.ReturnCode = retrieveResponse.ReturnCode;
                response.ErrorMessage = retrieveResponse.ErrorMessage;
                return response;   
            }
        }

    }
    
    
    public class DepositAllocationService : IDepositAllocationService
	{
		
        public static APIListener api32HH; 
        public DepositAllocationClient client; 

		public DepositAllocationResponse RetrieveAllocations (ref DepositAllocationRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            DepositAllocationResponse outProps = new DepositAllocationResponse();
            try
            {

                Log.AddDetailedLogEntry("HTTP Deposit Allocation RetrieveAllocations call received");

                assignedPort = DepositAllocationInitSteps(inProps, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);

                    if (assignedPort == 0)
                        return outProps;   //  Cannnot execute Dispose and End Session, since no port assigned.  
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Client Created, about to call Internal RetrieveAllocations");
                    outProps = client.RetrieveAllocations(ref inProps);
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Internal RetrieveAllocations Completed");  

                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);
                Log.AddDetailedLogEntry("HTTP Deposit Allocation Retrieve Allocations Call Returning");  


            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Deposit Allocation - RetrieveAllocations - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);
            }
			
			return outProps ; 
		
		}

        private int DepositAllocationInitSteps(DepositAllocationRequest inProps, ref string message, ref BaseResponse output)
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

            Util.DetermineBinding(assignedPort, "DepAllc", out selectBinding, out selectEndPoint);

            client = new DepositAllocationClient(selectBinding, selectEndPoint);

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
                    client = new DepositAllocationClient(selectBinding, selectEndPoint);
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

		public DepositAllocationResponse RefreshAvailability (ref DepositAllocationRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            DepositAllocationResponse outProps = new DepositAllocationResponse();
            try
            {
                Log.AddDetailedLogEntry("HTTP Deposit Allocation RefreshAvailability call received");

                assignedPort = DepositAllocationInitSteps(inProps, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation - call failure with Return Code = " + outProps.ReturnCode + " and Message = " + outProps.ErrorMessage);

                    if (assignedPort == 0)
                        return outProps;   //  Cannnot execute Dispose and End Session, since no port assigned.  
                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Client Created, about to call Internal RefreshAvailability");
                    outProps = client.RefreshAvailability(ref inProps);
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Internal RefreshAvailability Completed");  

                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);
                Log.AddDetailedLogEntry("HTTP Deposit Allocation RefreshAvailability Call Returning");  


            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Deposit Allocation - RefreshAvailability - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);
            }
			
			return outProps ; 
		
		}

		public BaseResponse PerformEditsOnly (DepositAllocationRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {
                Log.AddDetailedLogEntry("HTTP Deposit Allocation RetrieveAllocations call received");
                assignedPort = DepositAllocationInitSteps(inProps, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation - call failure with Return Code = " + output.ReturnCode + " and Message = " + output.ErrorMessage);

                    // Changed to only return when the assigned port wasn't non-zero.  Other cases we should try cleanup of Dispose and End Session.  
                    if (assignedPort == 0)
                        return output;

                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Client Created, about to call Internal PerformEditsOnly");
                    output = client.UpdateAllocations(inProps);
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Internal PerformEditsOnly Completed");  
                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);
                Log.AddDetailedLogEntry("HTTP Deposit Allocation PerformEditsOnly Call Returning");  

            }
            catch (Exception ex)
            {

                output.ReturnCode = 9999;
                output.ErrorMessage = ex.Message;
                Log.AddDetailedLogEntry("HTTP Deposit Allocation - PerformEditsOnly - Critical Unexpected Exception.  Exiting with Message: " + ex.Message);

            }
			
			return output ; 
		}


		public BaseResponse UpdateAllocations (DepositAllocationRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {
                Log.AddDetailedLogEntry("HTTP Deposit Allocation UpdateAllocations call received");

                assignedPort = DepositAllocationInitSteps(inProps, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation - call failure with Return Code = " + output.ReturnCode + " and Message = " + output.ErrorMessage);

                    // Changed to only return when the assigned port wasn't non-zero.  Other cases we should try cleanup of Dispose and End Session.  
                    if (assignedPort == 0)
                        return output;

                }
                else
                {
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Client Created, about to call Internal UpdateAllocations");
                    output = client.UpdateAllocations(inProps);
                    Log.AddDetailedLogEntry("HTTP Deposit Allocation Internal UpdateAllocations Completed");  
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
