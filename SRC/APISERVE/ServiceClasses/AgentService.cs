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
	/// The LifePRO Surrender Quote Service object, which allows a full surrender quote of a policy, using a Web Service interface.  
	/// </summary>

    public partial class AgentClient : System.ServiceModel.ClientBase<PDMA.LifePro.IAiefApi>, PDMA.LifePro.IAiefApi
    {


        public AgentClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.BaseResponse RunInterfaceFunction(ref PDMA.LifePro.AgentRequest inProps)
        {
            return base.Channel.RunInterfaceFunction(ref inProps);
        }
    }
    
    
    public class AgentService : IAgentService
	{
		
        public static APIListener api32HH; 
        public AgentClient client; 

		public BaseResponse RunInterfaceFunction (ref AgentRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "AiefApi", out selectBinding, out selectEndPoint);   

                client = new AgentClient(selectBinding, selectEndPoint);

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

                        client = new AgentClient(selectBinding, selectEndPoint);
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

                    // Updates and Deletes require an Inquire first.  If one of these operations are requested, we will execute 
                    // an inquire on agent number so that the underlying COBOL programs, etc., will be in the proper state 
                    // before executing the udpate.  

                    if (inProps.FunctionType.ToUpper() == "D" ||
                        inProps.FunctionType.ToUpper() == "U")
                    {
                        AgentRequest tempInput = new AgentRequest();
                        tempInput.FunctionType = "I";
                        tempInput.FunctionSubtype = "G";
                        tempInput.CompanyCode = inProps.CompanyCode;
                        tempInput.AgentNumber = inProps.AgentNumber;

                        output = client.RunInterfaceFunction(ref tempInput);  

                    }

                    if (output.ReturnCode == 0) 
                        output = client.RunInterfaceFunction(ref inProps);
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
