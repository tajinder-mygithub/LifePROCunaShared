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

#include "lpcopyrt.h"

/**************************************************************************
Compiling instructions:

   The following modules are needed to compile the program CCLIENT.DLL:
        C source:
        ADLER32.C   BYTESWAP.C  CCLIENT.C   CLIDRVL.C   COMPRESS.C  CRC32.C
        DEBUG.C     DEFLATE.C   DELTAC1.C   FILECOPY.C  GZIO.C      HHCLIENT.C
        INFBLOCK.C  INFCODES.C  INFFAST.C   INFLATE.C   INFTREES.C  INFUTIL.C
        NET.C       NHHTCP.C    PACKMAN.C   PACKPROC.C  RMTHASH.C   TREES.C
        UNCOMPR.C   ZUTIL.C

        Header files:
        BYTESWAP.H  DEBUG.H     DEFLATE.H   DELTAC1.H   DRVLTHIN.H  FILECOPY.H
        HH.H        INFBLOCK.H  INFCODES.H  INFFAST.H   INFTREES.H  INFUTIL.H
        NET.H       PACKMAN.H   PACKPROC.H  SIZECALC.H  SPX.H       STAT.H
        TIMEB.H     TYPES.H     UTIME.H     VERNUMS.H   VERSION.H   ZCONF.H
        ZLIB.H      ZUTIL.H

        Libraries:
        LPCALLER.LIB            COMMODE.OBJ (from system)

    The following module must be available, but should not itself be compiled
    (it's #included in another file):
        VERSION.C

    The following constants must be defined to the compiler:
        WIN
        IP
        ANY_NET
        DLL
        CLIENT

***************************************************************************/
/****************************** Module Header *******************************
* Module Name:  cclient.c
* Program Name: cclient
*
* Main module for cclient.dll.
*
* Functions:
*
*   cclient (exported)
*   playback
*   receive_file_from_host (exported)
*   send_file_to_host (exported)
*   output_run_time
*   apply_deltas
*   cleanup_on_exit (exported)
*
*  SR#              INIT    DATE        DESCRIPTION
*  -------------------------------------------------------------------------
*19990819-009-01    ADA     08/24/1999  Added this header, cleaned up tabs
*20070529-004-01    DAR     08/09/2007  Fix Synchronization for file upload, 
*                                       add debugging features (commented out for 
*                                       prod)  
* 20080903-002-01   DAR     01/12/2009  Pull synchronization changes back to 
*                                       v14, along with debug additions. 
****************************************************************************/
static char *RCSid = "$Header: /src/cs-proto/client/RCS/cclient.c,v 1.26 1999/04/20 19:12:57 fordd Exp $";

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <errno.h>
#define INCL_DOSFILEMGR
#define INCL_DOSERRORS
#define INCL_DOSPROCESS

#if defined (NWOS2)
#include <os2.h>
#endif

#if defined (UNIX)
/*#include <sys/io.h>*/
#include <utime.h>
#else
#include <io.h>
#include <direct.h>
#include <conio.h>
#include <process.h>
#include <sys/utime.h>
#endif

#if defined (CAPTURE) || defined (PLAYBACK)
#include <sys/types.h>
#include <sys/timeb.h>
#endif

#if defined (WIN)
#include <winsock.h>
#include <windows.h>
#endif

#if defined (NWOS2)
#include <dos.h>   /* under OS/2, Comment out for IBM or Uncomment for Watcom */
#endif

#include "version.h"
#include "net.h"
#include "packman.h"
#include "hh.h"
#include "debug.h"
#include "filecopy.h"
#include "drvlthin.h"
#include "version.c"    /* includes the function specific vernums.h */

/* Outer packet structure:
 * 1st byte: Server -> Client
 * '8'                  user type + 8 params (4 pointers intermixed with
 *                              lengths [pointer,length,pointer,length,...])
 *                      note an '8' with a user type of 'Q' at the client
 *                              says bye.
 * 'M'                  MessageBox (S->C)
 *                              user type 'E' error, 'I' info
 * 'S'                  screenio screen
 * 'T'                  Driveless thin call (S->C)
 *      user type
 *      'V' S->C        [version query only valid after a client tells the 
 *                      server the licensed code is present] 
 *      'v' C->S        version response 
 * user type: a one byte value that the application can use (passed from end to
 *      end), the 1st byte is only used by cclient/chost.
 */

