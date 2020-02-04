       IDENTIFICATION  DIVISION.
       PROGRAM-ID.     MUIBIL01.
       AUTHOR.         ROUT.
       DATE-WRITTEN.   SEPTEMBER 2013.
       DATE-COMPILED.
      *@**20130101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2013 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20130101*******************************************


      *D****************************************************************
      *D         PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D  Creates a list of active policies that are PAC or CRD with an 
      *D  active PAC record.
      *D
      *D  Trial run creates extract file with company code, policy
      *D  number, PAC form, generate bill date, and next anniversary
      *D
      *D  Update run reads the extract file created in the trial run
      *D  and creates/updates to IBIL records
      *D
      *D****************************************************************
      *H****************************************************************
      *H        PROGRAM HISTORY
      *H****************************************************************
      *H
090313*H 20121110-003-01 AKR Initial coding.
092413*H 20121110-003-02 AKR Separated PAC & CRD Processing (full re-do)
100413*H 20121110-003-07 AKR Update processing missing last record
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.
      ******************************************************************

      ******************************************************************
       CONFIGURATION SECTION.
      ******************************************************************

       SOURCE-COMPUTER. IBM-AT.

       OBJECT-COMPUTER. IBM-AT.

       SPECIAL-NAMES.

      ******************************************************************
       INPUT-OUTPUT SECTION.
      ******************************************************************

       FILE-CONTROL.

           SELECT EXTRACT-FILE-P
       COPY WVARYCPY.
                                 WS-EXTRACT-FILE-P
       COPY WLORGCPY.
                               STATUS IS WS-EXTRACT-STATUS-P.

           SELECT EXTRACT-FILE-C
       COPY WVARYCPY.
                                 WS-EXTRACT-FILE-C
       COPY WLORGCPY.
                               STATUS IS WS-EXTRACT-STATUS-C.

           SELECT REPORT-FILE-P
       COPY WVARYCPY.
                                 WS-REPORT-FILE-P
       COPY WLORGCPY.
                               STATUS IS WS-REPORT-STATUS-P.

           SELECT REPORT-FILE-C
       COPY WVARYCPY.
                                 WS-REPORT-FILE-C
       COPY WLORGCPY.
                               STATUS IS WS-REPORT-STATUS-C.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************

      ******************************************************************
       FILE SECTION.
      ******************************************************************

       FD  EXTRACT-FILE-P
           DATA RECORD IS EXTRACT-RECORD-P.
       01  EXTRACT-RECORD-P.
           05 FILLER                      PIC X(80).

       FD  REPORT-FILE-P
           DATA RECORD IS REPORT-RECORD-P.
       01  REPORT-RECORD-P.
           05  FILLER                     PIC X(80).

       FD  EXTRACT-FILE-C
           DATA RECORD IS EXTRACT-RECORD-C.
       01  EXTRACT-RECORD-C.
           05 FILLER                      PIC X(80).

       FD  REPORT-FILE-C
           DATA RECORD IS REPORT-RECORD-C.
       01  REPORT-RECORD-C.
           05  FILLER                     PIC X(80).

      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************

           COPY WWSCRCPY.

       01  PGETMESG                       PIC X(08)  VALUE 'PGETMESG'.
       01  PFILEBTV                       PIC X(08)  VALUE 'PFILEBTV'.
       01  PFILEINS                       PIC X(08)  VALUE 'PFILEINS'.
       01  SCREENIO                       PIC X(08)  VALUE 'SCRNIO'.
       01  PFUNCMNU                       PIC X(08)  VALUE 'PFUNCMNU'.
       01  PDATECON                       PIC X(08)  VALUE 'PDATECON'.
       01  PVHSTSQL                       PIC X(08)  VALUE 'PVHSTSQL'.

      ******************************************************************

       01  WFUNCTION                      PIC 9(02) COMP-5.
       01  WKEY-NUMBER                    PIC 9(03) COMP-5.
       01  WKEY-DISPLAY                   PIC 9(02) VALUE ZEROS.

       01  WS-EXTRACT-RECORD.
           05  EXT-COMPANY-CODE           PIC X(02).
           05  FILLER                     PIC X(02).
           05  EXT-POLICY-NUMBER          PIC X(12).
           05  FILLER                     PIC X(02).
           05  EXT-BILLING-FORM           PIC X(03).
           05  FILLER                     PIC X(02).
           05  EXT-NEXT-BILL-GEN-DATE     PIC 9(08).
           05  FILLER                     PIC X(02).
           05  EXT-NEXT-ANNIV-DATE        PIC 9(08).
           05  FILLER                     PIC X(39).

       01  WS-EXTRACT-FILE-P.
           05  WS-EXTR-DRIVE-P     PIC X(01) VALUE 'F'.
           05  FILLER              PIC X(01) VALUE ':'.
           05  FILLER              PIC X(15) VALUE 'MUIBILPA.TXT'.
           05  FILLER              PIC X(238) VALUE SPACES.

       01  WS-EXTRACT-FILE-C.
           05  WS-EXTR-DRIVE-C     PIC X(01) VALUE 'F'.
           05  FILLER              PIC X(01) VALUE ':'.
           05  FILLER              PIC X(15) VALUE 'MUIBILCR.TXT'.
           05  FILLER              PIC X(238) VALUE SPACES.

       01  WS-REPORT-FILE-P.
           05  WS-REPORT-DRIVE-P   PIC X(01) VALUE 'F'.
           05  FILLER              PIC X(01) VALUE ':'.
           05  FILLER              PIC X(15) VALUE 'MUIBILPA.PDM'.
           05  FILLER              PIC X(238) VALUE SPACES.

       01  WS-REPORT-FILE-C.
           05  WS-REPORT-DRIVE-C   PIC X(01)  VALUE 'F'.
           05  FILLER              PIC X(01)  VALUE ':'.
           05  FILLER              PIC X(15)  VALUE 'MUIBILCR.PDM'.
           05  FILLER              PIC X(238) VALUE SPACES.

       01  WS-FILE-FLAGS.
           05  WS-EXTRACT-STATUS-P        PIC X(02)  VALUE SPACES.
               88  WS-EXTRACT-FILE-OK-P              VALUE '00'.
               88  WS-EXTRACT-EOF-P                  VALUE '10'.
               88  WS-EXTRACT-FILE-NOT-FOUND-P       VALUE '35'.
           05  WS-EXTRACT-STATUS-C        PIC X(02)  VALUE SPACES.
               88  WS-EXTRACT-FILE-OK-C              VALUE '00'.
               88  WS-EXTRACT-EOF-C                  VALUE '10'.
               88  WS-EXTRACT-FILE-NOT-FOUND-C       VALUE '35'.
           05  WS-REPORT-STATUS-P         PIC X(02)  VALUE SPACES.
               88  WS-REPORT-FILE-OK-P               VALUE '00'.
           05  WS-REPORT-STATUS-C         PIC X(02)  VALUE SPACES.
               88  WS-REPORT-FILE-OK-C               VALUE '00'.
           05  WPOLC-EOF-FLAG             PIC X(01)  VALUE 'N'.
               88  EOF-WPOLC                         VALUE 'Y'.
           05  WVHST-EOF-FLAG             PIC X(01)  VALUE 'N'.
               88  EOF-WVHST                         VALUE 'Y'.
           05  EXTRACT-EOF-FLAG-P         PIC X(01)  VALUE 'N'.
               88  EOF-EXTRACT-P                     VALUE 'Y'.
           05  EXTRACT-EOF-FLAG-C         PIC X(01)  VALUE 'N'.
               88  EOF-EXTRACT-C                     VALUE 'Y'.
           05  WS-EXTRACT-FILE-FLAG-P     PIC X(01)  VALUE SPACES.
               88  WS-EXTRACT-FILE-EXISTS-P          VALUE 'Y'.
           05  WS-EXTRACT-FILE-FLAG-C     PIC X(01)  VALUE SPACES.
               88  WS-EXTRACT-FILE-EXISTS-C          VALUE 'Y'.
           05  WS-ACTIVE-LOAN-FLAG        PIC X(01)  VALUE SPACES.
               88  ACTIVE-LOAN                       VALUE 'Y'.
               88  NO-LOAN                           VALUE 'N'.
           05  WS-USING-PAID-TO-DATE      PIC X(01)  VALUE SPACES.

       01  WS-ASCII-FILE-NAME             PIC X(255) VALUE SPACES.
       01  WS-NEW-ASCII-FILE-NAME         PIC X(255) VALUE SPACES.

       01  WS-RETURN-CODE                 PIC 9(04)  VALUE ZEROS.
           88  WS-PROCESSING-OK                      VALUE ZEROS.
           88  WS-PROCESSING-ERROR                   VALUE 0001
                                                     THRU 9999.
       01  WS-ERROR-MESSAGE               PIC X(80)  VALUE SPACES.

       01  CONCATENATE-ERROR.
           05  FILLER                     PIC X(01)  VALUE SPACES.
           05  SUBJECT-IN-ERROR           PIC X(05)  VALUE SPACES.
           05  FILLER                     PIC X(01)  VALUE SPACES.
           05  KEY-IN-ERROR               PIC X(30)  VALUE SPACES.

       01  WS-UPDATE-CNT-P                PIC 9(9)   VALUE 0 COMP-5.
       01  WS-UPDATE-CNT-C                PIC 9(9)   VALUE 0 COMP-5.
       01  WS-UPDATE-CNT-T                PIC 9(9)   VALUE 0 COMP-5.

       01  WS-EXT-COVERAGE-ID             PIC X(10)  VALUE SPACES.
       01  WS-COVERAGE-ID                 PIC X(10)  VALUE SPACES.
       01  WS-XREF-FLAG                   PIC X(01)  VALUE SPACES.
       01  WS-ISS-SUBST-FLAG              PIC X(01)  VALUE SPACES.
       01  WS-EFF-SUBST-FLAG              PIC X(01)  VALUE SPACES.
       01  WS-COVERAGE-ID-DESC            PIC X(20)  VALUE SPACES.
       01  WS-WOPTION-BILL-DUE-DAYS       PIC 9(03).
       01  WS-LOAN-BILLING-DIR-FLAG       PIC X(01)  VALUE SPACES.
           88  BILL-LOAN-INT-DIR                     VALUE 'Y'.

       01  WS-NEXT-ANNIVERSARY-DATE       PIC 9(08).
       01  WS-NEXT-ANNIVERSARY-RE REDEFINES WS-NEXT-ANNIVERSARY-DATE.
           05  WS-NEXT-ANNIV-YY           PIC 9(04).
           05  WS-NEXT-ANNIV-MM           PIC 9(02).
           05  WS-NEXT-ANNIV-DD           PIC 9(02).
       01  WS-EFFECTIVE-DATE              PIC 9(08).
       01  WS-EFFECTIVE-DATE-RE REDEFINES WS-EFFECTIVE-DATE.
           05  WS-EFFECTIVE-YY            PIC 9(04).
           05  WS-EFFECTIVE-MM            PIC 9(02).
           05  WS-EFFECTIVE-DD            PIC 9(02).
       01  WS-NEXT-BILL-GEN-DATE          PIC 9(08).
       01  WS-NEXT-BILL-GEN-RE REDEFINES WS-NEXT-BILL-GEN-DATE.
           05  WS-NEXT-BILL-YY            PIC 9(04).
           05  WS-NEXT-BILL-MM            PIC 9(02).
           05  WS-NEXT-BILL-DD            PIC 9(02).

       01  CURRENT-DATE                   PIC X(08) VALUE SPACES.
       01  FILLER REDEFINES CURRENT-DATE.
           05  CURR-YR                    PIC 9(04).
           05  CURR-MN                    PIC 9(02).
           05  CURR-DY                    PIC 9(02).
       01  CURRENT-TIME                   PIC X(08) VALUE SPACES.
       01  FILLER REDEFINES CURRENT-TIME.
           05  CURR-HOUR                  PIC 9(02).
           05  CURR-MIN                   PIC 9(02).
           05  CURR-SEC                   PIC 9(02).
           05  CURR-HSEC                  PIC 9(02).

       01  PAGE-NUMBER-P                  PIC S9(4) VALUE 0 COMP-5.
       01  LINE-NUMBER-P                  PIC S9(4) VALUE 0 COMP-5.
       01  PAGE-NUMBER-C                  PIC S9(4) VALUE 0 COMP-5.
       01  LINE-NUMBER-C                  PIC S9(4) VALUE 0 COMP-5.

       01  HEADING1.
           05  FILLER                     PIC X(06) VALUE 'Date: '.
           05  HDG-MONTH                  PIC 9(02) VALUE ZEROS.
           05  FILLER                     PIC X(01) VALUE '/'.
           05  HDG-DAY                    PIC 9(02) VALUE ZEROS.
           05  FILLER                     PIC X(01) VALUE '/'.
           05  HDG-YEAR                   PIC 9(04) VALUE ZEROS.
           05  FILLER                     PIC X(08) VALUE SPACES.
