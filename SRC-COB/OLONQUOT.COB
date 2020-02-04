       IDENTIFICATION DIVISION.
       CLASS-ID. OLONQUOT AS "LPNETAPI.OLONQUOT".
022703*AUTHOR.         PDMA.
022703*DATE-WRITTEN.   March 2002.
022703*DATE-COMPILED.
      *@**20140101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2014 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20140101*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D BAPI object that returns loan information for a policy.
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
032907*H 20070329-004-01 DAR Increase WGLOB length.
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
032614*H 20140220-005-01 DAR Allow Future, Past and Terminated Policy Quoting
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
092308     05  PLONQUOT           PIC X(08) VALUE 'PLONQUOT'.

032614 01  SAVE-INTERFACE-FLAG              PIC X(01).
032614 01  SAVE-FUTURE-REQUEST-FLAG         PIC X(01).
032614 01  SAVE-ORIG-FUTURE-REQUEST-FLAG    PIC X(01).


       COPY WGLOBCPY.
       COPY WGLBXCPY.

      ******************************************************************
      * Object Properties
      ******************************************************************

       01  LpEffectiveDateUsed        PIC 9(08).

      * input
       01  wsCompanyCode              PIC X(02).
       01  wsPolicyNumber             PIC X(12).
       01  wsEffectiveDate            PIC 9(08).

      * output
       01  LpReturnCode                PIC S9(09) COMP-5.
       01  LpErrorMessage              PIC X(200).

       01  LpDividendsAccums          PIC S9(07)V99 COMP-5.
       01  LpCashValuePaidup          PIC S9(07)V99 COMP-5.
       01  LpCurLoanBalance           PIC S9(07)V99 COMP-5.
       01  LpFundOrCashValue          PIC S9(07)V99 COMP-5.
       01  LpSurrenderCharge          PIC S9(07)V99 COMP-5.
       01  LpAccruedInterest          PIC S9(07)V99 COMP-5.
       01  LpPremiumDue               PIC S9(07)V99 COMP-5.
       01  LpMaxLoanAvail             PIC S9(07)V99 COMP-5.
       01  LpInterestToAnniv          PIC S9(07)V99 COMP-5.
       01  LpNetLoanAvail             PIC S9(07)V99 COMP-5.
       01  LpLoanInterestRate         PIC S9(07)V9(04) COMP-5.
       01  LpInterestMethod           PIC X(07).
       01  LpInterestType             PIC X(08).
       01  LpLastAccruedDate          PIC 9(08).
       01  LpFundOrCash               PIC X(04).
       01  LpMinEquityText            PIC X(17).
       01  LpIntAdjustText            PIC X(17).

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
       METHOD-ID. RunQuote.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

       01 POPFUNCN                     PIC X(08)       VALUE 'POPFUNCN'.

           COPY WLNQUCPY.

      ******************************************************************
       LINKAGE SECTION.

       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************


           MOVE wsCompanyCode TO WLNQU-COMPANY-CODE.
           MOVE wsPolicyNumber TO WLNQU-POLICY-NUMBER.
           MOVE wsEffectiveDate TO WLNQU-EFFECTIVE-DATE.

032614     MOVE WGLOB-INTERFACE-FLAG TO SAVE-INTERFACE-FLAG
032614     MOVE WGLOB-API-FUTURE-REQUEST-FLAG
032614                               TO SAVE-ORIG-FUTURE-REQUEST-FLAG
032614     SET WGLOB-API-LOAN-QUOTE TO TRUE
032614     MOVE SAVE-FUTURE-REQUEST-FLAG
032614                TO WGLOB-API-FUTURE-REQUEST-FLAG

021709     TRY
092308         CALL PLONQUOT USING WGLOBAL
021709                             WLNQU-PARAMETERS
               MOVE WLNQU-RETURN-CODE TO lsReturnCode,
