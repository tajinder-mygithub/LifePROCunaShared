       IDENTIFICATION DIVISION.
       CLASS-ID.   OAPPLICA AS "LPNETAPI.OAPPLICA".
022703*AUTHOR.         PDMA.
022703*DATE-WRITTEN.   March 2002.
022703*DATE-COMPILED.
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
      *D BAPI object that initializes and creates a LifePRO session.
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
040802*H 20020327-005-01 WDS New object program.
022703*H 20030213-002-01 DAR Various changes to support latest 1.11 code.
091003*H 50000000-137-01 DAR Rewrote to create .NET API Library.  All API 
091003*H                 objects now are built into one .NET Assembly, 
091003*H                 LPNETAPI.DLL.  Cleared date stamps in program. 
012204*H 20031013-011-01 DAR Fitted to 1.12 base.  
040704*H 20040413-006-01 DAR Additional .NET API Modifications.      
092704*H 20040727-002-01 DAR Fixes for handling encrypted passwords.       
102104*H 20041015-010-01 DAR Remove clear of password.  
063005*H 20050627-004-01 DAR Pull in fix from 20040413-006-01, return 
063005*H                     Return Code and Message properties.  
110606*H 20060922-002-01 JKG Data area expansion
032907*H 20070329-004-01 DAR Increase WGLOB length.
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added class to resolve assembly locations
021709*H                     and added error handling and log method
040609*H 20090406-003-01 JWS Comment out redundant try-catch wrapper.
120110*H 20101008-003-01 DAR Implement alternate security/login
110711*H 20100408-004-01 DAR Split of APIs, and related corrections
111512*H 20120403-002-01 DAR Implement recovery of lost connection 
011316*H 20160527-004-01 DAR Test Fix to CheckConnection
061516*H 20160208-006-01 SES LifePRO Active Directory Integration
      *H
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
021709 SPECIAL-NAMES.
021709     ENVIRONMENT-NAME  IS ENV-NAME
021709     ENVIRONMENT-VALUE IS ENV-VALUE.
       REPOSITORY.

           CLASS CLASS-STRING    AS "System.String"
021709     CLASS THREAD-MONITOR  AS "System.Threading.Monitor"
021709     CLASS Thread          AS "System.Threading.Thread"
021709     CLASS Resolver        AS "DynaCobol.Resolver"
021709     CLASS CLASS-APPDOMAIN AS "System.AppDomain"
021709     CLASS CLASS-EXCEPTION AS "System.Exception"
021709     CLASS CLASS-EVENTLOG    AS "System.Diagnostics.EventLog"
021709     ENUM EVENT-TYPE AS "System.Diagnostics.EventLogEntryType"
021709     PROPERTY EVENT-ERROR AS "Error"
021709     CLASS CLASS-TYPE        AS "System.Type"
021709     DELEGATE DELEGATE-RESOLVE-EVENT
021709                           AS "System.ResolveEventHandler"
021709     PROPERTY PROP-CURRENTDOMAIN
021709                           AS "CurrentDomain".

       OBJECT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY WWSCRCPY.
110606 COPY WGLB2CPY.

       COPY WGLOBCPY.
       COPY WDBLLCPY.
120110 COPY WSCTYCPY.
120110 COPY WBTRVCPY.
120110 COPY WAPPLCPY.
120110 COPY WNCTLCPY.


      *01 WGLOB-REDEF REDEFINES WGLOBAL PIC X(10000).
      *COPY WGLBPCPY.

092308 01  WS-PROGRAM-INFO.
      *    05  PFILEBTV                     PIC X(08) VALUE 'PFILEBTV'.
120110     05  PSCTYACC                     PIC X(08) VALUE 'PSCTYACC'.
092308     05  PAPIMGTO                     PIC X(08) VALUE 'PAPIMGTO'.
092308     05  PBTRVCLO                     PIC X(08) VALUE 'PBTRVCLO'.
092308     05  PMASTINI                     PIC X(08) VALUE 'PMASTINI'.
092308     05  PMASTLGN                     PIC X(08) VALUE 'PMASTLGN'.
092308     05  PMASTCLO                     PIC X(08) VALUE 'PMASTCLO'.
092308     05  PDISCNCT                     PIC X(08) VALUE 'PDISCNCT'.
111512     05  PCONNECT                     PIC X(08) VALUE 'PCONNECT'.
120110     05  PPNCTLID                     PIC X(08) VALUE 'PPNCTLID'.
      *    05  SCREENIO                     PIC X(08) VALUE 'SCRNIO'. 

061516 01  SAVE-APPLICATION-GLOBAL        PIC X(21000).
061516*01  SAVE-APPLICATION-GLOBAL        PIC X(20000).

           COPY WAPIMGTO.

       01  ProgramDrive                     PIC X(260).
       01  WorkareaDrive                    PIC X(260).
      *01  DataDrive                        PIC X(260).
       01  ImageDrive                       PIC X(260).

