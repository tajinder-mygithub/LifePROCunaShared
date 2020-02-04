       IDENTIFICATION DIVISION.
       CLASS-ID. OENSEAPI AS "LPNETAPI.OENSEAPI".
      *AUTHOR.         EXL.
      *DATE-WRITTEN.   MAY 2016.
      *DATE-COMPILED.
      *@**20160101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2016 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20160101*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D BAPI object that Receives, Insert, Delete and Updates ENSE information.
      *D
      *D****************************************************************

      *P****************************************************************
      *P        PROGRAMMING NOTES
      *P****************************************************************
      *P
      *P
      *P
      *P****************************************************************

      *H****************************************************************
      *H        PROGRAM HISTORY
      *H****************************************************************
101016*H 20140611-015-01 SAP New object program.
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.

       REPOSITORY.

           CLASS OAPPLICA AS "LPNETAPI.OAPPLICA"
           CLASS CLASS-EXCEPTION AS "System.Exception"
           CLASS CLASS-STRING AS "System.String"
           PROPERTY PROP-EMPTY   AS "Empty".


      ******************************************************************
      * Object 
      ******************************************************************
       IDENTIFICATION DIVISION.

       OBJECT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       01  WS-PROGRAM-INFO.
           05  PDATECON                PIC X(08) VALUE 'PDATECON'.
           05  PFILEBTV                PIC X(08) VALUE 'PFILEBTV'.
           01  PCONCMAN                PIC X(08) VALUE 'PCONCMAN'.
           COPY WENSECPY.
           COPY WAPPLCPY REPLACING
               WAPPL-CALL-PARAMETERS   BY WENSE-CALL-PARAMETERS
               WAPPL-FUNCTION          BY WENSE-FUNCTION
               WAPPL-KEY-NUMBER        BY WENSE-KEY-NUMBER
               WAPPL-RETURN-CODE       BY WENSE-RETURN-CODE
               WAPPL-RETURN-NOT-OK     BY WENSE-RETURN-NOT-OK.
           COPY WENSCCPY.
           COPY WAPPLCPY   REPLACING
               WAPPL-CALL-PARAMETERS   BY WENSC-CALL-PARAMETERS
               WAPPL-FUNCTION          BY WENSC-FUNCTION
               WAPPL-KEY-NUMBER        BY WENSC-KEY-NUMBER
               WAPPL-RETURN-CODE       BY WENSC-RETURN-CODE
               WAPPL-RETURN-NOT-OK     BY WENSC-RETURN-NOT-OK.
           COPY WGLOBCPY.
           COPY WGLBXCPY.
           COPY WBTRVCPY.
           COPY WDATECPY.
           COPY WCMANCPY.

       01  WS-COUNT                    PIC S9(04) COMP-5.
       01  WS-KEYNUMBER                PIC X(12).
       01  WS-KEYTYPE                  PIC X(01).

       01  WS-SEARCH-KEY.
           05 WS-KEY-TYPE              PIC X(01).
           05 WS-COMPANY-CODE          PIC X(02).
           05 WS-KEY-NUMBER            PIC X(12).
           05 WS-EVENT-DATE            PIC X(08).
           05 WS-SEQUENCE-NUM          PIC X(07).


       78  wsMaxEnsCount               VALUE 100.

           EXEC SQL BEGIN DECLARE SECTION END-EXEC.

       01  WS-START-KEY                PIC X(30).
       01  WS-END-KEY                  PIC X(30).

       01  WS-ENSE-DATA.
           05  WS-SQ-EventDate       PIC S9(09) COMP-5
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-EventSequence   PIC S9(09) COMP-5
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-EventCode       PIC X(04)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-EnsKeyType      PIC X(01)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-CompanyCode     PIC X(02)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-KeyNumber       PIC X(12)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-OrgOperId       PIC X(04)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-OrgDate         PIC S9(09) COMP-5
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-CmpOperId       PIC X(04)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-CmpDate         PIC S9(09) COMP-5
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-Line1           PIC X(76)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-Line2           PIC X(76)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-Line3           PIC X(76)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-SQ-Ens-Desc        PIC X(200)
                                           OCCURS wsMaxEnsCount TIMES.

       01  WS-ENSC-CODES.
           05  WS-ENSC-CODE          PIC X(04)
                                           OCCURS wsMaxEnsCount TIMES.
           05  WS-ENSC-DESC          PIC X(200)
                                           OCCURS wsMaxEnsCount TIMES.
       COPY SQLCA.

           EXEC SQL END DECLARE SECTION END-EXEC.

      ******************************************************************
      * Object Properties
      ******************************************************************

      * input

      * *** Set the following flag to determine which action you want
      * *** to perform.  The default is a Query.
      *
      *    Q - Query   
      *    U - Update
      *    A - Add  
      *    D - Delete

       01  wsFunctionFlag              PIC X(01).
       01  wsCompanyCode               PIC X(02).
       01  wsPolicyNumber              PIC X(12).
       01  wsAgentNumber               PIC X(12).
       01  wsClaimsNumber              PIC X(12).
       01  wsEventCode                 PIC X(04).
       01  wsEventDate                 PIC 9(08).
       01  wsEventSequence             PIC 9(07).

      * output

       01  LpReturnCode                PIC S9(09) COMP-5.
       01  LpErrorMessage              PIC X(200).

       01  LpOutputGroup.
           05  LpNumOfRecords    PIC 9(03).
           05  LpEventDate       PIC 9(08) OCCURS wsMaxEnsCount TIMES.
           05  LpEventSequence   PIC 9(07) OCCURS wsMaxEnsCount TIMES.
           05  LpEventCode       PIC X(08) OCCURS wsMaxEnsCount TIMES.
           05  LpENSDescription  PIC X(200) OCCURS wsMaxEnsCount TIMES.
           05  LpCompanyCode     PIC X(02).
           05  LpPolicyNumber    PIC X(12).
           05  LpAgentNumber     PIC X(12).
           05  LpClaimsNumber    PIC X(12).
           05  LpOrgOperId       PIC X(04) OCCURS wsMaxEnsCount TIMES.
           05  LpOrgDate         PIC 9(08) OCCURS wsMaxEnsCount TIMES.
           05  LpCmpOperId       PIC X(04) OCCURS wsMaxEnsCount TIMES.
           05  LpCmpDate         PIC 9(08) OCCURS wsMaxEnsCount TIMES.
           05  LpLine1           PIC X(76) OCCURS wsMaxEnsCount TIMES.
           05  LpLine2           PIC X(76) OCCURS wsMaxEnsCount TIMES.
           05  LpLine3           PIC X(76) OCCURS wsMaxEnsCount TIMES.

       01  LpOutputEnscCodes.
           05  LpNumOfCodes      PIC 9(03).
           05  LpEnscCode        PIC X(04)  OCCURS wsMaxEnsCount TIMES.
           05  LpCodeDesc        PIC X(200) OCCURS wsMaxEnsCount TIMES.


      * Update ENSE Fields.  Fill these fields with the new ENSE fields
      * value for ENSE Update.

       01  LpUpdateCmpOperId               PIC X(04).
       01  LpUpdateCmpDate                 PIC 9(08).
       01  LpUpdateLine1                   PIC X(76).
       01  LpUpdateLine2                   PIC X(76).
       01  LpUpdateLine3                   PIC X(76).


       01  LpApp                      USAGE OBJECT REFERENCE OAPPLICA.
       01  WS-EXCEPTION        OBJECT REFERENCE CLASS-EXCEPTION.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
      ******************************************************************
      * Object Methods
      ******************************************************************

      ******************************************************************
       METHOD-ID. NEW.
      ******************************************************************…
       DATA DIVISION.
      ******************************************************************

       WORKING-STORAGE SECTION.
       01  wsReturnCode         PIC S9(09) COMP-5.
       01  wsErrorMessage       PIC X(200).
       01  wsUserType           PIC X(10) VALUE SPACES.

      ******************************************************************
       LINKAGE SECTION.
       01  lsApp                USAGE OBJECT REFERENCE OAPPLICA.
       01  lsUserType           USAGE OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsApp, lsUserType.
      ******************************************************************

           SET wsUserType TO lsUserType.
           SET LpApp TO lsApp.
           MOVE WGLOBAL TO WGLOBX.

           INVOKE lsApp "Login" USING wsUserType
                                      WGLOBX
                                      wsErrorMessage
                                RETURNING wsReturnCode

           MOVE WGLOBX TO WGLOBAL.

      *    If Login Attempt was unsuccessful, place results in 
      *    return code and message properties. 
           MOVE wsReturnCode to LpReturnCode.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to LpErrorMessage
           ELSE
               MOVE SPACES TO LpErrorMessage.

       END METHOD NEW.

      ******************************************************************…
       METHOD-ID. Dispose.
      *  Dispose will free any resources, for now just the Coder ID. 
      *  It will act as a destructor, but must be explictly called. 
      ******************************************************************… 
      ******************************************************************…
       DATA DIVISION.
      ******************************************************************

       WORKING-STORAGE SECTION.
       01  wsReturnCode         PIC S9(09) COMP-5.
       01  wsErrorMessage       PIC X(200).


      ******************************************************************
       LINKAGE SECTION.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
           MOVE WGLOBAL TO WGLOBX.
           INVOKE LpApp "Logout" USING WGLOBX
                                       wsErrorMessage
                                 RETURNING  wsReturnCode
           MOVE WGLOBX TO WGLOBAL.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to LpErrorMessage
           ELSE
               MOVE SPACES TO LpErrorMessage.

       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunENSFunction.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

       01 wsEnsChangedFlag             PIC X(01).
           88  wsEnsChanged                            VALUE 'Y'.
           88  wsEnsNotChanged                         VALUE 'N'.
       01 wsFoundFlag                  PIC X(01).
           88  wsFound                                 VALUE 'Y'.

      ******************************************************************
       LINKAGE SECTION.


       01  lsReturnCode        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           MOVE ZERO TO lsReturnCode
                        LpReturnCode
           MOVE SPACES TO LpErrorMessage

           EVALUATE wsFunctionFlag
              WHEN 'U'
                  PERFORM 1000-ENS-UPDATE
              WHEN 'A'
                  PERFORM 1500-ENS-ADD
              WHEN 'D'
                  PERFORM 2000-ENS-DELETE
              WHEN 'Q'
                  PERFORM 2500-ENS-QUERY
              WHEN 'C'
                  PERFORM 3000-ENS-CODES
              WHEN OTHER
                  MOVE 'Enter Valid Function'
                               TO LpErrorMessage
                  MOVE 999     TO lsReturnCode
                                  LpReturnCode
           END-EVALUATE.


           EXIT METHOD.
      ******************************************************************
       1000-ENS-UPDATE.

           SET wsEnsNotChanged TO TRUE.

           PERFORM 1100-GET-KEY-RECORD.

           IF WENSE-RETURN-NOT-OK
               MOVE 'Record not Found'  TO LpErrorMessage
                MOVE 999                TO lsReturnCode
                                           LpReturnCode
           ELSE
              MOVE DATA-AREA            TO WENSE-DATA-RECORD
              IF LpUpdateCmpOperId NOT = WENSE-CMP-OPER-ID
                 MOVE LpUpdateCmpOperId TO WENSE-CMP-OPER-ID
                 SET wsEnsChanged       TO TRUE
              END-IF
              IF LpUpdateCmpDate NOT = WENSE-CMP-DATE
                 MOVE LpUpdateCmpDate   TO WENSE-CMP-DATE
                 SET wsEnsChanged       TO TRUE
              END-IF
              IF LpUpdateLine1 NOT = WENSE-LINE-1
                 MOVE LpUpdateLine1     TO WENSE-LINE-1
                 SET wsEnsChanged       TO TRUE
              END-IF
              IF LpUpdateLine2 NOT = WENSE-LINE-2
                 MOVE LpUpdateLine2     TO WENSE-LINE-2
                 SET wsEnsChanged       TO TRUE
              END-IF
              IF LpUpdateLine3 NOT = WENSE-LINE-3
                 MOVE LpUpdateLine3     TO WENSE-LINE-3
                 SET wsEnsChanged       TO TRUE
              END-IF
              IF wsEnsChanged
                 PERFORM 1200-CONTINUE-UPDATE
              ELSE
                 MOVE 'No Changes made.  Update canceled '
                                        TO LpErrorMessage
                 MOVE 998               TO lsReturnCode
                                           LpReturnCode
              END-IF
           END-IF.

           CONTINUE.

      ******************************************************************
       1100-GET-KEY-RECORD.

           IF wsPolicyNumber NOT = SPACES
              MOVE 'P'                    TO WENSE-KEY-TYPE
              MOVE wsPolicyNumber         TO WENSE-POLICY-NUMBER
           ELSE
              IF wsAgentNumber NOT = SPACES
                 MOVE 'A'                 TO WENSE-KEY-TYPE
                 MOVE wsAgentNumber       TO WENSE-AGENT-NUMBER
              ELSE
                 IF wsClaimsNumber NOT = SPACES
                    MOVE 'C'              TO WENSE-KEY-TYPE
                    MOVE wsClaimsNumber   TO WENSE-CLAIM-NUMBER
                 END-IF
              END-IF
           END-IF

           MOVE wsCompanyCode             TO WENSE-COMPANY-CODE
           MOVE wsEventDate               TO WENSE-EVENT-DATE
           MOVE wsEventSequence           TO WENSE-EVENT-SEQUENCE
           MOVE WBTRV-GET-EQUAL           TO WENSE-FUNCTION
           MOVE 0                         TO WENSE-KEY-NUMBER
           PERFORM 4500-ENSE-PFILEBTV

           CONTINUE.

      ******************************************************************
       1200-CONTINUE-UPDATE.

           MOVE 9999 TO WCMAN-RETURN-CODE
           IF  WENSE-TYPE-POLICY
               PERFORM 5000-CONCURRENCY-MGMT-LOCK
               IF  NOT WCMAN-SUCCESSFUL
                   MOVE WBTRV-RETURN-CODE TO lsReturnCode
                                             LpReturnCode
                   MOVE WCMAN-MESSAGE     TO LpErrorMessage
               END-IF
           END-IF.

           IF WCMAN-SUCCESSFUL
              MOVE WBTRV-UPDATE           TO WENSE-FUNCTION
              MOVE 0                      TO WENSE-KEY-NUMBER
              PERFORM 4500-ENSE-PFILEBTV
              MOVE DATA-AREA              TO WENSE-DATA-RECORD
              PERFORM 5010-CONCURRENCY-MGMT-UNLOCK
           ELSE
              IF NOT WENSE-TYPE-POLICY
                 MOVE WBTRV-UPDATE        TO WENSE-FUNCTION
                 MOVE 0                   TO WENSE-KEY-NUMBER
                 PERFORM 4500-ENSE-PFILEBTV
                 MOVE DATA-AREA           TO WENSE-DATA-RECORD
              END-IF
           END-IF.

           IF WENSE-RETURN-NOT-OK
              MOVE WBTRV-RETURN-CODE      TO lsReturnCode
                                             LpReturnCode
              MOVE 'Update Failed '       TO LpErrorMessage
           ELSE
              PERFORM 2500-ENS-QUERY
           END-IF.

           CONTINUE.

      ******************************************************************
       1500-ENS-ADD.

           INITIALIZE WENSE-DATA-RECORD
                      WS-KEYNUMBER
                      WS-KEYTYPE.

           IF wsPolicyNumber NOT = SPACES
              MOVE 'P'                  TO WENSE-KEY-TYPE
                                           WS-KEYTYPE
              MOVE wsPolicyNumber       TO WENSE-POLICY-NUMBER
                                           WS-KEYNUMBER
           ELSE
              IF wsAgentNumber NOT = SPACES
                 MOVE 'A'               TO WENSE-KEY-TYPE
                                           WS-KEYTYPE
                 MOVE wsAgentNumber     TO WENSE-AGENT-NUMBER
                                           WS-KEYNUMBER
              ELSE
                 IF wsClaimsNumber NOT = SPACES
                    MOVE 'C'            TO WENSE-KEY-TYPE
                                           WS-KEYTYPE
                    MOVE wsClaimsNumber TO WENSE-CLAIM-NUMBER
                                           WS-KEYNUMBER
                 END-IF
              END-IF
           END-IF

           MOVE wsCompanyCode           TO WENSE-COMPANY-CODE

           MOVE WBTRV-GET-EQUAL         TO WENSC-FUNCTION
           MOVE wsEventCode             TO WENSC-EVENT-CODE
           MOVE ZERO                    TO WENSC-KEY-NUMBER
           MOVE ZERO                    TO WBTRV-RETURN-CODE

           PERFORM 4000-ENSC-PFILEBTV
           MOVE DATA-AREA               TO WENSC-DATA-RECORD
           IF NOT WBTRV-SUCCESSFUL
              MOVE 'Invalid Event Code '
                                        TO LpErrorMessage
              MOVE WBTRV-RETURN-CODE    TO lsReturnCode
                                           LpReturnCode
           ELSE
              MOVE wsEventCode          TO WENSE-EVENT-CODE
              MOVE wsEventDate          TO WENSE-EVENT-DATE

      * Access the PENSE and find the sequence number of the latest event
      * on the event date.        
              MOVE 99999999             TO WENSE-EVENT-SEQUENCE
              MOVE WBTRV-GET-LESS       TO WENSE-FUNCTION
              MOVE 0                    TO WENSE-KEY-NUMBER

              PERFORM 4500-ENSE-PFILEBTV

              MOVE DATA-AREA            TO WENSE-DATA-RECORD
              IF  WENSE-RETURN-CODE EQUAL ZEROES
              AND wsEventDate    = WENSE-EVENT-DATE
              AND wsCompanyCode  = WENSE-COMPANY-CODE
              AND WS-KEYNUMBER   = WENSE-POLICY-NUMBER
                 ADD 1 TO WENSE-EVENT-SEQUENCE
              ELSE
                 MOVE '0000001'         TO WENSE-EVENT-SEQUENCE
                 MOVE wsCompanyCode     TO WENSE-COMPANY-CODE
                 MOVE wsEventDate       TO WENSE-EVENT-DATE
                 MOVE WS-KEYTYPE        TO WENSE-KEY-TYPE
                 MOVE WS-KEYNUMBER      TO WENSE-POLICY-NUMBER
              END-IF

              MOVE wsEventCode          TO WENSE-EVENT-CODE
              MOVE WCODER-ID            TO WENSE-ORG-OPER-ID

              SET WDATE-ACCEPT-SYSTEM-DATE TO TRUE
              CALL PDATECON USING WDATE-PARMS

              MOVE WDATE-SYSTEM-DATE    TO WENSE-ORG-DATE
              MOVE LpUpdateCmpOperId    TO WENSE-CMP-OPER-ID
              MOVE LpUpdateCmpDate      TO WENSE-CMP-DATE
              MOVE LpUpdateLine1        TO WENSE-LINE-1
              MOVE LpUpdateLine2        TO WENSE-LINE-2
              MOVE LpUpdateLine3        TO WENSE-LINE-3

              MOVE 9999 TO WCMAN-RETURN-CODE
              IF  WENSE-TYPE-POLICY
                  PERFORM 5000-CONCURRENCY-MGMT-LOCK
                  IF  NOT WCMAN-SUCCESSFUL
                      MOVE WBTRV-RETURN-CODE TO lsReturnCode
                                                LpReturnCode
                      MOVE WCMAN-MESSAGE     TO LpErrorMessage
                  END-IF
              END-IF
              IF WCMAN-SUCCESSFUL
                 MOVE WBTRV-INSERT         TO WENSE-FUNCTION
                 MOVE 0                    TO WENSE-KEY-NUMBER
                 PERFORM 4500-ENSE-PFILEBTV
                 MOVE DATA-AREA            TO WENSE-DATA-RECORD
                 PERFORM 5010-CONCURRENCY-MGMT-UNLOCK
              ELSE
                 IF NOT WENSE-TYPE-POLICY
                    MOVE WBTRV-INSERT      TO WENSE-FUNCTION
                    MOVE 0                 TO WENSE-KEY-NUMBER
                    PERFORM 4500-ENSE-PFILEBTV
                    MOVE DATA-AREA         TO WENSE-DATA-RECORD
                 END-IF
              END-IF

              IF WENSE-RETURN-NOT-OK
                 MOVE 'Insert Failed '     TO LpErrorMessage
                 MOVE WBTRV-RETURN-CODE    TO lsReturnCode
                                              LpReturnCode
              ELSE
                 PERFORM 2500-ENS-QUERY
              END-IF
           END-IF.

           CONTINUE.

      ******************************************************************
       2000-ENS-DELETE.

           PERFORM 1100-GET-KEY-RECORD.

           IF  WENSE-RETURN-NOT-OK
               MOVE 'Record Not Found'        TO LpErrorMessage
               MOVE WBTRV-RETURN-CODE         TO lsReturnCode
                                                 LpReturnCode
           ELSE
               MOVE DATA-AREA                 TO WENSE-DATA-RECORD
               IF  WENSE-TYPE-POLICY
                   PERFORM 5000-CONCURRENCY-MGMT-LOCK
                   IF  NOT WCMAN-SUCCESSFUL
                       MOVE WBTRV-RETURN-CODE TO lsReturnCode
                                                 LpReturnCode
                       MOVE WCMAN-MESSAGE     TO LpErrorMessage
                   END-IF
               END-IF
               IF WCMAN-SUCCESSFUL
                  MOVE WBTRV-DELETE           TO WENSE-FUNCTION
                  MOVE 0                      TO WENSE-KEY-NUMBER
                  PERFORM 4500-ENSE-PFILEBTV
                  PERFORM 5010-CONCURRENCY-MGMT-UNLOCK
               ELSE
                  IF NOT WENSE-TYPE-POLICY
                     MOVE WBTRV-DELETE        TO WENSE-FUNCTION
                     MOVE 0                   TO WENSE-KEY-NUMBER
                     PERFORM 4500-ENSE-PFILEBTV
                     MOVE DATA-AREA           TO WENSE-DATA-RECORD
                  END-IF
               END-IF

               IF WENSE-RETURN-NOT-OK
                  MOVE 'Delete Failed '       TO LpErrorMessage
                  MOVE WBTRV-RETURN-CODE      TO lsReturnCode
                                                 LpReturnCode
               ELSE
                  PERFORM 2500-ENS-QUERY
               END-IF
           END-IF.

           CONTINUE.

      ******************************************************************
       2500-ENS-QUERY.

           PERFORM VARYING WS-COUNT FROM 1 BY 1
              UNTIL WS-COUNT > wsMaxEnsCount
              MOVE ZERO   TO LpEventDate (WS-COUNT)
                             LpEventSequence (WS-COUNT)
                             LpOrgDate (WS-COUNT)
                             LpCmpDate (WS-COUNT)

              MOVE SPACES TO LpEventCode (WS-COUNT)
                             LpENSDescription (WS-COUNT)
                             LpOrgOperId (WS-COUNT)
                             LpCmpOperId (WS-COUNT)
                             LpLine1 (WS-COUNT)
                             LpLine2 (WS-COUNT)
                             LpLine3 (WS-COUNT)
           END-PERFORM.

           MOVE SPACES TO LpCompanyCode
                          LpPolicyNumber
                          LpAgentNumber
                          LpClaimsNumber
                          WS-KEYNUMBER.

           IF wsPolicyNumber NOT = SPACES
              MOVE 'P'                     TO WS-KEY-TYPE
              MOVE wsPolicyNumber          TO WS-KEY-NUMBER
                                              LpPolicyNumber
           ELSE
              IF wsAgentNumber NOT = SPACES
                 MOVE 'A'                  TO WS-KEY-TYPE
                 MOVE wsAgentNumber        TO WS-KEY-NUMBER
                                              LpAgentNumber
              ELSE
                 IF wsClaimsNumber NOT = SPACES
                    MOVE 'C'               TO WS-KEY-TYPE
                    MOVE wsClaimsNumber    TO WS-KEY-NUMBER
                                              LpClaimsNumber
                 END-IF
              END-IF
           END-IF.
           MOVE wsCompanyCode              TO WS-COMPANY-CODE
                                              LpCompanyCode.
           MOVE '00000000'                 TO WS-EVENT-DATE
                                              WS-SEQUENCE-NUM.
           MOVE WS-SEARCH-KEY              TO WS-START-KEY.

           MOVE '99999999'                 TO WS-EVENT-DATE
                                              WS-SEQUENCE-NUM.
           MOVE WS-SEARCH-KEY              TO WS-END-KEY

           EXEC SQL
                  SELECT EVENT_DATE,
                       EVENT_SEQUENCE,
                       EVENT_CODE,
                       ENS_KEY_TYPE,
                       COMPANY_CODE,
                       KEY_NUMBER,
                       ORG_OPER_ID,
                       ORG_DATE,
                       CMP_OPER_ID,
                       CMP_DATE,
                       LINE_1,
                       LINE_2,
                       LINE_3,
                       ENSE_DESCRIPTION
                   FROM FENSE003(100, :WS-START-KEY,:WS-END-KEY)
                   INTO :WS-ENSE-DATA
           END-EXEC.

           IF  NOT SQLSTATE-OK
               MOVE SQLMSG                 TO LpErrorMessage
               MOVE SQLSTATE               TO lsReturnCode
                                              LpReturnCode
           ELSE
             IF SQLERRD (3) > 0
                MOVE SQLERRD(3)            TO LpNumOfRecords

                PERFORM VARYING WS-COUNT FROM 1 BY 1
                     UNTIL WS-SQ-KeyNumber (WS-COUNT) = SPACES
                        OR WS-COUNT > wsMaxEnsCount
                        OR WS-COUNT > LpNumOfRecords

                     MOVE WS-SQ-EventDate (WS-COUNT)
                       TO LpEventDate (WS-COUNT)
                     MOVE WS-SQ-EventSequence (WS-COUNT)
                       TO LpEventSequence (WS-COUNT)
                     MOVE WS-SQ-EventCode (WS-COUNT)
                       TO LpEventCode (WS-COUNT)
                     MOVE WS-SQ-OrgOperId (WS-COUNT)
                       TO LpOrgOperId (WS-COUNT)
                     MOVE WS-SQ-OrgDate (WS-COUNT)
                       TO LpOrgDate (WS-COUNT)
                     MOVE WS-SQ-CmpOperId (WS-COUNT)
                       TO LpCmpOperId (WS-COUNT)
                     MOVE WS-SQ-CmpDate (WS-COUNT)
                       TO LpCmpDate (WS-COUNT)
                     MOVE WS-SQ-Line1 (WS-COUNT)
                       TO LpLine1 (WS-COUNT)
                     MOVE WS-SQ-Line2 (WS-COUNT)
                       TO LpLine2 (WS-COUNT)
                     MOVE WS-SQ-Line3 (WS-COUNT)
                       TO LpLine3 (WS-COUNT)
                     MOVE WS-SQ-Ens-Desc (WS-COUNT)
                       TO LpEnsDescription (WS-COUNT)
                END-PERFORM
             ELSE
                MOVE 'Record not Found'    TO LpErrorMessage
                MOVE 999                   TO lsReturnCode
                                              LpReturnCode
             END-IF
           END-IF.

           CONTINUE.

      ******************************************************************
       3000-ENS-CODES.

           PERFORM VARYING WS-COUNT FROM 1 BY 1
              UNTIL WS-COUNT > wsMaxEnsCount
              MOVE ZERO   TO LpEventDate (WS-COUNT)
                             LpEventSequence (WS-COUNT)
                             LpOrgDate (WS-COUNT)
                             LpCmpDate (WS-COUNT)

              MOVE SPACES TO LpEventCode (WS-COUNT)
                             LpENSDescription (WS-COUNT)
                             LpOrgOperId (WS-COUNT)
                             LpCmpOperId (WS-COUNT)
                             LpLine1 (WS-COUNT)
                             LpLine2 (WS-COUNT)
                             LpLine3 (WS-COUNT)
           END-PERFORM.

           EXEC SQL
                  SELECT EVENT_CODE,
                         ENSE_DESCRIPTION
                   FROM FENSE004(100)
                   INTO :WS-ENSC-CODES
           END-EXEC.

           IF  NOT SQLSTATE-OK
               MOVE SQLMSG                 TO LpErrorMessage
               MOVE SQLSTATE               TO lsReturnCode
                                              LpReturnCode
           ELSE
             IF SQLERRD (3) > 0
                MOVE SQLERRD(3)            TO LpNumOfRecords

                PERFORM VARYING WS-COUNT FROM 1 BY 1
                     UNTIL WS-SQ-KeyNumber (WS-COUNT) = SPACES
                        OR WS-COUNT > wsMaxEnsCount
                        OR WS-COUNT > LpNumOfRecords
                        MOVE WS-ENSC-CODE (WS-COUNT)
                          TO LpEventCode (WS-COUNT)
                        MOVE WS-ENSC-DESC (WS-COUNT)
                          TO LpENSDescription (WS-COUNT)
                END-PERFORM
             ELSE
                MOVE 'Record not Found'    TO LpErrorMessage
                MOVE 999                   TO lsReturnCode
                                              LpReturnCode
             END-IF
           END-IF.

           CONTINUE.

      ******************************************************************
       4000-ENSC-PFILEBTV.

           TRY

           MOVE WENSC-DATA-RECORD          TO DATA-AREA
           MOVE WFILE-ENSC-NUM             TO DATA-FILE-NUMBER
           CALL PFILEBTV USING WGLOBAL
                               WENSC-CALL-PARAMETERS
                               WBTRIEVE

           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008 TO lsReturnCode
                            LpReturnCode
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                 TO LpErrorMessage
           END-TRY.

           CONTINUE.

      ******************************************************************
       4500-ENSE-PFILEBTV.

           TRY

           MOVE WENSE-DATA-RECORD          TO DATA-AREA
           MOVE WFILE-ENSE-NUM             TO DATA-FILE-NUMBER
           CALL PFILEBTV USING WGLOBAL
                               WENSE-CALL-PARAMETERS
                               WBTRIEVE

           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008 TO lsReturnCode
                            LpReturnCode
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                 TO LpErrorMessage
           END-TRY.

           CONTINUE.
      ******************************************************************
      *  Concurrency Management Entity Lock                            *
      ******************************************************************
       5000-CONCURRENCY-MGMT-LOCK.

           SET WCMAN-REQUEST-NOWAIT-LOCK
                                       TO TRUE.
           SET WCMAN-EXCLUSIVE-LOCK    TO TRUE.
           SET WCMAN-POLICY            TO TRUE.
           MOVE WENSE-COMPANY-CODE     TO WCMAN-POLICY-COMPANY-CODE.
           MOVE WENSE-POLICY-NUMBER    TO WCMAN-POLICY-NUMBER.
           PERFORM 5020-CALL-PCONCMAN.

           CONTINUE.

      ******************************************************************
      *  Concurrency Management Entity Unlock                          *
      ******************************************************************
       5010-CONCURRENCY-MGMT-UNLOCK.

           SET WCMAN-REQUEST-UNLOCK    TO TRUE.
           SET WCMAN-POLICY            TO TRUE.
           MOVE WENSE-COMPANY-CODE     TO WCMAN-POLICY-COMPANY-CODE.
           MOVE WENSE-POLICY-NUMBER    TO WCMAN-POLICY-NUMBER.
           PERFORM 5020-CALL-PCONCMAN.

           CONTINUE.

      ******************************************************************
      *  Call Concurrency Management Routine                           *
      ******************************************************************
       5020-CALL-PCONCMAN.
           TRY

           MOVE WCODER-ID              TO WCMAN-CODER-ID
           SET WCMAN-USE-DEFAULT-TIMEOUT
                                       TO TRUE
           CALL PCONCMAN USING         WGLOBAL
                                       WCMAN-PARAMETERS

           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008 TO lsReturnCode
                            LpReturnCode
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                   TO LpErrorMessage
           END-TRY.

           CONTINUE.
      ******************************************************************
       END METHOD RunENSFunction.
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * Get methods.
      * These get and set methods take as input, and provide as output, 
      * types that are part of the Common Language Runtime.  
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision floating point, 
      * and CLASS-STRING maps to String.  This allows these get/set methods
      * to be used in VB, C# and in COBOL.NET.    
      ******************************************************************


        METHOD-ID. getErrorMessage.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsErrorMessage        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsErrorMessage.
      ******************************************************************

           SET lsErrorMessage  TO  LpErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
        METHOD-ID. getFunctionFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFunctionFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFunctionFlag.
      ******************************************************************

           SET lsFunctionFlag  TO  wsFunctionFlag.

           EXIT METHOD.

       END METHOD getFunctionFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCompanyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCompanyCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCompanyCode.
      ******************************************************************

           SET lsCompanyCode  TO  LpCompanyCode.

           EXIT METHOD.

       END METHOD getCompanyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getReturnCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           MOVE LpReturnCode TO lsReturnCode.

           EXIT METHOD.

       END METHOD getReturnCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPolicyNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsPolicyNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPolicyNumber.
      ******************************************************************

           SET lsPolicyNumber  TO  LpPolicyNumber.

           EXIT METHOD.

       END METHOD getPolicyNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAgentNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAgentNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAgentNumber.
      ******************************************************************

           SET lsAgentNumber  TO  LpAgentNumber.

           EXIT METHOD.

       END METHOD getAgentNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getClaimsNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsClaimsNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsClaimsNumber.
      ******************************************************************

           SET lsClaimsNumber  TO  LpClaimsNumber.

           EXIT METHOD.

       END METHOD getClaimsNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEventCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsEventCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsEventCode.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsEventCode TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsEventCode  TO  LpEventCode (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getEventCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEventDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsEventDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsEventDate.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               MOVE ZERO TO lsEventDate
           ELSE
               MOVE LpEventDate (lsIndex) TO lsEventDate
           END-IF.

           EXIT METHOD.

       END METHOD getEventDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNumOfRecords.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNumOfRecords     PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNumOfRecords.
      ******************************************************************

           MOVE LpNumOfRecords TO lsNumOfRecords

           EXIT METHOD.

       END METHOD getNumOfRecords.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEventSequence.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsEventSequence        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsEventSequence.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               MOVE ZERO TO lsEventSequence
           ELSE
               MOVE LpEventSequence (lsIndex) TO lsEventSequence
           END-IF.

           EXIT METHOD.

       END METHOD getEventSequence.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getOrgOperId.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsOrgOperId        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsOrgOperId.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsOrgOperId TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsOrgOperId  TO  LpOrgOperId (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getOrgOperId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getOrgDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex          PIC S9(09) COMP-5.
       01  lsOrgDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsOrgDate.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               MOVE ZERO TO lsOrgDate
           ELSE
               MOVE LpOrgDate (lsIndex) TO lsOrgDate
           END-IF.

           EXIT METHOD.

       END METHOD getOrgDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCmpOperId.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsCmpOperId        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsCmpOperId.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsCmpOperId TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsCmpOperId  TO  LpCmpOperId (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getCmpOperId.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCmpDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex          PIC S9(09) COMP-5.
       01  lsCmpDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsCmpDate.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               MOVE ZERO TO lsCmpDate
           ELSE
               MOVE LpCmpDate (lsIndex) TO lsCmpDate
           END-IF.

           EXIT METHOD.

       END METHOD getCmpDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsLine1            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsLine1.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsLine1 TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsLine1 TO LpLine1 (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsLine2            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsLine2.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsLine2 TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsLine2 TO LpLine2 (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsLine3            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsLine3.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsLine3 TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsLine3 TO LpLine3 (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getENSDescription.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex            PIC S9(09) COMP-5.
       01  lsENSDescription   OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsENSDescription.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > wsMaxEnsCount
               SET lsENSDescription TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsENSDescription TO LpENSDescription (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getENSDescription.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateCmpOperId.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateCmpOperId        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateCmpOperId.
      ******************************************************************

           SET lsUpdateCmpOperId  TO  LpUpdateCmpOperId.

           EXIT METHOD.

       END METHOD getUpdateCmpOperId.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateCmpDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateCmpDate        PIC S9(09) USAGE COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateCmpDate.
      ******************************************************************

           MOVE LpUpdateCmpDate TO lsUpdateCmpDate.

           EXIT METHOD.

       END METHOD getUpdateCmpDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine1            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateLine1.
      ******************************************************************

           SET lsUpdateLine1  TO  LpUpdateLine1.

           EXIT METHOD.

       END METHOD getUpdateLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine2            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateLine2.
      ******************************************************************

           SET lsUpdateLine2  TO  LpUpdateLine2.

           EXIT METHOD.

       END METHOD getUpdateLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine3            OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateLine3.
      ******************************************************************

           SET lsUpdateLine3  TO  LpUpdateLine3.

           EXIT METHOD.

       END METHOD getUpdateLine3.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

      ******************************************************************
      *  Set methods 
      ******************************************************************
       METHOD-ID. setFunctionFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFunctionFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFunctionFlag.
      ******************************************************************

           SET wsFunctionFlag TO lsFunctionFlag.

           EXIT METHOD.

       END METHOD setFunctionFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setCompanyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCompanyCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.
      ******************************************************************

           SET wsCompanyCode  TO  lsCompanyCode.

           EXIT METHOD.

       END METHOD setCompanyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setPolicyNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsPolicyNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.
      ******************************************************************

           SET wsPolicyNumber  TO  lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setAgentNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAgentNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAgentNumber.
      ******************************************************************

           SET wsAgentNumber  TO  lsAgentNumber.

           EXIT METHOD.

       END METHOD setAgentNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setClaimsNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsClaimsNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsClaimsNumber.
      ******************************************************************

           SET wsClaimsNumber  TO  lsClaimsNumber.

           EXIT METHOD.

       END METHOD setClaimsNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEventCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEventCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEventCode.
      ******************************************************************

           SET wsEventCode  TO  lsEventCode.

           EXIT METHOD.

       END METHOD setEventCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEventDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEventDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEventDate.
      ******************************************************************

           MOVE lsEventDate  TO  wsEventDate.

           EXIT METHOD.

       END METHOD setEventDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEventSequence.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEventSequence        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEventSequence.
      ******************************************************************

           MOVE lsEventSequence  TO  wsEventSequence.

           EXIT METHOD.

       END METHOD setEventSequence.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateCmpOperId.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateCmpOperId       OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateCmpOperId.
      ******************************************************************

           SET LpUpdateCmpOperId  TO  lsUpdateCmpOperId.

           EXIT METHOD.

       END METHOD setUpdateCmpOperId.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateCmpDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateCmpDate       PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateCmpDate.
      ******************************************************************

           MOVE lsUpdateCmpDate  TO  LpUpdateCmpDate.

           EXIT METHOD.

       END METHOD setUpdateCmpDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateLine1.
      ******************************************************************

           SET LpUpdateLine1 TO lsUpdateLine1.

           EXIT METHOD.

       END METHOD setUpdateLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateLine2.
      ******************************************************************

           SET LpUpdateLine2 TO lsUpdateLine2.

           EXIT METHOD.

       END METHOD setUpdateLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateLine3.
      ******************************************************************

           SET LpUpdateLine3 TO lsUpdateLine3.

           EXIT METHOD.

       END METHOD setUpdateLine3.

       END OBJECT.
       END CLASS OENSEAPI.