#if defined (PLAYBACK) || defined (CAPTURE)
#if defined (UNIX)
#define TIMEB struct timeb
#define FTIME ftime
#define SLEEP usleep
#else
#define TIMEB struct _timeb
#define FTIME _ftime
#define SLEEP _sleep
#endif
#endif

#if defined (CAPTURE)
/* Header file for capturing data changes sent to the host */
#include "capture.h"
#elif defined (PLAYBACK)
/* Header file for reading the captured data changes sent to the host */
#include "playback.h"

static void apply_deltas  ( void *buffer, int area, Delta_header *dh,
                            Delta_item **di );

/* This function is uses to implement the loop to re-send all "input"
*  back to the host without returning to the COBOL and calling the
*  screen IO routine.
*/
static int playback ( char *type_arg, char *arg1, char *arg2,
                      char *arg3, char *arg4 );

static Playback_log log_data;

static TIMEB recv_time, rtrn_time;

#endif

#if defined (CAPTURE) || defined (PLAYBACK)
static void output_run_time ( void );
static long total_delay = 0;
static long total_host  = 0;
#endif


/*
#ifndef SERVNAME
#define SERVNAME        "JEFFTEST5"
#define SERVNAME        NULL
#define MyShutdownAdvertising()
#endif
*/

static char packet[32767];
static int packet_type = ' ';

static int receive_file_from_host ( int netfd, void *arg2 );
static int send_file_to_host      ( int netfd, void *packet );

#if defined (CAPTURE) || defined (PLAYBACK)

/*  Workareas for data delta capture */
static TIMEB s_time, e_time, start_run, end_run;
static TIMEB x_time;                    /* DEBUG */
static Delta_header d_header;

#if defined (PLAYBACK)
static Delta_item   *d_items;
static char new_id[128];
static int new_id_flag = 2, id_len;
#endif

static Save_area *saved_panel;

/* This is defined in packman.c.  It is referenced here to get
*  the difference for output to the delta file.  This is not a
*  recommended method, but since this is internal only and we are
*  in a hurry, I cheated :)
*/
extern Save_area *save_panelp;          /* Used for length only     */

#endif

void writelog (char * theLine)
{
	// Uncomment the following lines to turn on logging.
	
	/*
  	 FILE *stream;

 	 stream = fopen("c:\\temp\\CClientLog.txt", "a");
	 fprintf(stream, theLine);
	 fclose(stream);
	 */

}

void write2log (char * param1, char * param2);


int clientorserver = 1 ;
static Save_area *arg1_savep,
                 *arg2_savep,
                 *arg3_savep,
                 *arg4_savep;


#if defined (UNIX) && defined (PLAYBACK)
static char type_arg[1], arg1[MAX_BUFFER], arg2[MAX_BUFFER],
                         arg3[MAX_BUFFER], arg4[MAX_BUFFER];
#endif


#if defined (WIN)

__declspec(dllexport) _cdecl cclient (char *type_arg, char *arg1, char *arg2, char *arg3, char *arg4)

#elif defined (UNIX)

#if defined (PLAYBACK)
int main ( int argc, char **argv )
#else
int cclient (char *type_arg, char *arg1, char *arg2, char *arg3, char *arg4)
#endif /* PLAYBACK */

#else

_loadds _export cclient (char _far *type_arg, char _far *arg1, char _far *arg2, char _far *arg3, char _far *arg4)

#endif
{
    version_number server_version, my_version;
    static int first = 1;
    static int netfd;

#if defined (PLAYBACK)
    int rc;
    char dummy_in[128];

    while ( 1 )
    {
        if ( (rc = playback (type_arg, arg1, arg2, arg3, arg4)) < 0 ||
             first == 1 || *type_arg == 'E' || *type_arg == 'Q' )
            break;
    }

    if ( *type_arg == 'Q' || *type_arg == 'E' )
    {
        output_run_time ();
/*        fprintf (stdout, "Ready to quit.... ");
        gets (dummy_in);
*/
    }
    return (rc);

}

