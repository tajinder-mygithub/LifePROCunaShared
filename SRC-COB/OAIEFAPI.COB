       IDENTIFICATION DIVISION.
       CLASS-ID. OAIEFAPI AS "LPNETAPI.OAIEFAPI".
022703*AUTHOR.          WEAVER.
022703*DATE-WRITTEN.   Aug 10, 2005.
022703*DATE-COMPILED.
      *@**20170101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2017 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20170101*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D BAPI object that processes Agent Interface cards
      *D
      *D****************************************************************

      *H****************************************************************
      *H        PROGRAM HISTORY
      *H****************************************************************
082405*H 20041001-003-01 DJW New object program.
032907*H 20070329-004-01 DAR Increase WGLOB length.
100407*H 20071001-002-01 DAR Fix WGLOB length
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
112910*H 20101123-004-01 JWS Retrofit changes done for GALIC/GAFRIVA
112910*H                     including correcting dup name/address
112910*H                     code, DDEP date process, added agent data,
112910*H                     NASD information and affiliate agents.
010611*H 20101125-004-01 JWS Add Agent Consolidation Number.
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
022312*H 20111018-004-02 JVR Added Cell Phone Number to Name / Address record.
010913*H 20130108-004-01 DAR Add aspects of 20121126-003 (Hierarchy reserve 
010913*H                     amounts) to Agent API.
100114*H 20141001-002-01 SES Correctly handle failure in Name Card call
112014*H 20140812-001-01 AKR Only set "I" name if Individual being added
010217*H 20161201-003-01 SAP Changes for Personal and Business Email Addr
021717*H 20161201-003-01 SAP Increased size of data card
      *H
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.

       REPOSITORY.
           CLASS OAPPLICA AS "LPNETAPI.OAPPLICA"
021709     CLASS CLASS-EXCEPTION AS "System.Exception"
           CLASS CLASS-STRING AS "System.String".

      ******************************************************************
      * Object
      ******************************************************************
       IDENTIFICATION DIVISION.

       OBJECT.

       ENVIRONMENT DIVISION.
       DATA DIVISION.

       WORKING-STORAGE SECTION.

       COPY WWSCRCPY.

092308 01  WS-PROGRAM-INFO.
092308     05  PAIEFBOX                 PIC X(08) VALUE 'PAIEFBOX'.

       COPY WGLOBCPY.
       COPY WGLBXCPY.
       COPY WNAIFCPY.
       COPY WNFBXCPY.

       01  SUB                   PIC S9(04) COMP-5.
       01  WS-CARD               PIC S9(04) COMP-5.
       01  WS-REM                PIC S9(04) COMP-5.

       01  WS-INTERFACE-RECORD.
           05  WS-FUNCTION-TYPE                      PIC X(01).
               88  WS-ADD                                VALUE 'A'.
               88  WS-CHANGE                             VALUE 'C'.
               88  WS-DELETE                             VALUE 'D'.
               88  WS-UPDATE                             VALUE 'U'.
               88  WS-INQUIRY                            VALUE 'i'.
           05  WS-FUNCTION-SUBTYPE                   PIC X(01).
           05  WS-SEARCH-KEY-INFO.
               10  WS-COMPANY-CODE                   PIC X(02).
      * Fill the Agent Number is known
               10  WS-AGENT-NUMBER                   PIC X(12).
      * Fill Name info when processing a Name Card or when the
      * agent number is not known
112910*        10  WS-SSN-TAX-ID                     PIC 9(09).
112910         10  WS-SSN-TAX-ID                     PIC X(09).
               10  WS-BUS-NAME.
                   20  WS-BUSINESS-NAME              PIC X(50).
                   20  WS-BUSINESS-NAME-EXT          PIC X(20).
               10  FILLER REDEFINES WS-BUS-NAME.
                   20  WS-NAME-LONG-LAST.
                       25  WS-NAME-LAST              PIC X(20).
                       25  WS-NAME-LAST-EXT          PIC X(20).
                   20  WS-NAME-LONG-FIRST.
                       25  WS-NAME-FIRST             PIC X(20).
                   20  WS-NAME-LONG-MIDDLE.
                       25  WS-NAME-MIDDLE            PIC X(10).
               10  WS-NAME-TYPE                      PIC X(01).
                   88  WS-NAME-INDIVIDUAL                VALUE 'I'.
                   88  WS-NAME-BUSINESS                  VALUE 'B'.
      * These are storage for WNAIF information
           05  WS-CARD-STORAGE.
021717*        10  WS-NAME-CARD                      PIC X(500).
021717*        10  WS-ADDR-CARD                      PIC X(500).
021717*        10  WS-MASTER-CARD                    PIC X(500).
021717*        10  WS-LICENSE-CARD         OCCURS 10 PIC X(500).
021717*        10  WS-HIER-CARD                      PIC X(500).
021717*        10  WS-VEST-CARD                      PIC X(500).
021717*        10  WS-CONT-ED-CARD         OCCURS 10 PIC X(500).
021717*        10  WS-CONT-ED-CARD-H1      OCCURS 10 PIC X(500).
021717*        10  WS-CONT-ED-CARD-H2      OCCURS 10 PIC X(500).
021717*        10  WS-APPOINTMENT-CARD     OCCURS 10 PIC X(500).
021717*        10  WS-NASD-CARD            OCCURS 10 PIC X(500).
021717*        10  WS-COURSES-CARD         OCCURS 10 PIC X(500).
021717*        10  WS-PRINCIPLE-REP-CARD   OCCURS 10 PIC X(500).
021717*        10  WS-AFFILIATE-CARD       OCCURS 10 PIC X(500).
021717*        10  WS-PERSONAL-INFO-CARD   OCCURS  4 PIC X(500).
021717         10  WS-NAME-CARD                      PIC X(1000).
021717         10  WS-ADDR-CARD                      PIC X(1000).
021717         10  WS-MASTER-CARD                    PIC X(1000).
021717         10  WS-LICENSE-CARD         OCCURS 10 PIC X(1000).
021717         10  WS-HIER-CARD                      PIC X(1000).
021717         10  WS-VEST-CARD                      PIC X(1000).
021717         10  WS-CONT-ED-CARD         OCCURS 10 PIC X(1000).
021717         10  WS-CONT-ED-CARD-H1      OCCURS 10 PIC X(1000).
021717         10  WS-CONT-ED-CARD-H2      OCCURS 10 PIC X(1000).
021717         10  WS-APPOINTMENT-CARD     OCCURS 10 PIC X(1000).
021717         10  WS-NASD-CARD            OCCURS 10 PIC X(1000).
021717         10  WS-COURSES-CARD         OCCURS 10 PIC X(1000).
021717         10  WS-PRINCIPLE-REP-CARD   OCCURS 10 PIC X(1000).
021717         10  WS-AFFILIATE-CARD       OCCURS 10 PIC X(1000).
021717         10  WS-PERSONAL-INFO-CARD   OCCURS  4 PIC X(1000).

           05  CHANGE-FLAGS.
               10  WS-NAME-CHG                       PIC X(01).
               10  WS-ADDR-CHG                       PIC X(01).
               10  WS-MASTER-CHG                     PIC X(01).
               10  WS-LICENSE-CHG          OCCURS 10 PIC X(01).
               10  WS-CONT-ED-CHG          OCCURS 10 PIC X(01).
               10  WS-CONT-ED-H1-CHG       OCCURS 10 PIC X(01).
               10  WS-CONT-ED-H2-CHG       OCCURS 10 PIC X(01).
               10  WS-APPOINTMENT-CHG      OCCURS 10 PIC X(01).
112910         10  WS-NASD-CHG             OCCURS 10 PIC X(01).
               10  WS-COURSES-CHG          OCCURS 10 PIC X(01).
               10  WS-PRINCIPLE-REP-CHG    OCCURS 10 PIC X(01).
112910         10  WS-AFFILIATE-CHG        OCCURS 10 PIC X(01).
               10  WS-PERSONAL-INFO-CHG    OCCURS  4 PIC X(01).
               10  WS-HIER-CHG                       PIC X(01).
               10  WS-VEST-CHG                       PIC X(01).

           05  HOLD-CHANGE-FLAGS                     PIC X(100).

           05  DELETE-FLAGS.
               10  WS-NAME-DEL                       PIC X(01).
               10  WS-ADDR-DEL                       PIC X(01).
               10  WS-MASTER-DEL                     PIC X(01).
               10  WS-LICENSE-DEL                    PIC X(01).
               10  WS-CONT-ED-DEL                    PIC X(01).
               10  WS-CONT-ED-H1-DEL                 PIC X(01).
               10  WS-CONT-ED-H2-DEL                 PIC X(01).
               10  WS-APPOINTMENT-DEL                PIC X(01).
112910         10  WS-NASD-DEL                       PIC X(01).
               10  WS-COURSES-DEL                    PIC X(01).
               10  WS-PRINCIPLE-REP-DEL              PIC X(01).
112910         10  WS-AFFILIATE-DEL                  PIC X(01).
               10  WS-PERSONAL-INFO-DEL              PIC X(01).
               10  WS-HIER-DEL                       PIC X(01).
               10  WS-VEST-DEL                       PIC X(01).
      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpApp                      USAGE OBJECT REFERENCE OAPPLICA.
021709 01  WS-EXCEPTION        OBJECT REFERENCE CLASS-EXCEPTION.

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
           MOVE wsReturnCode to WNFBX-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WNFBX-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WNFBX-ERROR-MESSAGE.

           INITIALIZE WS-INTERFACE-RECORD.
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
               MOVE wsErrorMessage to WNFBX-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WNFBX-ERROR-MESSAGE.

       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunInterfaceFunction.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReturnCode                PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           MOVE ZERO TO lsReturnCode,
                        WNFBX-RETURN-CODE.
           MOVE SPACES TO WNFBX-ERROR-MESSAGE.

           EVALUATE TRUE
               WHEN WNAIF-INQUIRY
                   PERFORM 1000-INTERFACE-INQUIRY
               WHEN WNAIF-ADD
                   PERFORM 2000-INTERFACE-ADD
               WHEN WNAIF-DELETE
                   PERFORM 4000-INTERFACE-DELETE
               WHEN WNAIF-UPDATE
                   PERFORM 5000-INTERFACE-UPDATE
           END-EVALUATE

           EXIT METHOD.

      ******************************************************************
       1000-INTERFACE-INQUIRY.

           MOVE SPACES TO CHANGE-FLAGS
           EVALUATE TRUE
               WHEN WNAIF-DEFAULT-SEARCH
                 OR WNAIF-NAME-INQ-WITH-KEY
                 OR WNAIF-NAME-INQ-NEXT
                 OR WNAIF-NAME-INQ-WITH-AGENT
                     MOVE SPACES  TO WS-CARD-STORAGE
                     MOVE ALL 'Y' TO CHANGE-FLAGS
               WHEN WNAIF-ADDR-INQ-WITH-KEY
                 OR WNAIF-ADDR-INQ-NEXT
                    MOVE 'Y' TO WS-ADDR-CHG
               WHEN WNAIF-HIER-INQ-WITH-KEY
                 OR WNAIF-HIER-INQ-NEXT
                    MOVE 'Y' TO WS-HIER-CHG
               WHEN WNAIF-VEST-INQ-WITH-KEY
                 OR WNAIF-VEST-INQ-NEXT
                    MOVE 'Y' TO WS-VEST-CHG
           END-EVALUATE

           PERFORM 7010-CALL-FOR-ALL

           MOVE SPACES  TO CHANGE-FLAGS
                           WNAIF-FUNCTION-SUBTYPE

           CONTINUE.

      ******************************************************************
       2000-INTERFACE-ADD.

           IF CHANGE-FLAGS = SPACES
               MOVE 'No records selected To Add'
                        TO WNFBX-ERROR-MESSAGE

               MOVE 002 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           PERFORM 7010-CALL-FOR-ALL

           MOVE SPACES  TO CHANGE-FLAGS

           CONTINUE.

      ******************************************************************
       3000-INTERFACE-CHANGE.

           IF WNAIF-COMPANY-CODE NOT = WS-COMPANY-CODE
           OR WNAIF-AGENT-NUMBER NOT = WS-AGENT-NUMBER
               MOVE 'Must Retrieve Agent Information Before Updating'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 001 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           IF  WS-HIER-CHG NOT = 'Y'
           AND WS-ADDR-CHG NOT = 'Y'
               MOVE 'No Records Selected To Change'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 002 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           IF WS-HIER-CHG = 'Y'
               SET WNAIF-HIER-CARD TO TRUE
               MOVE WS-HIER-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-HIER-CARD
               MOVE SPACE TO WS-HIER-CHG
           END-IF

           IF WS-ADDR-CHG = 'Y'
               SET WNAIF-ADDR-CARD TO TRUE
               MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD
               MOVE SPACE TO WS-ADDR-CHG
           END-IF

           CONTINUE.

      ******************************************************************
       4000-INTERFACE-DELETE.

           IF WNAIF-COMPANY-CODE NOT = WS-COMPANY-CODE
           OR WNAIF-AGENT-NUMBER NOT = WS-AGENT-NUMBER
               MOVE 'Must Retrieve Agent Information Before Updating'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 001 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           IF DELETE-FLAGS = SPACES
               MOVE 'No Records Selected To Change'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 003 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           MOVE CHANGE-FLAGS TO HOLD-CHANGE-FLAGS
           MOVE SPACES       TO CHANGE-FLAGS
           PERFORM 7010-CALL-FOR-ALL
           MOVE HOLD-CHANGE-FLAGS TO CHANGE-FLAGS

           MOVE SPACES  TO DELETE-FLAGS

           CONTINUE.

      ******************************************************************
       5000-INTERFACE-UPDATE.

           IF WNAIF-COMPANY-CODE NOT = WS-COMPANY-CODE
           OR WNAIF-AGENT-NUMBER NOT = WS-AGENT-NUMBER
               MOVE 'Must Retrieve Agent Information Before Updating'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 001 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           IF CHANGE-FLAGS = SPACES
               MOVE 'No Records Selected To Update'
                        TO WNFBX-ERROR-MESSAGE
               MOVE 002 TO WNFBX-RETURN-CODE
                           lsReturnCode
               EXIT METHOD.

           PERFORM 7010-CALL-FOR-ALL

           MOVE SPACES  TO CHANGE-FLAGS

           CONTINUE.

      ******************************************************************
       7000-CALL-PAIEFBOX.

