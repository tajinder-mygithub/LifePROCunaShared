       IDENTIFICATION DIVISION.
       CLASS-ID. ODTHQUOT AS "LPNETAPI.ODTHQUOT".
      *AUTHOR.         Rigdon.
      *DATE-WRITTEN.   July 2008.
      *DATE-COMPILED.
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
      *D BAPI object that gets death quote information for a policy.
      *D Returns quote for an insured if name id is input, one benefit
      *D if benefit seq is input, or all insureds if name id and benefit
      *D seq is null.
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
071708*H 20070730-003-01 WAR New object program.
101008*H 20080402-003-01 JWS .NET testing error corrections  
102408*H 20070730-003-01 DAR Pass this object's results to Reprojection.
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
121213*H 20131114-004-01 DAR Revise caching to work best given current test results.  
032614*H 20140220-005-01 DAR Allow Future, Past and Terminated Policy Quoting
050814*H 20140220-006-01 DAR Add Joint Floor/Guaranteed Minimum Values
072114*H 20131208-001-01 TJO NFO Quoting Additions
041315*H 20140318-009-01 TJO Living Benefit Enhancement - Group B
042015*H 20140318-009-35 TJO Added more GWBN fields for Group B.
010617*H 20160315-003-01 JKG V19 clean up
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

101008 01  WS-PROGRAM-INFO.
101008     05  PDTHQUOT                PIC X(08) VALUE 'PDTHQUOT'.
101008     05  PFILEBTV                PIC X(08) VALUE 'PFILEBTV'.

032614 01  SAVE-INTERFACE-FLAG              PIC X(01).
032614 01  SAVE-FUTURE-REQUEST-FLAG         PIC X(01).
032614 01  SAVE-ORIG-FUTURE-REQUEST-FLAG    PIC X(01).

       COPY WWSCRCPY.

           COPY WGLOBCPY.
           COPY WAPPLCPY.
           COPY WBTRVCPY.
           COPY WGLBXCPY.
           COPY WDTQUCPY.
102408     COPY WPVALCPY.

      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpApp                USAGE OBJECT REFERENCE OAPPLICA.
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

121213*    SET WGLOB-BATCH-CACHING TO TRUE.
           SET WGLOB-USE-POLICY-APP-CACHE TO TRUE.
121213*    MOVE 'Y' TO WGLOB-APP-CACHE-FILES. 
121213     MOVE ALL 'Y' TO WGLOB-APP-CACHE-FILES.
121213*    MOVE 'N' TO WGLOB-APP-CACHE-BEHAVIOR. 
121213     MOVE ALL 'N' TO WGLOB-APP-CACHE-BEHAVIOR.

      *    If Login Attempt was unsuccessful, place results in
      *    return code and message properties.
           MOVE wsReturnCode              TO WDTQU-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage        TO WDTQU-ERROR-MESSAGE
           ELSE
               MOVE SPACES                TO WDTQU-ERROR-MESSAGE
           END-IF.

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
               MOVE wsErrorMessage          TO WDTQU-ERROR-MESSAGE
           ELSE
               MOVE SPACES                  TO WDTQU-ERROR-MESSAGE
           END-IF.

121213*    SET WGLOB-CLEAR-BATCH-CACHING    TO TRUE
           SET WGLOB-CLEAR-POLICY-APP-CACHE TO TRUE
           MOVE ZERO                        TO DATA-FILE-NUMBER

021709     TRY
101008         CALL PFILEBTV USING WGLOBAL
101008                             WAPPL-CALL-PARAMETERS
021709                             WBTRIEVE
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO wsReturnCode
021709                      WDTQU-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WDTQU-ERROR-MESSAGE
021709     END-TRY.

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
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

032614     MOVE WGLOB-INTERFACE-FLAG TO SAVE-INTERFACE-FLAG
032614     MOVE WGLOB-API-FUTURE-REQUEST-FLAG
032614                               TO SAVE-ORIG-FUTURE-REQUEST-FLAG
032614     SET WGLOB-API-DEATH-QUOTE TO TRUE
032614     MOVE SAVE-FUTURE-REQUEST-FLAG
032614                TO WGLOB-API-FUTURE-REQUEST-FLAG

021709     TRY
101008         CALL PDTHQUOT USING WGLOBAL
101008                             WDTQU-PARAMETERS
102408                             WPVAL-PARMS
               END-CALL
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO WDTQU-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WDTQU-ERROR-MESSAGE
021709     END-TRY.

