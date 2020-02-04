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
/***************************************************************************
*
*
*  PROGRAM:   clnoEOF.c
*
*  PURPOSE:   Removes ASCII 26 (^Z) End Of File marker from file argument 1
*             This is only called for ULPRO policy pages
*
*  AUTHOR :   David J. Overholt
*
*  DATE   :   05/08/96
*
*  SR #          INITIALS  DATE      DESCRIPTION
*  -----------------------------------------------------------------------
*  960308-028-01  DJO      10/04/96  Initial version  
*
***************************************************************************/
/***************************************************************************
#
# Makefile for CLNOEOF.C - Compiled for MS C Version 7.0
#

.c.obj:
# dos
            cl -c -AS -W3 $*.c

clnoeof.exe : clnoeof.obj 
           link /E clnoeof.obj, clnoeof.exe;

clnoeof.obj : clnoeof.c
***************************************************************************/

#include "lpcopyrt.h"


#include <conio.h>
#include <stddef.h>
#include <stdio.h>
#include <dos.h>
#include <bios.h>
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
#include <graph.h>
int renameFile(char *p);
int copyBuf(char *i, char *o, int len);
int removeEOF(char *p);
void main(int argc, char *argv[]);

#define  EOF_CHAR       (char )26  /* EOF ^Z <- */
#define  BUFFERLENGTH         4096

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

void main(int argc, char *argv[])
{

  if (argc != 2)
  {
     printf ("Usage: clnoeof <FileName>\n");
     exit;
  }

  if (renameFile(argv[1]))
  {
     removeEOF(argv[1]);
  }
}

/****************************************************************************
*
* Rename the orginal file. Change the character to a 'x' i.e. fwxyzupg.pdm to
*                                                             fwxyzupg.pdx
*
****************************************************************************/
int renameFile(char *p)
{
char *tmpFile;
int retval=TRUE;

  tmpFile = (char *)malloc(strlen(p)+1);
  if (tmpFile == NULL)
  {
     printf("Out of memory\n");
     retval=FALSE;
  }
  else
  {
     strcpy(tmpFile, p);
     *(tmpFile + strlen(tmpFile)-1) = 'x';
     unlink(tmpFile);
     if (rename(p, tmpFile) != 0)
     {
        printf("Could not rename %s\n", p);
        retval=FALSE;
     }
  }

  free(tmpFile);
  return(retval);
}

/****************************************************************************
*
* removeEOF Reads from the copy of the file and writes back to orginal file
*
****************************************************************************/
int removeEOF(char *p)
{
int fdIn, fdOut, cc;
char *tmpFile;
char *inBuf, *outBuf;
int retval=TRUE;


  inBuf= (char *)malloc(BUFFERLENGTH+1);
  outBuf= (char *)malloc(BUFFERLENGTH+1);
  tmpFile = (char *)malloc(strlen(p)+1);
  if (inBuf == NULL || outBuf == NULL || tmpFile == NULL)
  {
     printf("Out of memory\n");
     retval=FALSE;
  }
  else
  {
     strcpy(tmpFile, p);
     *(tmpFile + strlen(tmpFile)-1) = 'x';
     fdOut = open(p, O_CREAT | O_TRUNC | O_BINARY | O_WRONLY , S_IREAD | S_IWRITE );
     fdIn = open(tmpFile, O_RDONLY | O_BINARY);
     if (fdIn > 0 && fdOut > 0)
     {
        cc=read(fdIn, inBuf, BUFFERLENGTH);
        while (cc > 0)
        {

           cc=copyBuf(inBuf, outBuf, cc);
           write(fdOut, outBuf, strlen(outBuf));
           if (cc>0)
              cc=read(fdIn, inBuf, BUFFERLENGTH);
        }
     }
     else
     {
        printf("Could open file %s\n", tmpFile);
        retval=FALSE;
     }
  }



  free(inBuf);
  free(outBuf);
  free(tmpFile);
  close(fdIn);
  close(fdOut);
  unlink(tmpFile);
  return(retval);
}
//-- Copy i to o execpt for the EOF_CHAR character
int copyBuf(char *i, char *o, int len)
{
  for(;len>0 && *i != EOF_CHAR;len--)
        *o++=*i++;

  *o='\0';
  return(*i == EOF_CHAR ? -1 : 1);

}

