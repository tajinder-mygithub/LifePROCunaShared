/*@**20100811********************************************/
/*@** */
/*@** Licensed Materials - Property o */
/*@** ExlService Holdings, Inc. */
/*@** */
/*@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved. */
/*@** */
/*@** Contains confidential and trade secret information. */
/*@** Copyright notice is precautionary only and does not */
/*@** imply publication. */
/*@**
/*@**20100811********************************************/
/****************************** Module Header *******************************
* Module Name:  clidrvl.c
* Program Name: cclient
*
* Client Driveless-thin functions
*
* Functions:
*
*   cli_test_for_driveless_thin
*   cli_perform_driveless_thin
*   thin_cleanup
*   standard_thin_call
*   call_dll
*
*  SR#              INIT    DATE        DESCRIPTION
*  -------------------------------------------------------------------------
*19990819-009-01    ADA     08/24/1999  Fixed display of "not supported" message
****************************************************************************/

#include "lpcopyrt.h"

static char *RCSid = "$Header: /src/cs-proto/drvless/RCS/clidrvl.c,v 1.5 1999/04/19 19:55:07 fordd Exp $";

#define TESTMAIN
/*#define DEBUG_PARSE */    /* define to help debug parse_command() */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#define INCL_DOSFILEMGR
#define INCL_DOSERRORS
#define INCL_DOSPROCESS

#if defined(UNIX)
/*#include <sys/io.h>*/
#include <utime.h>
#else
#include <io.h>
#include <direct.h>
#include <conio.h>
#include <process.h>
#include <sys/utime.h>
#endif

#ifdef WIN
#include <windows.h>
#endif

#include "net.h"
#include "debug.h"

#include "packman.h"
#include "packproc.h"
#include "hh.h"
#include "filecopy.h"
#include "drvlthin.h"

// begin 19990329-001-01 functions
static int standard_thin_call (char *packet, int curr_packet_len, int user_type);
BOOL __declspec( dllexport) LPCALLER (char *args);  /* from lpcaller.dll */
static int call_dll(char *dllname, char *arg);
// end 19990329-001-01 functions

/* handle and function entry points into drvlthin.dll */
HANDLE                  drivelessthin = NULL;
LPFNDRVLTHIN            lpfnDrvLThin;
LPFNDRVLTHIN_CLEANUP    lpfnDrvLThin_cleanup;

static char *errmsg = "Driveless thin clienting is NOT supported. Contact your sales representive for purchase information.";

/* (client side call) returns 1 if the drvlthin.dll is present, 0 otherwise */
int
cli_test_for_driveless_thin()
{
    if (drivelessthin != NULL)
        return(1);      /* been here before... */

    drivelessthin = LoadLibrary("drvlthin.dll");
    if (drivelessthin != NULL)
    {   if (((lpfnDrvLThin = (LPFNDRVLTHIN)GetProcAddress(drivelessthin,
                  "dll_cli_perform_driveless_thin")) != NULL) &&
            ((lpfnDrvLThin_cleanup = (LPFNDRVLTHIN_CLEANUP)GetProcAddress(drivelessthin,
                  "dll_cli_cleanup_driveless_thin")) != NULL))
            return(1);
        else
        {   message(MSG_ERROR, errmsg, "Entry points not found");
            FreeLibrary(drivelessthin);
            drivelessthin = NULL;
        }
    }
    return(0);
}

/* (client side call) returns 1 if client side processing was successful
 * 0 otherwise */
int
cli_perform_driveless_thin(int netfd, char *packet,
               int curr_packet_len, int maxpacket)
{
    int retlen, retcode;

    static char *thisdll = "cclient/clidrvl"; // 19990329-001-01
    int user_type;                            // 19990329-001-01
    user_type = *(packet+1);                  // 19990329-001-01

    if ((drivelessthin == NULL) || (lpfnDrvLThin == NULL))
    // 19990329-001-01:
    // intercept and process standard thin client call from server side.
    {   if ((user_type == THINPACKET_EXECUTE_EXE) ||
            (user_type == THINPACKET_EXECUTE_DLL))
        {   standard_thin_call(packet, curr_packet_len, user_type);
            *packet = THINPACKET_EXECUTE_RESP; // send response to
            *(packet+2) = ':';                 // host that all is well
            *(packet+3) = ' ';
            if ( (retlen = net_send_buff (netfd, packet, strlen(packet)+1)) <= 0 )
            {   message(MSG_ERROR, "failed sending response after standard thin call, exiting", thisdll);
                cleanup_on_exit(1);
            }
            return(1);
        }
        // 19990816-009-01 moved else to inside the if statement
        else
        {   message(MSG_ERROR, errmsg, NULL);
            *packet = 'f';
            *(packet+1) = 'E';
            strcpy(packet+2, errmsg);
            if ( (retlen = net_send_buff (netfd, packet, strlen(packet))) <= 0 )
            {   winprintf("failed sending response after drvlthin, exiting\n");
                cleanup_on_exit(1);
            }
            return(0);
        }
    }
    retcode = (*lpfnDrvLThin)(netfd, packet, curr_packet_len, maxpacket);
    return(retcode);
}

void
thin_cleanup(void)
{   if (drivelessthin != NULL)
    {   if (lpfnDrvLThin_cleanup != NULL)
        {   (*lpfnDrvLThin_cleanup)();
            lpfnDrvLThin_cleanup = NULL;
        }
        FreeLibrary(drivelessthin);
        drivelessthin = NULL;
        lpfnDrvLThin = NULL;
    }
}

// 19990329-001-01:
// Processes input via standard thin client from host server.
// This function is used for standard thin client calls only.
// The driveless thin client has its own method of handling calls.
static int
standard_thin_call(char *packet, int curr_packet_len, int user_type)
{
    //char msg[512];
    //wsprintf(msg, "stnd thin: recv cmd %s len: %d", packet+5, curr_packet_len);
    //MessageBox(NULL, msg, "Standard Thin Packet+5", MB_OK|MB_SETFOREGROUND);

    // see 'sprintf' in clidrvl/client_execute function for
    // packet load with pipe-sign delimited arguments.

    if (user_type == THINPACKET_EXECUTE_DLL)
    {   if (call_dll(packet+5, NULL) == 0)  // packet+5 contains dll and any arguments
            *(packet+1) = '0';
        else
            *(packet+1) = '1';
    }
    else
    {
        LPCALLER(packet+5);
        *(packet+1) = '1';
    }

    return(1);

}  // end 'standard_thin_call'

// 19990329-001-01:
// Picks up DLL name and any arguments from packet.
static int
call_dll(char *dllname, char *arg)
{
    typedef int (_cdecl * LPFN_DLL)(char *argument);
    HANDLE      dll_lib = NULL;
    LPFN_DLL    lpfn_dll = NULL;

    static char *thisdll = "cclient/clidrvl";
    char msg_buf[512];

    if ((dll_lib = LoadLibrary(dllname)) == NULL)
    {   sprintf(msg_buf, "failed to find the dll: %s", dllname);
        message(MSG_ERROR, msg_buf, thisdll);
        return(0);
    }
    else
    if ((lpfn_dll = (LPFN_DLL)GetProcAddress(dll_lib, dllname)) == NULL)
    {   sprintf(msg_buf, "failed to find the entry point %s in dll %s",
            dllname, dllname);
        message(MSG_ERROR, msg_buf, thisdll);
        return(0);
    }

    if (arg == NULL)
       (*lpfn_dll);
    else
    {
        (*lpfn_dll)(arg);
    }

    FreeLibrary(dll_lib);
    return(1);

} // end 'call_dll'
