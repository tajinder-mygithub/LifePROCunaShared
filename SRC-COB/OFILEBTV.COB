       IDENTIFICATION DIVISION.
       CLASS-ID. OFILEBTV AS "LPNETAPI.OFILEBTV".
022703*AUTHOR.         David Ross. 
022703*DATE-WRITTEN.   July, 2005.
022703*DATE-COMPILED.
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
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D API object that provides PFILEBTV functionality.  
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
070505*H 20050324-004-01 DAR New object program.  
032907*H 20070329-004-01 DAR Increase WGLOB length.
080108*H 20080728-003-01 DAR Fix OFILEBTV Updates to keep both pre-read
080108*H                     and update in unmanaged code.  
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
102813*H 20131015-001-01 DAR Support for WCF and Web Services
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.

       REPOSITORY.

           CLASS OAPPLICA AS "LPNETAPI.OAPPLICA"
021709     CLASS CLASS-EXCEPTION AS "System.Exception"
           CLASS CLASS-STRING AS "System.String"
           CLASS CLASS-BYTE-ARRAY AS "System.Byte[]"
           CLASS CLASS-BYTE AS "System.Byte".


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

       COPY WWSCRCPY.

092308 01  WS-PROGRAM-INFO.
092308     05  PFILEBTV               PIC X(08) VALUE 'PFILEBTV'.
092308     05  PGETASCI               PIC X(08) VALUE 'PGETASCI'.
092308     05  PGETMESG               PIC X(08) VALUE 'PGETMESG'.
092308     05  PUPDTDVR               PIC X(08) VALUE 'PUPDTDVR'.

       COPY WGLOBCPY.
       COPY WGLBXCPY.
       COPY WAPPLCPY.
       COPY WBTRVCPY.
       COPY WGETMCPY.
       COPY WASCICPY.
080108 COPY WGLB2CPY.
080108 COPY WSIZECPY.
080108 COPY WUPDTCPY.

080108*If the following changes, change PSETCNCT also.
080108 01  WS-PRIOR-RECORD-INFO.
080108     05  WS-PRIOR-RECORD         PIC X(WGLB2-DA-TOT-LEN)
080108                                             VALUE SPACES.
080108
080108*The following table stores the offset pointers for the last
080108*record table.
080108
080108 01  WS-OFFSET-INFO.
080108*    05  WS-OFFSET-DATA          PIC X(1200) VALUE LOW-VALUES.
080108*    05  WS-OFFSET-DATA          PIC X(WS-MAX-DATA-AREA)
080108     05  WS-OFFSET-DATA          PIC X(WGLB2-LP-TBL4)
080108                                             VALUE LOW-VALUES.
080108     05  WS-OFFSET-TABLE REDEFINES
080108*        WS-OFFSET-DATA OCCURS 300.
080108*        WS-OFFSET-DATA OCCURS WS-MAX-FILES.
080108         WS-OFFSET-DATA OCCURS WGLB2-LP-TBL.
080108         10  WS-OFFSET-NUM       PIC S9(09) COMP-5.

080108 01  SAVE-DATA-AREA              PIC X(WGLB2-DA-LEN)
080108                                        VALUE LOW-VALUES.
080108 01  WS-OFFSET                   PIC S9(09) COMP-5 VALUE 1.

080108 01  WS-INDX                     PIC S9(04) COMP-5.

       01  WS-NAME-NUMBER.
           10  WS-NAME         PIC X(08).
           10  WS-NUMBER       PIC 9(04).
           10  WS-LENGTH       PIC 9(04).

       01  SAVE-FUNCTION       PIC 9(04).

      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpReturnCode                PIC S9(09) COMP-5.
       01  LpErrorMessage              PIC X(200).

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
      *    Start a NetCOBOL run unit here, so that resources are 
      *    preserved until JMPCINT3 is called in Dispose.  
092308*     CALL JMPCINT2

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

