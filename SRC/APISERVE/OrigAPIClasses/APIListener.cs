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
*  20061211-007-01   DAR   12/20/06    Check for successful start of APISessn
*  20101008-003-01   DAR   09/01/10    Implement "idle" session workers.  
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
 */


using System;
using System.Collections ; 
using System.Diagnostics;
using System.Threading; 
//using System.Runtime.Remoting; 
//using System.Runtime.Remoting.Channels;
//using System.Runtime.Remoting.Channels.Tcp;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.Net.NetworkInformation;  



namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for APIListener.
	/// </summary>
	public class APIListener :  IAPIListener  
	{
		// This class listens for requests, and starts APISessn instances, for one environment.  
		// All environment variables, path, etc., are created in the Thin Service before 
		// executing API32HH, which hosts this listener object.  
		
		public static string ID ;
        public static string StartPath, StartProgram;
        private static int activeSessions;

        public static int FirstPort;
        public static int LastPort;
        public static int SessionLimit;
        public static int MinimumWorkers;
        public static bool EnableWebService;
        public static string BindingType;
        public static int WebServicePort;
        public static bool EnableWindowsAuthentication;
        public static bool EnableSecureSockets;
        public static int[] CountPerPort;
        public static int[] PidPerPort;
        public static Process[] ProcessReferences;

        private static object thisLock = new object(); 

			
		public APIListener()
		{
		}

		public APIListenerInfo GetInfo () { 
			// Use a serializable class to return all port information to client.  Used in Admin utility. 

			APIListenerInfo apiInfo = new APIListenerInfo(); 
			apiInfo.FirstPort = FirstPort ; 
			apiInfo.LastPort = LastPort ; 
			apiInfo.SessionLimit = SessionLimit ; 
			apiInfo.CountPerPort = (int []) CountPerPort.Clone(); 
			apiInfo.PidPerPort = (int [] ) PidPerPort.Clone() ; 
			return apiInfo ; 
		}

        public static void GetAvailability ( out int activeWorkers, out int availableSlots) 
        {
            activeWorkers = 0;
            availableSlots = 0;

            for (int i = FirstPort; i < LastPort; i++)
            {
                int slot = i - FirstPort;
                if (ProcessReferences[slot] != null)
                    if (!ProcessReferences[slot].HasExited)
                        activeWorkers++;
                    else
                    {
                        ProcessReferences[slot] = null;
                        CountPerPort[slot] = 0;
                    }

                if (ProcessReferences[slot] == null)
                    availableSlots++;
            }



        }
        public static int LaunchIdleWorkers()
        
        {
            int activeWorkers, availableSlots;
            GetAvailability(out activeWorkers, out availableSlots);  

            if ((activeWorkers < MinimumWorkers) && 
                (availableSlots > 0))
            {

                int i = FirstPort;
                string message = "";  
                while (i < LastPort &&
                       activeWorkers < MinimumWorkers)
                {

                    int slot = i - FirstPort;
                    if (ProcessReferences[slot] == null)
                    {
                        if (IsPortAvailable(i))
                        {
                            int rc = RunAPISessn(i, out message);
                            if (rc == 0)
                            {
                                activeWorkers++;
                            }
                            else
                            {
                                // If a problem occurs starting APISessn, just log it here.  A failure starting 
                                // an idle worker is not critical.  
                                Log.AddLogEntry(message);
                            }
                        }
                    }
                    i++;  
                }
            }

            return 0; 
        }

        public static int RunAPISessn(int assignedPort, out string message)
        {
           
            Process procstart = new Process();

            procstart.StartInfo.FileName = StartPath + "\\" + StartProgram;
            procstart.StartInfo.UseShellExecute = false;
            procstart.StartInfo.CreateNoWindow = true;
            procstart.StartInfo.WorkingDirectory = StartPath;
            procstart.StartInfo.Arguments = assignedPort.ToString() + " " + BindingType;

            Log.AddLogEntry("About to start APISessn using port " + assignedPort.ToString());

            try
            {
                if (!(procstart.Start()))
                {
                    message = "Unable to start APISessn";
                    return 1;// Bad start of APISessn.exe 
                }
                else
                {
                    // Add a small wait so startup can complete before first attempt to access the module. 
                    bool success = true; 

                    // We are commenting out the following communication test because it serves little purpose, and slows  
                    // down the launching of additional APISessn modules.  The client (LPREMAPI) will also re-attempt communication 
                    // with APISessn, making several attempts over a period of seconds, if it fails on the first communication
                    // attempt, making this verification unnecessary.  

                    //Thread.Sleep(300);
                    //bool success = false;
                    //int tries = 0;
                    //while (!success && tries < 20)
                    //{
                    //    try
                    //    {
                    //        Uri serverUri = new Uri("tcp://" + "127.0.0.1" + ":" + assignedPort.ToString());
                    //        Uri apiUri = new Uri(serverUri, "SessionFactory");

                    //        ISessionFactory factory = (PDMA.LifePro.ISessionFactory)Activator.GetObject(typeof(PDMA.LifePro.ISessionFactory), apiUri.AbsoluteUri);
                    //        factory.GetInfo();
                    //        success = true;
                    //    }
                    //    catch
                    //    {
                    //        tries += 1;
                    //        Thread.Sleep(300);
                    //    }
                    //}

                    if (!success)
                    {
                        message = "Unable to verify that APISessn is available for connections.";
                        return 2; // Not able to verify that APISessn s
                    }

                }
            }
            catch (Exception e)
            {
                message = "Unable to start APISessn with " + e.Message;
                return 1; 
            }

            ProcessReferences[assignedPort - FirstPort] = procstart;
            PidPerPort[assignedPort - FirstPort] = procstart.Id; 

            message = "";  
            return 0;  
        }

        public static bool IsPortAvailable(int assignedPort)
        {
            try
            {

                IPGlobalProperties ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
                TcpConnectionInformation[] tcpConnInfoArray = ipGlobalProperties.GetActiveTcpConnections();

                foreach (TcpConnectionInformation tcpi in tcpConnInfoArray)
                {
                    if (tcpi.LocalEndPoint.Port == assignedPort)
                    {
                        return false;   
                    }
                }

            }
            catch 
            {
                return false; 

            }
            return true; 

        }

		public int StartSession (out int assignedPort, out string message) 
		{
			// Only allow one thread through this at a time. 
            lock (thisLock)
            {
                // This either launches a new APISessn, or maps the user to an existing port 
                int i;
                assignedPort = 0;
                string errorMessage;
                message = "";

                //TcpChannel chnl = null; 

                // Double check to see if all assigned processes are still running.  
                // If one was canceled or errored out, reset its counts so we can resue the port. 
                for (i = 0; i < LastPort - FirstPort; i++)
                    if (ProcessReferences[i] != null)
                    {
                        if (ProcessReferences[i].HasExited)
                        {
                            ProcessReferences[i] = null;
                            CountPerPort[i] = 0;

                        }
                    }
                    else
                        CountPerPort[i] = 0;

                // First try and find a running APISessn that still has more room.  This may not be 
                // at beginning of port list.  

                for (i = FirstPort; i <= LastPort; i++)
                {
                    if (ProcessReferences[i - FirstPort] != null &&
                        CountPerPort[i - FirstPort] < SessionLimit)
                    {
                        assignedPort = i;
                        break;
                    }
                }


                if (assignedPort == 0)
                    // If none assigned, seek any port, even though it will require running a new APISessn. 
                    for (i = FirstPort; i <= LastPort; i++)
                        if (CountPerPort[i - FirstPort] < SessionLimit)
                        {
                            assignedPort = i;

                            // If this will be the first use of this port, it should currently be available - 
                            // Try a connection to it to see if it is available.  

                            if (ProcessReferences[i - FirstPort] == null)
                            {
                                // See if port is available by trying to register it ...  
                                if (!IsPortAvailable(assignedPort))
                                    assignedPort = 0;

                            }

                            if (assignedPort > 0)
                                break;


                        }


                int slot = assignedPort - FirstPort;

                if (assignedPort > 0 &&
                    ProcessReferences[slot] == null)
                {
                    // Setup an environment, and launch APISessn with environment variables set and 
                    // input parameters.  

                    Log.AddLogEntry("About to start APISessn using port " + assignedPort.ToString());

                    int rc = RunAPISessn(assignedPort, out errorMessage);
                    if (rc != 0)
                    {
                        Log.AddLogEntry(errorMessage);   // While serious, this is not a reason to cancel server
                        assignedPort = 0;
                        message = errorMessage;
                        return rc;// Bad start of APISessn.exe 
                    }
                    else
                    {
                        Log.AddLogEntry("Successfully started an instance of " + StartProgram + " using port " + assignedPort.ToString());
                        CountPerPort[assignedPort - FirstPort] += 1;
                        activeSessions += 1;

                    }
                }
                else
                    if (assignedPort > 0)
                    {
                        // Just attaching a person to an exiting APISessn.exe
                        CountPerPort[assignedPort - FirstPort] += 1;
                        activeSessions += 1;
                    }
                    else
                    {
                        message = "No ports available for another APISessn instance.";
                        return 3; // No ports available for another session 
                    }

            }
			return 0 ; 
		}

		public int EndSession (int assignedPort, out string message) 
		{
            // Only allow one thread through this at a time. 
            lock (thisLock)
            {

                //  Locate the port number in the internal arrays, and decrement counts, etc.  
                message = "";
                try
                {
                    if ((assignedPort >= FirstPort) &&
                        (assignedPort <= LastPort))
                    {
                        int portIndex = assignedPort - FirstPort;
                        CountPerPort[portIndex] -= 1;
                        activeSessions -= 1;
                        if (CountPerPort[portIndex] < 1)
                        {
                            // Kill the associated APISessn instance, if no one needs it anymore. 
                            int activeWorkers, availableSlots;
                            GetAvailability(out activeWorkers, out availableSlots);

                            if (activeWorkers > MinimumWorkers)
                                if (ProcessReferences[portIndex] != null)
                                {
                                    {
                                        ProcessReferences[portIndex].Kill();
                                        ProcessReferences[portIndex] = null;
                                    }
                                }
                        }

                    }
                    else
                    {
                        message = "Invalid port number: " + assignedPort + ".  No APISessn is running using that port. ";
                        return 2; // Port number given for release is not valid 
                    }
                }
                catch
                {
                    message = "Not able to locate or successfully stop APISessn process for HostPort " + assignedPort + ".  It may be that process was already manually stopped. ";
                    return 3; // Was not able to locate or kill APISessn process
                }
            }

			return 0 ; 
		}



	}
}