021709                                   LpReturnCode
021709         MOVE WLNQU-ERROR-MESSAGE TO LpErrorMessage
021709         MOVE WLNQU-EFFECTIVE-DATE to LpEffectiveDateUsed
               IF WLNQU-PROCESSING-OK
                   MOVE WLNQU-DIVIDENDS-ACCUMS    TO LpDividendsAccums
                   MOVE WLNQU-CASH-VALUE-PAIDUP   TO LpCashValuePaidup
                   MOVE WLNQU-CUR-LOAN-BALANCE    TO LpCurLoanBalance
                   MOVE WLNQU-FUND-OR-CASH-VALUE  TO LpFundOrCashValue
                   MOVE WLNQU-SURRENDER-CHARGE    TO LpSurrenderCharge
                   MOVE WLNQU-ACCRUED-INTEREST    TO LpAccruedInterest
                   MOVE WLNQU-PREMIUM-DUE         TO LpPremiumDue
                   MOVE WLNQU-MAX-LOAN-AVAIL      TO LpMaxLoanAvail
                   MOVE WLNQU-INTEREST-TO-ANNIV   TO LpInterestToAnniv
                   MOVE WLNQU-NET-LOAN-AVAIL      TO LpNetLoanAvail
                   MOVE WLNQU-LOAN-INTEREST-RATE  TO LpLoanInterestRate
                   MOVE WLNQU-INTEREST-METHOD     TO LpInterestMethod
                   MOVE WLNQU-INTEREST-TYPE       TO LpInterestType
                   MOVE WLNQU-LAST-ACCRUED-DATE   TO LpLastAccruedDate
                   MOVE WLNQU-FUND-OR-CASH        TO LpFundOrCash
                   MOVE WLNQU-MIN-EQUITY-TEXT     TO LpMinEquityText
                   MOVE WLNQU-INT-ADJUST-TEXT     TO LpIntAdjustText
               ELSE
                   MOVE ZERO TO LpDividendsAccums
                                LpCashValuePaidup
                                LpCurLoanBalance
                                LpFundOrCashValue
                                LpSurrenderCharge
                                LpAccruedInterest
                                LpPremiumDue
                                LpMaxLoanAvail
                                LpInterestToAnniv
                                LpNetLoanAvail
                                LpLoanInterestRate
                                LpLastAccruedDate
                   MOVE SPACES TO   LpInterestMethod
                                    LpInterestType
                                    LpFundOrCash
                                    LpMinEquityText
                                    LpIntAdjustText
021709         END-IF
021709         MOVE WGLOBAL TO WGLOBX
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

