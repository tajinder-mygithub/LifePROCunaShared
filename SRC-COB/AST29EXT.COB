010996*$CALL
       IDENTIFICATION  DIVISION.
091296 PROGRAM-ID.     AST29EXT.
       AUTHOR.         GOODWIN.
       DATE-WRITTEN.   Jan 24, 1995.
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
      *D
      *D**********************************************************

      *H**********************************************************
      *H        PROGRAM HISTORY
      *H**********************************************************
      *H
022395*H 941105-002-04 REB Changed name of annual statement.
031095*H 941105-002-06 REB Add original loan payment amount.
010996*H 951004-005-01 TSC COMP-5 to COMP conversion
091296*H 940804-014-02 MAK Fixed PROGRAM-ID.
112597*H 800101-026-01 RVM Fix compile error.
03XX99*H 980722-026-02 P10 AUTOMATED NLS/MESSAGING CONVERSION
01FF02*H 20020124-001-01 RDE Fujitsu port (may include automated changes)
021102*H 20020124-001-01 WDS Changes to remove drive mappings for
021102*H                     the new BAPI project.
082407*H 20060720-003-01 KLS Use global variable to define WLK29 table
110507*H 20060720-003-20 KAM Fund Expansion
      *H
      *H**********************************************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.    IBM-AT.
       OBJECT-COMPUTER.    IBM-AT.
      *                     SEGMENT-LIMIT IS 1.
       SPECIAL-NAMES.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

112597*    SELECT EXTRACT-FILE ASSIGN TO
112597     SELECT EXTRACT-FILE
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
           LABEL RECORDS ARE STANDARD.
       01 EXTRACT-RECORD                  PIC X(132).

      ************************************************************
      *         FILE LAYOUTS
      ************************************************************
       WORKING-STORAGE SECTION.
112098
112098     COPY WWSCRCPY.
112098
082407     COPY WGLB2CPY.

       01  CALLED-MODULES.
           05  PFILEINS                   PIC X(08) VALUE 'PFILEINS'.
03XX99     05  PGETMESG                   PIC X(08) VALUE 'PGETMESG'.

       01 EXTRACT-STATUS                  PIC XX.
       01 EXTRACT-FILE-NAME.
           05 WS-EXTRACT-FILE-DRIVE       PIC X(01) VALUE 'H'.
           05 FILLER                      PIC X(01) VALUE ':'.
           05 FILLER                      PIC X(01) VALUE 'R'.
           05 EXTRACT-CODER               PIC X(04) VALUE '____'.
022395*    05 FILLER                      PIC X(07) VALUE 'XXX.PDM'.
022395     05 FILLER                      PIC X(07) VALUE 'U01.PDM'.
021102     05  FILLER                  PIC X(241) VALUE SPACES.

021102*01 WS-ASCII-FILE-NAME              PIC X(50).
021102 01 WS-ASCII-FILE-NAME              PIC X(255).
021102 01 WS-NEW-ASCII-FILE-NAME          PIC X(255).

       01  WS-INDICES.
010996     05  NDX                        PIC S9(05) COMP-5.
           05  C-NDX                      PIC 9(04).
               88  C-NDX-MAX                  VALUE 15.
           05  P-NDX                      PIC 9(04).
               88  P-NDX-MAX                  VALUE 50.
           05  F-NDX                      PIC 9(04).
082407*        88  F-NDX-MAX                  VALUE 16.
082407         88  F-NDX-MAX                  VALUE WGLB2-MAX-FV-BENS.
           05  L-NDX                      PIC 9(04).
               88  L-NDX-MAX                  VALUE 175.
           05  I-NDX                      PIC 9(04).
               88  I-NDX-MAX                  VALUE 6.