100413     05  HDG-TYPE                   PIC X(03).
           05  FILLER                     PIC X(37) VALUE
100413         ' Interest - (IBIL) Creation Report'.
           05  FILLER                     PIC X(07) VALUE SPACES.
           05  FILLER                     PIC X(06) VALUE SPACES.
           05  HDG-PAGE-NUMBER            PIC ZZZZ9 VALUE ZEROS.
           05  FILLER                     PIC X(01) VALUE SPACES.

       01  HEADING2.
           05  FILLER                     PIC X(06) VALUE 'Time: '.
           05  HDG-HOUR                   PIC 9(02) VALUE ZEROS.
           05  FILLER                     PIC X(01) VALUE ':'.
           05  HDG-MIN                    PIC 9(02) VALUE ZEROS.
           05  FILLER                     PIC X(01) VALUE ':'.
           05  HDG-SEC                    PIC 9(02) VALUE ZEROS.
100413     05  FILLER                     PIC X(17) VALUE SPACES.
           05  HDG-SELECTION              PIC X(22) VALUE SPACES.
           05  FILLER                     PIC X(15) VALUE SPACES.
           05  FILLER                     PIC X(07) VALUE 'Coder:'.
           05  HDG-CODER-ID               PIC X(04) VALUE SPACES.
           05  FILLER                     PIC X(01) VALUE SPACES.

       01  DETAIL-HEADING1.
           05  FILLER                     PIC X(02) VALUE
               'Co'.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  FILLER                     PIC X(06) VALUE
               'Policy'.
           05  FILLER                     PIC X(09) VALUE SPACES.
           05  FILLER                     PIC X(04) VALUE
               'PAC '.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  FILLER                     PIC X(12) VALUE
               'Bill Gen'.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  FILLER                     PIC X(12) VALUE
               'Anniversary'.
           05  FILLER                     PIC X(24) VALUE SPACES.

       01  DETAIL-HEADING2.
           05  FILLER                     PIC X(28) VALUE SPACES.
           05  FILLER                     PIC X(05) VALUE
               'Date '.
           05  FILLER                     PIC X(12) VALUE SPACES.
           05  FILLER                     PIC X(05) VALUE
               'Date '.
           05  FILLER                     PIC X(34) VALUE SPACES.

       01  DETAIL-LINE.
           05  DET-COMPANY                PIC X(02) VALUE SPACES.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  DET-POLICY                 PIC X(12) VALUE SPACES.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  DET-BILLING-FORM           PIC X(03) VALUE SPACES.
           05  FILLER                     PIC X(03) VALUE SPACES.
           05  DET-NEXT-BILL-GEN          PIC X(08) VALUE SPACES.
           05  FILLER                     PIC X(05) VALUE SPACES.
           05  DET-NEXT-ANNIV-DATE        PIC X(08) VALUE SPACES.
           05  FILLER                     PIC X(05) VALUE SPACES.
           05  DET-LOAN-INT-INDICATOR     PIC X(01) VALUE SPACES.
           05  FILLER                     PIC X(02) VALUE SPACES.
           05  DET-MESSAGE                PIC X(20) VALUE SPACES.

       01  TOTAL-REPORTED-LINE.
           05  FILLER                     PIC X(30) VALUE
               'Total Policies Reported:'.
           05  TOT-POLICY-CNT             PIC ZZZ,ZZZ,ZZ9.
           05  FILLER                     PIC X(52) VALUE SPACES.

       01  DASH-LINE.
           05  FILLER                     PIC X(80) VALUE ALL '-'.

      ******************************************************************
      **   COPYBOOKS USED IN THIS PROGRAM
      ******************************************************************

       01  SIBIL-PARMS.
           05  SIBIL-FIELD-INDEX          PIC 9(03) VALUE ZEROS.
       COPY SIBILCPY.
       COPY WCTRLCPY.
       COPY WFMNUCPY.
       COPY WGETMCPY.
       COPY WFKEYCPY.
       COPY WAPPLCPY.
       COPY WBTRVCPY.
       COPY WDATECPY.
       COPY WVBOXCPY.
       COPY WVHSTCPY.
       COPY WPOLCCPY.
       COPY WAPPLCPY REPLACING
                   WAPPL-CALL-PARAMETERS  BY WPOLC-CALL-PARAMETERS
                   WAPPL-FUNCTION         BY WPOLC-FUNCTION
                   WAPPL-KEY-NUMBER       BY WPOLC-KEY-NUMBER
                   WAPPL-RETURN-CODE      BY WPOLC-RETURN-CODE
                   WAPPL-RETURN-NOT-OK    BY WPOLC-RETURN-NOT-OK.

       COPY WPPACCPY.
       COPY WAPPLCPY REPLACING
                   WAPPL-CALL-PARAMETERS  BY WPPAC-CALL-PARAMETERS
                   WAPPL-FUNCTION         BY WPPAC-FUNCTION
                   WAPPL-KEY-NUMBER       BY WPPAC-KEY-NUMBER
                   WAPPL-RETURN-CODE      BY WPPAC-RETURN-CODE
                   WAPPL-RETURN-NOT-OK  BY WPPAC-RETURN-NOT-OK.

       COPY WPCRDCPY.
       COPY WAPPLCPY REPLACING
                   WAPPL-CALL-PARAMETERS  BY WPCRD-CALL-PARAMETERS
                   WAPPL-FUNCTION         BY WPCRD-FUNCTION
                   WAPPL-KEY-NUMBER       BY WPCRD-KEY-NUMBER
                   WAPPL-RETURN-CODE      BY WPCRD-RETURN-CODE
                   WAPPL-RETURN-NOT-OK  BY WPCRD-RETURN-NOT-OK.

       COPY WPOLMCPY.
       COPY WAPPLCPY REPLACING
                   WAPPL-CALL-PARAMETERS  BY WPOLM-CALL-PARAMETERS
                   WAPPL-FUNCTION         BY WPOLM-FUNCTION
                   WAPPL-KEY-NUMBER       BY WPOLM-KEY-NUMBER
                   WAPPL-RETURN-CODE      BY WPOLM-RETURN-CODE
                   WAPPL-RETURN-NOT-OK    BY WPOLM-RETURN-NOT-OK.

       COPY WOPTNCPY.
       COPY WAPPLCPY REPLACING
               WAPPL-CALL-PARAMETERS  BY WOPTN-CALL-PARAMETERS
               WAPPL-FUNCTION         BY WOPTN-FUNCTION
               WAPPL-KEY-NUMBER       BY WOPTN-KEY-NUMBER
               WAPPL-RETURN-CODE      BY WOPTN-RETURN-CODE
               WAPPL-RETURN-NOT-OK    BY WOPTN-RETURN-NOT-OK.

       COPY WIBILCPY.
       COPY WAPPLCPY REPLACING
               WAPPL-CALL-PARAMETERS  BY WIBIL-CALL-PARAMETERS
               WAPPL-FUNCTION         BY WIBIL-FUNCTION
               WAPPL-KEY-NUMBER       BY WIBIL-KEY-NUMBER
               WAPPL-RETURN-CODE      BY WIBIL-RETURN-CODE
               WAPPL-RETURN-NOT-OK    BY WIBIL-RETURN-NOT-OK.

       COPY WLOANCPY.
       COPY WAPPLCPY REPLACING
                   WAPPL-CALL-PARAMETERS  BY WLOAN-CALL-PARAMETERS
                   WAPPL-FUNCTION         BY WLOAN-FUNCTION
                   WAPPL-KEY-NUMBER       BY WLOAN-KEY-NUMBER
                   WAPPL-RETURN-CODE      BY WLOAN-RETURN-CODE
                   WAPPL-RETURN-NOT-OK    BY WLOAN-RETURN-NOT-OK.


      ******************************************************************
       LINKAGE SECTION.

       COPY WGLOBCPY.
      ******************************************************************

      ******************************************************************
       PROCEDURE DIVISION USING WGLOBAL.
      ******************************************************************
       0000-MAINLINE.

           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS UNTIL END-KEY.

       0000-MAINLINE-EXIT.
           EXIT PROGRAM.

      ******************************************************************
       1000-INITIALIZE.

           PERFORM 1010-OPEN-EXTRACT-FILES
           PERFORM 1020-SET-UP-REPORT-FILES

           MOVE 'C'                    TO WDATE-FUNCTION
           CALL PDATECON USING WDATE-PARMS
           MOVE WDATE-STR-GREG-DATE    TO CURRENT-DATE

           MOVE 'T'                   TO SIBIL-D-TRIAL-OR-UPDATE
           MOVE 'A'                   TO SIBIL-INPUT-1
           MOVE ' '                   TO SIBIL-INPUT-1-O

           CONTINUE.

      ******************************************************************
       1010-OPEN-EXTRACT-FILES.

           MOVE WS-EXTRACT-FILE-P      TO WS-ASCII-FILE-NAME
           CALL PFILEINS USING            WGLOBAL
                                          WS-ASCII-FILE-NAME
                                          WS-NEW-ASCII-FILE-NAME
           END-CALL
           MOVE WS-NEW-ASCII-FILE-NAME TO WS-EXTRACT-FILE-P
           MOVE 'N'                    TO EXTRACT-EOF-FLAG-P
           OPEN INPUT EXTRACT-FILE-P

           MOVE WS-EXTRACT-FILE-C      TO WS-ASCII-FILE-NAME
           CALL PFILEINS USING            WGLOBAL
                                          WS-ASCII-FILE-NAME
                                          WS-NEW-ASCII-FILE-NAME
           END-CALL
           MOVE WS-NEW-ASCII-FILE-NAME TO WS-EXTRACT-FILE-C
           MOVE 'N'                    TO EXTRACT-EOF-FLAG-C
           OPEN INPUT EXTRACT-FILE-C

           IF  WS-EXTRACT-FILE-OK-P OR WS-EXTRACT-FILE-OK-P
               SET WS-EXTRACT-FILE-EXISTS-P TO TRUE
      *        'Warning:  Each Extract Completely
      *         Overlays The Previous Extract File'
               INITIALIZE WGETM-PARAMETERS
               MOVE 000028334          TO WGETM-MESSAGE-NUMBER
               PERFORM 8000-CALL-PGETMESG
               MOVE WGETM-MESSAGE      TO WS-ERROR-MESSAGE
               CLOSE EXTRACT-FILE-P
               CLOSE EXTRACT-FILE-C
           END-IF

           CONTINUE.

      ********************************************************
       1020-SET-UP-REPORT-FILES.

           MOVE WS-REPORT-FILE-P       TO WS-ASCII-FILE-NAME
           CALL PFILEINS USING WGLOBAL
                               WS-ASCII-FILE-NAME
                               WS-NEW-ASCII-FILE-NAME
           END-CALL
           MOVE WS-NEW-ASCII-FILE-NAME TO WS-REPORT-FILE-P

           MOVE WS-REPORT-FILE-C       TO WS-ASCII-FILE-NAME
           CALL PFILEINS USING WGLOBAL
                               WS-ASCII-FILE-NAME
                               WS-NEW-ASCII-FILE-NAME
           END-CALL
           MOVE WS-NEW-ASCII-FILE-NAME TO WS-REPORT-FILE-C

           CONTINUE.

      ******************************************************************
       2000-PROCESS.

           PERFORM
               UNTIL END-KEY
               PERFORM 7000-DISPLAY-SIBIL
               PERFORM 2010-VALIDATE-TRIAL-OR-UPDATE
               PERFORM 2020-EVALUATE-SCREEN-FUNCTION
           END-PERFORM

           CONTINUE.

      ******************************************************************
       2010-VALIDATE-TRIAL-OR-UPDATE.

           IF SIBIL-D-TRIAL-OR-UPDATE-P = '*'
              EVALUATE SIBIL-D-TRIAL-OR-UPDATE
                 WHEN 'T'
                    IF WS-EXTRACT-FILE-EXISTS-P OR
                       WS-EXTRACT-FILE-EXISTS-C
                       MOVE ' '    TO SIBIL-INPUT-1-O
      *               'Warning:  Each Extract Completely
      *                Overlays The Previous Extract File'
                       INITIALIZE WGETM-PARAMETERS
                       MOVE 000028334 TO WGETM-MESSAGE-NUMBER
                       PERFORM 8000-CALL-PGETMESG
                       MOVE WGETM-MESSAGE TO WS-ERROR-MESSAGE
                    END-IF
                 WHEN 'U'