static int
playback (char *type_arg, char *arg1, char *arg2, char *arg3, char *arg4)
{
    int i;
    int millisecs;
#endif /* PLAYBACK */
    int retlen;
    int sendlen;
    char *cp;
#if defined (CAPTURE) || defined (PLAYBACK)
    long time_index;
#endif

    //{
    //char msg[512];
    //wsprintf(msg, "in cclient");
    //MessageBox(NULL, msg, "In Cclient", MB_OK|MB_SETFOREGROUND);
    //}

    if (first)
    {
#if defined (CAPTURE)
        fprintf (stderr, "\n\nRUNNING IN CAPTURE MODE\n\n");
#elif defined (PLAYBACK)
        fprintf (stderr, "\n\nRUNNING IN PLAYBACK MODE\n\n");

        cp = getenv ("REMOTE_ID");
        if ( (cp != NULL) && ((id_len = strlen(cp)) < 5) && (id_len > 0) )
        {
            strcpy (new_id, cp);
            fprintf (stdout, "ID is [%s]\n", new_id);
        }
        else
            while (1)
            {
                fprintf (stdout, "Enter new logon ID ");
                gets (new_id);
                if ( (id_len = strlen (new_id)) > 4 || id_len < 1 )
                {
                    fprintf (stderr, "ID must be 1-4 characters...\n");
                    continue;
                }
                break;
            }
        for ( i = 0; i < id_len; i++ )
            new_id[i] = toupper (new_id[i]);
        while ( i < 4 )
            new_id[i++] = ' ';
        new_id[i] = '\0';
        id_len = 4;

        open_playback_log (new_id);
#endif

        get_version(&my_version);

#ifdef TRAD_CS
        NOTE: my_version/client_version code is nnow broken here...
        if ((netfd = net_init_client(SERVNAME)) < 0)
            return(-1);
#else
        if ((netfd = net_hh_client(&my_version, &server_version)) == -1)
            return(-1);
#endif

#if defined (CAPTURE) || defined (PLAYBACK)
        if ( open_delta () != 0 )
        {
            net_close_cconn(&netfd);
            return (-1);
        }
#endif

		//Sleep(15000);

        arg1_savep  = New_SaveArea();
        arg2_savep  = New_SaveArea();
        arg3_savep  = New_SaveArea();
        arg4_savep  = New_SaveArea();
#if defined (CAPTURE) || defined (PLAYBACK)
        saved_panel = New_SaveArea();
        FTIME (&start_run);
#endif
#if defined (CAPTURE)
        d_header.sequence = 0;
#endif

        first = 0;
    }
    else
    {
        *packet     = packet_type;
        *(packet+1) = *type_arg;
#if defined (CAPTURE) || defined (PLAYBACK)
        FTIME (&e_time);               /* Get current time */
        time_index = ((e_time.time - start_run.time) * 1000)
                    +  (e_time.millitm - start_run.millitm);
#endif

#if defined (CAPTURE)
        /* Setup delta header fields */
        d_header.type = packet_type;
        d_header.elapsed_time = ((e_time.time - s_time.time) * 1000)
                              +  (e_time.millitm - s_time.millitm);
        d_header.delta_count = 0;
#endif

        if (packet_type == 'S')
        {
#if defined (PLAYBACK)
            /* Only the panel and return code will have any changes
            *  since this is a normal screen transmission
            */
            read_deltas (&d_header, &d_items);
            if ( d_header.type != 'S' ||
                 memcmp (d_header.screen, arg1, 8) != 0 )
            {
                fprintf (stderr, "\n\n**** OUT OF SYNC ****\n");
                fprintf (stderr, "Expected type [%c], screen [%8.8s]: "
                         "got type [S], Screen [%8.8s]\n",
                         d_header.type, d_header.screen, arg1);
                fprintf (stderr, "Terminating Run\n\n");
                net_close_cconn(&netfd);
                first = 1;

                cleanup_on_exit(DO_NOT_EXIT);
#if defined (CAPTURE) || defined (PLAYBACK)
                close_delta ();
#endif
                *type_arg = 'Q';
                return(0);
            }

            apply_deltas (arg1, 1, &d_header, &d_items);

            if ( new_id_flag > 0 )
                if ( memcmp ("SMASTCPY", d_header.screen, 8) == 0 )
                {
                    new_id_flag--;
                    memcpy (arg1 + 463, new_id, id_len);
                }
#endif

#if defined (CAPTURE)
            /* Only the panel and return code will have any changes
            *  since this is a normal screen transmission
            */
            memcpy (d_header.screen, arg1, 8);
            d_header.delta_count = get_delta (1, arg1, saved_panel);
            write_deltas (&d_header);
#endif

#if defined (CAPTURE) /* || defined (PLAYBACK)  */                   /* DEBUG */
printf ("Panel Returned (%d)  Sequence # %d  Time Index %ld:\n",
        saved_panel->length, d_header.sequence, time_index);
dump_packet(arg1, saved_panel->length);
printf ("\n\n");
fflush (stdout);
#endif
            sendlen = make_packet (packet+2, arg1, arg2, arg3, arg4);
            sendlen += 2;
        }
        else if (packet_type == '8')
        {
            /* Type 8 packets must have all four areas checked for
            *  changes.
            */
#if defined (CAPTURE)
            *d_header.screen = *(packet + 1);
            d_header.delta_count  = get_delta (1, arg1, arg1_savep);
            d_header.delta_count += get_delta (2, arg2, arg2_savep);
            d_header.delta_count += get_delta (3, arg3, arg3_savep);
            d_header.delta_count += get_delta (4, arg4, arg4_savep);
            write_deltas (&d_header);
#elif defined (PLAYBACK)
            read_deltas (&d_header, &d_items);
            apply_deltas (arg1, 1, &d_header, &d_items);
            apply_deltas (arg2, 2, &d_header, &d_items);
            apply_deltas (arg3, 3, &d_header, &d_items);
            apply_deltas (arg4, 4, &d_header, &d_items);
#endif

            cp = packet+2;
            cp = make_block (cp, arg1, arg1_savep->length, arg1_savep);
            cp = make_block (cp, arg2, arg2_savep->length, arg2_savep);
            cp = make_block (cp, arg3, arg3_savep->length, arg3_savep);
            cp = make_block (cp, arg4, arg4_savep->length, arg4_savep);
            sendlen = cp - packet;

#if defined (CAPTURE) /* || defined (PLAYBACK)  */                   /* DEBUG */
printf ("Type 8 arg2 returned (%d) type_arg = [%c], Sequence # %d Time Index %ld:\n",
        arg2_savep->length, *type_arg, d_header.sequence, time_index);
dump_packet (arg2, arg2_savep->length);
fflush (stdout);
#endif

        }
        else
            message(MSG_ERROR, "unknown packet type: send", NULL);

#if defined (PLAYBACK)
        FTIME (&e_time);
        millisecs = d_header.elapsed_time
                  - (((e_time.time - s_time.time) * 1000)
                     +  (e_time.millitm - s_time.millitm));

        if ( millisecs > 0 )
        {
            fprintf (stderr, "Sleeping for %5dms...", millisecs);
            SLEEP ( (long)(millisecs * 1000) );
FTIME (&x_time);
millisecs = ((x_time.time - e_time.time) * 1000)
          +  (x_time.millitm - e_time.millitm);
fprintf (stderr, "A[%5dms]", millisecs);
        }
        else
            fprintf (stderr, "Sleeping not needed ...");

        log_data.packet_type  = *packet;
        log_data.sequence     = d_header.sequence;
        log_data.delay_time   = millisecs;
        log_data.process_time = ((rtrn_time.time - recv_time.time) * 1000)
                              +  (rtrn_time.millitm - recv_time.millitm);
        total_delay += log_data.delay_time;
        total_host  += log_data.process_time;
        if ( log_data.packet_type == 'S' )
            memcpy (log_data.screen, d_header.screen, 8);
        else
            *log_data.screen = *(packet+1);
        write_playback_log (&log_data);

        fprintf (stderr, "Sending response # %4d\n", d_header.sequence);
#endif

        if ((retlen = SEND_BUFFER(netfd, packet, sendlen)) < 0)
        {
            message(MSG_ERROR, "send_buffer failed, exiting", NULL);

            /* the next line is a hack because COBOL does stop runs in
               the middle of the code instead of returning so that
               we can send the appropriate quit packet.  It should
               be fixed and done right */
            *type_arg = 'Q';
#if defined (CAPTURE)
            output_run_time ();
#endif
            return(retlen);
        }
/*
printf("This is what we sent:\n");
dump_packet(packet, retlen);
fflush(stdout);
*/
    }

    /* chost8 call and a X type: exiting lifepro (don't block) */
    if ((packet_type == '8') && (*type_arg == 'Q'))
    {
        net_close_cconn(&netfd);
        first = 1;

        cleanup_on_exit(DO_NOT_EXIT);

#if defined (CAPTURE) || defined (PLAYBACK)
        close_delta ();
#endif
#if defined (CAPTURE)
        output_run_time ();
#endif
        return(0);
    }


    while ( 1 )
    {
        #if defined (PLAYBACK)
            fprintf (stderr, "Waiting...");
            FTIME (&recv_time);
        #endif

/* printf ("Waiting for input\n"); */
        /* we will wait for a message from the server. It may be a 'M' which
         * means 'popup this', or something to process...
         */
        if ((retlen = RECV_BUFFER(netfd, packet, sizeof(packet))) <= 0)
        {
            message(MSG_ERROR, "recv_buffer failed, exiting\n", NULL);
            /*
             * the next line is a hack because COBOL does stop runs in the
             * middle of the code instead of returning so that we can send
             * the appropriate quit packet.  It should be fixed and done
             * right
             */
            *type_arg = 'Q';
            #if defined (CAPTURE) || defined (PLAYBACK)
                output_run_time ();
            #endif

            return(retlen);
        }

        #if defined (PLAYBACK)
            FTIME (&rtrn_time);
        #endif

/*  sprintf(msg_buf, "back from RECV_BUFFER, ret=%d 1:%c, 2:%c\n", retlen,
        *packet, *(packet+1));
        // message(MSG_INFO, msg_buf, NULL);
        winprintf(msg_buf);
*/

/*
        printf("This is what we received:\n");
        dump_packet(packet, retlen);
        fflush(stdout);
*/

        packet_type = *packet;
        *type_arg   = *(packet+1);

        if (packet_type == 'S')
        {
            break_packet (packet+2, arg1, arg2, arg3, arg4);
            #if defined (CAPTURE) || defined (PLAYBACK)
                memcpy (saved_panel->buffer, arg1, save_panelp->length);
                        saved_panel->length = save_panelp->length;
            #endif

#if defined (CAPTURE) /* || defined (PLAYBACK)  */                   /* DEBUG */
printf ("Panel Received (%d):\n", saved_panel->length);
dump_packet(arg1, save_panelp->length);
fflush (stdout);
#endif

        }
        else if (packet_type == '8')
        {
            if ( *(packet + 1) == '>' ) /* Receive file from host? */
            {
                receive_file_from_host (netfd, packet);
                continue;   /* Loop back and wait for input */
            }
            else
                if ( *(packet + 1) == '<' ) /* Send file to host? */
                {
                    send_file_to_host (netfd, packet);
                    continue;   /* Loop back and wait for input */
                }

            cp = packet+2;
            cp = break_block (arg1, cp, arg1_savep);
            cp = break_block (arg2, cp, arg2_savep);
            cp = break_block (arg3, cp, arg3_savep);
            cp = break_block (arg4, cp, arg4_savep);

#if defined (CAPTURE) /* || defined (PLAYBACK)  */                   /* DEBUG */
printf ("Type 8 arg2 received (%d) type_arg = [%c], Time Index %ld:\n",
        arg2_savep->length, *type_arg, time_index);
dump_packet (arg2, arg2_savep->length);
fflush (stdout);
#endif

        }
        else
        if (packet_type == 'M') /* messagebox popup */
        {   int     popup_level;

            if (*type_arg == 'E')
                popup_level = MSG_ERROR;
            else
                popup_level = MSG_INFO;
            message(popup_level, packet+2+strlen(packet+2)+1, packet+2);

            #if defined (PLAYBACK)
            #error "Timing code needs to be delt with here..."
            #endif

            /* respond when a button is pressed */
            strcpy(packet, "0");
            if ( (retlen = net_send_buff (netfd, packet, strlen(packet))) <= 0 )
            {   winprintf("failed sending response after popup, exiting\n");
                cleanup_on_exit(1);
            }

            continue;
        }
#ifdef SUPPORT_DRIVELESS_THIN
        else    /* Driveless thin */
        if (packet_type == 'T')
        {
            #if defined (PLAYBACK)
            #error "Timing code needs to be dealt with here..."
            #endif

            cli_perform_driveless_thin(netfd, packet,
                       retlen, sizeof(packet));
            continue;
        }
#endif /* SUPPORT_DRIVELESS_THIN */
        else
        {
            sprintf(msg_buf, "unknown packet type %c received", *packet);
            message(MSG_ERROR, msg_buf, NULL);
        }
        break;              /* Exit the while */

    } /* while 1 */

    #if defined (CAPTURE) || defined (PLAYBACK)
        FTIME (&s_time);               /* Save receipt time */
    #endif
    #if defined (PLAYBACK)
        fprintf (stderr, "Processing...");
    #endif

    return(0);
}

