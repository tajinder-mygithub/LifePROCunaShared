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
*  20050504-004-01   DAR   02/16/06    Initial implementation  
*  20060713-004-01   DAR   07/19/06    Changes to handle strong named assemblies
*  20101008-003-01   DAR   09/01/10    Implement "idle" session workers.  
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services  
*  20140129-005-01   JWS   03/05/14    SPIA Calculator
*  20140605-006-01   DAR   06/30/14    Use true machine name in WSDL transmission.  
*  20150311-012-32   DAR   10/03/16    Add support for Value Retrieve API
*/

using System;
//using System.Runtime.Remoting; 
//using System.Runtime.Remoting.Channels;
//using System.Runtime.Remoting.Channels.Tcp;

using System.ServiceModel;
using System.ServiceModel.Description; 
using System.Diagnostics;


namespace PDMA.LifePro
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class APIHost
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		private const string STARTPROG = "APISessn.exe" ;
        private static string baseUri = "";
        private static string baseWSUri = "";  
        private static bool enableWebService = false; 
        private static string bindingType = "";
        private static int webServicePort = 0;
        private static bool enableWindowsAuthentication = false;
        private static bool enableSecureSockets = false; 
        public static APIListener apiListener = null; 
		
		[STAThread]
		static void Main(string[] args)
		{

            //System.Threading.Thread.Sleep(15000); 

			string usage = "Parameters for API32HH are HOSTPORT, CHILDFIRSTPORT, CHILDLASTPORT, CHILDSESSIONLIMIT, CHILDMINIMUMWORKERS, ENABLEWEBSERVICE, BINDINGTYPE, WEBSERVICEPORT, ENABLEWINDOWSAUTHENTICATION, ENABLESECURESOCKETS " ; 
			string stopping = "API32HH is stopping because of a problem, see the following message: " ; 
			if (args.Length < 10 ) {
				Log.AddLogEntry(stopping + "\n" + usage); 
				Log.AddLogEntry("Number of parms received is: " + args.Length.ToString());  
				foreach (string arg in args) 
					Log.AddLogEntry("Arg is " + arg);  

				return ; 
			}
				
            //string envID = "" ; 
            //if (args.Length > 10) 
            //    envID = args[10] ; 


			int listenPort, firstPort, lastPort, sessionLimit, minimumWorkers ;

			try {
				listenPort = Int32.Parse(args[0]); 
				firstPort = Int32.Parse(args[1]); 
				lastPort = Int32.Parse(args[2]); 
				sessionLimit = Int32.Parse(args[3]);
                minimumWorkers = Int32.Parse(args[4]);
                enableWebService = (args[5].Trim() == "YES") ? true : false;  
                bindingType = args[6].Trim();
                webServicePort = Int32.Parse(args[7]); 
                enableWindowsAuthentication = (args[8].Trim() == "YES") ? true : false ; 
                enableSecureSockets = (args[9].Trim() == "YES") ? true : false ; 

			}
			catch {
				listenPort = firstPort = lastPort =  sessionLimit= minimumWorkers = 0; 
				Log.AddLogEntry(stopping + "\n" + usage); 
				return ; 
			}

			try { 


				apiListener = new APIListener(); 
				//APIListener.ID = envID ; 

				// The PROGRAMS environment variable contains StartPath, and is also used in LifePRO. 
				APIListener.StartPath = Environment.GetEnvironmentVariable("PROGRAMS");
				APIListener.StartProgram = STARTPROG ;  // A constant for now. 
				APIListener.FirstPort = firstPort ; 
				APIListener.LastPort = lastPort ; 
				APIListener.SessionLimit = sessionLimit ;
                APIListener.MinimumWorkers = minimumWorkers;
                APIListener.EnableWebService = enableWebService;
                APIListener.WebServicePort = webServicePort; 
                APIListener.BindingType = bindingType;  
                APIListener.EnableWindowsAuthentication = enableWindowsAuthentication ;  
                APIListener.EnableSecureSockets = enableSecureSockets ; 

				int ports = lastPort - firstPort + 1 ; 
				APIListener.CountPerPort = new int[ports] ; 
				APIListener.PidPerPort = new int[ports];
				APIListener.ProcessReferences = new Process[ports];

                //TcpChannel listenerChannel = new TcpChannel(listenPort);
                //ChannelServices.RegisterChannel(listenerChannel);

                APIListener.LaunchIdleWorkers(); 

                //RemotingServices.Marshal(apiListener, "APIListener");

                //if (bindingType.ToUpper() == "WSHTTP")
                //    baseUri = @"http://localhost:" + listenPort.ToString() + "/LifeProAPI/";
                //else   

                baseUri = @"net.tcp://localhost:" + listenPort.ToString() + "/LifeProAPI/";
                

                // 20140605-006-01:  Changed server name in below references from hard coded "localhost" to machine name, 
                // to improve value of the address given back in WSDL transmissions.  
                if (enableSecureSockets) 
                    //baseWSUri = @"https://localhost:" + webServicePort.ToString() + "/LifeProAPI/";
                    baseWSUri = @"https://" + Environment.MachineName + ":" + webServicePort.ToString() + "/LifeProAPI/";
                else
                    //baseWSUri = @"http://localhost:" + webServicePort.ToString() + "/LifeProAPI/";
                    baseWSUri = @"http://" + Environment.MachineName + ":" + webServicePort.ToString() + "/LifeProAPI/";    
                // End 20140605-006-01 change.  



                Type serviceType = null;
                Type iserviceType = null;

                //serviceType = typeof(APIListener);
                iserviceType = typeof(IAPIListener);
                serviceType = typeof(APIListener); 
                //AddSingletonService("APIListener", iserviceType);
                // Try a non-singleton approach using static items to see if this speeds 
                // access.  
                AddTcpServiceWithEndPoint("APIListener", serviceType, iserviceType);  

                if (enableWebService)
                {

                    // This provides a web service that is stateless and supports basic HTTP binding at the port given by HostPort. 
                    NameService.api32HH = apiListener;
                    serviceType = typeof(NameService);
                    iserviceType = typeof(INameService);
                    AddHttpServiceWithEndPoint("NameService", serviceType, iserviceType);

                    AddressService.api32HH = apiListener;
                    serviceType = typeof(AddressService);
                    iserviceType = typeof(IAddressService);
                    AddHttpServiceWithEndPoint("AddressService", serviceType, iserviceType);

                    SurrenderQuoteService.api32HH = apiListener;
                    serviceType = typeof(SurrenderQuoteService);
                    iserviceType = typeof(ISurrenderQuoteService);
                    AddHttpServiceWithEndPoint("SurrenderQuoteService", serviceType, iserviceType);

                    BalanceInquiryService.api32HH = apiListener;
                    serviceType = typeof(BalanceInquiryService);
                    iserviceType = typeof(IBalanceInquiryService);
                    AddHttpServiceWithEndPoint("BalanceInquiryService", serviceType, iserviceType);

                    DepositAllocationService.api32HH = apiListener;
                    serviceType = typeof(DepositAllocationService);
                    iserviceType = typeof(IDepositAllocationService);
                    AddHttpServiceWithEndPoint("DepositAllocationService", serviceType, iserviceType);

                    LoanQuoteService.api32HH = apiListener;
                    serviceType = typeof(LoanQuoteService);
                    iserviceType = typeof(ILoanQuoteService);
                    AddHttpServiceWithEndPoint("LoanQuoteService", serviceType, iserviceType);

                    PolicyInquiryService.api32HH = apiListener;
                    serviceType = typeof(PolicyInquiryService);
                    iserviceType = typeof(IPolicyInquiryService);
                    AddHttpServiceWithEndPoint("PolicyInquiryService", serviceType, iserviceType);

                    PolicyListService.api32HH = apiListener;
                    serviceType = typeof(PolicyListService);
                    iserviceType = typeof(IPolicyListService);
                    AddHttpServiceWithEndPoint("PolicyListService", serviceType, iserviceType);


                    PremiumQuoteService.api32HH = apiListener;
                    serviceType = typeof(PremiumQuoteService);
                    iserviceType = typeof(IPremiumQuoteService);
                    AddHttpServiceWithEndPoint("PremiumQuoteService", serviceType, iserviceType);

                    AgentService.api32HH = apiListener;
                    serviceType = typeof(AgentService);
                    iserviceType = typeof(IAgentService);
                    AddHttpServiceWithEndPoint("AgentService", serviceType, iserviceType);

                    DatabaseService.api32HH = apiListener;
                    serviceType = typeof(DatabaseService);
                    iserviceType = typeof(IDatabaseService);
                    AddHttpServiceWithEndPoint("DatabaseService", serviceType, iserviceType);

                    IllustrationInputService.api32HH = apiListener;
                    serviceType = typeof(IllustrationInputService);
                    iserviceType = typeof(IIllustrationInputService);
                    AddHttpServiceWithEndPoint("IllustrationInputService", serviceType, iserviceType);

                    MultipleInsuredQuoteService.api32HH = apiListener;
                    serviceType = typeof(MultipleInsuredQuoteService);
                    iserviceType = typeof(IMultipleInsuredQuoteService);
                    AddHttpServiceWithEndPoint("MultipleInsuredQuoteService", serviceType, iserviceType);

                    CreditInsuranceNewBusinessService.api32HH = apiListener;
                    serviceType = typeof(CreditInsuranceNewBusinessService);
                    iserviceType = typeof(ICreditInsuranceNewBusinessService);
                    AddHttpServiceWithEndPoint("CreditInsuranceNewBusinessService", serviceType, iserviceType);

                    DisclosureQuoteService.api32HH = apiListener;
                    serviceType = typeof(DisclosureQuoteService);
                    iserviceType = typeof(IDisclosureQuoteService);
                    AddHttpServiceWithEndPoint("DisclosureQuoteService", serviceType, iserviceType);

                    DeathQuoteService.api32HH = apiListener;
                    serviceType = typeof(DeathQuoteService);
                    iserviceType = typeof(IDeathQuoteService);
                    AddHttpServiceWithEndPoint("DeathQuoteService", serviceType, iserviceType);

                    TerminatePolicyBenefitService.api32HH = apiListener;
                    serviceType = typeof(TerminatePolicyBenefitService);
                    iserviceType = typeof(ITerminatePolicyBenefitService);
                    AddHttpServiceWithEndPoint("TerminatePolicyBenefitService", serviceType, iserviceType);

                    RMDQuoteService.api32HH = apiListener;
                    serviceType = typeof(RMDQuoteService);
                    iserviceType = typeof(IRMDQuoteService);
                    AddHttpServiceWithEndPoint("RMDQuoteService", serviceType, iserviceType);

                    PremiumIllustrationService.api32HH = apiListener;
                    serviceType = typeof(PremiumIllustrationService);
                    iserviceType = typeof(IPremiumIllustrationService);
                    AddHttpServiceWithEndPoint("PremiumIllustrationService", serviceType, iserviceType);

                    ProposalService.api32HH = apiListener;
                    serviceType = typeof(ProposalService);
                    iserviceType = typeof(IProposalService);
                    AddHttpServiceWithEndPoint("ProposalService", serviceType, iserviceType);

                    SystematicRequestService.api32HH = apiListener;
                    serviceType = typeof(SystematicRequestService);
                    iserviceType = typeof(ISystematicRequestService);
                    AddHttpServiceWithEndPoint("SystematicRequestService", serviceType, iserviceType);

                    HealthBenefitQuoteService.api32HH = apiListener;
                    serviceType = typeof(HealthBenefitQuoteService);
                    iserviceType = typeof(IHealthBenefitQuoteService);
                    AddHttpServiceWithEndPoint("HealthBenefitQuoteService", serviceType, iserviceType);

                    CommissionControlService.api32HH = apiListener;
                    serviceType = typeof(CommissionControlService);
                    iserviceType = typeof(ICommissionControlService);
                    AddHttpServiceWithEndPoint("CommissionControlService", serviceType, iserviceType);

                    SPIACalcService.api32HH = apiListener;
                    serviceType = typeof(SPIACalcService);
                    iserviceType = typeof(ISPIACalcService);
                    AddHttpServiceWithEndPoint("SPIACalcService", serviceType, iserviceType);

                    ValueRetrieveService.api32HH = apiListener;
                    serviceType = typeof(ValueRetrieveService);
                    iserviceType = typeof(IValueRetrieveService);
                    AddHttpServiceWithEndPoint("ValueRetrieveService", serviceType, iserviceType);

                    EnsService.api32HH = apiListener;
                    serviceType = typeof(EnsService);
                    iserviceType = typeof(IEnsService);
                    AddHttpServiceWithEndPoint("EnsService", serviceType, iserviceType);

                }


			} 
			catch (Exception e) {
				Log.AddLogEntry(stopping + "\n" + e.Message ); 
				return ; 
				
			}

			Console.ReadLine() ;
		}

        public static void AddSingletonService(string typeDesc,  Type iserviceType)
        {


            Uri address = new Uri(baseUri + typeDesc);
           
            ServiceHost service = new ServiceHost(apiListener, address);
            var behaviour = service.Description.Behaviors.Find<ServiceBehaviorAttribute>();
            behaviour.InstanceContextMode = InstanceContextMode.Single;

            System.ServiceModel.Channels.Binding selectBinding;
            selectBinding = new NetTcpBinding();

            selectBinding.OpenTimeout = TimeSpan.MaxValue;
            selectBinding.CloseTimeout = TimeSpan.MaxValue;
            selectBinding.SendTimeout = TimeSpan.MaxValue;
            selectBinding.ReceiveTimeout = TimeSpan.MaxValue;

            service.AddServiceEndpoint(iserviceType, selectBinding, address);

            service.Open();


        }


        public static void AddTcpServiceWithEndPoint(string typeDesc, Type serviceType, Type iserviceType)
        {


            Uri address = new Uri(baseUri + typeDesc);

            ServiceHost service = new ServiceHost(serviceType, address);

            ServiceDebugBehavior debug = service.Description.Behaviors.Find<ServiceDebugBehavior>();
            if (debug == null)
                service.Description.Behaviors.Add(new ServiceDebugBehavior() { IncludeExceptionDetailInFaults = true });
            else
                if (!debug.IncludeExceptionDetailInFaults)
                    debug.IncludeExceptionDetailInFaults = true;


            System.ServiceModel.Channels.Binding selectBinding;
            selectBinding = new NetTcpBinding();

            selectBinding.OpenTimeout = TimeSpan.MaxValue;
            selectBinding.CloseTimeout = TimeSpan.MaxValue;
            selectBinding.SendTimeout = TimeSpan.MaxValue;
            selectBinding.ReceiveTimeout = TimeSpan.MaxValue;

            ((NetTcpBinding)selectBinding).MaxReceivedMessageSize = Int32.MaxValue;
            ((NetTcpBinding)selectBinding).MaxBufferSize = Int32.MaxValue;
            ((NetTcpBinding)selectBinding).MaxBufferPoolSize = Int32.MaxValue; 

            service.AddServiceEndpoint(iserviceType, selectBinding, address);

            service.Open();


        }


        public static void AddHttpServiceWithEndPoint(string typeDesc, Type serviceType, Type iserviceType)
        {

            try
            {

                Uri address = new Uri(baseWSUri + typeDesc);

                ServiceHost service = new ServiceHost(serviceType, address);
                ServiceDebugBehavior debug = service.Description.Behaviors.Find<ServiceDebugBehavior>();
                if (debug == null)
                    service.Description.Behaviors.Add(new ServiceDebugBehavior() { IncludeExceptionDetailInFaults = true });
                else
                    if (!debug.IncludeExceptionDetailInFaults)
                        debug.IncludeExceptionDetailInFaults = true;


                System.ServiceModel.Channels.Binding selectBinding;
                if (bindingType.ToUpper() == "WSHTTP")
                {
                    selectBinding = new WSHttpBinding();

                    if (enableSecureSockets)
                        ((WSHttpBinding)selectBinding).Security.Mode = System.ServiceModel.SecurityMode.Transport;
                    else
                        if (enableWindowsAuthentication)
                            ((WSHttpBinding)selectBinding).Security.Mode = System.ServiceModel.SecurityMode.Message;
                        else
                            ((WSHttpBinding)selectBinding).Security.Mode = System.ServiceModel.SecurityMode.None;

                    if (enableWindowsAuthentication)
                    {
                        ((WSHttpBinding)selectBinding).Security.Transport.ClientCredentialType = HttpClientCredentialType.Windows;
                        ((WSHttpBinding)selectBinding).Security.Message.ClientCredentialType = MessageCredentialType.Windows;
                    }
                    else
                    {
                        ((WSHttpBinding)selectBinding).Security.Transport.ClientCredentialType = HttpClientCredentialType.None;
                        ((WSHttpBinding)selectBinding).Security.Message.ClientCredentialType = MessageCredentialType.None;

                    }

                }
                else
                { 
                    selectBinding = new BasicHttpBinding();

                    // Certain types of message security are possible with Basic HTTP, but require manual use of certificates, etc., 
                    // and for now, we limit Basic HTTP to only use Transport security options.  If user wants message security, 
                    // they can configure WS HTTP with Windows authentication above.  

                    if (enableSecureSockets)
                        ((BasicHttpBinding)selectBinding).Security.Mode = BasicHttpSecurityMode.Transport;
                    else
                        if (enableWindowsAuthentication)
                            ((BasicHttpBinding)selectBinding).Security.Mode = BasicHttpSecurityMode.TransportCredentialOnly;
                        else
                            ((BasicHttpBinding)selectBinding).Security.Mode = BasicHttpSecurityMode.None; 

                    if (enableWindowsAuthentication)
                        ((BasicHttpBinding)selectBinding).Security.Transport.ClientCredentialType = HttpClientCredentialType.Windows;
                    else
                        ((BasicHttpBinding)selectBinding).Security.Transport.ClientCredentialType = HttpClientCredentialType.None;

                }

                selectBinding.OpenTimeout = TimeSpan.MaxValue;
                selectBinding.CloseTimeout = TimeSpan.MaxValue;
                selectBinding.SendTimeout = TimeSpan.MaxValue;
                selectBinding.ReceiveTimeout = TimeSpan.MaxValue;

                if (bindingType.ToUpper() == "WSHTTP")
                {
                    ((WSHttpBinding)selectBinding).MaxReceivedMessageSize = Int32.MaxValue;
                    ((WSHttpBinding)selectBinding).MaxBufferPoolSize = Int32.MaxValue;
                }
                else
                {
                    ((BasicHttpBinding)selectBinding).MaxReceivedMessageSize = Int32.MaxValue;
                    ((BasicHttpBinding)selectBinding).MaxBufferSize = Int32.MaxValue;
                    ((BasicHttpBinding)selectBinding).MaxBufferPoolSize = Int32.MaxValue;
                }

                service.AddServiceEndpoint(iserviceType, selectBinding, address);

                ServiceMetadataBehavior smb = new ServiceMetadataBehavior();
                if (enableSecureSockets)
                    smb.HttpsGetEnabled = true;
                else
                    smb.HttpGetEnabled = true;
                service.Description.Behaviors.Add(smb);

                service.Open();
            }

            catch (Exception ex)
            {
                Log.AddLogEntry("A problem occurred starting a web-based service.  This does not prevent LPREMAPI.DLL calls from working, but will prevent web-based calls " +
                                "from working for the following service: " + typeDesc + ".  The system error description is " + ex.Message);  

            }


        }




	}
}