100413*              MOVE 'P'    TO SIBIL-INPUT-1-O
                    IF NOT WS-EXTRACT-FILE-EXISTS-P AND
                       NOT WS-EXTRACT-FILE-EXISTS-C
      *               'Currently No Records In Extract File'
                       INITIALIZE WGETM-PARAMETERS
                       MOVE 000028446 TO WGETM-MESSAGE-NUMBER
                       PERFORM 8000-CALL-PGETMESG
                       MOVE WGETM-MESSAGE TO WS-ERROR-MESSAGE
100413*            ELSE
100413*                MOVE 'A' TO SIBIL-INPUT-1
                   END-IF
              END-EVALUATE
           END-IF

           CONTINUE.

      *****************************************************************    
       2020-EVALUATE-SCREEN-FUNCTION.

           EVALUATE TRUE
              WHEN ABORT-KEY
                  MOVE 'T'                   TO SIBIL-D-TRIAL-OR-UPDATE
                  MOVE 'A'                   TO SIBIL-INPUT-1
                  MOVE ' '                   TO SIBIL-INPUT-1-O
              WHEN ENTER-KEY
      *           'Press <F4> To Process'
                  INITIALIZE WGETM-PARAMETERS
                  MOVE 000023278      TO WGETM-MESSAGE-NUMBER
                  PERFORM 8000-CALL-PGETMESG
                  MOVE WGETM-MESSAGE  TO WS-ERROR-MESSAGE
              WHEN PROCESS-KEY
                  EVALUATE SIBIL-D-TRIAL-OR-UPDATE
                      WHEN 'T'
                           PERFORM 3000-BUILD-EXTRACT
                      WHEN 'U'
                           PERFORM 4000-UPDATE-IBIL
                  END-EVALUATE
                  IF WS-PROCESSING-OK
      *              'Processing Complete'
                     INITIALIZE WGETM-PARAMETERS
                     MOVE 000012369  TO WGETM-MESSAGE-NUMBER
                     PERFORM 8000-CALL-PGETMESG
                     MOVE WGETM-MESSAGE TO WS-ERROR-MESSAGE
                  END-IF
           END-EVALUATE

           CONTINUE.

      ******************************************************************
       3000-BUILD-EXTRACT.

           PERFORM 6000-OPEN-FILES

           IF WS-PROCESSING-OK
               PERFORM 3100-EXTRACT-FROM-POLC
           END-IF

           IF SIBIL-INPUT-1 = 'P'
              PERFORM 5100-REPORT-COMPLETION-P
           ELSE
              IF SIBIL-INPUT-1 = 'C'
                 PERFORM 5200-REPORT-COMPLETION-C
              ELSE
                 PERFORM 5100-REPORT-COMPLETION-P
                 PERFORM 5200-REPORT-COMPLETION-C
              END-IF
           END-IF

           PERFORM 6400-CLOSE-FILES

           CONTINUE.

      ******************************************************************
       3100-EXTRACT-FROM-POLC.

           INITIALIZE WPOLC-DATA-RECORD
           MOVE SPACES TO WPOLC-COMPANY-CODE
           MOVE SPACES TO WPOLC-POLICY-NUMBER
           MOVE WBTRV-GET-GREATER         TO WPOLC-FUNCTION
           MOVE 0                         TO WPOLC-KEY-NUMBER
           PERFORM
               UNTIL WPOLC-RETURN-NOT-OK
                 PERFORM 9000-ACCESS-WPOLC
                 IF WPOLC-CONTRACT-ACTIVE
                    IF ((WPOLC-PAC-FORM OR WPOLC-CRD-FORM)
                    AND  SIBIL-INPUT-1 = 'A')
                    OR (WPOLC-PAC-FORM AND SIBIL-INPUT-1 = 'P')
                    OR (WPOLC-CRD-FORM AND SIBIL-INPUT-1 = 'C')
                       IF WPOLC-PAC-FORM
                          PERFORM 3101-PROCESS-PAC
                       ELSE
                          PERFORM 3102-PROCESS-CRD
                       END-IF
                    END-IF
                 END-IF
           END-PERFORM

           CONTINUE.

      *******************************************************************
       3101-PROCESS-PAC.

           INITIALIZE WPPAC-DATA-RECORD
           MOVE WPOLC-COMPANY-CODE  TO WPPAC-COMPANY-CODE
           MOVE WPOLC-POLICY-NUMBER TO WPPAC-POLICY-NUMBER
           MOVE WBTRV-GET-EQUAL     TO WPPAC-FUNCTION
           PERFORM 9400-ACCESS-WPPAC

           IF WPPAC-RETURN-CODE  = ZEROS
           AND BILL-INT-DIRECT
               MOVE HIGH-VALUES         TO WLOAN-DATA-RECORD
               MOVE WPPAC-COMPANY-CODE  TO WLOAN-COMPANY-CODE
               MOVE WPPAC-POLICY-NUMBER TO WLOAN-POLICY-NUMBER
               MOVE 'N' TO WS-ACTIVE-LOAN-FLAG
               PERFORM 3400-CHECK-FOR-ACTIVE-LOAN
               IF WS-ACTIVE-LOAN-FLAG = 'Y'
                  PERFORM 3150-CALCULATE-DATES
                  PERFORM 3210-WRITE-TO-EXTRACT-P
                  PERFORM 6310-WRITE-REPORT-DETAIL-P
               END-IF
           END-IF

           CONTINUE.

      *******************************************************************
       3102-PROCESS-CRD.

           INITIALIZE WPCRD-DATA-RECORD
           MOVE WPOLC-COMPANY-CODE  TO WPCRD-COMPANY-CODE
           MOVE WPOLC-POLICY-NUMBER TO WPCRD-POLICY-NUMBER
           MOVE WBTRV-GET-EQUAL     TO WPCRD-FUNCTION
           PERFORM 9500-ACCESS-WPCRD

           IF WPCRD-RETURN-CODE  = ZEROS
           AND WPCRD-BILL-INT-DIRECT
               MOVE HIGH-VALUES         TO WLOAN-DATA-RECORD
               MOVE WPCRD-COMPANY-CODE  TO WLOAN-COMPANY-CODE
               MOVE WPCRD-POLICY-NUMBER TO WLOAN-POLICY-NUMBER
               MOVE 'N' TO WS-ACTIVE-LOAN-FLAG
               PERFORM 3400-CHECK-FOR-ACTIVE-LOAN
               IF WS-ACTIVE-LOAN-FLAG = 'Y'
                  PERFORM 3150-CALCULATE-DATES
                  PERFORM 3200-WRITE-TO-EXTRACT-C
                  PERFORM 6300-WRITE-REPORT-DETAIL-C
               END-IF
           END-IF

           CONTINUE.

      ******************************************************************
       3150-CALCULATE-DATES.

           PERFORM 3200-GET-BILL-DUE-DAYS

           MOVE WPOLC-ISSUE-DATE    TO WS-NEXT-ANNIVERSARY-DATE

           IF WLOAN-CAPITALIZED-DATE > ZEROS
              MOVE WLOAN-CAPITALIZED-DATE TO WS-EFFECTIVE-DATE
              MOVE 'N' TO WS-USING-PAID-TO-DATE
           ELSE
              IF WLOAN-ACCRUAL-DATE > ZEROS
                 MOVE WLOAN-ACCRUAL-DATE  TO WS-EFFECTIVE-DATE
                 MOVE 'N' TO WS-USING-PAID-TO-DATE
              ELSE
                 MOVE WPOLC-PAID-TO-DATE  TO WS-EFFECTIVE-DATE
                 MOVE 'Y' TO WS-USING-PAID-TO-DATE
              END-IF
           END-IF

           MOVE WS-NEXT-ANNIVERSARY-DATE  TO WDATE-STR-GREG-DATE
           MOVE WPOLC-ISSUE-DATE          TO WDATE-ISS-DATE

           PERFORM UNTIL WS-NEXT-ANNIVERSARY-DATE >
                         WS-EFFECTIVE-DATE
               IF WS-EFFECTIVE-YY = WS-NEXT-ANNIV-YY
                  ADD 1 TO WS-NEXT-ANNIV-YY
               ELSE
                  IF WS-EFFECTIVE-YY > WS-NEXT-ANNIV-YY
                     MOVE 'M' TO WDATE-FUNCTION
                     COMPUTE WDATE-NUM-OF-MONTHS = 12 *
                        (WS-EFFECTIVE-YY - WS-NEXT-ANNIV-YY)
                  ELSE
                     IF WS-EFFECTIVE-YY < WS-NEXT-ANNIV-YY
                        MOVE 'B' TO WDATE-FUNCTION
                        COMPUTE WDATE-NUM-OF-MONTHS = 12 *
                            (WS-NEXT-ANNIV-YY - WS-EFFECTIVE-YY)
                     END-IF
                  END-IF
                  CALL PDATECON USING WDATE-PARMS
                  IF WDATE-FUNCTION-SUCCESSFUL
                     MOVE WDATE-END-GREG-DATE TO
                          WS-NEXT-ANNIVERSARY-DATE
                  END-IF
               END-IF
           END-PERFORM

           IF WS-USING-PAID-TO-DATE = 'Y'
              PERFORM 3155-TWEAK-THE-DATES
           END-IF

           IF WS-WOPTION-BILL-DUE-DAYS > 0
              MOVE WS-NEXT-ANNIVERSARY-DATE  TO WDATE-STR-GREG-DATE
              MOVE WS-WOPTION-BILL-DUE-DAYS   TO WDATE-NUM-OF-DAYS
              MOVE 'P'                      TO WDATE-FUNCTION
              CALL PDATECON              USING WDATE-PARMS
              MOVE WDATE-END-GREG-DATE      TO WS-NEXT-BILL-GEN-DATE
           ELSE
              MOVE WS-NEXT-ANNIVERSARY-DATE TO WS-NEXT-BILL-GEN-DATE
           END-IF

           CONTINUE.

      ***************************************************************
       3155-TWEAK-THE-DATES.

           IF WS-NEXT-ANNIVERSARY-DATE > WS-EFFECTIVE-DATE
              IF WS-EFFECTIVE-MM = WPOLC-ISSUE-MONTH AND
                 WS-EFFECTIVE-DD = WPOLC-ISSUE-DAY
                 MOVE WS-NEXT-ANNIVERSARY-DATE TO
                      WDATE-STR-GREG-DATE
                 MOVE 'B' TO WDATE-FUNCTION
                 MOVE 12 TO WDATE-NUM-OF-MONTHS
                 CALL PDATECON USING WDATE-PARMS
                 IF WDATE-FUNCTION-SUCCESSFUL
                    MOVE WDATE-END-GREG-DATE TO
                         WS-NEXT-ANNIVERSARY-DATE
                 END-IF
              ELSE
                 MOVE WS-EFFECTIVE-DATE TO WDATE-STR-GREG-DATE
                 MOVE WPOLC-ISSUE-DATE TO WDATE-END-GREG-DATE
                 MOVE 'W' TO WDATE-FUNCTION
                 CALL PDATECON USING WDATE-PARMS
                 IF WDATE-NUM-OF-MONTHS < 12
                    MOVE WS-NEXT-ANNIVERSARY-DATE TO
                         WDATE-STR-GREG-DATE
                    MOVE 'B' TO WDATE-FUNCTION
                    MOVE 12 TO WDATE-NUM-OF-MONTHS
                    CALL PDATECON USING WDATE-PARMS
                    IF WDATE-FUNCTION-SUCCESSFUL
                       MOVE WDATE-END-GREG-DATE TO
                            WS-NEXT-ANNIVERSARY-DATE
                    END-IF
                 END-IF
              END-IF
           END-IF

           CONTINUE.

      ******************************************************************
       3200-GET-BILL-DUE-DAYS.

           MOVE LOW-VALUES            TO WPOLM-DATA-RECORD
           MOVE ZEROS                 TO WPOLM-SEQUENCE
           PERFORM 9100-ACCESS-WPOLM

           IF WPOLM-RETURN-CODE = ZEROS
               IF WPOLM-BS-DAYS-1ST-BILL > ZERO
                   MOVE WPOLM-BS-DAYS-1ST-BILL
                     TO WS-WOPTION-BILL-DUE-DAYS
               ELSE
                   PERFORM 3300-GET-MANAGEMENT-OPTIONS
                   MOVE WOPTION-BILL-DUE-DAYS
                     TO WS-WOPTION-BILL-DUE-DAYS
           ELSE
               PERFORM 3300-GET-MANAGEMENT-OPTIONS
               MOVE WOPTION-BILL-DUE-DAYS
                 TO WS-WOPTION-BILL-DUE-DAYS
           END-IF

           CONTINUE.

      ******************************************************************
       3300-GET-MANAGEMENT-OPTIONS.

           MOVE SPACES                TO WOPTN-DATA-RECORD
           MOVE WPOLC-COMPANY-CODE    TO WOPTN-COMPANY-CODE
           MOVE 'MISC'                TO WOPTN-TYPE-KEY
           MOVE WBTRV-GET-EQUAL       TO WOPTN-FUNCTION
           MOVE 0                     TO WOPTN-KEY-NUMBER
           PERFORM 9200-ACCESS-POPTN

           IF WOPTN-RETURN-CODE = ZEROS
               MOVE WOPTN-MISC-DATA-AREA
                 TO WOPTION
           END-IF

           CONTINUE.

      ******************************************************************
       3200-WRITE-TO-EXTRACT-C.

           MOVE SPACES                   TO EXTRACT-RECORD-C
                                            WS-EXTRACT-RECORD

           PERFORM 3300-MOVE-DATA-TO-EXTRACT

           MOVE WS-EXTRACT-RECORD TO EXTRACT-RECORD-C

           WRITE EXTRACT-RECORD-C

           CONTINUE.

      ******************************************************************
       3210-WRITE-TO-EXTRACT-P.

           MOVE SPACES                   TO EXTRACT-RECORD-P
                                            WS-EXTRACT-RECORD

           PERFORM 3300-MOVE-DATA-TO-EXTRACT

           MOVE WS-EXTRACT-RECORD TO EXTRACT-RECORD-P

           WRITE EXTRACT-RECORD-P

           CONTINUE.

      ******************************************************************
       3300-MOVE-DATA-TO-EXTRACT.

           MOVE WPOLC-COMPANY-CODE       TO EXT-COMPANY-CODE
           MOVE WPOLC-POLICY-NUMBER      TO EXT-POLICY-NUMBER
           MOVE WPOLC-BILLING-FORM       TO EXT-BILLING-FORM
           MOVE WS-NEXT-ANNIVERSARY-DATE TO EXT-NEXT-ANNIV-DATE
           MOVE WS-NEXT-BILL-GEN-DATE    TO EXT-NEXT-BILL-GEN-DATE

           CONTINUE.

      ******************************************************************
       3400-CHECK-FOR-ACTIVE-LOAN.

           MOVE SPACES TO WS-ACTIVE-LOAN-FLAG

           PERFORM UNTIL WS-ACTIVE-LOAN-FLAG NOT EQUAL SPACES
              PERFORM 9600-ACCESS-WLOAN

              IF  WLOAN-RETURN-CODE = ZEROS
              AND WLOAN-POLICY-NUMBER = WPOLC-POLICY-NUMBER
              AND WLOAN-COMPANY-CODE  = WPOLC-COMPANY-CODE
              AND WLOAN-STATUS-CODE EQUAL 'A'
                  MOVE 'Y' TO WS-ACTIVE-LOAN-FLAG
              ELSE
                  IF WLOAN-POLICY-NUMBER = WPOLC-POLICY-NUMBER
                  AND WLOAN-COMPANY-CODE = WPOLC-COMPANY-CODE
                  AND WLOAN-RETURN-CODE = ZEROS
                      CONTINUE
                  ELSE
                      MOVE 'N' TO WS-ACTIVE-LOAN-FLAG
                  END-IF
              END-IF
           END-PERFORM

           CONTINUE.

      ******************************************************************
       4000-UPDATE-IBIL.

           PERFORM 6000-OPEN-FILES

           IF WS-PROCESSING-OK
              IF SIBIL-INPUT-1 = 'C'
                 PERFORM 4100-PROCESS-EXTRACT-C
              ELSE
                 IF SIBIL-INPUT-1 = 'P'
                    PERFORM 4110-PROCESS-EXTRACT-P
                 ELSE
                    PERFORM 4100-PROCESS-EXTRACT-C
                    PERFORM 4110-PROCESS-EXTRACT-P
                 END-IF
              END-IF
           END-IF

           IF WS-PROCESSING-OK
               PERFORM 5000-UPDATE-VHST