040704 01  LpReturnCode                     PIC S9(09) COMP-5.
040704 01  LpErrorMessage                   PIC X(200).

       01  WS-INDX                          PIC S9(4) COMP-5.
       01  WS-RETURN-CODE                   PIC S9(09) COMP-5.
       01  WS-CODER.
           05  WS-TYPE-INDICATOR            PIC X(01).
           05  FILLER                       PIC X(03) VALUE LOW-VALUES.

       01  WS-LAST-IDS.
           05  WS-LAST-ID-ARRAY OCCURS 20 TIMES.
               10  WS-ID-INDEX-1            PIC 99 VALUE 1.
               10  WS-ID-INDEX-2            PIC 99 VALUE 1.
               10  WS-ID-INDEX-3            PIC 99 VALUE 1.
       01  WS-CHAR-ARRAY                    PIC X(36)
                          VALUE '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
       01  WS-ARRAY-LIMIT                   PIC 99 VALUE 36.
021709 01  tmpDomain           OBJECT REFERENCE CLASS-APPDOMAIN.
021709 01  tmpEventHandler     OBJECT REFERENCE DELEGATE-RESOLVE-EVENT.
021709 01  WS-EXCEPTION        OBJECT REFERENCE CLASS-EXCEPTION.
021709 01  TMP-STR             OBJECT REFERENCE CLASS-STRING.

           EXEC SQL
               BEGIN DECLARE SECTION
           END-EXEC.

       COPY SQLCA.

           EXEC SQL
               END DECLARE SECTION
           END-EXEC.



       PROCEDURE DIVISION.
      *========================================================================
       METHOD-ID.  InitData.
       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  lsReturnCode     PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsReturnCode.

      *    Since the App object may be shared and used by multiple
      *    worker objects at once, using Thread Monitor will allow 
      *    us to restrict access to the code here to only one thread
      *    at a time.  Waits should be short, but we don't want 
      *    one person getting access to another person's WGLOBAL, 
      *    especially in Login/Logout.  

           INVOKE THREAD-MONITOR "Enter" USING BY VALUE SELF.

021709* the three statements below set up the resolver object
021709     SET tmpDomain TO PROP-CURRENTDOMAIN OF CLASS-APPDOMAIN.

021709     INVOKE DELEGATE-RESOLVE-EVENT "NEW"
021709         USING BY VALUE Resolver
021709               BY VALUE N"Resolve"
021709         RETURNING tmpEventHandler.
021709     INVOKE tmpDomain "add_AssemblyResolve"
021709         USING BY VALUE tmpEventHandler.

           MOVE ProgramDrive  to WGLOB-PROGRAM-UNC.
           MOVE WorkareaDrive to WGLOB-WORKAREA-UNC.
      *    MOVE DataDrive to WGLOB-DATA-UNC. 
           MOVE ImageDrive    to WGLOB-IMAGE-UNC.

           MOVE SPACES                         TO WGLOB-USE-UNC-FLAG.

           SET WGLOB-BYPASS-SCREENIO           TO TRUE.
           SET WGLOB-NEW-BAPI                  TO TRUE.
           SET WGLOB-DATA-SOURCE-SQL           TO TRUE.

      *    Force a disconnect before Connect, in case one was already 
      *    active. 
021709     TRY
092308         CALL PDISCNCT USING WGLOBAL
021709                             WDBLL-PARAMETERS
021709         MOVE SPACES TO WGLOB-RDBMS-CONNECTION
021709     CATCH WS-EXCEPTION
040609*         INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
040609*         MOVE 8008 TO lsReturnCode,
040609*                      LpReturnCode
040609*         MOVE 'Unexpected Abend in API - see Windows Event Log'
040609*             TO LpErrorMessage
040609*         INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF
040609*         EXIT METHOD
021709     END-TRY.

021709     TRY
092308         CALL PMASTINI USING WGLOBAL
      *    CALL PBTRVCLO USING SUPPRESS-WGLOBAL.
      *    MOVE SUPPRESS-WGLOBAL TO WGLOBAL. 
021709         SET WAPIMGTO-READ              TO TRUE
021709     CATCH WS-EXCEPTION
021709         INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709         EXIT METHOD
021709     END-TRY.

      *    These statements clear GLOB elements that PFILEBTV uses, which accomodate
      *    the fact that PFILEBTV is unloaded from memory after each native code call.  
      *    NO LONGER NEEDED IN SQL. 
      *    MOVE 'N' TO WGLOB-FILES-READ
      *    MOVE SPACES TO WFILE,
      *                   WGLOB-PFILEIOP-INIT-FLAG.
021709     TRY
092308         CALL PAPIMGTO USING WGLOBAL
021709                             WAPIMGTO-PARAMETERS
021709         MOVE WAPIMGTO-RETURN-CODE    TO lsReturnCode
021709                                         LpReturnCode
021709         MOVE WAPIMGTO-RETURN-MESSAGE TO LpErrorMessage
021709     CATCH WS-EXCEPTION
021709         INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF.

           EXIT METHOD.

       END METHOD InitData.
      *========================================================================
       METHOD-ID.  Dispose.
      * Provide a Dispose method on the OAPPLICA object to disconnect 
      * the database, and to free up any other common resources.
      * No return code, either the disconnect works, or there is nothing
      * to disconnect.  
       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       PROCEDURE DIVISION.

021709     TRY
092308         CALL PDISCNCT USING WGLOBAL
021709                             WDBLL-PARAMETERS
021709         MOVE SPACES TO WGLOB-RDBMS-CONNECTION
021709     CATCH WS-EXCEPTION
021709         INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

