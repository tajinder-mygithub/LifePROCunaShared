       IDENTIFICATION DIVISION.
       CLASS-ID.      OMULTDVR AS "LPNETAPI.OMULTDVR".
022703*AUTHOR.        PDMA.
022703*DATE-WRITTEN.  JAN 2008.
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
      *D Health Requote (Multi-Insured) API
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
      *H 20020327-005-01 JWS New object program.
022508*H 20070806-003-01 JWS Health Requote API
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
053110*H 20100204-002-01 DAR Health Requote enhancements. 
071811*H 20110202-002-01 DAR Revisions for New Policy Health Quote 
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
111411*H 20110621-005-01 DAR Enhancements to quote benefit changes
052512*H 20111117-006-01 DAR Retrofit 20110621-005-01 and 20110202-002-01
032113*H 20130307-007-01 DAR Fixes related to v17 and merge of above SR's. 
121213*H 20131114-004-01 DAR Revise caching to work best given current test results.  
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
092308     05  PMULTDVR           PIC X(08)  VALUE 'PMULTDVR'.
053110     05  PFILEBTV           PIC X(08)  VALUE 'PFILEBTV'.
           COPY WGLOBCPY.
           COPY WPGLBCPY.
           COPY WGLBXCPY.
           COPY WHRQTCPY.
053110     COPY WAPPLCPY.
053110     COPY WBTRVCPY.

      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpReturnCode               PIC S9(09) COMP-5.
       01  LpErrorMessage             PIC X(200).

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
121213*    SET WGLOB-BATCH-CACHING TO TRUE.
053110     SET WGLOB-USE-POLICY-APP-CACHE TO TRUE.
053110     MOVE ALL 'Y' TO WGLOB-APP-CACHE-FILES.
053110     MOVE ALL 'N' TO WGLOB-APP-CACHE-BEHAVIOR.

053110*    Setting this Glob field allows temporary MUIN, PBEN, and RELA
053110*    to be created in their own 'temp' cache, handled by program 
053110*    PTEMPPOL.  These temporary records are never saved to DB.  
053110*    Note that temp records have a company code of high values, 
053110*    which will match WGLOB-TEMP-CACHE-COMPANY-CODE, and indicate 
053110*    to PFILEBTV that temporary cache should be used.  
053110
053110     MOVE HIGH-VALUES TO WGLOB-TEMP-CACHE-COMPANY-CODE.
053110
053110*    False updates against temp records should not update history.  
053110     SET BYPASS-HISTORY-ALWAYS TO TRUE.

053110*    This flag will suppress age related edits in processing.  
053110     SET WGLOB-API-NO-AGE-EDITS TO TRUE

      *    If Login Attempt was unsuccessful, place results in 
      *    return code and message properties. 
           MOVE wsReturnCode to LpReturnCode.

           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to LpErrorMessage
           ELSE
               MOVE SPACES TO LpErrorMessage
           END-IF.

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
               MOVE SPACES TO LpErrorMessage
           END-IF.


053110     MOVE SPACES TO WGLOB-TEMP-CACHE-COMPANY-CODE
053110                    WGLOB-HISTORY-ALWAYS-FLAG
053110                    WGLOB-API-LIMIT-EDITS-FLAG

121213*    SET WGLOB-CLEAR-BATCH-CACHING TO TRUE
053110     SET WGLOB-CLEAR-POLICY-APP-CACHE TO TRUE

053110     MOVE ZERO TO DATA-FILE-NUMBER
053110
053110     TRY
053110         CALL PFILEBTV USING WGLOBAL
053110                             WAPPL-CALL-PARAMETERS
053110                             WBTRIEVE
053110     CATCH WS-EXCEPTION
053110         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
053110         MOVE 8008 TO wsReturnCode
053110         MOVE 'Unexpected Abend in API - see Windows Event Log'
053110             TO LpErrorMessage
053110     END-TRY.

       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunRequote.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           MOVE WHRQT-MI-NAME-ID(1, 1) TO WHRQT-NAME-ID.

071811*    If no function is set, assume benefit add, for backwards 
071811*    compatibility with code written before New Policy quotes were
071811*    added.         
071811     IF (WHRQT-FUNCTION = SPACES)
052512         SET WHRQT-API-EXISTING-POLC TO TRUE.
071811*    SET WHRQT-FULL-PROCESS      TO TRUE.

