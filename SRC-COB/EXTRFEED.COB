      *$CALL
       IDENTIFICATION  DIVISION.
       PROGRAM-ID.     EXTRFEED.
       AUTHOR.         DOUGLAS WEAVER.
       DATE-WRITTEN.   APRIL 1, 2000.
       DATE-COMPILED.
      *@**20100811*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20100811*******************************************
      *D****************************************************************
      *D         PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D   EXTRFEED
      *D
      *H****************************************************************
      *H        PROGRAM HISTORY
      *H****************************************************************
      *H
050400*H 000308-002-01 DJW New Program
050400*H 000501-015-01 DJW New Program
050400*H 20000630-021-01 RCE Commission Calculator Agency Feed - Real
050400*H                 date for this change was 081500 but the change
050400*H                 was same as 050400 changes listed above for.
050400*H                 Central States.
      *H
      *H****************************************************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AT.
       OBJECT-COMPUTER. IBM-AT.
       SPECIAL-NAMES.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************

           COPY WWSCRCPY.

      ******************************************************************
       LINKAGE SECTION.

       COPY WGLOBCPY.

      ******************************************************************
       PROCEDURE DIVISION USING WGLOBAL.
      ******************************************************************
      *
      *  Program mainline section
      *
      ******************************************************************
       0000-MAINLINE.

           INITIALIZE WFUNC-RETURN-CODE.

           EXIT PROGRAM.

      ******************************************************************
      *                                                                *
      *                    E N D   O F   S O U R C E                   *
      *                                                                *
      ******************************************************************