021709     EXIT METHOD.

       END METHOD Dispose.
      *========================================================================
       METHOD-ID.  Login.
       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01  wsSecurCoder            PIC X(04).
       01  wsCoder                 PIC X(04).
       01  wsPassword              PIC X(64).
       COPY WMASTLGN.

       LINKAGE SECTION.
       01  lsUserType              PIC X(10).
           COPY WGLBXCPY.
       01  lsErrorMessage          PIC X(200).
       01  lsReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING lsUserType
                                WGLOBX
                                lsErrorMessage
                      RETURNING lsReturnCode.

           INVOKE THREAD-MONITOR "Enter" USING BY VALUE SELF.
           MOVE WGLOBAL TO SAVE-APPLICATION-GLOBAL.

           IF lsUserType = SPACES
               MOVE 9902 TO lsReturnCode
               MOVE 'No LifePRO User Type given.' to lsErrorMessage
021709         INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF
               EXIT METHOD
           END-IF.

           INVOKE SELF "getSecurCoder" USING lsUserType
092704                                       wsSecurCoder
092704                                       wsPassword.

120110*    New security logic.  Retrieve settings for Secure Coder, and 
120110*    do not add Coder ID to Coder table at all.  

111512     IF wsSecurCoder NOT > SPACES
111512         MOVE 9903 TO lsReturnCode
111512         MOVE 'No Security ID available for login'
111512                    TO lsErrorMessage
111512         INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF
111512         EXIT METHOD
111512     END-IF

111512     INVOKE SELF "CheckConnection" USING lsErrorMessage
111512                                RETURNING lsReturnCode

111512     IF lsReturnCode NOT = ZERO
111512         INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF
111512         EXIT METHOD
111512     END-IF


120110     MOVE WBTRV-GET-EQUAL             TO WAPPL-FUNCTION.
120110     MOVE ZERO                        TO WAPPL-KEY-NUMBER.
120110     MOVE SPACES                      TO WSCTY-DATA-RECORD.
120110
120110     MOVE wsSecurCoder                TO WSCTY-CODER-ID
120110     MOVE ZERO                        TO WSCTY-SYSTEM-NUM.
120110
120110     TRY
120110         CALL PSCTYACC           USING WGLOBAL
120110                                       WSCTY-DATA-RECORD
120110                                       WAPPL-CALL-PARAMETERS
120110
120110         MOVE WAPPL-RETURN-CODE           TO WBTRV-RETURN-CODE
120110
120110         IF  WAPPL-RETURN-OK
120110             MOVE wsSecurCoder TO WCODER-ID
                   MOVE WSCTY-DEPT TO WCODER-DEPT
120110         ELSE
120110             MOVE ZEROES                  TO WSCTY-SYSTEM-DATA
                   MOVE WAPPL-RETURN-CODE TO lsReturnCode
                                             LpReturnCode
                   MOVE 'Failure to retrieve security credentials '
                       TO lsErrorMessage
120110         END-IF
120110
120110     CATCH WS-EXCEPTION
120110         INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
120110         MOVE 8008 TO lsReturnCode,
120110                      LpReturnCode
120110         MOVE 'Unexpected Abend in API - see Windows Event Log'
120110             TO lsErrorMessage
120110     END-TRY.


120110     MOVE ZERO TO WGLOB-API-UNIQUE-ID
120110                  WGLOB-LIFEPRO-ID
120110     IF lsReturnCode = ZERO
120110
120110         SET WNCTL-API-UNIQUE-ID  TO TRUE
120110         MOVE 01               TO WNCTL-REC-INCREMENT

111512*        Set this flag so that ADO.NET connection object is verified. 
111512*        If not valid, a new one will be created. 
111512         SET WCNTL-VERIFY-EXISTING TO TRUE

120110         CALL PPNCTLID USING WGLOBAL
120110                             WNCTL-PARMS
120110         IF WNCTL-RETURN-OK
120110             MOVE WNCTL-CONTROL-NUM TO WGLOB-API-UNIQUE-ID
120110         ELSE
120110             MOVE WNCTL-RETURN-CODE TO lsReturnCode
120110                                       lpReturnCode
120110             MOVE WNCTL-RETURN-MESSAGE TO
120110                                       lsErrorMessage
120110         END-IF
120110
120110         IF lsReturnCode = ZERO
120110             SET WNCTL-LIFEPRO-ID-NUMS TO TRUE
120110             MOVE 01               TO WNCTL-REC-INCREMENT
111512
111512*            Share last connection object from last PPNCTLID call.       
111512             MOVE SPACES TO WCNTL-CONNECTION-FLAG
111512
120110             CALL PPNCTLID USING WGLOBAL
120110                                 WNCTL-PARMS
120110             IF WNCTL-RETURN-OK
120110                 MOVE WNCTL-CONTROL-NUM TO WGLOB-LIFEPRO-ID
120110             ELSE
120110*                A failure here only requires us to use the 
120110*                API Unique ID.  No need to stop processing. 
120110                 MOVE WGLOB-API-UNIQUE-ID TO WGLOB-LIFEPRO-ID
120110             END-IF
120110         END-IF
120110     END-IF

           MOVE WGLOBAL                 TO WGLOBX.
           MOVE SAVE-APPLICATION-GLOBAL TO WGLOBAL.

           INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF.

           EXIT METHOD.

       END METHOD Login.

      *========================================================================

