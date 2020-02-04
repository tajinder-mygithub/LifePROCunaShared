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
	/// The LifePRO Deposit Allocation Service object, which allows inquiry on and update of Deposit Allocation information.  
	/// </summary>

    public partial class ProposalClient : System.ServiceModel.ClientBase<PDMA.LifePro.IProposl>, PDMA.LifePro.IProposl
    {


        public ProposalClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public void AcceptSurrenderQuote(PDMA.LifePro.ISurQuote inQuote)
        {
            base.Channel.AcceptSurrenderQuote(inQuote); 
        }

        public void AcceptDeathQuote(PDMA.LifePro.IDthQuote inQuote)
        {
            base.Channel.AcceptDeathQuote(inQuote);
        }

        public string LoadTradTable()
        {
            return base.Channel.LoadTradTable();
        }

        public string LoadUlTable()
        {

            return base.Channel.LoadUlTable(); 
        }

        public PDMA.LifePro.ProposalRequest InitFutrTable (PDMA.LifePro.ProposalRequest inProps)
        {
            return base.Channel.InitFutrTable(inProps);
        }

        public PDMA.LifePro.ProposalRequest IndexPremium(PDMA.LifePro.ProposalRequest inProps)
        {
            return base.Channel.IndexPremium(inProps);
        }

        public PDMA.LifePro.ProposalRequest LoadExistingPolicy(string company, string policy, int effectivedate, out int returncode, out string message)
        {
            return base.Channel.LoadExistingPolicy(company, policy, effectivedate, out returncode, out message);
        }


        public PDMA.LifePro.ProposalResponse RunProposal(PDMA.LifePro.ProposalRequest inProps)
        {

            // We create a temporary input block that can be discarded.  The actual udpate should attempt 
            // to use the inputs the user provided.  

            int returncode = 0 ; 
            string message = "";   

            ProposalRequest discardRequest ; 
            if (inProps.Function == "R")  // This is throwaway ... only done to initialize underlying COBOL programs. 
                discardRequest = base.Channel.LoadExistingPolicy (inProps.CompanyCode, inProps.PolicyNumber, inProps.EffectiveDate, out returncode, out message);

            if (returncode == 0)
                return base.Channel.RunProposal(inProps);
            else
            {
                ProposalResponse response = new ProposalResponse();
                response.ReturnCode = returncode;
                response.ErrorMessage = message;   
                return response ;  
            }
        }

        

    }
    
    
    public class ProposalService : IProposalService
	{
		
        public static APIListener api32HH; 
        public ProposalClient client; 

		public ProposalResponse RunProposal (ProposalRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            ProposalResponse outProps = new ProposalResponse();
            try
            {

                assignedPort = ProposalInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    outProps.ReturnCode = output.ReturnCode;
                    outProps.ErrorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.RunProposal(inProps);

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

		public ProposalRequest InitFutrTable (ProposalRequest inProps, out int returncode, out string errorMessage ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            ProposalRequest outProps = new ProposalRequest();
            returncode = 0;
            errorMessage = ""; 
            try
            {

                assignedPort = ProposalInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    returncode = output.ReturnCode;
                    errorMessage = output.ErrorMessage;
                }
                else 
                    outProps = client.InitFutrTable(inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {

                returncode = 9999;
                errorMessage = ex.Message;

            }
			
   			return outProps ; 
		
		}

		public ProposalRequest IndexPremium (ProposalRequest inProps, out int returncode, out string message ) 
		{

            int assignedPort;
            returncode = 0;  
            message = "";
            BaseResponse output = new BaseResponse();
            ProposalRequest outProps = new ProposalRequest();

            try
            {

                assignedPort = ProposalInitSteps(inProps.UserType, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    returncode = output.ReturnCode;
                    message = output.ErrorMessage;
                }
                else 
                    outProps = client.IndexPremium(inProps);

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                returncode = 9999;
                message = ex.Message;

            }
			
  			return outProps ; 
		}


		public ProposalRequest LoadExistingPolicy (string usertype, string company, string policy, int effectivedate, out int returncode, out string message ) 
		{

            int assignedPort; 
            message = "";
            BaseResponse output = new BaseResponse();
            ProposalRequest outProps = new ProposalRequest();
            try
            {

                assignedPort = ProposalInitSteps(usertype, ref message, ref output);

                if (output.ReturnCode != 0)
                {
                    returncode = output.ReturnCode;
                    message = output.ErrorMessage;
                }
                else
                {
                    outProps = client.LoadExistingPolicy(company, policy, effectivedate, out returncode, out message);
                    // Make sure the request object receives these basic inputs passed in.  
                    outProps.UserType = usertype;
                    outProps.Function = "R";
                    outProps.CompanyCode = company;
                    outProps.PolicyNumber = policy; 

                }

                client.Dispose();
                api32HH.EndSession(assignedPort, out message);      

            }
            catch (Exception ex)
            {
                returncode = 9999;
                message = ex.Message;

            }
			
   			return outProps ; 
		}


        private int ProposalInitSteps(string usertype, ref string message, ref BaseResponse output)
        {
            int assignedPort;
            int rc = api32HH.StartSession(out assignedPort, out message);

            System.ServiceModel.Channels.Binding selectBinding;
            EndpointAddress selectEndPoint;

            Util.DetermineBinding(assignedPort, "Proposl", out selectBinding, out selectEndPoint);

            client = new ProposalClient(selectBinding, selectEndPoint);

            bool isAvailable = false;
            int attempts = 0;
            while (!isAvailable && attempts < 20)
            {
                try
                {
                    output = client.Init(usertype);
                    isAvailable = true;
                }

                catch (Exception ex)
                {
                    client = new ProposalClient(selectBinding, selectEndPoint);
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