100413         SET WS-PROCESSING-OK TO TRUE
           END-IF

           IF SIBIL-INPUT-1 = 'P'
              PERFORM 5100-REPORT-COMPLETION-P
           ELSE
              IF SIBIL-INPUT-1 = 'C'
                 PERFORM 5200-REPORT-COMPLETION-C
              ELSE
                 PERFORM 5100-REPORT-COMPLETION-P
                 PERFORM 5200-REPORT-COMPLETION-C
              END-IF
           END-IF

           PERFORM 6400-CLOSE-FILES

           CONTINUE.

      ******************************************************************
       4100-PROCESS-EXTRACT-C.

           INITIALIZE WS-UPDATE-CNT-C
           MOVE 'N'               TO EXTRACT-EOF-FLAG-C
           PERFORM 4200-READ-EXTRACT-C

           IF EOF-EXTRACT-C
               MOVE 9999          TO WS-RETURN-CODE
      *        'Currently No Records In Extract File'
               INITIALIZE WGETM-PARAMETERS
               MOVE 000028446     TO WGETM-MESSAGE-NUMBER
               PERFORM 8000-CALL-PGETMESG
               MOVE WGETM-MESSAGE TO WS-ERROR-MESSAGE
           ELSE
               PERFORM
                   UNTIL EOF-EXTRACT-C
