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
*  PROGRAM  :   CLPPAR32
*
*  PURPOSE  :   Archives policy pages (cloned from CLPPARCH, compiled for x86) 
*
*  ARGUMENTS:   Argument 
*                 1 -  S Set position, A Perform Archive, C Copy Archive,
*                      D emulates a DOS copy (Destination, Source)
*                 2 -  File Name (including path)
*                 3 -  Archive File
*
*  AUTHOR   :   David J. Overholt
*
*  DATE     :   10/28/95
*
*  SR #            INITIALS  DATE      DESCRIPTION
*  -----------------------------------------------------------------------
*  20090304-005-01   DAR   04/10/09    Program Creation (cloned from CLPPARCH)
*    
*
***************************************************************************
***************************************************************************
*  
***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#ifndef UNIX
#include <io.h>
#endif
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef UNIX
#include <utime.h>
#else
#include <sys/utime.h>
#endif

#define MAXLINELENGTH 512


//#define DEBUG 1
#if DEBUG
int __near __cdecl volatile errno;
#endif

int setPosition(char *fileName, char *archiveFile);
int archiveFile(char *fileName, char *archiveFile);
int appendCopy(char *s, char *d, int fMode);

#if defined (WIN32)
int __declspec(dllexport) _cdecl
#elif defined (UNIX)
int
#else
int _loadds _export
#endif
 CLPPAR32(char *function, char *pgFileName, char *archFileName)

{
  int cc;
#ifdef UNIX
  struct stat fileStat;
  struct utimbuf timeBuf;
#else
  struct _stat fileStat;
  struct _utimbuf timeBuf;
#endif

  switch(function[0])
  {
     case 'S':
#       ifdef DEBUG
           printf ("\n calling setposition %s %s\n", pgFileName, archFileName);
#       endif
        cc=setPosition(pgFileName, archFileName);
     break;
     case 'A':
#       ifdef DEBUG
           printf ("\n calling archiveFile %s %s\n", pgFileName, archFileName);
#       endif
        cc=archiveFile(pgFileName, archFileName);
     break;
     case 'D':
        unlink (pgFileName);
     case 'C':
#       ifdef DEBUG
           printf ("\n calling appendCopy %s %s\n", pgFileName, archFileName);
#       endif
        // Copy pgFileName to archFileName
#       ifdef UNIX
        if((cc=appendCopy(archFileName, pgFileName, 0))>0)
#       else
        if((cc=appendCopy(archFileName, pgFileName, function[0] == 'C' ? _O_TEXT : _O_BINARY))>0)
#       endif
            break;
        if (function[0] == 'D')
        {
#          ifdef UNIX
           if (stat(pgFileName, &fileStat) == 0)
#          else
           if (_stat(pgFileName, &fileStat) == 0)
#          endif
           {
              timeBuf.actime  = fileStat.st_atime;
              timeBuf.modtime = fileStat.st_mtime;
#             ifdef UNIX
              utime(archFileName, &timeBuf);
#             else
              _utime(archFileName, &timeBuf);
#             endif
           }
        }
     break;
  }

  return(cc);
}

/****************************************************************************
*
* archiveFile 
*
****************************************************************************/
int setPosition(char *fileName, char *archiveFile)
{
FILE *filePtr;
long savePos;
int cc;


  if ((filePtr= fopen(fileName, "rt")) != NULL)
  {
     // Get the Offset for the end of file
     fseek( filePtr, -1, SEEK_END );
     savePos = ftell(filePtr);
     if ((cc = getc(filePtr)) != 26)
        savePos++; // Cobol puts that nasty ^Z must backSpace 1

     fclose(filePtr);
  }
  else
  {
#    ifdef DEBUG
        printf ("Could not open %s error %d\n", fileName, ferror(filePtr));
#    endif
     savePos=0L; // New Policy Page file
  }

#    ifdef DEBUG
        printf ("\nSavePos = %ld\n", savePos);
#    endif

  if ((filePtr= fopen(archiveFile, "w")) == NULL)
  {
        return 2;
  }

  cc=fwrite(&savePos, sizeof(savePos), 1, filePtr);

  fclose(filePtr);


   return (cc < 1 ? 8 : 0);

}
/****************************************************************************
*
* archiveFile 
*
****************************************************************************/
int archiveFile(char *fileName, char *archiveFile)
{
FILE *archivePtr;
FILE *policyPagePtr;
long savePos, charRead;
int cc=0;
char line[MAXLINELENGTH+1];
char *ptr;

  // Get Offset
  if ((archivePtr= fopen(archiveFile, "r")) == NULL)
     return  3;

  charRead=fread(&savePos, sizeof(savePos), 1, archivePtr);

  fclose(archivePtr);

  if (charRead < 1)
     return  4;



  if ((policyPagePtr= fopen(fileName, "rt")) == NULL)
     return  5;

  fseek(policyPagePtr, savePos, SEEK_SET);

  if ((archivePtr= fopen(archiveFile, "wt")) == NULL)
  {
     fclose(policyPagePtr);
     return  6;
  }

  memset(line, 0x00, sizeof(line));
  if ((ptr = fgets(line, MAXLINELENGTH, policyPagePtr)) == NULL)
  {
     cc=ferror(policyPagePtr);
     fclose(archivePtr);
     fclose(policyPagePtr);
     return  7;
  }


  while(ptr != NULL && cc >= 0)
  {
     cc = fputs(line, archivePtr);
     ptr = fgets(line, MAXLINELENGTH, policyPagePtr);
  }

  fclose(policyPagePtr);

  fclose(archivePtr);

  return(cc < 0 ? 14 : 0);



}
#define  READ_BLOCK   4096
/****************************************************************************
*
* Append-copy
*
****************************************************************************/
int appendCopy(char *s, char *d, int fMode)
{
 int input, output;
 char *ptr;
 int cc;
 int co=1;
 long pos;


  ptr = (char *)malloc(READ_BLOCK+1);
  if (ptr == NULL)
  {
     return  13;
  }
  memset(ptr, 0x00, READ_BLOCK+1);

#ifdef UNIX
  if ((input=open(s, O_RDONLY | fMode)) < 0)
#else
  if ((input=open(s, _O_RDONLY | fMode)) < 0)
#endif
  {
     free(ptr);
     return  9;
  }
#ifdef UNIX
  if ((output=open(d, O_RDWR | O_CREAT | fMode, S_IREAD | S_IWRITE)) < 0)
#else
  if ((output=open(d, _O_RDWR | _O_CREAT | fMode, _S_IREAD | _S_IWRITE)) < 0)
#endif
  {
     free(ptr);
     close(input);
     return  10;
  }

  pos=lseek(output, 0, SEEK_END);
  cc = read(input, ptr, READ_BLOCK);
  if (cc < 0)
  {
     free(ptr);
     close(input);
     close(output);
     return  12;
  }
  while (cc > 0 && co > 0)
  {
     co = write(output, ptr, cc);
     cc = read(input, ptr, READ_BLOCK);
  }


  free(ptr);
  close(input);
  close(output);
  return (co <= 0 ? 11 : 0);
}
