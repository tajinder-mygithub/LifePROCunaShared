       IDENTIFICATION DIVISION.
       CLASS-ID. ODISQUOT AS "LPNETAPI.ODISQUOT".
      *AUTHOR.         Rigdon.
      *DATE-WRITTEN.   July 2010.
      *DATE-COMPILED.
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
      *D BAPI object that gets disclosure quote information for a policy.
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
120110*H 20101008-003-01 DAR Initial implementation.  
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
121213*H 20131114-004-01 DAR Revise caching to work best given current test results.  
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.

       REPOSITORY.
           CLASS OAPPLICA        AS "LPNETAPI.OAPPLICA"
           CLASS CLASS-EXCEPTION AS "System.Exception"
           CLASS CLASS-STRING    AS "System.String"
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
           05  PFILEBTV                PIC X(08) VALUE 'PFILEBTV'.
           05  PDISQUOT                PIC X(08) VALUE 'PDISQUOT'.

       01  DISQ-MAX-INSURED            PIC S9(4) COMP-5 VALUE +2.
       01  DISQ-MAX-INDEXES            PIC S9(4) COMP-5 VALUE +22.
       01  DISQ-MAX-PREMS              PIC S9(4) COMP-5 VALUE +200.

       COPY WWSCRCPY.

           COPY WGLOBCPY.
           COPY WAPPLCPY.
           COPY WBTRVCPY.
           COPY WGLBXCPY.
           COPY WDISQCPY.

      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpApp     USAGE OBJECT REFERENCE OAPPLICA.
       01  WS-EXCEPTION    OBJECT REFERENCE CLASS-EXCEPTION.
       01  WS-EMPTY-STRING OBJECT REFERENCE CLASS-STRING.

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

       01  wsReturnCode                PIC S9(09) COMP-5.
       01  wsErrorMessage              PIC X(200).
       01  wsUserType                  PIC X(10) VALUE SPACES.

      ******************************************************************
       LINKAGE SECTION.

       01  lsApp                USAGE OBJECT REFERENCE OAPPLICA.
       01  lsUserType           USAGE OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsApp, lsUserType.
      ******************************************************************

           SET wsUserType                 TO lsUserType.
           SET LpApp                      TO lsApp.
           MOVE WGLOBAL                   TO WGLOBX.
           INVOKE lsApp "Login" USING wsUserType
                                      WGLOBX
                                      wsErrorMessage
                            RETURNING wsReturnCode

           MOVE WGLOBX                    TO WGLOBAL.

121213*    SET WGLOB-BATCH-CACHING        TO TRUE.
           SET WGLOB-USE-POLICY-APP-CACHE TO TRUE.
121213*    MOVE 'Y'                       TO WGLOB-APP-CACHE-FILES.
121213     MOVE ALL 'Y' TO WGLOB-APP-CACHE-FILES.
121213*    MOVE 'N'                       TO WGLOB-APP-CACHE-BEHAVIOR.
121213     MOVE ALL 'N' TO WGLOB-APP-CACHE-BEHAVIOR.

      *    If Login Attempt was unsuccessful, place results in
      *    return code and message properties.
           MOVE wsReturnCode              TO WDISQ-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage        TO WDISQ-ERROR-MESSAGE
           ELSE
               MOVE SPACES                TO WDISQ-ERROR-MESSAGE
           END-IF.

121213*    SET WGLOB-CLEAR-BATCH-CACHING    TO TRUE
121213*    SET WGLOB-CLEAR-POLICY-APP-CACHE TO TRUE
121213*    MOVE ZERO                        TO DATA-FILE-NUMBER
121213*
121213*    TRY
121213*        CALL PFILEBTV USING WGLOBAL
121213*                            WAPPL-CALL-PARAMETERS
121213*                            WBTRIEVE
121213*    CATCH WS-EXCEPTION
121213*        INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
121213*        MOVE 8008 TO wsReturnCode
121213*                     WDISQ-RETURN-CODE
121213*        MOVE 'Unexpected Abend in API - see Windows Event Log'
121213*            TO WDISQ-ERROR-MESSAGE
121213*    END-TRY.

       END METHOD NEW.

      ******************************************************************…
      *  Dispose will free any resources, for now just the Coder ID.
      *  It will act as a destructor, but must be explictly called.
      ******************************************************************…

       METHOD-ID. Dispose.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

       01  wsReturnCode                PIC S9(09) COMP-5.
       01  wsErrorMessage              PIC X(200).

      ******************************************************************
       LINKAGE SECTION.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************
           MOVE WGLOBAL                     TO WGLOBX.
           INVOKE LpApp "Logout" USING WGLOBX
                                       wsErrorMessage
                             RETURNING wsReturnCode
           MOVE WGLOBX                      TO WGLOBAL.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage          TO WDISQ-ERROR-MESSAGE
           ELSE
               MOVE SPACES                  TO WDISQ-ERROR-MESSAGE
           END-IF.