032614     MOVE SAVE-INTERFACE-FLAG TO WGLOB-INTERFACE-FLAG
032614     MOVE SAVE-ORIG-FUTURE-REQUEST-FLAG
032614                              TO WGLOB-API-FUTURE-REQUEST-FLAG.

           MOVE WDTQU-RETURN-CODE      TO lsReturnCode.

           EXIT METHOD.

       END METHOD RunQuote.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

      ******************************************************************
       METHOD-ID. RetrieveParameters.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

      ******************************************************************
       LINKAGE SECTION.

       01  WPVAL-PARMS-X             PIC X(300000).

      ******************************************************************
       PROCEDURE DIVISION  RETURNING WPVAL-PARMS-X.

           MOVE WPVAL-PARMS TO WPVAL-PARMS-X.

           EXIT METHOD.

       END METHOD RetrieveParameters.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEffectiveDateUsed.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEffectiveDateUsed         PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDateUsed.
      ******************************************************************

           MOVE WDTQU-EFFECTIVE-DATE   TO lsEffectiveDateUsed.

           EXIT METHOD.

       END METHOD getEffectiveDateUsed.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLoanPrincipal.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsLoanPrincipal             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLoanPrincipal.
      ******************************************************************

           MOVE WDTQU-LOAN-PRINCIPAL   TO lsLoanPrincipal.

           EXIT METHOD.

       END METHOD getLoanPrincipal.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLoanInterest.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsLoanInterest              USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLoanInterest.
      ******************************************************************

           MOVE WDTQU-LOAN-INTEREST    TO lsLoanInterest.

           EXIT METHOD.

       END METHOD getLoanInterest.

041315******************************************************************
041315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041315******************************************************************
041315 METHOD-ID. getLoanWriteOff.
041315
041315******************************************************************
041315 DATA DIVISION.
041315******************************************************************
041315 WORKING-STORAGE SECTION.
041315******************************************************************
041315 LINKAGE SECTION.
041315
041315 01  lsLoanWriteOff              USAGE COMP-2.
041315
041315******************************************************************
041315 PROCEDURE DIVISION RETURNING lsLoanWriteOff.
041315******************************************************************
041315
041315     MOVE WDTQU-LOAN-WRITEOFF    TO lsLoanWriteOff.
041315
041315     EXIT METHOD.
041315
041315 END METHOD getLoanWriteOff.
041315
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLoanBalance.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsLoanBalance               USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLoanBalance.
      ******************************************************************

           MOVE WDTQU-LOAN-BALANCE     TO lsLoanBalance.

           EXIT METHOD.

       END METHOD getLoanBalance.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getUnappliedCash.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUnappliedCash             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUnappliedCash.
      ******************************************************************

           MOVE WDTQU-UNAPPLIED-CASH   TO lsUnappliedCash.

           EXIT METHOD.

       END METHOD getUnappliedCash.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getIba01Amt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIba01Amt                  USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIba01Amt.
      ******************************************************************

           MOVE WDTQU-IBA-01-AMOUNT    TO lsIba01Amt.

           EXIT METHOD.

       END METHOD getIba01Amt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getIba02Amt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIba02Amt                  USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIba02Amt.
      ******************************************************************

           MOVE WDTQU-IBA-02-AMOUNT    TO lsIba02Amt.

           EXIT METHOD.

       END METHOD getIba02Amt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getIba04Amt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIba04Amt                  USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIba04Amt.
      ******************************************************************

           MOVE WDTQU-IBA-04-AMOUNT    TO lsIba04Amt.

           EXIT METHOD.

       END METHOD getIba04Amt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getAdbFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAdbFaceAmt                USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAdbFaceAmt.
      ******************************************************************

           MOVE WDTQU-ADB-FACE-AMT     TO lsAdbFaceAmt.

           EXIT METHOD.

       END METHOD getAdbFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getFundTax.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFundTax                   USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFundTax.
      ******************************************************************

           MOVE WDTQU-FUND-TAX         TO lsFundTax.

           EXIT METHOD.

       END METHOD getFundTax.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getDeferedPremTax.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDeferedPremTax            USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsDeferedPremTax.
      ******************************************************************

           MOVE WDTQU-DEFERED-PREM-TAX TO lsDeferedPremTax.

           EXIT METHOD.

       END METHOD getDeferedPremTax.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getRefundPremTax.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRefundPremTax             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRefundPremTax.
      ******************************************************************

           MOVE WDTQU-REFUND-PREM-TAX  TO lsRefundPremTax.

           EXIT METHOD.

       END METHOD getRefundPremTax.