/**********************************************************************
*    Function: receive_file_from_host
*     Purpose: Control the process of receiving a file to the host
*      Return: 0: error, 1: ok
*  Arguements: Pointer to the packet received which contains
*              the file names and a return code:
*                      char host_file_name[100];
*                      char client_file_name[100];
*                      char status_code[3];
*                      char file_type;
*              File names are COBOL strings (not nul terminated), and
*              the return code is numeric, 000 -> OK, 001 -> Error
*
*       Notes:
**********************************************************************/

int WINDLL
receive_file_from_host ( int netfd, void *packet )
{
    int  call_return, send_length;
    char *cpi, *cpo;
    char client_file_name[COPY_NAME_SIZE + 1];
    char file_type[2];
    Copy_control *ccp;
    Copy_client_info *ccip;

    ccp = (Copy_control *)packet;
    ccip = (Copy_client_info *)((char *)packet + sizeof(Copy_control));

    /* Copy our file name to a work area and nul terminate it */
    cpi = ccip->client_file_name;
    cpo = client_file_name;
    while ( *cpi != ' ' && *cpi != '\0' &&
            cpi <  ccip->client_file_name
                    + sizeof(ccip->client_file_name) )
        *cpo++ = *cpi++;
    *cpo = '\0';

    file_type[0] = ccip->copy_type;
    file_type[1] = '\0';

    /* For now, if type is invalid, make it text */
    if ((file_type[0] != 'b') && (file_type[0] != 'B'))
        file_type[0] = 't';

    call_return = recv_file (netfd, client_file_name, file_type, 'C');

    ccp->control[0]  = '8';
    ccp->control[1]  = '>';
    ccp->type        = 2;
    ccp->data_length = 0;
    if ( call_return < 0 )
        ccp->status = 1;
    else
        ccp->status = 0;

    send_length = sizeof(Copy_control);
    if ( (call_return = net_send_buff (netfd, packet, send_length)) <= 0 )
    {
        winprintf("receive_file: send failed, exiting\n");
        cleanup_on_exit(1);
    }

    return (!ccp->status);

} /* receive_file_from_host () */


