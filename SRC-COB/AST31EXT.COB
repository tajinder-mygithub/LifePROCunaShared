010996*$CALL
       IDENTIFICATION  DIVISION.
050102 PROGRAM-ID.     AST31EXT.
       AUTHOR.         BOYNTON.
       DATE-WRITTEN.   JUNE 10, 1996.
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
      *
      *D**********************************************************
      *D         PROGRAM DESCRIPTION
      *D**********************************************************
      *D
      *D Linkage is passed to this program from PMPANS31.  The
      *D client will use this shell in order to develop their own
      *D annual statement.
      *D
      *D**********************************************************

      *H**********************************************************
      *H        PROGRAM HISTORY
      *H**********************************************************
      *H
061096*H 941027-010-01 REB New program.
072696*H 941027-010-08 REB Print changes to zero premium.
111197*H 970929-005-01 MAK Automated changes for IBM compilers compatibility
03XX99*H 980722-026-02 P10 AUTOMATED NLS/MESSAGING CONVERSION
01FF02*H 20020124-001-01 RDE Fujitsu port (may include automated changes)
021102*H 20020124-001-01 WDS Changes to remove drive mappings for
021102*H                     the new BAPI project.
050102*H 20020124-001-01 SES Change Program ID causing Fujitsu Run-time error
      *H
      *H**********************************************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AT.
       OBJECT-COMPUTER. IBM-AT.
      *                     SEGMENT-LIMIT IS 1.
       SPECIAL-NAMES.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

110197*    SELECT EXTRACT-FILE ASSIGN TO
110197     SELECT EXTRACT-FILE
       COPY WVARYCPY.
                                       EXTRACT-FILE-NAME
01FF02*                                ORGANIZATION IS SEQUENTIAL
01FF02 COPY WLORGCPY.
                                       STATUS IS EXTRACT-STATUS.

      ************************************************************
      *         FILE DEFINITIONS
      ************************************************************
       DATA DIVISION.
       FILE SECTION.

       FD EXTRACT-FILE
111197*    LABEL RECORDS ARE STANDARD.
111197      .
       01 EXTRACT-RECORD                  PIC X(132).

      ************************************************************
      *         FILE LAYOUTS
      ************************************************************
       WORKING-STORAGE SECTION.
112098
112098     COPY WWSCRCPY.
112098

       01  CALLED-MODULES.
           05  PFILEINS                   PIC X(08) VALUE 'PFILEINS'.
03XX99     05  PGETMESG                   PIC X(08) VALUE 'PGETMESG'.

       01 EXTRACT-STATUS                  PIC X(02).
       01 EXTRACT-FILE-NAME.
           05 WS-EXTRACT-FILE-DRIVE       PIC X(01) VALUE 'H'.
           05 FILLER                      PIC X(01) VALUE ':'.
           05 FILLER                      PIC X(01) VALUE 'R'.
           05 EXTRACT-CODER               PIC X(04) VALUE '____'.
           05 FILLER                      PIC X(07) VALUE 'U01.PDM'.
021102     05  FILLER                  PIC X(241) VALUE SPACES.

021102*01 WS-ASCII-FILE-NAME              PIC X(50).
021102 01 WS-ASCII-FILE-NAME              PIC X(255).
021102 01 WS-NEW-ASCII-FILE-NAME          PIC X(255).
       01 IDX                             PIC 9(02).
       01 IDX-X REDEFINES IDX             PIC X(02).
03XX99 COPY WGETMCPY.

      ******************************************************************
       LINKAGE SECTION.

       COPY WGLOBCPY.
       COPY WLK31CPY.

      ******************************************************************
      ******************************************************************
       PROCEDURE DIVISION USING WGLOBAL
                                WLK31-LINKAGE-RECORD.

      ******************************************************************
       0000-MAIN-LOGIC.

           IF NOT PRELOADING-PROGRAM
               PERFORM 1000-INITIALIZE
               PERFORM 2000-PROCESS.

       0000-MAIN-LOGIC-EXIT.
           EXIT PROGRAM.

      ******************************************************************
       1000-INITIALIZE.

           MOVE WCODER-ID              TO EXTRACT-CODER.
           INSPECT EXTRACT-CODER REPLACING ALL ' ' BY '_'.
           MOVE WOPTION-WORK-DRIVE     TO WS-EXTRACT-FILE-DRIVE.

           MOVE EXTRACT-FILE-NAME      TO WS-ASCII-FILE-NAME.

           CALL PFILEINS USING WGLOBAL
