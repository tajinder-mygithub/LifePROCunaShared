       IDENTIFICATION DIVISION.
       CLASS-ID.      OHLTHCAL AS "LPNETAPI.OHLTHCAL".
022703*AUTHOR.        PDMA.
022703*DATE-WRITTEN.  JAN 2008.
022703*DATE-COMPILED.
      *@**20150101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2015 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20150101*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D Benefit Amount API
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
      *H
022108*H 20070806-001-01 KAM New object program
062708*H 20080714-004-01 JWS Revise to set up run unit and caching
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
060810*H 20100301-001-01 JWS Add accum days, allow neg remaining days
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
111411*H 20110621-005-01 DAR Add Inflation output properties
021012*H 20111122-003-01 JWS Add Inflation Adjustment values. 
021512*H 20111122-003-01 JWS Add Daily and Lifetime NFO flags.
052512*H 20111117-006-01 DAR Retrofit 20110621-005-01. 
020113*H 20121210-001-01 DAR Return Benefit Code table  
052113*H 20121101-001-01 DAR Shared Care Enhancement
052413*H 20121101-001-08 DAR Shared Care Additional Enhancements
070113*H 20130311-003-01 DAR Add additional values by benefit sequence.  
070113*H                     Also, restructured code to call a driver 
070113*H                     program (PHLTHAPI) to do all work previously 
070113*H                     done here.  
120413*H 20131014-002-01 DAR Restore repaired policy caching.
051115*H 20140318-009-01 JWS Recompiled as part of retrofit.
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
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       COPY WWSCRCPY.

070113*01  LINKED-POLICY-FLAG                   PIC X(01).
070113*    88  NO-LINKED-POLICY                 VALUE 'N'.
070113*    88  LINKED-POLICY-FOUND              VALUE 'Y'.


092308 01  WS-PROGRAM-INFO.
120413     05  PFILEBTV           PIC X(08) VALUE 'PFILEBTV'.
070513*    05  PHLTHCAL           PIC X(08) VALUE 'PHLTHCAL'.
070513*    05  PCBENINT           PIC X(08) VALUE 'PCBENINT'.
070513     05  PHLTHAPI           PIC X(08) VALUE 'PHLTHAPI'.

           COPY WGLOBCPY.
070113*    COPY WPGLBCPY.
           COPY WGLBXCPY.
070113*    COPY WHLTCCPY.
070113*    COPY WCINTCPY.
070113*    COPY WCLNKCPY.
120413     COPY WAPPLCPY.
120413     COPY WBTRVCPY.
070113*    COPY WSHPLCPY.
070113     COPY WHLTACPY.

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

       01  wsReturnCode        PIC S9(09) COMP-5.
       01  wsErrorMessage      PIC X(200).
       01  wsUserType          PIC X(10) VALUE SPACES.

      ******************************************************************
       LINKAGE SECTION.

       01  lsApp                USAGE OBJECT REFERENCE OAPPLICA.
       01  lsUserType           USAGE OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsApp, lsUserType.

      *-----------------------------------------------------------------
062708
062708*    Start a NetCOBOL run unit here, so that resources are 
062708*    preserved until JMPCINT3 is called in Dispose.  
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

062708* initiate caching for run unit.
111411*    Test:  This API has been performing best without small table caching, per recent testing - Nov 2011
111411*    SET WGLOB-BATCH-CACHING        TO TRUE.

120413*    Policy caching was not setup correctly here.  Note the missing "ALL".        
020113*    SET WGLOB-USE-POLICY-APP-CACHE TO TRUE.
020113*    MOVE 'Y'                       TO WGLOB-APP-CACHE-FILES.
020113*    MOVE 'N'                       TO WGLOB-APP-CACHE-BEHAVIOR.

120413     SET WGLOB-USE-POLICY-APP-CACHE TO TRUE
120413     MOVE ALL 'Y'                   TO WGLOB-APP-CACHE-FILES.
120413     MOVE ALL 'N'                   TO WGLOB-APP-CACHE-BEHAVIOR.


           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to LpErrorMessage
           ELSE
               MOVE SPACES TO LpErrorMessage
           END-IF.

       END METHOD NEW.

      ******************************************************************
       METHOD-ID. Dispose.
      *  Dispose will free any resources, for now just the Coder ID.
      *  It will act as a destructor, but must be explictly called.
      ******************************************************************
      ******************************************************************
       DATA DIVISION.
      ******************************************************************

       WORKING-STORAGE SECTION.

       01  wsReturnCode        PIC S9(09) COMP-5.
       01  wsErrorMessage      PIC X(200).

      ******************************************************************
       LINKAGE SECTION.

      ******************************************************************
       PROCEDURE DIVISION.

      *-----------------------------------------------------------------

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

020113*    SET WGLOB-CLEAR-BATCH-CACHING    TO TRUE.
120413     SET WGLOB-CLEAR-POLICY-APP-CACHE TO TRUE.
120413     MOVE ZERO                        TO DATA-FILE-NUMBER.
120413
120413     TRY
120413         CALL PFILEBTV USING WGLOBAL
120413                             WAPPL-CALL-PARAMETERS
120413                             WBTRIEVE
120413     CATCH WS-EXCEPTION
120413         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
120413         MOVE 8008 TO wsReturnCode,
120413                      LpReturnCode
120413         MOVE 'Unexpected Abend in API - see Windows Event Log'
120413             TO LpErrorMessage
120413     END-TRY.
120413
062708* cancel persistent COBOL run unit     
092308*     CALL JMPCINT3.

       END METHOD Dispose.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunQuote.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.

      *-----------------------------------------------------------------


