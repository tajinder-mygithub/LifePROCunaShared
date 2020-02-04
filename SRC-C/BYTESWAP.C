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


/**********************************************************************
**                                                                   **
**    Program Name......: byteswap.c                                 **
**    Author(s).........: Don Allen                                  **
**    Description.......: Swap Bytes in comp-5 fields in screen Panel**
**    Creation Date.....: 08 April 1997                              **
**    Revision Date.....:                                            **
**                                                                   **
**********************************************************************/
/****************************** Module Header *******************************
*
* Functions:
*   swap_bytes
*   fix_comps
*
*  SR#              INIT    DATE        DESCRIPTION
*  -------------------------------------------------------------------------
*19990819-009-01    ADA     08/24/1999  Added this header, cleaned up tabs
****************************************************************************/

static char *RCSid = "$Header: /src/cs-proto/common/RCS/byteswap.c,v 1.6 1997/10/14 13:48:13 buhrt Exp $";

/*
 * $Log: byteswap.c,v $
 * Revision 1.6  1997/10/14 13:48:13  buhrt
 * Don's tester changes
 *
 * Revision 1.5  1997/07/11 19:40:11  allen
 * Made swap_bytes visible to the outside world
 *
 * Revision 1.4  1997/07/02 19:22:05  buhrt
 * changed include filename
 *
 * Revision 1.3  1997/06/17 13:49:16  buhrt
 * changed location of swap.h
 *
 * Revision 1.2  1997/06/16 23:15:51  buhrt
 * merged PC & Unix versions
 * */

#include <stdlib.h>
#include <memory.h>
#include "byteswap.h"

/*
*       Screen Panel Comp Data Control Structure
*/

typedef struct
{
        unsigned        offset;
        unsigned        size;
} Panel_Comps;

static Panel_Comps comp_table[] =
{
        {   8, 2 },     /* Number of Fields     */
        {  11, 2 },     /* Active Color         */
        {  13, 2 },     /* Error Color          */
        {  15, 2 },     /* Menu Color           */
        { 177, 2 },     /* Display Option       */
        { 179, 2 },     /* Cursor Field         */
        { 182, 2 },     /* Cursor Offset        */
        { 184, 2 },     /* Exit Key             */
        { 213, 2 },     /* Border Color         */
        { 215, 2 },     /* Present Frequency    */
        { 217, 2 },     /* Present Time         */
        { 219, 2 },     /* Error Frequency      */
        { 221, 2 },     /* Error Time           */
        { 225, 2 },     /* Filler               */
        { 227, 2 },     /* Filler               */
        { 229, 2 },     /* Filler               */
        { 236, 2 },     /* Cursor Row           */
        { 238, 2 }      /* Cursor Column        */
};

static short table_items = sizeof(comp_table)/sizeof(comp_table[0]);

static short   initial_field_color = 317;      /* Initial Field Color  */
static short   field_color_increment = 4;      /* # bytes to next      */

/**********************************************************************
*    Function: swap_bytes
*     Purpose: Reverse the order of bytes in an integer
*      Return: None
*  Arguements: target -> pointer to first byte of "integer" to be swapped
*              size   -> sizeof the "integer"
*
*       Notes: This is a DESTRUCTIVE routine.
*
**********************************************************************/

void
swap_bytes ( void *target, size_t size )
{
    size_t i;
    char *cp, c;

    cp = (char *)target;

    for ( i = 0; i < size/2; i++ )
    {
        c = cp[i];
        cp[i] = cp[size - i - 1];
        cp[size - i - 1] = c;
    }

    return;
} /* swap_bytes () */

/**********************************************************************
*    Function: fix_comps
*     Purpose: Byte-flip all COMP-5 fields in the Screen Panel data area
*      Return: None
*  Arguements: panel -> pointer to the screen panel data
*              flag  -> 0 = Do not swap the field count bytes
*                       1 = Swap the field byte count bytes
*                       2 = Do not swap any of the field color bytes
*                           (This is for UNIX playback from DOS file)
*
*       Notes: This is a DESTRUCTIVE routine.
*
**********************************************************************/

void
fix_comps ( void *panel , int flag )
{
    char *pp;
    int  i;
    short  field_count;

    RCSid = NULL;                       /* Kill compiler complaint */

    pp = (char *)panel;

    for ( i = 0; i < table_items; i++ )
        swap_bytes (pp + comp_table[i].offset, comp_table[i].size);

    if ( flag != 2 )
    {                                   /* If not for playback on unix */
        memcpy (&field_count, pp + 8, 2);

        if ( flag )
            swap_bytes(&field_count, 2);

        i = 0;
        while ( field_count-- )
        {
            swap_bytes (pp + initial_field_color + i, 2);
            i += field_color_increment;
        }
    }

    return;

} /* fix_comps () */


/* byteswap.c */