111512 METHOD-ID.  CheckConnection.
111512 DATA DIVISION.
111512
111512 WORKING-STORAGE SECTION.
111512
111512 01  WS-ERROR-MESSAGE
111512     05  FILLER                     PIC X(60) VALUE
111512 'Database connection has been lost and cannot be restored.  '.
111512     05  FILLER                     PIC X(37) VALUE
111512 'Restart API environment on server.  ' .
111512
111512
111512 LINKAGE SECTION.
111512 01  lsErrorMessage          PIC X(200).
111512 01  lsReturnCode            PIC S9(09) COMP-5.
111512
111512 PROCEDURE DIVISION USING lsErrorMessage
111512                RETURNING lsReturnCode.
111512
111512*    Thread monitor "Enter" is already called in caller currently. 
111512*    INVOKE THREAD-MONITOR "Enter" USING BY VALUE SELF.
111512
111512     TRY
111512
111512*        Try the main connection  .. the choice of query is arbitrary.    
111512         EXEC SQL
111512              SELECT TOP 1 * FROM FOPTN001 (1, '            ')
111512         END-EXEC
111512
111512*        This list of codes derive from experimentation and Microsoft doc.  They represent 
111512*        cases where a connection has been closed forcibly by outside intervention.              
111512*        In these cases, a re-connect may be successful.  
111512         IF SQLCODE = 233
111512         OR SQLCODE = 10053
111512         OR SQLCODE = 10054
011316         OR SQLCODE = 10060
011316         OR SQLCODE = 10061
011316         OR SQLCODE = 1060
111512         OR SQLSTATE = '08S01'
111512*            Attempt recovery from damaged connection       
111512             CALL PDISCNCT USING WGLOBAL
111512                                 WDBLL-PARAMETERS
111512             CALL PCONNECT USING WGLOBAL
111512                                 WDBLL-PARAMETERS
111512             IF NOT WDBLL-SQLSTATE-OK
111512                 MOVE 8009 TO lsReturnCode
111512                 MOVE WS-ERROR-MESSAGE
111512                        TO lsErrorMessage
111512
111512             END-IF
111512         ELSE
111512             IF NOT SQLSTATE-OK
111512*                In this case, the above query failed for unknown reasons. 
111512*                Report failure.  
111512                 MOVE 8009 TO lsReturnCode
111512                 MOVE WS-ERROR-MESSAGE
111512                        TO lsErrorMessage
111512             END-IF
111512         END-IF
111512
111512
111512     CATCH WS-EXCEPTION
111512
111512         MOVE WS-ERROR-MESSAGE TO lsErrorMessage
111512         move 8009 TO lsReturnCode
111512     END-TRY.
111512
111512*    INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF.
111512
111512     EXIT METHOD.
111512
111512 END METHOD CheckConnection.

      *========================================================================
       METHOD-ID.  Logout.
       DATA DIVISION.

       WORKING-STORAGE SECTION.

        01  WS-PMASTCLO-CALL-INFO.
            05  WS-PMASTCLO-CALL-ORIGIN  PIC X(01) VALUE SPACES.
            05  WS-PMASTCLO-CALL-RC      PIC 9(04).
            05  WS-PMASTCLO-CALL-MESSAGE PIC X(80).

       LINKAGE SECTION.
       COPY WGLBXCPY.
       01  lsErrorMessage       PIC X(200).
       01  lsReturnCode         PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING WGLOBX
                                lsErrorMessage
                      RETURNING lsReturnCode.


120110*    Since we do not login to Coder ID table, we do not need 
120110*    to call PMASTCLO anymore.  No action for now.  


120110*    INVOKE THREAD-MONITOR "Enter" USING BY VALUE SELF.
120110
120110*    MOVE WGLOBAL                     TO SAVE-APPLICATION-GLOBAL.
120110*    MOVE WGLOBX                      TO WGLOBAL.
120110
120110*        MOVE 'N' TO WGLOB-FILES-READ
120110*        MOVE SPACES TO WFILE,
120110*                       WGLOB-PFILEIOP-INIT-FLAG.
120110*    TRY
120110*        CALL PMASTCLO USING WGLOBAL,
120110*                            WS-PMASTCLO-CALL-INFO
120110*        MOVE WGLOBAL                 TO WGLOBX
120110*        MOVE SAVE-APPLICATION-GLOBAL TO WGLOBAL
120110*        MOVE WS-PMASTCLO-CALL-RC     TO lsReturnCode
120110*        MOVE WS-PMASTCLO-CALL-MESSAGE
120110*                                     TO lsErrorMessage
120110*    CATCH WS-EXCEPTION
120110*        INVOKE SELF "writeErrorLog" USING WS-EXCEPTION
120110*        MOVE 8008 TO lsReturnCode,
120110*                     LpReturnCode
120110*        MOVE 'Unexpected Abend in API - see Windows Event Log'
120110*            TO LpErrorMessage
120110*    END-TRY.

      *        Also disconnect, and set WGLOB flag to indicate 
      *        disconnect. -- Pend for now, because concurrent connection
      *        use might disconnect other active users.  Allow connection 
      *        to be "garbage collected" when completely unused.  
      *        CALL PDISCNCT USING SUPPRESS-WGLOBAL
      *                            SUPPRESS-WDBLL-PARAMETERS.
      *        MOVE SUPPRESS-WGLOBAL TO WGLOBAL. 
      *        MOVE SUPPRESS-WDBLL-PARAMETERS TO WDBLL-PARAMETERS.
      *        MOVE SPACES TO WGLOB-RDBMS-CONNECTION.          