021709     TRY
070513         CALL PHLTHAPI USING WGLOBAL
021709                             WHLTA-PARAMETERS
               MOVE WHLTA-RETURN-CODE   TO LpReturnCode
               MOVE WHLTA-ERROR-MESSAGE TO LpErrorMessage
               MOVE WHLTA-RETURN-CODE   TO lsReturnCode
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

070513*    SET WCINT-RETRIEVE-LAST TO TRUE.
070513*    INITIALIZE WCLNK-PARAMETERS.
070513*
070513*    TRY
070513*        CALL PCBENINT USING WGLOBAL
070513*                            WCLNK-PARAMETERS
070513*                            WCINT-PARAMETERS
070513*    CATCH
070513*        INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
070513*        MOVE 8008 TO lsReturnCode,
070513*                     LpReturnCode
070513*        MOVE 'Unexpected Abend in API - see Windows Event Log'
070513*            TO LpErrorMessage
070513*    END-TRY.
070513*
070513*    SET NO-LINKED-POLICY TO TRUE
070513*
070513*    IF  WHLTC-LINKED-POL-INT-TERM
070513*    OR  WHLTC-LINKED-POL-EXT-TERM
070513*        INITIALIZE WSHPL-KEY
070513*        MOVE WHLTC-COMPANY-CODE     TO WSHPL-COMPANY-CODE
070513*        MOVE WHLTC-POLICY-NUMBER    TO WSHPL-POLICY-NUMBER
070513*        MOVE WHLTC-EFFEC-DATE       TO WSHPL-EFFECTIVE-DATE
070513*        MOVE WBTRV-GET-LESS-EQUAL   TO WAPPL-FUNCTION
070513*        MOVE WSHPL-DATA-RECORD      TO DATA-AREA
070513*        MOVE WFILE-SHPL-NUM         TO DATA-FILE-NUMBER
070513*        MOVE ZERO                   TO WAPPL-KEY-NUMBER
070513*
070513*
070513*        TRY
070513*            CALL PFILEBTV USING WGLOBAL
070513*                                WAPPL-CALL-PARAMETERS
070513*                                WBTRIEVE
070513*        CATCH
070513*            INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
070513*            MOVE 8008 TO lsReturnCode,
070513*                         LpReturnCode
070513*            MOVE
070513*             'Unexpected Abend in API - see Windows Event Log'
070513*               TO LpErrorMessage
070513*        END-TRY
070513*
070513*        IF WBTRV-RETURN-CODE = ZERO
070513*            MOVE DATA-AREA TO WSHPL-DATA-RECORD
070513*            IF WSHPL-COMPANY-CODE = WHLTC-COMPANY-CODE
070513*            AND WSHPL-POLICY-NUMBER = WHLTC-POLICY-NUMBER
070513*            AND WSHPL-REVERSED-FLAG NOT = 'Y'
070513*                SET LINKED-POLICY-FOUND TO TRUE
070513*            END-IF
070513*        END-IF
070513*    END-IF.

       END METHOD RunQuote.

      ******************************************************************

      ******************************************************************
      * Get methods.
      * These get and set methods take as input, and provide as output,
      * types that are part of the Common Language Runtime.
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision
      * floating point, and CLASS-STRING maps to String.  This allows
      * these get/set methods to be used in VB, C# and in COBOL.NET.
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

      *-----------------------------------------------------------------

           SET WHLTA-COMPANY-CODE to lsCompanyCode.

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

      *-----------------------------------------------------------------

           SET WHLTA-POLICY-NUMBER to lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setBenefitSeq.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsBenefitSeq                 PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBenefitSeq.

      *-----------------------------------------------------------------

           MOVE lsBenefitSeq TO WHLTA-BENEFIT-SEQ.

           EXIT METHOD.

       END METHOD setBenefitSeq.

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

      *-----------------------------------------------------------------

           MOVE lsEffectiveDate TO WHLTA-EFFEC-DATE.

           EXIT METHOD.

       END METHOD setEffectiveDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setBenefitCode.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsBenefitCode    OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBenefitCode.

      *-----------------------------------------------------------------

           SET WHLTA-BENEFIT-CODE to lsBenefitCode.

           EXIT METHOD.

       END METHOD setBenefitCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getReturnCode.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.

      *-----------------------------------------------------------------

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

      *-----------------------------------------------------------------

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpErrorMessage
                RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInsCount.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsInsCount                   PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsInsCount.

      *-----------------------------------------------------------------

           MOVE WHLTA-LAST-INS-ENTRY TO lsInsCount.
           EXIT METHOD.

       END METHOD getInsCount.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getNameID.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                      PIC S9(09) COMP-5.
       01 lsNameID                     PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsNameID.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsNameID
           ELSE
               MOVE WHLTA-CLAIMANT-NAME-ID (lsIndex)
                 TO lsNameID
           END-IF.

           EXIT METHOD.

       END METHOD getNameID.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getName.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsName                  OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsName.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsName
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WHLTA-CLAIMANT-NAME (lsIndex)
               RETURNING lsName
           END-IF.

           EXIT METHOD.

       END METHOD getName.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitCode.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsBenefitCode           OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsBenefitCode.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsBenefitCode
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WHLTA-BEN-BENEFIT-CODE (lsIndex)
               RETURNING lsBenefitCode
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitDesc.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsBenefitDesc           OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsBenefitDesc.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsBenefitDesc
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WHLTA-BEN-BENEFIT-CODE-DESC (lsIndex)
               RETURNING lsBenefitDesc
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitDesc.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitAmount.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsBenefitAmount          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsBenefitAmount.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsBenefitAmount
           ELSE
               MOVE WHLTA-HEALTH-QUOTE-DAILY-BEN (lsIndex)
                 TO lsBenefitAmount.

           EXIT METHOD.

       END METHOD getBenefitAmount.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getAccumClaimPayments.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsAccumClaimPayments     USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAccumClaimPayments.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsAccumClaimPayments
           ELSE
               MOVE WHLTA-HEALTH-QUOTE-ACCUM-PAYMT (lsIndex)
                 TO lsAccumClaimPayments.

           EXIT METHOD.

       END METHOD getAccumClaimPayments.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getTransferredBenefitAmount.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsIndex                        PIC S9(09) COMP-5.
