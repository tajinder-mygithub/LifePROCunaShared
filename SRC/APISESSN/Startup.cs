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
*  20060713-004-01   DAR   07/19/06    14.0 Base changes/additions
*  20060818-015-01   DAR   03/31/08    Credit Insurance New Business
*  20101008-003-01   WAR   07/16/2010  Disclosure Quote and Prem Illustration
*  20111205-001-01   DAR   02/23/2012  TerminatePolicyBenefit API 
*  20111117-006-01   DAR   05/25/2012  Retrofit 20111205-001-01
*  20111013-006-07   DAR   10/11/2012  Added RMD Quote 
*  20130226-004-01   DAR   03/31/2013  Add Commission Control API 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20140129-005-01   JWS   03/05/2014  Added SPIA Calculator
*  20140318-009-01   TJO   04/13/15    Add GWBN amounts to Death Quote API 
*  20141110-007-08   TJO   12/04/15    Add ABV description   
*  20150311-012-32   DAR   09/28/16    Add Value Retrieve API
*  20140611-015-01   SAP   10/10/16    Added Ens API  
*/


using System;
using System.Threading; 
using System.Collections;
using System.ServiceModel;
using System.ServiceModel.Description;
using LPNETAPI ; 

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for Startup
	/// </summary>
	class Startup
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		/// 

		public static OAPPLICA apiApp ;

        public static string baseUri = "";
        private static int iPort = 0; 
        
		static void Main(string[] args)
		{
			// Environment variables will be set coming in that define certain values, 
			// others come in as input parameters.  

            //Thread.Sleep(15000); 
			
			string sport = args[0]; 
			//Log.AddLogEntry("Input port is: " + sport) ; 
			
			iPort = Int32.Parse(sport);

			apiApp = new OAPPLICA();  

			string progPath = Environment.GetEnvironmentVariable("PROGRAMS"); 
			if (progPath == null) 
				progPath = "" ; 
			string workPath = Environment.GetEnvironmentVariable("WORKAREA"); 
			if (workPath == null) 
				workPath = "" ; 
			string imagePath = Environment.GetEnvironmentVariable("IMAGE"); 
			if (imagePath == null) 
				imagePath = "" ; 

			string path = Environment.GetEnvironmentVariable("PATH"); 
			string odbcInf = Environment.GetEnvironmentVariable("@ODBC_INF") ; 
			string sqldatasrc = Environment.GetEnvironmentVariable("SQL_DATASRC"); 


			apiApp.setProgramDrive(progPath);
			apiApp.setWorkareaDrive(workPath);
			apiApp.setImageDrive(imagePath);

            //Thread.Sleep(30000);   

			int rc = apiApp.InitData();

			SurQuote.apiApp = apiApp ; 
			PolcLst.apiApp = apiApp ; 
			PolcAPI.apiApp = apiApp ; 
			NameAPI.apiApp = apiApp ; 
			AddrAPI.apiApp = apiApp ; 
			PrmQuote.apiApp = apiApp ; 
			BalInqu.apiApp = apiApp ; 
			DepAllc.apiApp = apiApp ; 
			LonQuote.apiApp = apiApp ; 
			Proposl.apiApp = apiApp ; 
			SysRqst.apiApp = apiApp ; 
			FileBtv.apiApp = apiApp ; 
			AiefApi.apiApp = apiApp ;
			IllInp.apiApp = apiApp ;  
			MultQuote.apiApp = apiApp;  
            HealthCalc.apiApp = apiApp ;
            CINewBs.apiApp = apiApp;  
            DthQuote.apiApp = apiApp; 
            PremIllus.apiApp = apiApp; 
            DiscQuote.apiApp = apiApp;
            TerminatePolicyBenefit.apiApp = apiApp;   
            RMDQuote.apiApp = apiApp;  
            CommissionControl.apiApp = apiApp;  
            SPIACalcApi.apiApp = apiApp;
            ValueRetrieve.apiApp = apiApp;
            EnsAPI.apiApp = apiApp;

			try { 

				IDictionary props = new Hashtable();
				props["port"] = iPort;

                baseUri = @"net.tcp://localhost:" + iPort.ToString() + "/LifeProAPI/";

                Type serviceType = null;
                Type iserviceType = null;

                serviceType = typeof(NameAPI);
                iserviceType = typeof(INameAPI);
                AddServiceWithEndPoint("NameAPI", serviceType, iserviceType);

                serviceType = typeof(SurQuote);
                iserviceType = typeof(ISurQuote);  
                AddServiceWithEndPoint("SurQuote", serviceType, iserviceType);

                serviceType = typeof(PolcLst);
                iserviceType = typeof(IPolcLst);   
                AddServiceWithEndPoint("PolcLst", serviceType, iserviceType);

                serviceType = typeof(PolcAPI);
                iserviceType = typeof(IPolcAPI);  
                AddServiceWithEndPoint("PolcAPI", serviceType, iserviceType);


                serviceType = typeof(AddrAPI);
                iserviceType = typeof(IAddrAPI);
                AddServiceWithEndPoint("AddrAPI", serviceType, iserviceType);

                serviceType = typeof(PrmQuote);
                iserviceType = typeof(IPrmQuote);
                AddServiceWithEndPoint("PrmQuote", serviceType, iserviceType);

                serviceType = typeof(BalInqu);
                iserviceType = typeof(IBalInqu);
                AddServiceWithEndPoint("BalInqu", serviceType, iserviceType);

                serviceType = typeof(DepAllc);
                iserviceType = typeof(IDepAllc);
                AddServiceWithEndPoint("DepAllc", serviceType, iserviceType);

                serviceType = typeof(LonQuote);
                iserviceType = typeof(ILonQuote);
                AddServiceWithEndPoint("LonQuote", serviceType, iserviceType);

                serviceType = typeof(Proposl);
                iserviceType = typeof(IProposl);
                AddServiceWithEndPoint("Proposl", serviceType, iserviceType);

                serviceType = typeof(SysRqst);
                iserviceType = typeof(ISysRqst);
                AddServiceWithEndPoint("SysRqst", serviceType, iserviceType);

                serviceType = typeof(FileBtv);
                iserviceType = typeof(IFileBtv);
                AddServiceWithEndPoint("FileBtv", serviceType, iserviceType);

                serviceType = typeof(AiefApi);
                iserviceType = typeof(IAiefApi);
                AddServiceWithEndPoint("AiefApi", serviceType, iserviceType);

                serviceType = typeof(IllInp);
                iserviceType = typeof(IIllInp);
                AddServiceWithEndPoint("IllInp", serviceType, iserviceType);

                serviceType = typeof(MultQuote);
                iserviceType = typeof(IMultQuote);
                AddServiceWithEndPoint("MultQuote", serviceType, iserviceType);

                serviceType = typeof(HealthCalc);
                iserviceType = typeof(IHealthCalc);
                AddServiceWithEndPoint("HealthCalc", serviceType, iserviceType);

                serviceType = typeof(CINewBs);
                iserviceType = typeof(ICINewBs);
                AddServiceWithEndPoint("CINewBs", serviceType, iserviceType);

                serviceType = typeof(DthQuote);
                iserviceType = typeof(IDthQuote);
                AddServiceWithEndPoint("DthQuote", serviceType, iserviceType);

                serviceType = typeof(PremIllus);
                iserviceType = typeof(IPremIllus);
                AddServiceWithEndPoint("PremIllus", serviceType, iserviceType);

                serviceType = typeof(DiscQuote);
                iserviceType = typeof(IDiscQuote);
                AddServiceWithEndPoint("DiscQuote", serviceType, iserviceType);

                serviceType = typeof(TerminatePolicyBenefit);
                iserviceType = typeof(ITerminatePolicyBenefit);
                AddServiceWithEndPoint("TerminatePolicyBenefit", serviceType, iserviceType);

                serviceType = typeof(RMDQuote);
                iserviceType = typeof(IRMDQuote);
                AddServiceWithEndPoint("RMDQuote", serviceType, iserviceType);

                serviceType = typeof(CommissionControl);
                iserviceType = typeof(ICommissionControl);
                AddServiceWithEndPoint("CommissionControl", serviceType, iserviceType);

                serviceType = typeof(SPIACalcApi);
                iserviceType = typeof(ISPIACalc);
                AddServiceWithEndPoint("SPIACalcApi", serviceType, iserviceType);

                serviceType = typeof(ValueRetrieve);
                iserviceType = typeof(IValueRetrieve);
                AddServiceWithEndPoint("ValueRetrieve", serviceType, iserviceType);

                serviceType = typeof(EnsAPI);
                iserviceType = typeof(IEnsAPI);
                AddServiceWithEndPoint("EnsAPI", serviceType, iserviceType);

			}
			catch (Exception e) {
				
				Log.AddLogEntry("Unable to start SessionFactory object in APISessn with listener port " + sport + ".  Aborting program.  Message is: " + e.Message ) ; 
				return ; 
			}

			//Log.AddLogEntry("Next statement is ReadLine" ) ; 
			Console.ReadLine() ;

			// Because ReadLine runs forever, it doesn't get past this point.  
			// We should not need to explictly cancel channel (chnl), or call apiDispose (which only does a DB close), 
			// since both of these things happen automatically when this executable ends.  This process is ended
			// forcibly when API32HH cancels it, once it knows all sessions have been ended.  
		
		}

        public static void AddServiceWithEndPoint(string typeDesc, Type serviceType, Type iserviceType)
        {

            //Type serviceType = Type.GetType(typeDesc);
            //Type iServiceType = Type.GetType("i" + typeDesc); 

            Uri address = new Uri(baseUri + typeDesc); 
            //Uri address = new Uri(baseUri); 
            
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


	}
}