072114******************************************************************
072114*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
072114******************************************************************
072114 METHOD-ID. getReturnOfPremium.
072114
072114******************************************************************
072114 DATA DIVISION.
072114******************************************************************
072114 WORKING-STORAGE SECTION.
072114******************************************************************
072114 LINKAGE SECTION.
072114
072114 01  lsReturnOfPremium           USAGE COMP-2.
072114
072114******************************************************************
072114 PROCEDURE DIVISION RETURNING lsReturnOfPremium.
072114******************************************************************
072114
072114     MOVE WDTQU-ROP-AMOUNT TO lsReturnOfPremium.
072114
072114     EXIT METHOD.
072114
072114 END METHOD getReturnOfPremium.
072114
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getNumberOfInsureds.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNumberOfInsureds          PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNumberOfInsureds.
      ******************************************************************

           MOVE WDTQU-DB-MAX-INSURED   TO lsNumberOfInsureds.

           EXIT METHOD.

       END METHOD getNumberOfInsureds.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInsuredNameId.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsInsuredNameId             PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsInsuredNameId.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS                      TO lsInsuredNameId
           ELSE
               MOVE WDTQU-DB-NAME-ID (lsIndex) TO lsInsuredNameId
           END-IF.

           EXIT METHOD.

       END METHOD getInsuredNameId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInsuredRelateCode.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsInsuredRelateCode         OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsInsuredRelateCode.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsInsuredRelateCode
           ELSE
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE WDTQU-DB-RELA-CODE (lsIndex)
                        RETURNING lsInsuredRelateCode
           END-IF.

           EXIT METHOD.

       END METHOD getInsuredRelateCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInsuredRelateSeq.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsInsuredRelateSeq          PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsInsuredRelateSeq.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS                        TO lsInsuredRelateSeq
           ELSE
               MOVE WDTQU-DB-RELA-SEQ (lsIndex)  TO lsInsuredRelateSeq
           END-IF.

           EXIT METHOD.

       END METHOD getInsuredRelateSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotDeathBenefit.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotDeathBenefit           USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotDeathBenefit.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotDeathBenefit
           ELSE
               MOVE WDTQU-DB-TOT-DEATH-BENEFIT (lsIndex)
                 TO lsTotDeathBenefit
           END-IF.

           EXIT METHOD.

       END METHOD getTotDeathBenefit.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotFaceAmt                USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotFaceAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotFaceAmt
           ELSE
               MOVE WDTQU-DB-TOT-FACE-AMT (lsIndex)
                 TO lsTotFaceAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotPuaFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotPuaFaceAmt             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotPuaFaceAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotPuaFaceAmt
           ELSE
               MOVE WDTQU-DB-TOT-PUA-FACE-AMT (lsIndex)
                 TO lsTotPuaFaceAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotPuaFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotOytFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotOytFaceAmt             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotOytFaceAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotOytFaceAmt
           ELSE
               MOVE WDTQU-DB-TOT-OYT-FACE-AMT (lsIndex)
                 TO lsTotOytFaceAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotOytFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotEtiFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotEtiFaceAmt             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotEtiFaceAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotEtiFaceAmt
           ELSE
               MOVE WDTQU-DB-TOT-ETI-FACE-AMT (lsIndex)
                 TO lsTotEtiFaceAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotEtiFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotRpuFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotRpuFaceAmt             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotRpuFaceAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotRpuFaceAmt
           ELSE
               MOVE WDTQU-DB-TOT-RPU-FACE-AMT (lsIndex)
                 TO lsTotRpuFaceAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotRpuFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotDivAccums.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotDivAccums              USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotDivAccums.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotDivAccums
           ELSE
               MOVE WDTQU-DB-TOT-DIV-ACCUMS (lsIndex)
                 TO lsTotDivAccums
           END-IF.

           EXIT METHOD.

       END METHOD getTotDivAccums.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotDivAdjust.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotDivAdjust              USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotDivAdjust.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotDivAdjust
           ELSE
               MOVE WDTQU-DB-TOT-DIV-ADJUST (lsIndex)
                 TO lsTotDivAdjust
           END-IF.

           EXIT METHOD.

       END METHOD getTotDivAdjust.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotPremRefund.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotPremRefund             USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotPremRefund.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotPremRefund
           ELSE
               MOVE WDTQU-DB-TOT-PREM-REFUND (lsIndex)
                 TO lsTotPremRefund
           END-IF.

           EXIT METHOD.

       END METHOD getTotPremRefund.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotSpecifiedAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotSpecifiedAmt           USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotSpecifiedAmt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotSpecifiedAmt
           ELSE
               MOVE WDTQU-DB-TOT-SPECIFIED-AMT (lsIndex)
                 TO lsTotSpecifiedAmt
           END-IF.

           EXIT METHOD.

       END METHOD getTotSpecifiedAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotUlDeathBenefit.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotUlDeathBenefit         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotUlDeathBenefit.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotUlDeathBenefit
           ELSE
               MOVE WDTQU-DB-TOT-UL-DEATH-BEN (lsIndex)
                 TO lsTotUlDeathBenefit
           END-IF.

           EXIT METHOD.

       END METHOD getTotUlDeathBenefit.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotUlFundValue.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotUlFundValue            USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotUlFundValue.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotUlFundValue
           ELSE
               MOVE WDTQU-DB-TOT-UL-FUND-VALUE (lsIndex)
                 TO lsTotUlFundValue
           END-IF.

           EXIT METHOD.

       END METHOD getTotUlFundValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUlDeathBenefitOpt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsUlDeathBenefitOpt         OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsUlDeathBenefitOpt.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsUlDeathBenefitOpt
           ELSE
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE WDTQU-DB-UL-DB-OPT (lsIndex)
                        RETURNING lsUlDeathBenefitOpt
           END-IF.

           EXIT METHOD.

       END METHOD getUlDeathBenefitOpt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUlDeathBenefitOptDesc.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsUlDeathBenefitOptDesc     OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsUlDeathBenefitOptDesc.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsUlDeathBenefitOptDesc
           ELSE
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE WDTQU-DB-UL-DB-OPT-TEXT (lsIndex)
                        RETURNING lsUlDeathBenefitOptDesc
           END-IF.

           EXIT METHOD.

       END METHOD getUlDeathBenefitOptDesc.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTotArFundValue.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsTotArFundValue            USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTotArFundValue.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsTotArFundValue
           ELSE
               MOVE WDTQU-DB-TOT-AR-FUND-VALUE (lsIndex)
                 TO lsTotArFundValue
           END-IF.

           EXIT METHOD.

       END METHOD getTotArFundValue.