021102*                        WS-ASCII-FILE-NAME.
021102                         WS-ASCII-FILE-NAME
021102                         WS-NEW-ASCII-FILE-NAME
021102     END-CALL.

021102*    MOVE WS-ASCII-FILE-NAME     TO EXTRACT-FILE-NAME.
021102     MOVE WS-NEW-ASCII-FILE-NAME TO EXTRACT-FILE-NAME.
           CANCEL PFILEINS.
           MOVE 'AM'                   TO WFUNC-FUNCTION.
           CALL POPFUNCN USING WGLOBAL.

111197*    EXIT.

      ******************************************************************
       2000-PROCESS.

           PERFORM 2100-INIT-EXTRACT-FILE.
           IF EXTRACT-STATUS = '00'
               PERFORM 3000-WRITE-DATA
           END-IF.
           CLOSE EXTRACT-FILE.

111197*    EXIT.

      ******************************************************************
       2100-INIT-EXTRACT-FILE.

           OPEN EXTEND EXTRACT-FILE.

           IF EXTRACT-STATUS NOT = '00'
               CLOSE EXTRACT-FILE
               OPEN OUTPUT EXTRACT-FILE
           END-IF.

111197*    EXIT.

      ******************************************************************
       3000-WRITE-DATA.

03XX99*    MOVE '** POLICY INFO **'             TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028447 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-POLICY-INFO               TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

03XX99*    MOVE '** INSURED INFO **'            TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028448 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-INSURED-INFO(1:132)       TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-INSURED-INFO(133:)        TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

03XX99*    MOVE '** POLICY OWNER INFO **'       TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028449 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-POLICY-OWNER-INFO(1:132)  TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-POLICY-OWNER-INFO(133:)   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

03XX99*    MOVE '** SERVICE AGENT INFO **'      TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028450 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-SERVICE-AGENT-INFO        TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

03XX99*    MOVE '** PART #2 INFO **'            TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028451 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-PART2-INFO(1:132)         TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-PART2-INFO(133:)          TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

03XX99*    MOVE '** PART #3 INFO (BENEFIT PREMIUM CHANGES) **'
03XX99*                                         TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028452 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           PERFORM VARYING IDX FROM 1 BY 1
               UNTIL IDX > 98
               IF WLK31-BEN-CHG-PREMIUM (IDX) NOT = ZERO
072696         OR WLK31-BEN-CHG-COVERAGE(IDX) NOT = SPACES
072696         OR WLK31-BEN-CHG-REASON  (IDX) NOT = SPACES
03XX99*            MOVE 'BENEFIT #'             TO EXTRACT-RECORD
03XX99             INITIALIZE WGETM-PARAMETERS
03XX99             MOVE 000028453 TO WGETM-MESSAGE-NUMBER
03XX99             CALL PGETMESG USING WGLOBAL
03XX99                                 WGETM-PARAMETERS
03XX99             MOVE WGETM-MESSAGE           TO EXTRACT-RECORD
                   MOVE IDX-X                   TO EXTRACT-RECORD(10:2)
                   MOVE ' - '                   TO EXTRACT-RECORD(12:3)
                   MOVE WLK31-BEN-CHG-INFO(IDX) TO EXTRACT-RECORD(15:)
                   WRITE EXTRACT-RECORD
               END-IF
           END-PERFORM.

03XX99*    MOVE '** PART #3 INFO (NEW PREMIUMS) **'
03XX99*                                         TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028454 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE                   TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.
           MOVE WLK31-NEW-PREMIUM-INFO          TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

111197*    EXIT.

      ******************************************************************
      *                                                                *
      *                      E N D   S O U R C E                       *
      *                                                                *
      ******************************************************************


