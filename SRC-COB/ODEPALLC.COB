       IDENTIFICATION DIVISION.
       CLASS-ID. ODEPALLC AS "LPNETAPI.ODEPALLC".
      *AUTHOR.         PDMA.
      *DATE-WRITTEN.   January 2005.
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
      *D API object that retrieves and updates deposit allocation
      *D information.  Provides API functionality similar to programs
      *D PDELAPPLC/PSRCALLC (in fact, ultimately calls these modules as
      *D black boxes to return values).
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
012805*H 20030410-006-01 DAR New program.
062705*H 20050128-004-01 DAR Retrofit 20030410-006-01.
032907*H 20070329-004-01 DAR Increase WGLOB length.
082007*H 20060720-003-01 KAM Expand Fund Package - WDEPA
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
110712*H 20121106-004-01 DAR Added Edit Only Flag, and revised Return Code
110712*H                     to be more detailed. 
062615*H 20121115-004-02 DAR Added Model Allocation information 
022516*H 20151130-001-01 GWT MH - Add Sub-Model/Profile Info
082916*H 20131010-019-01 DAR Allow funds only in model cases, and return 
082916*H                     additional status related items. 
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
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       COPY WWSCRCPY.

092308 01  WS-PROGRAM-INFO.
092308     05  PALLCDRV                 PIC X(08) VALUE 'PALLCDRV'.

082007 COPY WGLB2CPY.

       COPY WGLOBCPY.
       COPY WGLBXCPY.

      *   WDEPACPY provides the linkage to PALLCDRV, and from there to the programs
      *   that really fill in the linkage, either PDEPALLC or PSRCALLC.
       COPY WDEPACPY.

062615*  WMDLSCPY added to provide outputs from Model Allocation policies.   
062615 COPY WMDLSCPY.

       01  SAVE-EFFECTIVE-DATE            PIC 9(08) VALUE ZERO.
       01  SAVE-INQUIRY-PERFORMED         PIC X(01) VALUE 'N'.
           88 INQUIRY-PERFORMED           VALUE 'Y'.

      *    If the Company or Policy Number properties are changed,
      *    another retrieval must be done before continuing with update.
       01  SAVE-COMPANY-CODE              PIC X(02).
       01  SAVE-POLICY-NUMBER             PIC X(12).

       01  MUST-RETRIEVE-MSG              PIC X(80) VALUE
           'Must Retrieve Allocations First'.

       01  LAST-DATE-MSG.
           05  FILLER                     PIC X(37) VALUE
           'Effective Date Must Not Be Less Than '.
           05  LAST-DATE                  PIC X(10).

       01  WS-YMD-DATE                    PIC 9(08).
       01  WS-YMD-DATE-R REDEFINES WS-YMD-DATE.
           05  WS-YMD-YYYY                PIC 9(04).
           05  WS-YMD-MM                  PIC 9(02).
           05  WS-YMD-DD                  PIC 9(02).

       01  WS-FORMATTED-DATE.
           05  WS-FORMATTED-MM            PIC 9(02).
           05  FILLER                     PIC X(01) VALUE '/'.
           05  WS-FORMATTED-DD            PIC 9(02).
           05  FILLER                     PIC X(01) VALUE '/'.
           05  WS-FORMATTED-YYYY          PIC 9(04).

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
           MOVE wsReturnCode to WDEPA-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WDEPA-RETURN-MESSAGE
           ELSE
               MOVE SPACES TO WDEPA-RETURN-MESSAGE.

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

           MOVE wsReturnCode to WDEPA-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WDEPA-RETURN-MESSAGE
           ELSE
               MOVE SPACES TO WDEPA-RETURN-MESSAGE.

       END METHOD Dispose.

      ******************************************************************
       METHOD-ID. RetrieveAllocations.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

062705*    MOVE 'N' TO WGLOB-FILES-READ
062705*    MOVE SPACES TO WFILE,
062705*                   WGLOB-PFILEIOP-INIT-FLAG.

           MOVE ZERO TO WDEPA-RETURN-CODE,
110712                  WDEPA-MESSAGE-NUMBER
                        WDEPA-NBR-OF-ALLOCATIONS.
           MOVE SPACES TO WDEPA-RETURN-MESSAGE.

           SET WDEPA-GET-LATEST-FROM-GUI TO TRUE.
062615     IF WDEPA-PARENT-BEN-SEQ NOT > 00
062615         MOVE 01 TO WDEPA-PARENT-BEN-SEQ
062615     END-IF

