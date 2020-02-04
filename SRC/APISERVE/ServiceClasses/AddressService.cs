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
*  20150601-002-01  AKR   01/14/16    New Co/Pol Methods Added  
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Address Service object, which allows inquiry and updates of the PADDR and related tables, using a Web Service interface.  
	/// </summary>

    public partial class AddressAPIClient : System.ServiceModel.ClientBase<PDMA.LifePro.IAddrAPI>, PDMA.LifePro.IAddrAPI
    {


        public AddressAPIClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.AddressResponse RunAddressFunction(ref PDMA.LifePro.AddressRequest inProps)
        {
            if (inProps.UpdateQueryFlag == "N" ||
                inProps.UpdateQueryFlag == "U")
            {

                // Perform an exact inquiry first.  Throwaway return code if successful, and then go on to requested operation. 
                string saveFunction = inProps.UpdateQueryFlag;
                AddressRequest tempInput = new AddressRequest();
                tempInput.NameID = inProps.NameID;

                // the user does not need to actually set these values.  They are passed back by reference on inquiry calls.   
                tempInput.AddressID = inProps.AddressID;
                tempInput.AddressCode = inProps.AddressCode;
                tempInput.EffectiveDate = inProps.EffectiveDate;
                tempInput.IdentifyingNumber = inProps.IdentifyingNumber;
                tempInput.UpdateQueryFlag = "E"; // Do an "Exact" lookup to position prior to processing an udpate or an inquire.  

                AddressResponse tempOutput = base.Channel.RunAddressFunction(ref tempInput);

                if (tempOutput.ReturnCode != 0)
                    return tempOutput;

                inProps.UpdateQueryFlag = saveFunction; 

            }

            return base.Channel.RunAddressFunction(ref inProps);
        }
        //20150601-002
        public PDMA.LifePro.AddressResponse GetAddress(ref PDMA.LifePro.AddressRequest inProps)
        {
            // Setting Flag so OADDRAPI will know this is coming from WebService Query (Search)
            if (inProps.UpdateQueryFlag != "N")
            {
                inProps.UpdateQueryFlag = "S";
            }
            return base.Channel.GetAddress(ref inProps);
        }
        // 20150601-002 20160114 Begin
        public PDMA.LifePro.AddressResponse AddAddressForPolicy(ref PDMA.LifePro.AddressRequest inProps)
        {
            // Setting Flag so OADDRAPI will know this is coming from WebService an Add (Insert)
            inProps.UpdateQueryFlag = "I";
            return base.Channel.AddAddressForPolicy(ref inProps);
        }
        public PDMA.LifePro.AddressResponse UpdateAddressForPolicy(ref PDMA.LifePro.AddressRequest inProps)
        {
            // Setting Flag so OADDRAPI will know this is coming from WebService an Update (Modify)
            inProps.UpdateQueryFlag = "M";

            return base.Channel.UpdateAddressForPolicy(ref inProps);
        }
        // 20150601-002 20160114 End
    }
    
    
    public class AddressService : IAddressService
	{
		
        public static APIListener api32HH; 
        public AddressAPIClient client; 

		public AddressResponse RunAddressFunction (ref AddressRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            AddressResponse outProps = new AddressResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "AddrAPI", out selectBinding, out selectEndPoint);   

                client = new AddressAPIClient(selectBinding, selectEndPoint);

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
                        client = new AddressAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.RunAddressFunction(ref inProps);

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

        // 20150601-002
        public AddressResponse GetAddress(ref AddressRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            AddressResponse outProps = new AddressResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "AddrAPI", out selectBinding, out selectEndPoint);

                client = new AddressAPIClient(selectBinding, selectEndPoint);

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
                        client = new AddressAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.GetAddress(ref inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;

            }

            return outProps;

        }
        // 20150601-002 20160114 Begin
        public AddressResponse AddAddressForPolicy(ref AddressRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            AddressResponse outProps = new AddressResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "AddrAPI", out selectBinding, out selectEndPoint);

                client = new AddressAPIClient(selectBinding, selectEndPoint);

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
                        client = new AddressAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.AddAddressForPolicy(ref inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;

            }

            return outProps;

        }
        public AddressResponse UpdateAddressForPolicy(ref AddressRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            AddressResponse outProps = new AddressResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "AddrAPI", out selectBinding, out selectEndPoint);

                client = new AddressAPIClient(selectBinding, selectEndPoint);

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
                        client = new AddressAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.UpdateAddressForPolicy(ref inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

            }
            catch (Exception ex)
            {
                outProps.ReturnCode = 9999;
                outProps.ErrorMessage = ex.Message;

            }

            return outProps;

        }
        // 20150601-002 20160114 AKR End
		
	}
}