052113 01 lsTransferredBenefitAmount     USAGE COMP-2.
052113
052113******************************************************************
052113 PROCEDURE DIVISION USING BY VALUE lsIndex
052113                    RETURNING lsTransferredBenefitAmount.
052113
052113*-----------------------------------------------------------------
052113
052113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
052113         MOVE ZERO TO lsTransferredBenefitAmount
052113     ELSE
052113         MOVE WHLTA-HQ-TRANS-BEN-AMT  (lsIndex)
052113           TO lsTransferredBenefitAmount.
052113
052113     EXIT METHOD.
052113
052113 END METHOD getTransferredBenefitAmount.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getSharedBenefitRemaining.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsIndex                        PIC S9(09) COMP-5.
052113 01 lsSharedBenefitRemaining       USAGE COMP-2.
052113
052113******************************************************************
052113 PROCEDURE DIVISION USING BY VALUE lsIndex
052113                    RETURNING lsSharedBenefitRemaining.
052113
052113*-----------------------------------------------------------------
052113
052113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
052113         MOVE ZERO TO lsSharedBenefitRemaining
052113     ELSE
052113         IF WHLTA-LINKED-POL-INTERNAL
052113             ADD WHLTA-HEALTH-QUOTE-REMAIN-LIFE (lsIndex)
052113                 WHLTA-LINKED-BENEFIT-AMT
052113               TO lsSharedBenefitRemaining
052113         ELSE
052113             MOVE ZERO TO lsSharedBenefitRemaining
052113         END-IF
052113     END-IF
052113
052113     EXIT METHOD.
052113
052113 END METHOD getSharedBenefitRemaining.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getLinkedPolicyType.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsLinkedPolicyType             OBJECT REFERENCE CLASS-STRING.
052113
052113******************************************************************
052113 PROCEDURE DIVISION RETURNING lsLinkedPolicyType.
052113
052113*-----------------------------------------------------------------
052113
052113     IF WHLTA-LINKED-POL-INTERNAL
052113     OR WHLTA-LINKED-POL-INT-TERM
052113     OR WHLTA-LINKED-POL-INT-NOT-FOUND
052113         SET lsLinkedPolicyType TO 'I'
052113     ELSE
052113         IF WHLTA-LINKED-POL-EXTERNAL OR
052113            WHLTA-LINKED-POL-EXT-TERM
052113            SET lsLinkedPolicyType TO 'E'
052113         ELSE
052113              SET lsLinkedPolicyType TO ' '
052113         END-IF
052113     END-IF
052113
052113     EXIT METHOD.
052113
052113 END METHOD getLinkedPolicyType.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getLinkedCompanyCode.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsLinkedCompanyCode            OBJECT REFERENCE CLASS-STRING.
052113
052113******************************************************************
052113 PROCEDURE DIVISION RETURNING lsLinkedCompanyCode.
052113
052113*-----------------------------------------------------------------
052113
052113     SET lsLinkedCompanyCode TO WHLTA-LINKED-COMPANY-CODE.
052113
052113     EXIT METHOD.
052113
052113 END METHOD getLinkedCompanyCode.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getLinkedPolicyNumber.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsLinkedPolicyNumber           OBJECT REFERENCE CLASS-STRING.
052113
052113******************************************************************
052113 PROCEDURE DIVISION RETURNING lsLinkedPolicyNumber.
052113
052113*-----------------------------------------------------------------
052113
052113     SET lsLinkedPolicyNumber TO WHLTA-LINKED-POLICY-NUMBER.
052113
052113     EXIT METHOD.
052113
052113 END METHOD getLinkedPolicyNumber.