021709     TRY
092308         CALL PALLCDRV  USING WGLOBAL
021709                              WDEPA-PARAMETERS
062615                              WMDLS-PARAMETERS
110712*        MOVE WDEPA-RETURN-CODE TO lsReturnCode
110712         INVOKE SELF "SelectReturnCode"
110712                   RETURNING lsReturnCode

               IF WDEPA-RETURN-CODE = ZERO
                   MOVE WDEPA-EFFECTIVE-DATE TO SAVE-EFFECTIVE-DATE
                   MOVE WDEPA-COMPANY-CODE TO SAVE-COMPANY-CODE
                   MOVE WDEPA-POLICY-NUMBER TO SAVE-POLICY-NUMBER
               ELSE
                   MOVE ZERO TO SAVE-EFFECTIVE-DATE
                   MOVE SPACES TO SAVE-COMPANY-CODE,
021709                            SAVE-POLICY-NUMBER
021709         END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                       WDEPA-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WDEPA-RETURN-MESSAGE
021709     END-TRY.


062705*    INVOKE LpApp "ReleaseClient".

           EXIT METHOD.

      ******************************************************************

       END METHOD RetrieveAllocations.


      ******************************************************************
       METHOD-ID. RefreshAvailability.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

062705*    MOVE 'N' TO WGLOB-FILES-READ
062705*    MOVE SPACES TO WFILE,
062705*                   WGLOB-PFILEIOP-INIT-FLAG.

110712     MOVE ZERO TO WDEPA-RETURN-CODE
110712                  WDEPA-MESSAGE-NUMBER
           MOVE SPACES TO WDEPA-RETURN-MESSAGE.

021709     TRY
             IF WDEPA-COMPANY-CODE NOT = SAVE-COMPANY-CODE
             OR WDEPA-POLICY-NUMBER NOT = SAVE-POLICY-NUMBER
      *        Note:  Message file is not used in .NET API code at this time, since
      *        PGETMESG may not use cache properly (W-S is cleared after each call),
      *        and other additional overhad exists that would reduce performance.
                   MOVE 901 TO lsReturnCode, WDEPA-RETURN-CODE
                   MOVE MUST-RETRIEVE-MSG
                                   TO WDEPA-RETURN-MESSAGE
               ELSE
               IF WDEPA-EFFECTIVE-DATE < SAVE-EFFECTIVE-DATE
                   MOVE 902 TO lsReturnCode, WDEPA-RETURN-CODE
                   MOVE SAVE-EFFECTIVE-DATE TO WS-YMD-DATE
                   MOVE WS-YMD-MM TO WS-FORMATTED-MM
                   MOVE WS-YMD-DD TO WS-FORMATTED-DD
                   MOVE WS-YMD-YYYY TO WS-FORMATTED-YYYY
                   MOVE WS-FORMATTED-DATE TO LAST-DATE
                   MOVE LAST-DATE-MSG TO WDEPA-RETURN-MESSAGE
               ELSE
                   SET WDEPA-REFRESH-AVAILABILITY TO TRUE
092308             CALL PALLCDRV  USING WGLOBAL
092308                                  WDEPA-PARAMETERS
062615                                  WMDLS-PARAMETERS
062615*            MOVE WDEPA-RETURN-CODE TO lsReturnCode
110712             INVOKE SELF "SelectReturnCode"
110712                    RETURNING lsReturnCode
021709         END-IF
021709       END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      WDEPA-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WDEPA-RETURN-MESSAGE
021709     END-TRY.

062705*        INVOKE LpApp "ReleaseClient".

           EXIT METHOD.

       END METHOD RefreshAvailability.

      ******************************************************************
       METHOD-ID. UpdateAllocations.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************
           MOVE ZERO TO WDEPA-RETURN-CODE
110712                  WDEPA-MESSAGE-NUMBER
           MOVE SPACES TO WDEPA-RETURN-MESSAGE.

           IF WDEPA-COMPANY-CODE NOT = SAVE-COMPANY-CODE
           OR WDEPA-POLICY-NUMBER NOT = SAVE-POLICY-NUMBER
      *        Note:  Message file is not used in .NET API code at this time, since
      *        PGETMESG may not use cache properly (W-S is cleared after each call),
      *        and other additional overhad exists that would reduce performance.
               MOVE 901 TO lsReturnCode, WDEPA-RETURN-CODE
               MOVE MUST-RETRIEVE-MSG
                               TO WDEPA-RETURN-MESSAGE
           ELSE
           IF WDEPA-EFFECTIVE-DATE < SAVE-EFFECTIVE-DATE
               MOVE 902 TO lsReturnCode, WDEPA-RETURN-CODE
               MOVE SAVE-EFFECTIVE-DATE TO WS-YMD-DATE
               MOVE WS-YMD-MM TO WS-FORMATTED-MM
               MOVE WS-YMD-DD TO WS-FORMATTED-DD
               MOVE WS-YMD-YYYY TO WS-FORMATTED-YYYY
               MOVE WS-FORMATTED-DATE TO LAST-DATE
               MOVE LAST-DATE-MSG TO WDEPA-RETURN-MESSAGE
           ELSE