/**********************************************************************
*    Function: send_file_to_host
*     Purpose: Control the process of sending a file to the remote host
*      Return: 0: error, 1: ok
*  Arguements: Pointer to the packet which contains the file name and
*              mode of the file to be sent
*                      char host_file_name[100];
*                      char client_file_name[100];
*                      char status_code[3];
*              File names are COBOL strings (not nul terminated), and
*              the return code is numeric, 000 -> OK, 001 -> Error
*
*       Notes:
**********************************************************************/

int WINDLL
send_file_to_host ( int netfd, void *packet )
{
    struct stat statbuf;
    int  call_return, send_length;
    char status[3];
    char file_type[2], *cli_filenamep;
    Copy_control *ccp;
    Copy_client_info *ccip;
	//char withcontent [20000];

	writelog("Beginning send_file_to_host\n");

    /* Initialize return code to all character 0's */
    memset (status, '0', sizeof(status));
    ccp = (Copy_control *)packet;
    ccip = (Copy_client_info *)((char *)packet + sizeof(Copy_control));

    ccp->data_length = 0;
    if ((cli_filenamep = stat_it(ccip->client_file_name,
                  sizeof(ccip->client_file_name), &statbuf)) == NULL)
        ccp->status = 1;
    else
        ccp->status = 0;
	call_return = net_send_buff (netfd, packet, sizeof(Copy_control));
		
    /*
	ZeroMemory(withcontent,sizeof(withcontent));  
	prepareline(packet,withcontent, call_return);  
	writelog("CLIENT, send_file_to_host: net_send_buff sent: \n");  
	writelog(withcontent);  
	*/

    /* stat() failure... */
    if (ccp->status == 1)
        return(0);

    file_type[0] = ccip->copy_type;
    file_type[1] = '\0';

    /* For now, if type is invalid, make it text */
    if ( file_type[0] != 'b' && file_type[0] != 'B' )
        file_type[0] = 't';

    /* let the filecopy program send the file to the host */
	//writelog("about to snd_file\n");
	if ( (call_return = snd_file (netfd, cli_filenamep, file_type)) <= 0 )
        status[2] = '1';
	//writelog("back from snd_file\n");

    ccp->control[0]  = '8';
    ccp->control[1]  = '<';
    ccp->type        = 2;           /* Set end indicator */
    ccp->data_length = 0;
    ccp->status      = status[2] & 0x0f;
    send_length      = sizeof(Copy_control);

	Sleep(200);  // Slight delay for synchronization with host
	//writelog("about to final net_send_buff\n");
	if ( (call_return = net_send_buff (netfd, packet, send_length)) <= 0 )
    {
        winprintf("sendfile: send failed, exiting\n");
        cleanup_on_exit(1);
    }
	//writelog("back from final net_send_buff\n");


    return (!ccp->status);

} /* send_file_to_host () */