110711*        INVOKE THREAD-MONITOR "Exit" USING BY VALUE SELF.

           EXIT METHOD.

       END METHOD Logout.
      *========================================================================            
120110*METHOD-ID.  NextId.
120110*DATA DIVISION.
120110*WORKING-STORAGE SECTION.
120110*
120110*01  WS-NEW-ID.
120110*    05  WS-TYPE-CHAR                 PIC X.
120110*    05  WS-CHAR-1                    PIC X.
120110*    05  WS-CHAR-2                    PIC X.
120110*    05  WS-CHAR-3                    PIC X.
120110*
120110*LINKAGE     SECTION.
120110*01 lsUserType        PIC X(10).
120110*01 lsCoderId         PIC X(04).
120110*
120110*PROCEDURE DIVISION USING lsUserType
120110*               RETURNING lsCoderId.
120110*
120110*    PERFORM VARYING WS-INDX FROM 1 BY 1
120110*         UNTIL WS-INDX > WAPIMGTO-OCCURRENCES-USED OR
120110*               WAPIMGTO-USER-TYPE(WS-INDX) = lsUserType
120110*    END-PERFORM.
120110*
120110*    IF WS-INDX > WAPIMGTO-OCCURRENCES-USED
120110*        MOVE LOW-VALUES TO lsCoderId
120110*        EXIT METHOD
120110*    END-IF.
120110*
120110*    ADD 1 TO WS-ID-INDEX-3(WS-INDX).
120110*
120110*    IF WS-ID-INDEX-3(WS-INDX) > WS-ARRAY-LIMIT
120110*        MOVE 1 TO WS-ID-INDEX-3(WS-INDX)
120110*        ADD 1 TO WS-ID-INDEX-2(WS-INDX)
120110*        IF WS-ID-INDEX-2(WS-INDX) > WS-ARRAY-LIMIT
120110*            MOVE 1 TO WS-ID-INDEX-2(WS-INDX)
120110*            ADD 1 TO WS-ID-INDEX-1(WS-INDX)
120110*            IF WS-ID-INDEX-1(WS-INDX) > WS-ARRAY-LIMIT
120110*                MOVE 1 TO WS-ID-INDEX-1(WS-INDX)
120110*                MOVE 2 TO WS-ID-INDEX-3(WS-INDX)
120110*            END-IF
120110*        END-IF
120110*    END-IF.
120110*
120110*    MOVE WAPIMGTO-TYPE-INDICATOR(WS-INDX)
120110*                                             TO WS-TYPE-CHAR.
120110*    MOVE WS-CHAR-ARRAY(WS-ID-INDEX-1(WS-INDX):1)
120110*                                             TO WS-CHAR-1.
120110*    MOVE WS-CHAR-ARRAY(WS-ID-INDEX-2(WS-INDX):1)
120110*                                             TO WS-CHAR-2.
120110*    MOVE WS-CHAR-ARRAY(WS-ID-INDEX-3(WS-INDX):1)
120110*                                             TO WS-CHAR-3.
120110*    MOVE WS-NEW-ID TO lsCoderId.
120110*
120110*    CONTINUE.
120110*
120110*END METHOD NextId.
      *========================================================================
       METHOD-ID.  getSecurCoder.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE     SECTION.
       01 lsUserType        PIC X(10).
       01 lsCoderId         PIC X(04).
092704 01 lsPassword        PIC X(64).

       PROCEDURE   DIVISION    USING lsUserType
092704                               lsCoderId
092704                               lsPassword .

           PERFORM VARYING WS-INDX FROM 1 BY 1
                UNTIL WS-INDX > WAPIMGTO-OCCURRENCES-USED OR
                      WAPIMGTO-USER-TYPE(WS-INDX) = lsUserType
           END-PERFORM.

           IF WS-INDX > WAPIMGTO-OCCURRENCES-USED
               MOVE SPACES TO lsCoderId
092704                        lsPassword
           ELSE
               MOVE WAPIMGTO-SECURITY-CODER-ID(WS-INDX) TO lsCoderId
092704         MOVE WAPIMGTO-SECURITY-PASSWORD (WS-INDX) TO lsPassword
           END-IF.

       END METHOD getSecurCoder.
      *========================================================================