062705*        MOVE 'N' TO WGLOB-FILES-READ
062705*        MOVE SPACES TO WFILE,
062705*                   WGLOB-PFILEIOP-INIT-FLAG
               IF WDEPA-EFFECTIVE-DATE = SAVE-EFFECTIVE-DATE
                   SET WDEPA-API-UPDATE-FROM-GUI TO TRUE
               ELSE
                   SET WDEPA-API-ADD-FROM-GUI TO TRUE
               END-IF

092308         CALL PALLCDRV  USING WGLOBAL
092308                              WDEPA-PARAMETERS
062615                              WMDLS-PARAMETERS
110712*        MOVE WDEPA-RETURN-CODE TO lsReturnCode
110712         INVOKE SELF "SelectReturnCode"
110712                     RETURNING lsReturnCode

               IF WDEPA-RETURN-CODE = ZERO
110712         AND NOT WDEPA-API-EDIT-ONLY
                   MOVE WDEPA-EFFECTIVE-DATE TO SAVE-EFFECTIVE-DATE.

062705*        INVOKE LpApp "ReleaseClient".

           EXIT METHOD.

      ******************************************************************

       END METHOD UpdateAllocations.


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

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
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

110712*    MOVE WDEPA-RETURN-CODE TO lsReturnCode.
110712     INVOKE SELF "SelectReturnCode"
110712                  RETURNING lsReturnCode.


       END METHOD getReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID.  SelectReturnCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

110712*    Use the message number as return code whenever possible, since
110712*    the original WDEPA-RETURN-CODE "buckets" many errors into a single 
110712*    code (generally 201).  Since message number will not always be 
110712*    available, use WDEPA-RETURN-CODE if message number is unavailable. 

110712     IF WDEPA-MESSAGE-NUMBER NOT = ZERO
110712         MOVE WDEPA-MESSAGE-NUMBER TO lsReturnCode
110712     ELSE
               MOVE WDEPA-RETURN-CODE TO lsReturnCode.
           EXIT METHOD.

       END METHOD SelectReturnCode.

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
           INVOKE CLASS-STRING "NEW" USING BY VALUE WDEPA-RETURN-MESSAGE
                            RETURNING lsErrorMessage.
           EXIT METHOD.

       END METHOD getErrorMessage.

      ******************************************************************
      *The following GET methods are for Input values, but the client
      *should be able to retrieve also so a Get is provided.
      ******************************************************************
       METHOD-ID. getCompanyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsCompanyCode        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCompanyCode.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE WDEPA-COMPANY-CODE
                            RETURNING lsCompanyCode.

           EXIT METHOD.

       END METHOD getCompanyCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getPolicyNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsPolicyNumber        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPolicyNumber.
      ******************************************************************
           INVOKE CLASS-STRING "NEW" USING BY VALUE WDEPA-POLICY-NUMBER
                            RETURNING lsPolicyNumber.

           EXIT METHOD.

       END METHOD getPolicyNumber.

      ******************************************************************
      * The following Get Methods are for returned output values.
      * getRowCount below allows the user to determine how many rows
      * have been returned.
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getEffectiveDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsEffectiveDate        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDate.
      ******************************************************************
           MOVE WDEPA-EFFECTIVE-DATE to lsEffectiveDate.

           EXIT METHOD.

       END METHOD getEffectiveDate.

062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getAssetAllocationModelFlag.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01 lsAssetAllocationModelFlag   OBJECT REFERENCE CLASS-STRING.
062615
062615******************************************************************
062615 PROCEDURE DIVISION RETURNING lsAssetAllocationModelFlag.
062615******************************************************************
062615
062615     SET lsAssetAllocationModelFlag TO WMDLS-AA-MODEL-FLAG.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getAssetAllocationModelFlag.
062615
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getAssetAllocationModelStatus.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01 lsAssetAllocationModelStatus   OBJECT REFERENCE CLASS-STRING.
062615
062615******************************************************************
062615 PROCEDURE DIVISION RETURNING lsAssetAllocationModelStatus.
062615******************************************************************
062615
062615     SET lsAssetAllocationModelStatus TO WMDLS-MODEL-STATUS.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getAssetAllocationModelStatus.

