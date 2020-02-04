       IDENTIFICATION DIVISION.
       CLASS-ID. OCINEWBS AS "LPNETAPI.OCINEWBS".
      *AUTHOR.         PDMA.
      *DATE-WRITTEN.   February 25, 2008.
      *DATE-COMPILED.
      *@**20110111*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2011 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20110111*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D Credit Life New Business API.  
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
022208*H 20060818-015-01 DAR new object program.  
032608*H 20060818-015-02 DAR Misc property corrections. 
060308*H 20060818-015-03 DAR Centralizing of PCINBPRC logic.  Add YEI
060308*H                     table.  
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
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

092308 01  WS-PROGRAM-INFO.
092308     05  PCINBPRC                 PIC X(08) VALUE 'PCINBPRC'.
092308     05  PFILEBTV                 PIC X(08) VALUE 'PFILEBTV'.

       01  MAX-APPLICANT              PIC S9(04) COMP-5 VALUE 2.
       01  MAX-FEATURE                PIC S9(04) COMP-5 VALUE 25.
       01  MAX-ERROR                  PIC S9(04) COMP-5 VALUE 200.

       01  SAVE-DI-AMOUNT                 PIC S9(09)V99.
       01  SAVE-LIFE-INSURANCE-AMOUNT     PIC S9(09)V99.
032608 01  WS-DATA                    PIC X(04) VALUE 'Data'.
032608 01  WS-ELIGIBILITY             PIC X(11) VALUE 'Eligibility'.

060308 78  INT-COV-MAX                             VALUE 100.
060308 78  INT-BEN-MAX                             VALUE 2.
060308 78  INT-APP-MAX                             VALUE 2.

060308 COPY WWSCRCPY.
060308 COPY WCIPNCPY.
060308
060308 78 WS-CIPN-LEN VALUE LENGTH OF WCIPN-DATA-RECORD.
060308 01  WCIPN-FILE-FLAG                 PIC X(01) VALUE SPACES.
060308     88  WCIPN-END-OF-FILE                     VALUE 'Y'.
060308
060308 COPY WCIBNCPY.
060308 78 WS-CIBN-LEN VALUE LENGTH OF WCIBN-DATA-RECORD.
060308 01  WCIBN-FILE-FLAG                 PIC X(01) VALUE SPACES.
060308     88  WCIBN-END-OF-FILE                     VALUE 'Y'.
060308
060308 COPY WCIADCPY.
060308 78 WS-CIAD-LEN VALUE LENGTH OF WCIAD-DATA-RECORD.
060308 01  WCIAD-FILE-FLAG                 PIC X(01) VALUE SPACES.
060308     88  WCIAD-END-OF-FILE                     VALUE 'Y'.
060308


       COPY WGLB2CPY.

           COPY WGLOBCPY.
           COPY WAPPLCPY.
           COPY WBTRVCPY.
           COPY WGLBXCPY.
           COPY WCINBCPY.
092308     COPY WCICPCPY.
092308     COPY WCISGCPY.
092308     COPY WCDTECPY.

092308* these are passed back and forth, but don't remap nicely
060308 01  SUPPRESS-IC-ERRORS             PIC X(2000).
060308 01  SUPPRESS-IC-DATA               PIC X(1200000).

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
           INITIALIZE WCINB-PARAMETERS.

           INVOKE lsApp "Login" USING wsUserType
                                      WGLOBX
                                      wsErrorMessage
                                RETURNING wsReturnCode

           MOVE WGLOBX TO WGLOBAL.

      *    If Login Attempt was unsuccessful, place results in 
      *    return code and message properties. 
           MOVE wsReturnCode to WCINB-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WCINB-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WCINB-ERROR-MESSAGE.


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
               MOVE wsErrorMessage to WCINB-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WCINB-ERROR-MESSAGE.
           MOVE wsReturnCode TO WCINB-RETURN-CODE.

      *    End COBOL Run Unit here        
092308*     CALL JMPCINT3.


       END METHOD Dispose.

      ******************************************************************
       METHOD-ID. InitiateApplication.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WCINB-INITIATE TO TRUE.

092308     MOVE SPACES TO WCICP-DATA-RECORD,
092308                    WCISG-DATA-RECORD,
092308                    WCDTE-PARAMETERS,
060308                    SUPPRESS-IC-ERRORS,
060308                    SUPPRESS-IC-DATA

021709     TRY
092308         CALL PCINBPRC USING WGLOBAL
092308                             WCICP-DATA-RECORD
092308                             WCISG-DATA-RECORD
092308                             WCDTE-PARAMETERS
060308                             SUPPRESS-IC-ERRORS
060308                             SUPPRESS-IC-DATA
092308                             WCINB-PARAMETERS
021709         MOVE WCINB-RETURN-CODE TO lsReturnCode
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      WCINB-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WCINB-ERROR-MESSAGE
021709     END-TRY.

           EXIT METHOD.

       END METHOD InitiateApplication.

      ******************************************************************
       METHOD-ID. QuoteApplication.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WCINB-QUOTE TO TRUE.
092308     MOVE SPACES TO WCICP-DATA-RECORD,
092308                    WCISG-DATA-RECORD,
092308                    WCDTE-PARAMETERS,
060308                    SUPPRESS-IC-ERRORS,
060308                    SUPPRESS-IC-DATA