120110*METHOD-ID.  getTypeSymbol.
120110*DATA DIVISION.
120110*WORKING-STORAGE SECTION.
120110
120110*LINKAGE     SECTION.
120110*01 lsUserType        PIC X(10).
120110*01 lsTypeSymbol      PIC X(01).
120110
120110*PROCEDURE   DIVISION    USING lsUserType
120110*                    RETURNING lsTypeSymbol.
120110
120110*    PERFORM VARYING WS-INDX FROM 1 BY 1
120110*         UNTIL WS-INDX > WAPIMGTO-OCCURRENCES-USED OR
120110*               WAPIMGTO-USER-TYPE(WS-INDX) = lsUserType
120110*    END-PERFORM.
120110
120110*    IF WS-INDX > WAPIMGTO-OCCURRENCES-USED
120110*        MOVE SPACES TO lsTypeSymbol
120110*    ELSE
120110*        MOVE WAPIMGTO-TYPE-INDICATOR(WS-INDX) TO lsTypeSymbol
120110*    END-IF.
120110
120110*END METHOD getTypeSymbol.
      *========================================================================
       METHOD-ID.  getUserType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE     SECTION.
       01 lsIndex           PIC 9(04).
       01 lsUserType        PIC X(10).

       PROCEDURE   DIVISION    USING lsIndex
                           RETURNING lsUserType.

           IF lsIndex < 1 OR lsIndex > WAPIMGTO-OCCURRENCES-USED
               MOVE SPACES TO lsUserType
           ELSE
               MOVE WAPIMGTO-USER-TYPE(lsIndex) TO lsUserType
           END-IF.

       END METHOD getUserType.
      *========================================================================
       METHOD-ID.  getTypeCount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE     SECTION.
       01 lsIndex           PIC 9(04).

       PROCEDURE   DIVISION
                           RETURNING lsIndex.

           MOVE WAPIMGTO-OCCURRENCES-USED to lsIndex.

       END METHOD getTypeCount.

      *========================================================================
      *   The "get*" methods retrieve property values as CLR compliant types.  
      *   In the case of the Drive values, as Strings.         
      *========================================================================
       METHOD-ID. getProgramDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsProgramDrive        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsProgramDrive.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE ProgramDrive
                            RETURNING lsProgramDrive.

           EXIT METHOD.

       END METHOD getProgramDrive.

      *========================================================================   
       METHOD-ID. getWorkareaDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsWorkareaDrive        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsWorkareaDrive.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE WorkareaDrive
                            RETURNING lsWorkareaDrive.

           EXIT METHOD.

       END METHOD getWorkareaDrive.
      *========================================================================   
       METHOD-ID. getImageDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsImageDrive        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsImageDrive.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE ImageDrive
                            RETURNING lsImageDrive.

           EXIT METHOD.

       END METHOD getImageDrive.
      *========================================================================   
      *METHOD-ID. getDataDrive.
      *DATA DIVISION.
      ******************************************************************
      *WORKING-STORAGE SECTION.
      ******************************************************************
      *LINKAGE SECTION. 
      *
      *01 lsDataDrive        OBJECT REFERENCE CLASS-STRING.
      *
      ******************************************************************
      *PROCEDURE DIVISION RETURNING lsDataDrive.
      ******************************************************************
      *    INVOKE CLASS-STRING "NEW" USING BY VALUE DataDrive 
      *                     RETURNING lsDataDrive.

      *    EXIT METHOD.

      *END METHOD getDataDrive.
040704 METHOD-ID. getReturnCode.
040704 DATA DIVISION.
040704******************************************************************
040704 WORKING-STORAGE SECTION.
040704******************************************************************
040704 LINKAGE SECTION.

040704 01 lsReturnCode                PIC S9(09) COMP-5.

040704******************************************************************
040704 PROCEDURE DIVISION RETURNING lsReturnCode.
040704******************************************************************

040704     MOVE LpReturnCode TO lsReturnCode.
040704     EXIT METHOD.

040704 END METHOD getReturnCode.
040704
040704******************************************************************
040704*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
040704******************************************************************      


040704 METHOD-ID. getErrorMessage.
040704 DATA DIVISION.
040704******************************************************************
040704 WORKING-STORAGE SECTION.
040704******************************************************************
040704 LINKAGE SECTION.

040704 01 lsErrorMessage        OBJECT REFERENCE CLASS-STRING.

040704******************************************************************
040704 PROCEDURE DIVISION RETURNING lsErrorMessage.
040704******************************************************************
040704     INVOKE CLASS-STRING "NEW" USING BY VALUE LpErrorMessage
040704                      RETURNING lsErrorMessage.

040704     EXIT METHOD.

040704 END METHOD getErrorMessage.
040704
      *========================================================================         

      *========================================================================   
      *  These set methods accept clr-compliant types and assign values to 
      *  local working storage values, in this case, drive paths.  
      *========================================================================   
       METHOD-ID. setProgramDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsProgramDrive            OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
      *  Note - Using "BY VALUE" still just receives a reference to 
      *  the object, passed in by value.  Without this, a reference to a 
      *  reference is received, and this is cumbersome in VB/C#.  
      *
       PROCEDURE DIVISION USING BY VALUE lsProgramDrive.
      ******************************************************************
           SET ProgramDrive TO lsProgramDrive.

           EXIT METHOD.

       END METHOD setProgramDrive.
      *========================================================================   

       METHOD-ID. setWorkareaDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsWorkareaDrive            OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsWorkareaDrive.
      ******************************************************************
           SET WorkareaDrive TO lsWorkareaDrive.

           EXIT METHOD.

       END METHOD setWorkareaDrive.
      *========================================================================   
       METHOD-ID. setImageDrive.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsImageDrive            OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE  lsImageDrive.
      ******************************************************************
           SET ImageDrive TO lsImageDrive.

           EXIT METHOD.

       END METHOD setImageDrive.
      *========================================================================   
      *METHOD-ID. setDataDrive. 
      *DATA DIVISION.
      ******************************************************************
      *WORKING-STORAGE SECTION.
      ******************************************************************
      *LINKAGE SECTION.
      *
      *01 lsDataDrive            OBJECT REFERENCE CLASS-STRING. 
      *
      ******************************************************************
      *PROCEDURE DIVISION USING BY VALUE lsDataDrive. 
      ******************************************************************
      *    SET DataDrive TO lsDataDrive.                           
      *
      *    EXIT METHOD.
      *
      *END METHOD setDataDrive.
      *========================================================================   
