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
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/


using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
    public static class Util
    {
        public static string Format(string inStr) 
        {
            if (inStr == null)
                return "";
            else
                return inStr.Trim(); 

        }


        public static void DetermineBinding(int assignedPort, string apiName, out System.ServiceModel.Channels.Binding selectBinding, out System.ServiceModel.EndpointAddress selectEndPoint)  
        {

            selectBinding = new NetTcpBinding();
            selectEndPoint = new EndpointAddress(@"net.tcp://127.0.0.1:" + assignedPort.ToString() + @"/LifeProAPI/" + apiName );
            selectBinding.OpenTimeout = TimeSpan.MaxValue;
            selectBinding.CloseTimeout = TimeSpan.MaxValue;
            selectBinding.SendTimeout = TimeSpan.MaxValue;
            selectBinding.ReceiveTimeout = TimeSpan.MaxValue;
            ((NetTcpBinding)selectBinding).MaxReceivedMessageSize = Int32.MaxValue;
            ((NetTcpBinding)selectBinding).MaxBufferSize = Int32.MaxValue;
            ((NetTcpBinding)selectBinding).MaxBufferPoolSize = Int32.MaxValue; 

        }


    }
}
