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
*  20131015-001-01  DAR   10/28/13     Support WCF and Web Services
*  20150311-012-32  DAR   09/27/2016  Created to return trace "screen" values, along with select GW Rider values.  
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Disclosure Quote Service object, which allows a Disclosure quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class ValueRetrieveClient : System.ServiceModel.ClientBase<PDMA.LifePro.IValueRetrieve>, PDMA.LifePro.IValueRetrieve
    {


        public ValueRetrieveClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.ValueRetrieveResponse RetrieveTraceValues(PDMA.LifePro.ValueRetrieveRequest inProps)
        {
            return base.Channel.RetrieveTraceValues(inProps);
        }


        public PDMA.LifePro.ValueRetrieveGWResponse RetrieveGWValues(PDMA.LifePro.ValueRetrieveGWRequest inProps)
        {
            return base.Channel.RetrieveGWValues(inProps);
        }


    }
    
    
    public class ValueRetrieveService : IValueRetrieveService
	{
		
        public static APIListener api32HH; 
        public ValueRetrieveClient client; 

		public ValueRetrieveResponse RetrieveTraceValues (ValueRetrieveRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            ValueRetrieveResponse outProps = new ValueRetrieveResponse();
            try
            {

                assignedPort = ValueRetrieveInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.RetrieveTraceValues(inProps);

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



        public ValueRetrieveGWResponse RetrieveGWValues(ValueRetrieveGWRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            ValueRetrieveGWResponse outProps = new ValueRetrieveGWResponse();
            try
            {

                assignedPort = ValueRetrieveInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else
                    outProps = client.RetrieveGWValues(inProps);

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
        
        
        private int ValueRetrieveInitSteps(string userType, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "ValueRetrieve", out selectBinding, out selectEndPoint);

            client = new ValueRetrieveClient(selectBinding, selectEndPoint);

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
                    client = new ValueRetrieveClient(selectBinding, selectEndPoint);
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
