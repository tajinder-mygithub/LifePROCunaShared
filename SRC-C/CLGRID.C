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

/*************************************************************************** 
*
*
*  PROGRAM:   CLGRID
*
*  PURPOSE:   This program generates FGRIDPPI.PDM, this file can be printed
*             using CLPOLPRT to produce a grid to align X/Y coordinates
*
*  AUTHOR :   David J. Overholt
*
*  DATE   :   7/24/95
*
*  SR#            INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  950626-005-02  DJO    09-18-95    Added  ^IMAGE to print through pprntrpt
*  970327-006-01  DJO    04-28-97    Modified to run under Windows 95/NT
*20000526-026-06  ADA    06/19/2000  changed output filename to upper case
***************************************************************************/
/***************************************************************************

# makefile for clgrid

.c.obj:
   cl /W3 /c $*.c


clgrid.exe:  clgrid.obj
 link clgrid.obj /out:clgrid.exe

clgrid.obj: clgrid.c 

***************************************************************************/
#include <conio.h>
#include <stddef.h>
#include <stdio.h>
#include <dos.h>
#include <stdlib.h>
#include <memory.h>
#include <malloc.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include <process.h>
#include <errno.h>

void main(int argc, char *argv[])
{
  int i, j;
  char *tmpFile="FGRIDPPI.PDM";
  int pclFile;
  char buffer[90];


    if ((pclFile = open(tmpFile, O_TEXT | O_WRONLY | O_TRUNC | O_CREAT, S_IREAD | S_IWRITE )) < 0)
    {
       printf("Can't open file %s, %d\n", tmpFile, errno);
    }

    write (pclFile, "^IMAGE\n", 7);
    write (pclFile, "E\n", 3);
//    write (pclFile, "(s1P&l6D\n", 11);
    write (pclFile, "^P\n", 3);
    write (pclFile, "^'\n", 3);


  for (i=5;i<=107;i+=5)
  {
      sprintf(buffer, "^{%4.4d%4.4d\n%3d", 0, i,i);
      write (pclFile, buffer, strlen(buffer));
      for(j=0;j<80;j++)
        *(buffer+j) = '_';

      *(buffer+j++) = '\n';
      *(buffer+j) = '\0';
      write (pclFile, buffer, strlen(buffer));
      write (pclFile, "^}\n", 3);
  }

  for (i=5;i<=80;i+=5)
  {
      sprintf(buffer, "^{%4.4d0106\n%d\n^}\n", i,i);
      write (pclFile, buffer, strlen(buffer));
      for(j=0;j<=68;j++)
      {
        sprintf(buffer, "^{%4.4d\n|\n^}\n", i);
        write (pclFile, buffer, strlen(buffer));
      }

  }
  write (pclFile, "\n", 2);
  close(pclFile);
}