021709     TRY
092308         CALL PCINBPRC USING WGLOBAL
092308                             WCICP-DATA-RECORD
092308                             WCISG-DATA-RECORD
092308                             WCDTE-PARAMETERS
060308                             SUPPRESS-IC-ERRORS
060308                             SUPPRESS-IC-DATA
092308                             WCINB-PARAMETERS
021709         MOVE WCINB-RETURN-CODE TO lsReturnCode
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      WCINB-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WCINB-ERROR-MESSAGE
021709     END-TRY.

           EXIT METHOD.

       END METHOD QuoteApplication.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * These get and set methods take as input, and provide as output,
      * types that are part of the Common Language Runtime.
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision floating point,
      * and CLASS-STRING maps to String.  This allows these get/set methods
      * to be used in VB, C# and in COBOL.NET.
      ******************************************************************
       METHOD-ID. getCompanyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCompanyCode               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsCompanyCode.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-COMPANY-CODE
                   RETURNING lsCompanyCode.

           EXIT METHOD.
       END METHOD getCompanyCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setCompanyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCompanyCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.

           SET WCINB-COMPANY-CODE TO lsCompanyCode.

           EXIT METHOD.
       END METHOD setCompanyCode.
      **************************************************************************

       METHOD-ID. getPolicyNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPolicyNumber               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsPolicyNumber.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-POLICY-NUMBER
                   RETURNING lsPolicyNumber.

           EXIT METHOD.
       END METHOD getPolicyNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setPolicyNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPolicyNumber             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.

           SET WCINB-POLICY-NUMBER TO lsPolicyNumber.

           EXIT METHOD.
       END METHOD setPolicyNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getProductId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsProductId               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsProductId.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-PRODUCT-ID
                   RETURNING lsProductId.

           EXIT METHOD.
       END METHOD getProductId.
      *-------------------------------------------------------------------------
       METHOD-ID. setProductId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsProductId             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsProductId.

           SET WCINB-PRODUCT-ID TO lsProductId.

           EXIT METHOD.
       END METHOD setProductId.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTransactionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTransactionDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsTransactionDate.

           MOVE WCINB-TRANSACTION-DATE TO lsTransactionDate.

           EXIT METHOD.
       END METHOD getTransactionDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setTransactionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTransactionDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsTransactionDate.

           MOVE lsTransactionDate TO WCINB-TRANSACTION-DATE.

           EXIT METHOD.
       END METHOD setTransactionDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLoanNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanNumber               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsLoanNumber.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-LOAN-NUMBER
                   RETURNING lsLoanNumber.

           EXIT METHOD.
       END METHOD getLoanNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setLoanNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanNumber             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsLoanNumber.

           SET WCINB-LOAN-NUMBER TO lsLoanNumber.

           EXIT METHOD.
       END METHOD setLoanNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLoanDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLoanDate.

           MOVE WCINB-LOAN-DATE TO lsLoanDate.

           EXIT METHOD.
       END METHOD getLoanDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setLoanDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsLoanDate.

           MOVE lsLoanDate TO WCINB-LOAN-DATE.

           EXIT METHOD.
       END METHOD setLoanDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLanguagePreference.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLanguagePreference     OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsLanguagePreference.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-LANGUAGE-PREFERENCE
                   RETURNING lsLanguagePreference.

           EXIT METHOD.

       END METHOD getLanguagePreference.
      *-------------------------------------------------------------------------
       METHOD-ID. setLanguagePreference.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLanguagePreference OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsLanguagePreference.

           SET WCINB-LANGUAGE-PREFERENCE TO lsLanguagePreference.

           EXIT METHOD.
       END METHOD setLanguagePreference.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBranchNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBranchNumber               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsBranchNumber.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-BRANCH-NUMBER
                   RETURNING lsBranchNumber.

           EXIT METHOD.
       END METHOD getBranchNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setBranchNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBranchNumber             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsBranchNumber.

           SET WCINB-BRANCH-NUMBER TO lsBranchNumber.

           EXIT METHOD.
       END METHOD setBranchNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getRescissionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRescissionDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsRescissionDate.

           MOVE WCINB-RESCISSION-DATE TO lsRescissionDate.

           EXIT METHOD.
       END METHOD getRescissionDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setRescissionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRescissionDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsRescissionDate.

           MOVE lsRescissionDate TO WCINB-RESCISSION-DATE.

           EXIT METHOD.
       END METHOD setRescissionDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLoanTerm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanTerm               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLoanTerm.

           MOVE WCINB-LOAN-TERM TO lsLoanTerm.

           EXIT METHOD.
       END METHOD getLoanTerm.
      *-------------------------------------------------------------------------
       METHOD-ID. setLoanTerm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanTerm             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsLoanTerm.

           MOVE lsLoanTerm TO WCINB-LOAN-TERM.

           EXIT METHOD.
       END METHOD setLoanTerm.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLoanMaturityDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanMaturityDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLoanMaturityDate.

           MOVE WCINB-LOAN-MATURITY-DATE TO lsLoanMaturityDate.

           EXIT METHOD.
       END METHOD getLoanMaturityDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setLoanMaturityDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanMaturityDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsLoanMaturityDate.

           MOVE lsLoanMaturityDate TO WCINB-LOAN-MATURITY-DATE.

           EXIT METHOD.
       END METHOD setLoanMaturityDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getNextLoanPaymentDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNextLoanPaymentDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsNextLoanPaymentDate.

           MOVE WCINB-NEXT-LOAN-PAYMENT-DATE TO lsNextLoanPaymentDate.

           EXIT METHOD.
       END METHOD getNextLoanPaymentDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setNextLoanPaymentDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsNextLoanPaymentDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsNextLoanPaymentDate.

           MOVE lsNextLoanPaymentDate TO WCINB-NEXT-LOAN-PAYMENT-DATE.

           EXIT METHOD.
       END METHOD setNextLoanPaymentDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLoanDueDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanDueDay               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLoanDueDay.

           MOVE WCINB-LOAN-DUE-DAY TO lsLoanDueDay.

           EXIT METHOD.
       END METHOD getLoanDueDay.
      *-------------------------------------------------------------------------
       METHOD-ID. setLoanDueDay.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLoanDueDay             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsLoanDueDay.

           MOVE lsLoanDueDay TO WCINB-LOAN-DUE-DAY.

           EXIT METHOD.
       END METHOD setLoanDueDay.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getBranchState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBranchState               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsBranchState.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-BRANCH-STATE
                   RETURNING lsBranchState.

           EXIT METHOD.
       END METHOD getBranchState.
      *-------------------------------------------------------------------------
       METHOD-ID. setBranchState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsBranchState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsBranchState.

           SET WCINB-BRANCH-STATE TO lsBranchState.

           EXIT METHOD.
       END METHOD setBranchState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getIndividualOrJoint.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndividualOrJoint      OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsIndividualOrJoint.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-INDIVIDUAL-JOINT-FLAG
                   RETURNING lsIndividualOrJoint.

           EXIT METHOD.
       END METHOD getIndividualOrJoint.
      *-------------------------------------------------------------------------
       METHOD-ID. setIndividualOrJoint.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndividualOrJoint             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndividualOrJoint.

           SET WCINB-INDIVIDUAL-JOINT-FLAG TO lsIndividualOrJoint.

           EXIT METHOD.
       END METHOD setIndividualOrJoint.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMonthlyPayment.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMonthlyPayment               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsMonthlyPayment.

           MOVE WCINB-MONTHLY-PAYMENT TO lsMonthlyPayment.

           EXIT METHOD.
       END METHOD getMonthlyPayment.
      *-------------------------------------------------------------------------
       METHOD-ID. setMonthlyPayment.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsMonthlyPayment             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsMonthlyPayment.

           MOVE lsMonthlyPayment TO WCINB-MONTHLY-PAYMENT.

           EXIT METHOD.
       END METHOD setMonthlyPayment.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPrincipalAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPrincipalAmount               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsPrincipalAmount.

           MOVE WCINB-PRINCIPAL-AMOUNT TO lsPrincipalAmount.

           EXIT METHOD.
       END METHOD getPrincipalAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setPrincipalAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPrincipalAmount             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsPrincipalAmount.

           MOVE lsPrincipalAmount TO WCINB-PRINCIPAL-AMOUNT.

           EXIT METHOD.
       END METHOD setPrincipalAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getInterestRate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsInterestRate               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsInterestRate.

           MOVE WCINB-INTEREST-RATE TO lsInterestRate.

           EXIT METHOD.
       END METHOD getInterestRate.
      *-------------------------------------------------------------------------
       METHOD-ID. setInterestRate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsInterestRate             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsInterestRate.

           MOVE lsInterestRate TO WCINB-INTEREST-RATE.

           EXIT METHOD.
       END METHOD setInterestRate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAmountFinanced.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAmountFinanced               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsAmountFinanced.

           MOVE WCINB-AMOUNT-FINANCED TO lsAmountFinanced.

           EXIT METHOD.
       END METHOD getAmountFinanced.
      *-------------------------------------------------------------------------
       METHOD-ID. setAmountFinanced.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAmountFinanced             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsAmountFinanced.

           MOVE lsAmountFinanced TO WCINB-AMOUNT-FINANCED.

           EXIT METHOD.
       END METHOD setAmountFinanced.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAPR.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAPR               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsAPR.

           MOVE WCINB-ANNUAL-PERCENTAGE-RATE TO lsAPR.

           EXIT METHOD.
       END METHOD getAPR.
      *-------------------------------------------------------------------------
       METHOD-ID. setAPR.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAPR             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsAPR.

           MOVE lsAPR TO WCINB-ANNUAL-PERCENTAGE-RATE.

           EXIT METHOD.
       END METHOD setAPR.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getInceptionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsInceptionDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsInceptionDate.

           MOVE WCINB-INCEPTION-DATE TO lsInceptionDate.

           EXIT METHOD.
       END METHOD getInceptionDate.
      *-------------------------------------------------------------------------
       METHOD-ID. setInceptionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsInceptionDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsInceptionDate.

           MOVE lsInceptionDate TO WCINB-INCEPTION-DATE.

           EXIT METHOD.
       END METHOD setInceptionDate.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getIssueState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIssueState               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsIssueState.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-ISSUE-STATE
                   RETURNING lsIssueState.

           EXIT METHOD.
       END METHOD getIssueState.
      *-------------------------------------------------------------------------
       METHOD-ID. setIssueState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIssueState             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIssueState.

           SET WCINB-ISSUE-STATE TO lsIssueState.

           EXIT METHOD.
       END METHOD setIssueState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCoverageTerm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCoverageTerm               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsCoverageTerm.

           MOVE WCINB-COVERAGE-TERM TO lsCoverageTerm.

           EXIT METHOD.
       END METHOD getCoverageTerm.
      *-------------------------------------------------------------------------
       METHOD-ID. setCoverageTerm.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCoverageTerm             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsCoverageTerm.

           MOVE lsCoverageTerm TO WCINB-COVERAGE-TERM.

           EXIT METHOD.
       END METHOD setCoverageTerm.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLifeInsuranceAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLifeInsuranceAmount               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsLifeInsuranceAmount.

           MOVE WCINB-LIFE-INSURANCE-AMOUNT TO lsLifeInsuranceAmount.

           EXIT METHOD.
       END METHOD getLifeInsuranceAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setLifeInsuranceAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLifeInsuranceAmount             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsLifeInsuranceAmount.

           MOVE lsLifeInsuranceAmount TO WCINB-LIFE-INSURANCE-AMOUNT.

           EXIT METHOD.
       END METHOD setLifeInsuranceAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getDICoverageAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDICoverageAmount               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsDICoverageAmount.

           MOVE WCINB-DI-AMOUNT TO lsDICoverageAmount.

           EXIT METHOD.
       END METHOD getDICoverageAmount.
      *-------------------------------------------------------------------------
       METHOD-ID. setDICoverageAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsDICoverageAmount             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsDICoverageAmount.

           MOVE lsDICoverageAmount TO WCINB-DI-AMOUNT.

           EXIT METHOD.
       END METHOD setDICoverageAmount.

      **************************************************************************
      **************************************************************************