052113******************************************************************
052113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052113******************************************************************
052113 METHOD-ID. getLinkedPolicyStatus.
052113 DATA DIVISION.
052113
052113******************************************************************
052113 WORKING-STORAGE SECTION.
052113
052113******************************************************************
052113 LINKAGE SECTION.
052113
052113 01 lsLinkedPolicyStatus           OBJECT REFERENCE CLASS-STRING.
052113
052113******************************************************************
052113 PROCEDURE DIVISION RETURNING lsLinkedPolicyStatus.
052113
052113*-----------------------------------------------------------------
052113
052113     SET lsLinkedPolicyStatus TO ' '.
052113     IF WHLTA-LINKED-POL-INTERNAL
052113     OR WHLTA-LINKED-POL-INT-NOT-FOUND
052113     OR WHLTA-LINKED-POL-EXTERNAL
052113         SET lsLinkedPolicyStatus TO 'A'
052113     ELSE
052113         IF WHLTA-LINKED-POL-INT-TERM
052113         OR WHLTA-LINKED-POL-EXT-TERM
052113             IF WHLTA-LINKED-POLICY-FOUND AND
052113                WHLTA-LINKED-POLICY-STATUS = 'D'
052113                 SET lsLinkedPolicyStatus TO 'D'
052113             ELSE
052113                 SET lsLinkedPolicyStatus TO 'T'
052113             END-IF
052113         END-IF
052113     END-IF
052113
052113     EXIT METHOD.
052113
052113 END METHOD getLinkedPolicyStatus.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getRemainLifeMax.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsRemainLifeMax          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsRemainLifeMax.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsRemainLifeMax
           ELSE
               MOVE WHLTA-HEALTH-QUOTE-REMAIN-LIFE (lsIndex)
                 TO lsRemainLifeMax.

           EXIT METHOD.

       END METHOD getRemainLifeMax.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getRemainLifeDaysFlag.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsRemainLifeDaysFlag       OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsRemainLifeDaysFlag.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsRemainLifeDaysFlag
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WHLTA-HEALTH-QUOTE-REMAIN-FLAG (lsIndex)
               RETURNING lsRemainLifeDaysFlag
           END-IF.

           EXIT METHOD.

       END METHOD getRemainLifeDaysFlag.

060810******************************************************************
060810*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
060810******************************************************************
060810 METHOD-ID. getAccumLifeDays.
060810 DATA DIVISION.
060810
060810******************************************************************
060810 WORKING-STORAGE SECTION.
060810
060810******************************************************************
060810 LINKAGE SECTION.
060810
060810 01 lsIndex                  PIC S9(09) COMP-5.
060810 01 lsAccumLifeDays         USAGE COMP-2.
060810
060810******************************************************************
060810 PROCEDURE DIVISION USING BY VALUE lsIndex
060810                    RETURNING lsAccumLifeDays.
060810
060810*-----------------------------------------------------------------
060810
060810     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
060810         MOVE ZERO TO lsAccumLifeDays
060810     ELSE
060810         MOVE WHLTA-HEALTH-QUOTE-ACCUM-DAYS (lsIndex)
060810           TO lsAccumLifeDays.
060810
060810     EXIT METHOD.
060810
060810 END METHOD getAccumLifeDays.
060810
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getRemainLifeDays.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsRemainLifeDays         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsRemainLifeDays.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsRemainLifeDays
           ELSE
               MOVE WHLTA-HEALTH-QUOTE-REMAIN-DAYS (lsIndex)
                 TO lsRemainLifeDays.

           EXIT METHOD.

       END METHOD getRemainLifeDays.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