03XX99 COPY WGETMCPY.

      ******************************************************************
       LINKAGE SECTION.

       COPY WGLOBCPY.

       01  WLK29-LINKAGE-RECORD.
           05  WLK29-KEY-DATA.
             07  WLK29-1.
               10  WLK29-COMPANY-CODE          PIC X(02).
               10  WLK29-POLICY-NUMBER         PIC X(12).
               10  WLK29-AGENT-NUMBER-1        PIC X(12).
               10  WLK29-AGENT-NUMBER-2        PIC X(12).
             07  WLK29-2.
               10  WLK29-INSURED-NAME.
                   15  WLK29-INSURED-LAST      PIC X(20).
                   15  WLK29-INSURED-FIRST     PIC X(20).
                   15  WLK29-INSURED-MIDDLE    PIC X(10).
             07  WLK29-3.
               10  WLK29-OWNER-SSN             PIC X(09).
               10  WLK29-OWNER-ZIP-CODE        PIC X(10).
               10  WLK29-PRODUCT-ID            PIC X(10).
               10  WLK29-GROUP-NUMBER          PIC X(10).
               10  WLK29-TAX-QUAL-CODE         PIC X(01).
               10  WLK29-RECORD-TYPE           PIC X(01).
                   88  WLK29-BASIC-INFORMATION-REC       VALUE 'B'.
                   88  WLK29-AGENT1-NAME-ADDR-REC        VALUE '1'.
                   88  WLK29-AGENT2-NAME-ADDR-REC        VALUE '2'.
                   88  WLK29-OWNER-NAME-ADDR-REC         VALUE 'O'.
                   88  WLK29-COPY-NAME-ADDR-REC          VALUE 'C'.
                   88  WLK29-POLICY-VALUE-REC            VALUE 'P'.
                   88  WLK29-FUND-DETAIL-REC             VALUE 'F'.
                   88  WLK29-LOAN-INFORMATION-REC        VALUE 'L'.
                   88  WLK29-INTEREST-RATE-REC           VALUE 'I'.
012595         10  WLK29-RECORD-SEQUENCE       PIC 9(03).
           05  WLK29-B-DATA.
               10  WLK29-B-START-DATE          PIC 9(08).
               10  WLK29-B-END-DATE            PIC 9(08).
               10  WLK29-B-START-VALUE         PIC S9(08)V9(02).
               10  WLK29-B-START-SURR-VALUE    PIC S9(08)V9(02).
               10  WLK29-B-END-VALUE           PIC S9(08)V9(02).
               10  WLK29-B-END-SURR-VALUE      PIC S9(08)V9(02).
               10  WLK29-B-BASE-ISSUE-AGE      PIC 9(03).
               10  WLK29-B-POLICY-ISSUE-DATE   PIC 9(08).
               10  WLK29-B-PRM-FOR-PREV-TAX-YR PIC S9(08)V9(02).
               10  WLK29-B-WTD-FOR-PREV-TAX-YR PIC S9(08)V9(02).