021709     TRY
092308         CALL PMULTDVR USING WGLOBAL
092308                             GLOBAL-PARAMETERS
021709                             WHRQT-PARAMETERS
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE ZEROS TO WHRQT-RETURN-MSG-NUMBER
021709         MOVE 8008  TO WHRQT-RETURN-STATUS
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WHRQT-RETURN-MSG
021709     END-TRY.

           IF WHRQT-RETURN-STATUS NOT = ZERO
               MOVE ZEROES TO WHRQT-RETURN-POL-PREM-TOTL
                              WHRQT-RETURN-QT-POL-TOTAL
           END-IF.

           MOVE WHRQT-RETURN-STATUS TO LpReturnCode.
           MOVE WHRQT-RETURN-MSG    TO LpErrorMessage.
           MOVE WHRQT-RETURN-STATUS TO lsReturnCode.

       END METHOD RunRequote.


111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. LoadExistingBenefits.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsReturnCode                PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION RETURNING lsReturnCode.
111411******************************************************************
111411
111411     SET WHRQT-READ              TO TRUE.
111411
111411     TRY
111411         CALL PMULTDVR USING WGLOBAL
111411                             GLOBAL-PARAMETERS
111411                             WHRQT-PARAMETERS
111411     CATCH WS-EXCEPTION
111411         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
111411         MOVE ZEROS TO WHRQT-RETURN-MSG-NUMBER
111411         MOVE 8008  TO WHRQT-RETURN-STATUS
111411         MOVE 'Unexpected Abend in API - see Windows Event Log'
111411             TO WHRQT-RETURN-MSG
111411     END-TRY.
111411
111411     MOVE WHRQT-RETURN-STATUS TO LpReturnCode.
111411     MOVE WHRQT-RETURN-MSG    TO LpErrorMessage.
111411     MOVE WHRQT-RETURN-STATUS TO lsReturnCode.
111411
111411 END METHOD  LoadExistingBenefits.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. LoadWithTarget.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411 01  lsReturnCode                PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION RETURNING lsReturnCode.
111411******************************************************************
111411
111411     SET WHRQT-LOAD-WITH-TARGET  TO TRUE.
111411
111411     TRY
111411         CALL PMULTDVR USING WGLOBAL
111411                             GLOBAL-PARAMETERS
111411                             WHRQT-PARAMETERS
111411     CATCH WS-EXCEPTION
111411         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
111411         MOVE ZEROS TO WHRQT-RETURN-MSG-NUMBER
111411         MOVE 8008  TO WHRQT-RETURN-STATUS
111411         MOVE 'Unexpected Abend in API - see Windows Event Log'
111411             TO WHRQT-RETURN-MSG
111411     END-TRY.
111411
111411     MOVE WHRQT-RETURN-STATUS TO LpReturnCode.
111411     MOVE WHRQT-RETURN-MSG    TO LpErrorMessage.
111411     MOVE WHRQT-RETURN-STATUS TO lsReturnCode.
111411
111411 END METHOD  LoadWithTarget.
111411
      ******************************************************************
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEffectiveDateUsed.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsEffectiveDateUsed        PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDateUsed.
      ******************************************************************

           MOVE WHRQT-EFFECTIVE-DATE TO lsEffectiveDateUsed.

           EXIT METHOD.

       END METHOD getEffectiveDateUsed.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getLifePROMessageNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsLifePROMessageNumber        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLifePROMessageNumber.
      ******************************************************************

           MOVE WHRQT-RETURN-MSG-NUMBER TO lsLifePROMessageNumber.

           EXIT METHOD.

       END METHOD getLifePROMessageNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCurrPolcTotal.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsCurrPolcTotal        USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCurrPolcTotal.
      ******************************************************************

           MOVE WHRQT-RETURN-POL-PREM-TOTL TO lsCurrPolcTotal.

           EXIT METHOD.

       END METHOD getCurrPolcTotal.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getQuotePolcTotal.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsQuotePolcTotal        USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsQuotePolcTotal.
      ******************************************************************

           MOVE WHRQT-RETURN-QT-POL-TOTAL TO lsQuotePolcTotal.

           EXIT METHOD.

       END METHOD getQuotePolcTotal.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getModalPremiumDescription.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411
