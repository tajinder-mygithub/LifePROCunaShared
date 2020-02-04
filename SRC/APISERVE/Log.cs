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
*  20131010-019-01   DAR   12/21/16    Added capabilities for more detailed logging, and 
*                                      fixed issues with multi-threaded calls to this class.  
*/


using System;
using System.Configuration;
using System.Diagnostics; 
using System.Threading;  

namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for Log.
	/// </summary>
	public class Log
	{
		private const string LogName = "LifePRO Service Execution Log";

        private static bool LogDetailedEntries = false;
        private static bool CheckedForEnvVar = false;  

		public Log()
		{
		}


        public static void AddDetailedLogEntry(string message)
        {
            try
            {

                if (!CheckedForEnvVar)
                {
                    CheckedForEnvVar = true;
                    LogDetailedEntries = false;
                    string showapidetail = System.Environment.GetEnvironmentVariable("SHOWAPIDETAIL");
                    if (!String.IsNullOrWhiteSpace(showapidetail))
                    {
                        if (showapidetail.ToUpper() == "YES" ||
                            showapidetail.ToUpper() == "Y")
                        {
                            LogDetailedEntries = true;
                        }
                    }
                }

                if (!LogDetailedEntries)
                    return;

                string processID = Process.GetCurrentProcess().Id.ToString();
                string processName = Process.GetCurrentProcess().ProcessName;
                string threadID = Thread.CurrentThread.ManagedThreadId.ToString();


                string newMessage = "Process Name: " + processName + " ID: " + processID +
                          " Thread: " + threadID + " Time: " + DateTime.Now.ToString("HH:mm:ss.ffff") + " Message: " + message;

                AddLogEntry(newMessage);
            }
            catch 
            { }  // Throw away logging errors so as to not stop processing.  

        }

		public static void AddLogEntry (string message) 
		{
			AddLogEntry(message, EventLogEntryType.Information);
		}

        private static EventLog EventLog = new EventLog();  

		public static void AddLogEntry (string message, EventLogEntryType type) 
		{

            try
            {
                // 20131010-019-01 :  CSR Portal multi-threading issues.  
                // Locking and using one static EventLog object to avoid problems with multi-threading.  
                // Also added close to Log. 
                lock (EventLog)
                {
                    string logName = LogName + ": " + Process.GetCurrentProcess().ProcessName;
                    if (!EventLog.SourceExists(logName))
                    {
                        EventLog.CreateEventSource(logName, String.Empty);
                    }
                    EventLog.Source = logName;

                    EventLog.WriteEntry(message, type);

                    EventLog.Close(); 
                }

            }
            catch 
            { } // Throw away logging errors so as to not stop processing.  
		}
	

	}
}