032608 METHOD-ID. getReportingOnly.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportOnly               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsReportOnly.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-REPORT-ONLY
                   RETURNING lsReportOnly.

           EXIT METHOD.
032608 END METHOD getReportingOnly.
      *-------------------------------------------------------------------------
032608 METHOD-ID. setReportingOnly.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReportOnly             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsReportOnly.

           SET WCINB-REPORT-ONLY TO lsReportOnly.

           EXIT METHOD.
032608 END METHOD setReportingOnly.

      **************************************************************************
      **************************************************************************
       METHOD-ID. getFeature.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsFeature               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsFeature.

           IF lsIndex < 1 OR lsIndex > MAX-FEATURE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsFeature
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-FEATURE (lsIndex)
                   RETURNING lsFeature.

           EXIT METHOD.
       END METHOD getFeature.
      *-------------------------------------------------------------------------
       METHOD-ID. setFeature.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex               PIC S9(09) COMP-5.
       01  lsFeature             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                                 BY VALUE lsFeature.

           IF lsIndex < 1 OR lsIndex > MAX-FEATURE
               CONTINUE
           ELSE
               SET WCINB-FEATURE (lsIndex) TO lsFeature.

           EXIT METHOD.
       END METHOD setFeature.
      **************************************************************************
      **************************************************************************

       METHOD-ID. getApplicantFirstName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex               PIC S9(09) COMP-5.
       01  lsApplicantFirstName  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantFirstName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantFirstName
           ELSE
               INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-APP-FIRST-NAME (lsIndex)
                   RETURNING lsApplicantFirstName.

           EXIT METHOD.
       END METHOD getApplicantFirstName.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantFirstName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsApplicantFirstName       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantFirstName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-FIRST-NAME (lsIndex)
                                  TO lsApplicantFirstName.

           EXIT METHOD.
       END METHOD setApplicantFirstName.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantMiddleName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsApplicantMiddleName      OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantMiddleName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantMiddleName
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-MIDDLE-NAME (lsIndex)
                      RETURNING lsApplicantMiddleName.

           EXIT METHOD.
       END METHOD getApplicantMiddleName.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantMiddleName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsApplicantMiddleName       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantMiddleName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-MIDDLE-NAME (lsIndex)
                          TO lsApplicantMiddleName.

           EXIT METHOD.
       END METHOD setApplicantMiddleName.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantLastName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsApplicantLastName         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantLastName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantLastName
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-LAST-NAME (lsIndex)
                      RETURNING lsApplicantLastName.

           EXIT METHOD.
       END METHOD getApplicantLastName.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantLastName.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsApplicantLastName             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantLastName.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-LAST-NAME (lsIndex) TO lsApplicantLastName.

           EXIT METHOD.
       END METHOD setApplicantLastName.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantAddressLine1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine1            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppAddrLine1.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppAddrLine1
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-ADDR-LINE-1 (lsIndex)
                       RETURNING lsAppAddrLine1.

           EXIT METHOD.
       END METHOD getApplicantAddressLine1.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantAddressLine1.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine1            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppAddrLine1.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-ADDR-LINE-1 (lsIndex)
                            TO lsAppAddrLine1.

           EXIT METHOD.
       END METHOD setApplicantAddressLine1.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantAddressLine2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine2            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppAddrLine2.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppAddrLine2
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-ADDR-LINE-2 (lsIndex)
                       RETURNING lsAppAddrLine2.

           EXIT METHOD.
       END METHOD getApplicantAddressLine2.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantAddressLine2.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine2            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppAddrLine2.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-ADDR-LINE-2 (lsIndex)
                            TO lsAppAddrLine2.

           EXIT METHOD.
       END METHOD setApplicantAddressLine2.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantAddressLine3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine3            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppAddrLine3.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppAddrLine3
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-ADDR-LINE-3 (lsIndex)
                       RETURNING lsAppAddrLine3.

           EXIT METHOD.
       END METHOD getApplicantAddressLine3.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantAddressLine3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAppAddrLine3            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppAddrLine3.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-ADDR-LINE-3 (lsIndex)
                            TO lsAppAddrLine3.

           EXIT METHOD.
       END METHOD setApplicantAddressLine3.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantCity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppCity            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppCity.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppCity
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-CITY (lsIndex)
                       RETURNING lsAppCity.

           EXIT METHOD.
       END METHOD getApplicantCity.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantCity.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppCity            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppCity.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-CITY (lsIndex)
                            TO lsAppCity.

           EXIT METHOD.
       END METHOD setApplicantCity.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppState            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppState.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppState
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-STATE (lsIndex)
                       RETURNING lsAppState.

           EXIT METHOD.
       END METHOD getApplicantState.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppState            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppState.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-STATE (lsIndex)
                            TO lsAppState.

           EXIT METHOD.
       END METHOD setApplicantState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantZip.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppZip            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppZip.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppZip
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-ZIP (lsIndex)
                       RETURNING lsAppZip.

           EXIT METHOD.
       END METHOD getApplicantZip.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantZip.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppZip            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppZip.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-ZIP (lsIndex)
                            TO lsAppZip.

           EXIT METHOD.
       END METHOD setApplicantZip.

      **************************************************************************
      **************************************************************************

       METHOD-ID. getApplicantBoxNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppBoxNumber       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppBoxNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppBoxNumber
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-BOX-NUMBER (lsIndex)
                       RETURNING lsAppBoxNumber.

           EXIT METHOD.
       END METHOD getApplicantBoxNumber.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantBoxNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsApplicantBoxNumber            OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantBoxNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-BOX-NUMBER (lsIndex)
                            TO lsApplicantBoxNumber.

           EXIT METHOD.
       END METHOD setApplicantBoxNumber.

      **************************************************************************
      **************************************************************************

      **************************************************************************
      **************************************************************************

       METHOD-ID. getApplicantZipExtension.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppZipExtension       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppZipExtension.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppZipExtension
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-ZIP-EXTENSION (lsIndex)
                       RETURNING lsAppZipExtension.

           EXIT METHOD.
       END METHOD getApplicantZipExtension.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantZipExtension.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsApplicantZipExtension  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantZipExtension.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-ZIP-EXTENSION (lsIndex)
                            TO lsApplicantZipExtension.

           EXIT METHOD.
       END METHOD setApplicantZipExtension.

      **************************************************************************
      **************************************************************************


       METHOD-ID. getApplicantSSN.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppSocSecNumber    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAppSocSecNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsAppSocSecNumber
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-SOC-SEC-NUMBER (lsIndex)
                   RETURNING lsAppSocSecNumber.

           EXIT METHOD.
       END METHOD getApplicantSSN.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantSSN.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex              PIC S9(09) COMP-5.
       01  lsAppSocSecNumber    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppSocSecNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-SOC-SEC-NUMBER (lsIndex)
                            TO lsAppSocSecNumber.

           EXIT METHOD.
       END METHOD setApplicantSSN.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantPhone.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsAppPhoneNumber               PIC S9(18) COMP-5.
       PROCEDURE DIVISION    USING BY VALUE lsIndex
                             RETURNING lsAppPhoneNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               MOVE ZERO TO lsAppPhoneNumber
           ELSE
               MOVE WCINB-APP-PHONE-NUMBER (lsIndex)
                         TO lsAppPhoneNumber.

           EXIT METHOD.
       END METHOD getApplicantPhone.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantPhone.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsAppPhoneNumber             PIC S9(18) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppPhoneNumber.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               MOVE lsAppPhoneNumber
                         TO WCINB-APP-PHONE-NUMBER (lsIndex).

           EXIT METHOD.
       END METHOD setApplicantPhone.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantDOB.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsAppDateOfBirth               PIC S9(09) COMP-5.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsAppDateOfBirth.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               MOVE ZERO TO WCINB-APP-DATE-OF-BIRTH (lsIndex)
           ELSE
               MOVE WCINB-APP-DATE-OF-BIRTH (lsIndex)
                                    TO lsAppDateOfBirth.

           EXIT METHOD.
       END METHOD getApplicantDOB.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantDOB.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsAppDateOfBirth             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAppDateOfBirth.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               MOVE lsAppDateOfBirth
                            TO WCINB-APP-DATE-OF-BIRTH (lsIndex).

           EXIT METHOD.
       END METHOD setApplicantDOB.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantGender.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsApplicantGender               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantGender.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantGender
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-SEX-CODE (lsIndex)
                      RETURNING lsApplicantGender.

           EXIT METHOD.
       END METHOD getApplicantGender.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantGender.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsApplicantGender             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantGender.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-SEX-CODE (lsIndex)
                               TO lsApplicantGender.

           EXIT METHOD.
       END METHOD setApplicantGender.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantUWCLS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex             PIC S9(09) COMP-5.
       01  lsApplicantUWCLS          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantUWCLS.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantUWCLS
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-UWCLS (lsIndex)
                       RETURNING lsApplicantUWCLS.

           EXIT METHOD.
       END METHOD getApplicantUWCLS.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantUWCLS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsApplicantUWCLS             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantUWCLS.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-UWCLS (lsIndex) TO lsApplicantUWCLS.

           EXIT METHOD.
       END METHOD setApplicantUWCLS.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantBorrowerType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                         PIC S9(09) COMP-5.
       01  lsApplicantBorrowerType         OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantBorrowerType.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantBorrowerType
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-BORROWER-TYPE (lsIndex)
                       RETURNING lsApplicantBorrowerType.

           EXIT METHOD.
       END METHOD getApplicantBorrowerType.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantBorrowerType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsApplicantBorrowerType        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantBorrowerType.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-BORROWER-TYPE (lsIndex)
                            TO lsApplicantBorrowerType.

           EXIT METHOD.
       END METHOD setApplicantBorrowerType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantCreditLife.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsApplicantCreditLife     OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantCreditLife.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsApplicantCreditLife
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-CREDIT-LIFE-FLAG (lsIndex)
                       RETURNING lsApplicantCreditLife.

           EXIT METHOD.
       END METHOD getApplicantCreditLife.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantCreditLife.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsApplicantCreditLife   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantCreditLife.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-CREDIT-LIFE-FLAG (lsIndex)
                               TO lsApplicantCreditLife.

           EXIT METHOD.
       END METHOD setApplicantCreditLife.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantCreditDisability.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                       PIC S9(09) COMP-5.
       01  lsApplicantCreditDisability   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                RETURNING lsApplicantCreditDisability.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
              INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                   RETURNING lsApplicantCreditDisability
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-CREDIT-DISAB-FLAG (lsIndex)
                       RETURNING lsApplicantCreditDisability.

           EXIT METHOD.
       END METHOD getApplicantCreditDisability.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantCreditDisability.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsApplicantCreditDisability  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantCreditDisability.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-CREDIT-DISAB-FLAG (lsIndex)
                               TO lsApplicantCreditDisability.

           EXIT METHOD.
       END METHOD setApplicantCreditDisability.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantUnemployment.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsApplicantUnemployment  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsApplicantUnemployment.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsApplicantUnemployment
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-UNEMPLOYMENT-FLAG (lsIndex)
                       RETURNING lsApplicantUnemployment.

           EXIT METHOD.
       END METHOD getApplicantUnemployment.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantUnemployment.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsApplicantUnemployment    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantUnemployment.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-UNEMPLOYMENT-FLAG (lsIndex)
                            TO lsApplicantUnemployment.

           EXIT METHOD.
       END METHOD setApplicantUnemployment.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantOccupationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsApplicantOccupationCode   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsApplicantOccupationCode.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsApplicantOccupationCode
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-OCCUPATION-CODE (lsIndex)
                       RETURNING lsApplicantOccupationCode.

           EXIT METHOD.
       END METHOD getApplicantOccupationCode.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantOccupationCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsApplicantOccupationCode    OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantOccupationCode.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-OCCUPATION-CODE (lsIndex)
                                    TO lsApplicantOccupationCode.

           EXIT METHOD.
       END METHOD setApplicantOccupationCode.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantEmploymentStatus.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsApplicantEmploymentStatus  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                RETURNING lsApplicantEmploymentStatus.


           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsApplicantEmploymentStatus
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-EMPLOYMENT-STATUS (lsIndex)
                       RETURNING lsApplicantEmploymentStatus.

           EXIT METHOD.
       END METHOD getApplicantEmploymentStatus.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantEmploymentStatus.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsApplicantEmploymentStatus  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantEmploymentStatus.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-EMPLOYMENT-STATUS (lsIndex)
                            TO lsApplicantEmploymentStatus.

           EXIT METHOD.
       END METHOD setApplicantEmploymentStatus.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getApplicantHoursWorked.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsApplicantHoursWorked OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsApplicantHoursWorked.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsApplicantHoursWorked
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-APP-HOURS-WORKED (lsIndex)
                       RETURNING lsApplicantHoursWorked.

           EXIT METHOD.
       END METHOD getApplicantHoursWorked.
      *-------------------------------------------------------------------------
       METHOD-ID. setApplicantHoursWorked.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                      PIC S9(09) COMP-5.
       01  lsApplicantHoursWorked       OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsApplicantHoursWorked.

           IF lsIndex < 1 OR lsIndex > MAX-APPLICANT
               CONTINUE
           ELSE
               SET WCINB-APP-HOURS-WORKED (lsIndex)
                                    TO lsApplicantHoursWorked.

           EXIT METHOD.
       END METHOD setApplicantHoursWorked.
      **************************************************************************
      *  The remaining properties are output only. 
      **************************************************************************      

       METHOD-ID. getReturnCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReturnCode               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsReturnCode.

           MOVE WCINB-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.
       END METHOD getReturnCode.
      *-------------------------------------------------------------------------
       METHOD-ID. getReturnMessage.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReturnMessage               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsReturnMessage.

           INVOKE CLASS-STRING "NEW" USING
               BY VALUE WCINB-ERROR-MESSAGE
                   RETURNING lsReturnMessage.

           EXIT METHOD.
       END METHOD getReturnMessage.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getLastError.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsLastError               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsLastError.

           MOVE WCINB-LAST-ERROR TO lsLastError.

           EXIT METHOD.
       END METHOD getLastError.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getErrorNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsErrorNumber               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsErrorNumber.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsErrorNumber
           ELSE
               MOVE WCINB-ERROR-NUMBER (lsIndex)
                               TO lsErrorNumber.

           EXIT METHOD.
       END METHOD getErrorNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getErrorType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsErrorType               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                RETURNING lsErrorType.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsErrorType
           ELSE