021709 METHOD-ID. writeErrorLog.
021709******************************************************************
021709 ENVIRONMENT DIVISION.
021709 INPUT-OUTPUT SECTION.
021709 FILE-CONTROL.
021709************************************************************
021709*         FILE DEFINITIONS
021709************************************************************
021709
021709     SELECT ERROR-LOG
021709 COPY WVARYCPY.
021709                                 WS-ERROR-LOG-NAME
021709 COPY WLORGCPY.
021709                         STATUS IS WS-ERROR-LOG-FS.
021709
021709 DATA DIVISION.
021709******************************************************************
021709 FILE SECTION.
021709
021709 FD  ERROR-LOG
021709     RECORD CONTAINS 8000 CHARACTERS.
021709 01  ERROR-LOG-LINE         PIC X(8000).
021709
021709******************************************************************
021709 WORKING-STORAGE SECTION.
021709
021709 01  WS-ERROR-LOG-NAME       PIC X(255).
021709 01  WS-ERROR-LOG-FS         PIC X(02).
021709
021709 01  WS-CURRENT-DATE         PIC X(08).
021709 01  WS-CURRENT-TIME         PIC X(08).
021709
021709 01  WS-LOG-OPTION          PIC X(01)  VALUE  SPACES.
021709     88  WS-LOG-WINDOWS                VALUES 'W', 'B', ' '.
021709     88  WS-LOG-FILE                   VALUES 'F', 'B'.
021709     88  WS-LOG-NONE                   VALUE  'N'.
021709
021709 01  WS-EVENTLOG         OBJECT REFERENCE CLASS-EVENTLOG.
021709 01  TMP-EXCEPTION       OBJECT REFERENCE CLASS-EXCEPTION.
021709 01  TMP-STR             OBJECT REFERENCE CLASS-STRING.
021709 01  EVT-TYPE            OBJECT REFERENCE EVENT-TYPE.
021709
021709******************************************************************
021709 LINKAGE SECTION.
021709
021709 01  LS-EXCEPTION        OBJECT REFERENCE CLASS-EXCEPTION.
021709
021709*****************************************************************
021709 PROCEDURE DIVISION USING LS-EXCEPTION.
021709*****************************************************************
021709
021709     MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE.
021709     ACCEPT WS-CURRENT-TIME     FROM TIME.
021709     DISPLAY "LP_LOG_OPTION"    UPON ENV-NAME.
021709     ACCEPT WS-LOG-OPTION       FROM ENV-VALUE.
021709     INVOKE LS-EXCEPTION "GetBaseException"
021709         RETURNING TMP-EXCEPTION.
021709     INVOKE TMP-EXCEPTION "ToString" RETURNING TMP-STR.
021709
021709     IF WS-LOG-WINDOWS
021709         INVOKE CLASS-EVENTLOG "New"
021709             USING "Application", ".", "LifePRO API"
021709             RETURNING WS-EVENTLOG
021709         SET EVT-TYPE TO EVENT-ERROR OF EVENT-TYPE
021709         INVOKE WS-EVENTLOG "WriteEntry"
021709             USING BY VALUE TMP-STR, EVT-TYPE, 9999
021709     END-IF
021709
021709     IF WS-LOG-FILE
021709*    Write out an error log to the default run directory ... 
021709*    which is likely where LPNETAPI.DLL executed.  
021709         INVOKE LS-EXCEPTION "ToString" RETURNING TMP-STR
021709         MOVE SPACES TO WS-ERROR-LOG-NAME
021709         STRING 'LPAPI-'
021709                WS-CURRENT-DATE '-'
021709                WS-CURRENT-TIME
021709                '.LOG' DELIMITED BY SIZE
021709             INTO WS-ERROR-LOG-NAME
021709         OPEN OUTPUT ERROR-LOG
021709         IF WS-ERROR-LOG-FS = '00'
021709             SET ERROR-LOG-LINE TO TMP-STR
021709             WRITE ERROR-LOG-LINE
021709             IF WS-ERROR-LOG-FS = '00'
021709                 CLOSE ERROR-LOG
021709             END-IF
021709         END-IF
021709     END-IF.
021709
021709     EXIT METHOD.
021709
021709 END METHOD writeErrorLog.
021709*========================================================================   

       END OBJECT.
       END CLASS OAPPLICA.