022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getProfileID.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01 lsProfileID   OBJECT REFERENCE CLASS-STRING.
022516
022516******************************************************************
022516 PROCEDURE DIVISION RETURNING lsProfileID.
022516******************************************************************
022516
022516     SET lsProfileID TO WMDLS-PROFILE-ID.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getProfileID.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getProfileDescription.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01 lsProfileDescription   OBJECT REFERENCE CLASS-STRING.
022516
022516******************************************************************
022516 PROCEDURE DIVISION RETURNING lsProfileDescription.
022516******************************************************************
022516
022516     SET lsProfileDescription TO WMDLS-PROFILE-DESCRIPTION.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getProfileDescription.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getAllocEffectiveDate.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsAllocEffectiveDate       PIC S9(09) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION RETURNING lsAllocEffectiveDate.
022516******************************************************************
022516
022516     MOVE WMDLS-ALLOC-EFFECTIVE-DATE
022516                      to lsAllocEffectiveDate.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getAllocEffectiveDate.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelCount.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelCount         PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION RETURNING lsModelCount.
062615******************************************************************
062615
062615     MOVE WMDLS-MDLS-LAST TO lsModelCount
062615
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelCount.
062615
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelName.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelName          OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelName.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsModelName
062615     ELSE
062615         SET lsModelName to WMDLS-MDLS-MODEL-NAME (lsIndex).
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelName.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelVersion.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelVersion       PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelVersion.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         MOVE ZERO TO lsModelVersion
062615     ELSE
062615         MOVE WMDLS-MDLS-MODEL-VERSION (lsIndex)
062615                      to lsModelVersion
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelVersion.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelDescription.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelDescription          OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelDescription.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsModelDescription
062615     ELSE
062615         SET lsModelDescription
062615                      TO WMDLS-MDLS-DESCRIPTION (lsIndex).
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelDescription.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelAvailableRank.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelAvailableRank PIC S9(04) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelAvailableRank.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         MOVE ZERO TO lsModelAvailableRank
062615     ELSE
062615         MOVE WMDLS-MDLS-AVAIL-RANK (lsIndex)
062615                      to lsModelAvailableRank
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelAvailableRank.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelMinPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelMinPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelMinPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         MOVE ZERO TO lsModelMinPercent
062615     ELSE
062615         MOVE WMDLS-MDLS-MIN-PERCENT (lsIndex)
062615                      to lsModelMinPercent
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelMinPercent.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelMaxPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelMaxPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelMaxPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         MOVE ZERO TO lsModelMaxPercent
062615     ELSE
062615         MOVE WMDLS-MDLS-MAX-PERCENT  (lsIndex)
062615                      to lsModelMaxPercent
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelMaxPercent.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getModelSelectionPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsModelSelectionPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsModelSelectionPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
062615         MOVE ZERO TO lsModelSelectionPercent
062615     ELSE
062615         MOVE WMDLS-MDLS-SEL-PERCENT  (lsIndex)
062615                      to lsModelSelectionPercent
062615
062615     EXIT METHOD.
062615
062615 END METHOD getModelSelectionPercent.
062615
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getModelMappingIndicator.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                 PIC S9(09) COMP-5.
022516 01  lsModelMappingIndicator PIC S9(04) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsModelMappingIndicator.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-MDLS-LAST
022516         MOVE ZERO TO lsModelMappingIndicator
022516     ELSE
022516         MOVE WMDLS-MDLS-MAPPING-IND (lsIndex)
022516                   TO lsModelMappingIndicator.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getModelMappingIndicator.
022516
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615
062615 METHOD-ID. getCategoryCount.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsCategoryCount         PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION RETURNING lsCategoryCount.
062615******************************************************************
062615
062615     MOVE WMDLS-CAT-LAST TO lsCategoryCount
062615
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryCount.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryModelTableIndex.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                  PIC S9(09) COMP-5.
062615 01  lsCategoryModelTableIndex        PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsCategoryModelTableIndex.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsCategoryModelTableIndex
062615     ELSE
062615         MOVE WMDLS-CAT-MODEL-INDEX (lsIndex)
062615              TO lsCategoryModelTableIndex
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryModelTableIndex.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryModelName.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsCategoryModelName      OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsCategoryModelName.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsCategoryModelName
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-CAT-MODEL-NAME (lsIndex)
062615              RETURNING lsCategoryModelName.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryModelName.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryModelVersion.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                      PIC S9(09) COMP-5.
062615 01  lsCategoryModelVersion       PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsCategoryModelVersion.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         MOVE ZERO TO lsCategoryModelVersion
062615     ELSE
062615         MOVE WMDLS-CAT-MODEL-VERSION (lsIndex)
062615              TO lsCategoryModelVersion
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryModelVersion.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryName.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                   PIC S9(09) COMP-5.
062615 01  lsCategoryName       OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsCategoryName.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsCategoryName
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-CAT-NAME (lsIndex)
062615              RETURNING lsCategoryName.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryName.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryPercentFlag.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                      PIC S9(09) COMP-5.
062615 01  lsCategoryPercentFlag   OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsCategoryPercentFlag.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsCategoryPercentFlag
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-CAT-FLAG (lsIndex)
062615              RETURNING lsCategoryPercentFlag.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getCategoryPercentFlag.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryConstantPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                           PIC S9(09) COMP-5.
062615 01  lsCategoryConstantPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsCategoryConstantPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         MOVE ZERO TO lsCategoryConstantPercent
062615     ELSE
062615         MOVE WMDLS-CAT-CON-PCT (lsIndex)
062615                 TO lsCategoryConstantPercent
062615
062615     EXIT METHOD.
062615 END METHOD getCategoryConstantPercent.
062615
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryMinPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                           PIC S9(09) COMP-5.
062615 01  lsCategoryMinPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsCategoryMinPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         MOVE ZERO TO lsCategoryMinPercent
062615     ELSE
062615         MOVE WMDLS-CAT-MIN-PCT (lsIndex)
062615                 TO lsCategoryMinPercent
062615
062615     EXIT METHOD.
062615 END METHOD getCategoryMinPercent.
062615
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCategoryMaxPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                           PIC S9(09) COMP-5.
062615 01  lsCategoryMaxPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsCategoryMaxPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-CAT-LAST
062615         MOVE ZERO TO lsCategoryMaxPercent
062615     ELSE
062615         MOVE WMDLS-CAT-MAX-PCT (lsIndex)
062615                 TO lsCategoryMaxPercent
062615
062615     EXIT METHOD.
062615 END METHOD getCategoryMaxPercent.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516
022516 METHOD-ID. getSubModelCount.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsSubModelCount         PIC S9(09) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION RETURNING lsSubModelCount.
022516******************************************************************
022516
022516     MOVE WMDLS-SUB-MODEL-LAST TO lsSubModelCount.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelCount.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelModelTableIndex.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                          PIC S9(09) COMP-5.
022516 01  lsSubModelModelTableIndex        PIC S9(09) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelModelTableIndex.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelModelTableIndex
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-MODEL-INDEX (lsIndex)
022516              TO lsSubModelModelTableIndex
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelModelTableIndex.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelModelName.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                  PIC S9(09) COMP-5.
022516 01  lsSubModelModelName      OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelModelName.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsSubModelModelName
022516     ELSE
022516         SET lsSubModelModelName
022516              TO WMDLS-SUB-MODEL-MODEL-NAME (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelModelName.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelModelVersion.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                      PIC S9(09) COMP-5.
022516 01  lsSubModelModelVersion       PIC S9(09) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelModelVersion.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelModelVersion
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-MODEL-VERSION (lsIndex)
022516              TO lsSubModelModelVersion.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelModelVersion.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelName.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                   PIC S9(09) COMP-5.
022516 01  lsSubModelName       OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelName.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsSubModelName
022516     ELSE
022516         SET lsSubModelName
022516              TO WMDLS-SUB-MODEL-NAME (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelName.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelDescription.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                   PIC S9(09) COMP-5.
022516 01  lsSubModelDescription     OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelDescription.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsSubModelDescription
022516     ELSE
022516         SET lsSubModelDescription
022516              TO WMDLS-SUB-MODEL-DESCRIPTION (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelDescription.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelPercentFlag.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                      PIC S9(09) COMP-5.
022516 01  lsSubModelPercentFlag   OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelPercentFlag.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsSubModelPercentFlag
022516     ELSE
022516         SET lsSubModelPercentFlag
022516              TO WMDLS-SUB-MODEL-FLAG (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelPercentFlag.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelConstantPercent.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                           PIC S9(09) COMP-5.
022516 01  lsSubModelConstantPercent         USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsSubModelConstantPercent.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelConstantPercent
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-CON-PCT (lsIndex)
022516                 TO lsSubModelConstantPercent
022516
022516     EXIT METHOD.
022516 END METHOD getSubModelConstantPercent.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelMinPercent.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                           PIC S9(09) COMP-5.
022516 01  lsSubModelMinPercent              USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsSubModelMinPercent.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelMinPercent
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-MIN-PCT (lsIndex)
022516                 TO lsSubModelMinPercent
022516
022516     EXIT METHOD.
022516 END METHOD getSubModelMinPercent.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelMaxPercent.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                           PIC S9(09) COMP-5.
022516 01  lsSubModelMaxPercent              USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsSubModelMaxPercent.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelMaxPercent
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-MAX-PCT (lsIndex)
022516                 TO lsSubModelMaxPercent
022516
022516     EXIT METHOD.
022516 END METHOD getSubModelMaxPercent.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelSelectionPercent.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                           PIC S9(09) COMP-5.
022516 01  lsSubModelSelectionPercent        USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsSubModelSelectionPercent.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelSelectionPercent
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-SEL-PERCENT (lsIndex)
022516                 TO lsSubModelSelectionPercent
022516
022516     EXIT METHOD.
022516 END METHOD getSubModelSelectionPercent.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getSubModelMappingIndicator.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                    PIC S9(09) COMP-5.
022516 01  lsSubModelMappingIndicator PIC S9(04) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsSubModelMappingIndicator.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-SUB-MODEL-LAST
022516         MOVE ZERO TO lsSubModelMappingIndicator
022516     ELSE
022516         MOVE WMDLS-SUB-MODEL-MAPPING-IND (lsIndex)
022516                   TO lsSubModelMappingIndicator.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getSubModelMappingIndicator.
022516
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getRowCount.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsRowCount                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRowCount.
      ******************************************************************

062615*    MOVE WDEPA-NBR-OF-ALLOCATIONS TO lsRowCount.
062615     MOVE WMDLS-FUND-LAST TO lsRowCount.
           EXIT METHOD.

       END METHOD getRowCount.

      ******************************************************************
      * The following get methods require an input index to determine the
      * table index you wish retrieved.
      ******************************************************************

062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelTableIndex.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                      PIC S9(09) COMP-5.
062615 01  lsFundModelTableIndex        PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsFundModelTableIndex.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundModelTableIndex
062615     ELSE
062615         MOVE WMDLS-FUND-MODEL-INDEX (lsIndex)
062615              TO lsFundModelTableIndex
062615
062615     EXIT METHOD.
062615
062615 END METHOD getFundModelTableIndex.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundCategoryTableIndex.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                      PIC S9(09) COMP-5.
062615 01  lsFundCategoryTableIndex        PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsFundCategoryTableIndex.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundCategoryTableIndex
062615     ELSE
062615         MOVE WMDLS-FUND-CAT-INDEX (lsIndex)
062615              TO lsFundCategoryTableIndex
062615
062615     EXIT METHOD.
062615
062615 END METHOD getFundCategoryTableIndex.
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getFundSubModelTableIndex.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                      PIC S9(09) COMP-5.
022516 01  lsFundSubModelTableIndex     PIC S9(09) COMP-5.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsFundSubModelTableIndex.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
022516         MOVE ZERO TO lsFundSubModelTableIndex
022516     ELSE
022516         MOVE WMDLS-FUND-SUB-MODEL-INDEX (lsIndex)
022516              TO lsFundSubModelTableIndex.
022516
022516     EXIT METHOD.
022516
022516 END METHOD getFundSubModelTableIndex.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelName.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsFundModelName      OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsFundModelName.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsFundModelName
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-FUND-MODEL-NAME (lsIndex)
062615              RETURNING lsFundModelName.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getFundModelName.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelVersion.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                  PIC S9(09) COMP-5.
062615 01  lsFundModelVersion       PIC S9(09) COMP-5.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsFundModelVersion.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundModelVersion
062615     ELSE
062615         MOVE WMDLS-FUND-MODEL-VERSION  (lsIndex)
062615              TO lsFundModelVersion
062615
062615     EXIT METHOD.
062615
062615 END METHOD getFundModelVersion.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getInvestedInThisModel.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex              PIC S9(09) COMP-5.
062615 01  lsInvestedInThisModel      OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION Using BY VALUE lsIndex
062615                    RETURNING lsInvestedInThisModel.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsInvestedInThisModel
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615              BY VALUE WMDLS-FUND-MOD-SELECTED-FLAG (lsIndex)
062615              RETURNING lsInvestedInThisModel.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getInvestedInThisModel.

022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getFundSubModelName.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex              PIC S9(09) COMP-5.
022516 01  lsFundSubModelName   OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsFundSubModelName.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsFundSubModelName
022516     ELSE
022516         SET lsFundSubModelName
022516              TO WMDLS-FUND-SUB-MODEL-NAME (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getFundSubModelName.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getFundSubModelDescription.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex              PIC S9(09) COMP-5.
022516 01  lsFundSubModelDescription  OBJECT REFERENCE CLASS-STRING.
022516******************************************************************
022516 PROCEDURE DIVISION Using BY VALUE lsIndex
022516                    RETURNING lsFundSubModelDescription.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
022516         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
022516              RETURNING lsFundSubModelDescription
022516     ELSE
022516         SET lsFundSubModelDescription
022516              TO WMDLS-FUND-SUB-MODEL-DESC (lsIndex).
022516
022516     EXIT METHOD.
022516
022516 END METHOD getFundSubModelDescription.
022516
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getFundID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex              PIC S9(09) COMP-5.
       01  lsFundID        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsFundID.
      ******************************************************************

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsFundID
           ELSE
               INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-FUND-ID (lsIndex)
                    RETURNING lsFundID.

           EXIT METHOD.

       END METHOD getFundID.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getFundAvailable.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsFundAvailable        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsFundAvailable.
      ******************************************************************
062615*    IF lsIndex < 1 OR lsIndex > WDEPA-NBR-OF-ALLOCATIONS
062615*        INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615*             RETURNING lsFundAvailable
062615*    ELSE
062615*        IF WDEPA-NOT-STATE-APPROVED (lsIndex)
062615*            INVOKE CLASS-STRING "NEW" USING
062615*                    BY VALUE 'N'
062615*                RETURNING lsFundAvailable
062615*        ELSE
062615*            INVOKE CLASS-STRING "NEW" USING
062615*                    BY VALUE 'Y'
062615*                RETURNING lsFundAvailable.
062615*

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         SET lsFundAvailable TO ' '
062615     ELSE
062615         SET lsFundAvailable TO WMDLS-FUND-AVAIL-FLAG (lsIndex)
062615     END-IF
062615
062615     EXIT METHOD.

       END METHOD getFundAvailable.
082916******************************************************************
082916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
082916******************************************************************
082916 METHOD-ID. getFundApprovalIndicator.
082916 DATA DIVISION.
082916******************************************************************
082916 WORKING-STORAGE SECTION.
082916******************************************************************
082916 LINKAGE SECTION.
082916
082916 01  lsIndex                    PIC S9(09) COMP-5.
082916 01  lsFundApprovalIndicator        OBJECT REFERENCE CLASS-STRING.
082916******************************************************************
082916 PROCEDURE DIVISION USING BY VALUE lsIndex
082916                    RETURNING lsFundApprovalIndicator.
082916******************************************************************
082916
082916     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
082916         SET lsFundApprovalIndicator TO ' '
082916     ELSE
082916         SET lsFundApprovalIndicator
082916                    TO WMDLS-STATE-APPROVAL-FLAG (lsIndex)
082916     END-IF
082916
082916     EXIT METHOD.
082916
082916 END METHOD getFundApprovalIndicator.

082916******************************************************************
082916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
082916******************************************************************
082916 METHOD-ID. getTerminatedAlternateFundID.
082916 DATA DIVISION.
082916******************************************************************
082916 WORKING-STORAGE SECTION.
082916******************************************************************
082916 LINKAGE SECTION.
082916
082916 01  lsIndex                       PIC S9(09) COMP-5.
082916 01  lsTerminatedAlternateFundID   OBJECT REFERENCE CLASS-STRING.
082916******************************************************************
082916 PROCEDURE DIVISION USING BY VALUE lsIndex
082916                    RETURNING lsTerminatedAlternateFundID.
082916******************************************************************
082916
082916     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
082916         SET lsTerminatedAlternateFundID TO ' '
082916     ELSE
082916         SET lsTerminatedAlternateFundID
082916           TO WMDLS-TERM-ALT-FUND-ID  (lsIndex)
082916     END-IF
082916
082916     EXIT METHOD.
082916
082916 END METHOD getTerminatedAlternateFundID.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getShortDescription.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsShortDescription        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsShortDescription.
      ******************************************************************

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsShortDescription
           ELSE
               INVOKE CLASS-STRING "NEW" USING
062615                     BY VALUE WMDLS-FUND-SHORT-DESC (lsIndex)
                    RETURNING lsShortDescription.

           EXIT METHOD.

       END METHOD getShortDescription.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLongDescription.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsLongDescription          OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsLongDescription.
      ******************************************************************

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsLongDescription
           ELSE
               INVOKE CLASS-STRING "NEW" USING
062615              BY VALUE WMDLS-FUND-LONG-DESC  (lsIndex)
                    RETURNING lsLongDescription.

           EXIT METHOD.

       END METHOD getLongDescription.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getFundType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsFundType             OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsFundType.
      ******************************************************************

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsFundType
           ELSE
               INVOKE CLASS-STRING "NEW" USING
062615              BY VALUE WMDLS-FUND-TYPE (lsIndex)
                    RETURNING lsFundType.

           EXIT METHOD.
       END METHOD getFundType.

062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getCusipNumber.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                         PIC S9(09) COMP-5.
062615 01  lsCusipNumber          OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsCusipNumber.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsCusipNumber
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615              BY VALUE WMDLS-FUND-CUSIP-NUMBER (lsIndex)
062615              RETURNING lsCusipNumber.
062615
062615     EXIT METHOD.
062615 END METHOD getCusipNumber.
062615
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelPercentFlag.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                       PIC S9(09) COMP-5.
062615 01  lsFundModelPercentFlag        OBJECT REFERENCE CLASS-STRING.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsFundModelPercentFlag.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
062615              RETURNING lsFundModelPercentFlag
062615     ELSE
062615         INVOKE CLASS-STRING "NEW" USING
062615              BY VALUE WMDLS-FUND-MDL-FLAG (lsIndex)
062615              RETURNING lsFundModelPercentFlag.
062615
062615     EXIT METHOD.
062615 END METHOD getFundModelPercentFlag.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelConstantPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                       PIC S9(09) COMP-5.
062615 01  lsFundModelConstantPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsFundModelConstantPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundModelConstantPercent
062615     ELSE
062615         MOVE WMDLS-FUND-MDL-CON-PCT (lsIndex)
062615                 TO lsFundModelConstantPercent
062615
062615     EXIT METHOD.
062615 END METHOD getFundModelConstantPercent.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelMinPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                       PIC S9(09) COMP-5.
062615 01  lsFundModelMinPercent    USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsFundModelMinPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundModelMinPercent
062615     ELSE
062615         MOVE WMDLS-FUND-MDL-MIN-PCT (lsIndex)
062615                 TO lsFundModelMinPercent
062615
062615     EXIT METHOD.
062615 END METHOD getFundModelMinPercent.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getFundModelMaxPercent.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01  lsIndex                       PIC S9(09) COMP-5.
062615 01  lsFundModelMaxPercent         USAGE COMP-2.
062615******************************************************************
062615 PROCEDURE DIVISION USING BY VALUE lsIndex
062615                    RETURNING lsFundModelMaxPercent.
062615******************************************************************
062615
062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
062615         MOVE ZERO TO lsFundModelMaxPercent
062615     ELSE
062615         MOVE WMDLS-FUND-MDL-MAX-PCT  (lsIndex)
062615                 TO lsFundModelMaxPercent
062615     EXIT METHOD.
062615 END METHOD getFundModelMaxPercent.
062615
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getFundModelAllocation.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                       PIC S9(09) COMP-5.
022516 01  lsFundModelAllocation         USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsFundModelAllocation.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
022516         MOVE ZERO TO lsFundModelAllocation
022516     ELSE
022516         MOVE WMDLS-FUND-MODEL-ALLOC  (lsIndex)
022516                 TO lsFundModelAllocation
022516     EXIT METHOD.
022516
022516 END METHOD getFundModelAllocation.
022516
022516******************************************************************
022516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022516******************************************************************
022516 METHOD-ID. getFundSubModelAllocation.
022516 DATA DIVISION.
022516******************************************************************
022516 WORKING-STORAGE SECTION.
022516******************************************************************
022516 LINKAGE SECTION.
022516
022516 01  lsIndex                          PIC S9(09) COMP-5.
022516 01  lsFundSubModelAllocation         USAGE COMP-2.
022516******************************************************************
022516 PROCEDURE DIVISION USING BY VALUE lsIndex
022516                    RETURNING lsFundSubModelAllocation.
022516******************************************************************
022516
022516     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
022516         MOVE ZERO TO lsFundSubModelAllocation
022516     ELSE
022516         MOVE WMDLS-FUND-SUB-MODEL-ALLOC (lsIndex)
022516                 TO lsFundSubModelAllocation
022516     EXIT METHOD.
022516
022516 END METHOD getFundSubModelAllocation.
022516
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getDepositAllocation.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsDepositAllocation      USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsDepositAllocation.
      ******************************************************************

062615     IF lsIndex < 1 OR lsIndex > WMDLS-FUND-LAST
               MOVE ZERO TO lsDepositAllocation
           ELSE
062615         MOVE WMDLS-FUND-ALLOCATION (lsIndex)
                            TO lsDepositAllocation.
           EXIT METHOD.

       END METHOD getDepositAllocation.

      ******************************************************************
      * Set methods.
      ******************************************************************
      ******************************************************************
       METHOD-ID. setCompanyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsCompanyCode                OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.
      ******************************************************************

           SET WDEPA-COMPANY-CODE to lsCompanyCode.

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

       01 lsPolicyNumber               OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.
      ******************************************************************

           SET WDEPA-POLICY-NUMBER to lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEffectiveDate.
      *  The SetEffectiveDate method is only effective when doing an update.
      *  The inquiry ALWAYS pulls the highest effective date.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsEffectiveDate              PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.
      ******************************************************************

           MOVE lsEffectiveDate TO WDEPA-EFFECTIVE-DATE.
           EXIT METHOD.

       END METHOD setEffectiveDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEditOnlyFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsEditOnlyFlag               OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEditOnlyFlag.
      ******************************************************************

           SET WDEPA-API-EDIT-ONLY-FLAG to lsEditOnlyFlag.

           EXIT METHOD.

       END METHOD setEditOnlyFlag.

082916******************************************************************
082916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
082916******************************************************************
082916 METHOD-ID. setShowFundsOnlyFlag.
082916 DATA DIVISION.
082916******************************************************************
082916 WORKING-STORAGE SECTION.
082916******************************************************************
082916 LINKAGE SECTION.
082916
082916 01 lsShowFundsOnlyFlag          OBJECT REFERENCE CLASS-STRING.
082916
082916******************************************************************
082916 PROCEDURE DIVISION USING BY VALUE lsShowFundsOnlyFlag.
082916******************************************************************
082916
082916     SET WDEPA-API-FUNDS-ONLY-FLAG  to lsShowFundsOnlyFlag.
082916
082916     EXIT METHOD.
082916
082916 END METHOD setShowFundsOnlyFlag.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setDepositAllocation.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsDepositAllocation      USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsDepositAllocation.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDEPA-NBR-OF-ALLOCATIONS
      *        If they provide an invalid index, just ignore the change.
               CONTINUE
           ELSE
               MOVE lsDepositAllocation TO WDEPA-ALLOCATION (lsIndex).

           EXIT METHOD.

       END METHOD setDepositAllocation.

       END OBJECT.
       END CLASS ODEPALLC.