122294         10  WLK29-B-GEN-ANNUAL-STMT     PIC X(01).
           05  WLK29-1-DATA.
             07  WLK29-4.
               10  WLK29-1-NAME-TYPE           PIC X(01).
                   88  WLK29-1-NAME-INDIVIDUAL           VALUE 'I'.
                   88  WLK29-1-NAME-BUSINESS             VALUE 'B'.
               10  WLK29-1-NAME-PREFIX         PIC X(06).
               10  WLK29-1-NAME                PIC X(50).
               10  WLK29-1-NAME-SUFFIX         PIC X(06).

             07  WLK29-5.
               10  WLK29-1-ADDR-LINE-1         PIC X(35).
             07  WLK29-6.
               10  WLK29-1-ADDR-LINE-2         PIC X(35).
             07  WLK29-7.
               10  WLK29-1-ADDR-LINE-3         PIC X(35).
             07  WLK29-8.
               10  WLK29-1-CITY                PIC X(24).
               10  WLK29-1-STATE               PIC X(02).
               10  WLK29-1-ZIP-CODE            PIC X(10).
               10  WLK29-1-PHONE-NUMBER        PIC 9(10).
           05  WLK29-2-DATA.
             07  WLK29-9.
               10  WLK29-2-NAME-TYPE           PIC X(01).
                   88  WLK29-2-NAME-INDIVIDUAL           VALUE 'I'.
                   88  WLK29-2-NAME-BUSINESS             VALUE 'B'.
               10  WLK29-2-NAME-PREFIX         PIC X(06).
               10  WLK29-2-NAME                PIC X(50).
               10  WLK29-2-NAME-SUFFIX         PIC X(06).
             07  WLK29-10.
               10  WLK29-2-ADDR-LINE-1         PIC X(35).
             07  WLK29-11.
               10  WLK29-2-ADDR-LINE-2         PIC X(35).
             07  WLK29-12.
               10  WLK29-2-ADDR-LINE-3         PIC X(35).
             07  WLK29-13.
               10  WLK29-2-CITY                PIC X(24).
               10  WLK29-2-STATE               PIC X(02).
               10  WLK29-2-ZIP-CODE            PIC X(10).
               10  WLK29-2-PHONE-NUMBER        PIC 9(10).
           05  WLK29-O-DATA.
             07  WLK29-14.
               10  WLK29-O-NAME-TYPE           PIC X(01).
                   88  WLK29-O-NAME-INDIVIDUAL           VALUE 'I'.
                   88  WLK29-O-NAME-BUSINESS             VALUE 'B'.
               10  WLK29-O-NAME-PREFIX         PIC X(06).
               10  WLK29-O-NAME                PIC X(50).
               10  WLK29-O-NAME-SUFFIX         PIC X(06).
             07  WLK29-15.
               10  WLK29-O-ADDR-LINE-1         PIC X(35).
             07  WLK29-16.
               10  WLK29-O-ADDR-LINE-2         PIC X(35).
             07  WLK29-17.
               10  WLK29-O-ADDR-LINE-3         PIC X(35).
             07  WLK29-18.
               10  WLK29-O-CITY                PIC X(24).
               10  WLK29-O-STATE               PIC X(02).
               10  WLK29-O-ZIP-CODE            PIC X(10).
               10  WLK29-O-PHONE-NUMBER        PIC 9(10).
           05  WLK29-C-DATA                    OCCURS 15 TIMES.
             07  WLK29-19.
               10  WLK29-C-NAME-TYPE           PIC X(01).
                   88  WLK29-C-NAME-INDIVIDUAL           VALUE 'I'.
                   88  WLK29-C-NAME-BUSINESS             VALUE 'B'.
               10  WLK29-C-NAME-PREFIX         PIC X(06).
               10  WLK29-C-NAME                PIC X(50).
               10  WLK29-C-NAME-SUFFIX         PIC X(06).
             07  WLK29-20.
               10  WLK29-C-ADDR-LINE-1         PIC X(35).
             07  WLK29-21.
               10  WLK29-C-ADDR-LINE-2         PIC X(35).
             07  WLK29-22.
               10  WLK29-C-ADDR-LINE-3         PIC X(35).
             07  WLK29-23.
               10  WLK29-C-CITY                PIC X(24).
               10  WLK29-C-STATE               PIC X(02).
               10  WLK29-C-ZIP-CODE            PIC X(10).
               10  WLK29-C-PHONE-NUMBER        PIC 9(10).
               10  WLK29-C-RELATIONSHIP-CODE   PIC X(02).
           05  WLK29-P-DATA                    OCCURS 50 TIMES.
               10  WLK29-P-START-DATE          PIC 9(08).
               10  WLK29-P-END-DATE            PIC 9(08).
               10  WLK29-P-PREMIUMS            PIC S9(08)V9(02).
               10  WLK29-P-PREMIUM-LOADS       PIC S9(08)V9(02).
               10  WLK29-P-PREMIUM-EXPENSES    PIC S9(08)V9(02).
               10  WLK29-P-WITHDRAWALS         PIC S9(08)V9(02).
               10  WLK29-P-FED-WITHHOLDING     PIC S9(08)V9(02).
               10  WLK29-P-ST-WITHHOLDING      PIC S9(08)V9(02).
               10  WLK29-P-WITHDRAWAL-CHARGES  PIC S9(08)V9(02).
               10  WLK29-P-INTEREST-CREDITED   PIC S9(08)V9(02).
               10  WLK29-P-POLICY-VALUE        PIC S9(08)V9(02).
082407*    05  WLK29-F-DATA                    OCCURS 16 TIMES.
082407     05  WLK29-F-DATA     OCCURS WGLB2-MAX-FV-BENS TIMES.
               10  WLK29-F-FUND-ID             PIC X(10).
               10  WLK29-F-PRM-THRU-END-DATE   PIC S9(08)V9(02).
               10  WLK29-F-WTD-THRU-END-DATE   PIC S9(08)V9(02).
               10  WLK29-F-INT-THRU-END-DATE   PIC S9(08)V9(02).
           05  WLK29-L-DATA                    OCCURS 175 TIMES.
012595         10  WLK29-L-ORIG-LOAN-DATE      PIC 9(08).
               10  WLK29-L-ORIG-LOAN-AMOUNT    PIC S9(08)V9(02).