032608         IF WCINB-ERROR-TYPE (lsIndex) = 'D'
032608*            Expand code to equivalent description.  
032608             INVOKE CLASS-STRING "NEW" USING
032608                 BY VALUE WS-DATA
032608                     RETURNING lsErrorType
032608         ELSE
032608             INVOKE CLASS-STRING "NEW" USING
032608                 BY VALUE WS-ELIGIBILITY
032608                     RETURNING lsErrorType
032608         END-IF

           EXIT METHOD.
       END METHOD getErrorType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getErrorCoverageType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                    PIC S9(09) COMP-5.
       01  lsErrorCoverageType        OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsErrorCoverageType.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsErrorCoverageType
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-ERROR-COVERAGE-TYPE (lsIndex)
                       RETURNING lsErrorCoverageType.

           EXIT METHOD.
       END METHOD getErrorCoverageType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getErrorMessage.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsErrorMessage               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsErrorMessage.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsErrorMessage
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-DET-ERROR-MSG (lsIndex)
                       RETURNING lsErrorMessage.

           EXIT METHOD.
       END METHOD getErrorMessage.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getCoverageAmount.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsCoverageAmount               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsCoverageAmount.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsCoverageAmount
           ELSE
               MOVE WCINB-COVERAGE-AMOUNT (lsIndex)
                                   TO lsCoverageAmount.

           EXIT METHOD.
       END METHOD getCoverageAmount.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTermOfCoverage.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                         PIC S9(09) COMP-5.
       01  lsTermOfCoverage               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsTermOfCoverage.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsTermOfCoverage
           ELSE
               MOVE WCINB-OUT-COVERAGE-TERM (lsIndex)
                           TO lsTermOfCoverage.

           EXIT METHOD.
       END METHOD getTermOfCoverage.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getPremiumType.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                 PIC S9(09) COMP-5.
       01  lsPremiumType           OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsPremiumType.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
                INVOKE CLASS-STRING "NEW" USING
                   BY VALUE ' '
                       RETURNING lsPremiumType
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-PREMIUM-TYPE (lsIndex)
                       RETURNING lsPremiumType.

           EXIT METHOD.
       END METHOD getPremiumType.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMonthlySinglePremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                              PIC S9(09) COMP-5.
       01  lsMonthlySinglePremium               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsMonthlySinglePremium.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsMonthlySinglePremium
           ELSE
               MOVE WCINB-MONTHLY-SINGLE-PREMIUM (lsIndex)
                           TO lsMonthlySinglePremium.

           EXIT METHOD.
       END METHOD getMonthlySinglePremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMonthlyJointPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsMonthlyJointPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsMonthlyJointPremium.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsMonthlyJointPremium
           ELSE
               MOVE WCINB-MONTHLY-JOINT-PREMIUM (lsIndex)
                           TO lsMonthlyJointPremium.

           EXIT METHOD.
       END METHOD getMonthlyJointPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getMonthlyBilledPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                              PIC S9(09) COMP-5.
       01  lsMonthlyBilledPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsMonthlyBilledPremium.
           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsMonthlyBilledPremium
           ELSE
               MOVE WCINB-MONTHLY-BILLED-PREMIUM (lsIndex)
                               TO lsMonthlyBilledPremium.

           EXIT METHOD.
       END METHOD getMonthlyBilledPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllSinglePremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsAllSinglePremium               USAGE IS COMP-2.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsAllSinglePremium.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsAllSinglePremium
           ELSE
               MOVE WCINB-ALL-SINGLE-PREMIUM (lsIndex)
                           TO lsAllSinglePremium.

           EXIT METHOD.
       END METHOD getAllSinglePremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllJointPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                        PIC S9(09) COMP-5.
       01  lsAllJointPremium              USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAllJointPremium.

            IF lsIndex < 1 OR lsIndex > MAX-ERROR
                MOVE ZERO TO lsAllJointPremium
            ELSE
                MOVE WCINB-ALL-JOINT-PREMIUM (lsIndex)
                           TO lsAllJointPremium.

           EXIT METHOD.
       END METHOD getAllJointPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getAllBilledPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                          PIC S9(09) COMP-5.
       01  lsAllBilledPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsAllBilledPremium.

           IF lsIndex < 1 OR lsIndex > MAX-ERROR
               MOVE ZERO TO lsAllBilledPremium
           ELSE
               MOVE WCINB-ALL-BILLED-PREMIUM (lsIndex)
                               TO lsAllBilledPremium.

           EXIT METHOD.
       END METHOD getAllBilledPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalMonthlySinglePremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalMonthlySinglePremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalMonthlySinglePremium.

           MOVE WCINB-TOT-MONTHLY-SINGLE
                               TO lsTotalMonthlySinglePremium.

           EXIT METHOD.
       END METHOD getTotalMonthlySinglePremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalMonthlyJointPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalMonthlyJointPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalMonthlyJointPremium.

               MOVE WCINB-TOT-MONTHLY-JOINT
                               TO lsTotalMonthlyJointPremium.
           EXIT METHOD.
       END METHOD getTotalMonthlyJointPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalMonthlyBilledPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalMonthlyBilledPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalMonthlyBilledPremium.

               MOVE WCINB-TOT-MONTHLY-BILLED
                               TO lsTotalMonthlyBilledPremium.

           EXIT METHOD.
       END METHOD getTotalMonthlyBilledPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalAllSinglePremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalAllSinglePremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalAllSinglePremium.

               MOVE WCINB-TOT-ALL-SINGLE
                               TO lsTotalAllSinglePremium.

           EXIT METHOD.
       END METHOD getTotalAllSinglePremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalAllJointPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalAllJointPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalAllJointPremium.

               MOVE WCINB-TOT-ALL-JOINT
                           TO lsTotalAllJointPremium.

           EXIT METHOD.
       END METHOD getTotalAllJointPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getTotalAllBilledPremium.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsTotalAllBilledPremium               USAGE IS COMP-2.
       PROCEDURE DIVISION RETURNING lsTotalAllBilledPremium.

           MOVE WCINB-TOT-ALL-BILLED
                           TO lsTotalAllBilledPremium.
           EXIT METHOD.
       END METHOD getTotalAllBilledPremium.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getGeneratedPolicyNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsGeneratedPolicyNumber   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  RETURNING lsGeneratedPolicyNumber.

               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-OUT-POLICY-NUMBER
                       RETURNING lsGeneratedPolicyNumber.

           EXIT METHOD.
       END METHOD getGeneratedPolicyNumber.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getOutputIssueState.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsOutputIssueState OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  RETURNING lsOutputIssueState.

               INVOKE CLASS-STRING "NEW" USING
                   BY VALUE WCINB-OUT-ISSUE-STATE
                       RETURNING lsOutputIssueState.

           EXIT METHOD.
       END METHOD getOutputIssueState.
      **************************************************************************
      **************************************************************************
       METHOD-ID. getOutputInceptionDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsOutputInceptionDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsOutputInceptionDate.

           MOVE WCINB-OUT-INCEPTION-DATE
                       TO lsOutputInceptionDate.

           EXIT METHOD.
       END METHOD getOutputInceptionDate.
      **************************************************************************
      **************************************************************************