021709
021709*=================================================================
021709 IDENTIFICATION DIVISION.
021709 CLASS-ID. Resolver AS "DynaCobol.Resolver".
021709*=================================================================
021709 ENVIRONMENT DIVISION.
021709 CONFIGURATION SECTION.
021709 SPECIAL-NAMES.
021709     ENVIRONMENT-NAME  IS ENV-NAME
021709     ENVIRONMENT-VALUE IS ENV-VALUE.
021709
021709 REPOSITORY.
021709     CLASS CLASS-RES-EVT-ARGS AS "System.ResolveEventArgs"
021709     CLASS CLASS-OBJECT       AS "System.Object"
021709     CLASS CLASS-STRING       AS "System.String"
021709     CLASS CLASS-ASSEMBLY     AS "System.Reflection.Assembly"
021709     CLASS CLASS-FILE         AS "System.IO.File"
021709     CLASS CLASS-BOOLEAN      AS "System.Boolean"
021709     CLASS CLASS-INT32        AS "System.Int32"
021709     PROPERTY PROP-NAME       AS "Name"
021709     PROPERTY PROP-LENGTH     AS "Length".
021709
021709 STATIC.
021709*=================================================================
021709 PROCEDURE DIVISION.
021709*=================================================================
021709
021709 METHOD-ID. Resolve AS "Resolve".
021709
021709*=================================================================
021709 DATA DIVISION.
021709*=================================================================
021709
021709*=================================================================
021709 WORKING-STORAGE SECTION.
021709
021709 01  WS-FILENAME       OBJECT REFERENCE CLASS-STRING.
021709 01  WS-FILEPATH       OBJECT REFERENCE CLASS-STRING.
021709 01  WS-TMPSTRING      OBJECT REFERENCE CLASS-STRING.
021709 01  WS-FILE-FLAG-BOOL OBJECT REFERENCE CLASS-BOOLEAN.
021709 01  WS-LENGTH         OBJECT REFERENCE CLASS-INT32.
021709
021709 01  WS-WORK-FIELDS.
021709     05  WS-IDX              PIC S9(9) COMP-5.
021709     05  WS-PATHLEN          PIC S9(9) COMP-5.
021709     05  WS-PATHALL          PIC X(50000).
021709     05  WS-PATHSTR          PIC X(255).
021709     05  WS-FILE-FOUND-FLAG  PIC X(06) VALUE 'False'.
021709         88  FILE-FOUND                VALUE 'True '.
021709         88  FILE-NOT-FOUND            VALUE 'False'.
021709
021709*=================================================================
021709 LINKAGE SECTION.
021709 01  o           OBJECT REFERENCE CLASS-OBJECT.
021709 01  rea         OBJECT REFERENCE CLASS-RES-EVT-ARGS.
021709 01  retAssembly OBJECT REFERENCE CLASS-ASSEMBLY.
021709
021709*=================================================================
021709 PROCEDURE DIVISION USING BY VALUE o
021709                          BY VALUE rea
021709                    RETURNING retAssembly.
021709*=================================================================
021709
021709     SET WS-TMPSTRING TO PROP-NAME OF rea.
021709
021709     MOVE SPACES   TO WS-PATHALL.
021709
021709     DISPLAY "PATH" UPON ENV-NAME.
021709
021709     ACCEPT WS-PATHALL FROM ENV-VALUE.
021709
021709     INVOKE CLASS-STRING "Concat"
021709         USING BY VALUE WS-TMPSTRING BY VALUE N".dll"
021709         RETURNING WS-FILENAME.
021709
021709     MOVE SPACES TO WS-PATHSTR.
021709
021709     PERFORM UNTIL WS-PATHALL = SPACES
021709         SET WS-TMPSTRING TO WS-PATHALL
021709         INVOKE WS-TMPSTRING "IndexOf"
021709             USING BY VALUE ";" RETURNING WS-IDX
021709         IF WS-IDX > 0
021709             INVOKE WS-TMPSTRING "SubString"
021709                 USING BY VALUE 0 BY VALUE WS-IDX
021709                 RETURNING WS-TMPSTRING
021709             INVOKE WS-TMPSTRING "ToString" RETURNING WS-PATHSTR
021709             SET WS-TMPSTRING to WS-PATHALL
021709             SET WS-LENGTH TO PROP-LENGTH OF WS-TMPSTRING
021709             SET WS-PATHLEN TO WS-LENGTH
021709             ADD 1 TO WS-IDX
021709             COMPUTE WS-PATHLEN = WS-PATHLEN - WS-IDX
021709             INVOKE WS-TMPSTRING "SubString"
021709                 USING BY VALUE WS-IDX
021709                       BY VALUE WS-PATHLEN
021709                 RETURNING WS-TMPSTRING
021709             INVOKE WS-TMPSTRING "ToString" RETURNING WS-PATHALL
021709         ELSE
021709             MOVE WS-PATHALL TO WS-PATHSTR
021709             MOVE SPACES TO WS-PATHALL
021709         END-IF
021709         INSPECT WS-PATHSTR REPLACING ALL
021709             LOW-VALUE BY SPACES
021709         INVOKE CLASS-STRING "Concat"
021709             USING BY VALUE WS-PATHSTR BY VALUE N"\"
021709             RETURNING WS-FILEPATH
021709         INVOKE CLASS-STRING "Concat"
021709             USING BY VALUE WS-FILEPATH BY VALUE WS-FILENAME
021709             RETURNING WS-TMPSTRING
021709         INVOKE CLASS-FILE "Exists"
021709             USING BY VALUE WS-TMPSTRING
021709             RETURNING WS-FILE-FLAG-BOOL
021709         INVOKE WS-FILE-FLAG-BOOL "ToString"
021709             RETURNING WS-FILE-FOUND-FLAG
021709         IF FILE-FOUND
021709             MOVE SPACES TO WS-PATHALL
021709         ELSE
021709             MOVE SPACES TO WS-PATHSTR
021709         END-IF
021709     END-PERFORM.
021709
021709     IF WS-PATHSTR > SPACES
021709         INVOKE CLASS-ASSEMBLY "LoadFile"
021709             USING BY VALUE WS-TMPSTRING RETURNING retAssembly
021709     END-IF.
021709
021709 END METHOD Resolve.
021709
021709 END STATIC.
021709
021709 END CLASS Resolver.
      *=================================================================
      *                    E N D   O F   S O U R C E
      *=================================================================