031095         10  WLK29-L-ORIG-PAYMENT-AMOUNT PIC S9(08)V9(02).
               10  WLK29-L-PAYMENT-MODE-DESC   PIC X(10).
               10  WLK29-L-BALANCE-DATE        PIC 9(08).
               10  WLK29-L-CURR-LOAN-RATE      PIC S9(03)V9(02).
               10  WLK29-L-CURR-CREDITING-RATE PIC S9(03)V9(02).
               10  WLK29-L-BALANCE-BEFORE-PYMT PIC S9(08)V9(02).
               10  WLK29-L-CAPITALIZED-INT     PIC S9(08)V9(02).
               10  WLK29-L-PAYMENT-AMOUNT      PIC S9(08)V9(02).
               10  WLK29-L-BALANCE-AFTER-PYMT  PIC S9(08)V9(02).
           05  WLK29-I-DATA.
               10  WLK29-I-INTEREST-TABLE-INFO.
                   15  WLK29-I-START-DATE-1    PIC 9(08).
                   15  WLK29-I-END-DATE-1      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-1 PIC S9(03)V9(02).
                   15  WLK29-I-START-DATE-2    PIC 9(08).
                   15  WLK29-I-END-DATE-2      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-2 PIC S9(03)V9(02).
                   15  WLK29-I-START-DATE-3    PIC 9(08).
                   15  WLK29-I-END-DATE-3      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-3 PIC S9(03)V9(02).
                   15  WLK29-I-START-DATE-4    PIC 9(08).
                   15  WLK29-I-END-DATE-4      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-4 PIC S9(03)V9(02).
                   15  WLK29-I-START-DATE-5    PIC 9(08).
                   15  WLK29-I-END-DATE-5      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-5 PIC S9(03)V9(02).
                   15  WLK29-I-START-DATE-6    PIC 9(08).
                   15  WLK29-I-END-DATE-6      PIC 9(08).
                   15  WLK29-I-INTEREST-RATE-6 PIC S9(03)V9(02).
               10  WLK29-I-INTEREST-TABLE REDEFINES
                   WLK29-I-INTEREST-TABLE-INFO OCCURS 6.
                   15  WLK29-I-START-DATE      PIC 9(08).
                   15  WLK29-I-END-DATE        PIC 9(08).
                   15  WLK29-I-INTEREST-RATE   PIC S9(03)V9(02).

      ******************************************************************
      ******************************************************************
       PROCEDURE DIVISION USING WGLOBAL
                                WLK29-LINKAGE-RECORD.

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
021102     MOVE WS-NEW-ASCII-FILE-NAME     TO EXTRACT-FILE-NAME.
           CANCEL PFILEINS.
           MOVE 'AM'                   TO WFUNC-FUNCTION.
           CALL POPFUNCN USING WGLOBAL.

           EXIT.

      ******************************************************************
       2000-PROCESS.

           PERFORM 5010-INIT-EXTRACT-FILE.
           PERFORM 5015-WRITE-KEY-DATA.
           PERFORM 5020-WRITE-B-DATA.
           PERFORM 5030-WRITE-1-DATA.
           PERFORM 5040-WRITE-2-DATA.
           PERFORM 5050-WRITE-O-DATA.
           PERFORM 5060-WRITE-C-DATA.
           PERFORM 5070-WRITE-P-DATA.
           PERFORM 5080-WRITE-F-DATA.
           PERFORM 5090-WRITE-L-DATA.
           PERFORM 5100-WRITE-I-DATA.
           CLOSE EXTRACT-FILE.

           EXIT.

      ******************************************************************
       5010-INIT-EXTRACT-FILE.

           OPEN EXTEND EXTRACT-FILE.

           IF EXTRACT-STATUS NOT = ZEROES
               CLOSE EXTRACT-FILE
               OPEN OUTPUT EXTRACT-FILE.

           EXIT.

      ******************************************************************
       5015-WRITE-KEY-DATA.

03XX99*    MOVE 'KEY-DATA'              TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028977 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           WRITE EXTRACT-RECORD        FROM WLK29-1.
           WRITE EXTRACT-RECORD        FROM WLK29-2.
           WRITE EXTRACT-RECORD        FROM WLK29-3.

           EXIT.

      ******************************************************************
       5020-WRITE-B-DATA.

03XX99*    MOVE 'B-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028978 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           MOVE WLK29-B-DATA            TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           EXIT.

      ******************************************************************
       5030-WRITE-1-DATA.

03XX99*    MOVE '1-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028979 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           WRITE EXTRACT-RECORD        FROM WLK29-4.
           WRITE EXTRACT-RECORD        FROM WLK29-5.
           WRITE EXTRACT-RECORD        FROM WLK29-6.
           WRITE EXTRACT-RECORD        FROM WLK29-7.
           WRITE EXTRACT-RECORD        FROM WLK29-8.

           EXIT.

      ******************************************************************
       5040-WRITE-2-DATA.

03XX99*    MOVE '2-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028980 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           WRITE EXTRACT-RECORD        FROM WLK29-9.
           WRITE EXTRACT-RECORD        FROM WLK29-10.
           WRITE EXTRACT-RECORD        FROM WLK29-11.
           WRITE EXTRACT-RECORD        FROM WLK29-12.
           WRITE EXTRACT-RECORD        FROM WLK29-13.

           EXIT.

      ******************************************************************
       5050-WRITE-O-DATA.

