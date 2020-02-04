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
*  20151221-010-01  SAP   06/28/16    Added Foreign Tax ID
*  20161201-003-01   ABH   01/02/17   Added field Personal and Business Emails
*/


using System;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
	/// <summary>
	/// The LifePRO Name WS object, which allows inquiry and updates of the PNAME and related tables, using a Web Service interface.  
	/// </summary>

    public partial class NameAPIClient : System.ServiceModel.ClientBase<PDMA.LifePro.INameAPI>, PDMA.LifePro.INameAPI
    {

        //public NameAPIClient()
        //{
        //}

        //public NameAPIClient(string endpointConfigurationName) :
        //    base(endpointConfigurationName)
        //{
        //}

        //public NameAPIClient(string endpointConfigurationName, string remoteAddress) :
        //    base(endpointConfigurationName, remoteAddress)
        //{
        //}

        //public NameAPIClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) :
        //    base(endpointConfigurationName, remoteAddress)
        //{
        //}

        public NameAPIClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) :
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

        public PDMA.LifePro.NameResponse RunNameFunction(PDMA.LifePro.NameRequest inProps)
        {

            if (inProps.UpdateQueryFlag == "U")
            {
                string saveIndividualPrefix = inProps.UpdateIndividualPrefix;
                string saveIndividualFirstName = inProps.UpdateIndividualFirstName;
                string saveIndividualMiddleName = inProps.UpdateIndividualMiddleName;
                string saveIndividualLastName = inProps.UpdateIndividualLastName;
                string saveIndividualSuffix = inProps.UpdateIndividualSuffix;
                int saveIndividualSSN = inProps.UpdateIndividualSSN;
                string saveBusinessPrefix = inProps.UpdateBusinessPrefix;
                string saveBusinessName = inProps.UpdateBusinessName;
                string saveBusinessSuffix = inProps.UpdateBusinessSuffix;
                string saveBusinessTaxID = inProps.UpdateBusinessTaxID;
                int saveNameDateOfBirth = inProps.UpdateNameDateOfBirth;
                string saveNameGender = inProps.UpdateNameGender;
                string saveForeignTaxID = inProps.UpdateForeignTaxID;
                //20161201-003-01
                string savePersonalEmail = inProps.UpdatePersonalEmail;
                string saveBusinessEmail = inProps.UpdateBusinessEmail;
                //20161201-003-01

                inProps.UpdateQueryFlag = "Q";
                NameResponse temp = base.Channel.RunNameFunction(inProps);

                if (temp.ReturnCode != 0)
                    return temp;
                else
                {
                    inProps.UpdateQueryFlag = "U";  
                    inProps.UpdateIndividualPrefix = saveIndividualPrefix;
                    inProps.UpdateIndividualFirstName = saveIndividualFirstName;
                    inProps.UpdateIndividualMiddleName = saveIndividualMiddleName;
                    inProps.UpdateIndividualLastName = saveIndividualLastName;
                    inProps.UpdateIndividualSuffix = saveIndividualSuffix;
                    inProps.UpdateIndividualSSN = saveIndividualSSN;
                    inProps.UpdateBusinessPrefix = saveBusinessPrefix;
                    inProps.UpdateBusinessName = saveBusinessName;
                    inProps.UpdateBusinessSuffix = saveBusinessSuffix;
                    inProps.UpdateBusinessTaxID = saveBusinessTaxID;
                    inProps.UpdateNameDateOfBirth = saveNameDateOfBirth;
                    inProps.UpdateNameGender = saveNameGender;
                    inProps.UpdateForeignTaxID = saveForeignTaxID;
                    //20161201-003-01
                    inProps.UpdatePersonalEmail = savePersonalEmail;
                    inProps.UpdateBusinessEmail = saveBusinessEmail;
                    //20161201-003-01

                    return base.Channel.RunNameFunction(inProps); 

                }

            }

            return base.Channel.RunNameFunction(inProps);
        }
    }
    
    
    public class NameService : INameService
	{
		
        public static APIListener api32HH; 
        public NameAPIClient client; 

		public NameResponse RunNameFunction (NameRequest inProps ) 
		{

            int assignedPort; 
            string message = "";
            BaseResponse output = new BaseResponse();
            NameResponse outProps = new NameResponse();
            try
            {

                int rc = api32HH.StartSession(out assignedPort, out message);
                    
                System.ServiceModel.Channels.Binding selectBinding;
                EndpointAddress selectEndPoint;

                Util.DetermineBinding(assignedPort, "NameAPI", out selectBinding, out selectEndPoint);   

                client = new NameAPIClient(selectBinding, selectEndPoint);

                bool isAvailable = false;
                int attempts = 0; 

                // It takes a moment for APISessn.exe to become available.  Loop a few times 
                // on errors to give it a chance to become available.  We might refine this 
                // to look for the specific error that occurs.  
                while (!isAvailable && attempts < 20)
                {
                    try
                    {
                        output = client.Init(inProps.UserType);
                        isAvailable = true;  
                    }

                    catch (Exception ex)
                    {

                        client = new NameAPIClient(selectBinding, selectEndPoint);
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
                    outProps = client.RunNameFunction(inProps);

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
	
	
	}
}
