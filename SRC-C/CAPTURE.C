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
/**********************************************************************
**                                                                   **
**   This program is the CONFIDENTIAL and PROPRIETARY PROPERTY of    **
**   International Business Machines, Inc. (IBM).  Any unauthorized  **
**   use, reproduction, or transfer of this program is strictly      **
**   prohibited.                                                     **
**                                                                   **
**   Copyright (c) 1997 IBM, Inc.                                    **
**                                                                   **
**********************************************************************/

#include "lpcopyrt.h"


/**********************************************************************
**                                                                   **
**    Program Name......: capture.c                                  **
**    Author(s).........: Don Allen                                  **
**    Description.......: Capture differences in packets for playback**
**    Creation Date.....: 06/05/1997                                 **
**    Revision Date.....:                                            **
**                                                                   **
**********************************************************************/

static char *RCSid = "$Header: /src/cs-proto/client/RCS/capture.c,v 1.1 1997/10/14 19:24:03 allen Exp $";

/* $Log: capture.c,v $
 * Revision 1.1  1997/10/14 19:24:03  allen
 * Initial revision
 * */

#define ERROUT stderr

#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "capture.h"

static int delta_h = -1;

static Delta_item *di, *di_first = NULL;

/**********************************************************************
*    Function: open_delta
*     Purpose: Open the data capture delta file
*      Return: 0 = Success
*              1 = Failure
*  Arguements: None
*
*       Notes:
**********************************************************************/

int
open_delta   ( void )
{
    char *file_name;

    if ( delta_h >= 0 )
        fprintf (stderr, "Subsequent open of delta file ignored\n");
    else
    {
        if ( (file_name = getenv ("CAPTURE_FILE")) == NULL )
            file_name = "C:\\cclient.cap";
        if ( (delta_h = _open (file_name,
                                 _O_BINARY | _O_CREAT | _O_TRUNC | _O_WRONLY,
                                 _S_IREAD | _S_IWRITE)) == EOF )
        {
            perror ("Error opening capture file");
            return (1);
        }
    }

    di_first = di = NULL;

    return (0);

} /* open_delta () */

/**********************************************************************
*    Function: get_delta
*     Purpose: Build linked list of all changes in the requested area
*      Return: Number of changes processed
*  Arguements: area -> value indicating the area being processed (1-4)
*              data -> Data being returned to the host
*              save -> Data saved when received from host
*
*       Notes:
**********************************************************************/

int
get_delta ( int area, void *data, Save_area *save )
{
    int     dc;
    char    *dp, *sp, *wp, *ep;

    dc = 0;
    dp = (char *)data;
    sp = save->buffer;
    ep = sp + save->length;

    while ( sp < ep )
    {
        while ( (*sp == *dp) && (sp < ep) )
        {
            sp++;
            dp++;
        }

        if ( sp >= ep )
            break;

        dc++;

        if ( di_first == NULL )
            di = di_first = calloc (sizeof(Delta_item), 1);
        else
        {
            di->next = calloc(sizeof(Delta_item), 1);
            di = di->next;
        }

        if ( di == NULL )
        {
            fprintf (stderr, "Out of memory on delta %d, area %d\n",
                     dc, area);
            return (-1);
        }

        di->d_field.area   = area;
        di->d_field.offset = sp - save->buffer;
        wp = dp;

        while ( (*sp != *dp) && (sp < ep) )
        {
            sp++;
            dp++;
        }

        di->d_field.length = dp - wp;

        if ( (di->data = malloc (di->d_field.length))
               == NULL )
        {
            fprintf (stderr, "Out of memory on data area for delta %d,"
                     " area %d\n", dc, area);
            return (-1);
        }

        memcpy (di->data, wp, di->d_field.length);

    } /* while data to process */

    return (dc);

} /* get_delta () */

/**********************************************************************
*    Function: write_deltas
*     Purpose: write the header and deltas to the capture delta file
*      Return: None
*  Arguements: None
*
*       Notes:
**********************************************************************/


void
write_deltas ( Delta_header *header )
{
    int  wc;

    header->sequence++;
    wc = header->delta_count;
    if ( _write (delta_h, header, sizeof(Delta_header)) == -1 )
    {
        perror ("Error writing header");
        return;
    }

    for ( di = di_first; di != NULL; di = di->next )
    {
        wc--;
        if ( _write (delta_h, &di->d_field, sizeof(Delta_field)) == -1 )
        {
            perror ("Error writing delta_field");
            break;
        }
        if ( _write (delta_h, di->data, di->d_field.length) == -1 )
        {
            perror ("Error writing delta data");
            break;
        }
    } /* for each delta */

    di = di_first;
    while ( di_first != NULL )
    {
        di_first = di->next;
        free (di->data);
        free (di);
        di = di_first;
    }

    if ( wc )
        fprintf (stderr, "deltas not = count. Difference = %d\n", wc);

    return;

} /* write_deltas () */

/**********************************************************************
*    Function: close_delta
*     Purpose: Close the data capture delta file
*      Return: None
*  Arguements: None
*
*       Notes:
**********************************************************************/

void
close_delta  ( void )
{
    if ( delta_h >= 0 )
    {
        _close (delta_h);
        delta_h = -1;
    }

    return;

} /* close_delta () */


/* capture.c */