03XX99*    MOVE 'O-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028981 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           WRITE EXTRACT-RECORD        FROM WLK29-14.
           WRITE EXTRACT-RECORD        FROM WLK29-15.
           WRITE EXTRACT-RECORD        FROM WLK29-16.
           WRITE EXTRACT-RECORD        FROM WLK29-17.
           WRITE EXTRACT-RECORD        FROM WLK29-18.

           EXIT.

      ******************************************************************
       5060-WRITE-C-DATA.

03XX99*    MOVE 'C-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028982 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           PERFORM
             VARYING C-NDX FROM 1 BY 1
               UNTIL C-NDX-MAX
               IF (WLK29-C-DATA(C-NDX) > SPACES)
                   MOVE SPACES              TO EXTRACT-RECORD
                   STRING '('
                          C-NDX
                          ') '
                          WLK29-C-DATA(C-NDX)
                          DELIMITED BY SIZE
                     INTO EXTRACT-RECORD
                   WRITE EXTRACT-RECORD
                   WRITE EXTRACT-RECORD FROM WLK29-19(C-NDX)
                   WRITE EXTRACT-RECORD FROM WLK29-20(C-NDX)
                   WRITE EXTRACT-RECORD FROM WLK29-21(C-NDX)
                   WRITE EXTRACT-RECORD FROM WLK29-22(C-NDX)
                   WRITE EXTRACT-RECORD FROM WLK29-23(C-NDX)
               END-IF
           END-PERFORM.

           EXIT.

      ******************************************************************
       5070-WRITE-P-DATA.

03XX99*    MOVE 'P-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028983 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           PERFORM
             VARYING P-NDX FROM 1 BY 1
               UNTIL P-NDX-MAX
               IF (WLK29-P-DATA(P-NDX) > SPACES)
                   MOVE SPACES              TO EXTRACT-RECORD
                   STRING '('
                      P-NDX
                      ') '
                      WLK29-P-DATA(P-NDX)
                      DELIMITED BY SIZE
                     INTO EXTRACT-RECORD
                   WRITE EXTRACT-RECORD
               END-IF
           END-PERFORM.

           EXIT.

      ******************************************************************
       5080-WRITE-F-DATA.

03XX99*    MOVE 'F-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028984 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           PERFORM
             VARYING F-NDX FROM 1 BY 1
               UNTIL F-NDX-MAX
               IF (WLK29-F-DATA(F-NDX) > SPACES)
                   MOVE SPACES              TO EXTRACT-RECORD
                   STRING '('
                      F-NDX
                      ') '
                      WLK29-F-DATA(F-NDX)
                      DELIMITED BY SIZE
                     INTO EXTRACT-RECORD
                   WRITE EXTRACT-RECORD
               END-IF
           END-PERFORM.

           EXIT.

      ******************************************************************
       5090-WRITE-L-DATA.

03XX99*    MOVE 'L-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028985 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.
           WRITE EXTRACT-RECORD.

           PERFORM
             VARYING L-NDX FROM 1 BY 1
               UNTIL L-NDX-MAX
               IF (WLK29-L-DATA(L-NDX) > SPACES)
                   MOVE SPACES              TO EXTRACT-RECORD
                   STRING '('
                          L-NDX
                          ') '
                          WLK29-L-DATA(L-NDX)
                          DELIMITED BY SIZE
                      INTO EXTRACT-RECORD
                   WRITE EXTRACT-RECORD
               END-IF
           END-PERFORM.

           EXIT.

      ******************************************************************
       5100-WRITE-I-DATA.

03XX99*    MOVE 'I-DATA'                TO EXTRACT-RECORD.
03XX99     INITIALIZE WGETM-PARAMETERS
03XX99     MOVE 000028986 TO WGETM-MESSAGE-NUMBER
03XX99     CALL PGETMESG USING WGLOBAL
03XX99                         WGETM-PARAMETERS
03XX99     MOVE WGETM-MESSAGE           TO EXTRACT-RECORD.

           WRITE EXTRACT-RECORD.

           PERFORM
             VARYING I-NDX FROM 1 BY 1
               UNTIL I-NDX > 6
               IF (WLK29-I-INTEREST-TABLE(I-NDX) > SPACES)
                   MOVE SPACES              TO EXTRACT-RECORD
                   STRING '('
                          I-NDX
                          ') '
                          WLK29-I-INTEREST-TABLE(I-NDX)
                          DELIMITED BY SIZE
                     INTO EXTRACT-RECORD
                   WRITE EXTRACT-RECORD
               END-IF
           END-PERFORM.

           EXIT.

      ******************************************************************
      *                                                                *
      *                      E N D   S O U R C E                       *
      *                                                                *
      ******************************************************************