100413*               OR WS-PROCESSING-ERROR
100413             MOVE EXTRACT-RECORD-C TO WS-EXTRACT-RECORD
                   PERFORM 4300-UPDATE-IBIL
                   PERFORM 6300-WRITE-REPORT-DETAIL-C
                   PERFORM 4200-READ-EXTRACT-C
               END-PERFORM
           END-IF

           CONTINUE.

      ******************************************************************
       4110-PROCESS-EXTRACT-P.

           INITIALIZE WS-UPDATE-CNT-P
           MOVE 'N'               TO EXTRACT-EOF-FLAG-P
           PERFORM 4210-READ-EXTRACT-P

           IF EOF-EXTRACT-P
               MOVE 9999          TO WS-RETURN-CODE
      *        'Currently No Records In Extract File'
               INITIALIZE WGETM-PARAMETERS
               MOVE 000028446     TO WGETM-MESSAGE-NUMBER
               PERFORM 8000-CALL-PGETMESG
               MOVE WGETM-MESSAGE TO WS-ERROR-MESSAGE
           ELSE
               PERFORM
                   UNTIL EOF-EXTRACT-P
100413*               OR WS-PROCESSING-ERROR
100413             MOVE EXTRACT-RECORD-P TO WS-EXTRACT-RECORD
                   PERFORM 4300-UPDATE-IBIL
                   PERFORM 6310-WRITE-REPORT-DETAIL-P
                   PERFORM 4210-READ-EXTRACT-P
               END-PERFORM
           END-IF

           CONTINUE.
      ******************************************************************
       4200-READ-EXTRACT-C.

           READ EXTRACT-FILE-C NEXT RECORD
             AT END
               MOVE 'Y'           TO EXTRACT-EOF-FLAG-C
           END-READ

           CONTINUE.

      ******************************************************************
       4210-READ-EXTRACT-P.

           READ EXTRACT-FILE-P NEXT RECORD
             AT END
               MOVE 'Y'           TO EXTRACT-EOF-FLAG-P
           END-READ

           CONTINUE.

      ******************************************************************
       4300-UPDATE-IBIL.

           INITIALIZE WIBIL-DATA-RECORD

           MOVE EXT-COMPANY-CODE       TO WIBIL-COMPANY-CODE
           MOVE EXT-POLICY-NUMBER      TO WIBIL-POLICY-NUMBER
           MOVE WBTRV-GET-EQUAL        TO WIBIL-FUNCTION


           PERFORM 9500-ACCESS-WIBIL.

           IF WIBIL-RETURN-CODE = ZEROS
               MOVE WBTRV-UPDATE       TO WIBIL-FUNCTION
           ELSE
               MOVE WBTRV-INSERT       TO WIBIL-FUNCTION
           END-IF
           PERFORM 4310-MOVE-DATA.
           PERFORM 9500-ACCESS-WIBIL.

           CONTINUE.

      ******************************************************************
       4310-MOVE-DATA.

           MOVE EXT-COMPANY-CODE       TO WIBIL-COMPANY-CODE
           MOVE EXT-POLICY-NUMBER      TO WIBIL-POLICY-NUMBER
           MOVE EXT-BILLING-FORM       TO WIBIL-BILLING-FORM
           MOVE EXT-NEXT-BILL-GEN-DATE TO WIBIL-NEXT-BILL-GEN-DATE
           MOVE EXT-NEXT-ANNIV-DATE    TO WIBIL-NEXT-ANNIV-DATE

           CONTINUE.

      ******************************************************************
       5000-UPDATE-VHST.

           COMPUTE WS-UPDATE-CNT-T =
                   WS-UPDATE-CNT-P + WS-UPDATE-CNT-C

           MOVE 'N'                      TO WVHST-EOF-FLAG
           MOVE 'MUIBIL01'               TO WVHST-VCONVERT-PROGRAM
           MOVE 11700                    TO WVHST-CLIENT-VERSION
           MOVE 0                        TO WKEY-NUMBER
           MOVE WBTRV-GET-EQUAL          TO WFUNCTION
           PERFORM 9300-ACCESS-WVHST

           IF WS-PROCESSING-OK
               IF WBTRV-SUCCESSFUL
                   MOVE WBTRV-DELETE     TO WFUNCTION
                   PERFORM 9300-ACCESS-WVHST
               END-IF
               SET WDATE-GET-CURRENT-DATE  TO TRUE
               CALL PDATECON USING WDATE-PARMS
               MOVE WDATE-END-GREG-DATE  TO WVBOX-DATE-CREATED
               ACCEPT WVBOX-TIME-CREATED FROM TIME
               MOVE WS-UPDATE-CNT-T      TO WVBOX-RECORDS-UPDATED
               MOVE 'IBIL'               TO WVBOX-LIFEPRO-FILENAME
               MOVE 'MUIBIL01'           TO WVBOX-VCONVERT-PROGRAM
               MOVE 11700                TO WVBOX-CLIENT-VERSION

               SET WVBOX-ADD-RECORD      TO TRUE
               MOVE 1                    TO WVBOX-KEY-DEFINITION
               CALL PVHSTSQL USING WGLOBAL
                                   WVBOX-PARAMETERS
               END-CALL