111411
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                    PIC S9(09) COMP-5.
111411 01 lsModalPremiumDescription
111411                    USAGE OBJECT REFERENCE CLASS-STRING.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsModalPremiumDescription.
111411******************************************************************
111411
111411     IF lsIndex > 0 AND lsIndex NOT > WHRQT-PREM-DESC-MAX
111411         SET lsModalPremiumDescription
111411                 TO WHRQT-RETURN-MODAL-DESC (lsIndex)
111411     ELSE
111411         SET lsModalPremiumDescription TO ' '
111411     END-IF
111411
111411     EXIT METHOD.
111411
111411 END METHOD getModalPremiumDescription.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getModalPremiumCode.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                    PIC S9(09) COMP-5.
111411 01 lsModalPremiumCode
111411                    USAGE OBJECT REFERENCE CLASS-STRING.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsModalPremiumCode.
111411******************************************************************
111411
111411     IF lsIndex > 0 AND lsIndex NOT > WHRQT-PREM-DESC-MAX
111411         SET lsModalPremiumCode
111411                 TO WHRQT-RETURN-MODAL-CODE  (lsIndex)
111411     ELSE
111411         SET lsModalPremiumCode TO ' '
111411     END-IF
111411
111411     EXIT METHOD.
111411
111411 END METHOD getModalPremiumCode.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getModalPremiumAmount.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                    PIC S9(09) COMP-5.
111411 01 lsModalPremiumAmount       USAGE COMP-2.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsModalPremiumAmount.
111411******************************************************************
111411
111411     IF lsIndex > 0 AND lsIndex NOT > WHRQT-PREM-DESC-MAX
111411         MOVE WHRQT-RETURN-MODAL-AMOUNT (lsIndex)
111411             TO lsModalPremiumAmount
111411     ELSE
111411         MOVE ZERO TO lsModalPremiumAmount
111411     END-IF
111411
111411     EXIT METHOD.
111411
111411 END METHOD getModalPremiumAmount.

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

           INVOKE CLASS-STRING "NEW" USING BY VALUE WHRQT-RETURN-MSG
                RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.

      ******************************************************************
111411* Input property set and get methods.  
111411* The "get" methods below are typically required by the 
111411* LoadExistingBenefits call, which loads the input properties 
111411* for an existing policy.  
      ******************************************************************
071811 METHOD-ID. setFunction.
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01 lsFunction            OBJECT REFERENCE CLASS-STRING.
071811
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsFunction.
071811******************************************************************
071811
071811*    Valid values at this time are 'N' for new policy, or 
071811*    'B' for Benefit Add.  
071811     SET WHRQT-FUNCTION to lsFunction.
071811
071811     EXIT METHOD.
071811
071811 END METHOD setFunction.

      ******************************************************************
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
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

           SET WHRQT-COMPANY-CODE to lsCompanyCode.

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

           SET WHRQT-POLICY-NUMBER to lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEffectiveDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsEffectiveDate              PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.
      ******************************************************************

           MOVE lsEffectiveDate TO WHRQT-EFFECTIVE-DATE.

           EXIT METHOD.

       END METHOD setEffectiveDate.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. setBenefitRequest.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex         PIC S9(09) COMP-5.
