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
*  20140611-015-01  SAP   10/10/16    Added new Ens API
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;


namespace PDMA.LifePro
{

    public partial class EnsAPIClient : System.ServiceModel.ClientBase<PDMA.LifePro.IEnsAPI>, PDMA.LifePro.IEnsAPI
    {


        public EnsAPIClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.EnsResponse RunENSFunction(PDMA.LifePro.EnsRequest inProps)
        {
            return base.Channel.RunENSFunction(inProps);
        }
    }


    public class EnsService : PDMA.LifePro.IEnsService
    {

        public static APIListener api32HH;
        public EnsAPIClient client;

        public EnsResponse RunENSFunction(EnsRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            EnsResponse outProps = new EnsResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);

                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "EnsAPI", out selectBinding, out selectEndPoint);

                client = new EnsAPIClient(selectBinding, selectEndPoint);

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
                        client = new EnsAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.RunENSFunction(inProps);

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

    }
}