041315******************************************************************
041315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041315******************************************************************
041315
041315 METHOD-ID. getAnnuitizationBenefit.
041315
041315******************************************************************
041315 DATA DIVISION.
041315******************************************************************
041315 WORKING-STORAGE SECTION.
041315******************************************************************
041315 LINKAGE SECTION.
041315
041315 01  lsIndex                     PIC S9(09) COMP-5.
041315 01  lsAnnuitizationBenefit            USAGE COMP-2.
041315
041315******************************************************************
041315 PROCEDURE DIVISION USING BY VALUE lsIndex
041315                    RETURNING lsAnnuitizationBenefit.
041315******************************************************************
041315
041315     IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
041315         MOVE ZEROS
041315           TO lsAnnuitizationBenefit
041315     ELSE
041315         MOVE WDTQU-DB-GWBN-ANNUITIZ-AMT (lsIndex)
041315           TO lsAnnuitizationBenefit
041315     END-IF.
041315
041315     EXIT METHOD.
041315
041315 END METHOD getAnnuitizationBenefit.
041315
041315******************************************************************
041315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041315******************************************************************
041315
041315 METHOD-ID. getAnnuitizationAnnualAmt.
041315
041315******************************************************************
041315 DATA DIVISION.
041315******************************************************************
041315 WORKING-STORAGE SECTION.
041315******************************************************************
041315 LINKAGE SECTION.
041315
041315 01  lsIndex                     PIC S9(09) COMP-5.
041315 01  lsAnnuitizationAnnualAmt            USAGE COMP-2.
041315
041315******************************************************************
041315 PROCEDURE DIVISION USING BY VALUE lsIndex
041315                    RETURNING lsAnnuitizationAnnualAmt.
041315******************************************************************
041315
041315     IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
041315         MOVE ZEROS
041315           TO lsAnnuitizationAnnualAmt
041315     ELSE
041315         MOVE WDTQU-DB-GWBN-ANN-ANNUITIZ-AMT (lsIndex)
041315           TO lsAnnuitizationAnnualAmt
041315     END-IF.
041315
041315     EXIT METHOD.
041315
041315 END METHOD getAnnuitizationAnnualAmt.
041315
041315******************************************************************
041315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041315******************************************************************
041315
041315 METHOD-ID. getAnnuitizationNumberYears.
041315
041315******************************************************************
041315 DATA DIVISION.
041315******************************************************************
041315 WORKING-STORAGE SECTION.
041315******************************************************************
041315 LINKAGE SECTION.
041315
041315 01  lsIndex                     PIC S9(09) COMP-5.
041315 01  lsAnnuitizationNumberYears  PIC S9(09) COMP-5.
041315
041315******************************************************************
041315 PROCEDURE DIVISION USING BY VALUE lsIndex
041315                    RETURNING lsAnnuitizationNumberYears.
041315******************************************************************
041315
041315     IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
041315         MOVE ZEROS
041315           TO lsAnnuitizationNumberYears
041315     ELSE
041315         MOVE WDTQU-DB-GWBN-BY-OPTION-YEAR (lsIndex)
041315           TO lsAnnuitizationNumberYears
041315     END-IF.
041315
041315     EXIT METHOD.
041315
041315 END METHOD getAnnuitizationNumberYears.
041315
041315******************************************************************
041315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041315******************************************************************
041315
041315 METHOD-ID. getLumpSumBenefit.
041315
041315******************************************************************
041315 DATA DIVISION.
041315******************************************************************
041315 WORKING-STORAGE SECTION.
041315******************************************************************
041315 LINKAGE SECTION.
041315
041315 01  lsIndex                     PIC S9(09) COMP-5.
041315 01  lsLumpSumBenefit            USAGE COMP-2.
041315
041315******************************************************************
041315 PROCEDURE DIVISION USING BY VALUE lsIndex
041315                    RETURNING lsLumpSumBenefit.
041315******************************************************************
041315
041315     IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
041315         MOVE ZEROS
041315           TO lsLumpSumBenefit
041315     ELSE
041315         MOVE WDTQU-DB-GWBN-LUMP-SUM-AMT (lsIndex)
041315           TO lsLumpSumBenefit
041315     END-IF.
041315
041315     EXIT METHOD.
041315
041315 END METHOD getLumpSumBenefit.
041315
042015******************************************************************
042015*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
042015******************************************************************
042015
042015 METHOD-ID. getGWBNWaitPeriodFlag.
042015
042015******************************************************************
042015 DATA DIVISION.
042015******************************************************************
042015 WORKING-STORAGE SECTION.
042015******************************************************************
042015 LINKAGE SECTION.
042015
042015 01  lsIndex                     PIC S9(09) COMP-5.
042015 01  lsGWBNWaitPeriodFlag        OBJECT REFERENCE CLASS-STRING.
042015
042015******************************************************************
042015 PROCEDURE DIVISION USING BY VALUE lsIndex
042015                    RETURNING lsGWBNWaitPeriodFlag.
042015******************************************************************
042015
042015     IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
042015         INVOKE CLASS-STRING "NEW"
042015             USING BY VALUE ' '
042015                  RETURNING lsGWBNWaitPeriodFlag
042015     ELSE
042015         IF WDTQU-DB-GWBN-WAIT-PERIOD-FLAG (lsIndex) = 'Y'
042015             INVOKE CLASS-STRING "NEW"
042015                 USING BY VALUE
042015                   WDTQU-DB-GWBN-WAIT-PERIOD-FLAG (lsIndex)
042015                      RETURNING lsGWBNWaitPeriodFlag
042015         ELSE
042015             INVOKE CLASS-STRING "NEW"
042015                 USING BY VALUE 'N'
042015                      RETURNING lsGWBNWaitPeriodFlag
042015         END-IF
042015     END-IF.
042015
042015     EXIT METHOD.
042015
042015 END METHOD getGWBNWaitPeriodFlag.
042015
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBCount.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsGMBCount                  PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                    RETURNING lsGMBCount.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBCount
050814     ELSE
050814         MOVE WDTQU-GMB-LAST-ITEM (lsIndex1)
050814                         TO lsGMBCount
050814     END-IF
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBCount.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBDescription.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBDescription            OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBDescription.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         SET lsGMBDescription TO ' '
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             SET lsGMBDescription TO ' '
050814         ELSE
050814             SET lsGMBDescription TO WDTQU-GMB-DESCRIPTION
050814                                     (lsIndex1, lsIndex2)
050814         END-IF
050814     END-IF
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBDescription.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBCoverageID.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBCoverageID             OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBCoverageID.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         SET lsGMBCoverageID TO ' '
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             SET lsGMBCoverageID TO ' '
050814         ELSE
050814             SET lsGMBCoverageID TO WDTQU-GMB-COVERAGE-ID
050814                                 (lsIndex1, lsIndex2)
050814         END-IF
050814     END-IF
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBCoverageID.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBGrossAmount.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBGrossAmount            USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBGrossAmount.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBGrossAmount
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             MOVE ZERO TO lsGMBGrossAmount
050814         ELSE
050814             MOVE WDTQU-GMB-GROSS-AMOUNT (lsIndex1, lsIndex2)
050814                       TO lsGMBGrossAmount
050814         END-IF
050814     END-IF
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBGrossAmount.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBPremiumTax.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                   PIC S9(09) COMP-5.
050814 01  lsIndex2                   PIC S9(09) COMP-5.
050814 01  lsGMBPremiumTax            USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBPremiumTax.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBPremiumTax
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             MOVE ZERO TO lsGMBPremiumTax
050814         ELSE
050814             MOVE WDTQU-GMB-PREM-TAX (lsIndex1, lsIndex2)
050814                   TO lsGMBPremiumTax
050814         END-IF
050814     END-IF
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBPremiumTax.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBLoanAmount.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBLoanAmount            USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBLoanAmount.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBLoanAmount
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             MOVE ZERO TO lsGMBLoanAmount
050814         ELSE
050814             MOVE WDTQU-GMB-LOAN-AMOUNT (lsIndex1, lsIndex2)
050814                   TO lsGMBLoanAmount
050814         END-IF
050814     END-IF.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBLoanAmount.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBNetAmount.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBNetAmount            USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBNetAmount.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBNetAmount
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             MOVE ZERO TO lsGMBNetAmount
050814         ELSE
050814             MOVE WDTQU-GMB-NET-AMOUNT (lsIndex1, lsIndex2)
050814                       TO lsGMBNetAmount
050814         END-IF
050814     END-IF.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBNetAmount.
050814
042015******************************************************************
042015*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
042015******************************************************************
042015
042015 METHOD-ID. getGMBLumpSum.
042015
042015******************************************************************
042015 DATA DIVISION.
042015******************************************************************
042015 WORKING-STORAGE SECTION.
042015******************************************************************
042015 LINKAGE SECTION.
042015
042015 01  lsIndex1                    PIC S9(09) COMP-5.
042015 01  lsIndex2                    PIC S9(09) COMP-5.
042015 01  lsGMBLumpSum                USAGE COMP-2.
042015
042015******************************************************************
042015 PROCEDURE DIVISION USING BY VALUE lsIndex1
042015                          BY VALUE lsIndex2
042015                    RETURNING lsGMBLumpSum.
042015******************************************************************
042015
042015     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
042015         MOVE ZERO TO lsGMBLumpSum
042015     ELSE
042015         IF (lsIndex2 < 1 OR
042015             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
042015             MOVE ZERO TO lsGMBLumpSum
042015         ELSE
042015             MOVE WDTQU-GMB-LUMP-SUM (lsIndex1, lsIndex2)
042015                   TO lsGMBLumpSum
042015         END-IF
042015     END-IF.
042015
042015     EXIT METHOD.
042015
042015 END METHOD getGMBLumpSum.
042015
042015******************************************************************
042015*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
042015******************************************************************
042015
042015 METHOD-ID. getGMBAnnuitized.
042015
042015******************************************************************
042015 DATA DIVISION.
042015******************************************************************
042015 WORKING-STORAGE SECTION.
042015******************************************************************
042015 LINKAGE SECTION.
042015
042015 01  lsIndex1                    PIC S9(09) COMP-5.
042015 01  lsIndex2                    PIC S9(09) COMP-5.
042015 01  lsGMBAnnuitized             USAGE COMP-2.
042015
042015******************************************************************
042015 PROCEDURE DIVISION USING BY VALUE lsIndex1
042015                          BY VALUE lsIndex2
042015                    RETURNING lsGMBAnnuitized.
042015******************************************************************
042015
042015     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
042015         MOVE ZERO TO lsGMBAnnuitized
042015     ELSE
042015         IF (lsIndex2 < 1 OR
042015             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
042015             MOVE ZERO TO lsGMBAnnuitized
042015         ELSE
042015             MOVE WDTQU-GMB-ANNUITIZED (lsIndex1, lsIndex2)
042015                   TO lsGMBAnnuitized
042015         END-IF
042015     END-IF.
042015
042015     EXIT METHOD.
042015
042015 END METHOD getGMBAnnuitized.
042015
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGMBEarningsEnhancement.
050814
050814******************************************************************
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01  lsIndex1                    PIC S9(09) COMP-5.
050814 01  lsIndex2                    PIC S9(09) COMP-5.
050814 01  lsGMBEarningsEnhancement    USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION USING BY VALUE lsIndex1
050814                          BY VALUE lsIndex2
050814                    RETURNING lsGMBEarningsEnhancement.
050814******************************************************************
050814
050814     IF (lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED)
050814         MOVE ZERO TO lsGMBEarningsEnhancement
050814     ELSE
050814         IF (lsIndex2 < 1 OR
050814             lsIndex2 > WDTQU-GMB-LAST-ITEM (lsIndex1))
050814             MOVE ZERO TO lsGMBEarningsEnhancement
050814         ELSE
050814             MOVE WDTQU-GMB-ADDL-AMOUNT (lsIndex1, lsIndex2)
050814                   TO lsGMBEarningsEnhancement
050814         END-IF
050814     END-IF.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGMBEarningsEnhancement.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getNumberOfBenefits.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsNumberOfBenefits          PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsNumberOfBenefits.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WDTQU-DB-MAX-INSURED
               MOVE ZEROS
                 TO lsNumberOfBenefits
           ELSE
               MOVE WDTQU-DB-MAX-BEN (lsIndex)
                 TO lsNumberOfBenefits
           END-IF.

           EXIT METHOD.

       END METHOD getNumberOfBenefits.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitSeq.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitSeq                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitSeq.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitSeq
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitSeq
               ELSE
                   MOVE WDTQU-DB-BEN-SEQ (lsIndex1 lsIndex2)
                     TO lsBenefitSeq
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitType.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitType               OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitType.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsBenefitType
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE ' '
                            RETURNING lsBenefitType
               ELSE
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE WDTQU-DB-BEN-TYPE
                                                     (lsIndex1 lsIndex2)
                            RETURNING lsBenefitType
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitPlanCode.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitPlanCode           OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitPlanCode.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsBenefitPlanCode
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE ' '
                            RETURNING lsBenefitPlanCode
               ELSE
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE WDTQU-DB-BEN-PLANCODE
                                                     (lsIndex1 lsIndex2)
                            RETURNING lsBenefitPlanCode
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitPlanCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitDescription.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitDescription        OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitDescription.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsBenefitDescription
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE ' '
                            RETURNING lsBenefitDescription
               ELSE
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE WDTQU-DB-BEN-DESCRIPTION
                                                     (lsIndex1 lsIndex2)
                            RETURNING lsBenefitDescription
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitDescription.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitDeathBenefit.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitDeathBenefit       USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitDeathBenefit.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitDeathBenefit
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitDeathBenefit
               ELSE
                   MOVE WDTQU-DB-BEN-DEATH-BENEFIT (lsIndex1 lsIndex2)
                     TO lsBenefitDeathBenefit
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitDeathBenefit.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitFaceAmt            USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitFaceAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitFaceAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitFaceAmt
               ELSE
                   MOVE WDTQU-DB-BEN-FACE-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitFaceAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitPuaFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitPuaFaceAmt         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitPuaFaceAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitPuaFaceAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitPuaFaceAmt
               ELSE
                   MOVE WDTQU-DB-BEN-PUA-FACE-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitPuaFaceAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitPuaFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitOytFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitOytFaceAmt         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitOytFaceAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitOytFaceAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitOytFaceAmt
               ELSE
                   MOVE WDTQU-DB-BEN-OYT-FACE-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitOytFaceAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitOytFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitEtiFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitEtiFaceAmt         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitEtiFaceAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitEtiFaceAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitEtiFaceAmt
               ELSE
                   MOVE WDTQU-DB-BEN-ETI-FACE-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitEtiFaceAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitEtiFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitRpuFaceAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitRpuFaceAmt         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitRpuFaceAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitRpuFaceAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitRpuFaceAmt
               ELSE
                   MOVE WDTQU-DB-BEN-RPU-FACE-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitRpuFaceAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitRpuFaceAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitDivAccums.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitDivAccums          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitDivAccums.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitDivAccums
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitDivAccums
               ELSE
                   MOVE WDTQU-DB-BEN-DIV-ACCUMS (lsIndex1 lsIndex2)
                     TO lsBenefitDivAccums
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitDivAccums.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitDivAdjust.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitDivAdjust          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitDivAdjust.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitDivAdjust
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitDivAdjust
               ELSE
                   MOVE WDTQU-DB-BEN-DIV-ADJUST (lsIndex1 lsIndex2)
                     TO lsBenefitDivAdjust
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitDivAdjust.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitPremRefund.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitPremRefund         USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitPremRefund.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitPremRefund
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitPremRefund
               ELSE
                   MOVE WDTQU-DB-BEN-PREM-REFUND (lsIndex1 lsIndex2)
                     TO lsBenefitPremRefund
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitPremRefund.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitSpecifiedAmt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitSpecifiedAmt       USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitSpecifiedAmt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitSpecifiedAmt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitSpecifiedAmt
               ELSE
                   MOVE WDTQU-DB-BEN-SPECIFIED-AMT (lsIndex1 lsIndex2)
                     TO lsBenefitSpecifiedAmt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitSpecifiedAmt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitUlDeathBenefit.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitUlDeathBenefit     USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitUlDeathBenefit.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitUlDeathBenefit
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitUlDeathBenefit
               ELSE
                   MOVE WDTQU-DB-BEN-UL-DEATH-BEN (lsIndex1 lsIndex2)
                     TO lsBenefitUlDeathBenefit
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitUlDeathBenefit.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitUlFundValue.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitUlFundValue        USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitUlFundValue.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitUlFundValue
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitUlFundValue
               ELSE
                   MOVE WDTQU-DB-BEN-UL-FUND-VALUE (lsIndex1 lsIndex2)
                     TO lsBenefitUlFundValue
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitUlFundValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitUlDeathBenOpt.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitUlDeathBenOpt      OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitUlDeathBenOpt.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsBenefitUlDeathBenOpt
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE ' '
                            RETURNING lsBenefitUlDeathBenOpt
               ELSE
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE WDTQU-DB-BEN-UL-DB-OPT
                                                     (lsIndex1 lsIndex2)
                            RETURNING lsBenefitUlDeathBenOpt
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitUlDeathBenOpt.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitUlDeathBenOptDesc.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitUlDeathBenOptDesc  OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitUlDeathBenOptDesc.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               INVOKE CLASS-STRING "NEW"
                   USING BY VALUE ' '
                        RETURNING lsBenefitUlDeathBenOptDesc
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE ' '
                            RETURNING lsBenefitUlDeathBenOptDesc
               ELSE
                   INVOKE CLASS-STRING "NEW"
                       USING BY VALUE WDTQU-DB-BEN-UL-DB-OPT-TEXT
                                                     (lsIndex1 lsIndex2)
                            RETURNING lsBenefitUlDeathBenOptDesc
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitUlDeathBenOptDesc.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitArFundValue.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitArFundValue        USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitArFundValue.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitArFundValue
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitArFundValue
               ELSE
                   MOVE WDTQU-DB-BEN-AR-FUND-VALUE (lsIndex1 lsIndex2)
                     TO lsBenefitArFundValue
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitArFundValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getBenefitFundTax.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex1                    PIC S9(09) COMP-5.
       01  lsIndex2                    PIC S9(09) COMP-5.
       01  lsBenefitFundTax            USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex1, lsIndex2
                          RETURNING lsBenefitFundTax.
      ******************************************************************

           IF lsIndex1 < 1 OR lsIndex1 > WDTQU-DB-MAX-INSURED
               MOVE ZEROS        TO lsBenefitFundTax
           ELSE
               IF lsIndex2 < 1 OR lsIndex2 > WDTQU-DB-MAX-BEN (lsIndex1)
                   MOVE ZEROS    TO lsBenefitFundTax
               ELSE
                   MOVE WDTQU-DB-BEN-FUND-TAX (lsIndex1 lsIndex2)
                     TO lsBenefitFundTax
               END-IF
           END-IF.

           EXIT METHOD.

       END METHOD getBenefitFundTax.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getReturnCode.

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

           MOVE WDTQU-RETURN-CODE      TO lsReturnCode.

           EXIT METHOD.

       END METHOD getReturnCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getErrorMessage.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsErrorMessage              OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsErrorMessage.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE WDTQU-ERROR-MESSAGE
                                     RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.


      ******************************************************************
      *The following GET methods are for Input values, but the client
      *should be able to retrieve also so a Get is provided.
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getCompanyCode.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lswsCompanyCode             OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lswsCompanyCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE WDTQU-COMPANY-CODE
                                     RETURNING lswsCompanyCode.

           EXIT METHOD.

       END METHOD getCompanyCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getPolicyNumber.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lswsPolicyNumber            OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lswsPolicyNumber.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE WDTQU-POLICY-NUMBER
                                     RETURNING lswsPolicyNumber.

           EXIT METHOD.

       END METHOD getPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getEffectiveDate.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lswsEffectiveDate           PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lswsEffectiveDate.
      ******************************************************************

           MOVE WDTQU-EFFECTIVE-DATE   TO lswsEffectiveDate.

           EXIT METHOD.

       END METHOD getEffectiveDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInputNameId.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lswsInputNameId             PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lswsInputNameId.
      ******************************************************************

           MOVE WDTQU-NAME-ID          TO lswsInputNameId.

           EXIT METHOD.

       END METHOD getInputNameId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getInputBenefitSeq.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lswsInputBenefitSeq         PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lswsInputBenefitSeq.
      ******************************************************************

           MOVE WDTQU-BENEFIT-SEQ      TO lswsInputBenefitSeq.

           EXIT METHOD.

       END METHOD getInputBenefitSeq.

      ******************************************************************
      * Set methods.
      ******************************************************************

032614 METHOD-ID. setOverrideFutureDateEdits.
032614 DATA DIVISION.
032614******************************************************************
032614 WORKING-STORAGE SECTION.
032614******************************************************************
032614 LINKAGE SECTION.
032614
032614 01 lsOverrideFutureDateEdits      OBJECT REFERENCE CLASS-STRING.
032614
032614******************************************************************
032614 PROCEDURE DIVISION USING BY VALUE lsOverrideFutureDateEdits.
032614******************************************************************
032614
032614     SET SAVE-FUTURE-REQUEST-FLAG TO
032614                         lsOverrideFutureDateEdits.
032614
032614     EXIT METHOD.
032614
032614 END METHOD setOverrideFutureDateEdits.
032614
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setCompanyCode.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCompanyCode               OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.
      ******************************************************************

           SET WDTQU-COMPANY-CODE      TO lsCompanyCode.

           EXIT METHOD.

       END METHOD setCompanyCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setPolicyNumber.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsPolicyNumber              OBJECT REFERENCE CLASS-STRING.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.
      ******************************************************************

           SET WDTQU-POLICY-NUMBER     TO lsPolicyNumber.

           EXIT METHOD.

       END METHOD setPolicyNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setEffectiveDate.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEffectiveDate             PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.
      ******************************************************************

           MOVE lsEffectiveDate        TO WDTQU-EFFECTIVE-DATE.

           EXIT METHOD.

       END METHOD setEffectiveDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setInputNameId.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsInputNameId               PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsInputNameId.
      ******************************************************************

           MOVE lsInputNameId          TO WDTQU-NAME-ID.

           EXIT METHOD.

       END METHOD setInputNameId.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setInputBenefitSeq.

      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsInputBenefitSeq           PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsInputBenefitSeq.
      ******************************************************************

           MOVE lsInputBenefitSeq      TO WDTQU-BENEFIT-SEQ.

           EXIT METHOD.

       END METHOD setinputBenefitSeq.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       END OBJECT.

       END CLASS ODTHQUOT.
