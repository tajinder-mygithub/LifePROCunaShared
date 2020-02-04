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

    public partial class DatabaseClient : System.ServiceModel.ClientBase<PDMA.LifePro.IFileBtv>, PDMA.LifePro.IFileBtv
    {


        public DatabaseClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.BaseResponse ExecFunction(ref PDMA.LifePro.DatabaseRequest inProps)
        {
            if (inProps.Function == 03)
            {
                // Perform a pre-read here before an update.  Prior reads customer did using service are not 
                // preserved.  If the user wishes to locate a prior key value, the key buffers may be used, with the 
                // PassKeyValues flag set to "p", just as when doing a read.  Otherwise, the record indicated by 
                // the data buffer itself will locate the record.  if found, the update may proceed.  

                inProps.Function = 05;
                // We do not want to lose updates, so copy DataArea.  
                byte[] dataBuffer = (byte []) inProps.DataBuffer.Clone(); 
                BaseResponse tempResponse = base.Channel.ExecFunction(ref inProps);
                inProps.DataBuffer = dataBuffer;
                inProps.Function = 03;

                if (tempResponse.ReturnCode != 0)
                    return tempResponse; 

            }

            return base.Channel.ExecFunction(ref inProps);
        }

        public PDMA.LifePro.BaseResponse FindFileNumber(ref PDMA.LifePro.DatabaseRequest inProps)
        {
            return base.Channel.FindFileNumber(ref inProps);
        }

        public PDMA.LifePro.BaseResponse FindFileLength(ref PDMA.LifePro.DatabaseRequest inProps)
        {
            return base.Channel.FindFileLength(ref inProps);
        }

    }
    
    
    public class DatabaseService : IDatabaseService
	{
		
        public static APIListener api32HH; 
        public DatabaseClient client; 

		public BaseResponse ExecFunction (ref DatabaseRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {

                assignedPort = DatabaseInitSteps(inProps, ref message, ref output);
                if (output.ReturnCode == 0)
                    output = client.ExecFunction(ref inProps);

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

        public BaseResponse FindFileNumber(ref DatabaseRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {

                assignedPort = DatabaseInitSteps(inProps, ref message, ref output);
                if (output.ReturnCode == 0)
                    output = client.FindFileNumber(ref inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

            }
            catch (Exception ex)
            {
                output.ReturnCode = 9999;
                output.ErrorMessage = ex.Message;

            }

            return output;

        }

        public BaseResponse FindFileLength(ref DatabaseRequest inProps)
        {

            int assignedPort;
            string message = "";
            BaseResponse output = new BaseResponse();
            try
            {

                assignedPort = DatabaseInitSteps(inProps, ref message, ref output);
                if (output.ReturnCode == 0)
                    output = client.FindFileLength(ref inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);

            }
            catch (Exception ex)
            {
                output.ReturnCode = 9999;
                output.ErrorMessage = ex.Message;

            }

            return output;

        }


        
        
        private int DatabaseInitSteps(DatabaseRequest inProps, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "FileBtv", out selectBinding, out selectEndPoint);

            client = new DatabaseClient(selectBinding, selectEndPoint);

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
                    client = new DatabaseClient(selectBinding, selectEndPoint);
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