121213     SET WGLOB-CLEAR-POLICY-APP-CACHE TO TRUE
121213     MOVE ZERO TO DATA-FILE-NUMBER
121213
121213     TRY
121213         CALL PFILEBTV USING WGLOBAL
121213                             WAPPL-CALL-PARAMETERS
121213                             WBTRIEVE
121213     CATCH WS-EXCEPTION
121213         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
121213         MOVE 8008 TO WDISQ-RETURN-CODE
121213         MOVE 'Unexpected Abend in API - see Windows Event Log'
121213             TO WDISQ-ERROR-MESSAGE
121213     END-TRY.


       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. RunQuote.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode           PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           TRY
               CALL PDISQUOT USING WGLOBAL
                                   WDISQ-PARAMETERS
               END-CALL
           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008               TO WDISQ-RETURN-CODE
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                                       TO WDISQ-ERROR-MESSAGE
           END-TRY.

           MOVE WDISQ-RETURN-CODE      TO lsReturnCode.

           EXIT METHOD.

       END METHOD RunQuote.

      ******************************************************************
      *  Property declarations.
      *  Input - Get and Set methods
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFunction.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFunction             OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsFunction.

           SET lsFunction TO WDISQ-FUNCTION.

           EXIT METHOD.

       END METHOD getFunction.

      *-----------------------------------------------------------------

       METHOD-ID. setFunction.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFunction             OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsFunction.

           SET WDISQ-FUNCTION TO lsFunction.

           EXIT METHOD.

       END METHOD setFunction.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCoverageId.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCoverageId           OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsCoverageId.

           SET lsCoverageId TO WDISQ-COVERAGE-ID.

           EXIT METHOD.

       END METHOD getCoverageId.

      *-----------------------------------------------------------------

       METHOD-ID. setCoverageId.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCoverageId           OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsCoverageId.

           SET WDISQ-COVERAGE-ID TO lsCoverageId.

           EXIT METHOD.

       END METHOD setCoverageId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSuppCoverageId.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSuppCoverageId       OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsSuppCoverageId.

           SET lsSuppCoverageId TO WDISQ-SUPP-COVERAGE-ID.

           EXIT METHOD.

       END METHOD getSuppCoverageId.

      *-----------------------------------------------------------------

       METHOD-ID. setSuppCoverageId.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSuppCoverageId       OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsSuppCoverageId.

           SET WDISQ-SUPP-COVERAGE-ID TO lsSuppCoverageId.

           EXIT METHOD.

       END METHOD setSuppCoverageId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBenefitType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitType          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsBenefitType.

           SET lsBenefitType TO WDISQ-BENEFIT-TYPE.

           EXIT METHOD.

       END METHOD getBenefitType.

      *-----------------------------------------------------------------

       METHOD-ID. setBenefitType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitType          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsBenefitType.

           SET WDISQ-BENEFIT-TYPE TO lsBenefitType.

           EXIT METHOD.

       END METHOD setBenefitType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBenefitSubType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitSubType       OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsBenefitSubType.

           SET lsBenefitSubType TO WDISQ-BENEFIT-SUB-TYPE.

           EXIT METHOD.

       END METHOD getBenefitSubType.

      *-----------------------------------------------------------------

       METHOD-ID. setBenefitSubType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitSubType       OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsBenefitSubType.

           SET WDISQ-BENEFIT-SUB-TYPE TO lsBenefitSubType.

           EXIT METHOD.

       END METHOD setBenefitSubType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCompanyCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCompanyCode          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsCompanyCode.

           SET lsCompanyCode TO WDISQ-COMPANY-CODE.

           EXIT METHOD.

       END METHOD getCompanyCode.

      *-----------------------------------------------------------------

       METHOD-ID. setCompanyCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCompanyCode          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.

           SET WDISQ-COMPANY-CODE TO lsCompanyCode.

           EXIT METHOD.

       END METHOD setCompanyCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPolicyNumber.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPolicyNumber         OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsPolicyNumber.

           SET lsPolicyNumber TO WDISQ-POLICY-NUMBER.

           EXIT METHOD.

       END METHOD getPolicyNumber.

      *-----------------------------------------------------------------

       METHOD-ID. setPolicyNumber.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPolicyNumber         OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.

           SET WDISQ-POLICY-NUMBER TO lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBenefitSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitSeq           PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsBenefitSeq.

           MOVE WDISQ-BENEFIT-SEQ TO lsBenefitSeq.

           EXIT METHOD.

       END METHOD getBenefitSeq.

      *-----------------------------------------------------------------

       METHOD-ID. setBenefitSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsBenefitSeq           PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsBenefitSeq.

           MOVE lsBenefitSeq TO WDISQ-BENEFIT-SEQ.

           EXIT METHOD.

       END METHOD setBenefitSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getParentBenefitSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsParentBenefitSeq     PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsParentBenefitSeq.

           MOVE WDISQ-PARENT-BENEFIT-SEQ TO lsParentBenefitSeq.

           EXIT METHOD.

       END METHOD getParentBenefitSeq.

      *-----------------------------------------------------------------

       METHOD-ID. setParentBenefitSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsParentBenefitSeq     PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsParentBenefitSeq.

           MOVE lsParentBenefitSeq TO WDISQ-PARENT-BENEFIT-SEQ.

           EXIT METHOD.

       END METHOD setParentBenefitSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSubstandardSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSubstandardSeq       PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsSubstandardSeq.

           MOVE WDISQ-SUBSTANDARD-SEQ TO lsSubstandardSeq.

           EXIT METHOD.

       END METHOD getSubstandardSeq.

      *-----------------------------------------------------------------

       METHOD-ID. setSubstandardSeq.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSubstandardSeq       PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsSubstandardSeq.

           MOVE lsSubstandardSeq TO WDISQ-SUBSTANDARD-SEQ.

           EXIT METHOD.

       END METHOD setSubstandardSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIssueDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIssueDate            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsIssueDate.

           MOVE WDISQ-ISSUE-DATE TO lsIssueDate.

           EXIT METHOD.

       END METHOD getIssueDate.

      *-----------------------------------------------------------------

       METHOD-ID. setIssueDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIssueDate            PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIssueDate.

           MOVE lsIssueDate TO WDISQ-ISSUE-DATE.

           EXIT METHOD.

       END METHOD setIssueDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEffDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEffDate              PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsEffDate.

           MOVE WDISQ-EFF-DATE TO lsEffDate.

           EXIT METHOD.

       END METHOD getEffDate.

      *-----------------------------------------------------------------

       METHOD-ID. setEffDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEffDate              PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsEffDate.

           MOVE lsEffDate TO WDISQ-EFF-DATE.

           EXIT METHOD.

       END METHOD setEffDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getForm.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsForm                 OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsForm.

           SET lsForm TO WDISQ-FORM.

           EXIT METHOD.

       END METHOD getForm.

      *-----------------------------------------------------------------

       METHOD-ID. setForm.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsForm                 OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsForm.

           SET WDISQ-FORM TO lsForm.

           EXIT METHOD.

       END METHOD setForm.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getMode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsMode                 PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsMode.

           MOVE WDISQ-MODE TO lsMode.

           EXIT METHOD.

       END METHOD getMode.

      *-----------------------------------------------------------------

       METHOD-ID. setMode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsMode                 PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsMode.

           MOVE lsMode TO WDISQ-MODE.

           EXIT METHOD.

       END METHOD setMode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFaceUnitsOrAmount.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFaceUnitsOrAmount    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING lsFaceUnitsOrAmount.

           MOVE WDISQ-FACE-UNITS-OR-AMOUNT TO lsFaceUnitsOrAmount.

           EXIT METHOD.

       END METHOD getFaceUnitsOrAmount.

      *-----------------------------------------------------------------

       METHOD-ID. setFaceUnitsOrAmount.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFaceUnitsOrAmount    USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsFaceUnitsOrAmount.

           MOVE lsFaceUnitsOrAmount TO WDISQ-FACE-UNITS-OR-AMOUNT.

           EXIT METHOD.

       END METHOD setFaceUnitsOrAmount.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFaceType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFaceType             OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsFaceType.

           SET lsFaceType TO WDISQ-FACE-TYPE.

           EXIT METHOD.

       END METHOD getFaceType.

      *-----------------------------------------------------------------

       METHOD-ID. setFaceType.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsFaceType             OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsFaceType.

           SET WDISQ-FACE-TYPE TO lsFaceType.

           EXIT METHOD.

       END METHOD setFaceType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGender.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsGender               OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsGender.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               SET lsGender TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsGender TO WDISQ-GENDER (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getGender.

      *-----------------------------------------------------------------

       METHOD-ID. setGender.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsGender               OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsGender.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               SET WDISQ-GENDER (lsIndex) TO lsGender
           END-IF.

           EXIT METHOD.

       END METHOD setGender.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUwcls.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsUwcls                OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsUwcls.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               SET lsUwcls TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsUwcls TO  WDISQ-UWCLS (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getUwcls.

      *-----------------------------------------------------------------

       METHOD-ID. setUwcls.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsUwcls                OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsUwcls.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               SET WDISQ-UWCLS (lsIndex) TO lsUwcls
           END-IF.

           EXIT METHOD.

       END METHOD setUwcls.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDob.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsDob                  PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsDob.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS               TO lsDob
           ELSE
               MOVE WDISQ-DOB (lsIndex) TO lsDob
           END-IF.

           EXIT METHOD.

       END METHOD getDob.

      *-----------------------------------------------------------------

       METHOD-ID. setDob.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsDob                  PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsDob.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsDob TO WDISQ-DOB (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setDob.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIssueAge.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsIssueAge             PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsIssueAge.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS                     TO lsIssueAge
           ELSE
               MOVE WDISQ-ISSUE-AGE (lsIndex) TO lsIssueAge
           END-IF.

           EXIT METHOD.

       END METHOD getIssueAge.

      *-----------------------------------------------------------------

       METHOD-ID. setIssueAge.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsIssueAge             PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsIssueAge.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsIssueAge TO WDISQ-ISSUE-AGE (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setIssueAge.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTable.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsTable                OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsTable.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               SET lsTable TO PROP-EMPTY OF CLASS-STRING
           ELSE
               SET lsTable TO WDISQ-TABLE (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD getTable.

      *-----------------------------------------------------------------

       METHOD-ID. setTable.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsTable                OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsTable.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               SET WDISQ-TABLE (lsIndex) TO lsTable
           END-IF.

           EXIT METHOD.

       END METHOD setTable.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPercentRating.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsPercentRating        USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsPercentRating.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS                          TO lsPercentRating
           ELSE
               MOVE WDISQ-PERCENT-RATING (lsIndex) TO lsPercentRating
           END-IF.

           EXIT METHOD.

       END METHOD getPercentRating.

      *-----------------------------------------------------------------

       METHOD-ID. setPercentRating.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsPercentRating        USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsPercentRating.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsPercentRating TO WDISQ-PERCENT-RATING (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setPercentRating.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPercentRatingDur.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsPercentRatingDur     PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsPercentRatingDur.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS
                 TO lsPercentRatingDur
           ELSE
               MOVE WDISQ-PERCENT-RATING-DUR (lsIndex)
                 TO lsPercentRatingDur
           END-IF.

           EXIT METHOD.

       END METHOD getPercentRatingDur.

      *-----------------------------------------------------------------

       METHOD-ID. setPercentRatingDur.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsPercentRatingDur     PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsPercentRatingDur.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsPercentRatingDur
                 TO WDISQ-PERCENT-RATING-DUR (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setPercentRatingDur.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFlatExtra.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsFlatExtra            USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsFlatExtra.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS                      TO lsFlatExtra
           ELSE
               MOVE WDISQ-FLAT-EXTRA (lsIndex) TO lsFlatExtra
           END-IF.

           EXIT METHOD.

       END METHOD getFlatExtra.

      *-------------------------------------------------------------------------

       METHOD-ID. setFlatExtra.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsFlatExtra            USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsFlatExtra.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsFlatExtra   TO WDISQ-FLAT-EXTRA (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setFlatExtra.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFlatExtraDur.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsFlatExtraDur         PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsFlatExtraDur.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               MOVE ZEROS                          TO lsFlatExtraDur
           ELSE
               MOVE WDISQ-FLAT-EXTRA-DUR (lsIndex) TO lsFlatExtraDur
           END-IF.

           EXIT METHOD.

       END METHOD getFlatExtraDur.

      *-------------------------------------------------------------------------

       METHOD-ID. setFlatExtraDur.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsFlatExtraDur         PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsFlatExtraDur.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-INSURED
               CONTINUE
           ELSE
               MOVE lsFlatExtraDur TO WDISQ-FLAT-EXTRA-DUR (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setFlatExtraDur.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPremBasedOnDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPremBasedOnDate      OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsPremBasedOnDate.

           SET lsPremBasedOnDate TO WDISQ-PREM-BASED-ON-DATE.

           EXIT METHOD.

       END METHOD getPremBasedOnDate.

      *-----------------------------------------------------------------

       METHOD-ID. setPremBasedOnDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPremBasedOnDate      OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsPremBasedOnDate.

           SET WDISQ-PREM-BASED-ON-DATE TO lsPremBasedOnDate.

           EXIT METHOD.

       END METHOD setPremBasedOnDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPremiumRank.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPremiumRank          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsPremiumRank.

           MOVE WDISQ-PREMIUM-RANK TO lsPremiumRank.

           EXIT METHOD.

       END METHOD getPremiumRank.

      *-----------------------------------------------------------------

       METHOD-ID. setPremiumRank.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPremiumRank          PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsPremiumRank.

           MOVE lsPremiumRank TO WDISQ-PREMIUM-RANK.

           EXIT METHOD.

       END METHOD setPremiumRank.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRatingRank.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRatingRank           PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsRatingRank.

           MOVE WDISQ-RATING-RANK TO lsRatingRank.

           EXIT METHOD.

       END METHOD getRatingRank.

      *-----------------------------------------------------------------

       METHOD-ID. setRatingRank.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRatingRank          PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsRatingRank.

           MOVE lsRatingRank TO WDISQ-RATING-RANK.

           EXIT METHOD.

       END METHOD setRatingRank.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCurrPercent.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCurrPercent          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsCurrPercent.

           MOVE WDISQ-CURR-PERCENT TO lsCurrPercent.

           EXIT METHOD.

       END METHOD getCurrPercent.

      *-----------------------------------------------------------------

       METHOD-ID. setCurrPercent.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCurrPercent          PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsCurrPercent.

           MOVE lsCurrPercent TO WDISQ-CURR-PERCENT.

           EXIT METHOD.

       END METHOD setCurrPercent.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGuarPercent.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGuarPercent          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsGuarPercent.

           MOVE WDISQ-GUAR-PERCENT TO lsGuarPercent.

           EXIT METHOD.

       END METHOD getGuarPercent.

      *-----------------------------------------------------------------

       METHOD-ID. setGuarPercent.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGuarPercent          PIC S9(09) COMP-5.

       PROCEDURE DIVISION USING BY VALUE lsGuarPercent.

           MOVE lsGuarPercent TO WDISQ-GUAR-PERCENT.

           EXIT METHOD.

       END METHOD setGuarPercent.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCurrBasis.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCurrBasis            OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsCurrBasis.

           SET lsCurrBasis TO WDISQ-CURR-BASIS.

           EXIT METHOD.

       END METHOD getCurrBasis.

      *-----------------------------------------------------------------

       METHOD-ID. setCurrBasis.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCurrBasis            OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsCurrBasis.

           SET WDISQ-CURR-BASIS TO lsCurrBasis.

           EXIT METHOD.

       END METHOD setCurrBasis.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGuarBasis.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGuarBasis            OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsGuarBasis.

           SET lsGuarBasis TO WDISQ-GUAR-BASIS.

           EXIT METHOD.

       END METHOD getGuarBasis.

      *-----------------------------------------------------------------

       METHOD-ID. setGuarBasis.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGuarBasis            OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsGuarBasis.

           SET WDISQ-GUAR-BASIS TO lsGuarBasis.

           EXIT METHOD.

       END METHOD setGuarBasis.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInputIssueState.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsInputIssueState      OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsInputIssueState.

           SET lsInputIssueState TO WDISQ-INPUT-ISSUE-STATE.

           EXIT METHOD.

       END METHOD getInputIssueState.

      *-----------------------------------------------------------------

       METHOD-ID. setInputIssueState.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsInputIssueState      OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION USING BY VALUE lsInputIssueState.

           SET WDISQ-INPUT-ISSUE-STATE TO lsInputIssueState.

           EXIT METHOD.

       END METHOD setInputIssueState.

      ******************************************************************
      *  Property declarations.
      *  Output - Get methods
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsReturnCode               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsReturnCode.

           MOVE WDISQ-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.

       END METHOD getReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsErrorMessage               OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsErrorMessage.

           SET lsErrorMessage TO WDISQ-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPriReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPriReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsPriReturnCode.

           MOVE WDISQ-PRI-RETURN-CODE TO lsPriReturnCode.

           EXIT METHOD.

       END METHOD getPriReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPriErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPriErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsPriErrorMessage.

           SET lsPriErrorMessage TO WDISQ-PRI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getPriErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPrrReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPrrReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsPrrReturnCode.

           MOVE WDISQ-PRR-RETURN-CODE TO lsPrrReturnCode.

           EXIT METHOD.

       END METHOD getPrrReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPrrErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsPrrErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsPrrErrorMessage.

           SET lsPrrErrorMessage TO WDISQ-PRR-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getPrrErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGpiReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGpiReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsGpiReturnCode.

           MOVE WDISQ-GPI-RETURN-CODE TO lsGpiReturnCode.

           EXIT METHOD.

       END METHOD getGpiReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGpiErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGpiErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsGpiErrorMessage.

           SET lsGpiErrorMessage TO WDISQ-GPI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getGpiErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCviReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCviReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsCviReturnCode.

           MOVE WDISQ-CVI-RETURN-CODE TO lsCviReturnCode.

           EXIT METHOD.

       END METHOD getCviReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCviErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCviErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsCviErrorMessage.

           SET lsCviErrorMessage TO WDISQ-CVI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getCviErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDbiReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDbiReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsDbiReturnCode.

           MOVE WDISQ-DBI-RETURN-CODE TO lsDbiReturnCode.

           EXIT METHOD.

       END METHOD getDbiReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDbiErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDbiErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsDbiErrorMessage.

           SET lsDbiErrorMessage TO WDISQ-DBI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getDbiErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDviReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDviReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsDviReturnCode.

           MOVE WDISQ-DVI-RETURN-CODE TO lsDviReturnCode.

           EXIT METHOD.

       END METHOD getDviReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDviErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDviErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsDviErrorMessage.

           SET lsDviErrorMessage TO WDISQ-DVI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getDviErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRpuReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRpuReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsRpuReturnCode.

           MOVE WDISQ-RPU-RETURN-CODE TO lsRpuReturnCode.

           EXIT METHOD.

       END METHOD getRpuReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRpuErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRpuErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsRpuErrorMessage.

           SET lsRpuErrorMessage TO WDISQ-RPU-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getRpuErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEtiReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsEtiReturnCode.

           MOVE WDISQ-ETI-RETURN-CODE TO lsEtiReturnCode.

           EXIT METHOD.

       END METHOD getEtiReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEtiErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsEtiErrorMessage.

           SET lsEtiErrorMessage TO WDISQ-ETI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getEtiErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSpiReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSpiReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsSpiReturnCode.

           MOVE WDISQ-SPI-RETURN-CODE TO lsSpiReturnCode.

           EXIT METHOD.

       END METHOD getSpiReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSpiErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSpiErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsSpiErrorMessage.

           SET lsSpiErrorMessage TO WDISQ-SPI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getSpiErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSgiReturnCode.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSgiReturnCode            PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsSgiReturnCode.

           MOVE WDISQ-SGI-RETURN-CODE TO lsSgiReturnCode.

           EXIT METHOD.

       END METHOD getSgiReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSgiErrorMessage.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSgiErrorMessage          OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsSgiErrorMessage.

           SET lsSgiErrorMessage TO WDISQ-SGI-ERROR-MESSAGE.

           EXIT METHOD.

       END METHOD getSgiErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDatePaidUp.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDatePaidUp               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsDatePaidUp.

           MOVE WDISQ-DATE-PAID-UP TO lsDatePaidUp.

           EXIT METHOD.

       END METHOD getDatePaidUp.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getExpirationDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsExpirationDate               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsExpirationDate.

           MOVE WDISQ-EXPIRATION-DATE TO lsExpirationDate.

           EXIT METHOD.

       END METHOD getExpirationDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNextPremiumDate.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsNextPremiumDate               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsNextPremiumDate.

           MOVE WDISQ-NEXT-PREMIUM-DATE TO lsNextPremiumDate.

           EXIT METHOD.

       END METHOD getNextPremiumDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNextPremiumDur.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsNextPremiumDur               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsNextPremiumDur.

           MOVE WDISQ-NEXT-PREMIUM-DUR TO lsNextPremiumDur.

           EXIT METHOD.

       END METHOD getNextPremiumDur.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDescription.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDescription               OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsDescription.

           SET lsDescription TO WDISQ-DESCRIPTION.

           EXIT METHOD.

       END METHOD getDescription.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIssueState.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIssueState               OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION RETURNING lsIssueState.

           SET lsIssueState TO WDISQ-ISSUE-STATE.

           EXIT METHOD.

       END METHOD getIssueState.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDirMonthlyPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDirMonthlyPrem               USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING lsDirMonthlyPrem.

           MOVE WDISQ-DIR-MONTHLY-PREM TO lsDirMonthlyPrem.

           EXIT METHOD.

       END METHOD getDirMonthlyPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDirQuarterlyPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDirQuarterlyPrem               USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING lsDirQuarterlyPrem.

           MOVE WDISQ-DIR-QUARTERLY-PREM TO lsDirQuarterlyPrem.

           EXIT METHOD.

       END METHOD getDirQuarterlyPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDirSemiAnnualPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDirSemiAnnualPrem               USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING lsDirSemiAnnualPrem.

           MOVE WDISQ-DIR-SEMI-ANNUAL-PREM TO lsDirSemiAnnualPrem.

           EXIT METHOD.

       END METHOD getDirSemiAnnualPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAnnualPolicyFee.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsAnnualPolicyFee               USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING lsAnnualPolicyFee.

           MOVE WDISQ-ANNUAL-POLICY-FEE TO lsAnnualPolicyFee.

           EXIT METHOD.

       END METHOD getAnnualPolicyFee.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInitialModalPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsInitialModalPrem     USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsInitialModalPrem.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsInitialModalPrem
           ELSE
               MOVE WDISQ-INITIAL-MODAL-PREM (lsIndex)
                 TO lsInitialModalPrem
           END-IF.

           EXIT METHOD.

       END METHOD getInitialModalPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInitialPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsInitialPrem          USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsInitialPrem.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsInitialPrem
           ELSE
               MOVE WDISQ-INITIAL-PREM (lsIndex)
                 TO lsInitialPrem
           END-IF.

           EXIT METHOD.

       END METHOD getInitialPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRenewalPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsRenewalPrem          USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsRenewalPrem.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsRenewalPrem
           ELSE
               MOVE WDISQ-RENEWAL-PREM (lsIndex)
                 TO lsRenewalPrem
           END-IF.

           EXIT METHOD.

       END METHOD getRenewalPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGuarPrem.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsGuarPrem             USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsGuarPrem.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsGuarPrem
           ELSE
               MOVE WDISQ-GUAR-PREM (lsIndex)
                 TO lsGuarPrem
           END-IF.

           EXIT METHOD.

       END METHOD getGuarPrem.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCashValue.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsCashValue            USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsCashValue.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsCashValue
           ELSE
               MOVE WDISQ-CASH-VALUE (lsIndex)
                 TO lsCashValue
           END-IF.

           EXIT METHOD.

       END METHOD getCashValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDeathBenefit.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsDeathBenefit         USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsDeathBenefit.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsDeathBenefit
           ELSE
               MOVE WDISQ-DEATH-BENEFIT (lsIndex)
                 TO lsDeathBenefit
           END-IF.

           EXIT METHOD.

       END METHOD getDeathBenefit.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDivAtIssue.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsDivAtIssue           USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsDivAtIssue.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsDivAtIssue
           ELSE
               MOVE WDISQ-DIV-AT-ISSUE (lsIndex)
                 TO lsDivAtIssue
           END-IF.

           EXIT METHOD.

       END METHOD getDivAtIssue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRpuValue.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsRpuValue             USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsRpuValue.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsRpuValue
           ELSE
               MOVE WDISQ-RPU-VALUE (lsIndex)
                 TO lsRpuValue
           END-IF.

           EXIT METHOD.

       END METHOD getRpuValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiYear.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsEtiYear              USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsEtiYear.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsEtiYear
           ELSE
               MOVE WDISQ-ETI-YEAR (lsIndex)
                 TO lsEtiYear
           END-IF.

           EXIT METHOD.

       END METHOD getEtiYear.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiDay.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsEtiDay               USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsEtiDay.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsEtiDay
           ELSE
               MOVE WDISQ-ETI-DAY (lsIndex)
                 TO lsEtiDay
           END-IF.

           EXIT METHOD.

       END METHOD getEtiDay.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSubstCurr.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsSubstCurr            USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsSubstCurr.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsSubstCurr
           ELSE
               MOVE WDISQ-SUBST-CURR (lsIndex)
                 TO lsSubstCurr
           END-IF.

           EXIT METHOD.

       END METHOD getSubstCurr.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSubstGuar.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsIndex                PIC S9(09) COMP-5.
       01  lsSubstGuar            USAGE IS COMP-2.

       PROCEDURE DIVISION USING BY VALUE lsIndex
                               RETURNING lsSubstGuar.

           IF lsIndex < 1 OR lsIndex > DISQ-MAX-PREMS
               MOVE ZEROS
                 TO lsSubstGuar
           ELSE
               MOVE WDISQ-SUBST-GUAR(lsIndex)
                 TO lsSubstGuar
           END-IF.

           EXIT METHOD.

       END METHOD getSubstGuar.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thNetCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thNetCurrIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thNetCurrIndex.

           MOVE WDISQ-05TH-NET-CURR-INDEX TO ls05thNetCurrIndex.

           EXIT METHOD.

       END METHOD get05thNetCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thNetCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thNetCurrIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thNetCurrIndex.

           MOVE WDISQ-10TH-NET-CURR-INDEX TO ls10thNetCurrIndex.

           EXIT METHOD.

       END METHOD get10thNetCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thNetCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thNetCurrIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thNetCurrIndex.

           MOVE WDISQ-20TH-NET-CURR-INDEX TO ls20thNetCurrIndex.

           EXIT METHOD.

       END METHOD get20thNetCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thNetCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thNetCurrIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thNetCurrIndex.

           MOVE WDISQ-25TH-NET-CURR-INDEX TO ls25thNetCurrIndex.

           EXIT METHOD.

       END METHOD get25thNetCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thNetGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thNetGuarIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thNetGuarIndex.

           MOVE WDISQ-05TH-NET-GUAR-INDEX TO ls05thNetGuarIndex.

           EXIT METHOD.

       END METHOD get05thNetGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thNetGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thNetGuarIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thNetGuarIndex.

           MOVE WDISQ-10TH-NET-GUAR-INDEX TO ls10thNetGuarIndex.

           EXIT METHOD.

       END METHOD get10thNetGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thNetGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thNetGuarIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thNetGuarIndex.

           MOVE WDISQ-20TH-NET-GUAR-INDEX TO ls20thNetGuarIndex.

           EXIT METHOD.

       END METHOD get20thNetGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thNetGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thNetGuarIndex     USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thNetGuarIndex.

           MOVE WDISQ-25TH-NET-GUAR-INDEX TO ls25thNetGuarIndex.

           EXIT METHOD.

       END METHOD get25thNetGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thSurrCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thSurrCurrIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thSurrCurrIndex.

           MOVE WDISQ-05TH-SURR-CURR-INDEX TO ls05thSurrCurrIndex.

           EXIT METHOD.

       END METHOD get05thSurrCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thSurrCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thSurrCurrIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thSurrCurrIndex.

           MOVE WDISQ-10TH-SURR-CURR-INDEX TO ls10thSurrCurrIndex.

           EXIT METHOD.

       END METHOD get10thSurrCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thSurrCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thSurrCurrIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thSurrCurrIndex.

           MOVE WDISQ-20TH-SURR-CURR-INDEX TO ls20thSurrCurrIndex.

           EXIT METHOD.

       END METHOD get20thSurrCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thSurrCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thSurrCurrIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thSurrCurrIndex.

           MOVE WDISQ-25TH-SURR-CURR-INDEX TO ls25thSurrCurrIndex.

           EXIT METHOD.

       END METHOD get25thSurrCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thSurrGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thSurrGuarIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thSurrGuarIndex.

           MOVE WDISQ-05TH-SURR-GUAR-INDEX TO ls05thSurrGuarIndex.

           EXIT METHOD.

       END METHOD get05thSurrGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thSurrGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thSurrGuarIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thSurrGuarIndex.

           MOVE WDISQ-10TH-SURR-GUAR-INDEX TO ls10thSurrGuarIndex.

           EXIT METHOD.

       END METHOD get10thSurrGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thSurrGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thSurrGuarIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thSurrGuarIndex.

           MOVE WDISQ-20TH-SURR-GUAR-INDEX TO ls20thSurrGuarIndex.

           EXIT METHOD.

       END METHOD get20thSurrGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thSurrGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thSurrGuarIndex    USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thSurrGuarIndex.

           MOVE WDISQ-25TH-SURR-GUAR-INDEX TO ls25thSurrGuarIndex.

           EXIT METHOD.

       END METHOD get25thSurrGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thEquivCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thEquivCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thEquivCurrIndex.

           MOVE WDISQ-10TH-EQUIV-CURR-INDEX TO ls10thEquivCurrIndex.

           EXIT METHOD.

       END METHOD get10thEquivCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thEquivCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thEquivCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thEquivCurrIndex.

           MOVE WDISQ-20TH-EQUIV-CURR-INDEX TO ls20thEquivCurrIndex.

           EXIT METHOD.

       END METHOD get20thEquivCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thEquivCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thEquivCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thEquivCurrIndex.

           MOVE WDISQ-25TH-EQUIV-CURR-INDEX TO ls25thEquivCurrIndex.

           EXIT METHOD.

       END METHOD get25thEquivCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thEquivGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thEquivGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thEquivGuarIndex.

           MOVE WDISQ-10TH-EQUIV-GUAR-INDEX TO ls10thEquivGuarIndex.

           EXIT METHOD.

       END METHOD get10thEquivGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thEquivGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thEquivGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thEquivGuarIndex.

           MOVE WDISQ-20TH-EQUIV-GUAR-INDEX TO ls20thEquivGuarIndex.

           EXIT METHOD.

       END METHOD get20thEquivGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thEquivGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thEquivGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thEquivGuarIndex.

           MOVE WDISQ-25TH-EQUIV-GUAR-INDEX TO ls25thEquivGuarIndex.

           EXIT METHOD.

       END METHOD get25thEquivGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thCalifCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thCalifCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thCalifCurrIndex.

           MOVE WDISQ-05TH-CALIF-CURR-INDEX TO ls05thCalifCurrIndex.

           EXIT METHOD.

       END METHOD get05thCalifCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thCalifCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thCalifCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thCalifCurrIndex.

           MOVE WDISQ-10TH-CALIF-CURR-INDEX TO ls10thCalifCurrIndex.

           EXIT METHOD.

       END METHOD get10thCalifCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thCalifCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thCalifCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thCalifCurrIndex.

           MOVE WDISQ-20TH-CALIF-CURR-INDEX TO ls20thCalifCurrIndex.

           EXIT METHOD.
       END METHOD get20thCalifCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thCalifCurrIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thCalifCurrIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thCalifCurrIndex.

           MOVE WDISQ-25TH-CALIF-CURR-INDEX TO ls25thCalifCurrIndex.

           EXIT METHOD.

       END METHOD get25thCalifCurrIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get05thCalifGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls05thCalifGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls05thCalifGuarIndex.


           MOVE WDISQ-05TH-CALIF-GUAR-INDEX TO ls05thCalifGuarIndex.


           EXIT METHOD.

       END METHOD get05thCalifGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get10thCalifGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls10thCalifGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls10thCalifGuarIndex.

           MOVE WDISQ-10TH-CALIF-GUAR-INDEX TO ls10thCalifGuarIndex.

           EXIT METHOD.

       END METHOD get10thCalifGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get20thCalifGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls20thCalifGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls20thCalifGuarIndex.

           MOVE WDISQ-20TH-CALIF-GUAR-INDEX TO ls20thCalifGuarIndex.

           EXIT METHOD.

       END METHOD get20thCalifGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. get25thCalifGuarIndex.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  ls25thCalifGuarIndex   USAGE IS COMP-2.

       PROCEDURE DIVISION RETURNING ls25thCalifGuarIndex.

           MOVE WDISQ-25TH-CALIF-GUAR-INDEX TO ls25thCalifGuarIndex.

           EXIT METHOD.

       END METHOD get25thCalifGuarIndex.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInitModalPremCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsInitModalPremCnt     PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsInitModalPremCnt.

           MOVE WDISQ-INIT-MODAL-PREM-CNT TO lsInitModalPremCnt.

           EXIT METHOD.

       END METHOD getInitModalPremCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInitPremCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsInitPremCnt          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsInitPremCnt.

           MOVE WDISQ-INIT-PREM-CNT TO lsInitPremCnt.

           EXIT METHOD.

       END METHOD getInitPremCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRenewalPremCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRenewalPremCnt       PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsRenewalPremCnt.

           MOVE WDISQ-RENEWAL-PREM-CNT TO lsRenewalPremCnt.

           EXIT METHOD.

       END METHOD getRenewalPremCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getGuarPremCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsGuarPremCnt          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsGuarPremCnt.

           MOVE WDISQ-GUAR-PREM-CNT TO lsGuarPremCnt.

           EXIT METHOD.

       END METHOD getGuarPremCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCashValuesCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsCashValuesCnt        PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsCashValuesCnt.

           MOVE WDISQ-CASH-VALUES-CNT TO lsCashValuesCnt.

           EXIT METHOD.

       END METHOD getCashValuesCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDeathBenefitCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDeathBenefitCnt      PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsDeathBenefitCnt.

           MOVE WDISQ-DEATH-BENEFIT-CNT TO lsDeathBenefitCnt.

           EXIT METHOD.

       END METHOD getDeathBenefitCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDivAtIssueCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsDivAtIssueCnt        PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsDivAtIssueCnt.

           MOVE WDISQ-DIV-AT-ISSUE-CNT TO lsDivAtIssueCnt.

           EXIT METHOD.

       END METHOD getDivAtIssueCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRpuCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsRpuCnt               PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsRpuCnt.

           MOVE WDISQ-RPU-CNT TO lsRpuCnt.

           EXIT METHOD.

       END METHOD getRpuCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiYearsCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEtiYearsCnt          PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsEtiYearsCnt.

           MOVE WDISQ-ETI-YEARS-CNT TO lsEtiYearsCnt.

           EXIT METHOD.

       END METHOD getEtiYearsCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEtiDaysCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsEtiDaysCnt           PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsEtiDaysCnt.

           MOVE WDISQ-ETI-DAYS-CNT TO lsEtiDaysCnt.

           EXIT METHOD.

       END METHOD getEtiDaysCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSubstCurrCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSubstCurrCnt         PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsSubstCurrCnt.

           MOVE WDISQ-SUBST-CURR-CNT TO lsSubstCurrCnt.

           EXIT METHOD.

       END METHOD getSubstCurrCnt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSubstGuarCnt.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.

       01  lsSubstGuarCnt         PIC S9(09) COMP-5.

       PROCEDURE DIVISION RETURNING lsSubstGuarCnt.

           MOVE WDISQ-SUBST-GUAR-CNT TO lsSubstGuarCnt.

           EXIT METHOD.

       END METHOD getSubstGuarCnt.


       END OBJECT.

       END CLASS ODISQUOT.