111411 METHOD-ID. getBenInflateSelectDescription.
111411 DATA DIVISION.
111411
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                               PIC S9(09) COMP-5.
111411 01 lsBenInflateSelectDescription   OBJECT REFERENCE CLASS-STRING.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsBenInflateSelectDescription.
111411
111411*-----------------------------------------------------------------
111411
111411     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
111411         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
111411              RETURNING lsBenInflateSelectDescription
111411     ELSE
111411         INVOKE CLASS-STRING "NEW" USING
111411             BY VALUE WHLTA-HQ-KD-SEL-DESC (lsIndex)
111411         RETURNING lsBenInflateSelectDescription
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenInflateSelectDescription.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getBenInflateSelectState.
111411 DATA DIVISION.
111411
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                               PIC S9(09) COMP-5.
111411 01 lsBenInflateSelectState  OBJECT REFERENCE CLASS-STRING.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsBenInflateSelectState.
111411
111411*-----------------------------------------------------------------
111411
111411     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
111411         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
111411              RETURNING lsBenInflateSelectState
111411     ELSE
111411         INVOKE CLASS-STRING "NEW" USING
111411             BY VALUE WHLTA-HQ-STATE (lsIndex)
111411         RETURNING lsBenInflateSelectState
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenInflateSelectState.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getBenInflateDailyRate.
111411 DATA DIVISION.
111411
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                               PIC S9(09) COMP-5.
111411 01 lsBenInflateDailyRate                 USAGE COMP-2.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsBenInflateDailyRate.
111411
111411*-----------------------------------------------------------------
111411
111411     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
111411         MOVE ZERO TO lsBenInflateDailyRate
111411     ELSE
111411         MOVE WHLTA-HQ-DAILY-INFL-RATE (lsIndex)
111411           TO lsBenInflateDailyRate
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenInflateDailyRate.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
111411
111411 METHOD-ID. getBenInflateLifetimeRate.
111411 DATA DIVISION.
111411
111411******************************************************************
111411 WORKING-STORAGE SECTION.
111411
111411******************************************************************
111411 LINKAGE SECTION.
111411
111411 01 lsIndex                                  PIC S9(09) COMP-5.
111411 01 lsBenAllocatedReserve                 USAGE COMP-2.
111411
111411******************************************************************
111411 PROCEDURE DIVISION USING BY VALUE lsIndex
111411                    RETURNING lsBenAllocatedReserve.
111411
111411*-----------------------------------------------------------------
111411
111411     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
111411         MOVE ZERO TO lsBenAllocatedReserve
111411     ELSE
111411         MOVE WHLTA-HQ-LIFE-INFL-RATE (lsIndex)
111411           TO lsBenAllocatedReserve
111411     END-IF.
111411
111411     EXIT METHOD.
111411
111411 END METHOD getBenInflateLifetimeRate.
111411
111411******************************************************************
111411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111411******************************************************************
021412 METHOD-ID. getDailyNFOFlag.
021412 DATA DIVISION.
021412
021412******************************************************************
021412 WORKING-STORAGE SECTION.
021412
021412******************************************************************
021412 LINKAGE SECTION.
021412
021412 01  lsIndex                 PIC S9(09) COMP-5.
021412 01  lsDailyNFOFlag       OBJECT REFERENCE CLASS-STRING.
021412
021412******************************************************************
021412 PROCEDURE DIVISION Using BY VALUE lsIndex
021412                    RETURNING lsDailyNFOFlag.
021412
021412*-----------------------------------------------------------------
021412
021412     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021412         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
021412              RETURNING lsDailyNFOFlag
021412     ELSE
021412         INVOKE CLASS-STRING "NEW" USING
021412             BY VALUE WHLTA-INF-DMB-NFO (lsIndex)
021412         RETURNING lsDailyNFOFlag
021412     END-IF.
021412
021412     EXIT METHOD.
021412
021412 END METHOD getDailyNFOFlag.
021412
021412******************************************************************
021412*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021412******************************************************************
021412 METHOD-ID. getLifeNFOFlag.
021412 DATA DIVISION.
021412
021412******************************************************************
021412 WORKING-STORAGE SECTION.
021412
021412******************************************************************
021412 LINKAGE SECTION.
021412
021412 01  lsIndex                 PIC S9(09) COMP-5.
021412 01  lsLifeNFOFlag           OBJECT REFERENCE CLASS-STRING.
021412
021412******************************************************************
021412 PROCEDURE DIVISION Using BY VALUE lsIndex
021412                    RETURNING lsLifeNFOFlag.
021412
021412*-----------------------------------------------------------------
021412
021412     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021412         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
021412              RETURNING lsLifeNFOFlag
021412     ELSE
021412         INVOKE CLASS-STRING "NEW" USING
021412             BY VALUE WHLTA-INF-LMB-NFO (lsIndex)
021412         RETURNING lsLifeNFOFlag
021412     END-IF.
021412
021412     EXIT METHOD.
021412
021412 END METHOD getLifeNFOFlag.
021412
021412******************************************************************
021412*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021412******************************************************************
021412
021012 METHOD-ID. getBenAdjCount.
021012 DATA DIVISION.
021012
021012******************************************************************
021012 WORKING-STORAGE SECTION.
021012
021012******************************************************************
021012 LINKAGE SECTION.
021012
021012 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenAdjCount                            PIC S9(09) COMP-5.
021012
021012******************************************************************
021012 PROCEDURE DIVISION USING BY VALUE lsIndex
021012                    RETURNING lsBenAdjCount.
021012
021012*-----------------------------------------------------------------
021012
021012     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021012         MOVE ZERO TO lsBenAdjCount
021012     ELSE
021012         MOVE WHLTA-INF-LAST-ENTRY (lsIndex)
021012             TO lsBenAdjCount
021012     END-IF.
021012
021012     EXIT METHOD.
021012
021012 END METHOD getBenAdjCount.
021012
021012******************************************************************
021012*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021012******************************************************************
021012
021012 METHOD-ID. getBenSeq.
021012 DATA DIVISION.
021012
021012******************************************************************
021012 WORKING-STORAGE SECTION.
021012
021012******************************************************************
021012 LINKAGE SECTION.
021012
021012 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenIndex                               PIC S9(09) COMP-5.
021012 01 lsBenSeq                                 PIC S9(09) COMP-5.
021012
021012******************************************************************
021012 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
021012                    RETURNING lsBenSeq.
021012
021012*-----------------------------------------------------------------
021012
021012     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021012         MOVE ZERO TO lsBenSeq
021012     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenSeq
021012         ELSE
021012             MOVE WHLTA-INF-BEN-SEQ (lsIndex, lsBenIndex)
021012                                TO lsBenSeq
021012         END-IF
021012     END-IF.
021012
021012     EXIT METHOD.
021012
021012 END METHOD getBenSeq.
021012
021012******************************************************************
021012*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021012******************************************************************
021012
021012 METHOD-ID. getBenIssueDate.
021012 DATA DIVISION.
021012
021012******************************************************************
021012 WORKING-STORAGE SECTION.
021012
021012******************************************************************
021012 LINKAGE SECTION.
021012
021012 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenIndex                               PIC S9(09) COMP-5.
021012 01 lsBenIssueDate                           PIC S9(09) COMP-5.
021012
021012******************************************************************
021012 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
021012                    RETURNING lsBenIssueDate.
021012
021012*-----------------------------------------------------------------
021012
021012     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021012         MOVE ZERO TO lsBenIssueDate
021012     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenIssueDate
021012         ELSE
021012             MOVE WHLTA-INF-BEN-ISSUE-DATE (lsIndex, lsBenIndex)
021012                                   TO lsBenIssueDate
021012         END-IF
021012     END-IF.
021012
021012     EXIT METHOD.
021012
021012 END METHOD getBenIssueDate.
021012
021012******************************************************************
021012*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021012******************************************************************
021012
021012 METHOD-ID. getBenDMBAdj.
021012 DATA DIVISION.
021012
021012******************************************************************
021012 WORKING-STORAGE SECTION.
021012
021012******************************************************************
021012 LINKAGE SECTION.
021012
021012 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenIndex                               PIC S9(09) COMP-5.
021012 01 lsBenDMBAdj                              USAGE COMP-2.
021012
021012******************************************************************
021012 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
021012                    RETURNING lsBenDMBAdj.
021012
021012*-----------------------------------------------------------------
021012
021012     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021012         MOVE ZERO TO lsBenDMBAdj
021012     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenDMBAdj
021012         ELSE
021012             MOVE WHLTA-INF-BEN-DMB-ADJ (lsIndex, lsBenIndex)
021012                                   TO lsBenDMBAdj
021012         END-IF
021012     END-IF.
021012
021012     EXIT METHOD.
021012
021012 END METHOD getBenDMBAdj.
021012
021012******************************************************************
021012*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021012******************************************************************
021012
021012 METHOD-ID. getBenLMBAdj.
021012 DATA DIVISION.
021012
021012******************************************************************
021012 WORKING-STORAGE SECTION.
021012
021012******************************************************************
021012 LINKAGE SECTION.
021012
021012 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenIndex                               PIC S9(09) COMP-5.
021012 01 lsBenLMBAdj                              USAGE COMP-2.
021012
021012******************************************************************
021012 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
021012                    RETURNING lsBenLMBAdj.
021012
021012*-----------------------------------------------------------------
021012
021012     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
021012         MOVE ZERO TO lsBenLMBAdj
021012     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenLMBAdj
021012         ELSE
021012             MOVE WHLTA-INF-BEN-LMB-ADJ (lsIndex, lsBenIndex)
021012                                   TO lsBenLMBAdj
021012         END-IF
021012     END-IF.
021012
021012     EXIT METHOD.
021012
021012 END METHOD getBenLMBAdj.
021012
021012******************************************************************
021012*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021012******************************************************************
070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenAllocatedReserve.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                               PIC S9(09) COMP-5.
070113 01 lsBenIndex                            PIC S9(09) COMP-5.
070113 01 lsBenAllocatedReserve                 USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenAllocatedReserve.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenAllocatedReserve
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenAllocatedReserve
021012         ELSE
070113             MOVE WHLTA-ALLOCATED-RESERVE (lsIndex, lsBenIndex)
070113               TO lsBenAllocatedReserve
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenAllocatedReserve.