080108*Build record offset table from record size info.
080108     PERFORM VARYING WS-INDX FROM 1 BY 1
080108         UNTIL WS-INDX GREATER THAN WGLB2-LP-TBL
080108         MOVE WS-OFFSET          TO WS-OFFSET-NUM (WS-INDX)
080108         ADD FILE-LENGTH (WS-INDX)
080108                                 TO WS-OFFSET
080108     END-PERFORM.

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

092308*     CALL JMPCINT3.

       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. ExecFunction.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************
           IF DATA-FILE-NUMBER > ZERO AND
              ( DATA-FILE-NUMBER NOT = WS-NUMBER OR
                WS-LENGTH = ZERO  )
      *        If we don't have length yet, fill it in first.  we don't need 
      *        it yet, but we will when user requests data area.               
               MOVE WAPPL-FUNCTION TO SAVE-FUNCTION
               SET WAPPL-GET-FILE-LENGTH TO TRUE
               INVOKE Self "FindFileLength"
               MOVE SAVE-FUNCTION TO WAPPL-FUNCTION

               IF WBTRV-RETURN-CODE NOT = ZERO
                   MOVE WBTRV-RETURN-CODE TO lsReturnCode,
                                             LpReturnCode
                   EXIT METHOD
               END-IF
           END-IF.

           IF  WAPPL-FUNCTION = WBTRV-GET-LOWEST
           AND WGLOB-PASS-KEY-VALUE
               MOVE LOW-VALUES
                       TO WFUNC-PASSED-KEY (WAPPL-KEY-NUMBER + 1)
           ELSE
           IF  WAPPL-FUNCTION = WBTRV-GET-HIGHEST
           AND WGLOB-PASS-KEY-VALUE
               MOVE HIGH-VALUES
                       TO WFUNC-PASSED-KEY (WAPPL-KEY-NUMBER + 1).

021709     TRY
080108         IF WAPPL-FUNCTION = WBTRV-UPDATE
080108*        For updates, we need to re-read the record, and perform
080108*        the update in one step in native Windows code, or 
080108*        infrequently, because of threading issues, working storage 
080108*        values are lost between calls that are critical.      
080108*        Note that this technique, with all the supporting W-S items, 
080108*        may be eliminated after the entire system is converted to .NET. 
080108             MOVE DATA-AREA TO SAVE-DATA-AREA
080108             MOVE FILE-LENGTH (DATA-FILE-NUMBER)
080108                                     TO WS-INDX
080108             MOVE WS-OFFSET-NUM (DATA-FILE-NUMBER)
080108                                     TO WS-OFFSET
080108             MOVE WS-PRIOR-RECORD (WS-OFFSET:WS-INDX)
080108                               TO WUPDT-PRIOR-RECORD
080108             MOVE ZERO TO WBTRV-RETURN-CODE,
080108                          WAPPL-RETURN-CODE
092308             CALL PUPDTDVR USING WGLOBAL
092308                             WAPPL-CALL-PARAMETERS
092308                             WBTRIEVE
092308                             WUPDT-PARAMETERS
080108             IF WBTRV-RETURN-CODE NOT = ZERO
080108                 INITIALIZE WGETM-PARAMETERS
080108                 MOVE WBTRV-RETURN-CODE
080108                           TO WGETM-MESSAGE-NUMBER
092308                 CALL PGETMESG USING WGLOBAL
092308                                     WGETM-PARAMETERS
080108                 MOVE WGETM-MESSAGE TO LpErrorMessage
080108             END-IF
080108         ELSE
080108             INVOKE Self "CallPFILE"
080108         END-IF
               MOVE WBTRV-RETURN-CODE TO lsReturnCode,