060308 METHOD-ID. getYEIRequested.
060308 DATA DIVISION.
060308 WORKING-STORAGE SECTION.
060308 LINKAGE SECTION.
060308 01  lsIndex1                PIC S9(09) COMP-5.
060308 01  lsIndex2                PIC S9(09) COMP-5.
060308 01  lsYEIFlag               OBJECT REFERENCE CLASS-STRING.
060308 PROCEDURE DIVISION   USING BY VALUE lsIndex1
060308                            BY VALUE lsIndex2
060308                      RETURNING lsYEIFlag.
060308
060308     IF ( lsIndex1 < 1 OR lsIndex1 > 2 ) OR
060308        ( lsIndex2 < 1 OR lsIndex2 > 2 )
060308         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
060308              RETURNING lsYEIFlag
060308     ELSE
060308         INVOKE CLASS-STRING "NEW" USING
060308             BY VALUE WCINB-YEI-REQUESTED (lsIndex1, lsIndex2)
060308             RETURNING lsYEIFlag.
060308
060308     EXIT METHOD.
060308 END METHOD getYEIRequested.
060308
060308**************************************************************************
060308**************************************************************************
060308
060308 METHOD-ID. getYEIAllowed.
060308 DATA DIVISION.
060308 WORKING-STORAGE SECTION.
060308 LINKAGE SECTION.
060308 01  lsIndex1                PIC S9(09) COMP-5.
060308 01  lsIndex2                PIC S9(09) COMP-5.
060308 01  lsYEIFlag               OBJECT REFERENCE CLASS-STRING.
060308 PROCEDURE DIVISION   USING BY VALUE lsIndex1
060308                            BY VALUE lsIndex2
060308                      RETURNING lsYEIFlag.
060308
060308     IF ( lsIndex1 < 1 OR lsIndex1 > 2 ) OR
060308        ( lsIndex2 < 1 OR lsIndex2 > 2 )
060308         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
060308              RETURNING lsYEIFlag
060308     ELSE
060308         INVOKE CLASS-STRING "NEW" USING
060308             BY VALUE WCINB-YEI-ALLOWED (lsIndex1, lsIndex2)
060308             RETURNING lsYEIFlag.
060308
060308     EXIT METHOD.
060308 END METHOD getYEIAllowed.

       END OBJECT.
       END CLASS OCINEWBS.