070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenPortfolioRate.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                            PIC S9(09) COMP-5.
070113 01 lsBenIndex                         PIC S9(09) COMP-5.
070113 01 lsBenPortfolioRate                 USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenPortfolioRate.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenPortfolioRate
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenPortfolioRate
070113         ELSE
070113             MOVE WHLTA-PORTFOLIO-RATE (lsIndex, lsBenIndex)
070113                 TO lsBenPortfolioRate
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenPortfolioRate.

070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenGuaranteeRate.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                            PIC S9(09) COMP-5.
070113 01 lsBenIndex                         PIC S9(09) COMP-5.
070113 01 lsBenGuaranteeRate                 USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenGuaranteeRate.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenGuaranteeRate
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenGuaranteeRate
070113         ELSE
070113             MOVE WHLTA-GUARANTEE-RATE (lsIndex, lsBenIndex)
070113               TO lsBenGuaranteeRate
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenGuaranteeRate.

070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenPriorNegativeCredit.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                            PIC S9(09) COMP-5.
070113 01 lsBenIndex                         PIC S9(09) COMP-5.
070113 01 lsBenPriorNegativeCredit           USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenPriorNegativeCredit.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenPriorNegativeCredit
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenPriorNegativeCredit
070113         ELSE
070113             MOVE WHLTA-PRIOR-NEG-CREDIT (lsIndex, lsBenIndex)
070113                 TO lsBenPriorNegativeCredit
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenPriorNegativeCredit.

