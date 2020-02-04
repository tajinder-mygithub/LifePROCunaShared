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
*  20140129-005-01  JWS   03/05/14    SPIA Calculator
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;


namespace PDMA.LifePro
{
    /// <summary>
    /// The LifePRO DPIA Calculator Service object, which allows modeling SPIA and other annuities, using a Web Service interface.  
    /// </summary>

    public partial class SPIACalcClient : System.ServiceModel.ClientBase<PDMA.LifePro.ISPIACalc>, PDMA.LifePro.ISPIACalc
    {
        public SPIACalcClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.BaseResponse RunQuote(ref PDMA.LifePro.SPIACalcInput inProps)
        {
            return base.Channel.RunQuote(ref inProps);
        }
    }

    public class SPIACalcService : ISPIACalcService
	{
		
        public static APIListener api32HH;
        public SPIACalcClient client;

        public BaseResponse RunQuote(ref SPIACalcInput inProps) 
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
                client = new SPIACalcClient(selectBinding, selectEndPoint);
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
                        client = new SPIACalcClient(selectBinding, selectEndPoint);
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
                    output = client.RunQuote(ref inProps);
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