021709                                    LpReturnCode
080108*        Save off last record used in prior data.  
080108         MOVE FILE-LENGTH (DATA-FILE-NUMBER)
080108                                 TO WS-INDX
080108         MOVE WS-OFFSET-NUM (DATA-FILE-NUMBER)
080108                                 TO WS-OFFSET
080108         MOVE DATA-AREA
080108            TO WS-PRIOR-RECORD (WS-OFFSET:WS-INDX)
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           EXIT METHOD.

       END METHOD ExecFunction.


       METHOD-ID. FindFileNumber.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WAPPL-GET-FILE-NUMBER TO TRUE.
           MOVE WS-NAME-NUMBER TO DATA-AREA.
           INVOKE Self "CallPFILE".
           MOVE DATA-AREA TO WS-NAME-NUMBER.
           MOVE WS-NUMBER TO DATA-FILE-NUMBER.
           MOVE WAPPL-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.

       END METHOD FindFileNumber.


       METHOD-ID. FindFileLength.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WAPPL-GET-FILE-LENGTH TO TRUE.
           MOVE WS-NAME-NUMBER TO DATA-AREA.
           INVOKE Self "CallPFILE".
           MOVE DATA-AREA TO WS-NAME-NUMBER.
           MOVE WAPPL-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.

       END METHOD FindFileLength.

       METHOD-ID. CallPFILE IS PRIVATE.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************
           MOVE ZERO TO WBTRV-RETURN-CODE,
                        WAPPL-RETURN-CODE.

021709     TRY
092308         CALL PFILEBTV USING WGLOBAL
092308                             WAPPL-CALL-PARAMETERS
092308                             WBTRIEVE
               MOVE WBTRV-RETURN-CODE TO lsReturnCode,
021709                                   LpReturnCode
               IF WBTRV-RETURN-CODE NOT = ZERO
                   INITIALIZE WGETM-PARAMETERS
                   IF WBTRV-RETURN-CODE = 997
      *                Bad file name (on a get file number call)                
                       MOVE 000020200 TO WGETM-MESSAGE-NUMBER
                   ELSE
                       IF WBTRV-RETURN-CODE = 998
      *                    Bad file number
                           MOVE 000203868 TO WGETM-MESSAGE-NUMBER
                       ELSE
      *                    A database IO error 
                           MOVE WBTRV-RETURN-CODE
                                          TO WGETM-MESSAGE-NUMBER
                       END-IF
                   END-IF