#if defined (CAPTURE) || defined (PLAYBACK)
/**********************************************************************
*    Function: output_run_time
*     Purpose: Calculate and display the elapsed time of this run
*      Return: None
*  Arguements: None
*
*       Notes:
**********************************************************************/

static void
output_run_time ( void )
{
    int run_time;
    char msg[256], msg2[256];

    FTIME (&end_run);
    run_time = ((end_run.time - start_run.time) * 1000)
             +  (end_run.millitm - start_run.millitm);

#if defined (PLAYBACK)
    sprintf (msg, "\n\nID: [%s], Elapsed run time = %4.3f\n",
             new_id, (float)run_time/1000);
#else
    sprintf (msg, "\n\nElapsed run time = %4.3f\n",
             (float)run_time/1000);
#endif

    sprintf (msg2, "Time at host = %4.3f, Total delay = %4.3f\n\n",
             (float)total_host/1000, (float)total_delay/1000);
    fprintf (stderr, "%s", msg);
    fprintf (stderr, "%s", msg2);

#if defined (CAPTURE)
    printf ("%s", msg);
    printf ("%s", msg2);
#endif
#if defined (PLAYBACK)
    write_playback_msg (msg);
    write_playback_msg (msg2);
    close_playback_log ();
#endif

    return;

} /* output_run_time */
#endif