021709     TRY
092308         CALL PAIEFBOX USING WGLOBAL
092308                             WNFBX-PARMS
092308                             WNAIF-INTERFACE-RECORD
               MOVE WNAIF-FUNCTION-TYPE     TO WS-FUNCTION-TYPE
               MOVE WNAIF-COMPANY-CODE      TO WS-COMPANY-CODE
               MOVE WNAIF-AGENT-NUMBER      TO WS-AGENT-NUMBER
               MOVE WNAIF-SSN-TAX-ID        TO WS-SSN-TAX-ID
               MOVE WNAIF-BUS-NAME          TO WS-BUS-NAME
               MOVE WNAIF-NAME-TYPE         TO WS-NAME-TYPE
               MOVE WNFBX-RETURN-CODE       TO lsReturnCode
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      WNFBX-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WNFBX-ERROR-MESSAGE
021709     END-TRY.

           CONTINUE.

      *-----------------------------------------------------------------
       7010-CALL-FOR-ALL.

           IF WS-NAME-CHG = 'Y'
           OR WS-NAME-DEL = 'Y'
               SET WNAIF-NAME-CARD TO TRUE
               MOVE WS-NAME-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-NAME-CARD
           END-IF

      *    If a basic name/agent retrieval fails on an inquiry, there's no 
      *    reason to continue with additional retrievals.  
           IF WNFBX-RETURN-CODE NOT = ZERO
100114         IF  WNAIF-INQUIRY
100114*        AND WNAIF-INQUIRY
               AND ( WNAIF-DEFAULT-SEARCH OR
                     WNAIF-NAME-INQ-WITH-AGENT OR
                     WNAIF-NAME-INQ-WITH-KEY OR
                     WNAIF-NAME-INQ-NEXT)
                   INITIALIZE WS-CARD-STORAGE