092308             CALL PGETMESG USING WGLOBAL
092308                                 WGETM-PARAMETERS
                   MOVE WGETM-MESSAGE TO LpErrorMessage
               END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           EXIT METHOD.

       END METHOD CallPFILE.


      ******************************************************************
      * Get methods.
      * These get and set methods take as input, and provide as output, 
      * types that are part of the Common Language Runtime.  
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision floating point, 
      * and CLASS-STRING maps to String.  This allows these get/set methods
      * to be used in VB, C# and in COBOL.NET.    
      ******************************************************************
       METHOD-ID. getReturnCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           MOVE LpReturnCode TO lsReturnCode.
           EXIT METHOD.

       END METHOD getReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      

       METHOD-ID. getErrorMessage.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsErrorMessage        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsErrorMessage.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE LpErrorMessage
                            RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      
       METHOD-ID. getFileName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFileName        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFileName.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE WS-NAME
                            RETURNING lsFileName.
           EXIT METHOD.

       END METHOD getFileName.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      
       METHOD-ID. getFileLength.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFileLength                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFileLength.
      ******************************************************************

           MOVE WS-LENGTH TO lsFileLength.
           EXIT METHOD.

       END METHOD getFileLength.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      


       METHOD-ID. getFunction.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFunction                PIC S9(04) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFunction.
      ******************************************************************

           MOVE WAPPL-FUNCTION TO lsFunction.
           EXIT METHOD.

       END METHOD getFunction.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      
       METHOD-ID. getKeyNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsKeyNumber                PIC S9(04) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsKeyNumber.
      ******************************************************************

           MOVE WAPPL-KEY-NUMBER TO lsKeyNumber.
           EXIT METHOD.

       END METHOD getKeyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      
       METHOD-ID. getFileNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.
       01 lsFileNumber                PIC S9(04) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFileNumber.
      ******************************************************************
           MOVE DATA-FILE-NUMBER TO lsFileNumber.
           EXIT METHOD.

       END METHOD getFileNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************      

       METHOD-ID. getPassKeyValues.
      *  A value of 'p' passes key values from KeyBuffer(..) properties
      *  to PFILEBTV/PRDB, and uses these instead of data area.  
      *  A value of 'r' passes key values back in KeyBuffer(..) properties.
      *  If left blank, PFILEBTV operates as normal, and determines keys 
      *  from Data Area (this is the default, and how LifePRO normally
      *  runs).         

       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.
       01 lsPassKeyValues        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPassKeyValues.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE
                       WGLOB-PASS-KEY-VALUE-FLAG
                            RETURNING lsPassKeyValues.

           EXIT METHOD.

       END METHOD getPassKeyValues.

       METHOD-ID. getKeyBuffer.
      *  See note in getPassKeyBuffers.  The use of these 
      *  KeyBuffers is optional.  Each KeyBuffer (indexed) 
      *  corresponds to one composite key value (an index of 1 
      *  gives first key, or key #0).  The KeyBuffer contains only 
      *  characters ... compressed numerics have been uncompressed
      *  into characters.  For example, these key buffers support the 
      *  key lines in File Dump, and in the test utility. 
      *  Set PassKeyValues property to "r" to retrieve these.  
      *   
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex            PIC S9(09) COMP-5.
       01 lsKeyBuffer        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex RETURNING lsKeyBuffer.
      ******************************************************************
           IF lsIndex > 0 AND lsIndex < 8
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE WFUNC-PASSED-KEY (lsIndex)
                   RETURNING lsKeyBuffer
           ELSE
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                   RETURNING lsKeyBuffer.

           EXIT METHOD.

       END METHOD getKeyBuffer.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getDataBuffer.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       77 I         USAGE BINARY-LONG.
       77 I2        USAGE BINARY-LONG.
       77 Term      USAGE BINARY-CHAR UNSIGNED.
       77 ByteRef   OBJECT REFERENCE CLASS-BYTE.
       01 Digit-X   PIC X(01).
       01 Digits    PIC S9(04) COMP-5.

       LINKAGE SECTION.
       77 lsDataBuffer OBJECT REFERENCE CLASS-BYTE-ARRAY.
       PROCEDURE DIVISION RETURNING lsDataBuffer.

102813     IF WS-LENGTH = ZERO
102813*        Depending on usage of API, length may not have been 
102813*        set yet.  
102813         MOVE WAPPL-FUNCTION TO SAVE-FUNCTION
102813         IF DATA-FILE-NUMBER = ZERO
102813         AND WS-NAME > SPACES
102813             INVOKE Self "FindFileNumber"
102813         END-IF
102813
102813         MOVE DATA-FILE-NUMBER TO WS-NUMBER
102813         SET WAPPL-GET-FILE-LENGTH TO TRUE
102813         INVOKE Self "FindFileLength"
102813         MOVE SAVE-FUNCTION TO WAPPL-FUNCTION
102813     END-IF

           INVOKE CLASS-BYTE-ARRAY  "NEW"
                        USING WS-LENGTH RETURNING lsDataBuffer.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-LENGTH
               COMPUTE I2 = I - 1
               SET ASCII-CHAR-TO-CODE TO TRUE
               MOVE DATA-AREA(I:1) TO ASCII-CHAR
092308         CALL PGETASCI USING ASCII-PARAMS
               MOVE ASCII-CODE TO Term
               INVOKE lsDataBuffer "Set" USING BY VALUE I2 Term
           END-PERFORM.
       END METHOD getDataBuffer.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * Set methods    
      ******************************************************************

       METHOD-ID. setFunction.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFunction   PIC S9(04) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFunction.
      ******************************************************************

           MOVE lsFunction TO WAPPL-FUNCTION.
           EXIT METHOD.

       END METHOD setFunction.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setKeyNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsKeyNumber   PIC S9(04) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsKeyNumber.
      ******************************************************************

           MOVE lsKeyNumber TO WAPPL-KEY-NUMBER.
           EXIT METHOD.

       END METHOD setKeyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setFileNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFileNumber   PIC S9(04) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFileNumber.
      ******************************************************************

           MOVE lsFileNumber TO DATA-FILE-NUMBER
           EXIT METHOD.

       END METHOD setFileNumber.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setFileName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsFileName   OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFileName.
      ******************************************************************

           SET WS-NAME TO lsFileName
           EXIT METHOD.

       END METHOD setFileName.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setPassKeyValues.
      *  A value of 'p' passes key values from KeyBuffer(..) properties
      *  to PFILEBTV/PRDB, and uses these instead of data area.  
      *  A value of 'r' passes key values back in KeyBuffer(..) properties.
      *  If left blank, PFILEBTV operates as normal, and determines keys 
      *  from Data Area (this is the default, and how LifePRO normally
      *  runs).         

       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsPassKeyValues   OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsPassKeyValues.
      ******************************************************************
           SET WGLOB-PASS-KEY-VALUE-FLAG TO lsPassKeyValues
           EXIT METHOD.

       END METHOD setPassKeyValues.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setDataBuffer.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       77 I         USAGE BINARY-LONG.
       77 I2        USAGE BINARY-LONG.
       77 Term      USAGE BINARY-CHAR UNSIGNED.
       77 ByteRef   OBJECT REFERENCE CLASS-BYTE.
       77 Digit     PIC 9(01).

       LINKAGE SECTION.
       01 lsDataBuffer       OBJECT REFERENCE CLASS-BYTE-ARRAY.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsDataBuffer.
      ******************************************************************

102813     IF WS-LENGTH = ZERO
102813*        Depending on usage of API, length may not have been 
102813*        set yet.  
102813         MOVE WAPPL-FUNCTION TO SAVE-FUNCTION
102813         IF DATA-FILE-NUMBER = ZERO
102813         AND WS-NAME > SPACES
102813             INVOKE Self "FindFileNumber"
102813         END-IF
102813
102813         MOVE DATA-FILE-NUMBER TO WS-NUMBER
102813         SET WAPPL-GET-FILE-LENGTH TO TRUE
102813         INVOKE Self "FindFileLength"
102813         MOVE SAVE-FUNCTION TO WAPPL-FUNCTION
102813     END-IF

           PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-LENGTH
               COMPUTE I2 = I - 1
               INVOKE lsDataBuffer "Get"
                        USING BY VALUE I2 RETURNING ByteRef
               Set Term to ByteRef
               SET ASCII-CODE-TO-CHAR TO TRUE
               MOVE Term TO ASCII-CODE
092308         CALL PGETASCI USING ASCII-PARAMS
               MOVE ASCII-CHAR TO DATA-AREA (I:1)
           END-PERFORM.

           EXIT METHOD.

       END METHOD setDataBuffer.

       METHOD-ID. setKeyBuffer.
      *  See note in getPassKeyBuffers.  The use of these 
      *  KeyBuffers is optional.  Each KeyBuffer (indexed) 
      *  corresponds to one composite key value (an index of 1 
      *  gives first key, or key #0).  The KeyBuffer contains only 
      *  characters ... compressed numerics have been uncompressed
      *  into characters.  For example, these key buffers support the 
      *  key lines in File Dump, and in the test utility. 
      *  Set PassKeyValues property to "p" to pass these values in.
      *   
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex            PIC S9(09) COMP-5.
       01 lsKeyBuffer        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex lsKeyBuffer.
      ******************************************************************
           IF (lsIndex > 0 AND lsIndex < 8)
               SET WFUNC-PASSED-KEY (lsIndex)
                   TO lsKeyBuffer.

           EXIT METHOD.

       END METHOD setKeyBuffer.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       END OBJECT.
       END CLASS OFILEBTV.