032614     MOVE SAVE-INTERFACE-FLAG TO WGLOB-INTERFACE-FLAG
032614     MOVE SAVE-ORIG-FUTURE-REQUEST-FLAG
032614                              TO WGLOB-API-FUTURE-REQUEST-FLAG.

           EXIT METHOD.

       END METHOD RunQuote.

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

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpErrorMessage
                RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEffectiveDateUsed.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEffectiveDateUsed        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDateUsed.
      ******************************************************************

           MOVE LpEffectiveDateUsed TO lsEffectiveDateUsed.

           EXIT METHOD.

       END METHOD getEffectiveDateUsed.
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

           INVOKE CLASS-STRING "NEW" USING BY VALUE wsCompanyCode
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

       01  lsPolicyNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPolicyNumber.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE wsPolicyNumber
                RETURNING lsPolicyNumber.

           EXIT METHOD.

       END METHOD getPolicyNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getEffectiveDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsEffectiveDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDate.
      ******************************************************************

           MOVE wsEffectiveDate TO lsEffectiveDate.

           EXIT METHOD.

       END METHOD getEffectiveDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDividendsAccums.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDividendsAccums        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsDividendsAccums.
      ******************************************************************

           MOVE LpDividendsAccums TO lsDividendsAccums.

           EXIT METHOD.

       END METHOD getDividendsAccums.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCashValuePaidup.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCashValuePaidup        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCashValuePaidup.
      ******************************************************************

           MOVE LpCashValuePaidup TO lsCashValuePaidup.

           EXIT METHOD.

       END METHOD getCashValuePaidup.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCurLoanBalance.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCurLoanBalance        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCurLoanBalance.
      ******************************************************************

           MOVE LpCurLoanBalance TO lsCurLoanBalance.

           EXIT METHOD.

       END METHOD getCurLoanBalance.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFundOrCashValue.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFundOrCashValue        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFundOrCashValue.
      ******************************************************************

           MOVE LpFundOrCashValue TO lsFundOrCashValue.

           EXIT METHOD.

       END METHOD getFundOrCashValue.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getSurrenderCharge.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsSurrenderCharge        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsSurrenderCharge.
      ******************************************************************

           MOVE LpSurrenderCharge TO lsSurrenderCharge.

           EXIT METHOD.

       END METHOD getSurrenderCharge.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAccruedInterest.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAccruedInterest        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAccruedInterest.
      ******************************************************************

           MOVE LpAccruedInterest TO lsAccruedInterest.

           EXIT METHOD.

       END METHOD getAccruedInterest.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPremiumDue.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsPremiumDue        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPremiumDue.
      ******************************************************************

           MOVE LpPremiumDue TO lsPremiumDue.

           EXIT METHOD.

       END METHOD getPremiumDue.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getMaxLoanAvail.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsMaxLoanAvail        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsMaxLoanAvail.
      ******************************************************************

           MOVE LpMaxLoanAvail TO lsMaxLoanAvail.

           EXIT METHOD.

       END METHOD getMaxLoanAvail.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInterestToAnniv.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsInterestToAnniv        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsInterestToAnniv.
      ******************************************************************

           MOVE LpInterestToAnniv TO lsInterestToAnniv.

           EXIT METHOD.

       END METHOD getInterestToAnniv.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNetLoanAvail.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNetLoanAvail        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNetLoanAvail.
      ******************************************************************

           MOVE LpNetLoanAvail TO lsNetLoanAvail.

           EXIT METHOD.

       END METHOD getNetLoanAvail.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************


       METHOD-ID. getLoanInterestRate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsLoanInterestRate        USAGE COMP-2.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLoanInterestRate.
      ******************************************************************

           MOVE LpLoanInterestRate TO lsLoanInterestRate.

           EXIT METHOD.

       END METHOD getLoanInterestRate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInterestMethod.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsInterestMethod        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsInterestMethod.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpInterestMethod
                RETURNING lsInterestMethod.

           EXIT METHOD.

       END METHOD getInterestMethod.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getInterestType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsInterestType        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsInterestType.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpInterestType
                RETURNING lsInterestType.

           EXIT METHOD.

       END METHOD getInterestType.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************


       METHOD-ID. getLastAccruedDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsLastAccruedDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLastAccruedDate.
      ******************************************************************

           MOVE LpLastAccruedDate TO lsLastAccruedDate.

           EXIT METHOD.

       END METHOD getLastAccruedDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************


       METHOD-ID. getFundOrCash.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFundOrCash        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFundOrCash.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFundOrCash
                RETURNING lsFundOrCash.

           EXIT METHOD.

       END METHOD getFundOrCash.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************


       METHOD-ID. getMinEquityText.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsMinEquityText        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsMinEquityText.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpMinEquityText
                RETURNING lsMinEquityText.

           EXIT METHOD.

       END METHOD getMinEquityText.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIntAdjustText.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIntAdjustText        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIntAdjustText.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpIntAdjustText
                RETURNING lsIntAdjustText.

           EXIT METHOD.

       END METHOD getIntAdjustText.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

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
032614******************************************************************
032614*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032614******************************************************************

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

           SET wsCompanyCode TO lsCompanyCode.

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

           SET wsPolicyNumber TO lsPolicyNumber.

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

       01  lsEffectiveDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.
      ******************************************************************

           MOVE lsEffectiveDate TO wsEffectiveDate.

           EXIT METHOD.

       END METHOD setEffectiveDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************



      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       END OBJECT.
       END CLASS OLONQUOT.