100413         SET WS-PROCESSING-OK TO TRUE
100413     ELSE
100413         SET WS-PROCESSING-OK TO TRUE
           END-IF

           CONTINUE.

      ******************************************************************
       5100-REPORT-COMPLETION-P.

           IF LINE-NUMBER-P + 3 NOT < WCTRL-MAX-PORTRAIT-STANDARD
               PERFORM 6210-WRITE-REPORT-HEADINGS-P
           END-IF

           MOVE SPACES               TO REPORT-RECORD-P
           WRITE REPORT-RECORD-P

           IF WS-PROCESSING-ERROR
               MOVE SPACES           TO REPORT-RECORD-P
               STRING
                   '**** Process TERMINATED -> '
                   WS-ERROR-MESSAGE
                       DELIMITED BY SIZE
                 INTO REPORT-RECORD-P
               END-STRING
               WRITE REPORT-RECORD-P
           ELSE
               MOVE '**** Process Completed ****'
                 TO REPORT-RECORD-P
               WRITE REPORT-RECORD-P
           END-IF

           MOVE WS-UPDATE-CNT-P   TO TOT-POLICY-CNT
           WRITE REPORT-RECORD-P FROM TOTAL-REPORTED-LINE

100413     MOVE SPACES               TO REPORT-RECORD-P
100413     WRITE REPORT-RECORD-P

           CONTINUE.

      ******************************************************************
       5200-REPORT-COMPLETION-C.

           IF LINE-NUMBER-C + 3 NOT < WCTRL-MAX-PORTRAIT-STANDARD
               PERFORM 6220-WRITE-REPORT-HEADINGS-C
           END-IF

           MOVE SPACES               TO REPORT-RECORD-C
           WRITE REPORT-RECORD-C

           IF WS-PROCESSING-ERROR
               MOVE SPACES           TO REPORT-RECORD-C
               STRING
                   '**** Process TERMINATED -> '
                   WS-ERROR-MESSAGE
                       DELIMITED BY SIZE
                 INTO REPORT-RECORD-C
               END-STRING
               WRITE REPORT-RECORD-C
           ELSE
               MOVE '**** Process Completed ****'
                 TO REPORT-RECORD-C
               WRITE REPORT-RECORD-C
           END-IF

           MOVE WS-UPDATE-CNT-C       TO TOT-POLICY-CNT
           WRITE REPORT-RECORD-C FROM TOTAL-REPORTED-LINE

100413     MOVE SPACES               TO REPORT-RECORD-C
100413     WRITE REPORT-RECORD-C

           CONTINUE.

      ******************************************************************
       6000-OPEN-FILES.

           SET WS-PROCESSING-OK     TO TRUE
           SET WS-EXTRACT-FILE-OK-C TO TRUE
           SET WS-EXTRACT-FILE-OK-P TO TRUE
           SET WS-REPORT-FILE-OK-P  TO TRUE
           SET WS-REPORT-FILE-OK-C  TO TRUE

           IF SIBIL-D-TRIAL-OR-UPDATE = 'T'
              IF SIBIL-INPUT-1 = 'P'
                 OPEN OUTPUT EXTRACT-FILE-P
                 OPEN OUTPUT REPORT-FILE-P
              ELSE
                IF SIBIL-INPUT-1 = 'C'
                   OPEN OUTPUT EXTRACT-FILE-C
                   OPEN OUTPUT REPORT-FILE-C
                ELSE
                   OPEN OUTPUT EXTRACT-FILE-P
                   OPEN OUTPUT EXTRACT-FILE-C
                   OPEN OUTPUT REPORT-FILE-P
                   OPEN OUTPUT REPORT-FILE-C
                END-IF
              END-IF
              IF WS-EXTRACT-FILE-OK-P AND WS-EXTRACT-FILE-OK-C AND
                 WS-REPORT-FILE-OK-P  AND WS-REPORT-FILE-OK-C
                 PERFORM 6100-INIT-REPORT-HEADINGS
                 PERFORM 6200-WRITE-REPORT-HEADINGS
              ELSE
                 PERFORM 6010-CHECK-EXTRACT-STATUS
              END-IF
           END-IF

           IF WS-PROCESSING-OK
              IF SIBIL-D-TRIAL-OR-UPDATE = 'U'
                 IF SIBIL-INPUT-1 = 'P'
                    OPEN INPUT EXTRACT-FILE-P
                    OPEN OUTPUT REPORT-FILE-P
                 ELSE
                    IF SIBIL-INPUT-1 = 'C'
                       OPEN INPUT EXTRACT-FILE-C
                       OPEN OUTPUT REPORT-FILE-C
                    ELSE
                       OPEN INPUT EXTRACT-FILE-P
                       OPEN INPUT EXTRACT-FILE-C
                       OPEN OUTPUT REPORT-FILE-P
                       OPEN OUTPUT REPORT-FILE-C
                    END-IF
                 END-IF
                 IF WS-EXTRACT-FILE-OK-P AND WS-EXTRACT-FILE-OK-C
                 AND WS-REPORT-FILE-OK-P  AND WS-REPORT-FILE-OK-C
                     PERFORM 6100-INIT-REPORT-HEADINGS
                     PERFORM 6200-WRITE-REPORT-HEADINGS
                 ELSE
                     PERFORM 6010-CHECK-EXTRACT-STATUS
                 END-IF
              END-IF
           END-IF

           CONTINUE.

      ****************************************************************
       6010-CHECK-EXTRACT-STATUS.

      *    'Error Opening %Extract File% Status %Extract File
      *    'Status%           
           MOVE 9999                    TO WS-RETURN-CODE
           INITIALIZE WGETM-PARAMETERS
           IF NOT WS-EXTRACT-FILE-OK-C
              MOVE WS-EXTRACT-FILE-C   TO WGETM-VARIABLE-VALUE(1)
              MOVE WS-EXTRACT-STATUS-C TO WGETM-VARIABLE-VALUE(2)
           ELSE
              IF NOT WS-EXTRACT-FILE-OK-P
                 MOVE WS-EXTRACT-FILE-P   TO WGETM-VARIABLE-VALUE(1)
                 MOVE WS-EXTRACT-STATUS-P TO WGETM-VARIABLE-VALUE(2)
              ELSE
                 IF NOT WS-REPORT-FILE-OK-P
                    MOVE WS-REPORT-FILE-P   TO WGETM-VARIABLE-VALUE(1)
                    MOVE WS-REPORT-STATUS-P TO WGETM-VARIABLE-VALUE(2)
                 ELSE
                    MOVE WS-REPORT-FILE-C   TO WGETM-VARIABLE-VALUE(1)
                    MOVE WS-REPORT-STATUS-C TO WGETM-VARIABLE-VALUE(2)
                 END-IF
              END-IF
           END-IF

           MOVE 000019423           TO WGETM-MESSAGE-NUMBER
           MOVE '%WS-OUTPUT-FILE%'  TO WGETM-VARIABLE-NAME(1)
           MOVE '%FUTLPROP-STATUS%' TO WGETM-VARIABLE-NAME(2)
           PERFORM 8000-CALL-PGETMESG
           MOVE WGETM-MESSAGE       TO WS-ERROR-MESSAGE

           CONTINUE.

      ******************************************************************
       6100-INIT-REPORT-HEADINGS.

           IF SIBIL-INPUT-1 = 'P'