070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenExcessEarnings.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                               PIC S9(09) COMP-5.
021012 01 lsBenIndex                            PIC S9(09) COMP-5.
070113 01 lsBenExcessEarnings                   USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenExcessEarnings.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenExcessEarnings
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenExcessEarnings
021012         ELSE
070113             MOVE WHLTA-EXCESS-EARNINGS (lsIndex, lsBenIndex)
070113               TO lsBenExcessEarnings
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenExcessEarnings.


070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenNetSinglePremPerDollar.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                              PIC S9(09) COMP-5.
021012 01 lsBenIndex                           PIC S9(09) COMP-5.
070113 01 lsBenNetSinglePremPerDollar       USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenNetSinglePremPerDollar.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenNetSinglePremPerDollar
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenNetSinglePremPerDollar
021012         ELSE
070113             MOVE WHLTA-SINGLE-PREM-DOLLAR  (lsIndex, lsBenIndex)
070113                 TO lsBenNetSinglePremPerDollar
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenNetSinglePremPerDollar.

070113******************************************************************
070113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
070113******************************************************************
070113
070113 METHOD-ID. getBenAutomaticBenefitIncrease.
070113 DATA DIVISION.
070113
070113******************************************************************
070113 WORKING-STORAGE SECTION.
070113
070113******************************************************************
070113 LINKAGE SECTION.
070113
070113 01 lsIndex                                  PIC S9(09) COMP-5.
021012 01 lsBenIndex                               PIC S9(09) COMP-5.
070113 01 lsBenAutomaticBenefitIncrease            USAGE COMP-2.
070113
070113******************************************************************
070113 PROCEDURE DIVISION USING BY VALUE lsIndex, lsBenIndex
070113                    RETURNING lsBenAutomaticBenefitIncrease.
070113
070113*-----------------------------------------------------------------
070113
070113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
070113         MOVE ZERO TO lsBenAutomaticBenefitIncrease
070113     ELSE
021012         IF lsBenIndex < 1
021012         OR lsBenIndex > WHLTA-INF-LAST-ENTRY (lsIndex)
021012             MOVE ZERO TO lsBenAutomaticBenefitIncrease
021012         ELSE
070113             MOVE WHLTA-AUTO-BEN-INCREASE  (lsIndex, lsBenIndex)
070113                 TO lsBenAutomaticBenefitIncrease
070113         END-IF
070113     END-IF.
070113
070113     EXIT METHOD.
070113
070113 END METHOD getBenAutomaticBenefitIncrease.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************




       METHOD-ID. getBenErrorCode.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                      PIC S9(09) COMP-5.
       01 lsBenErrorCode               PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsBenErrorCode.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               MOVE ZERO TO lsBenErrorCode
           ELSE
               MOVE WHLTA-BEN-RETURN-CODE (lsIndex)
                 TO lsBenErrorCode
           END-IF.

           EXIT METHOD.

       END METHOD getBenErrorCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenErrorMessage.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsBenErrorMessage       OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsBenErrorMessage.

      *-----------------------------------------------------------------

           IF lsIndex < 1 OR lsIndex > WHLTA-LAST-INS-ENTRY
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsBenErrorMessage
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WHLTA-BEN-ERROR-MESSAGE (lsIndex)
               RETURNING lsBenErrorMessage
           END-IF.

           EXIT METHOD.

       END METHOD getBenErrorMessage.


       METHOD-ID. getEffectiveDateUsed.
       DATA DIVISION.

      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01 lsEffectiveDateUsed          PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDateUsed.

      *-----------------------------------------------------------------

           MOVE WHLTA-EFFEC-DATE-USED TO lsEffectiveDateUsed.

           EXIT METHOD.

       END METHOD getEffectiveDateUsed.



      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
020113 METHOD-ID. getBenefitTableCount.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01 lsBenTabCount                   PIC S9(09) COMP-5.
020113
020113******************************************************************
020113 PROCEDURE DIVISION RETURNING lsBenTabCount.
020113
020113*-----------------------------------------------------------------
020113
020113     MOVE WHLTA-LAST-BEN-CODE-ENTRY  TO lsBenTabCount.
020113     EXIT METHOD.
020113
020113 END METHOD getBenefitTableCount.
020113
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************

020113*  All of the following "BenTab" prefixed properties provide access
020113*  to a full list of benefit codes and related data items.  These 
020113*  will be served up in the API as a DataTable or similar structure. 

