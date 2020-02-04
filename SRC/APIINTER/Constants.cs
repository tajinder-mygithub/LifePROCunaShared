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
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/


using System;

namespace PDMA.LifePro
{
	/// <summary>
	/// This is a repository for constants used in the Thin Service and APi environments. 
	/// </summary>
	public class C
	{
		public C()
		{
		}

		// Capitalize variable names here to match syntax of string value, so "windows" will use 
		// variable windows, and "Windows" variable Windows.  Do not include punctuation symbols in 
		// constant names.  

		public const string id = "id" ; 
		public const string type = "type" ; 
		public const string windows = "windows" ; 
		public const string Windows = "Windows" ; 
		public const string api = "api" ; 
		public const string API = "API" ; 
		public const string STARTPROGRAM = "STARTPROGRAM" ; 
		public const string STARTPATH = "STARTPATH" ; 
		public const string SEARCHPATH = "SEARCHPATH" ; 
		public const string WORKAREA = "WORKAREA" ; 
		public const string IMAGE = "IMAGE" ; 
		public const string HOSTHOST = "HOSTHOST" ; 
		public const string DATASOURCETYPE = "DATASOURCETYPE" ; 
		public const string SQLDATASRC = "SQL_DATASRC" ; 
		public const string CHILDFIRSTPORT = "CHILDFIRSTPORT" ; 
		public const string CHILDLASTPORT = "CHILDLASTPORT" ; 
		public const string CHILDSESSIONLIMIT = "CHILDSESSIONLIMIT" ;
        public const string CHILDMINIMUMWORKERS = "CHILDMINIMUMWORKERS";
        public const string BINDINGTYPE = "BINDINGTYPE";   
		public const string ODBCINF = "@ODBC_INF" ; 
		public const string SERVER = "SERVER" ; 
		public const string MAXSPAWN = "MAXSPAWN" ; 
		public const string HOSTPORT = "HOSTPORT" ; 
		public const string INTERFACE = "INTERFACE" ; 
		public const string LOGPATH = "LOGPATH" ; 
		public const string DEBUGLOG = "DEBUGLOG" ; 
		public const string LPCLIENTPLATFORM = "LPCLIENTPLATFORM" ; 
		public const string ENVIRONMENTPOLICY = "ENVIRONMENTPOLICY" ; 
		public const string ENVIRONMENTCOUNT = "ENVIRONMENTCOUNT"; 
		public const string CPULIMIT = "CPULIMIT" ; 
		public const string CPUTIMEBETWEENCHECKS = "CPUTIMEBETWEENCHECKS" ; 
		public const string CPUALLOWEDVIOLATIONS = "CPUALLOWEDVIOLATIONS" ; 
		public const string PUBLISHPORT = "PUBLISHPORT" ; 
		public const string FORMATVERSION = "FORMATVERSION"; 
		public const string version14 = "14.0" ; 

		public const string winListenProg = "WIN32HH" ; 
		public const string apiListenProg = "API32HH" ; 
		public const string winRunProg = "RUNFJ" ; 
		public const string apiRunProg = "APISessn"; 

		public const string hosts = "hosts" ; 
		public const string host = "host" ; 
		public const string children = "children" ;
		public const string child = "child" ; 
		public const string HostId = "HostId"; 
		public const string HostType = "HostType"; 
		public const string PID = "PID" ; 
		public const string HostHost = "HostHost"; 
		public const string all = "all" ; 
		public const string WorkstationId = "WorkstationId"; 
		public const string APISessions = "APISessions"; 
		public const string disconnected = "disconnected"; 
		public const string Disconnected = "Disconnected"; 
		public const string LastCPU = "LastCPU";  
		public const string service = "service"; 
		public const string help = "help"; 
		public const string list = "list"; 
		public const string start = "start"; 
		public const string stop = "stop"; 
		public const string environment = "environment"; 
		public const string pid = "pid"; 
		public const string status = "status"; 
		public const string hostID = "hostID"; 
		public const string Publisher = "Publisher";  
		public const string CANCELSTOP = "CANCELSTOP"; 
		public const string KILL = "KILL"; 
		public const string kill = "kill";  
		public const string configuration = "configuration"; 
		public const string configSections = "configSections"; 
		public const string appSettings = "appSettings";  
		public const string remove = "remove"; 
		public const string section = "section" ; 
		public const string name = "name"; 
		public const string RemotePort = "RemotePort"; 
		public const string RemoteIP = "RemoteIP"; 
		public const string LocalIP = "LocalIP"; 
		public const string LocalPort = "LocalPort"; 
		public const string ServiceName = "LifePro Thin Service"; 
		public const string SkipPorts = "1433";  
		public const int WaitSeconds = 5  ;   // Decides how long to wait before refreshing information that is published. 
											  

		public const string ClientErrorMessage = "Client is unable to communicate with APISessn and 'factory' instance. " ; 

	}
}