100413        MOVE SPACES TO REPORT-RECORD-P
              WRITE REPORT-RECORD-P FROM WCTRL-PORTRAIT-STANDARD
              MOVE ZEROES TO PAGE-NUMBER-P
                             LINE-NUMBER-P
           ELSE
              IF SIBIL-INPUT-1 = 'C'
100413           MOVE SPACES TO REPORT-RECORD-C
                 WRITE REPORT-RECORD-C FROM WCTRL-PORTRAIT-STANDARD
                 MOVE ZEROS  TO PAGE-NUMBER-C
                 MOVE ZEROS  TO PAGE-NUMBER-C
              ELSE
100413           MOVE SPACES TO REPORT-RECORD-P REPORT-RECORD-C
                 WRITE REPORT-RECORD-P FROM WCTRL-PORTRAIT-STANDARD
                 MOVE ZEROES TO PAGE-NUMBER-P
                                LINE-NUMBER-P
                 WRITE REPORT-RECORD-C FROM WCTRL-PORTRAIT-STANDARD
                 MOVE ZEROS  TO PAGE-NUMBER-C
100413                          LINE-NUMBER-C
             END-IF
          END-IF

           ACCEPT CURRENT-TIME FROM TIME

           MOVE CURR-MN                      TO HDG-MONTH
           MOVE CURR-DY                      TO HDG-DAY
           MOVE CURR-YR                      TO HDG-YEAR
           MOVE CURR-HOUR                    TO HDG-HOUR
           MOVE CURR-MIN                     TO HDG-MIN
           MOVE CURR-SEC                     TO HDG-SEC
           MOVE WCODER-ID                    TO HDG-CODER-ID

           IF SIBIL-D-TRIAL-OR-UPDATE = 'T'
               MOVE 'Trial - Create Extract' TO HDG-SELECTION
           ELSE
               MOVE 'Process - Update Rider' TO HDG-SELECTION
           END-IF

           CONTINUE.

      ******************************************************************
       6200-WRITE-REPORT-HEADINGS.
           IF SIBIL-INPUT-1 = 'P'
              ADD 01 TO PAGE-NUMBER-P
              PERFORM 6210-WRITE-REPORT-HEADINGS-P
           ELSE
              IF SIBIL-INPUT-1 = 'C'
                 ADD 01 TO PAGE-NUMBER-C
                 PERFORM 6220-WRITE-REPORT-HEADINGS-C
              ELSE
                 ADD 01 TO PAGE-NUMBER-P
                 ADD 01 TO PAGE-NUMBER-C
                 PERFORM 6210-WRITE-REPORT-HEADINGS-P
                 PERFORM 6220-WRITE-REPORT-HEADINGS-C
              END-IF
           END-IF

           CONTINUE.

      ****************************************************************     
       6210-WRITE-REPORT-HEADINGS-P.

           MOVE PAGE-NUMBER-P  TO HDG-PAGE-NUMBER

100413     MOVE 'PAC' TO HDG-TYPE
           WRITE REPORT-RECORD-P FROM HEADING1
100413     MOVE SPACES TO REPORT-RECORD-P
           WRITE REPORT-RECORD-P FROM HEADING2
           MOVE SPACES TO REPORT-RECORD-P
           WRITE REPORT-RECORD-P
           WRITE REPORT-RECORD-P FROM DETAIL-HEADING1
           WRITE REPORT-RECORD-P FROM DETAIL-HEADING2
           WRITE REPORT-RECORD-P FROM DASH-LINE

           MOVE 06 TO LINE-NUMBER-P

           CONTINUE.

      ****************************************************************     
       6220-WRITE-REPORT-HEADINGS-C.

           MOVE PAGE-NUMBER-C  TO HDG-PAGE-NUMBER

100413     MOVE 'CRD' TO HDG-TYPE
           WRITE REPORT-RECORD-C FROM HEADING1
100413     MOVE SPACES TO REPORT-RECORD-C
           WRITE REPORT-RECORD-C FROM HEADING2
           MOVE SPACES TO REPORT-RECORD-C
           WRITE REPORT-RECORD-C
           WRITE REPORT-RECORD-C FROM DETAIL-HEADING1
           WRITE REPORT-RECORD-C FROM DETAIL-HEADING2
           WRITE REPORT-RECORD-C FROM DASH-LINE

           MOVE 06 TO LINE-NUMBER-C

           CONTINUE.

      ******************************************************************
       6300-WRITE-REPORT-DETAIL-C.
           MOVE EXTRACT-RECORD-C TO WS-EXTRACT-RECORD

           ADD 1 TO LINE-NUMBER-C
           IF LINE-NUMBER-C > WCTRL-MAX-PORTRAIT-STANDARD
               WRITE REPORT-RECORD-C FROM WCTRL-EJECT
               PERFORM 6220-WRITE-REPORT-HEADINGS-C
           END-IF

           PERFORM 6400-WRITE-REPORT-DETAIL

           WRITE REPORT-RECORD-C FROM DETAIL-LINE

           ADD +1 TO WS-UPDATE-CNT-C

           CONTINUE.

      ******************************************************************
       6310-WRITE-REPORT-DETAIL-P.
           MOVE EXTRACT-RECORD-P TO WS-EXTRACT-RECORD

           ADD 1 TO LINE-NUMBER-P
           IF LINE-NUMBER-P > WCTRL-MAX-PORTRAIT-STANDARD
               WRITE REPORT-RECORD-P FROM WCTRL-EJECT
               PERFORM 6210-WRITE-REPORT-HEADINGS-P
           END-IF

           PERFORM 6400-WRITE-REPORT-DETAIL

           WRITE REPORT-RECORD-P FROM DETAIL-LINE

           ADD +1 TO WS-UPDATE-CNT-P

           CONTINUE.



      ******************************************************************
       6400-WRITE-REPORT-DETAIL.

           MOVE EXT-COMPANY-CODE          TO DET-COMPANY
           MOVE EXT-POLICY-NUMBER         TO DET-POLICY
           MOVE EXT-BILLING-FORM          TO DET-BILLING-FORM
           MOVE EXT-NEXT-BILL-GEN-DATE    TO DET-NEXT-BILL-GEN
           MOVE EXT-NEXT-ANNIV-DATE       TO DET-NEXT-ANNIV-DATE