100114         END-IF
           ELSE
               PERFORM 7012-FINISH-ALL-CALLS.

           CONTINUE.

       7012-FINISH-ALL-CALLS.
      *    Continuation of 7010-.  

           IF WS-ADDR-CHG = 'Y'
           OR WS-ADDR-DEL = 'Y'
               SET WNAIF-ADDR-CARD TO TRUE
               MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD
           END-IF

           IF WS-MASTER-CHG = 'Y'
           OR WS-MASTER-DEL = 'Y'
               SET WNAIF-MASTER-CARD TO TRUE
               MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD
           END-IF

           IF WS-HIER-CHG = 'Y'
           OR WS-HIER-DEL = 'Y'
               SET WNAIF-HIER-CARD TO TRUE
               MOVE WS-HIER-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-HIER-CARD
           END-IF

           IF WS-VEST-CHG = 'Y'
           OR WS-VEST-DEL = 'Y'
               SET WNAIF-VEST-CARD TO TRUE
               MOVE WS-VEST-CARD TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-VEST-CARD
           END-IF

           SET WNAIF-LICENSE-CARD TO TRUE
           IF WS-LICENSE-DEL = 'Y'
      *        If this is true, H1 and H2 will be true also. 
               MOVE WS-LICENSE-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(1)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                     UNTIL SUB > 10
                        OR WNFBX-RETURN-CODE > ZERO
                   IF WS-LICENSE-CHG(SUB) = 'Y'
                       MOVE WS-LICENSE-CARD(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-CONT-ED-CARD TO TRUE
           IF WS-CONT-ED-DEL = 'Y'
               MOVE WS-CONT-ED-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD(1)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                         UNTIL SUB > 10
                            OR WNFBX-RETURN-CODE > ZERO
                   IF WS-CONT-ED-CHG(SUB) = 'Y'
                       MOVE WS-CONT-ED-CARD(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-CONT-ED-CARD-H1 TO TRUE
           IF WS-CONT-ED-H1-DEL = 'Y'
               MOVE WS-CONT-ED-CARD-H1 (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (1)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                         UNTIL SUB > 10
                            OR WNFBX-RETURN-CODE > ZERO
                   IF WS-CONT-ED-H1-CHG(SUB) = 'Y'
                       MOVE WS-CONT-ED-CARD-H1(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-CONT-ED-CARD-H2 TO TRUE
           IF WS-CONT-ED-H2-DEL = 'Y'
               MOVE WS-CONT-ED-CARD-H2 (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (1)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                         UNTIL SUB > 10
                            OR WNFBX-RETURN-CODE > ZERO
                   IF WS-CONT-ED-H2-CHG(SUB) = 'Y'
                       MOVE WS-CONT-ED-CARD-H2(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-APPOINTMENT-CARD TO TRUE
           IF WS-APPOINTMENT-DEL = 'Y'
      *        We only need to submit one card for delete
               MOVE WS-APPOINTMENT-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD (SUB)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                         UNTIL SUB > 10
                            OR WNFBX-RETURN-CODE > ZERO
                   IF WS-APPOINTMENT-CHG(SUB) = 'Y'
                       MOVE WS-APPOINTMENT-CARD(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

112910     SET WNAIF-NASD-CARD TO TRUE
112910*     IF WS-NASD-DEL = 'Y'
112910**        We only need to submit one card for delete
112910*         MOVE WS-NASD-CARD (1) TO WNAIF-CARD-DATA
112910*         PERFORM 7000-CALL-PAIEFBOX
112910*         MOVE WNAIF-CARD-DATA TO WS-NASD-CARD (SUB)
112910*     ELSE
112910         PERFORM VARYING SUB FROM 1 BY 1
112910                   UNTIL SUB > 10
112910                      OR WNFBX-RETURN-CODE > ZERO
112910             IF WS-NASD-CHG(SUB) = 'Y'
112910                 MOVE WS-NASD-CARD(SUB) TO WNAIF-CARD-DATA
112910                 PERFORM 7000-CALL-PAIEFBOX
112910                 MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(SUB)
112910             END-IF
112910             ADD 1 TO WNAIF-CARD-TYPE
112910         END-PERFORM.
112910
           SET WNAIF-COURSES-CARD TO TRUE
           IF WS-COURSES-DEL = 'Y'
      *        We only need to submit one card for delete
               MOVE WS-COURSES-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-COURSES-CARD (SUB)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                         UNTIL SUB > 10
                            OR WNFBX-RETURN-CODE > ZERO
                   IF WS-COURSES-CHG(SUB) = 'Y'
                       MOVE WS-COURSES-CARD(SUB) TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA TO WS-COURSES-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-PRINCIPLE-REP-CARD TO TRUE
           IF WS-PRINCIPLE-REP-DEL = 'Y'
      *        We only need to submit one card for delete
               MOVE WS-PRINCIPLE-REP-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-PRINCIPLE-REP-CARD (SUB)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                          UNTIL SUB > 10
                             OR WNFBX-RETURN-CODE > ZERO
                   IF WS-PRINCIPLE-REP-CHG(SUB) = 'Y'
                       MOVE WS-PRINCIPLE-REP-CARD(SUB)
                                   TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA
                                TO WS-PRINCIPLE-REP-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

           SET WNAIF-PERSONAL-INFO-CARD TO TRUE
           IF WS-PERSONAL-INFO-DEL = 'Y'
      *        We only need to submit one card for delete
               MOVE WS-PERSONAL-INFO-CARD (1) TO WNAIF-CARD-DATA
               PERFORM 7000-CALL-PAIEFBOX
               MOVE WNAIF-CARD-DATA TO WS-PERSONAL-INFO-CARD(1)
           ELSE
               PERFORM VARYING SUB FROM 1 BY 1
                     UNTIL SUB > 4
                        OR WNFBX-RETURN-CODE > ZERO
                   IF WS-PERSONAL-INFO-CHG(SUB) = 'Y'
                       MOVE WS-PERSONAL-INFO-CARD(SUB)
                                  TO WNAIF-CARD-DATA
                       PERFORM 7000-CALL-PAIEFBOX
                       MOVE WNAIF-CARD-DATA
                                  TO WS-PERSONAL-INFO-CARD(SUB)
                   END-IF
                   ADD 1 TO WNAIF-CARD-TYPE
               END-PERFORM.

112910     SET WNAIF-AFFILIATE-CARD TO TRUE
112910     IF WS-AFFILIATE-DEL = 'Y'
112910*        We only need to submit one card for delete
112910         MOVE WS-AFFILIATE-CARD (1) TO WNAIF-CARD-DATA
112910         PERFORM 7000-CALL-PAIEFBOX
112910         MOVE WNAIF-CARD-DATA TO WS-AFFILIATE-CARD (SUB)
112910     ELSE
112910         PERFORM VARYING SUB FROM 1 BY 1
112910                    UNTIL SUB > 10
112910                       OR WNFBX-RETURN-CODE > ZERO
112910             IF WS-AFFILIATE-CHG(SUB) = 'Y'
112910                 MOVE WS-AFFILIATE-CARD(SUB)
112910                             TO WNAIF-CARD-DATA
112910                 PERFORM 7000-CALL-PAIEFBOX
112910                 MOVE WNAIF-CARD-DATA TO WS-AFFILIATE-CARD(SUB)
112910             END-IF
112910             ADD 1 TO WNAIF-CARD-TYPE
112910         END-PERFORM.

           CONTINUE.

      ******************************************************************
       END METHOD RunInterfaceFunction.
      ******************************************************************

      **************************************************************************
      **************************************************************************
       METHOD-ID. getErrorMessage.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsErrorMessage               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsErrorMessage.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNFBX-ERROR-MESSAGE
                   RETURNING lsErrorMessage.

           EXIT METHOD.
       END METHOD getErrorMessage.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getReturnCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReturnCode                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsReturnCode.

           MOVE WNFBX-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.
       END METHOD getReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * "SET FOR DELETION" FLAGS
      * To delete a record, perform a set Method on any or all
      * records to be deleted.
      *
      * NOTE THAT THE DELETE FLAG IS FOR A RECORD NOT A CARD. Records
      * defined by multiple cards will perform a delete on all cards
      ******************************************************************
      ******************************************************************
       METHOD-ID. setNameDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameDel                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameDel.

           SET WS-NAME-DEL TO lsNameDel.

           EXIT METHOD.
       END METHOD setNameDel.
      **************************************************************************
       METHOD-ID. setAddrDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddrDel                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddrDel.

           SET WS-ADDR-DEL TO lsAddrDel.

           EXIT METHOD.
       END METHOD setAddrDel.
      **************************************************************************
       METHOD-ID. setMasterDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMasterDel                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsMasterDel.

           SET WS-MASTER-DEL TO lsMasterDel.

           EXIT METHOD.
       END METHOD setMasterDel.
      **************************************************************************
       METHOD-ID. setLicenseDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLicenseDel                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsLicenseDel.

           SET WS-LICENSE-DEL TO lsLicenseDel.

           EXIT METHOD.
       END METHOD setLicenseDel.
      **************************************************************************
       METHOD-ID. setContedDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsContedDel                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsContedDel.

           SET WS-CONT-ED-DEL TO lsContedDel.

           EXIT METHOD.
       END METHOD setContedDel.
      **************************************************************************
       METHOD-ID. setContedH1Del.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsContedH1Del             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsContedH1Del.

           SET WS-CONT-ED-H1-DEL TO lsContedH1Del.

           EXIT METHOD.
       END METHOD setContedH1Del.
      **************************************************************************
       METHOD-ID. setContedH2Del.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsContedH2Del             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsContedH2Del.

           SET WS-CONT-ED-H2-DEL TO lsContedH2Del.

           EXIT METHOD.
       END METHOD setContedH2Del.
      **************************************************************************
       METHOD-ID. setAppointmentDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAppointmentDel            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAppointmentDel.

           SET WS-APPOINTMENT-DEL TO lsAppointmentDel.

           EXIT METHOD.
       END METHOD setAppointmentDel.
112910**************************************************************************
112910 METHOD-ID. setNASDDel.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNASDDel            OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsNASDDel.
112910
112910     SET WS-NASD-DEL TO lsNASDDel.
112910
112910     EXIT METHOD.
112910 END METHOD setNASDDel.
      **************************************************************************
       METHOD-ID. setCoursesDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCoursesDel                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCoursesDel.

           SET WS-COURSES-DEL TO lsCoursesDel.

           EXIT METHOD.
       END METHOD setCoursesDel.
      **************************************************************************
       METHOD-ID. setPrinciplerepDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPrinciplerepDel          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPrinciplerepDel.

           SET WS-PRINCIPLE-REP-DEL TO lsPrinciplerepDel.

           EXIT METHOD.
       END METHOD setPrinciplerepDel.
      **************************************************************************
       METHOD-ID. setPersonalinfoDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPersonalinfoDel          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPersonalinfoDel.

           SET WS-PERSONAL-INFO-DEL TO lsPersonalinfoDel.

           EXIT METHOD.
       END METHOD setPersonalinfoDel.
112910**************************************************************************
112910 METHOD-ID. setAffiliateDel.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAffiliateDel          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsAffiliateDel.
112910
112910     SET WS-AFFILIATE-DEL TO lsAffiliateDel.
112910
112910     EXIT METHOD.
112910 END METHOD setAffiliateDel.
      **************************************************************************
       METHOD-ID. setHierDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierDel                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsHierDel.

           SET WS-HIER-DEL TO lsHierDel.

           EXIT METHOD.
       END METHOD setHierDel.
      **************************************************************************
       METHOD-ID. setVestDel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDel                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestDel.

           SET WS-VEST-DEL TO lsVestDel.

           EXIT METHOD.
       END METHOD setVestDel.
      **************************************************************************
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * Get And Set methods.
      * These get and set methods take as input, and provide as output,
      * types that are part of the Common Language Runtime.
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision floating point,
      * and CLASS-STRING maps to String.  This allows these get/set methods
      * to be used in VB, C# and in COBOL.NET.
      ******************************************************************

      **************************************************************************
      **************************************************************************
       METHOD-ID. getFunctionType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFunctionType               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsFunctionType.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-FUNCTION-TYPE
                   RETURNING lsFunctionType.

           EXIT METHOD.
       END METHOD getFunctionType.
      *-------------------------------------------------------------------------
       METHOD-ID. setFunctionType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFunctionType               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsFunctionType.

           SET WNAIF-FUNCTION-TYPE TO lsFunctionType.

           EXIT METHOD.
       END METHOD setFunctionType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFunctionSubtype.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFunctionSubtype               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsFunctionSubtype.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-FUNCTION-SUBTYPE
                   RETURNING lsFunctionSubtype.

           EXIT METHOD.
       END METHOD getFunctionSubtype.
      *-------------------------------------------------------------------------
       METHOD-ID. setFunctionSubtype.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFunctionSubtype               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsFunctionSubtype.

           SET WNAIF-FUNCTION-SUBTYPE TO lsFunctionSubtype.

           EXIT METHOD.
       END METHOD setFunctionSubtype.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCompanyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCompanyCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsCompanyCode.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-COMPANY-CODE
                   RETURNING lsCompanyCode.

           EXIT METHOD.
       END METHOD getCompanyCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setCompanyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCompanyCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.

           SET WNAIF-COMPANY-CODE TO lsCompanyCode.

           EXIT METHOD.
       END METHOD setCompanyCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAgentNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgentNumber                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAgentNumber.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-AGENT-NUMBER
                   RETURNING lsAgentNumber.

           EXIT METHOD.
       END METHOD getAgentNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setAgentNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgentNumber                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAgentNumber.

           SET WNAIF-AGENT-NUMBER TO lsAgentNumber.

           EXIT METHOD.
       END METHOD setAgentNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getSsnTaxId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
112910*01  lsSsnTaxId                   PIC S9(09) COMP-5.
112910 01  lsSsnTaxId         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsSsnTaxId.

112910     SET lsSsnTaxId to WNAIF-SSN-TAX-ID.
112910*    MOVE WNAIF-SSN-TAX-ID TO lsSsnTaxId.

           EXIT METHOD.
       END METHOD getSsnTaxId.
      *-------------------------------------------------------------------------
       METHOD-ID. setSsnTaxId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
112910*01  lsSsnTaxId                   PIC S9(09) COMP-5.
112910 01  lsSsnTaxId   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsSsnTaxId.

112910     SET WNAIF-SSN-TAX-ID TO lsSsnTaxId.
112910*    MOVE lsSsnTaxId TO WNAIF-SSN-TAX-ID.

           EXIT METHOD.
       END METHOD setSsnTaxId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBusinessName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBusinessName               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsBusinessName.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-BUS-NAME
                   RETURNING lsBusinessName.

           EXIT METHOD.
       END METHOD getBusinessName.
      *-------------------------------------------------------------------------
       METHOD-ID. setBusinessName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBusinessName               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsBusinessName.

           SET WNAIF-BUS-NAME TO lsBusinessName.

           EXIT METHOD.
       END METHOD setBusinessName.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameLast.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameLast                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameLast.

           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NAME-LONG-LAST
                   RETURNING lsNameLast.

           EXIT METHOD.
       END METHOD getNameLast.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameLast.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameLast                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameLast.

092005     SET WNAIF-NAME-LONG-LAST TO lsNameLast.

           EXIT METHOD.
       END METHOD setNameLast.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameFirst.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameFirst                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameFirst.

           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NAME-FIRST
                   RETURNING lsNameFirst.

           EXIT METHOD.
       END METHOD getNameFirst.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameFirst.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameFirst                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameFirst.

092005     SET WNAIF-NAME-FIRST TO lsNameFirst.

           EXIT METHOD.
       END METHOD setNameFirst.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameMiddle.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameMiddle                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameMiddle.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-MIDDLE
                   RETURNING lsNameMiddle.

           EXIT METHOD.
       END METHOD getNameMiddle.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameMiddle.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameMiddle                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameMiddle.

           SET WNAIF-NAME-MIDDLE TO lsNameMiddle.

           EXIT METHOD.
       END METHOD setNameMiddle.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameType                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameType.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-TYPE
                   RETURNING lsNameType.

           EXIT METHOD.
       END METHOD getNameType.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameType                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameType.

           SET WNAIF-NAME-TYPE TO lsNameType.

           EXIT METHOD.
       END METHOD setNameType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameId                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsNameId.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-NAME-ID TO lsNameId.

           EXIT METHOD.
       END METHOD getNameId.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameId                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsNameId.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsNameId TO WNAIF-NAME-ID.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNameId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewSsnTin.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
112910*01  lsNewSsnTin                  PIC S9(09) COMP-5.
112910 01  lsNewSsnTin   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewSsnTin.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112910*    MOVE WNAIF-NEW-SSN-TIN TO lsNewSsnTin.
112910     SET lsNewSsnTin TO WNAIF-NEW-SSN-TIN.

           EXIT METHOD.
       END METHOD getNewSsnTin.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewSsnTin.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
112910* 01  lsNewSsnTin                  PIC S9(09) COMP-5.
112910 01  lsNewSsnTin   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewSsnTin.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112910*    MOVE lsNewSsnTin TO WNAIF-NEW-SSN-TIN.
112910     SET WNAIF-NEW-SSN-TIN TO lsNewSsnTin.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNewSsnTin.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewBusName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewBusName                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewBusName.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NEW-BUS-NAME-R
                   RETURNING lsNewBusName.

           EXIT METHOD.
       END METHOD getNewBusName.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewBusName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewBusName                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewBusName.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
092005     SET WNAIF-NEW-BUS-NAME-R TO lsNewBusName.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNewBusName.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewLast.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewLast                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewLast.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NEW-LONG-LAST-R
                   RETURNING lsNewLast.

           EXIT METHOD.
       END METHOD getNewLast.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewLast.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewLast                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewLast.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112014     IF WNAIF-NAME-INDIVIDUAL
092005        SET WNAIF-NEW-LONG-LAST-R TO lsNewLast.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNewLast.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewFirst.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewFirst                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewFirst.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NEW-FIRST
                   RETURNING lsNewFirst.

           EXIT METHOD.
       END METHOD getNewFirst.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewFirst.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewFirst                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewFirst.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112014     IF WNAIF-NAME-INDIVIDUAL
              SET WNAIF-NEW-FIRST TO lsNewFirst.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNewFirst.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewMiddle.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewMiddle                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewMiddle.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NEW-MIDDLE
                   RETURNING lsNewMiddle.

           EXIT METHOD.
       END METHOD getNewMiddle.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewMiddle.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewMiddle                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewMiddle.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112014     IF WNAIF-NAME-INDIVIDUAL
              SET WNAIF-NEW-MIDDLE TO lsNewMiddle.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNewMiddle.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNamePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNamePrefix                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNamePrefix.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NAME-LONG-PREFIX-R
                   RETURNING lsNamePrefix.

           EXIT METHOD.
       END METHOD getNamePrefix.
      *-------------------------------------------------------------------------
       METHOD-ID. setNamePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNamePrefix                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNamePrefix.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112014     IF WNAIF-NAME-INDIVIDUAL
092005        SET WNAIF-NAME-LONG-PREFIX-R TO lsNamePrefix.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNamePrefix.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameSuffix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameSuffix                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameSuffix.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
092005         BY VALUE WNAIF-NAME-LONG-SUFFIX-R
                   RETURNING lsNameSuffix.

           EXIT METHOD.
       END METHOD getNameSuffix.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameSuffix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameSuffix                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameSuffix.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112014     IF WNAIF-NAME-INDIVIDUAL
092005        SET WNAIF-NAME-LONG-SUFFIX-R TO lsNameSuffix.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNameSuffix.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameSexCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameSexCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameSexCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-SEX-CODE
                   RETURNING lsNameSexCode.

           EXIT METHOD.
       END METHOD getNameSexCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameSexCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameSexCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameSexCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-SEX-CODE TO lsNameSexCode.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNameSexCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameDeceased.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameDeceased               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameDeceased.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-DECEASED
                   RETURNING lsNameDeceased.

           EXIT METHOD.
       END METHOD getNameDeceased.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameDeceased.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameDeceased               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameDeceased.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-DECEASED TO lsNameDeceased.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNameDeceased.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDob.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDob                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsDob.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-DOB TO lsDob.

           EXIT METHOD.
       END METHOD getDob.
      *-------------------------------------------------------------------------
       METHOD-ID. setDob.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDob                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsDob.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsDob TO WNAIF-DOB.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setDob.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTaxStatus.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxStatus                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsTaxStatus.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-TAX-STATUS
                   RETURNING lsTaxStatus.

           EXIT METHOD.
       END METHOD getTaxStatus.
      *-------------------------------------------------------------------------
       METHOD-ID. setTaxStatus.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxStatus                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsTaxStatus.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-TAX-STATUS TO lsTaxStatus.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setTaxStatus.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTaxWithholdingFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxWithholdingFlag         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsTaxWithholdingFlag.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-TAX-WITHHOLDING-FLAG
                   RETURNING lsTaxWithholdingFlag.

           EXIT METHOD.
       END METHOD getTaxWithholdingFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setTaxWithholdingFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxWithholdingFlag         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsTaxWithholdingFlag.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-TAX-WITHHOLDING-FLAG TO lsTaxWithholdingFlag.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setTaxWithholdingFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTaxCertificationDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxCertificationDate       PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsTaxCertificationDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-TAX-CERTIFICATION-DATE TO lsTaxCertificationDate.

           EXIT METHOD.
       END METHOD getTaxCertificationDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setTaxCertificationDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxCertificationDate       PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsTaxCertificationDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsTaxCertificationDate TO WNAIF-TAX-CERTIFICATION-DATE.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setTaxCertificationDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTaxCertificationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxCertificationCode       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsTaxCertificationCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-TAX-CERTIFICATION-CODE
                   RETURNING lsTaxCertificationCode.

           EXIT METHOD.
       END METHOD getTaxCertificationCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setTaxCertificationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTaxCertificationCode       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsTaxCertificationCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-TAX-CERTIFICATION-CODE TO lsTaxCertificationCode.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setTaxCertificationCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDirectDepositFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDirectDepositFlag          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsDirectDepositFlag.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-DIRECT-DEPOSIT-FLAG
                   RETURNING lsDirectDepositFlag.

           EXIT METHOD.
       END METHOD getDirectDepositFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setDirectDepositFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDirectDepositFlag          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsDirectDepositFlag.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-DIRECT-DEPOSIT-FLAG TO lsDirectDepositFlag.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setDirectDepositFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNextPrenoteDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNextPrenoteDate            PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsNextPrenoteDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-NEXT-PRENOTE-DATE TO lsNextPrenoteDate.

           EXIT METHOD.
       END METHOD getNextPrenoteDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setNextPrenoteDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNextPrenoteDate            PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsNextPrenoteDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsNextPrenoteDate TO WNAIF-NEXT-PRENOTE-DATE.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setNextPrenoteDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getEndDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsEndDate                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsEndDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-END-DATE TO lsEndDate.

           EXIT METHOD.
       END METHOD getEndDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setEndDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsEndDate                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsEndDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsEndDate TO WNAIF-END-DATE.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setEndDate.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNewEndDate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNewEndDate                    PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION RETURNING lsNewEndDate.
112910
112910     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-NEW-END-DATE TO lsNewEndDate.
112910
112910     EXIT METHOD.
112910 END METHOD getNewEndDate.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNewEndDate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNewEndDate                    PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE lsNewEndDate.
112910
112910     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
112910     MOVE lsNewEndDate TO WNAIF-NEW-END-DATE.
112910     MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
112910     MOVE 'Y' TO WS-NAME-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setNewEndDate.
010217**************************************************************************
010217**************************************************************************
010217 METHOD-ID. getPersonalEmailAdr.
010217 DATA DIVISION.
010217 WORKING-STORAGE SECTION.
010217 LINKAGE SECTION.
010217 01  lsPersonalEmailAdr           OBJECT REFERENCE CLASS-STRING.
010217 PROCEDURE DIVISION RETURNING lsPersonalEmailAdr.
010217
010217     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
010217     INVOKE CLASS-STRING "NEW" USING
010217         BY VALUE WNAIF-PERSONAL-EMAIL-ADR
010217             RETURNING lsPersonalEmailAdr.
010217
010217     EXIT METHOD.
010217 END METHOD getPersonalEmailAdr.
010217*-------------------------------------------------------------------------
010217 METHOD-ID. setPersonalEmailAdr.
010217 DATA DIVISION.
010217 WORKING-STORAGE SECTION.
010217 LINKAGE SECTION.
010217 01  lsPersonalEmailAdr           OBJECT REFERENCE CLASS-STRING.
010217 PROCEDURE DIVISION USING BY VALUE lsPersonalEmailAdr.
010217
010217     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
010217     SET WNAIF-PERSONAL-EMAIL-ADR TO lsPersonalEmailAdr.
010217     MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
010217     MOVE 'Y' TO WS-NAME-CHG.
010217
010217     EXIT METHOD.
010217 END METHOD setPersonalEmailAdr.
010217**************************************************************************
010217**************************************************************************
010217 METHOD-ID. getBusinessEmailAdr.
010217 DATA DIVISION.
010217 WORKING-STORAGE SECTION.
010217 LINKAGE SECTION.
010217 01  lsBusinessEmailAdr           OBJECT REFERENCE CLASS-STRING.
010217 PROCEDURE DIVISION RETURNING lsBusinessEmailAdr.
010217
010217     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
010217     INVOKE CLASS-STRING "NEW" USING
010217         BY VALUE WNAIF-BUSINESS-EMAIL-ADR
010217             RETURNING lsBusinessEmailAdr.
010217
010217     EXIT METHOD.
010217 END METHOD getBusinessEmailAdr.
010217*-------------------------------------------------------------------------
010217 METHOD-ID. setBusinessEmailAdr.
010217 DATA DIVISION.
010217 WORKING-STORAGE SECTION.
010217 LINKAGE SECTION.
010217 01  lsBusinessEmailAdr           OBJECT REFERENCE CLASS-STRING.
010217 PROCEDURE DIVISION USING BY VALUE lsBusinessEmailAdr.
010217
010217     MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
010217     SET WNAIF-BUSINESS-EMAIL-ADR TO lsBusinessEmailAdr.
010217     MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
010217     MOVE 'Y' TO WS-NAME-CHG.
010217
010217     EXIT METHOD.
010217 END METHOD setBusinessEmailAdr.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTranCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTranCode                   PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsTranCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-TRAN-CODE TO lsTranCode.

           EXIT METHOD.
       END METHOD getTranCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setTranCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTranCode                   PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsTranCode.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsTranCode TO WNAIF-TRAN-CODE.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setTranCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBankNameId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBankNameId                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsBankNameId.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-BANK-NAME-ID TO lsBankNameId.

           EXIT METHOD.
       END METHOD getBankNameId.
      *-------------------------------------------------------------------------
       METHOD-ID. setBankNameId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBankNameId                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsBankNameId.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsBankNameId TO WNAIF-BANK-NAME-ID.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setBankNameId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPayeeBankAccount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayeeBankAccount           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsPayeeBankAccount.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PAYEE-BANK-ACCOUNT
                   RETURNING lsPayeeBankAccount.

           EXIT METHOD.
       END METHOD getPayeeBankAccount.
      *-------------------------------------------------------------------------
       METHOD-ID. setPayeeBankAccount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayeeBankAccount           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPayeeBankAccount.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-PAYEE-BANK-ACCOUNT TO lsPayeeBankAccount.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setPayeeBankAccount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLastPrenoteDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLastPrenoteDate            PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLastPrenoteDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-LAST-PRENOTE-DATE TO lsLastPrenoteDate.

           EXIT METHOD.
       END METHOD getLastPrenoteDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setLastPrenoteDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLastPrenoteDate            PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsLastPrenoteDate.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsLastPrenoteDate TO WNAIF-LAST-PRENOTE-DATE.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setLastPrenoteDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPrenoteLagDays.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPrenoteLagDays             PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsPrenoteLagDays.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-PRENOTE-LAG-DAYS TO lsPrenoteLagDays.

           EXIT METHOD.
       END METHOD getPrenoteLagDays.
      *-------------------------------------------------------------------------
       METHOD-ID. setPrenoteLagDays.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPrenoteLagDays             PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsPrenoteLagDays.

           MOVE WS-NAME-CARD TO WNAIF-CARD-DATA.
           MOVE lsPrenoteLagDays TO WNAIF-PRENOTE-LAG-DAYS.
           MOVE WNAIF-CARD-DATA TO WS-NAME-CARD.
           MOVE 'Y' TO WS-NAME-CHG.

           EXIT METHOD.
       END METHOD setPrenoteLagDays.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddressId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressId                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsAddressId.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ADDRESS-ID TO lsAddressId.

           EXIT METHOD.
       END METHOD getAddressId.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddressId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressId                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsAddressId.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsAddressId TO WNAIF-ADDRESS-ID.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAddressId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameAddr1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr1                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameAddr1.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-ADDR-1
                   RETURNING lsNameAddr1.

           EXIT METHOD.
       END METHOD getNameAddr1.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameAddr1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr1                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameAddr1.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-ADDR-1 TO lsNameAddr1.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameAddr1.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameAddr2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr2                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameAddr2.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-ADDR-2
                   RETURNING lsNameAddr2.

           EXIT METHOD.
       END METHOD getNameAddr2.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameAddr2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr2                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameAddr2.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-ADDR-2 TO lsNameAddr2.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameAddr2.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameAddr3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr3                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameAddr3.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-ADDR-3
                   RETURNING lsNameAddr3.

           EXIT METHOD.
       END METHOD getNameAddr3.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameAddr3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameAddr3                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameAddr3.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-ADDR-3 TO lsNameAddr3.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameAddr3.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameCity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCity                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameCity.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-CITY
                   RETURNING lsNameCity.

           EXIT METHOD.
       END METHOD getNameCity.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameCity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCity                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameCity.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-CITY TO lsNameCity.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameCity.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameState                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameState.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-STATE
                   RETURNING lsNameState.

           EXIT METHOD.
       END METHOD getNameState.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameState                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameState.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-STATE TO lsNameState.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getZip.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsZip                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsZip.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ZIP TO lsZip.

           EXIT METHOD.
       END METHOD getZip.
      *-------------------------------------------------------------------------
       METHOD-ID. setZip.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsZip                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsZip.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsZip TO WNAIF-ZIP.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setZip.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getZip4.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsZip4                       PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsZip4.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ZIP-4 TO lsZip4.

           EXIT METHOD.
       END METHOD getZip4.
      *-------------------------------------------------------------------------
       METHOD-ID. setZip4.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsZip4                       PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsZip4.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsZip4 TO WNAIF-ZIP-4.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setZip4.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameCntry.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCntry                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameCntry.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-CNTRY
                   RETURNING lsNameCntry.

           EXIT METHOD.
       END METHOD getNameCntry.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameCntry.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCntry                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameCntry.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-CNTRY TO lsNameCntry.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameCntry.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNameCounty.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCounty                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNameCounty.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NAME-COUNTY
                   RETURNING lsNameCounty.

           EXIT METHOD.
       END METHOD getNameCounty.
      *-------------------------------------------------------------------------
       METHOD-ID. setNameCounty.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNameCounty                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNameCounty.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NAME-COUNTY TO lsNameCounty.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setNameCounty.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCityCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCityCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsCityCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CITY-CODE
                   RETURNING lsCityCode.

           EXIT METHOD.
       END METHOD getCityCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setCityCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCityCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCityCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CITY-CODE TO lsCityCode.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setCityCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCountyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCountyCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsCountyCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-COUNTY-CODE
                   RETURNING lsCountyCode.

           EXIT METHOD.
       END METHOD getCountyCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setCountyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCountyCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCountyCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-COUNTY-CODE TO lsCountyCode.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setCountyCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddressType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressType                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddressType.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDRESS-TYPE
                   RETURNING lsAddressType.

           EXIT METHOD.
       END METHOD getAddressType.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddressType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressType                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddressType.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDRESS-TYPE TO lsAddressType.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAddressType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddressCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddressCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDRESS-CODE
                   RETURNING lsAddressCode.

           EXIT METHOD.
       END METHOD getAddressCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddressCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddressCode                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddressCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDRESS-CODE TO lsAddressCode.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAddressCode.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getBadAddressInd.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBadAddressInd             OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsBadAddressInd.
112910
112910     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-BAD-ADDRESS-IND
112910             RETURNING lsBadAddressInd.
112910
112910     EXIT METHOD.
112910 END METHOD getBadAddressInd.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setBadAddressInd.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBadAddressInd             OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsBadAddressInd.
112910
112910     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-BAD-ADDRESS-IND TO lsBadAddressInd.
112910     MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
112910     MOVE 'Y' TO WS-ADDR-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setBadAddressInd.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCancelDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCancelDate                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsCancelDate.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-CANCEL-DATE TO lsCancelDate.

           EXIT METHOD.
       END METHOD getCancelDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setCancelDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCancelDate                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsCancelDate.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsCancelDate TO WNAIF-CANCEL-DATE.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setCancelDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getEffectiveDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsEffectiveDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsEffectiveDate.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-EFFECTIVE-DATE TO lsEffectiveDate.

           EXIT METHOD.
       END METHOD getEffectiveDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setEffectiveDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsEffectiveDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsEffectiveDate TO WNAIF-EFFECTIVE-DATE.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setEffectiveDate.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNewEffectiveDate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNewEffectiveDate              PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION RETURNING lsNewEffectiveDate.
112910
112910     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-NEW-EFFECTIVE-DATE TO lsNewEffectiveDate.
112910
112910     EXIT METHOD.
112910 END METHOD getNewEffectiveDate.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNewEffectiveDate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNewEffectiveDate              PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE lsNewEffectiveDate.
112910
112910     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
112910     MOVE lsNewEffectiveDate TO WNAIF-NEW-EFFECTIVE-DATE.
112910     MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
112910     MOVE 'Y' TO WS-ADDR-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setNewEffectiveDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecurringStartMonth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStartMonth        PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsRecurringStartMonth.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECURRING-START-MONTH TO lsRecurringStartMonth.

           EXIT METHOD.
       END METHOD getRecurringStartMonth.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecurringStartMonth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStartMonth        PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRecurringStartMonth.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecurringStartMonth TO WNAIF-RECURRING-START-MONTH.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setRecurringStartMonth.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecurringStartDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStartDay          PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsRecurringStartDay.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECURRING-START-DAY TO lsRecurringStartDay.

           EXIT METHOD.
       END METHOD getRecurringStartDay.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecurringStartDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStartDay          PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRecurringStartDay.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecurringStartDay TO WNAIF-RECURRING-START-DAY.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setRecurringStartDay.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecurringStopMonth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStopMonth         PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsRecurringStopMonth.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECURRING-STOP-MONTH TO lsRecurringStopMonth.

           EXIT METHOD.
       END METHOD getRecurringStopMonth.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecurringStopMonth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStopMonth         PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRecurringStopMonth.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecurringStopMonth TO WNAIF-RECURRING-STOP-MONTH.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setRecurringStopMonth.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecurringStopDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStopDay           PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsRecurringStopDay.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECURRING-STOP-DAY TO lsRecurringStopDay.

           EXIT METHOD.
       END METHOD getRecurringStopDay.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecurringStopDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecurringStopDay           PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRecurringStopDay.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecurringStopDay TO WNAIF-RECURRING-STOP-DAY.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setRecurringStopDay.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAreaCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAreaCode                   PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsAreaCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-AREA-CODE TO lsAreaCode.

           EXIT METHOD.
       END METHOD getAreaCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setAreaCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAreaCode                   PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsAreaCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsAreaCode TO WNAIF-AREA-CODE.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAreaCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTelePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTelePrefix                 PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsTelePrefix.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-TELE-PREFIX TO lsTelePrefix.

           EXIT METHOD.
       END METHOD getTelePrefix.
      *-------------------------------------------------------------------------
       METHOD-ID. setTelePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTelePrefix                 PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsTelePrefix.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsTelePrefix TO WNAIF-TELE-PREFIX.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setTelePrefix.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTeleNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTeleNumber                 PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsTeleNumber.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-TELE-NUMBER TO lsTeleNumber.

           EXIT METHOD.
       END METHOD getTeleNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setTeleNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTeleNumber                 PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsTeleNumber.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsTeleNumber TO WNAIF-TELE-NUMBER.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setTeleNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFaxAreaCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxAreaCode                PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsFaxAreaCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-FAX-AREA-CODE TO lsFaxAreaCode.

           EXIT METHOD.
       END METHOD getFaxAreaCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setFaxAreaCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxAreaCode                PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsFaxAreaCode.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsFaxAreaCode TO WNAIF-FAX-AREA-CODE.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setFaxAreaCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFaxTelePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxTelePrefix              PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsFaxTelePrefix.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-FAX-TELE-PREFIX TO lsFaxTelePrefix.

           EXIT METHOD.
       END METHOD getFaxTelePrefix.
      *-------------------------------------------------------------------------
       METHOD-ID. setFaxTelePrefix.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxTelePrefix              PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsFaxTelePrefix.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsFaxTelePrefix TO WNAIF-FAX-TELE-PREFIX.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setFaxTelePrefix.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFaxTeleNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxTeleNumber              PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsFaxTeleNumber.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-FAX-TELE-NUMBER TO lsFaxTeleNumber.

           EXIT METHOD.
       END METHOD getFaxTeleNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setFaxTeleNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFaxTeleNumber              PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsFaxTeleNumber.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           MOVE lsFaxTeleNumber TO WNAIF-FAX-TELE-NUMBER.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setFaxTeleNumber.
      **************************************************************************
022312 METHOD-ID. getCellAreaCode.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellAreaCode               PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION RETURNING lsCellAreaCode.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE WNAIF-CELL-AREA-CODE TO lsCellAreaCode.

022312     EXIT METHOD.
022312 END METHOD getCellAreaCode.
022312*-------------------------------------------------------------------------     
022312 METHOD-ID. setCellAreaCode.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellAreaCode               PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION USING BY VALUE lsCellAreaCode.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE lsCellAreaCode TO WNAIF-CELL-AREA-CODE.
022312     MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
022312     MOVE 'Y' TO WS-ADDR-CHG.

022312     EXIT METHOD.
022312 END METHOD setCellAreaCode.
022312**************************************************************************     
022312**************************************************************************     
022312 METHOD-ID. getCellTelePrefix.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellTelePrefix             PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION RETURNING lsCellTelePrefix.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE WNAIF-CELL-TELE-PREFIX TO lsCellTelePrefix.

022312     EXIT METHOD.
022312 END METHOD getCellTelePrefix.
022312*-------------------------------------------------------------------------     
022312 METHOD-ID. setCellTelePrefix.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellTelePrefix             PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION USING BY VALUE lsCellTelePrefix.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE lsCellTelePrefix TO WNAIF-CELL-TELE-PREFIX.
022312     MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
022312     MOVE 'Y' TO WS-ADDR-CHG.

022312     EXIT METHOD.
022312 END METHOD setCellTelePrefix.
022312**************************************************************************     
022312**************************************************************************     
022312 METHOD-ID. getCellTeleNumber.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellTeleNumber             PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION RETURNING lsCellTeleNumber.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE WNAIF-CELL-TELE-NUMBER TO lsCellTeleNumber.

022312     EXIT METHOD.
022312 END METHOD getCellTeleNumber.
022312*-------------------------------------------------------------------------     
022312 METHOD-ID. setCellTeleNumber.
022312 DATA DIVISION.
022312 WORKING-STORAGE SECTION.
022312 LINKAGE SECTION.
022312 01  lsCellTeleNumber             PIC S9(04) COMP-5.
022312 PROCEDURE DIVISION USING BY VALUE lsCellTeleNumber.

022312     MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
022312     MOVE lsCellTeleNumber TO WNAIF-CELL-TELE-NUMBER.
022312     MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
022312     MOVE 'Y' TO WS-ADDR-CHG.

022312     EXIT METHOD.
022312 END METHOD setCellTeleNumber.
022312**************************************************************************     
022312**************************************************************************     

       METHOD-ID. getAddrCompany.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddrCompany               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddrCompany.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDR-COMPANY
                   RETURNING lsAddrCompany.

           EXIT METHOD.
       END METHOD getAddrCompany.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddrCompany.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddrCompany               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddrCompany.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDR-COMPANY TO lsAddrCompany.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAddrCompany.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddrPolicy.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddrPolicy                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddrPolicy.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDR-POLICY
                   RETURNING lsAddrPolicy.

           EXIT METHOD.
       END METHOD getAddrPolicy.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddrPolicy.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddrPolicy                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddrPolicy.

           MOVE WS-ADDR-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDR-POLICY TO lsAddrPolicy.
           MOVE WNAIF-CARD-DATA TO WS-ADDR-CARD.
           MOVE 'Y' TO WS-ADDR-CHG.

           EXIT METHOD.
       END METHOD setAddrPolicy.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatusCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsStatusCode.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-STATUS-CODE
                   RETURNING lsStatusCode.

           EXIT METHOD.
       END METHOD getStatusCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatusCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsStatusCode.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-STATUS-CODE TO lsStatusCode.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setStatusCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStatusDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatusDate                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsStatusDate.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-STATUS-DATE TO lsStatusDate.

           EXIT METHOD.
       END METHOD getStatusDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setStatusDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatusDate                 PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsStatusDate.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           MOVE lsStatusDate TO WNAIF-STATUS-DATE.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setStatusDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getClassification1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification1            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsClassification1.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CLASSIFICATION-1
                   RETURNING lsClassification1.

           EXIT METHOD.
       END METHOD getClassification1.
      *-------------------------------------------------------------------------
       METHOD-ID. setClassification1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification1            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsClassification1.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CLASSIFICATION-1 TO lsClassification1.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setClassification1.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getClassification2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification2            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsClassification2.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CLASSIFICATION-2
                   RETURNING lsClassification2.

           EXIT METHOD.
       END METHOD getClassification2.
      *-------------------------------------------------------------------------
       METHOD-ID. setClassification2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification2            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsClassification2.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CLASSIFICATION-2 TO lsClassification2.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setClassification2.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getClassification3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification3            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsClassification3.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CLASSIFICATION-3
                   RETURNING lsClassification3.

           EXIT METHOD.
       END METHOD getClassification3.
      *-------------------------------------------------------------------------
       METHOD-ID. setClassification3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassification3            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsClassification3.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CLASSIFICATION-3 TO lsClassification3.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setClassification3.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStartDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStartDate                  PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsStartDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-START-DATE TO lsStartDate.

           EXIT METHOD.
       END METHOD getStartDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setStartDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStartDate                  PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsStartDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsStartDate TO WNAIF-START-DATE.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setStartDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBasicAsscAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBasicAsscAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsBasicAsscAgent.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-BASIC-ASSC-AGENT
                   RETURNING lsBasicAsscAgent.

           EXIT METHOD.
       END METHOD getBasicAsscAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setBasicAsscAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBasicAsscAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsBasicAsscAgent.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-BASIC-ASSC-AGENT TO lsBasicAsscAgent.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setBasicAsscAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDbaState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDbaState                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsDbaState.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-DBA-STATE
                   RETURNING lsDbaState.

           EXIT METHOD.
       END METHOD getDbaState.
      *-------------------------------------------------------------------------
       METHOD-ID. setDbaState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDbaState                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsDbaState.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-DBA-STATE TO lsDbaState.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setDbaState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCertificationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCertificationCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsCertificationCode.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CERTIFICATION-CODE
                   RETURNING lsCertificationCode.

           EXIT METHOD.
       END METHOD getCertificationCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setCertificationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCertificationCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCertificationCode.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CERTIFICATION-CODE TO lsCertificationCode.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setCertificationCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContractDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsContractDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsContractDate.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONTRACT-DATE TO lsContractDate.

           EXIT METHOD.
       END METHOD getContractDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContractDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsContractDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsContractDate.

           MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
           MOVE lsContractDate TO WNAIF-CONTRACT-DATE.
           MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
           MOVE 'Y' TO WS-MASTER-CHG.

           EXIT METHOD.
       END METHOD setContractDate.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getAgntReasonCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAgntReasonCode          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsAgntReasonCode.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-AGNT-REASON-CODE
112910             RETURNING lsAgntReasonCode.
112910
112910     EXIT METHOD.
112910 END METHOD getAgntReasonCode.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setAgntReasonCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAgntReasonCode          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsAgntReasonCode.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-AGNT-REASON-CODE TO lsAgntReasonCode.
112910     MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
112910     MOVE 'Y' TO WS-MASTER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setAgntReasonCode.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getAutoIssueFlag.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAutoIssueFlag          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsAutoIssueFlag.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-AUTO-ISSUE-FLAG
112910             RETURNING lsAutoIssueFlag.
112910
112910     EXIT METHOD.
112910 END METHOD getAutoIssueFlag.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setAutoIssueFlag.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAutoIssueFlag          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsAutoIssueFlag.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-AUTO-ISSUE-FLAG TO lsAutoIssueFlag.
112910     MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
112910     MOVE 'Y' TO WS-MASTER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setAutoIssueFlag.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getAgntDivisionCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAgntDivisionCode          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsAgntDivisionCode.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-AGNT-DIVISION-CODE
112910             RETURNING lsAgntDivisionCode.
112910
112910     EXIT METHOD.
112910 END METHOD getAgntDivisionCode.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setAgntDivisionCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAgntDivisionCode          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsAgntDivisionCode.
112910
112910     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-AGNT-DIVISION-CODE TO lsAgntDivisionCode.
112910     MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
112910     MOVE 'Y' TO WS-MASTER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setAgntDivisionCode.
010611**************************************************************************
010611**************************************************************************
010611 METHOD-ID. getAgntConsolNum.
010611 DATA DIVISION.
010611 WORKING-STORAGE SECTION.
010611 LINKAGE SECTION.
010611 01  lsAgntConsolNum          OBJECT REFERENCE CLASS-STRING.
010611 PROCEDURE DIVISION RETURNING lsAgntConsolNum.
010611
010611     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
010611     INVOKE CLASS-STRING "NEW" USING
010611         BY VALUE WNAIF-CONSOL-NUM
010611             RETURNING lsAgntConsolNum.
010611
010611     EXIT METHOD.
010611 END METHOD getAgntConsolNum.
010611*-------------------------------------------------------------------------
010611 METHOD-ID. setAgntConsolNum.
010611 DATA DIVISION.
010611 WORKING-STORAGE SECTION.
010611 LINKAGE SECTION.
010611 01  lsAgntConsolNum          OBJECT REFERENCE CLASS-STRING.
010611 PROCEDURE DIVISION USING BY VALUE lsAgntConsolNum.
010611
010611     MOVE WS-MASTER-CARD TO WNAIF-CARD-DATA.
010611     SET WNAIF-CONSOL-NUM TO lsAgntConsolNum.
010611     MOVE WNAIF-CARD-DATA TO WS-MASTER-CARD.
010611     MOVE 'Y' TO WS-MASTER-CHG.
010611
010611     EXIT METHOD.
010611 END METHOD setAgntConsolNum.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStateLicensed.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsStateLicensed              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsStateLicensed.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-STATE-LICENSED(WS-REM)
                   RETURNING lsStateLicensed.

           EXIT METHOD.
       END METHOD getStateLicensed.
      *-------------------------------------------------------------------------
       METHOD-ID. setStateLicensed.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsStateLicensed              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsStateLicensed.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-STATE-LICENSED(WS-REM) TO lsStateLicensed.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setStateLicensed.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseStatusCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseStatusCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-LICENSE-STATUS-CODE(WS-REM)
                   RETURNING lsLicenseStatusCode.

           EXIT METHOD.
       END METHOD getLicenseStatusCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseStatusCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseStatusCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-LICENSE-STATUS-CODE(WS-REM) TO lsLicenseStatusCode.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseStatusCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseReasonCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseReasonCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-LICENSE-REASON-CODE(WS-REM)
                   RETURNING lsLicenseReasonCode.

           EXIT METHOD.
       END METHOD getLicenseReasonCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseReasonCode          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseReasonCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-LICENSE-REASON-CODE(WS-REM) TO lsLicenseReasonCode.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseReasonCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseGranted.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseGranted             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseGranted.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-LICENSE-GRANTED(WS-REM) TO lsLicenseGranted.

           EXIT METHOD.
       END METHOD getLicenseGranted.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseGranted.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseGranted             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseGranted.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsLicenseGranted TO WNAIF-LICENSE-GRANTED(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseGranted.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseExpires.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseExpires             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseExpires.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-LICENSE-EXPIRES(WS-REM) TO lsLicenseExpires.

           EXIT METHOD.
       END METHOD getLicenseExpires.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseExpires.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseExpires             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseExpires.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsLicenseExpires TO WNAIF-LICENSE-EXPIRES(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseExpires.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getResidentCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsResidentCode               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsResidentCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-RESIDENT-CODE(WS-REM)
                   RETURNING lsResidentCode.

           EXIT METHOD.
       END METHOD getResidentCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setResidentCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsResidentCode               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsResidentCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-RESIDENT-CODE(WS-REM) TO lsResidentCode.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setResidentCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNasd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsNasd                       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsNasd.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NASD(WS-REM)
                   RETURNING lsNasd.

           EXIT METHOD.
       END METHOD getNasd.
      *-------------------------------------------------------------------------
       METHOD-ID. setNasd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsNasd                       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsNasd.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-NASD(WS-REM) TO lsNasd.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setNasd.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLife.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLife                       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLife.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-LIFE(WS-REM)
                   RETURNING lsLife.

           EXIT METHOD.
       END METHOD getLife.
      *-------------------------------------------------------------------------
       METHOD-ID. setLife.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLife                       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLife.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-LIFE(WS-REM) TO lsLife.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLife.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getHealth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsHealth                     OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsHealth.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-HEALTH(WS-REM)
                   RETURNING lsHealth.

           EXIT METHOD.
       END METHOD getHealth.
      *-------------------------------------------------------------------------
       METHOD-ID. setHealth.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsHealth                     OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsHealth.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-HEALTH(WS-REM) TO lsHealth.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setHealth.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAnnuity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsAnnuity                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsAnnuity.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ANNUITY(WS-REM)
                   RETURNING lsAnnuity.

           EXIT METHOD.
       END METHOD getAnnuity.
      *-------------------------------------------------------------------------
       METHOD-ID. setAnnuity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsAnnuity                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsAnnuity.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-ANNUITY(WS-REM) TO lsAnnuity.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setAnnuity.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBasicLtc.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicLtc                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsBasicLtc.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-BASIC-LTC(WS-REM)
                   RETURNING lsBasicLtc.

           EXIT METHOD.
       END METHOD getBasicLtc.
      *-------------------------------------------------------------------------
       METHOD-ID. setBasicLtc.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicLtc                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsBasicLtc.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-BASIC-LTC(WS-REM) TO lsBasicLtc.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setBasicLtc.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBasicLastRenewal.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicLastRenewal           PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsBasicLastRenewal.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-BASIC-LAST-RENEWAL(WS-REM) TO lsBasicLastRenewal.

           EXIT METHOD.
       END METHOD getBasicLastRenewal.
      *-------------------------------------------------------------------------
       METHOD-ID. setBasicLastRenewal.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicLastRenewal           PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsBasicLastRenewal.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsBasicLastRenewal TO WNAIF-BASIC-LAST-RENEWAL(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setBasicLastRenewal.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBasicNextRenewal.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicNextRenewal           PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsBasicNextRenewal.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-BASIC-NEXT-RENEWAL(WS-REM) TO lsBasicNextRenewal.

           EXIT METHOD.
       END METHOD getBasicNextRenewal.
      *-------------------------------------------------------------------------
       METHOD-ID. setBasicNextRenewal.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsBasicNextRenewal           PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsBasicNextRenewal.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsBasicNextRenewal TO WNAIF-BASIC-NEXT-RENEWAL(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setBasicNextRenewal.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseNumber              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseNumber.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-LICENSE-NUMBER(WS-REM)
                   RETURNING lsLicenseNumber.

           EXIT METHOD.
       END METHOD getLicenseNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseNumber              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseNumber.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-LICENSE-NUMBER(WS-REM) TO lsLicenseNumber.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLicenseType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseType                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsLicenseType.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-LICENSE-TYPE(WS-REM)
                   RETURNING lsLicenseType.

           EXIT METHOD.
       END METHOD getLicenseType.
      *-------------------------------------------------------------------------
       METHOD-ID. setLicenseType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsLicenseType                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsLicenseType.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-LICENSE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-LICENSE-TYPE(WS-REM) TO lsLicenseType.
           MOVE WNAIF-CARD-DATA TO WS-LICENSE-CARD(WS-CARD).
           MOVE 'Y' TO WS-LICENSE-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setLicenseType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMarketingCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMarketingCode              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsMarketingCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-MARKETING-CODE
                   RETURNING lsMarketingCode.

           EXIT METHOD.
       END METHOD getMarketingCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setMarketingCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMarketingCode              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsMarketingCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-MARKETING-CODE TO lsMarketingCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setMarketingCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgentLevel                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-AGENT-LEVEL
                   RETURNING lsAgentLevel.

           EXIT METHOD.
       END METHOD getAgentLevel.
      *-------------------------------------------------------------------------
       METHOD-ID. setAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgentLevel                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-AGENT-LEVEL TO lsAgentLevel.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAgentLevel.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStopDate                   PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsStopDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-STOP-DATE TO lsStopDate.

           EXIT METHOD.
       END METHOD getStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStopDate                   PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsStopDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsStopDate TO WNAIF-STOP-DATE.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewMarketingCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewMarketingCode           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewMarketingCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NEW-MARKETING-CODE
                   RETURNING lsNewMarketingCode.

           EXIT METHOD.
       END METHOD getNewMarketingCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewMarketingCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewMarketingCode           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewMarketingCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NEW-MARKETING-CODE TO lsNewMarketingCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setNewMarketingCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewAgentLevel              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsNewAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-NEW-AGENT-LEVEL
                   RETURNING lsNewAgentLevel.

           EXIT METHOD.
       END METHOD getNewAgentLevel.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewAgentLevel              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsNewAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-NEW-AGENT-LEVEL TO lsNewAgentLevel.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setNewAgentLevel.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNewStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewStopDate                PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsNewStopDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-NEW-STOP-DATE TO lsNewStopDate.

           EXIT METHOD.
       END METHOD getNewStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setNewStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNewStopDate                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsNewStopDate.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsNewStopDate TO WNAIF-NEW-STOP-DATE.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setNewStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getReportDesc.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportDesc                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsReportDesc.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-REPORT-DESC
                   RETURNING lsReportDesc.

           EXIT METHOD.
       END METHOD getReportDesc.
      *-------------------------------------------------------------------------
       METHOD-ID. setReportDesc.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportDesc                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsReportDesc.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-REPORT-DESC TO lsReportDesc.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setReportDesc.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRegionCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRegionCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsRegionCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-REGION-CODE
                   RETURNING lsRegionCode.

           EXIT METHOD.
       END METHOD getRegionCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setRegionCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRegionCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsRegionCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-REGION-CODE TO lsRegionCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setRegionCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDealCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDealCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsDealCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-DEAL-CODE
                   RETURNING lsDealCode.

           EXIT METHOD.
       END METHOD getDealCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setDealCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDealCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsDealCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-DEAL-CODE TO lsDealCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setDealCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddlCommIndicator.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlCommIndicator          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddlCommIndicator.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDL-COMM-INDICATOR
                   RETURNING lsAddlCommIndicator.

           EXIT METHOD.
       END METHOD getAddlCommIndicator.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddlCommIndicator.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlCommIndicator          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddlCommIndicator.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDL-COMM-INDICATOR TO lsAddlCommIndicator.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAddlCommIndicator.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddlDealCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlDealCode               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddlDealCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDL-DEAL-CODE
                   RETURNING lsAddlDealCode.

           EXIT METHOD.
       END METHOD getAddlDealCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddlDealCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlDealCode               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddlDealCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDL-DEAL-CODE TO lsAddlDealCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAddlDealCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPayCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayCode                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsPayCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PAY-CODE
                   RETURNING lsPayCode.

           EXIT METHOD.
       END METHOD getPayCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setPayCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayCode                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPayCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-PAY-CODE TO lsPayCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setPayCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPayFrequency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayFrequency               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsPayFrequency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PAY-FREQUENCY
                   RETURNING lsPayFrequency.

           EXIT METHOD.
       END METHOD getPayFrequency.
      *-------------------------------------------------------------------------
       METHOD-ID. setPayFrequency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayFrequency               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPayFrequency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-PAY-FREQUENCY TO lsPayFrequency.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setPayFrequency.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAdvanceIndicator.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvanceIndicator           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAdvanceIndicator.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADVANCE-INDICATOR
                   RETURNING lsAdvanceIndicator.

           EXIT METHOD.
       END METHOD getAdvanceIndicator.
      *-------------------------------------------------------------------------
       METHOD-ID. setAdvanceIndicator.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvanceIndicator           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAdvanceIndicator.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADVANCE-INDICATOR TO lsAdvanceIndicator.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAdvanceIndicator.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAdvancePayFrequency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvancePayFrequency        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAdvancePayFrequency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADVANCE-PAY-FREQUENCY
                   RETURNING lsAdvancePayFrequency.

           EXIT METHOD.
       END METHOD getAdvancePayFrequency.
      *-------------------------------------------------------------------------
       METHOD-ID. setAdvancePayFrequency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvancePayFrequency        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAdvancePayFrequency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADVANCE-PAY-FREQUENCY TO lsAdvancePayFrequency.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAdvancePayFrequency.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getHierarchyAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsHierarchyAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-HIERARCHY-AGENT
                   RETURNING lsHierarchyAgent.

           EXIT METHOD.
       END METHOD getHierarchyAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setHierarchyAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsHierarchyAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-HIERARCHY-AGENT TO lsHierarchyAgent.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setHierarchyAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getHierarchyMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyMarketCode        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsHierarchyMarketCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-HIERARCHY-MARKET-CODE
                   RETURNING lsHierarchyMarketCode.

           EXIT METHOD.
       END METHOD getHierarchyMarketCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setHierarchyMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyMarketCode        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsHierarchyMarketCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-HIERARCHY-MARKET-CODE TO lsHierarchyMarketCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setHierarchyMarketCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getHierarchyAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyAgentLevel        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsHierarchyAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-HIERARCHY-AGENT-LEVEL
                   RETURNING lsHierarchyAgentLevel.

           EXIT METHOD.
       END METHOD getHierarchyAgentLevel.
      *-------------------------------------------------------------------------
       METHOD-ID. setHierarchyAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsHierarchyAgentLevel        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsHierarchyAgentLevel.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-HIERARCHY-AGENT-LEVEL TO lsHierarchyAgentLevel.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setHierarchyAgentLevel.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFinancialAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFinancialAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsFinancialAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-FINANCIAL-AGENT
                   RETURNING lsFinancialAgent.

           EXIT METHOD.
       END METHOD getFinancialAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setFinancialAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFinancialAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsFinancialAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-FINANCIAL-AGENT TO lsFinancialAgent.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setFinancialAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllocatedAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAllocatedAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ALLOCATED-AGENT
                   RETURNING lsAllocatedAgent.

           EXIT METHOD.
       END METHOD getAllocatedAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setAllocatedAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAllocatedAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ALLOCATED-AGENT TO lsAllocatedAgent.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAllocatedAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllocatedPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedPercent           USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsAllocatedPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ALLOCATED-PERCENT TO lsAllocatedPercent.

           EXIT METHOD.
       END METHOD getAllocatedPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setAllocatedPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedPercent           USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsAllocatedPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsAllocatedPercent TO WNAIF-ALLOCATED-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAllocatedPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllocatedAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedAmount            PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsAllocatedAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ALLOCATED-AMOUNT TO lsAllocatedAmount.

           EXIT METHOD.
       END METHOD getAllocatedAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setAllocatedAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocatedAmount            PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsAllocatedAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsAllocatedAmount TO WNAIF-ALLOCATED-AMOUNT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAllocatedAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDebitMaximum.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDebitMaximum               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsDebitMaximum.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-DEBIT-MAXIMUM TO lsDebitMaximum.

           EXIT METHOD.
       END METHOD getDebitMaximum.
      *-------------------------------------------------------------------------
       METHOD-ID. setDebitMaximum.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDebitMaximum               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsDebitMaximum.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsDebitMaximum TO WNAIF-DEBIT-MAXIMUM.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setDebitMaximum.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecovPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecovPercent               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsRecovPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECOV-PERCENT TO lsRecovPercent.

           EXIT METHOD.
       END METHOD getRecovPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecovPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecovPercent               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsRecovPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecovPercent TO WNAIF-RECOV-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setRecovPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRecovAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecovAmount                PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsRecovAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-RECOV-AMOUNT TO lsRecovAmount.

           EXIT METHOD.
       END METHOD getRecovAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setRecovAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRecovAmount                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRecovAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsRecovAmount TO WNAIF-RECOV-AMOUNT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setRecovAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDeferredPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDeferredPercent            USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsDeferredPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-DEFERRED-PERCENT TO lsDeferredPercent.

           EXIT METHOD.
       END METHOD getDeferredPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setDeferredPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDeferredPercent            USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsDeferredPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsDeferredPercent TO WNAIF-DEFERRED-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setDeferredPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDeferredAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDeferredAmount             PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsDeferredAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-DEFERRED-AMOUNT TO lsDeferredAmount.

           EXIT METHOD.
       END METHOD getDeferredAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setDeferredAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDeferredAmount             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsDeferredAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsDeferredAmount TO WNAIF-DEFERRED-AMOUNT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setDeferredAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAdvancePointer.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvancePointer             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAdvancePointer.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADVANCE-POINTER
                   RETURNING lsAdvancePointer.

           EXIT METHOD.
       END METHOD getAdvancePointer.
      *-------------------------------------------------------------------------
       METHOD-ID. setAdvancePointer.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAdvancePointer             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAdvancePointer.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADVANCE-POINTER TO lsAdvancePointer.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAdvancePointer.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFicaInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaInd                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsFicaInd.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-FICA-IND
                   RETURNING lsFicaInd.

           EXIT METHOD.
       END METHOD getFicaInd.
      *-------------------------------------------------------------------------
       METHOD-ID. setFicaInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaInd                    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsFicaInd.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-FICA-IND TO lsFicaInd.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setFicaInd.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAddlUpHier.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlUpHier                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAddlUpHier.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ADDL-UP-HIER
                   RETURNING lsAddlUpHier.

           EXIT METHOD.
       END METHOD getAddlUpHier.
      *-------------------------------------------------------------------------
       METHOD-ID. setAddlUpHier.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddlUpHier                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddlUpHier.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ADDL-UP-HIER TO lsAddlUpHier.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAddlUpHier.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getReportForm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportForm                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsReportForm.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-REPORT-FORM
                   RETURNING lsReportForm.

           EXIT METHOD.
       END METHOD getReportForm.
      *-------------------------------------------------------------------------
       METHOD-ID. setReportForm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportForm                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsReportForm.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-REPORT-FORM TO lsReportForm.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setReportForm.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplyToUnsecPolicy.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecPolicy         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsApplyToUnsecPolicy.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPLY-TO-UNSEC-POLICY
                   RETURNING lsApplyToUnsecPolicy.

           EXIT METHOD.
       END METHOD getApplyToUnsecPolicy.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplyToUnsecPolicy.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecPolicy         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsApplyToUnsecPolicy.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-APPLY-TO-UNSEC-POLICY TO lsApplyToUnsecPolicy.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setApplyToUnsecPolicy.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplyToUnsecNonPol.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecNonPol         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsApplyToUnsecNonPol.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPLY-TO-UNSEC-NON-POL
                   RETURNING lsApplyToUnsecNonPol.

           EXIT METHOD.
       END METHOD getApplyToUnsecNonPol.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplyToUnsecNonPol.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecNonPol         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsApplyToUnsecNonPol.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-APPLY-TO-UNSEC-NON-POL TO lsApplyToUnsecNonPol.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setApplyToUnsecNonPol.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplyToUnsecBalance.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecBalance        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsApplyToUnsecBalance.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPLY-TO-UNSEC-BALANCE
                   RETURNING lsApplyToUnsecBalance.

           EXIT METHOD.
       END METHOD getApplyToUnsecBalance.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplyToUnsecBalance.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsApplyToUnsecBalance        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsApplyToUnsecBalance.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-APPLY-TO-UNSEC-BALANCE TO lsApplyToUnsecBalance.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setApplyToUnsecBalance.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFicaPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaPercent                USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsFicaPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-FICA-PERCENT TO lsFicaPercent.

           EXIT METHOD.
       END METHOD getFicaPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setFicaPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaPercent                USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsFicaPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsFicaPercent TO WNAIF-FICA-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setFicaPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getFicaMaximum.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaMaximum                PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsFicaMaximum.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-FICA-MAXIMUM TO lsFicaMaximum.

           EXIT METHOD.
       END METHOD getFicaMaximum.
      *-------------------------------------------------------------------------
       METHOD-ID. setFicaMaximum.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsFicaMaximum                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsFicaMaximum.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsFicaMaximum TO WNAIF-FICA-MAXIMUM.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setFicaMaximum.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStatementAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatementAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsStatementAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-STATEMENT-AGENT
                   RETURNING lsStatementAgent.

           EXIT METHOD.
       END METHOD getStatementAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setStatementAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatementAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsStatementAgent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-STATEMENT-AGENT TO lsStatementAgent.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setStatementAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getStatementInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatementInd               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsStatementInd.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-STATEMENT-IND
                   RETURNING lsStatementInd.

           EXIT METHOD.
       END METHOD getStatementInd.
      *-------------------------------------------------------------------------
       METHOD-ID. setStatementInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsStatementInd               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsStatementInd.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-STATEMENT-IND TO lsStatementInd.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setStatementInd.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllocRenewalPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocRenewalPercent        USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsAllocRenewalPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ALLOC-RENEWAL-PERCENT TO lsAllocRenewalPercent.

           EXIT METHOD.
       END METHOD getAllocRenewalPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setAllocRenewalPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocRenewalPercent        USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsAllocRenewalPercent.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsAllocRenewalPercent TO WNAIF-ALLOC-RENEWAL-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAllocRenewalPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllocRenewalAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocRenewalAmount         PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsAllocRenewalAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-ALLOC-RENEWAL-AMOUNT TO lsAllocRenewalAmount.

           EXIT METHOD.
       END METHOD getAllocRenewalAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setAllocRenewalAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAllocRenewalAmount         PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsAllocRenewalAmount.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsAllocRenewalAmount TO WNAIF-ALLOC-RENEWAL-AMOUNT.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAllocRenewalAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPayReason.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayReason                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsPayReason.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PAY-REASON
                   RETURNING lsPayReason.

           EXIT METHOD.
       END METHOD getPayReason.
      *-------------------------------------------------------------------------
       METHOD-ID. setPayReason.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPayReason                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPayReason.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-PAY-REASON TO lsPayReason.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setPayReason.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAgencyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgencyCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAgencyCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-AGENCY-CODE
                   RETURNING lsAgencyCode.

           EXIT METHOD.
       END METHOD getAgencyCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setAgencyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAgencyCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAgencyCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-AGENCY-CODE TO lsAgencyCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAgencyCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMga.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMga                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsMga.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-MGA TO lsMga.

           EXIT METHOD.
       END METHOD getMga.
      *-------------------------------------------------------------------------
       METHOD-ID. setMga.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMga                        PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsMga.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsMga TO WNAIF-MGA.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setMga.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getControl.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsControl                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsControl.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONTROL TO lsControl.

           EXIT METHOD.
       END METHOD getControl.
      *-------------------------------------------------------------------------
       METHOD-ID. setControl.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsControl                    PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsControl.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsControl TO WNAIF-CONTROL.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setControl.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getControlId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsControlId                  PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsControlId.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONTROL-ID TO lsControlId.

           EXIT METHOD.
       END METHOD getControlId.
      *-------------------------------------------------------------------------
       METHOD-ID. setControlId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsControlId                  PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsControlId.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           MOVE lsControlId TO WNAIF-CONTROL-ID.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setControlId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getServicingAgency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsServicingAgency            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsServicingAgency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-SERVICING-AGENCY
                   RETURNING lsServicingAgency.

           EXIT METHOD.
       END METHOD getServicingAgency.
      *-------------------------------------------------------------------------
       METHOD-ID. setServicingAgency.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsServicingAgency            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsServicingAgency.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-SERVICING-AGENCY TO lsServicingAgency.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setServicingAgency.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMailSortKey.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMailSortKey                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsMailSortKey.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-MAIL-SORT-KEY
                   RETURNING lsMailSortKey.

           EXIT METHOD.
       END METHOD getMailSortKey.
      *-------------------------------------------------------------------------
       METHOD-ID. setMailSortKey.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMailSortKey                OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsMailSortKey.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-MAIL-SORT-KEY TO lsMailSortKey.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setMailSortKey.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAssignmentFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAssignmentFlag             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsAssignmentFlag.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-ASSIGNMENT-FLAG
                   RETURNING lsAssignmentFlag.

           EXIT METHOD.
       END METHOD getAssignmentFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setAssignmentFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAssignmentFlag             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAssignmentFlag.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-ASSIGNMENT-FLAG TO lsAssignmentFlag.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setAssignmentFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReasonCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsReasonCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-REASON-CODE
                   RETURNING lsReasonCode.

           EXIT METHOD.
       END METHOD getReasonCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReasonCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsReasonCode.

           MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-REASON-CODE TO lsReasonCode.
           MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
           MOVE 'Y' TO WS-HIER-CHG.

           EXIT METHOD.
       END METHOD setReasonCode.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getDivisionIndicator.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsDivisionIndicator          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsDivisionIndicator.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-DIVISION-INDICATOR
112910             RETURNING lsDivisionIndicator.
112910
112910     EXIT METHOD.
112910 END METHOD getDivisionIndicator.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setDivisionIndicator.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsDivisionIndicator          OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsDivisionIndicator.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-DIVISION-INDICATOR TO lsDivisionIndicator.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setDivisionIndicator.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getProdPercent.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsProdPercent                USAGE IS COMP-2.
112910 PROCEDURE DIVISION RETURNING lsProdPercent.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-PROD-PCT TO lsProdPercent.
112910
112910     EXIT METHOD.
112910 END METHOD getProdPercent.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setProdPercent.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsProdPercent                USAGE IS COMP-2.
112910 PROCEDURE DIVISION USING BY VALUE lsProdPercent.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE lsProdPercent TO WNAIF-PROD-PCT.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setProdPercent.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNetComm.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNetComm                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsNetComm.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-NET-COMM
112910             RETURNING lsNetComm.
112910
112910     EXIT METHOD.
112910 END METHOD getNetComm.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNetComm.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsNetComm                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsNetComm.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-NET-COMM TO lsNetComm.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setNetComm.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getCommType.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsCommType                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsCommType.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-COMM-TYPE
112910             RETURNING lsCommType.
112910
112910     EXIT METHOD.
112910 END METHOD getCommType.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setCommType.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsCommType                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsCommType.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-COMM-TYPE TO lsCommType.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setCommType.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getBonusAllowed.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
       01  lsBonusAllowed OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsBonusAllowed.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-BONUS-ALLOWED-FLAG
112910             RETURNING lsBonusAllowed.
112910
112910     EXIT METHOD.
112910 END METHOD getBonusAllowed.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setBonusAllowed.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBonusAllowed OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsBonusAllowed.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-BONUS-ALLOWED-FLAG TO lsBonusAllowed.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setBonusAllowed.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getBonusLevel.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBonusLevel                  PIC S9(04) COMP-5.
112910 PROCEDURE DIVISION RETURNING lsBonusLevel.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-BONUS-LEVEL TO lsBonusLevel.
112910
112910     EXIT METHOD.
112910 END METHOD getBonusLevel.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setBonusLevel.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBonusLevel                  PIC S9(04) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE lsBonusLevel.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE lsBonusLevel TO WNAIF-BONUS-LEVEL.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setBonusLevel.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getBonusCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBonusCode                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsBonusCode.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-BONUS-CODE
112910             RETURNING lsBonusCode.
112910
112910     EXIT METHOD.
112910 END METHOD getBonusCode.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setBonusCode.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsBonusCode                    OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsBonusCode.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-BONUS-CODE TO lsBonusCode.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setBonusCode.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getDbBalIntFlag.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
       01  lsDbBalIntFlag OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsDbBalIntFlag.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-DB-BAL-INT-FLAG
112910             RETURNING lsDbBalIntFlag.
112910
112910     EXIT METHOD.
112910 END METHOD getDbBalIntFlag.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setDbBalIntFlag.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsDbBalIntFlag  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsDbBalIntFlag.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-DB-BAL-INT-FLAG TO lsDbBalIntFlag.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setDbBalIntFlag.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getDbBalIntPct.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsDbBalIntPct                USAGE IS COMP-2.
112910 PROCEDURE DIVISION RETURNING lsDbBalIntPct.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-DB-BAL-INT-PCT TO lsDbBalIntPct.
112910
112910     EXIT METHOD.
112910 END METHOD getDbBalIntPct.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setDbBalIntPct.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsDbBalIntPct                USAGE IS COMP-2.
112910 PROCEDURE DIVISION USING BY VALUE lsDbBalIntPct.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     MOVE lsDbBalIntPct TO WNAIF-DB-BAL-INT-PCT.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setDbBalIntPct.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getDfltCommOptn.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
       01  lsDfltCommOptn  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsDfltCommOptn.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-DFLT-COMM-OPTN
112910             RETURNING lsDfltCommOptn.
112910
112910     EXIT METHOD.
112910 END METHOD getDfltCommOptn.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setDfltCommOptn.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
       01  lsDfltCommOptn OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsDfltCommOptn.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-DFLT-COMM-OPTN TO lsDfltCommOptn.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setDfltCommOptn.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getAllocationOption.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAllocationOption            OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION RETURNING lsAllocationOption.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-ALLOCATION-OPTION
112910             RETURNING lsAllocationOption.
112910
112910     EXIT METHOD.
112910 END METHOD getAllocationOption.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setAllocationOption.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  lsAllocationOption            OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE lsAllocationOption.
112910
112910     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
112910     SET WNAIF-ALLOCATION-OPTION TO lsAllocationOption.
112910     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
112910     MOVE 'Y' TO WS-HIER-CHG.
112910
112910     EXIT METHOD.
112910 END METHOD setAllocationOption.
010913**************************************************************************
010913**************************************************************************
010913 METHOD-ID. getReserveFlag.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveFlag            OBJECT REFERENCE CLASS-STRING.
010913 PROCEDURE DIVISION RETURNING lsReserveFlag.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     INVOKE CLASS-STRING "NEW" USING
010913         BY VALUE WNAIF-RESERVE-FLAG
010913             RETURNING lsReserveFlag.
010913
010913     EXIT METHOD.
010913 END METHOD getReserveFlag.
010913*-------------------------------------------------------------------------
010913 METHOD-ID. setReserveFlag.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveFlag            OBJECT REFERENCE CLASS-STRING.
010913 PROCEDURE DIVISION USING BY VALUE lsReserveFlag.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     SET WNAIF-RESERVE-FLAG TO lsReserveFlag.
010913     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
010913     MOVE 'Y' TO WS-HIER-CHG.
010913
010913     EXIT METHOD.
010913 END METHOD setReserveFlag.
010913**************************************************************************
010913**************************************************************************
010913 METHOD-ID. getReserveRateID.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveRateID      OBJECT REFERENCE CLASS-STRING.
010913 PROCEDURE DIVISION RETURNING lsReserveRateID.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     INVOKE CLASS-STRING "NEW" USING
010913         BY VALUE WNAIF-RESERVE-RATE-ID
010913             RETURNING lsReserveRateID.
010913
010913     EXIT METHOD.
010913 END METHOD getReserveRateID.
010913*-------------------------------------------------------------------------
010913 METHOD-ID. setReserveRateID.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveRateID      OBJECT REFERENCE CLASS-STRING.
010913 PROCEDURE DIVISION USING BY VALUE lsReserveRateID.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     SET WNAIF-RESERVE-RATE-ID TO lsReserveRateID.
010913     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
010913     MOVE 'Y' TO WS-HIER-CHG.
010913
010913     EXIT METHOD.
010913 END METHOD setReserveRateID.
010913**************************************************************************
010913**************************************************************************
010913 METHOD-ID. getReserveFlatAmount.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveFlatAmount                USAGE IS COMP-2.
010913 PROCEDURE DIVISION RETURNING lsReserveFlatAmount.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE WNAIF-RESERVE-FLAT-AMT TO lsReserveFlatAmount.
010913
010913     EXIT METHOD.
010913 END METHOD getReserveFlatAmount.
010913*-------------------------------------------------------------------------
010913 METHOD-ID. setReserveFlatAmount.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveFlatAmount                USAGE IS COMP-2.
010913 PROCEDURE DIVISION USING BY VALUE lsReserveFlatAmount.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE lsReserveFlatAmount TO WNAIF-RESERVE-FLAT-AMT.
010913     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
010913     MOVE 'Y' TO WS-HIER-CHG.
010913
010913     EXIT METHOD.
010913 END METHOD setReserveFlatAmount.
010913**************************************************************************
010913**************************************************************************
010913 METHOD-ID. getReserveMaxBalance.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveMaxBalance                USAGE IS COMP-2.
010913 PROCEDURE DIVISION RETURNING lsReserveMaxBalance.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE WNAIF-RESERVE-MAX-BAL TO lsReserveMaxBalance.
010913
010913     EXIT METHOD.
010913 END METHOD getReserveMaxBalance.
010913*-------------------------------------------------------------------------
010913 METHOD-ID. setReserveMaxBalance.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveMaxBalance                USAGE IS COMP-2.
010913 PROCEDURE DIVISION USING BY VALUE lsReserveMaxBalance.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE lsReserveMaxBalance TO WNAIF-RESERVE-MAX-BAL.
010913     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
010913     MOVE 'Y' TO WS-HIER-CHG.
010913
010913     EXIT METHOD.
010913 END METHOD setReserveMaxBalance.
010913**************************************************************************
010913**************************************************************************
010913 METHOD-ID. getReserveMinBalance.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveMinBalance                USAGE IS COMP-2.
010913 PROCEDURE DIVISION RETURNING lsReserveMinBalance.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE WNAIF-RESERVE-MIN-BAL TO lsReserveMinBalance.
010913
010913     EXIT METHOD.
010913 END METHOD getReserveMinBalance.
010913*-------------------------------------------------------------------------
010913 METHOD-ID. setReserveMinBalance.
010913 DATA DIVISION.
010913 WORKING-STORAGE SECTION.
010913 LINKAGE SECTION.
010913 01  lsReserveMinBalance                USAGE IS COMP-2.
010913 PROCEDURE DIVISION USING BY VALUE lsReserveMinBalance.
010913
010913     MOVE WS-HIER-CARD TO WNAIF-CARD-DATA.
010913     MOVE lsReserveMinBalance TO WNAIF-RESERVE-MIN-BAL.
010913     MOVE WNAIF-CARD-DATA TO WS-HIER-CARD.
010913     MOVE 'Y' TO WS-HIER-CHG.
010913
010913     EXIT METHOD.
010913 END METHOD setReserveMinBalance.

      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMarketCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestMarketCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-MARKET-CODE
                   RETURNING lsVestMarketCode.

           EXIT METHOD.
       END METHOD getVestMarketCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMarketCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestMarketCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-MARKET-CODE TO lsVestMarketCode.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestMarketCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestAgentLevel             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestAgentLevel.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-AGENT-LEVEL
                   RETURNING lsVestAgentLevel.

           EXIT METHOD.
       END METHOD getVestAgentLevel.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestAgentLevel             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestAgentLevel.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-AGENT-LEVEL TO lsVestAgentLevel.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestAgentLevel.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getClassCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsClassCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CLASS-CODE
                   RETURNING lsClassCode.

           EXIT METHOD.
       END METHOD getClassCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setClassCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsClassCode                 OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsClassCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-CLASS-CODE TO lsClassCode.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setClassCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestStartDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestStartDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsVestStartDate.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-START-DATE TO lsVestStartDate.

           EXIT METHOD.
       END METHOD getVestStartDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestStartDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestStartDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsVestStartDate.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestStartDate TO WNAIF-VEST-START-DATE.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestStartDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestDealType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDealType               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestDealType.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-DEAL-TYPE
                   RETURNING lsVestDealType.

           EXIT METHOD.
       END METHOD getVestDealType.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestDealType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDealType               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestDealType.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-DEAL-TYPE TO lsVestDealType.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestDealType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestOrRevCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestOrRevCode              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestOrRevCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-OR-REV-CODE
                   RETURNING lsVestOrRevCode.

           EXIT METHOD.
       END METHOD getVestOrRevCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestOrRevCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestOrRevCode              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestOrRevCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-OR-REV-CODE TO lsVestOrRevCode.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestOrRevCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestDurationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDurationCode           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestDurationCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-DURATION-CODE
                   RETURNING lsVestDurationCode.

           EXIT METHOD.
       END METHOD getVestDurationCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestDurationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDurationCode           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestDurationCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-DURATION-CODE TO lsVestDurationCode.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestDurationCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestDuration.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDuration               PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsVestDuration.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-DURATION TO lsVestDuration.

           EXIT METHOD.
       END METHOD getVestDuration.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestDuration.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestDuration               PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsVestDuration.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestDuration TO WNAIF-VEST-DURATION.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestDuration.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestStopDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsVestStopDate.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-STOP-DATE TO lsVestStopDate.

           EXIT METHOD.
       END METHOD getVestStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestStopDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsVestStopDate.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestStopDate TO WNAIF-VEST-STOP-DATE.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestMaxAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMaxAmount              PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsVestMaxAmount.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-MAX-AMOUNT TO lsVestMaxAmount.

           EXIT METHOD.
       END METHOD getVestMaxAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestMaxAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMaxAmount              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsVestMaxAmount.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestMaxAmount TO WNAIF-VEST-MAX-AMOUNT.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestMaxAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestMaxBalance.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMaxBalance             USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsVestMaxBalance.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-MAX-BALANCE TO lsVestMaxBalance.

           EXIT METHOD.
       END METHOD getVestMaxBalance.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestMaxBalance.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestMaxBalance             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsVestMaxBalance.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestMaxBalance TO WNAIF-VEST-MAX-BALANCE.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestMaxBalance.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-CODE
                   RETURNING lsVestCode.

           EXIT METHOD.
       END METHOD getVestCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestCode                   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestCode.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-CODE TO lsVestCode.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestPercent                USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsVestPercent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-PERCENT TO lsVestPercent.

           EXIT METHOD.
       END METHOD getVestPercent.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestPercent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestPercent                USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsVestPercent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestPercent TO WNAIF-VEST-PERCENT.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestPercent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestRevToAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestRevToAgent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-REV-TO-AGENT
                   RETURNING lsVestRevToAgent.

           EXIT METHOD.
       END METHOD getVestRevToAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestRevToAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestRevToAgent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-REV-TO-AGENT TO lsVestRevToAgent.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestRevToAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestRevToMarket.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToMarket            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestRevToMarket.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-REV-TO-MARKET
                   RETURNING lsVestRevToMarket.

           EXIT METHOD.
       END METHOD getVestRevToMarket.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestRevToMarket.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToMarket            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestRevToMarket.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-REV-TO-MARKET TO lsVestRevToMarket.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestRevToMarket.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestRevToLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToLevel             PIC S9(04) COMP-5.
       PROCEDURE DIVISION RETURNING lsVestRevToLevel.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE WNAIF-VEST-REV-TO-LEVEL TO lsVestRevToLevel.

           EXIT METHOD.
       END METHOD getVestRevToLevel.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestRevToLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestRevToLevel             PIC S9(04) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsVestRevToLevel.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           MOVE lsVestRevToLevel TO WNAIF-VEST-REV-TO-LEVEL.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestRevToLevel.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getVestCheckRevToAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestCheckRevToAgent        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsVestCheckRevToAgent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-VEST-CHECK-REV-TO-AGENT
                   RETURNING lsVestCheckRevToAgent.

           EXIT METHOD.
       END METHOD getVestCheckRevToAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setVestCheckRevToAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsVestCheckRevToAgent        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsVestCheckRevToAgent.

           MOVE WS-VEST-CARD TO WNAIF-CARD-DATA.
           SET WNAIF-VEST-CHECK-REV-TO-AGENT TO lsVestCheckRevToAgent.
           MOVE WNAIF-CARD-DATA TO WS-VEST-CARD.
           MOVE 'Y' TO WS-VEST-CHG.

           EXIT METHOD.
       END METHOD setVestCheckRevToAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdReqState.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-STATE(WS-REM)
                   RETURNING lsContEdReqState.

           EXIT METHOD.
       END METHOD getContEdReqState.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdReqState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-STATE(WS-REM) TO lsContEdReqState.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdReqState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqFlag              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-FLAG(WS-REM)
                   RETURNING lsContEdReqFlag.

           EXIT METHOD.
       END METHOD getContEdReqFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqFlag              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF

           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-FLAG(WS-REM) TO lsContEdReqFlag.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdReqFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdReqStrtDate.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM)
                    TO lsContEdReqStrtDate.

           EXIT METHOD.
       END METHOD getContEdReqStrtDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdReqStrtDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsContEdReqStrtDate
                    TO WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdReqStrtDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM)
                        TO lsContEdReqStopDate.

           EXIT METHOD.
       END METHOD getContEdReqStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.

           MOVE lsContEdReqStopDate
                    TO WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdReqStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdQualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdQualified            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdQualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-QUALIFIED(WS-REM)
                   RETURNING lsContEdQualified.

           EXIT METHOD.
       END METHOD getContEdQualified.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdQualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdQualified            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdQualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-QUALIFIED(WS-REM) TO lsContEdQualified.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdQualified.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdNonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdNonQual              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdNonQual.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-NON-QUAL(WS-REM)
                   RETURNING lsContEdNonQual.

           EXIT METHOD.
       END METHOD getContEdNonQual.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdNonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdNonQual              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdNonQual.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-NON-QUAL(WS-REM) TO lsContEdNonQual.
           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdNonQual.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdPartnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdPartnership          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdPartnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-PARTNERSHIP(WS-REM)
                   RETURNING lsContEdPartnership.

           EXIT METHOD.
       END METHOD getContEdPartnership.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdPartnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdPartnership          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdPartnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-PARTNERSHIP(WS-REM) TO lsContEdPartnership.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdPartnership.
      **************************************************************************
       METHOD-ID. getContEdH1ReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqState           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1ReqState.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-STATE(WS-REM)
                   RETURNING lsContEdH1ReqState.

           EXIT METHOD.
       END METHOD getContEdH1ReqState.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1ReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqState           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1ReqState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-STATE(WS-REM) TO lsContEdH1ReqState.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1ReqState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1ReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqFlag            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1ReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-FLAG(WS-REM)
                   RETURNING lsContEdH1ReqFlag.

           EXIT METHOD.
       END METHOD getContEdH1ReqFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1ReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqFlag            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1ReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF

           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-FLAG(WS-REM) TO lsContEdH1ReqFlag.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1ReqFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1ReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1ReqStrtDate.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM)
                      TO lsContEdH1ReqStrtDate.

           EXIT METHOD.
       END METHOD getContEdH1ReqStrtDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1ReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1ReqStrtDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsContEdH1ReqStrtDate
                      TO WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1ReqStrtDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1ReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1ReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM)
                      TO lsContEdH1ReqStopDate.

           EXIT METHOD.
       END METHOD getContEdH1ReqStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1ReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1ReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1ReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.

           MOVE lsContEdH1ReqStopDate
                        TO WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1ReqStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1Qualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                  PIC S9(09) COMP-5.
       01  lsContEdH1Qualified  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1Qualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD)
                    TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-QUALIFIED(WS-REM)
                   RETURNING lsContEdH1Qualified.

           EXIT METHOD.
       END METHOD getContEdH1Qualified.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1Qualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1Qualified          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1Qualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD)
                              TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-QUALIFIED(WS-REM)
                              TO lsContEdH1Qualified.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1Qualified.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1NonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1NonQual            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1NonQual.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-NON-QUAL(WS-REM)
                   RETURNING lsContEdH1NonQual.

           EXIT METHOD.
       END METHOD getContEdH1NonQual.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1NonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1NonQual            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1NonQual.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-NON-QUAL(WS-REM) TO lsContEdH1NonQual.
           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1NonQual.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH1Partnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1Partnership        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH1Partnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-PARTNERSHIP(WS-REM)
                   RETURNING lsContEdH1Partnership.

           EXIT METHOD.
       END METHOD getContEdH1Partnership.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH1Partnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH1Partnership        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH1Partnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H1(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-PARTNERSHIP(WS-REM)
                              TO lsContEdH1Partnership.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H1 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H1-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH1Partnership.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2ReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqState           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2ReqState.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-STATE(WS-REM)
                   RETURNING lsContEdH2ReqState.

           EXIT METHOD.
       END METHOD getContEdH2ReqState.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2ReqState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqState           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2ReqState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-STATE(WS-REM) TO lsContEdH2ReqState.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2ReqState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2ReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqFlag            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2ReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-REQ-FLAG(WS-REM)
                   RETURNING lsContEdH2ReqFlag.

           EXIT METHOD.
       END METHOD getContEdH2ReqFlag.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2ReqFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqFlag            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2ReqFlag.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF

           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-REQ-FLAG(WS-REM) TO lsContEdH2ReqFlag.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2ReqFlag.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2ReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2ReqStrtDate.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM)
                            TO lsContEdH2ReqStrtDate.

           EXIT METHOD.
       END METHOD getContEdH2ReqStrtDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2ReqStrtDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqStrtDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2ReqStrtDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsContEdH2ReqStrtDate
                        TO WNAIF-CONT-ED-REQ-STRT-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2ReqStrtDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2ReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2ReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM)
                        TO lsContEdH2ReqStopDate.

           EXIT METHOD.
       END METHOD getContEdH2ReqStopDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2ReqStopDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2ReqStopDate          PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2ReqStopDate.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.

           MOVE lsContEdH2ReqStopDate
                        TO WNAIF-CONT-ED-REQ-STOP-DATE(WS-REM).

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2ReqStopDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2Qualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2Qualified          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2Qualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-QUALIFIED(WS-REM)
                   RETURNING lsContEdH2Qualified.

           EXIT METHOD.
       END METHOD getContEdH2Qualified.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2Qualified.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2Qualified          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2Qualified.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-QUALIFIED(WS-REM) TO lsContEdH2Qualified.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2Qualified.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2NonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2NonQual            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2NonQual.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD)
                              TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-NON-QUAL(WS-REM)
                   RETURNING lsContEdH2NonQual.

           EXIT METHOD.
       END METHOD getContEdH2NonQual.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2NonQual.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2NonQual            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2NonQual.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-NON-QUAL(WS-REM) TO lsContEdH2NonQual.
           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2NonQual.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getContEdH2Partnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2Partnership        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsContEdH2Partnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-CONT-ED-PARTNERSHIP(WS-REM)
                   RETURNING lsContEdH2Partnership.

           EXIT METHOD.
       END METHOD getContEdH2Partnership.
      *-------------------------------------------------------------------------
       METHOD-ID. setContEdH2Partnership.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsContEdH2Partnership        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsContEdH2Partnership.


           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-CONT-ED-CARD-H2(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-CONT-ED-PARTNERSHIP(WS-REM)
                          TO lsContEdH2Partnership.

           MOVE WNAIF-CARD-DATA TO WS-CONT-ED-CARD-H2 (WS-CARD)
           MOVE 'Y' TO WS-CONT-ED-H2-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setContEdH2Partnership.
      **************************************************************************
       METHOD-ID. getApptState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptState                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsApptState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPT-STATE(WS-REM)
                   RETURNING lsApptState.

           EXIT METHOD.
       END METHOD getApptState.
      *-------------------------------------------------------------------------
       METHOD-ID. setApptState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptState                  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsApptState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-APPT-STATE(WS-REM) TO lsApptState.
           MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(WS-CARD).
           MOVE 'Y' TO WS-APPOINTMENT-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setApptState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApptStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptStatusCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsApptStatusCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPT-STATUS-CODE(WS-REM)
                   RETURNING lsApptStatusCode.

           EXIT METHOD.
       END METHOD getApptStatusCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setApptStatusCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptStatusCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsApptStatusCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-APPT-STATUS-CODE(WS-REM) TO lsApptStatusCode.
           MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(WS-CARD).
           MOVE 'Y' TO WS-APPOINTMENT-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setApptStatusCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApptReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptReasonCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsApptReasonCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-APPT-REASON-CODE(WS-REM)
                   RETURNING lsApptReasonCode.

           EXIT METHOD.
       END METHOD getApptReasonCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setApptReasonCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptReasonCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsApptReasonCode.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-APPT-REASON-CODE(WS-REM) TO lsApptReasonCode.
           MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(WS-CARD).
           MOVE 'Y' TO WS-APPOINTMENT-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setApptReasonCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApptGranted.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptGranted                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsApptGranted.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-APPT-GRANTED(WS-REM) TO lsApptGranted.

           EXIT METHOD.
       END METHOD getApptGranted.
      *-------------------------------------------------------------------------
       METHOD-ID. setApptGranted.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptGranted                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsApptGranted.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsApptGranted TO WNAIF-APPT-GRANTED(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(WS-CARD).
           MOVE 'Y' TO WS-APPOINTMENT-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setApptGranted.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApptExpires.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptExpires                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsApptExpires.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-APPT-EXPIRES(WS-REM) TO lsApptExpires.

           EXIT METHOD.
       END METHOD getApptExpires.
      *-------------------------------------------------------------------------
       METHOD-ID. setApptExpires.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsApptExpires                PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsApptExpires.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-APPOINTMENT-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsApptExpires TO WNAIF-APPT-EXPIRES(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-APPOINTMENT-CARD(WS-CARD).
           MOVE 'Y' TO WS-APPOINTMENT-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setApptExpires.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNASDState.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDState                  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsNASDState.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-NASD-STATE(WS-REM)
112910             RETURNING lsNASDState.
112910
112910     EXIT METHOD.
112910 END METHOD getNASDState.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNASDState.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDState                  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsNASDState.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     SET WNAIF-NASD-STATE(WS-REM) TO lsNASDState.
112910     MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-NASD-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setNASDState.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNASDStatus.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDStatus                 OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsNASDStatus.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-NASD-STATUS(WS-REM)
112910             RETURNING lsNASDStatus.
112910
112910     EXIT METHOD.
112910 END METHOD getNASDStatus.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNASDStatus.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDStatus                 OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsNASDStatus.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     SET WNAIF-NASD-STATUS(WS-REM) TO lsNASDStatus.
112910     MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-NASD-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setNASDStatus.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNASDReason.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDReason                 OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsNASDReason.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-NASD-REASON(WS-REM)
112910             RETURNING lsNASDReason.
112910
112910     EXIT METHOD.
112910 END METHOD getNASDReason.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNASDReason.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDReason                 OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsNASDReason.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     SET WNAIF-NASD-REASON(WS-REM) TO lsNASDReason.
112910     MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-NASD-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setNASDReason.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNASDDateGranted.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDDateGranted            PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsNASDDateGranted.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-NASD-DATE-GRANTED(WS-REM) TO lsNASDDateGranted.
112910
112910     EXIT METHOD.
112910 END METHOD getNASDDateGranted.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNASDDateGranted.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDDateGranted            PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsNASDDateGranted.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     MOVE lsNASDDateGranted TO WNAIF-NASD-DATE-GRANTED(WS-REM).
112910     MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-NASD-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setNASDDateGranted.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getNASDDateExpired.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDDateExpired            PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsNASDDateExpired.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     MOVE WNAIF-NASD-DATE-EXPIRED(WS-REM) TO lsNASDDateExpired.
112910
112910     EXIT METHOD.
112910 END METHOD getNASDDateExpired.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setNASDDateExpired.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsNASDDateExpired            PIC S9(09) COMP-5.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsNASDDateExpired.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-NASD-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     MOVE lsNASDDateExpired TO WNAIF-NASD-DATE-EXPIRED(WS-REM).
112910     MOVE WNAIF-CARD-DATA TO WS-NASD-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-NASD-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setNASDDateExpired.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCourseActDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseActDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsCourseActDate.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-COURSE-ACT-DATE(WS-REM) TO lsCourseActDate.

           EXIT METHOD.
       END METHOD getCourseActDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setCourseActDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseActDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsCourseActDate.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsCourseActDate TO WNAIF-COURSE-ACT-DATE(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-COURSES-CARD(WS-CARD).
           MOVE 'Y' TO WS-COURSES-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setCourseActDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCourseCeuDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseCeuDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsCourseCeuDate.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE WNAIF-COURSE-CEU-DATE(WS-REM) TO lsCourseCeuDate.

           EXIT METHOD.
       END METHOD getCourseCeuDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setCourseCeuDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseCeuDate              PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsCourseCeuDate.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           MOVE lsCourseCeuDate TO WNAIF-COURSE-CEU-DATE(WS-REM).
           MOVE WNAIF-CARD-DATA TO WS-COURSES-CARD(WS-CARD).
           MOVE 'Y' TO WS-COURSES-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setCourseCeuDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCourseNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseNumber               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsCourseNumber.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-COURSE-NUMBER(WS-REM)
                   RETURNING lsCourseNumber.

           EXIT METHOD.
       END METHOD getCourseNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setCourseNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsCourseNumber               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsCourseNumber.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-COURSES-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-COURSE-NUMBER(WS-REM) TO lsCourseNumber.
           MOVE WNAIF-CARD-DATA TO WS-COURSES-CARD(WS-CARD).
           MOVE 'Y' TO WS-COURSES-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setCourseNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPrincipleState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsPrincipleState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsPrincipleState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-PRINCIPLE-REP-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PRINCIPLE-STATE(WS-REM)
                   RETURNING lsPrincipleState.

           EXIT METHOD.
       END METHOD getPrincipleState.
      *-------------------------------------------------------------------------
       METHOD-ID. setPrincipleState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsPrincipleState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsPrincipleState.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-PRINCIPLE-REP-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-PRINCIPLE-STATE(WS-REM) TO lsPrincipleState.
           MOVE WNAIF-CARD-DATA TO WS-PRINCIPLE-REP-CARD(WS-CARD).
           MOVE 'Y' TO WS-PRINCIPLE-REP-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setPrincipleState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPrincipleAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsPrincipleAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsPrincipleAgent.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-PRINCIPLE-REP-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PRINCIPLE-AGENT(WS-REM)
                   RETURNING lsPrincipleAgent.

           EXIT METHOD.
       END METHOD getPrincipleAgent.
      *-------------------------------------------------------------------------
       METHOD-ID. setPrincipleAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsPrincipleAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsPrincipleAgent.

           COMPUTE WS-CARD = ((idx - 1) / 5) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 5)
           IF WS-REM = ZERO
               MOVE 5 TO WS-REM
           END-IF
           MOVE WS-PRINCIPLE-REP-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-PRINCIPLE-AGENT(WS-REM) TO lsPrincipleAgent.
           MOVE WNAIF-CARD-DATA TO WS-PRINCIPLE-REP-CARD(WS-CARD).
           MOVE 'Y' TO WS-PRINCIPLE-REP-CHG(WS-CARD).

           EXIT METHOD.
       END METHOD setPrincipleAgent.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getParamResponse.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsParamResponse              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                          RETURNING lsParamResponse.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-PERSONAL-INFO-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WNAIF-PARAM-RESPONSE(WS-REM)
                   RETURNING lsParamResponse.

           EXIT METHOD.
       END METHOD getParamResponse.
      *-------------------------------------------------------------------------
       METHOD-ID. setParamResponse.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  idx                          PIC S9(09) COMP-5.
       01  lsParamResponse              OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE idx
                                BY VALUE lsParamResponse.

           COMPUTE WS-CARD = ((idx - 1) / 6) + 1
           COMPUTE WS-REM = FUNCTION MOD(idx 6)
           IF WS-REM = ZERO
               MOVE 6 TO WS-REM
           END-IF
           MOVE WS-PERSONAL-INFO-CARD(WS-CARD) TO WNAIF-CARD-DATA.
           SET WNAIF-PARAM-RESPONSE(WS-REM) TO lsParamResponse.
           MOVE WNAIF-CARD-DATA TO WS-PERSONAL-INFO-CARD(WS-CARD).
112910*     MOVE 'Y' TO WS-PERSONAL-INFO-CHG(WS-CARD).
112910     MOVE 'Y' TO WS-PERSONAL-INFO-CHG(1).
112910     MOVE 'Y' TO WS-PERSONAL-INFO-CHG(2).
112910     MOVE 'Y' TO WS-PERSONAL-INFO-CHG(3).

           EXIT METHOD.
       END METHOD setParamResponse.
112910**************************************************************************
112910**************************************************************************
112910 METHOD-ID. getAffiliate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsAffiliate                  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                    RETURNING lsAffiliate.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-AFFILIATE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     INVOKE CLASS-STRING "NEW" USING
112910         BY VALUE WNAIF-AFFILIATE-AGENT(WS-REM)
112910             RETURNING lsAffiliate.
112910
112910     EXIT METHOD.
112910 END METHOD getAffiliate.
112910*-------------------------------------------------------------------------
112910 METHOD-ID. setAffiliate.
112910 DATA DIVISION.
112910 WORKING-STORAGE SECTION.
112910 LINKAGE SECTION.
112910 01  idx                          PIC S9(09) COMP-5.
112910 01  lsAffiliate                  OBJECT REFERENCE CLASS-STRING.
112910 PROCEDURE DIVISION USING BY VALUE idx
112910                          BY VALUE lsAffiliate.
112910
112910     COMPUTE WS-CARD = ((idx - 1) / 5) + 1
112910     COMPUTE WS-REM = FUNCTION MOD(idx 5)
112910     IF WS-REM = ZERO
112910         MOVE 5 TO WS-REM
112910     END-IF
112910     MOVE WS-AFFILIATE-CARD(WS-CARD) TO WNAIF-CARD-DATA.
112910     SET WNAIF-AFFILIATE-AGENT(WS-REM) TO lsAffiliate.
112910     MOVE WNAIF-CARD-DATA TO WS-AFFILIATE-CARD(WS-CARD).
112910     MOVE 'Y' TO WS-AFFILIATE-CHG(WS-CARD).
112910
112910     EXIT METHOD.
112910 END METHOD setAffiliate.
      **************************************************************************
       END OBJECT.
       END CLASS OAIEFAPI.