020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabBenefitCode.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                   PIC S9(09) COMP-5.
020113 01  lsBenTabBenefitCode       OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabBenefitCode.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabBenefitCode TO ' '
020113     ELSE
020113         SET lsBenTabBenefitCode
020113                TO WHLTA-BEN-TAB-BENEFIT-CODE (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabBenefitCode.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabGroupID.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                   PIC S9(09) COMP-5.
020113 01  lsBenTabGroupID       OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabGroupID.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabGroupID TO ' '
020113     ELSE
020113         SET lsBenTabGroupID
020113              TO WHLTA-ACCUM-GROUP-ID (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabGroupID.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabBenefitSeq.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                   PIC S9(09) COMP-5.
020113 01  lsBenTabBenefitSeq        PIC S9(04) COMP-5.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabBenefitSeq.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         MOVE ZERO TO lsBenTabBenefitSeq
020113     ELSE
020113         MOVE WHLTA-BEN-BENEFIT-SEQ (lsIndex)
020113                    TO lsBenTabBenefitSeq
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabBenefitSeq.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabAccumFlag.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                   PIC S9(09) COMP-5.
020113 01  lsBenTabAccumFlag         OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabAccumFlag.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabAccumFlag TO ' '
020113     ELSE
020113         SET lsBenTabAccumFlag
020113              TO WHLTA-ACCUM-FLAG (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabAccumFlag.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabCalcRule.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                   PIC S9(09) COMP-5.
020113 01  lsBenTabCalcRule         OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabCalcRule.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabCalcRule TO ' '
020113     ELSE
020113         SET lsBenTabCalcRule
020113              TO WHLTA-CALC-RULE  (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabCalcRule.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabDefaultDescription.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                      PIC S9(09) COMP-5.
020113 01  lsBenTabDefaultDescription   OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabDefaultDescription.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabDefaultDescription TO ' '
020113     ELSE
020113         SET lsBenTabDefaultDescription
020113              TO WHLTA-DFLT-DESC (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabDefaultDescription.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabEOBDescription.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                  PIC S9(09) COMP-5.
020113 01  lsBenTabEOBDescription   OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabEOBDescription.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabEOBDescription TO ' '
020113     ELSE
020113         SET lsBenTabEOBDescription
020113              TO WHLTA-EOB-DESC (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabEOBDescription.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabDaysCalcFlag.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                  PIC S9(09) COMP-5.
020113 01  lsBenTabDaysCalcFlag   OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabDaysCalcFlag.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabDaysCalcFlag TO ' '
020113     ELSE
020113         SET lsBenTabDaysCalcFlag
020113              TO WHLTA-DAYS-CALC-FLAG (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabDaysCalcFlag.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabDaysCalcDesc.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                PIC S9(09) COMP-5.
020113 01  lsBenTabDaysCalcDesc   OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabDaysCalcDesc.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabDaysCalcDesc TO ' '
020113     ELSE
020113         SET lsBenTabDaysCalcDesc
020113              TO WHLTA-DAYS-CALC-DESC (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabDaysCalcDesc.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabPTDEdit.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                PIC S9(09) COMP-5.
020113 01  lsBenTabPTDEdit        OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabPTDEdit.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabPTDEdit TO ' '
020113     ELSE
020113         SET lsBenTabPTDEdit
020113              TO WHLTA-PTD-EDIT (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabPTDEdit.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabRestoreBenFlag.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                PIC S9(09) COMP-5.
020113 01  lsBenTabRestoreBenFlag        OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabRestoreBenFlag.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabRestoreBenFlag TO ' '
020113     ELSE
020113         SET lsBenTabRestoreBenFlag
020113              TO WHLTA-RESTORE-BEN-FLAG (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabRestoreBenFlag.
020113
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabWaitPeriodFlag.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                       PIC S9(09) COMP-5.
020113 01  lsBenTabWaitPeriodFlag        OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabWaitPeriodFlag.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabWaitPeriodFlag TO ' '
020113     ELSE
020113         SET lsBenTabWaitPeriodFlag
020113              TO WHLTA-WAIT-PERIOD-FLAG (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabWaitPeriodFlag.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabWaitPeriodDuration.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                       PIC S9(09) COMP-5.
020113 01  lsBenTabWaitPeriodDuration    PIC S9(04) COMP-5.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabWaitPeriodDuration.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         MOVE ZERO TO lsBenTabWaitPeriodDuration
020113     ELSE
020113         MOVE WHLTA-WAIT-PERIOD-DUR (lsIndex)
020113             TO lsBenTabWaitPeriodDuration
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabWaitPeriodDuration.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabWaitPeriodMessageNum.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                         PIC S9(09) COMP-5.
020113 01  lsBenTabWaitPeriodMessageNum    PIC S9(09) COMP-5.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabWaitPeriodMessageNum.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         MOVE ZERO TO lsBenTabWaitPeriodMessageNum
020113     ELSE
020113         MOVE WHLTA-WAIT-PERIOD-MSG (lsIndex)
020113             TO lsBenTabWaitPeriodMessageNum
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabWaitPeriodMessageNum.
020113******************************************************************
020113*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
020113******************************************************************
020113 METHOD-ID. getBenTabType.
020113 DATA DIVISION.
020113
020113******************************************************************
020113 WORKING-STORAGE SECTION.
020113
020113******************************************************************
020113 LINKAGE SECTION.
020113
020113 01  lsIndex                       PIC S9(09) COMP-5.
020113 01  lsBenTabType                  OBJECT REFERENCE CLASS-STRING.
020113
020113******************************************************************
020113 PROCEDURE DIVISION Using BY VALUE lsIndex
020113                    RETURNING lsBenTabType.
020113
020113*-----------------------------------------------------------------
020113
020113     IF lsIndex < 1 OR lsIndex > WHLTA-LAST-BEN-CODE-ENTRY
020113         SET lsBenTabType TO ' '
020113     ELSE
020113         SET lsBenTabType
020113              TO WHLTA-TYPE (lsIndex)
020113     END-IF.
020113
020113     EXIT METHOD.
020113
020113 END METHOD getBenTabType.

       END OBJECT.
       END CLASS OHLTHCAL.