#if defined (PLAYBACK)
/**********************************************************************
*    Function: apply_deltas
*     Purpose: Place the changes from the capture over the original
*              data
*      Return: None
*  Arguements: None
*
*       Notes:
**********************************************************************/

static void
apply_deltas  ( void *buffer, int area, Delta_header *dh,
                Delta_item **di )
{

    Delta_item *dw;
    char *bp;

    if ( *di == NULL )
        return;

    dw = *di;
    bp = (char *)buffer;

    while ( dh->delta_count > 0 && dw->d_field.area == area )
    {
        dh->delta_count--;
        memcpy (bp + dw->d_field.offset, dw->data, dw->d_field.length);
        dw = dw->next;
    }

    *di = dw;

    return;

} /* apply_deltas () */
#endif


void WINDLL
cleanup_on_exit(int retcode)
{
    arg1_savep  = Free_SaveArea(arg1_savep);
    arg2_savep  = Free_SaveArea(arg2_savep);
    arg3_savep  = Free_SaveArea(arg3_savep);
    arg4_savep  = Free_SaveArea(arg4_savep);
#if defined (CAPTURE) || defined (PLAYBACK)
    saved_panel = Free_SaveArea(saved_panel);
#endif

    thin_cleanup();
    if (retcode == DO_NOT_EXIT)
        return;
    else
        exit(retcode);
}

/* cclient.c */