100413*    MOVE WPPAC-LOAN-INT-INDICATOR  TO DET-LOAN-INT-INDICATOR           


           IF SIBIL-D-TRIAL-OR-UPDATE = 'T'
               MOVE SPACES             TO DET-MESSAGE
           ELSE
               MOVE 'IBIL  Updated'    TO DET-MESSAGE
           END-IF

           CONTINUE.

      ******************************************************************
       6400-CLOSE-FILES.

           IF SIBIL-INPUT-1 = 'C'
              CLOSE EXTRACT-FILE-C
                    REPORT-FILE-C
           ELSE
              IF SIBIL-INPUT-1 = 'P'
                 CLOSE EXTRACT-FILE-P
                       REPORT-FILE-P
              ELSE
                 CLOSE EXTRACT-FILE-P
                       REPORT-FILE-P
                       EXTRACT-FILE-C
                       REPORT-FILE-C
              END-IF
           END-IF

           SET WS-EXTRACT-FILE-OK-C TO TRUE
           SET WS-EXTRACT-FILE-OK-P TO TRUE
           SET WS-REPORT-FILE-OK-P  TO TRUE
           SET WS-REPORT-FILE-OK-C  TO TRUE

           CONTINUE.

      ******************************************************************
       7000-DISPLAY-SIBIL.

           IF WS-ERROR-MESSAGE > SPACES
               MOVE WS-ERROR-MESSAGE   TO SIBILCPY-MENU-MSG
               MOVE 01                 TO SIBILCPY-DISPLAY-OPTION
               MOVE ZEROS              TO WS-RETURN-CODE
               MOVE SPACES             TO WS-ERROR-MESSAGE
           END-IF

           CALL SCREENIO
               USING SIBILCPY-PANEL
                     SIBILCPY-PASS-TO-EXIT
                     SIBILCPY-WORK-S
                     SIBILCPY-WORK-D
           END-CALL
           MOVE SIBILCPY-EXIT-KEY      TO WS-EXIT-KEY
           IF HOT-FIELD
               SUBTRACT 1000 FROM WS-EXIT-KEY
                 GIVING SIBIL-FIELD-INDEX
           ELSE
               MOVE SIBILCPY-CURSOR-FIELD
                 TO SIBIL-FIELD-INDEX
           END-IF
           IF SIBIL-FIELD-INDEX > 0
               MOVE '*' TO SIBILCPY-FIELD-PAINT (SIBIL-FIELD-INDEX)
           END-IF
           IF  WS-EXIT-KEY = 0104
               PERFORM 7120-SIBILCPY-FKEY-MENU
           END-IF

           CONTINUE.

      ******************************************************************
       7120-SIBILCPY-FKEY-MENU.

           INITIALIZE WFMNU-TABLE
           PERFORM 7130-SIBILCPY-INCREMENT-INDEX

           SET WFMNU-F4
               (WFMNU-INDEX)        TO TRUE
      *    'Process'
           INITIALIZE WGETM-PARAMETERS
           MOVE 000202074           TO WGETM-MESSAGE-NUMBER
           PERFORM 8000-CALL-PGETMESG
           MOVE WGETM-MESSAGE       TO WFMNU-FUNC-KEY-DESC(WFMNU-INDEX)
           PERFORM 7130-SIBILCPY-INCREMENT-INDEX

           SET WFMNU-ALT-F10
              (WFMNU-INDEX)         TO TRUE
      *    'Cancel'
           INITIALIZE WGETM-PARAMETERS
           MOVE 000201767           TO WGETM-MESSAGE-NUMBER
           PERFORM 8000-CALL-PGETMESG
           MOVE WGETM-MESSAGE       TO WFMNU-FUNC-KEY-DESC(WFMNU-INDEX)
           PERFORM 7130-SIBILCPY-INCREMENT-INDEX

           SET WFMNU-ENTER-KEY
              (WFMNU-INDEX)         TO TRUE
      *    'Save/Select/Confirm'
           INITIALIZE WGETM-PARAMETERS
           MOVE 000202146           TO WGETM-MESSAGE-NUMBER
           PERFORM 8000-CALL-PGETMESG
           MOVE WGETM-MESSAGE       TO WFMNU-FUNC-KEY-DESC(WFMNU-INDEX)
           PERFORM 7130-SIBILCPY-INCREMENT-INDEX

           SET WFMNU-END-KEY
              (WFMNU-INDEX)         TO TRUE
      *    'Exit/Cancel'
           INITIALIZE WGETM-PARAMETERS
           MOVE 000201964           TO WGETM-MESSAGE-NUMBER
           PERFORM 8000-CALL-PGETMESG
           MOVE WGETM-MESSAGE       TO WFMNU-FUNC-KEY-DESC(WFMNU-INDEX)

           CALL PFUNCMNU USING WGLOBAL
                               WFMNU-PARAMETERS
                               WS-EXIT-KEY
           END-CALL
           CANCEL PFUNCMNU
           MOVE 'AM'                TO WFUNC-FUNCTION
           CALL POPFUNCN USING WGLOBAL

           CONTINUE.

      ******************************************************************
       7130-SIBILCPY-INCREMENT-INDEX.

           IF  WFMNU-INDEX < WFMNU-MAX-OCCURS
               ADD 1                TO WFMNU-INDEX
           END-IF

           CONTINUE.

      ******************************************************************
       8000-CALL-PGETMESG.

           CALL PGETMESG USING WGLOBAL
                               WGETM-PARAMETERS
           END-CALL

           CONTINUE.

      ******************************************************************
       9000-ACCESS-WPOLC.

           MOVE WFILE-POLC-NUM        TO DATA-FILE-NUMBER
           MOVE WPOLC-DATA-RECORD     TO DATA-AREA
           CALL PFILEBTV USING WGLOBAL
                               WPOLC-CALL-PARAMETERS
                               WBTRIEVE
           MOVE DATA-AREA             TO WPOLC-DATA-RECORD.

           CONTINUE.

      ******************************************************************
       9100-ACCESS-WPOLM.

           MOVE WPOLC-POLICY-NUMBER   TO WPOLM-POLICY-NUMBER
           MOVE WPOLC-COMPANY-CODE    TO WPOLM-COMPANY-CODE
           MOVE ZEROS                 TO WPOLM-BENEFIT
           MOVE WBTRV-GET-EQUAL       TO WPOLM-FUNCTION
           MOVE 0                     TO WPOLM-KEY-NUMBER
           MOVE WFILE-POLM-NUM        TO DATA-FILE-NUMBER
           MOVE WPOLM-DATA-RECORD     TO DATA-AREA
           CALL PFILEBTV USING WGLOBAL
                               WPOLM-CALL-PARAMETERS
                               WBTRIEVE
           MOVE DATA-AREA             TO WPOLM-DATA-RECORD.

           CONTINUE.

      ******************************************************************
       9200-ACCESS-POPTN.

           MOVE WFILE-OPTN-NUM        TO DATA-FILE-NUMBER
           MOVE WOPTN-DATA-RECORD     TO DATA-AREA
           CALL PFILEBTV USING WGLOBAL
                               WOPTN-CALL-PARAMETERS
                               WBTRIEVE
           MOVE DATA-AREA             TO WOPTN-DATA-RECORD.

           CONTINUE.



      ******************************************************************
       9300-ACCESS-WVHST.

           MOVE WFILE-VHST-NUM         TO DATA-FILE-NUMBER
           MOVE WVHST-DATA-RECORD      TO DATA-AREA
           PERFORM 9990-CALL-BTRV
           MOVE DATA-AREA              TO WVHST-DATA-RECORD

           IF WBTRV-SUCCESSFUL
               CONTINUE
           ELSE
               IF WBTRV-END-OF-FILE
               OR WBTRV-KEY-NOT-FOUND
                   MOVE 'Y'            TO WVHST-EOF-FLAG
               ELSE
                   MOVE 9999           TO WS-RETURN-CODE
                   MOVE 'Y'            TO WVHST-EOF-FLAG
               END-IF
               MOVE WKEY-NUMBER        TO WKEY-DISPLAY
               MOVE 'WVHST'            TO SUBJECT-IN-ERROR
               STRING
                   'KEY '
                       DELIMITED BY SIZE
                   WKEY-DISPLAY
                       DELIMITED BY SIZE
                   '; '
                   WVHST-KEY-0
                       DELIMITED BY SIZE
                 INTO KEY-IN-ERROR
               END-STRING
               PERFORM 9900-BTRV-ERROR-MESSAGE
           END-IF

           CONTINUE.

      ******************************************************************
       9400-ACCESS-WPPAC.

           MOVE WPPAC-DATA-RECORD       TO DATA-AREA
           MOVE WFILE-PPAC-NUM          TO DATA-FILE-NUMBER
           CALL PFILEBTV USING          WGLOBAL
                                        WPPAC-CALL-PARAMETERS
                                        WBTRIEVE
           MOVE DATA-AREA               TO WPPAC-DATA-RECORD.

           CONTINUE.

      ******************************************************************
       9500-ACCESS-WIBIL.

           MOVE WFILE-IBIL-NUM        TO DATA-FILE-NUMBER
           MOVE WIBIL-DATA-RECORD     TO DATA-AREA
           CALL PFILEBTV USING WGLOBAL
                               WIBIL-CALL-PARAMETERS
                               WBTRIEVE
           MOVE DATA-AREA             TO WIBIL-DATA-RECORD.

           CONTINUE.

      ******************************************************************
       9500-ACCESS-WPCRD.

           MOVE WPCRD-DATA-RECORD       TO DATA-AREA
           MOVE WFILE-PCRD-NUM          TO DATA-FILE-NUMBER
           CALL PFILEBTV USING          WGLOBAL
                                        WPCRD-CALL-PARAMETERS
                                        WBTRIEVE
           MOVE DATA-AREA               TO WPCRD-DATA-RECORD.

           CONTINUE.

      ******************************************************************
       9600-ACCESS-WLOAN.

           MOVE WBTRV-GET-LESS TO WLOAN-FUNCTION
           MOVE 0 TO WLOAN-KEY-NUMBER.
           MOVE WFILE-LOAN-NUM    TO DATA-FILE-NUMBER.
           MOVE WLOAN-DATA-RECORD TO DATA-AREA.
           CALL PFILEBTV USING       WGLOBAL
                                     WLOAN-CALL-PARAMETERS
                                     WBTRIEVE.
           MOVE DATA-AREA         TO WLOAN-DATA-RECORD.


      ******************************************************************
       9900-BTRV-ERROR-MESSAGE.

           INITIALIZE WGETM-PARAMETERS
           MOVE WBTRV-RETURN-CODE      TO WGETM-MESSAGE-NUMBER
           PERFORM 8000-CALL-PGETMESG

           MOVE SPACES                 TO WS-ERROR-MESSAGE
           STRING
               WGETM-MESSAGE
                   DELIMITED BY '   '
               CONCATENATE-ERROR
                  DELIMITED BY SIZE
             INTO WS-ERROR-MESSAGE
           END-STRING

           CONTINUE.

      ******************************************************************
       9990-CALL-BTRV.

           MOVE WFUNCTION              TO WAPPL-FUNCTION
           MOVE WKEY-NUMBER            TO WAPPL-KEY-NUMBER

           CALL PFILEBTV USING WGLOBAL
                               WAPPL-CALL-PARAMETERS
                               WBTRIEVE
           END-CALL

           MOVE WAPPL-RETURN-CODE      TO WBTRV-RETURN-CODE

           CONTINUE.