111411 01  lsBenefitRequest    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          BY VALUE lsBenefitRequest.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         CONTINUE
111411     ELSE
111411         SET WHRQT-BEN-REQUEST (lsIndex) to lsBenefitRequest
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setBenefitRequest.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getBenefitRequest.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex             PIC S9(09) COMP-5.
111411 01  lsBenefitRequest    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsBenefitRequest.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsBenefitRequest TO ' '
111411     ELSE
111411         SET lsBenefitRequest TO WHRQT-BEN-REQUEST (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenefitRequest.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. setTargetBenefitCode.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex                PIC S9(09) COMP-5.
111411 01  lsTargetBenefitCode    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          BY VALUE lsTargetBenefitCode.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-TARGET-MAX
111411         CONTINUE
111411     ELSE
111411         SET WHRQT-TARGET-BENEFIT-CODE (lsIndex)
111411                     TO lsTargetBenefitCode
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setTargetBenefitCode.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getTargetBenefitCode.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.

111411 01  lsIndex                PIC S9(09) COMP-5.
111411 01  lsTargetBenefitCode    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsTargetBenefitCode.
111411******************************************************************

032113*    IF lsIndex < 1 OR lsIndex >  10
032113     IF lsIndex < 1 OR lsIndex > WHRQT-TARGET-MAX
111411         SET lsTargetBenefitCode TO ' '
111411     ELSE
111411         SET lsTargetBenefitCode
111411                 TO WHRQT-TARGET-BENEFIT-CODE (lsIndex)
111411     END-IF.

111411     EXIT METHOD.

111411 END METHOD getTargetBenefitCode.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. setTargetMaxBenefit.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex                PIC S9(09) COMP-5.
111411 01  lsTargetMaxBenefit            USAGE COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          BY VALUE lsTargetMaxBenefit.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-TARGET-MAX
111411         CONTINUE
111411     ELSE
111411         MOVE lsTargetMaxBenefit
111411                 TO WHRQT-TARGET-DAILY-BEN (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setTargetMaxBenefit.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getTargetMaxBenefit.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex                PIC S9(09) COMP-5.
111411 01  lsTargetMaxBenefit            USAGE COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsTargetMaxBenefit.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex >  10
111411         MOVE ZERO TO lsTargetMaxBenefit
111411     ELSE
111411         MOVE WHRQT-TARGET-DAILY-BEN (lsIndex)
111411             TO lsTargetMaxBenefit
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getTargetMaxBenefit.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. setBenefitSequence.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1                  PIC S9(09) COMP-5.
111411 01  lsBenefitSequence         PIC S9(04) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsBenefitSequence.
111411******************************************************************
111411
111411     IF lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         CONTINUE
111411     ELSE
111411         MOVE lsBenefitSequence
111411             TO  WHRQT-SEQ (lsIndex1)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setBenefitSequence.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getBenefitSequence.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1                  PIC S9(09) COMP-5.
111411 01  lsBenefitSequence         PIC S9(04) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          RETURNING lsBenefitSequence
111411******************************************************************
111411
111411     IF lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         MOVE ZERO TO lsBenefitSequence
111411     ELSE
111411         MOVE WHRQT-SEQ (lsIndex1)
111411             TO lsBenefitSequence
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenefitSequence.
071811******************************************************************
071811*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
071811******************************************************************
071811 METHOD-ID. setProductID.
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01 lsProductID              OBJECT REFERENCE CLASS-STRING.
071811
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsProductID.
071811******************************************************************
071811
071811     SET WHRQT-PRODUCT-ID TO lsProductID
071811
071811     EXIT METHOD.
071811
071811 END METHOD setProductID.
071811
071811******************************************************************
071811*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
071811******************************************************************
071811 METHOD-ID. setBillingForm
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01 lsBillingForm              OBJECT REFERENCE CLASS-STRING.
071811
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsBillingForm
071811******************************************************************
071811
071811     SET WHRQT-BILLING-FORM TO lsBillingForm
071811
071811     EXIT METHOD.
071811
071811 END METHOD setBillingForm.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setCoverageID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex         PIC S9(09) COMP-5.
       01  lsCoverageID    OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsCoverageID.
      ******************************************************************

111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               SET WHRQT-COVR (lsIndex) to lsCoverageID
           END-IF.

           EXIT METHOD.

       END METHOD setCoverageID.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getCoverageID.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex         PIC S9(09) COMP-5.
111411 01  lsCoverageID    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsCoverageID.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsCoverageID TO ' '
111411     ELSE
111411         SET lsCoverageID TO WHRQT-COVR (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getCoverageID.
111411
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. setBenefitType.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex          PIC S9(09) COMP-5.
111411 01  lsBenefitType    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          BY VALUE lsBenefitType.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         CONTINUE
111411     ELSE
111411         SET WHRQT-TYPE (lsIndex) to lsBenefitType
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setBenefitType.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getBenefitType.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex         PIC S9(09) COMP-5.
111411 01  lsBenefitType    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsBenefitType.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsBenefitType TO ' '
111411     ELSE
111411         SET lsBenefitType TO WHRQT-TYPE (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenefitType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setValuePerUnit.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                           PIC S9(09) COMP-5.
       01  lsValuePerUnit                    COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsValuePerUnit.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsValuePerUnit TO WHRQT-VALUE-PER-UNIT (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setValuePerUnit.

      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getValuePerUnit.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                           PIC S9(09) COMP-5.
       01  lsValuePerUnit                    COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                RETURNING lsValuePerUnit.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               MOVE ZERO TO lsValuePerUnit
           ELSE
               MOVE WHRQT-VALUE-PER-UNIT (lsIndex)
                         TO lsValuePerUnit
           END-IF.

           EXIT METHOD.

       END METHOD getValuePerUnit.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. setUnitsOrFaceFlag.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex          PIC S9(09) COMP-5.
111411 01  lsUnitsOrFaceFlag    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          BY VALUE lsUnitsOrFaceFlag.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         CONTINUE
111411     ELSE
111411         SET WHRQT-UNITS-FACE-FLAG (lsIndex) to lsUnitsOrFaceFlag
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setUnitsOrFaceFlag.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getUnitsOrFaceFlag.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex         PIC S9(09) COMP-5.
111411 01  lsUnitsOrFaceFlag    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsUnitsOrFaceFlag.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsUnitsOrFaceFlag TO ' '
111411     ELSE
111411         SET lsUnitsOrFaceFlag TO WHRQT-UNITS-FACE-FLAG (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getUnitsOrFaceFlag.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUnits.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex         PIC S9(09) COMP-5.
       01  lsUnits                    COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsUnits.
      ******************************************************************

111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsUnits TO WHRQT-QT-FACE (lsIndex)
           END-IF.

           EXIT METHOD.

       END METHOD setUnits.

111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411 METHOD-ID. getUnits.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex         PIC S9(09) COMP-5.
111411 01  lsUnits                    COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsUnits.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsUnits
111411     ELSE
111411         MOVE WHRQT-QT-FACE (lsIndex)
111411                   TO lsUnits
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getUnits.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setNameID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsNameID         PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsNameID.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsNameID
                   TO WHRQT-MI-NAME-ID (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setNameID.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getNameID.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsNameID         PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsNameID
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         MOVE ZERO TO lsNameID
111411     ELSE
111411         MOVE WHRQT-MI-NAME-ID (lsIndex1, lsIndex2)
111411             TO lsNameID
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getNameID.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUWCLS.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsUWCLS          OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsUWCLS.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               SET WHRQT-UWCLS (lsIndex1, lsIndex2)
                   TO lsUWCLS
           END-IF.

           EXIT METHOD.

       END METHOD setUWCLS.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getUWCLS.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsUWCLS          OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsUWCLS.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411        SET lsUWCLS TO ' '
111411     ELSE
111411         SET lsUWCLS
111411              TO WHRQT-UWCLS (lsIndex1, lsIndex2)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getUWCLS.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

071811 METHOD-ID. setSex.
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01  lsIndex1         PIC S9(09) COMP-5.
071811 01  lsIndex2         PIC S9(09) COMP-5.
071811 01  lsSex            OBJECT REFERENCE CLASS-STRING.
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsIndex1
071811                          BY VALUE lsIndex2
071811                          BY VALUE lsSex.
071811******************************************************************
071811
032113*    IF lsIndex2 < 1 OR lsIndex2 > 20
032113*    OR lsIndex1 < 1 OR lsIndex1 > 14
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
071811*        If they provide an invalid index, just ignore the change.        
071811         CONTINUE
071811     ELSE
071811         SET WHRQT-SEX (lsIndex1, lsIndex2)
071811             TO lsSex
071811     END-IF.
071811
071811     EXIT METHOD.
071811
071811 END METHOD setSex.
071811
032113******************************************************************
032113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032113******************************************************************
032113
032113 METHOD-ID. getSex.
032113 DATA DIVISION.
032113******************************************************************
032113 WORKING-STORAGE SECTION.
032113******************************************************************
032113 LINKAGE SECTION.
032113
032113 01  lsIndex1         PIC S9(09) COMP-5.
032113 01  lsIndex2         PIC S9(09) COMP-5.
032113 01  lsSex            OBJECT REFERENCE CLASS-STRING.
032113******************************************************************
032113 PROCEDURE DIVISION USING BY VALUE lsIndex1
032113                          BY VALUE lsIndex2
032113                          RETURNING lsSex.
032113******************************************************************
032113
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
032113         SET lsSex TO ' '
032113     ELSE
032113         SET lsSex TO WHRQT-SEX (lsIndex1, lsIndex2)
032113     END-IF.
032113
032113     EXIT METHOD.
032113
032113 END METHOD getSex.
032113
071811******************************************************************
071811*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
071811******************************************************************
071811
071811 METHOD-ID. setDOB.
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01  lsIndex1         PIC S9(09) COMP-5.
071811 01  lsIndex2         PIC S9(09) COMP-5.
071811 01  lsDOB      PIC S9(09) COMP-5.
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsIndex1
071811                          BY VALUE lsIndex2
071811                          BY VALUE lsDOB.
071811******************************************************************
071811
032113*    IF lsIndex2 < 1 OR lsIndex2 > 20
032113*    OR lsIndex1 < 1 OR lsIndex1 > 14
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
071811*        If they provide an invalid index, just ignore the change.        
071811         CONTINUE
071811     ELSE
071811         MOVE lsDOB
071811             TO WHRQT-DOB (lsIndex1, lsIndex2)
071811     END-IF.
071811
071811     EXIT METHOD.
071811
071811 END METHOD setDOB.
032113
032113******************************************************************
032113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032113******************************************************************
032113
032113 METHOD-ID. getDOB.
032113 DATA DIVISION.
032113******************************************************************
032113 WORKING-STORAGE SECTION.
032113******************************************************************
032113 LINKAGE SECTION.
032113
032113 01  lsIndex1         PIC S9(09) COMP-5.
032113 01  lsIndex2         PIC S9(09) COMP-5.
032113 01  lsDOB            PIC S9(09) COMP-5.
032113******************************************************************
032113 PROCEDURE DIVISION USING BY VALUE lsIndex1
032113                          BY VALUE lsIndex2
032113                          RETURNING lsDOB.
032113******************************************************************
032113
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
032113         MOVE ZERO TO lsDOB
032113     ELSE
032113         MOVE WHRQT-DOB (lsIndex1, lsIndex2) TO lsDOB
032113     END-IF.
032113
032113     EXIT METHOD.
032113
032113 END METHOD getDOB.
032113
071811******************************************************************
071811*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
071811******************************************************************
071811
071811 METHOD-ID. setIssueAge.
071811 DATA DIVISION.
071811******************************************************************
071811 WORKING-STORAGE SECTION.
071811******************************************************************
071811 LINKAGE SECTION.
071811
071811 01  lsIndex1         PIC S9(09) COMP-5.
071811 01  lsIndex2         PIC S9(09) COMP-5.
071811 01  lsIssueAge            PIC S9(09) COMP-5.
071811******************************************************************
071811 PROCEDURE DIVISION USING BY VALUE lsIndex1
071811                          BY VALUE lsIndex2
071811                          BY VALUE lsIssueAge.
071811******************************************************************
071811
032113*    IF lsIndex2 < 1 OR lsIndex2 > 20
032113*    OR lsIndex1 < 1 OR lsIndex1 > 14
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
071811*        If they provide an invalid index, just ignore the change.        
071811         CONTINUE
071811     ELSE
071811         MOVE lsIssueAge
071811             TO WHRQT-ISSUE-AGE (lsIndex1, lsIndex2)
071811     END-IF.
071811
071811     EXIT METHOD.
071811
071811 END METHOD setIssueAge.
032113******************************************************************
032113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032113******************************************************************
032113
032113 METHOD-ID. getIssueAge.
032113 DATA DIVISION.
032113******************************************************************
032113 WORKING-STORAGE SECTION.
032113******************************************************************
032113 LINKAGE SECTION.
032113
032113 01  lsIndex1              PIC S9(09) COMP-5.
032113 01  lsIndex2              PIC S9(09) COMP-5.
032113 01  lsIssueAge            PIC S9(09) COMP-5.
032113******************************************************************
032113 PROCEDURE DIVISION USING BY VALUE lsIndex1
032113                          BY VALUE lsIndex2
032113                          RETURNING lsIssueAge.
032113******************************************************************
032113
032113     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
032113     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
032113         MOVE ZERO TO lsIssueAge
032113     ELSE
032113         MOVE WHRQT-ISSUE-AGE (lsIndex1, lsIndex2)
032113                                TO lsIssueAge
032113     END-IF.
032113
032113     EXIT METHOD.
032113
032113 END METHOD getIssueAge.
032113
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAgeRateUp.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsAgeRateUp      PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsAgeRateUp.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsAgeRateUp
                   TO WHRQT-AGE-RATE-UP (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setAgeRateUp.


111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getAgeRateUp.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsAgeRateUp      PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsAgeRateUp.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         MOVE ZERO TO lsAgeRateUp
111411     ELSE
111411         MOVE WHRQT-AGE-RATE-UP (lsIndex1, lsIndex2)
111411             TO lsAgeRateUp
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getAgeRateUp.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setTableRating.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsTableRating    OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsTableRating.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               SET WHRQT-TABLE-RATING (lsIndex1, lsIndex2)
                   TO lsTableRating
           END-IF.

           EXIT METHOD.

       END METHOD setTableRating.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getTableRating.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsTableRating    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsTableRating.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         SET lsTableRating TO ' '
111411     ELSE
111411         SET lsTableRating
111411             TO WHRQT-TABLE-RATING (lsIndex1, lsIndex2)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getTableRating.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setPCTRating.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsPCTRating                 COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsPCTRating.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsPCTRating
                   TO WHRQT-PCT-RATING (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setPCTRating.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getPCTRating.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsPCTRating                 COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsPCTRating.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         MOVE ZERO TO lsPCTRating
111411     ELSE
111411         MOVE WHRQT-PCT-RATING (lsIndex1, lsIndex2)
111411             TO lsPCTRating
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getPCTRating.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setPCTDuration.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsPCTDuration    PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsPCTDuration.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsPCTDuration
                   TO WHRQT-PCT-DURATION (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setPCTDuration.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getPCTDuration.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsPCTDuration    PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsPCTDuration.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsPCTDuration
111411     ELSE
111411         MOVE WHRQT-PCT-DURATION (lsIndex1, lsIndex2)
111411             TO lsPCTDuration
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getPCTDuration.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFlat.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsFlat                      COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsFlat.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsFlat
                   TO WHRQT-FLAT (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setFlat.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getFlat.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsFlat                      COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsFlat.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411         MOVE ZERO TO lsFlat
111411     ELSE
111411         MOVE WHRQT-FLAT (lsIndex1, lsIndex2)
111411             TO lsFlat
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getFlat.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFlatDuration.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsFlatDuration   PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsFlatDuration.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsFlatDuration
                   TO WHRQT-FLAT-DURATION (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setFlatDuration.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getFlatDuration.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsFlatDuration   PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsFlatDuration.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsFlatDuration
111411     ELSE
111411         MOVE WHRQT-FLAT-DURATION (lsIndex1, lsIndex2)
111411             TO lsFlatDuration
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getFlatDuration.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. set2ndFlat.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  ls2ndFlat                   COMP-2.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE ls2ndFlat.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE ls2ndFlat
                   TO WHRQT-2ND-FLAT (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD set2ndFlat.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. get2ndFlat.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  ls2ndFlat                   COMP-2.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING ls2ndFlat.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO ls2ndFlat
111411     ELSE
111411         MOVE WHRQT-2ND-FLAT (lsIndex1, lsIndex2)
111411             TO ls2ndFlat
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD get2ndFlat.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. set2ndFlatDur.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  ls2ndFlatDur     PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE ls2ndFlatDur.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE ls2ndFlatDur
                   TO WHRQT-2ND-FLAT-DUR (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD set2ndFlatDur.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. get2ndFlatDur.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  ls2ndFlatDur     PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING ls2ndFlatDur.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO ls2ndFlatDur
111411     ELSE
111411         MOVE WHRQT-2ND-FLAT-DUR (lsIndex1, lsIndex2)
111411             TO ls2ndFlatDur
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD get2ndFlatDur.



      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setExtendedKey.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsExtendedKey    OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsExtendedKey.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               SET WHRQT-EXTENDED-KEY (lsIndex1, lsIndex2)
                   TO lsExtendedKey
           END-IF.

           EXIT METHOD.

       END METHOD setExtendedKey.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getExtendedKey.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsExtendedKey    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsExtendedKey.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsExtendedKey TO ' '
111411     ELSE
111411         SET lsExtendedKey
111411             TO WHRQT-EXTENDED-KEY (lsIndex1, lsIndex2)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getExtendedKey.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. setExtendedKeyID.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsExtendedKeyID    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          BY VALUE lsExtendedKeyID.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         CONTINUE
111411     ELSE
111411         SET WHRQT-EXTENDED-KEY-ID (lsIndex1, lsIndex2)
111411             TO lsExtendedKeyID
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD setExtendedKeyID.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getExtendedKeyID.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsExtendedKeyID    OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsExtendedKeyID.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsExtendedKeyID TO ' '
111411     ELSE
111411         SET lsExtendedKeyID
111411             TO WHRQT-EXTENDED-KEY-ID (lsIndex1, lsIndex2)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getExtendedKeyID.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setState.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsState          OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsState.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               SET WHRQT-STATE (lsIndex1, lsIndex2)
                   TO lsState
           END-IF.

           EXIT METHOD.

       END METHOD setState.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getState.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsState          OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsState.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsState TO ' '
111411     ELSE
111411         SET lsState
111411             TO WHRQT-STATE (lsIndex1, lsIndex2)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getState.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAreaCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1         PIC S9(09) COMP-5.
       01  lsIndex2         PIC S9(09) COMP-5.
       01  lsAreaCode       PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                                BY VALUE lsAreaCode.
      ******************************************************************

111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
      *        If they provide an invalid index, just ignore the change.        
               CONTINUE
           ELSE
               MOVE lsAreaCode
                   TO WHRQT-AREA-CODE (lsIndex1, lsIndex2)
           END-IF.

           EXIT METHOD.

       END METHOD setAreaCode.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getAreaCode.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex1         PIC S9(09) COMP-5.
111411 01  lsIndex2         PIC S9(09) COMP-5.
111411 01  lsAreaCode       PIC S9(09) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex1
111411                          BY VALUE lsIndex2
111411                          RETURNING lsAreaCode.
111411******************************************************************
111411
111411     IF lsIndex2 < 1 OR lsIndex2 > WHRQT-INS-MAX
111411     OR lsIndex1 < 1 OR lsIndex1 > WHRQT-COV-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsAreaCode
111411     ELSE
111411         MOVE WHRQT-AREA-CODE (lsIndex1, lsIndex2)
111411             TO lsAreaCode
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getAreaCode.


111411*  The following "get" method properties return MUIN description and 
111411*  selection text information.  These are read only, are returned by 
111411*  the "LoadExistingBenefits" call (and LoadToTarget), and are only
111411*  returned for FYI.  They are not used in quote processing.        

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

111411 METHOD-ID. getKDExtendedKeyID.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex              PIC S9(09) COMP-5.
111411 01  lsKDExtendedKeyID     OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsKDExtendedKeyID.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-MUIN-EXPANSION-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsKDExtendedKeyID to ' '
111411     ELSE
111411         SET lsKDExtendedKeyID TO WHRQT-KDEF-KEY-ID (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getKDExtendedKeyID.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getKDEntryType.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex          PIC S9(09) COMP-5.
111411 01  lsKDEntryType     OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsKDEntryType.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-MUIN-EXPANSION-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsKDEntryType to ' '
111411     ELSE
111411         SET lsKDEntryType
111411              TO WHRQT-KDEF-ENTRY-TYPE (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getKDEntryType.


111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getKDEntrySequence.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex              PIC S9(09) COMP-5.
111411 01  lsKDEntrySequence     PIC S9(04) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsKDEntrySequence.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-MUIN-EXPANSION-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsKDEntrySequence
111411     ELSE
111411         MOVE WHRQT-KDEF-ENTRY-SEQ (lsIndex)
111411               TO lsKDEntrySequence
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getKDEntrySequence.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getKDParentDescription.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex               PIC S9(09) COMP-5.
111411 01  lsKDParentDescription     PIC S9(04) COMP-5.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsKDParentDescription.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-MUIN-EXPANSION-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         MOVE ZERO TO lsKDParentDescription
111411     ELSE
111411         MOVE WHRQT-KDEF-PARENT-DESC (lsIndex)
111411               TO lsKDParentDescription
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getKDParentDescription.

111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getKDEntryText.
111411 DATA DIVISION.
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01  lsIndex          PIC S9(09) COMP-5.
111411 01  lsKDEntryText     OBJECT REFERENCE CLASS-STRING.
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                          RETURNING lsKDEntryText.
111411******************************************************************
111411
111411     IF lsIndex < 1 OR lsIndex > WHRQT-MUIN-EXPANSION-MAX
111411*        If they provide an invalid index, just ignore the change.        
111411         SET lsKDEntryText to ' '
111411     ELSE
111411         SET lsKDEntryText
111411              TO WHRQT-KDEF-ENTRY-TEXT (lsIndex)
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getKDEntryText.


       END OBJECT.
       END CLASS OMULTDVR.

