       IDENTIFICATION DIVISION.
       CLASS-ID. OBALINQU AS "LPNETAPI.OBALINQU".
      *AUTHOR.         PDMA.
      *DATE-WRITTEN.   December 2004.
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
      *D API object that retrieves balance inquiry information.  This
      *D corresponds with screen SBIFBCPY, managed by program PBINQDIS.
      *D Since PBINQDIS is a screen program, it will not be called here,
      *D but the methods and "black boxes" it uses to retrieve information
      *D will be used here as well.
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
051105*H 20030206-003-01 DAR Add Loan API Support
062705*H 20050128-004-01 DAR Retrofit 20030410-006-01 and 20030206-003-01
032907*H 20070329-004-01 DAR Increase WGLOB length.
081307*H 20060720-003-01 KAM Expand Fund Package
081407*H 20060720-003-01 KAM Expand Fund Package - WFNDV
101207*H 20071001-002-01 DAR Additional fund package fixes
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
101812*H 20120706-004-01 DAR Added Bucket detail table to output
111212*H 20120706-004-01 DAR Added total cost basis and pre tefra basis
122613*H 20100901-003-01 TJO Enhancements to include additional rate information
032614*H 20140220-005-01 DAR Allow Future Quoting 
050814*H 20140220-006-01 DAR Add Guaranteed Withdrawal values
061714*H 20140220-008-01 DAR Add additional bucket-level values
101414*H 20141010-004-01 DAR Add additional GW values and Source Summary
122914*H 20141010-004-01 DAR Add additional GW values
021615*H 20141010-004-01 Add Gross Source and Model Status values
052215*H 20141110-008-08 TJO RFIA
062615*H 20121115-004-02 DAR Add Last Anniversary Date 
072515*H 20131010-019-01 DAR Return Guar Retirement Balance Due
090315*H 20131010-019-01 DAR Add Guar Retirement Overdue Details
093015*H 20131010-019-01 DAR Add additional summary level values
102315*H 20131010-019-01 DAR Add Rate History properties 
021816*H 20151130-001-01 GWT MH Model/Sub-Model/Profile Info
033116*H 20131010-019-01 DAR Add Rollup To Date 
041516*H 20131010-019-01 DAR Add Rider Fee Change Date
041516*H                     and GR Billing Modal Amount 
091916*H 20150805-006-36 SAP Invest Next phase 2
101716*H 20131010-019-01 DAR Separate functions so that they can be called independently. 
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
092308     05  PQUOTDRV                 PIC X(08) VALUE 'PQUOTDRV'.

032614 01  SAVE-INTERFACE-FLAG              PIC X(01).
032614 01  SAVE-FUTURE-REQUEST-FLAG         PIC X(01).
032614 01  SAVE-ORIG-FUTURE-REQUEST-FLAG    PIC X(01).

081407 COPY WGLB2CPY.

       COPY WGLOBCPY.
       COPY WGLBXCPY.

      *  WBALICPY contains linkage to PROCDRVR, which does all PROCQUOT and
      *  other calls required.  This allows all work to be done in one "native"
      *  code pass, thus preserving working storage, etc., and making everything
      *  more efficient.
       COPY WBALICPY.

       COPY WPRCTCPY.
       COPY WFNDVCPY.
       COPY LSREQCPY.
051105 COPY LCOVRCPY.

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
           MOVE wsReturnCode to WBALI-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WBALI-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WBALI-ERROR-MESSAGE.

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

           MOVE wsReturnCode to WBALI-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WBALI-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WBALI-ERROR-MESSAGE.

       END METHOD Dispose.

      ******************************************************************
       METHOD-ID. RunInquiry.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
      *    Note that comp-5 maps to the Int32 CLR type.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WBALI-SOURCE-BALANCES TO TRUE.

032614     MOVE WGLOB-INTERFACE-FLAG TO SAVE-INTERFACE-FLAG
032614     MOVE WGLOB-API-FUTURE-REQUEST-FLAG
032614                               TO SAVE-ORIG-FUTURE-REQUEST-FLAG
032614     SET WGLOB-API-BALANCE-INQUIRY TO TRUE
032614     MOVE SAVE-FUTURE-REQUEST-FLAG
032614                TO WGLOB-API-FUTURE-REQUEST-FLAG


      *    Only BALI is used in this object.  The other parameters from PQUOTDRV are used
      *    when OSYSRQST calls this module for systematics.
021709     TRY
092308         CALL PQUOTDRV  USING WGLOBAL
092308                              WBALI-PARAMETERS
092308                              WPRCT-PARMS-1
092308                              WPRCT-PARMS-2
092308                              WPRCT-PARMS-3
092308                              WPRCT-PARMS-4
092308                              WPRCT-PARMS-5
092308                              WPRCT-PARMS-6
092308                              WPRCT-PARMS-7
092308                              WFNDV-PARAMETERS
092308                              LSREQ-PARMS
092308                              LCOVR-DATA-RECORD
021709         MOVE WBALI-RETURN-CODE TO lsReturnCode
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      WBALI-RETURN-CODE
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO WBALI-ERROR-MESSAGE
021709     END-TRY.

032614     MOVE SAVE-INTERFACE-FLAG TO WGLOB-INTERFACE-FLAG
032614     MOVE SAVE-ORIG-FUTURE-REQUEST-FLAG
032614                              TO WGLOB-API-FUTURE-REQUEST-FLAG.

062705*    INVOKE LpApp "ReleaseClient".

           EXIT METHOD.

      ******************************************************************
       END METHOD RunInquiry.
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

           MOVE WBALI-RETURN-CODE TO lsReturnCode.
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
           INVOKE CLASS-STRING "NEW" USING BY VALUE WBALI-ERROR-MESSAGE
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
           INVOKE CLASS-STRING "NEW" USING BY VALUE WBALI-COMPANY-CODE
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
           INVOKE CLASS-STRING "NEW" USING BY VALUE WBALI-POLICY-NUMBER
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

       01 lsEffectiveDate        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsEffectiveDate.
      ******************************************************************
           MOVE WBALI-RQST-DATE to lsEffectiveDate.

           EXIT METHOD.
       END METHOD getEffectiveDate.

      ******************************************************************
      * The following get Methods are for data items output from the
      * inquiry process.  These are pulled from the WBALICPY copybook.
      *******************************************************************

       METHOD-ID. getActiveRequests.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.
       01  lsActiveRequests        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsActiveRequests.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                       BY VALUE WBALI-ACTIVE-REQUESTS-FLAG
                RETURNING lsActiveRequests.

           EXIT METHOD.

       END METHOD getActiveRequests.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getMultipleLoans.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsMultipleLoans        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsMultipleLoans.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                       BY VALUE WBALI-MULTIPLE-LOANS-FLAG
                RETURNING lsMultipleLoans.

           EXIT METHOD.

       END METHOD getMultipleLoans.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getQuoteDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsQuoteDate        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsQuoteDate.
      ******************************************************************
           MOVE WBALI-QUOTE-DATE to lsQuoteDate.

           EXIT METHOD.

       END METHOD getQuoteDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getProcessToDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsProcessToDate        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsProcessToDate.
      ******************************************************************
           MOVE WBALI-PROC-TO-DATE to lsProcessToDate.

           EXIT METHOD.

       END METHOD getProcessToDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLastValuationDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsLastValuationDate        PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLastValuationDate.
      ******************************************************************
           MOVE WBALI-LAST-VAL-DATE to lsLastValuationDate.

           EXIT METHOD.

       END METHOD getLastValuationDate.
062615******************************************************************
062615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062615******************************************************************
062615 METHOD-ID. getLastAnniversaryDate.
062615 DATA DIVISION.
062615******************************************************************
062615 WORKING-STORAGE SECTION.
062615******************************************************************
062615 LINKAGE SECTION.
062615
062615 01 lsLastAnniversaryDate        PIC S9(09) COMP-5.
062615
062615******************************************************************
062615 PROCEDURE DIVISION RETURNING lsLastAnniversaryDate.
062615******************************************************************
062615     MOVE WBALI-LAST-ANNIVERSARY-DATE
062615           TO lsLastAnniversaryDate.
062615
062615     EXIT METHOD.
062615
062615 END METHOD getLastAnniversaryDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getGrossDeposits.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsGrossDeposits          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsGrossDeposits.
      ******************************************************************

           MOVE WBALI-GROSS-DEPOSITS TO lsGrossDeposits.

           EXIT METHOD.

       END METHOD getGrossDeposits.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getGrossWithdrawals.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsGrossWithdrawals          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsGrossWithdrawals.
      ******************************************************************

           MOVE WBALI-GROSS-WITHDRAWALS TO lsGrossWithdrawals.

           EXIT METHOD.

       END METHOD getGrossWithdrawals.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getLoanBalance.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsLoanBalance          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsLoanBalance.
      ******************************************************************

           MOVE WBALI-LOAN-BALANCE TO lsLoanBalance.

           EXIT METHOD.

       END METHOD getLoanBalance.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getTotalFundBalance.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsTotalFundBalance          USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsTotalFundBalance.
      ******************************************************************

           MOVE WBALI-TOTAL-FUND-BALANCE TO lsTotalFundBalance.

           EXIT METHOD.

       END METHOD getTotalFundBalance.

111212******************************************************************
111212*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111212******************************************************************
111212 METHOD-ID. getTotalCostBasis.
111212 DATA DIVISION.
111212******************************************************************
111212 WORKING-STORAGE SECTION.
111212******************************************************************
111212 LINKAGE SECTION.
111212
111212 01 lsTotalCostBasis          USAGE COMP-2.
111212
111212******************************************************************
111212 PROCEDURE DIVISION RETURNING lsTotalCostBasis.
111212******************************************************************
111212
111212     MOVE WBALI-TOTAL-COST-BASIS TO lsTotalCostBasis.
111212
111212     EXIT METHOD.
111212
111212 END METHOD getTotalCostBasis.
111212
111212******************************************************************
111212*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
111212******************************************************************
111212 METHOD-ID. getPreTefraCostBasis.
111212 DATA DIVISION.
111212******************************************************************
111212 WORKING-STORAGE SECTION.
111212******************************************************************
111212 LINKAGE SECTION.
111212
111212 01 lsPreTefraCostBasis          USAGE COMP-2.
111212
111212******************************************************************
111212 PROCEDURE DIVISION RETURNING lsPreTefraCostBasis.
111212******************************************************************
111212
111212     MOVE WBALI-PRE-TEFRA-COST-BASIS TO lsPreTefraCostBasis.
111212
111212     EXIT METHOD.
111212
111212 END METHOD getPreTefraCostBasis.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getCurrentEarningsRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsCurrentEarningsRate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsCurrentEarningsRate.
122613******************************************************************
122613
122613     MOVE WBALI-CURR-EARNINGS-RATE TO lsCurrentEarningsRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getCurrentEarningsRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getIndexEarningsRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndexEarningsRate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsIndexEarningsRate.
122613******************************************************************
122613
122613     MOVE WBALI-INDEX-EARNINGS-RATE TO lsIndexEarningsRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getIndexEarningsRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getGuarEarningsRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsGuarEarningsRate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsGuarEarningsRate.
122613******************************************************************
122613
122613     MOVE WBALI-GUAR-EARNINGS-RATE TO lsGuarEarningsRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getGuarEarningsRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getCurrentEarningsAmountToDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsCurrentEarningsAmountToDate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsCurrentEarningsAmountToDate.
122613******************************************************************
122613
122613     MOVE WBALI-CURR-EARNINGS-TO-DATE
122613       TO lsCurrentEarningsAmountToDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getCurrentEarningsAmountToDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getIndexEarningsAmountToDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndexEarningsAmountToDate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsIndexEarningsAmountToDate.
122613******************************************************************
122613
122613     MOVE WBALI-INDEX-EARNINGS-TO-DATE
122613       TO lsIndexEarningsAmountToDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getIndexEarningsAmountToDate.


021615******************************************************************
021615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021615******************************************************************
021615 METHOD-ID. getAssetAllocationModelFlag.
021615 DATA DIVISION.
021615******************************************************************
021615 WORKING-STORAGE SECTION.
021615******************************************************************
021615 LINKAGE SECTION.
021615
021615 01 lsAssetAllocationModelFlag   OBJECT REFERENCE CLASS-STRING.
021615
021615******************************************************************
021615 PROCEDURE DIVISION RETURNING lsAssetAllocationModelFlag.
021615******************************************************************
021615
021615     SET lsAssetAllocationModelFlag TO WBALI-AA-MODEL-FLAG.
021615
021615     EXIT METHOD.
021615
021615 END METHOD getAssetAllocationModelFlag.
021615
021615******************************************************************
021615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021615******************************************************************
021615 METHOD-ID. getAssetAllocationModelStatus.
021615 DATA DIVISION.
021615******************************************************************
021615 WORKING-STORAGE SECTION.
021615******************************************************************
021615 LINKAGE SECTION.
021615
021615 01 lsAssetAllocationModelStatus   OBJECT REFERENCE CLASS-STRING.
021615
021615******************************************************************
021615 PROCEDURE DIVISION RETURNING lsAssetAllocationModelStatus.
021615******************************************************************
021615
021615     SET lsAssetAllocationModelStatus TO WBALI-MODEL-STATUS.
021615
021615     EXIT METHOD.
021615
021615 END METHOD getAssetAllocationModelStatus.

021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getProfileID.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsProfileID                 OBJECT REFERENCE CLASS-STRING.
021816
021816******************************************************************
021816 PROCEDURE DIVISION RETURNING lsProfileID.
021816******************************************************************
021816
021816     INVOKE CLASS-STRING "NEW" USING
021816                 BY VALUE WBALI-PROFILE-ID
021816          RETURNING lsProfileID.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getProfileID.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getProfileDesc.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsProfileDesc               OBJECT REFERENCE CLASS-STRING.
021816
021816******************************************************************
021816 PROCEDURE DIVISION RETURNING lsProfileDesc.
021816******************************************************************
021816
021816     INVOKE CLASS-STRING "NEW" USING
021816                 BY VALUE WBALI-PROFILE-DESC
021816          RETURNING lsProfileDesc.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getProfileDesc.
021816
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getFinancialRptInd.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsFinancialRptInd         OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsFinancialRptInd.
091916******************************************************************
091916
091916    INVOKE CLASS-STRING "NEW" USING
091916                BY VALUE WBALI-FINANCIAL-RPT-IND
091916         RETURNING lsFinancialRptInd.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getFinancialRptInd.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getPolicyCode.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsPolicyCode              OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsPolicyCode.
091916******************************************************************
091916
091916    INVOKE CLASS-STRING "NEW" USING
091916                BY VALUE WBALI-POLICY-CODE
091916         RETURNING lsPolicyCode.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getPolicyCode.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getPolicyMatureExpDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsPolicyMatureExpDate     PIC S9(9) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsPolicyMatureExpDate.
091916******************************************************************
091916
091916    MOVE WBALI-POLICY-MATURE-EXP-DATE TO lsPolicyMatureExpDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getPolicyMatureExpDate.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getPolicyRebalFlag.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsPolicyRebalFlag         OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsPolicyRebalFlag.
091916******************************************************************
091916
091916    INVOKE CLASS-STRING "NEW" USING
091916                BY VALUE WBALI-POLICY-REBAL-FLAG
091916         RETURNING lsPolicyRebalFlag.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getPolicyRebalFlag.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getPolicyRebalDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsPolicyRebalDate         PIC S9(9) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsPolicyRebalDate.
091916******************************************************************
091916
091916    MOVE WBALI-POLICY-REBAL-DATE TO lsPolicyRebalDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getPolicyRebalDate.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getHybridBOTDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsHybridBOTDate           PIC S9(9) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsHybridBOTDate.
091916******************************************************************
091916
091916    MOVE WBALI-HYBRID-BOT-DATE TO lsHybridBOTDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getHybridBOTDate.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getHybridEOTDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsHybridEOTDate           PIC S9(9) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsHybridEOTDate.
091916******************************************************************
091916
091916    MOVE WBALI-HYBRID-EOT-DATE TO lsHybridEOTDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getHybridEOTDate.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getHybridEOTHoldDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsHybridEOTHoldDate       PIC S9(9) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsHybridEOTHoldDate.
091916******************************************************************
091916
091916    MOVE WBALI-HYBRID-EOT-HOLD-DATE TO lsHybridEOTHoldDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getHybridEOTHoldDate.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getHybridHoldAcctStatus.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsHybridHoldAcctStatus    OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION RETURNING lsHybridHoldAcctStatus.
091916******************************************************************
091916
091916    INVOKE CLASS-STRING "NEW" USING
091916                BY VALUE WBALI-HYBRID-HOLD-ACCT-STATUS
091916         RETURNING lsHybridHoldAcctStatus.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getHybridHoldAcctStatus.
091916
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

           MOVE WBALI-LAST-LINE TO lsRowCount.
           EXIT METHOD.

       END METHOD getRowCount.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWResetStatus.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWResetStatus      OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWResetStatus.
050814******************************************************************
050814
050814     SET lsGWResetStatus TO WBALI-GW-RESET-STATUS.
050814     EXIT METHOD.
050814
050814 END METHOD getGWResetStatus.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdrawalBenAvailable.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalBenAvailable  OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWWithdrawalBenAvailable.
050814******************************************************************
050814
050814     SET lsGWWithdrawalBenAvailable
050814              TO WBALI-GW-WTD-BENEFIT-AVAIL
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalBenAvailable.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWSingleBenAvailable.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWSingleBenAvailable  OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWSingleBenAvailable.
050814******************************************************************
050814
050814     SET lsGWSingleBenAvailable
050814              TO WBALI-GW-SINGLE-BEN-FLAG
050814     EXIT METHOD.
050814
050814 END METHOD getGWSingleBenAvailable.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWJointBenAvailable.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWJointBenAvailable  OBJECT REFERENCE CLASS-STRING.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWJointBenAvailable.
050814******************************************************************
050814
050814     SET lsGWJointBenAvailable
050814              TO WBALI-GW-JOINT-BEN-FLAG
050814     EXIT METHOD.
050814
050814 END METHOD getGWJointBenAvailable.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdrawalEligiblePrems.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalEligiblePrems          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWWithdrawalEligiblePrems.
050814******************************************************************
050814
050814     MOVE WBALI-GW-WITHD-ELIGIBLE-PREMS
050814                     TO lsGWWithdrawalEligiblePrems.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalEligiblePrems.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWRemainingWithdrawalBen.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWRemainingWithdrawalBen          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWRemainingWithdrawalBen.
050814******************************************************************
050814
050814     MOVE WBALI-GW-REMAIN-WTD-BENEFIT
050814                     TO lsGWRemainingWithdrawalBen.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWRemainingWithdrawalBen.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdBenLastWithdDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdBenLastWithdDate     PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWWithdBenLastWithdDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-WITHD-LAST-WTD-DATE
050814                     TO lsGWWithdBenLastWithdDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdBenLastWithdDate.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdrawalExcessRMD.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalExcessRMD          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWWithdrawalExcessRMD.
050814******************************************************************
050814
050814     MOVE WBALI-GW-WITHD-CARRYOVER-RMD
050814                     TO lsGWWithdrawalExcessRMD.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalExcessRMD.



050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
101414 METHOD-ID. getGWLifeSingleLifetimeBasis.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
101414 01 lsGWLifeSingleLifetimeBasis          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWLifeSingleLifetimeBasis.
050814******************************************************************
050814
101414     MOVE WBALI-GW-SINGLE-LIFETIME-BASIS
101414                     TO lsGWLifeSingleLifetimeBasis.
050814
050814     EXIT METHOD.
050814
101414 END METHOD getGWLifeSingleLifetimeBasis.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleCarryoverAmount.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleCarryoverAmount          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWLifeSingleCarryoverAmount.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SINGLE-CARRYOVER-AMT
050814                     TO lsGWLifeSingleCarryoverAmount.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleCarryoverAmount.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleExcessRMD.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleExcessRMD          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING lsGWLifeSingleExcessRMD.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SINGLE-CARRYOVER-RMD
050814                     TO lsGWLifeSingleExcessRMD.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleExcessRMD.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleWithdrawals.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleWithdrawals          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleWithdrawals.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SINGLE-CUMULATIVE-WTD
050814                     TO lsGWLifeSingleWithdrawals.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleWithdrawals.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleLastWithdDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleLastWithdDate        PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleLastWithdDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SINGLE-LAST-WTD-DATE
050814                     TO lsGWLifeSingleLastWithdDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleLastWithdDate.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
101414 METHOD-ID. getGWLifeJointLifetimeBasis.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
101414 01 lsGWLifeJointLifetimeBasis          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointLifetimeBasis.
050814******************************************************************
050814
101414     MOVE WBALI-GW-JOINT-LIFETIME-BASIS
101414                TO lsGWLifeJointLifetimeBasis.
050814
050814     EXIT METHOD.
050814
101414 END METHOD getGWLifeJointLifetimeBasis.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointCarryoverAmount.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointCarryoverAmount          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointCarryoverAmount.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-CARRYOVER-AMT
050814                TO lsGWLifeJointCarryoverAmount.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointCarryoverAmount.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointExcessRMD.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointExcessRMD          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointExcessRMD.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-CARRYOVER-RMD
050814                TO lsGWLifeJointExcessRMD.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointExcessRMD.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointWithdrawals.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointWithdrawals          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointWithdrawals.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-CUMULATIVE-WTD
050814                TO lsGWLifeJointWithdrawals.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointWithdrawals.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdrawalGMWBPercentage.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalGMWBPercentage          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWWithdrawalGMWBPercentage.
050814******************************************************************
050814
050814     MOVE WBALI-GW-WITHD-GMWB-PCT
050814                TO lsGWWithdrawalGMWBPercentage.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalGMWBPercentage.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleGMWBPercentage.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleGMWBPercentage          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleGMWBPercentage.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SINGLE-GMWB-PCT
050814                TO lsGWLifeSingleGMWBPercentage.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleGMWBPercentage.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointGMWBPercentage.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointGMWBPercentage          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointGMWBPercentage.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-GMWB-PCT
050814                TO lsGWLifeJointGMWBPercentage.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointGMWBPercentage.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWWithdrawalAnnualBen.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalAnnualBen          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWWithdrawalAnnualBen.
050814******************************************************************
050814
050814     MOVE WBALI-GW-ANNUAL-WTD-BENEFIT
050814                TO lsGWWithdrawalAnnualBen.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalAnnualBen.
050814
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getGWWithdrawalAvailableAmount.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01 lsGWWithdrawalAvailableAmount          USAGE COMP-2.
101414
101414******************************************************************
101414 PROCEDURE DIVISION RETURNING
101414                 lsGWWithdrawalAvailableAmount.
101414******************************************************************
101414
101414     MOVE WBALI-GW-AVAIL-WTD-BENEFIT
101414                TO lsGWWithdrawalAvailableAmount.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getGWWithdrawalAvailableAmount.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleAnnualBen.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleAnnualBen          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleAnnualBen.
050814******************************************************************
050814
050814     MOVE WBALI-GW-ANNUAL-LIFE-SINGLE
050814                TO lsGWLifeSingleAnnualBen.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleAnnualBen.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointAnnualBen.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointAnnualBen          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointAnnualBen.
050814******************************************************************
050814
050814     MOVE WBALI-GW-ANNUAL-LIFE-JOINT
050814                TO lsGWLifeJointAnnualBen.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointAnnualBen.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeSingleAvailableAmt.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleAvailableAmt          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleAvailableAmt.
050814******************************************************************
050814
050814     MOVE WBALI-GW-AVAIL-LIFE-BEN-SINGLE
050814                TO lsGWLifeSingleAvailableAmt.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleAvailableAmt.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814 METHOD-ID. getGWLifeJointAvailableAmt.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointAvailableAmt          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointAvailableAmt.
050814******************************************************************
050814
050814     MOVE WBALI-GW-AVAIL-LIFE-BEN-JOINT
050814                TO lsGWLifeJointAvailableAmt.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointAvailableAmt.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWWithdrawalBenWithdrawals.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWWithdrawalBenWithdrawals          USAGE COMP-2.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWWithdrawalBenWithdrawals.
050814******************************************************************
050814
050814     MOVE WBALI-GW-WITHD-CUMULATIVE-WTD
050814                TO lsGWWithdrawalBenWithdrawals.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWWithdrawalBenWithdrawals.
050814
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWBenPhaseStartDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWBenPhaseStartDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWBenPhaseStartDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-BEN-PHASE-START-DATE
050814                TO lsGWBenPhaseStartDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWBenPhaseStartDate.
050814
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWLastResetDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLastResetDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLastResetDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-LAST-RESET-DATE
050814                TO lsGWLastResetDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLastResetDate.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWLifeSingleEarliestIncDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeSingleEarliestIncDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeSingleEarliestIncDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-SGL-EARLIEST-INC-DT
050814                TO lsGWLifeSingleEarliestIncDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeSingleEarliestIncDate.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWLifeJointEarliestIncDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointEarliestIncDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointEarliestIncDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-EARLIEST-INC-DT
050814                TO lsGWLifeJointEarliestIncDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointEarliestIncDate.
050814
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWLastPremiumDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLastPremiumDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLastPremiumDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-LAST-PREMIUM-DATE
050814                TO lsGWLastPremiumDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLastPremiumDate.
050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
050814
050814 METHOD-ID. getGWLifeJointLastWithdDate.
050814 DATA DIVISION.
050814******************************************************************
050814 WORKING-STORAGE SECTION.
050814******************************************************************
050814 LINKAGE SECTION.
050814
050814 01 lsGWLifeJointLastWithdDate          PIC S9(09) COMP-5.
050814
050814******************************************************************
050814 PROCEDURE DIVISION RETURNING
050814                 lsGWLifeJointLastWithdDate.
050814******************************************************************
050814
050814     MOVE WBALI-GW-JOINT-LAST-WTD-DATE
050814                TO lsGWLifeJointLastWithdDate.
050814
050814     EXIT METHOD.
050814
050814 END METHOD getGWLifeJointLastWithdDate.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
101414 METHOD-ID. getGWNextResetDate.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01 lsGWNextResetDate          PIC S9(09) COMP-5.
101414
101414******************************************************************
101414 PROCEDURE DIVISION RETURNING
101414                 lsGWNextResetDate.
101414******************************************************************
101414
101414     MOVE WBALI-GW-NEXT-RESET-DATE
101414                TO lsGWNextResetDate.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getGWNextResetDate.

122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleDepositBasis.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleDepositBasis          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeSingleDepositBasis.
122914******************************************************************
122914
122914     MOVE WBALI-GW-SINGLE-DEPOSIT-BASIS
122914                     TO lsGWLifeSingleDepositBasis.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleDepositBasis.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointDepositBasis.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointDepositBasis          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeJointDepositBasis.
122914******************************************************************
122914
122914     MOVE WBALI-GW-JOINT-DEPOSIT-BASIS
122914                     TO lsGWLifeJointDepositBasis.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointDepositBasis.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleDepositBonus.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleDepositBonus          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeSingleDepositBonus.
122914******************************************************************
122914
122914     MOVE WBALI-GW-SINGLE-DEPOSIT-BONUS
122914                     TO lsGWLifeSingleDepositBonus.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleDepositBonus.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointDepositBonus.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointDepositBonus          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeJointDepositBonus.
122914******************************************************************
122914
122914     MOVE WBALI-GW-JOINT-DEPOSIT-BONUS
122914                     TO lsGWLifeJointDepositBonus.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointDepositBonus.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleRolledUp.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleRolledUp          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeSingleRolledUp.
122914******************************************************************
122914
122914     MOVE WBALI-GW-SINGLE-ROLLED-UP
122914                TO lsGWLifeSingleRolledUp.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleRolledUp.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointRolledUp.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointRolledUp          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeJointRolledUp.
122914******************************************************************
122914
122914     MOVE WBALI-GW-JOINT-ROLLED-UP
122914                TO lsGWLifeJointRolledUp.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointRolledUp.
122914

033116******************************************************************
033116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
033116******************************************************************
033116 METHOD-ID. getGWLifeSingleRolledUpToDate.
033116 DATA DIVISION.
033116******************************************************************
033116 WORKING-STORAGE SECTION.
033116******************************************************************
033116 LINKAGE SECTION.
033116
033116 01 lsGWLifeSingleRolledUpToDate       PIC S9(09) COMP-5.
033116
033116******************************************************************
033116 PROCEDURE DIVISION RETURNING
033116                 lsGWLifeSingleRolledUpToDate.
033116******************************************************************
033116
033116     MOVE WBALI-GW-SINGLE-ROLLUP-TO-DATE
033116                TO lsGWLifeSingleRolledUpToDate.
033116
033116     EXIT METHOD.
033116
033116 END METHOD getGWLifeSingleRolledUpToDate.
033116
033116******************************************************************
033116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
033116******************************************************************
033116 METHOD-ID. getGWLifeJointRolledUpToDate.
033116 DATA DIVISION.
033116******************************************************************
033116 WORKING-STORAGE SECTION.
033116******************************************************************
033116 LINKAGE SECTION.
033116
033116 01 lsGWLifeJointRolledUpToDate       PIC S9(09) COMP-5.
033116
033116******************************************************************
033116 PROCEDURE DIVISION RETURNING
033116                 lsGWLifeJointRolledUpToDate.
033116******************************************************************
033116
033116     MOVE WBALI-GW-JOINT-ROLLUP-TO-DATE
033116                TO lsGWLifeJointRolledUpToDate.
033116
033116     EXIT METHOD.
033116
033116 END METHOD getGWLifeJointRolledUpToDate.
033116

122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleMaxAnniv.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleMaxAnniv        USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeSingleMaxAnniv.
122914******************************************************************
122914
122914     MOVE WBALI-GW-SINGLE-MAX-ANNIV
122914                TO lsGWLifeSingleMaxAnniv.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleMaxAnniv.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointMaxAnniv.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointMaxAnniv        USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeJointMaxAnniv.
122914******************************************************************
122914
122914     MOVE WBALI-GW-JOINT-MAX-ANNIV
122914                TO lsGWLifeJointMaxAnniv.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointMaxAnniv.


122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleDeathBasis.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
041516 01 lsGWLifeSingleDeathBasis          USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeSingleDeathBasis.
122914******************************************************************
122914
122914     MOVE WBALI-GW-SINGLE-DEATH-BASIS
122914                TO lsGWLifeSingleDeathBasis.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleDeathBasis.
122914
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointDeathBasis.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
041516 01 lsGWLifeJointDeathBasis         USAGE COMP-2.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeJointDeathBasis.
122914******************************************************************
122914
122914     MOVE WBALI-GW-JOINT-DEATH-BASIS
122914                TO lsGWLifeJointDeathBasis.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointDeathBasis.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleExcessWithd.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleExcessWithd    OBJECT REFERENCE CLASS-STRING.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeSingleExcessWithd.
122914******************************************************************
122914
122914     SET lsGWLifeSingleExcessWithd
122914                      TO WBALI-GW-SINGLE-EXCESS-WD-FLAG.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleExcessWithd.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointExcessWithd.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointExcessWithd    OBJECT REFERENCE CLASS-STRING.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING
122914                 lsGWLifeJointExcessWithd.
122914******************************************************************
122914
122914     SET lsGWLifeJointExcessWithd
122914                      TO WBALI-GW-JOINT-EXCESS-WD-FLAG.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointExcessWithd.

122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeSingleRestore.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeSingleRestore    OBJECT REFERENCE CLASS-STRING.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeSingleRestore.
122914******************************************************************
122914
122914     SET lsGWLifeSingleRestore TO WBALI-GW-SINGLE-RESTORE-FLAG.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeSingleRestore.
122914
122914******************************************************************
122914*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122914******************************************************************
122914 METHOD-ID. getGWLifeJointRestore.
122914 DATA DIVISION.
122914******************************************************************
122914 WORKING-STORAGE SECTION.
122914******************************************************************
122914 LINKAGE SECTION.
122914
122914 01 lsGWLifeJointRestore    OBJECT REFERENCE CLASS-STRING.
122914
122914******************************************************************
122914 PROCEDURE DIVISION RETURNING lsGWLifeJointRestore.
122914******************************************************************
122914
122914     SET lsGWLifeJointRestore TO WBALI-GW-JOINT-RESTORE-FLAG.
122914
122914     EXIT METHOD.
122914
122914 END METHOD getGWLifeJointRestore.

050814******************************************************************
050814*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
050814******************************************************************
101414 METHOD-ID. getGWWaitPeriodEndDate.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01 lsGWWaitPeriodEndDate          PIC S9(09) COMP-5.
101414
101414******************************************************************
101414 PROCEDURE DIVISION RETURNING
101414                 lsGWWaitPeriodEndDate.
101414******************************************************************
101414
101414     MOVE WBALI-GW-WAIT-PERIOD-END-DATE
101414                TO lsGWWaitPeriodEndDate.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getGWWaitPeriodEndDate.
101414
041516
041516******************************************************************
041516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041516******************************************************************
041516
041516 METHOD-ID. getGWLastRateChangeDate.
041516 DATA DIVISION.
041516******************************************************************
041516 WORKING-STORAGE SECTION.
041516******************************************************************
041516 LINKAGE SECTION.
041516
041516 01 lsGWLastRateChangeDate          PIC S9(09) COMP-5.
041516
041516******************************************************************
041516 PROCEDURE DIVISION RETURNING
041516                 lsGWLastRateChangeDate.
041516******************************************************************
041516
041516     MOVE WBALI-GW-LAST-RATE-CHANGE-DATE
041516                TO lsGWLastRateChangeDate.
041516
041516     EXIT METHOD.
041516
041516 END METHOD getGWLastRateChangeDate.
041516
072515******************************************************************
072515*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
072515******************************************************************
072515 METHOD-ID. getGuarRetireTotalDue.
072515 DATA DIVISION.
072515******************************************************************
072515 WORKING-STORAGE SECTION.
072515******************************************************************
072515 LINKAGE SECTION.
072515
072515 01 lsGuarRetireTotalDue         USAGE COMP-2.
072515
072515******************************************************************
072515 PROCEDURE DIVISION RETURNING
072515                 lsGuarRetireTotalDue.
072515******************************************************************
072515
072515     MOVE WBALI-GUAR-RETIRE-TOTAL-DUE
072515                TO lsGuarRetireTotalDue.
072515
072515     EXIT METHOD.
072515
072515 END METHOD getGuarRetireTotalDue.
101414
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
090315
090315 METHOD-ID. getGuarRetirePaymentDueCount.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01 lsGuarRetirePaymentDueCount     PIC S9(09) COMP-5.
090315
090315******************************************************************
090315 PROCEDURE DIVISION RETURNING lsGuarRetirePaymentDueCount.
090315******************************************************************
090315
090315     MOVE WBALI-GR-PAYMENT-DUE-LAST
090315                     TO lsGuarRetirePaymentDueCount.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGuarRetirePaymentDueCount.
090315
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueBenefitSeq.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                   PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueBenefitSeq  PIC S9(09) COMP-5.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueBenefitSeq.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueBenefitSeq
090315     ELSE
090315         MOVE WBALI-GR-PD-BENEFIT-SEQ (lsIndex)
090315               TO lsGRPaymentDueBenefitSeq.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueBenefitSeq.
090315
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueDueDate.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                   PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueDueDate     PIC S9(09) COMP-5.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueDueDate.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueDueDate
090315     ELSE
090315         MOVE WBALI-GR-PD-DUE-DATE (lsIndex)
090315               TO lsGRPaymentDueDueDate.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueDueDate.
090315
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueEffectiveDate.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                         PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueEffectiveDate     PIC S9(09) COMP-5.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueEffectiveDate.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueEffectiveDate
090315     ELSE
090315         MOVE WBALI-GR-PD-EFFECTIVE-DATE (lsIndex)
090315               TO lsGRPaymentDueEffectiveDate.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueEffectiveDate.
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueWithdEffDate.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                         PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueWithdEffDate     PIC S9(09) COMP-5.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueWithdEffDate.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueWithdEffDate
090315     ELSE
090315         MOVE WBALI-GR-PD-WITHD-EFF-DATE (lsIndex)
090315               TO lsGRPaymentDueWithdEffDate.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueWithdEffDate.
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueDueType.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                   PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueDueType     OBJECT REFERENCE CLASS-STRING.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueDueType.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         SET lsGRPaymentDueDueType TO ' '
090315     ELSE
090315         SET lsGRPaymentDueDueType
090315                      TO WBALI-GR-PD-DUE-TYPE (lsIndex)
090315     END-IF
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueDueType.
090315
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueAmountDue.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                   PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueAmountDue   USAGE COMP-2.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueAmountDue.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueAmountDue
090315     ELSE
090315         MOVE WBALI-GR-PD-AMOUNT-DUE (lsIndex)
090315               TO lsGRPaymentDueAmountDue.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueAmountDue.
090315
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
090315 METHOD-ID. getGRPaymentDueAmountPaid.
090315 DATA DIVISION.
090315******************************************************************
090315 WORKING-STORAGE SECTION.
090315******************************************************************
090315 LINKAGE SECTION.
090315
090315 01  lsIndex                    PIC S9(09) COMP-5.
090315 01  lsGRPaymentDueAmountPaid   USAGE COMP-2.
090315******************************************************************
090315 PROCEDURE DIVISION Using BY VALUE lsIndex
090315                    RETURNING lsGRPaymentDueAmountPaid.
090315******************************************************************
090315
090315     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
090315         MOVE ZERO TO lsGRPaymentDueAmountPaid
090315     ELSE
090315         MOVE WBALI-GR-PD-AMOUNT-PAID (lsIndex)
090315               TO lsGRPaymentDueAmountPaid.
090315
090315     EXIT METHOD.
090315
090315 END METHOD getGRPaymentDueAmountPaid.
090315
041516******************************************************************
041516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041516******************************************************************
041516 METHOD-ID. getGRPaymentDueModePremium.
041516 DATA DIVISION.
041516******************************************************************
041516 WORKING-STORAGE SECTION.
041516******************************************************************
041516 LINKAGE SECTION.
041516
041516 01  lsIndex                     PIC S9(09) COMP-5.
041516 01  lsGRPaymentDueModePremium   USAGE COMP-2.
041516******************************************************************
041516 PROCEDURE DIVISION Using BY VALUE lsIndex
041516                    RETURNING lsGRPaymentDueModePremium.
041516******************************************************************
041516
041516     IF lsIndex < 1 OR lsIndex > WBALI-GR-PAYMENT-DUE-LAST
041516         MOVE ZERO TO lsGRPaymentDueModePremium
041516     ELSE
041516         MOVE WBALI-GR-PD-MODE-PREMIUM (lsIndex)
041516               TO lsGRPaymentDueModePremium.
041516
041516     EXIT METHOD.
041516
041516 END METHOD getGRPaymentDueModePremium.
041516
090315******************************************************************
090315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
090315******************************************************************
101812 METHOD-ID. getBucketRowCount.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsBucketRowCount                PIC S9(09) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION RETURNING lsBucketRowCount.
101812******************************************************************
101812
101812     MOVE WBALI-BUCKET-LAST-LINE
101812                         TO lsBucketRowCount.
101812     EXIT METHOD.
101812
101812 END METHOD getBucketRowCount.

102315******************************************************************
102315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102315******************************************************************
102315 METHOD-ID. getRateHistRowCount.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsRateHistRowCount                PIC S9(09) COMP-5.
102315
102315******************************************************************
102315 PROCEDURE DIVISION RETURNING lsRateHistRowCount.
102315******************************************************************
102315
102315     MOVE WBALI-RATE-HIST-LAST-LINE
102315                         TO lsRateHistRowCount.
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistRowCount.

      ******************************************************************
      * The following get methods require an input index to determine the
      * table index you wish retrieved.
      ******************************************************************
093015******************************************************************
093015*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
093015******************************************************************
093015 METHOD-ID. getPremiumIncrementRule.
093015 DATA DIVISION.
093015******************************************************************
093015 WORKING-STORAGE SECTION.
093015******************************************************************
093015 LINKAGE SECTION.
093015
093015 01 lsPremiumIncrementRule      OBJECT REFERENCE CLASS-STRING.
093015
093015******************************************************************
093015 PROCEDURE DIVISION RETURNING lsPremiumIncrementRule.
093015******************************************************************
093015
093015     SET lsPremiumIncrementRule TO WBALI-CE-PREM-INCREMENT-RULE
093015     EXIT METHOD.
093015
093015 END METHOD getPremiumIncrementRule.
093015
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumRowCount.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01 lsSumRowCount                PIC S9(09) COMP-5.
101414
101414******************************************************************
101414 PROCEDURE DIVISION RETURNING lsSumRowCount.
101414******************************************************************
101414
101414     MOVE WBALI-SUM-LAST-LINE TO lsSumRowCount.
101414     EXIT METHOD.
101414
101414 END METHOD getSumRowCount.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumRow.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex              PIC S9(09) COMP-5.
101414 01  lsSumRow             PIC S9(09) COMP-5.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumRow.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumRow
101414     ELSE
101414         MOVE WBALI-SUM-ROW (lsIndex)
101414               to lsSumRow.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumRow.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumSource.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                 PIC S9(09) COMP-5.
101414 01  lsSumSource             OBJECT REFERENCE CLASS-STRING.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumSource.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         SET lsSumSource TO ' '
101414     ELSE
101414         SET lsSumSource TO WBALI-SUM-SOURCE (lsIndex)
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumSource.
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumSourceDesc.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                 PIC S9(09) COMP-5.
101414 01  lsSumSourceDesc         OBJECT REFERENCE CLASS-STRING.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumSourceDesc.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         SET lsSumSourceDesc TO ' '
101414     ELSE
101414         SET lsSumSourceDesc TO WBALI-SUM-SOURCE-DESC (lsIndex)
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumSourceDesc.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumFundBalance.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                 PIC S9(09) COMP-5.
101414 01  lsSumFundBalance        USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumFundBalance.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumFundBalance
101414     ELSE
101414         MOVE WBALI-SUM-FUND-BALANCE (lsIndex)
101414                   TO lsSumFundBalance
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumFundBalance.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumFreeAmount.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                 PIC S9(09) COMP-5.
101414 01  lsSumFreeAmount         USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumFreeAmount.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumFreeAmount
101414     ELSE
101414         MOVE WBALI-SUM-FREE-AMOUNT (lsIndex)
101414                   TO lsSumFreeAmount
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumFreeAmount.

101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumLoad.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                 PIC S9(09) COMP-5.
101414 01  lsSumLoad               USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumLoad.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumLoad
101414     ELSE
101414         MOVE WBALI-SUM-LOAD (lsIndex)
101414                   TO lsSumLoad
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumLoad.
021615
021615******************************************************************
021615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021615******************************************************************
021615 METHOD-ID. getSumGrossDeposits.
021615 DATA DIVISION.
021615******************************************************************
021615 WORKING-STORAGE SECTION.
021615******************************************************************
021615 LINKAGE SECTION.
021615
021615 01  lsIndex                 PIC S9(09) COMP-5.
021615 01  lsSumGrossDeposits      USAGE COMP-2.
021615******************************************************************
021615 PROCEDURE DIVISION Using BY VALUE lsIndex
021615                    RETURNING lsSumGrossDeposits.
021615******************************************************************
021615
021615     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
021615         MOVE ZERO TO lsSumGrossDeposits
021615     ELSE
021615         MOVE WBALI-SUM-GROSS-DEPOSITS (lsIndex)
021615                   TO lsSumGrossDeposits
021615
021615     EXIT METHOD.
021615
021615 END METHOD getSumGrossDeposits.
021615
021615******************************************************************
021615*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021615******************************************************************
021615 METHOD-ID. getSumGrossWithdrawals.
021615 DATA DIVISION.
021615******************************************************************
021615 WORKING-STORAGE SECTION.
021615******************************************************************
021615 LINKAGE SECTION.
021615
021615 01  lsIndex                    PIC S9(09) COMP-5.
021615 01  lsSumGrossWithdrawals      USAGE COMP-2.
021615******************************************************************
021615 PROCEDURE DIVISION Using BY VALUE lsIndex
021615                    RETURNING lsSumGrossWithdrawals.
021615******************************************************************
021615
021615     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
021615         MOVE ZERO TO lsSumGrossWithdrawals
021615     ELSE
021615         MOVE WBALI-SUM-GROSS-WITHDRAWALS (lsIndex)
021615                   TO lsSumGrossWithdrawals
021615
021615     EXIT METHOD.
021615
021615 END METHOD getSumGrossWithdrawals.
021615
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumStartDate.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex              PIC S9(09) COMP-5.
101414 01  lsSumStartDate       PIC S9(09) COMP-5.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsSumStartDate.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumStartDate
101414     ELSE
101414         MOVE WBALI-SUM-START-DATE (lsIndex)
101414               to lsSumStartDate.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumStartDate.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumIncomeStartDate.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex               PIC S9(09) COMP-5.
101414 01  lsSumIncomeStartDate  PIC S9(09) COMP-5.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumIncomeStartDate.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumIncomeStartDate
101414     ELSE
101414         MOVE WBALI-SUM-INC-START-DATE  (lsIndex)
101414               to lsSumIncomeStartDate.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumIncomeStartDate.
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumPeriodCertain.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex               PIC S9(09) COMP-5.
101414 01  lsSumPeriodCertain    PIC S9(09) COMP-5.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumPeriodCertain.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumPeriodCertain
101414     ELSE
101414         MOVE WBALI-SUM-PERIOD-CERTAIN  (lsIndex)
101414               to lsSumPeriodCertain.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumPeriodCertain.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumGuaranteeStatus.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                PIC S9(09) COMP-5.
101414 01  lsSumGuaranteeStatus    OBJECT REFERENCE CLASS-STRING.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumGuaranteeStatus.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         SET lsSumGuaranteeStatus TO ' '
101414     ELSE
101414         SET lsSumGuaranteeStatus
101414                 TO WBALI-SUM-GUAR-STATUS (lsIndex)
101414     EXIT METHOD.
101414
101414 END METHOD getSumGuaranteeStatus.
101414
093015******************************************************************
093015*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
093015******************************************************************
093015 METHOD-ID. getSumGuaranteeStatusDate.
093015 DATA DIVISION.
093015******************************************************************
093015 WORKING-STORAGE SECTION.
093015******************************************************************
093015 LINKAGE SECTION.
093015
093015 01  lsIndex                     PIC S9(09) COMP-5.
093015 01  lsSumGuaranteeStatusDate    PIC S9(09) COMP-5.
093015******************************************************************
093015 PROCEDURE DIVISION USING BY VALUE lsIndex
093015                    RETURNING lsSumGuaranteeStatusDate.
093015******************************************************************
093015
093015     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
093015         MOVE ZERO TO lsSumGuaranteeStatusDate
093015     ELSE
093015         MOVE WBALI-SUM-GUAR-STATUS-DATE (lsIndex)
093015               to lsSumGuaranteeStatusDate.
093015
093015     EXIT METHOD.
093015
093015 END METHOD getSumGuaranteeStatusDate.
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumGuaranteeIncomeFactor.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                       PIC S9(09) COMP-5.
101414 01  lsSumGuaranteeIncomeFactor    USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumGuaranteeIncomeFactor.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumGuaranteeIncomeFactor
101414     ELSE
101414         MOVE WBALI-SUM-GUAR-INC-FACTOR (lsIndex)
101414               to lsSumGuaranteeIncomeFactor.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumGuaranteeIncomeFactor.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumGuaranteeIncome.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                       PIC S9(09) COMP-5.
101414 01  lsSumGuaranteeIncome          USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumGuaranteeIncome.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumGuaranteeIncome
101414     ELSE
101414         MOVE WBALI-SUM-GUAR-INCOME (lsIndex)
101414               to lsSumGuaranteeIncome.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumGuaranteeIncome.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumVestedAnnualIncome.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                         PIC S9(09) COMP-5.
101414 01  lsSumVestedAnnualIncome         USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumVestedAnnualIncome.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumVestedAnnualIncome
101414     ELSE
101414         MOVE WBALI-SUM-VESTED-ANNUAL-INC (lsIndex)
101414               to lsSumVestedAnnualIncome.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumVestedAnnualIncome.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumVestedMonthlyIncome.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                         PIC S9(09) COMP-5.
101414 01  lsSumVestedMonthlyIncome        USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumVestedMonthlyIncome.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumVestedMonthlyIncome
101414     ELSE
101414         MOVE WBALI-SUM-VESTED-MONTHLY-INC (lsIndex)
101414               to lsSumVestedMonthlyIncome.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumVestedMonthlyIncome.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumScheduledTransferAmount.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                          PIC S9(09) COMP-5.
101414 01  lsSumScheduledTransferAmount     USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumScheduledTransferAmount.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumScheduledTransferAmount
101414     ELSE
101414         MOVE WBALI-SUM-SCHEDULED-TRANSFER (lsIndex)
101414               to lsSumScheduledTransferAmount.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumScheduledTransferAmount.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumAccumPrepaymentAmount.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                              PIC S9(09) COMP-5.
101414 01  lsSumAccumPrepaymentAmount           USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumAccumPrepaymentAmount.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumAccumPrepaymentAmount
101414     ELSE
101414         MOVE WBALI-SUM-ACCUM-PREPAYMENT  (lsIndex)
101414               to lsSumAccumPrepaymentAmount.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumAccumPrepaymentAmount.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumRemainPrepayTransfers.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                             PIC S9(09) COMP-5.
101414 01  lsSumRemainPrepayTransfers       USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumRemainPrepayTransfers.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumRemainPrepayTransfers
101414     ELSE
101414         MOVE WBALI-SUM-REMAIN-PREPAY-XFERS (lsIndex)
101414               to lsSumRemainPrepayTransfers.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumRemainPrepayTransfers.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getSumAmountToFullyFund.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex                         PIC S9(09) COMP-5.
101414 01  lsSumAmountToFullyFund          USAGE COMP-2.
101414******************************************************************
101414 PROCEDURE DIVISION USING BY VALUE lsIndex
101414                    RETURNING lsSumAmountToFullyFund.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-SUM-LAST-LINE
101414         MOVE ZERO TO lsSumAmountToFullyFund
101414     ELSE
101414         MOVE WBALI-SUM-AMOUNT-FULLY-FUND (lsIndex)
101414               to lsSumAmountToFullyFund.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getSumAmountToFullyFund.
101414
101414******************************************************************
101414*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101414******************************************************************
101414 METHOD-ID. getRowNumber.
101414 DATA DIVISION.
101414******************************************************************
101414 WORKING-STORAGE SECTION.
101414******************************************************************
101414 LINKAGE SECTION.
101414
101414 01  lsIndex              PIC S9(09) COMP-5.
101414 01  lsRowNumber          PIC S9(09) COMP-5.
101414******************************************************************
101414 PROCEDURE DIVISION Using BY VALUE lsIndex
101414                    RETURNING lsRowNumber.
101414******************************************************************
101414
101414     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
101414         MOVE ZERO TO lsRowNumber
101414     ELSE
101414         MOVE WBALI-ROW (lsIndex)
101414               to lsRowNumber.
101414
101414     EXIT METHOD.
101414
101414 END METHOD getRowNumber.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getMoneySource.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndex              PIC S9(09) COMP-5.
       01  lsMoneySource        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION Using BY VALUE lsIndex
                          RETURNING lsMoneySource.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsMoneySource
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                           BY VALUE WBALI-MONEY-SOURCE (lsIndex)
                    RETURNING lsMoneySource.

           EXIT METHOD.

       END METHOD getMoneySource.

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

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsFundID
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                           BY VALUE WBALI-FUND-ID (lsIndex)
                    RETURNING lsFundID.

           EXIT METHOD.

       END METHOD getFundID.

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

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsShortDescription
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                           BY VALUE WBALI-FUND-SHORT-DESC (lsIndex)
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

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsLongDescription
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                           BY VALUE WBALI-FUND-LONG-DESC (lsIndex)
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

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
                    RETURNING lsFundType
           ELSE
               INVOKE CLASS-STRING "NEW" USING
                    BY VALUE WBALI-FUND-TYPE (lsIndex)
                    RETURNING lsFundType.

           EXIT METHOD.
       END METHOD getFundType.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getUnits.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                  PIC S9(09) COMP-5.
       01 lsUnits                  USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsUnits.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               MOVE ZERO TO lsUnits
           ELSE
               MOVE WBALI-NUMBER-OF-UNITS (lsIndex)
                            TO lsUnits.

           EXIT METHOD.

       END METHOD getUnits.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getUnitValue.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                     PIC S9(09) COMP-5.
       01 lsUnitValue                 USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsUnitValue.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               MOVE ZERO TO lsUnitValue
           ELSE
               MOVE WBALI-UNIT-VALUE (lsIndex)
                            TO lsUnitValue.

           EXIT METHOD.

       END METHOD getUnitValue.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getUnitValueDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                     PIC S9(09) COMP-5.
       01 lsUnitValueDate             PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsUnitValueDate.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               MOVE ZERO TO lsUnitValueDate
           ELSE

      *  It may seem odd, but we're moving a single WBALI-QUOTE-DATE
      *  to every row, regardless of Index.  This is on purpose, per the
      *  client's specific request.  Misc Quote Date is also provided as
      *  a single property.
               MOVE WBALI-QUOTE-DATE
                            TO lsUnitValueDate.

           EXIT METHOD.

       END METHOD getUnitValueDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. getFundBalance.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01 lsIndex                     PIC S9(09) COMP-5.
       01 lsFundBalance               USAGE COMP-2.

      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsFundBalance.
      ******************************************************************

           IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
               MOVE ZERO TO lsFundBalance
           ELSE
               MOVE WBALI-FUND-BALANCE (lsIndex)
                            TO lsFundBalance.

           EXIT METHOD.

       END METHOD getFundBalance.

021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getFundModel.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsFundModel                 PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsFundModel.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
021816         MOVE ZERO TO lsFundModel
021816     ELSE
021816         MOVE WBALI-FUND-MODEL (lsIndex)
021816                       TO lsFundModel.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getFundModel.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getFundSubModel.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsFundSubModel              PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsFundSubModel.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
021816         MOVE ZERO TO lsFundSubModel
021816     ELSE
021816         MOVE WBALI-FUND-SUB-MODEL (lsIndex)
021816                       TO lsFundSubModel.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getFundSubModel.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getFundSubAlloc.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsFundSubAlloc              USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsFundSubAlloc.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
021816         MOVE ZERO TO lsFundSubAlloc
021816     ELSE
021816         MOVE WBALI-FUND-SUB-ALLOC (lsIndex)
021816                       TO lsFundSubAlloc.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getFundSubAlloc.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getFundHybridCap.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsFundHybridCap             USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsFundHybridCap.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
021816         MOVE ZERO TO lsFundHybridCap
021816     ELSE
021816         MOVE WBALI-FUND-HYBRID-CAP (lsIndex)
021816                       TO lsFundHybridCap.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getFundHybridCap.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getFundHybridFloor.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsFundHybridFloor           USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsFundHybridFloor.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
021816         MOVE ZERO TO lsFundHybridFloor
021816     ELSE
021816         MOVE WBALI-FUND-HYBRID-FLOOR (lsIndex)
021816                       TO lsFundHybridFloor.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getFundHybridFloor.
021816
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getFundBOTAnnvIndex.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsFundBOTAnnvIndex        USAGE COMP-2.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsFundBOTAnnvIndex.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
091916        MOVE ZERO TO lsFundBOTAnnvIndex
091916    ELSE
091916        MOVE WBALI-FUND-BOT-ANNV-INDEX (lsIndex)
091916          TO lsFundBOTAnnvIndex.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getFundBOTAnnvIndex.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getFundCurrIndex.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsFundCurrIndex           USAGE COMP-2.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsFundCurrIndex.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-LINE
091916        MOVE ZERO TO lsFundCurrIndex
091916    ELSE
091916        MOVE WBALI-FUND-CURR-INDEX (lsIndex)
091916          TO lsFundCurrIndex.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getFundCurrIndex.
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketParentSequence.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                     PIC S9(09) COMP-5.
101812 01 lsBucketParentSequence      PIC S9(04) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketParentSequence.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketParentSequence
101812     ELSE
101812         MOVE WBALI-BUCKET-PARENT (lsIndex)
101812                      TO lsBucketParentSequence.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketParentSequence.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketEffectiveDate.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                     PIC S9(09) COMP-5.
101812 01 lsBucketEffectiveDate       PIC S9(09) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketEffectiveDate.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketEffectiveDate
101812     ELSE
101812         MOVE WBALI-BUCKET-DATE (lsIndex)
101812                      TO lsBucketEffectiveDate.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketEffectiveDate.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketDuration.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                        PIC S9(09) COMP-5.
101812 01 lsBucketDuration               PIC S9(04) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketDuration.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketDuration
101812     ELSE
101812         MOVE WBALI-BUCKET-DURATION (lsIndex)
101812                    TO lsBucketDuration.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketDuration.

101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketValue.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                     PIC S9(09) COMP-5.
101812 01 lsBucketValue               USAGE COMP-2.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketValue.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketValue
101812     ELSE
101812         MOVE WBALI-BUCKET-VALUE (lsIndex)
101812                      TO lsBucketValue.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketValue.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketCurrentRate.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketCurrentRate               USAGE COMP-2.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketCurrentRate.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketCurrentRate
101812     ELSE
101812         MOVE WBALI-CURR-RATE (lsIndex)
101812                      TO lsBucketCurrentRate.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketCurrentRate.
101812
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketCurrentSegmentID.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketCurrentSegmentID OBJECT REFERENCE CLASS-STRING.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketCurrentSegmentID.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         SET lsBucketCurrentSegmentID TO ' '
101812     ELSE
101812         SET lsBucketCurrentSegmentID TO
101812                  WBALI-CURR-SEGT-ID (lsIndex)
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketCurrentSegmentID.

101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketCurrentRateID.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketCurrentRateID OBJECT REFERENCE CLASS-STRING.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketCurrentRateID.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         SET lsBucketCurrentRateID TO ' '
101812     ELSE
101812         SET lsBucketCurrentRateID TO
101812                  WBALI-CURR-RATE-ID (lsIndex)
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketCurrentRateID.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketCurrentRule.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketCurrentRule               PIC S9(04) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketCurrentRule.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketCurrentRule
101812     ELSE
101812         MOVE WBALI-CURR-RULE (lsIndex)
101812              TO lsBucketCurrentRule
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketCurrentRule.
101812

101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketCurrRateEffectiveDate.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                             PIC S9(09) COMP-5.
101812 01 lsBucketCurrRateEffectiveDate    PIC S9(09) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketCurrRateEffectiveDate.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketCurrRateEffectiveDate
101812     ELSE
101812         MOVE WBALI-CURR-EFFECTIVE-DATE (lsIndex)
101812                    TO lsBucketCurrRateEffectiveDate.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketCurrRateEffectiveDate.
101812
101812
061714******************************************************************
061714*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
061714******************************************************************
061714
061714 METHOD-ID. getBucketCurrRateBeginDate.
061714 DATA DIVISION.
061714******************************************************************
061714 WORKING-STORAGE SECTION.
061714******************************************************************
061714 LINKAGE SECTION.
061714
061714 01 lsIndex                         PIC S9(09) COMP-5.
061714 01 lsBucketCurrRateBeginDate       PIC S9(09) COMP-5.
061714
061714******************************************************************
061714 PROCEDURE DIVISION USING BY VALUE lsIndex
061714                    RETURNING lsBucketCurrRateBeginDate.
061714******************************************************************
061714
061714     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
061714         MOVE ZERO TO lsBucketCurrRateBeginDate
061714     ELSE
061714         MOVE WBALI-CURR-RATE-BEGIN-DATE (lsIndex)
061714                    TO lsBucketCurrRateBeginDate.
061714
061714     EXIT METHOD.
061714
061714 END METHOD getBucketCurrRateBeginDate.
061714
061714******************************************************************
061714*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
061714******************************************************************
061714
061714 METHOD-ID. getBucketCurrRateEndDate.
061714 DATA DIVISION.
061714******************************************************************
061714 WORKING-STORAGE SECTION.
061714******************************************************************
061714 LINKAGE SECTION.
061714
061714 01 lsIndex                         PIC S9(09) COMP-5.
061714 01 lsBucketCurrRateEndDate         PIC S9(09) COMP-5.
061714
061714******************************************************************
061714 PROCEDURE DIVISION USING BY VALUE lsIndex
061714                    RETURNING lsBucketCurrRateEndDate.
061714******************************************************************
061714
061714     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
061714         MOVE ZERO TO lsBucketCurrRateEndDate
061714     ELSE
061714         MOVE WBALI-CURR-RATE-END-DATE (lsIndex)
061714                    TO lsBucketCurrRateEndDate.
061714
061714     EXIT METHOD.
061714
061714 END METHOD getBucketCurrRateEndDate.
061714
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketGuaranteedRate.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketGuaranteedRate            USAGE COMP-2.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketGuaranteedRate.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketGuaranteedRate
101812     ELSE
101812         MOVE WBALI-GUAR-RATE (lsIndex)
101812                      TO lsBucketGuaranteedRate.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketGuaranteedRate.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketGuaranteedSegmentID.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketGuaranteedSegmentID OBJECT REFERENCE CLASS-STRING.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketGuaranteedSegmentID.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         SET lsBucketGuaranteedSegmentID TO ' '
101812     ELSE
101812         SET lsBucketGuaranteedSegmentID TO
101812                  WBALI-GUAR-SEGT-ID (lsIndex)
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketGuaranteedSegmentID.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketGuaranteedRateID.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketGuaranteedRateID OBJECT REFERENCE CLASS-STRING.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketGuaranteedRateID.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         SET lsBucketGuaranteedRateID TO ' '
101812     ELSE
101812         SET lsBucketGuaranteedRateID TO
101812                  WBALI-GUAR-RATE-ID (lsIndex)
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketGuaranteedRateID.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketGuaranteedRule.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                           PIC S9(09) COMP-5.
101812 01 lsBucketGuaranteedRule            PIC S9(04) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketGuaranteedRule.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketGuaranteedRule
101812     ELSE
101812         MOVE WBALI-GUAR-RULE (lsIndex)
101812              TO lsBucketGuaranteedRule
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketGuaranteedRule.
101812
101812******************************************************************
101812*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101812******************************************************************
101812
101812 METHOD-ID. getBucketGuarRateEffectiveDate.
101812 DATA DIVISION.
101812******************************************************************
101812 WORKING-STORAGE SECTION.
101812******************************************************************
101812 LINKAGE SECTION.
101812
101812 01 lsIndex                             PIC S9(09) COMP-5.
101812 01 lsBucketGuarRateEffectiveDate       PIC S9(09) COMP-5.
101812
101812******************************************************************
101812 PROCEDURE DIVISION USING BY VALUE lsIndex
101812                    RETURNING lsBucketGuarRateEffectiveDate.
101812******************************************************************
101812
101812     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
101812         MOVE ZERO TO lsBucketGuarRateEffectiveDate
101812     ELSE
101812         MOVE WBALI-GUAR-EFFECTIVE-DATE (lsIndex)
101812                    TO lsBucketGuarRateEffectiveDate.
101812
101812     EXIT METHOD.
101812
101812 END METHOD getBucketGuarRateEffectiveDate.
122613******************************************************************
122613
061714******************************************************************
061714*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
061714******************************************************************
061714
061714 METHOD-ID. getBucketGuarRateBeginDate.
061714 DATA DIVISION.
061714******************************************************************
061714 WORKING-STORAGE SECTION.
061714******************************************************************
061714 LINKAGE SECTION.
061714
061714 01 lsIndex                         PIC S9(09) COMP-5.
061714 01 lsBucketGuarRateBeginDate       PIC S9(09) COMP-5.
061714
061714******************************************************************
061714 PROCEDURE DIVISION USING BY VALUE lsIndex
061714                    RETURNING lsBucketGuarRateBeginDate.
061714******************************************************************
061714
061714     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
061714         MOVE ZERO TO lsBucketGuarRateBeginDate
061714     ELSE
061714         MOVE WBALI-GUAR-RATE-BEGIN-DATE (lsIndex)
061714                    TO lsBucketGuarRateBeginDate.
061714
061714     EXIT METHOD.
061714
061714 END METHOD getBucketGuarRateBeginDate.
061714
061714******************************************************************
061714*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
061714******************************************************************
061714
061714 METHOD-ID. getBucketGuarRateEndDate.
061714 DATA DIVISION.
061714******************************************************************
061714 WORKING-STORAGE SECTION.
061714******************************************************************
061714 LINKAGE SECTION.
061714
061714 01 lsIndex                         PIC S9(09) COMP-5.
061714 01 lsBucketGuarRateEndDate         PIC S9(09) COMP-5.
061714
061714******************************************************************
061714 PROCEDURE DIVISION USING BY VALUE lsIndex
061714                    RETURNING lsBucketGuarRateEndDate.
061714******************************************************************
061714
061714     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
061714         MOVE ZERO TO lsBucketGuarRateEndDate
061714     ELSE
061714         MOVE WBALI-GUAR-RATE-END-DATE (lsIndex)
061714                    TO lsBucketGuarRateEndDate.
061714
061714     EXIT METHOD.
061714
061714 END METHOD getBucketGuarRateEndDate.
061714
061714******************************************************************
061714*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
061714******************************************************************
122613 METHOD-ID. getBucketOriginalPaymentDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketOriginalPaymentDate         PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketOriginalPaymentDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketOriginalPaymentDate
122613     ELSE
122613         MOVE WBALI-ORIG-PYMNT-DATE (lsIndex)
122613                    TO lsBucketOriginalPaymentDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketOriginalPaymentDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketAppSignedDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketAppSignedDate               PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketAppSignedDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketAppSignedDate
122613     ELSE
122613         MOVE WBALI-APP-SIGNED-DATE (lsIndex)
122613                    TO lsBucketAppSignedDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketAppSignedDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketAppReceivedDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketAppReceivedDate             PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketAppReceivedDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketAppReceivedDate
122613     ELSE
122613         MOVE WBALI-APP-RECEIVED-DATE (lsIndex)
122613                    TO lsBucketAppReceivedDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketAppReceivedDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketAccountingTransCode.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketAccountingTransCode         PIC S9(04) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketAccountingTransCode.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketAccountingTransCode
122613     ELSE
122613         MOVE WBALI-ACTG-TRANS-CODE (lsIndex)
122613                    TO lsBucketAccountingTransCode.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketAccountingTransCode.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketRateLockEligible.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketRateLockEligible OBJECT REFERENCE CLASS-STRING.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketRateLockEligible.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         SET lsBucketRateLockEligible TO ' '
122613     ELSE
122613         SET lsBucketRateLockEligible TO
122613             WBALI-RATE-LOCK-ELIGIBLE (lsIndex).
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketRateLockEligible.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketMaturityDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                             PIC S9(09) COMP-5.
122613 01 lsBucketMaturityDate                PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketMaturityDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketMaturityDate
122613     ELSE
122613         MOVE WBALI-MATURITY-DATE (lsIndex)
122613                    TO lsBucketMaturityDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketMaturityDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketEndingBalance.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketEndingBalance             USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketEndingBalance.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketEndingBalance
122613     ELSE
122613         MOVE WBALI-ENDING-BALANCE (lsIndex)
122613                      TO lsBucketEndingBalance.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketEndingBalance.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketInitialAmount.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketInitialAmount             USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketInitialAmount.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketInitialAmount
122613     ELSE
122613         MOVE WBALI-INITIAL-AMOUNT (lsIndex)
122613                      TO lsBucketInitialAmount.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketInitialAmount.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketWithdrawals.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketWithdrawals               USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketWithdrawals.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketWithdrawals
122613     ELSE
122613         MOVE WBALI-WITHDRAWALS (lsIndex)
122613                      TO lsBucketWithdrawals.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketWithdrawals.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketInterestCredited.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketInterestCredited          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketInterestCredited.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketInterestCredited
122613     ELSE
122613         MOVE WBALI-INTEREST-CREDITED (lsIndex)
122613                      TO lsBucketInterestCredited.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketInterestCredited.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketIndexRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketIndexRate                 USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketIndexRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketIndexRate
122613     ELSE
122613         MOVE WBALI-INDEX-RATE (lsIndex)
122613                      TO lsBucketIndexRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketIndexRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmParticipDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmParticipDate       PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmParticipDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmParticipDate
122613     ELSE
122613         MOVE WBALI-ITRM-PARTICIP-DATE (lsIndex)
122613                      TO lsBucketItrmParticipDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmParticipDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmParticipRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmParticipRate          USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmParticipRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmParticipRate
122613     ELSE
122613         MOVE WBALI-ITRM-PARTICIP-RATE (lsIndex)
122613                      TO lsBucketItrmParticipRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmParticipRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalParticipDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalParticipDate         PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalParticipDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalParticipDate
122613     ELSE
122613         MOVE WBALI-FINAL-PARTICIP-DATE (lsIndex)
122613                      TO lsBucketFinalParticipDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalParticipDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalParticipRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalParticipRate         USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalParticipRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalParticipRate
122613     ELSE
122613         MOVE WBALI-FINAL-PARTICIP-RATE (lsIndex)
122613                      TO lsBucketFinalParticipRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalParticipRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmBonParticipDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmBonParticipDate       PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmBonParticipDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmBonParticipDate
122613     ELSE
122613         MOVE WBALI-ITRM-BON-PARTICIP-DATE (lsIndex)
122613                      TO lsBucketItrmBonParticipDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmBonParticipDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmBonParticipRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmBonParticipRate       USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmBonParticipRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmBonParticipRate
122613     ELSE
122613         MOVE WBALI-ITRM-BON-PARTICIP-RATE (lsIndex)
122613                      TO lsBucketItrmBonParticipRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmBonParticipRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalBonParticipDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalBonParticipDate      PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalBonParticipDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalBonParticipDate
122613     ELSE
122613         MOVE WBALI-FINAL-BON-PARTICIP-DATE (lsIndex)
122613                      TO lsBucketFinalBonParticipDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalBonParticipDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalBonParticipRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalBonParticipRate      USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalBonParticipRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalBonParticipRate
122613     ELSE
122613         MOVE WBALI-FINAL-BON-PARTICIP-RATE (lsIndex)
122613                      TO lsBucketFinalBonParticipRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalBonParticipRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmVestFactorDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmVestFactorDate        PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmVestFactorDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmVestFactorDate
122613     ELSE
122613         MOVE WBALI-ITRM-VEST-FACTOR-DATE (lsIndex)
122613                      TO lsBucketItrmVestFactorDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmVestFactorDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmVestFactorRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmVestFactorRate        USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmVestFactorRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmVestFactorRate
122613     ELSE
122613         MOVE WBALI-ITRM-VEST-FACTOR-RATE (lsIndex)
122613                      TO lsBucketItrmVestFactorRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmVestFactorRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalVestFactorDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalVestFactorDate       PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalVestFactorDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalVestFactorDate
122613     ELSE
122613         MOVE WBALI-FINAL-VEST-FACTOR-DATE (lsIndex)
122613                      TO lsBucketFinalVestFactorDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalVestFactorDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalVestFactorRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalVestFactorRate       USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalVestFactorRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalVestFactorRate
122613     ELSE
122613         MOVE WBALI-FINAL-VEST-FACTOR-RATE (lsIndex)
122613                      TO lsBucketFinalVestFactorRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalVestFactorRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmCapDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmCapDate               PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmCapDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmCapDate
122613     ELSE
122613         MOVE WBALI-ITRM-CAP-DATE (lsIndex)
122613                      TO lsBucketItrmCapDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmCapDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmCapRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmCapRate               USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmCapRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmCapRate
122613     ELSE
122613         MOVE WBALI-ITRM-CAP-RATE (lsIndex)
122613                      TO lsBucketItrmCapRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmCapRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalCapDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalCapDate              PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalCapDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalCapDate
122613     ELSE
122613         MOVE WBALI-FINAL-CAP-DATE (lsIndex)
122613                      TO lsBucketFinalCapDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalCapDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalCapRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalCapRate              USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalCapRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalCapRate
122613     ELSE
122613         MOVE WBALI-FINAL-CAP-RATE (lsIndex)
122613                      TO lsBucketFinalCapRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalCapRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmFloorDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmFloorDate             PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmFloorDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmFloorDate
122613     ELSE
122613         MOVE WBALI-ITRM-FLOOR-DATE (lsIndex)
122613                      TO lsBucketItrmFloorDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmFloorDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmFloorRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmFloorRate             USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmFloorRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmFloorRate
122613     ELSE
122613         MOVE WBALI-ITRM-FLOOR-RATE (lsIndex)
122613                      TO lsBucketItrmFloorRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmFloorRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalFloorDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalFloorDate            PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalFloorDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalFloorDate
122613     ELSE
122613         MOVE WBALI-FINAL-FLOOR-DATE (lsIndex)
122613                      TO lsBucketFinalFloorDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalFloorDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalFloorRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalFloorRate              USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalFloorRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalFloorRate
122613     ELSE
122613         MOVE WBALI-FINAL-FLOOR-RATE (lsIndex)
122613                      TO lsBucketFinalFloorRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalFloorRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmSpreadDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmSpreadDate            PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmSpreadDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmSpreadDate
122613     ELSE
122613         MOVE WBALI-ITRM-SPREAD-DATE (lsIndex)
122613                      TO lsBucketItrmSpreadDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmSpreadDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmSpreadRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmSpreadRate            USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmSpreadRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmSpreadRate
122613     ELSE
122613         MOVE WBALI-ITRM-SPREAD-RATE (lsIndex)
122613                      TO lsBucketItrmSpreadRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmSpreadRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalSpreadDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalSpreadDate           PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalSpreadDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalSpreadDate
122613     ELSE
122613         MOVE WBALI-FINAL-SPREAD-DATE (lsIndex)
122613                      TO lsBucketFinalSpreadDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalSpreadDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalSpreadRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalSpreadRate           USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalSpreadRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalSpreadRate
122613     ELSE
122613         MOVE WBALI-FINAL-SPREAD-RATE (lsIndex)
122613                      TO lsBucketFinalSpreadRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalSpreadRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketStateMinParticipRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketStateMinParticipRate      USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketStateMinParticipRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketStateMinParticipRate
122613     ELSE
122613         MOVE WBALI-STATE-MIN-PARTICIP-RATE (lsIndex)
122613                      TO lsBucketStateMinParticipRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketStateMinParticipRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketStartingIndexAverage.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketStartingIndexAverage      USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketStartingIndexAverage.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketStartingIndexAverage
122613     ELSE
122613         MOVE WBALI-STARTING-INDEX-AVERAGE (lsIndex)
122613                      TO lsBucketStartingIndexAverage.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketStartingIndexAverage.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketEndingIndexAverage.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketEndingIndexAverage        USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketEndingIndexAverage.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketEndingIndexAverage
122613     ELSE
122613         MOVE WBALI-ENDING-INDEX-AVERAGE (lsIndex)
122613                      TO lsBucketEndingIndexAverage.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketEndingIndexAverage.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketCreditedIndexRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketCreditedIndexRate         USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketCreditedIndexRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketCreditedIndexRate
122613     ELSE
122613         MOVE WBALI-CREDITED-INDEX-RATE (lsIndex)
122613                      TO lsBucketCreditedIndexRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketCreditedIndexRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketItrmRenewalCap.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketItrmRenewalCap            USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketItrmRenewalCap.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketItrmRenewalCap
122613     ELSE
122613         MOVE WBALI-ITRM-RENEWAL-CAP (lsIndex)
122613                      TO lsBucketItrmRenewalCap.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketItrmRenewalCap.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getBucketFinalRenewalCap.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsBucketFinalRenewalCap           USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsBucketFinalRenewalCap.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
122613         MOVE ZERO TO lsBucketFinalRenewalCap
122613     ELSE
122613         MOVE WBALI-FINAL-RENEWAL-CAP (lsIndex)
122613                      TO lsBucketFinalRenewalCap.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getBucketFinalRenewalCap.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketIndexEndCapDate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketIndexEndCapDate           PIC S9(09) COMP-5.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketIndexEndCapDate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketIndexEndCapDate
052215     ELSE
052215         MOVE WBALI-END-INDEX-CAP-DATE (lsIndex)
052215                      TO lsBucketIndexEndCapDate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketIndexEndCapDate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketIndexEndCapRate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketIndexEndCapRate           USAGE COMP-2.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketIndexEndCapRate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketIndexEndCapRate
052215     ELSE
052215         MOVE WBALI-END-INDEX-CAP-RATE (lsIndex)
052215                      TO lsBucketIndexEndCapRate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketIndexEndCapRate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketIndexEndFloorDate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketIndexEndFloorDate         PIC S9(09) COMP-5.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketIndexEndFloorDate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketIndexEndFloorDate
052215     ELSE
052215         MOVE WBALI-END-INDEX-FLOOR-DATE (lsIndex)
052215                      TO lsBucketIndexEndFloorDate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketIndexEndFloorDate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketIndexEndFloorRate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketIndexEndFloorRate         USAGE COMP-2.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketIndexEndFloorRate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketIndexEndFloorRate
052215     ELSE
052215         MOVE WBALI-END-INDEX-FLOOR-RATE (lsIndex)
052215                      TO lsBucketIndexEndFloorRate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketIndexEndFloorRate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketBailoutCapDate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketBailoutCapDate            PIC S9(09) COMP-5.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketBailoutCapDate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketBailoutCapDate
052215     ELSE
052215         MOVE WBALI-BAILOUT-CAP-DATE (lsIndex)
052215                      TO lsBucketBailoutCapDate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketBailoutCapDate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketBailoutCapRate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketBailoutCapRate            USAGE COMP-2.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketBailoutCapRate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketBailoutCapRate
052215     ELSE
052215         MOVE WBALI-BAILOUT-CAP-RATE (lsIndex)
052215                      TO lsBucketBailoutCapRate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketBailoutCapRate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketDailyOptionFactorDate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketDailyOptionFactorDate     PIC S9(09) COMP-5.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketDailyOptionFactorDate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketDailyOptionFactorDate
052215     ELSE
052215         MOVE WBALI-DAILY-OPT-FACT-DATE (lsIndex)
052215                      TO lsBucketDailyOptionFactorDate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketDailyOptionFactorDate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketDailyOptionFactorRate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketDailyOptionFactorRate     USAGE COMP-2.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketDailyOptionFactorRate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketDailyOptionFactorRate
052215     ELSE
052215         MOVE WBALI-DAILY-OPT-FACT-RATE (lsIndex)
052215                      TO lsBucketDailyOptionFactorRate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketDailyOptionFactorRate.
052215
052215******************************************************************
052215*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
052215******************************************************************
052215
052215 METHOD-ID. getBucketOriginalSweepDate.
052215 DATA DIVISION.
052215******************************************************************
052215 WORKING-STORAGE SECTION.
052215******************************************************************
052215 LINKAGE SECTION.
052215
052215 01 lsIndex                           PIC S9(09) COMP-5.
052215 01 lsBucketOriginalSweepDate         PIC S9(09) COMP-5.
052215
052215******************************************************************
052215 PROCEDURE DIVISION USING BY VALUE lsIndex
052215                    RETURNING lsBucketOriginalSweepDate.
052215******************************************************************
052215
052215     IF lsIndex < 1 OR lsIndex > WBALI-BUCKET-LAST-LINE
052215         MOVE ZERO TO lsBucketOriginalSweepDate
052215     ELSE
052215         MOVE WBALI-ORIG-SWEEP-DATE (lsIndex)
052215                      TO lsBucketOriginalSweepDate.
052215
052215     EXIT METHOD.
052215
052215 END METHOD getBucketOriginalSweepDate.
052215
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613 METHOD-ID. getPointRowCount.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsPointRowCount                PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION RETURNING lsPointRowCount.
122613******************************************************************
122613
122613     MOVE WBALI-POINT-DATA-LAST-LINE
122613                         TO lsPointRowCount.
122613     EXIT METHOD.
122613
122613 END METHOD getPointRowCount.

122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointBucketLine.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointBucketLine                 PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointBucketLine.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointBucketLine
122613     ELSE
122613         MOVE WBALI-POINT-BUCKET-LINE (lsIndex)
122613                      TO lsPointBucketLine.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointBucketLine.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointADate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointADate                      PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointADate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointADate
122613     ELSE
122613         MOVE WBALI-OUT-POINT-A-DATE (lsIndex)
122613                      TO lsPointADate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointADate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointARate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointARate                      USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointARate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointARate
122613     ELSE
122613         MOVE WBALI-OUT-POINT-A-RATE (lsIndex)
122613                      TO lsPointARate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointARate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointBDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointBDate                      PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointBDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointBDate
122613     ELSE
122613         MOVE WBALI-OUT-POINT-B-DATE (lsIndex)
122613                      TO lsPointBDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointBDate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointBRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointBRate                      USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointBRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointBRate
122613     ELSE
122613         MOVE WBALI-OUT-POINT-B-RATE (lsIndex)
122613                      TO lsPointBRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointBRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointP2PDate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointP2PDate                         PIC S9(09) COMP-5.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointP2PDate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointP2PDate
122613     ELSE
122613         MOVE WBALI-OUT-P2P-DATE (lsIndex)
122613                      TO lsPointP2PDate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointP2PDate.

122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointP2PRate.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointP2PRate                         USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointP2PRate.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointP2PRate
122613     ELSE
122613         MOVE WBALI-OUT-P2P-RATE (lsIndex)
122613                      TO lsPointP2PRate.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointP2PRate.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointP2PGrowth.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointP2PGrowth                       USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointP2PGrowth.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointP2PGrowth
122613     ELSE
122613         MOVE WBALI-OUT-P2P-GRTH (lsIndex)
122613                      TO lsPointP2PGrowth.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointP2PGrowth.
122613
122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
122613
122613 METHOD-ID. getPointP2PCapGrowth.
122613 DATA DIVISION.
122613******************************************************************
122613 WORKING-STORAGE SECTION.
122613******************************************************************
122613 LINKAGE SECTION.
122613
122613 01 lsIndex                           PIC S9(09) COMP-5.
122613 01 lsPointP2PCapGrowth                    USAGE COMP-2.
122613
122613******************************************************************
122613 PROCEDURE DIVISION USING BY VALUE lsIndex
122613                    RETURNING lsPointP2PCapGrowth.
122613******************************************************************
122613
122613     IF lsIndex < 1 OR lsIndex > WBALI-POINT-DATA-LAST-LINE
122613         MOVE ZERO TO lsPointP2PCapGrowth
122613     ELSE
122613         MOVE WBALI-OUT-P2P-CAP-GRTH (lsIndex)
122613                      TO lsPointP2PCapGrowth.
122613
122613     EXIT METHOD.
122613
122613 END METHOD getPointP2PCapGrowth.

122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************
102315 METHOD-ID. getRateHistParentSeq.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsIndex                     PIC S9(09) COMP-5.
102315 01 lsRateHistParentSeq         PIC S9(04) COMP-5.
102315
102315******************************************************************
102315 PROCEDURE DIVISION USING BY VALUE lsIndex
102315                    RETURNING lsRateHistParentSeq.
102315******************************************************************
102315
102315     IF lsIndex < 1 OR lsIndex > WBALI-RATE-HIST-LAST-LINE
102315         MOVE ZERO TO lsRateHistParentSeq
102315     ELSE
102315         MOVE WBALI-RATE-HIST-PARENT (lsIndex)
102315                      TO lsRateHistParentSeq.
102315
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistParentSeq.

122613******************************************************************
122613*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
122613******************************************************************

102315 METHOD-ID. getRateHistType.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsIndex                     PIC S9(09) COMP-5.
102315 01 lsRateHistType              OBJECT REFERENCE CLASS-STRING.
102315
102315******************************************************************
102315 PROCEDURE DIVISION USING BY VALUE lsIndex
102315                    RETURNING lsRateHistType.
102315******************************************************************
102315
102315     IF lsIndex < 1 OR lsIndex > WBALI-RATE-HIST-LAST-LINE
102315         SET lsRateHistType TO ' '
102315     ELSE
102315         SET lsRateHistType TO WBALI-RATE-HIST-TYPE (lsIndex).
102315
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistType.

102315******************************************************************
102315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102315******************************************************************
102315 METHOD-ID. getRateHistChangeDate.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsIndex                      PIC S9(09) COMP-5.
102315 01 lsRateHistChangeDate         PIC S9(09) COMP-5.
102315
102315******************************************************************
102315 PROCEDURE DIVISION USING BY VALUE lsIndex
102315                    RETURNING lsRateHistChangeDate.
102315******************************************************************
102315
102315     IF lsIndex < 1 OR lsIndex > WBALI-RATE-HIST-LAST-LINE
102315         MOVE ZERO TO lsRateHistChangeDate
102315     ELSE
102315         MOVE WBALI-RATE-CHANGE-DATE (lsIndex)
102315                      TO lsRateHistChangeDate.
102315
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistChangeDate.

102315******************************************************************
102315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102315******************************************************************
102315 METHOD-ID. getRateHistEndDate.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsIndex                      PIC S9(09) COMP-5.
102315 01 lsRateHistEndDate            PIC S9(09) COMP-5.
102315
102315******************************************************************
102315 PROCEDURE DIVISION USING BY VALUE lsIndex
102315                    RETURNING lsRateHistEndDate.
102315******************************************************************
102315
102315     IF lsIndex < 1 OR lsIndex > WBALI-RATE-HIST-LAST-LINE
102315         MOVE ZERO TO lsRateHistEndDate
102315     ELSE
102315         MOVE WBALI-RATE-END-DATE (lsIndex)
102315                      TO lsRateHistEndDate.
102315
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistEndDate.

102315******************************************************************
102315*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102315******************************************************************
102315 METHOD-ID. getRateHistInterestRate.
102315 DATA DIVISION.
102315******************************************************************
102315 WORKING-STORAGE SECTION.
102315******************************************************************
102315 LINKAGE SECTION.
102315
102315 01 lsIndex                           PIC S9(09) COMP-5.
102315 01 lsRateHistInterestRate            USAGE COMP-2.
102315
102315******************************************************************
102315 PROCEDURE DIVISION USING BY VALUE lsIndex
102315                    RETURNING lsRateHistInterestRate.
102315******************************************************************
102315
102315     IF lsIndex < 1 OR lsIndex > WBALI-RATE-HIST-LAST-LINE
102315         MOVE ZERO TO lsRateHistInterestRate
102315     ELSE
102315         MOVE WBALI-RATE-INT-RATE (lsIndex)
102315                      TO lsRateHistInterestRate.
102315
102315     EXIT METHOD.
102315
102315 END METHOD getRateHistInterestRate.

021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getLastModel.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsLastModel                 PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION RETURNING lsLastModel.
021816******************************************************************
021816
021816     MOVE WBALI-LAST-MODEL TO lsLastModel.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getLastModel.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelID.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelID OBJECT REFERENCE CLASS-STRING.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelID.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
021816          RETURNING lsModelID
021816     ELSE
021816         INVOKE CLASS-STRING "NEW" USING
021816                     BY VALUE WBALI-MODEL-ID (lsIndex)
021816          RETURNING lsModelID.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelID.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelVersion.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelVersion              PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelVersion.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         MOVE ZERO TO lsModelVersion
021816     ELSE
021816         MOVE WBALI-MODEL-VERSION (lsIndex)
021816                       TO lsModelVersion.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelVersion.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelMdlmIdent.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelMdlmIdent            PIC S9(18) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelMdlmIdent.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         MOVE ZERO TO lsModelMdlmIdent
021816     ELSE
021816         MOVE WBALI-MODEL-MDLM-IDENT (lsIndex)
021816                       TO lsModelMdlmIdent.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelMdlmIdent.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelType.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelType OBJECT REFERENCE CLASS-STRING.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelType.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
021816          RETURNING lsModelType
021816     ELSE
021816         INVOKE CLASS-STRING "NEW" USING
021816                     BY VALUE WBALI-MODEL-TYPE (lsIndex)
021816          RETURNING lsModelType.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelType.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelBalance.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelBalance              USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelBalance.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         MOVE ZERO TO lsModelBalance
021816     ELSE
021816         MOVE WBALI-MODEL-BALANCE (lsIndex)
021816                       TO lsModelBalance.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelBalance.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getModelSubModelCount.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsModelSubModelCount        PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsModelSubModelCount.
021816******************************************************************
021816
021816     IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
021816         MOVE ZERO TO lsModelSubModelCount
021816     ELSE
021816         MOVE WBALI-MODEL-SUB-MODEL-COUNT (lsIndex)
021816                       TO lsModelSubModelCount.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getModelSubModelCount.
021816
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getModelRebalFlag.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsModelRebalFlag          OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsModelRebalFlag.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
091916        INVOKE CLASS-STRING "NEW" USING
091916                   BY VALUE ' '
091916            RETURNING lsModelRebalFlag
091916    ELSE
091916        INVOKE CLASS-STRING "NEW" USING
091916                   BY VALUE WBALI-MODEL-REBAL-FLAG (lsIndex)
091916            RETURNING lsModelRebalFlag.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getModelRebalFlag.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getModelRebalDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsModelRebalDate          PIC S9(09) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsModelRebalDate.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
091916        MOVE ZERO TO lsModelRebalDate
091916    ELSE
091916        MOVE WBALI-MODEL-REBAL-DATE (lsIndex)
091916          TO lsModelRebalDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getModelRebalDate.
091916
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getLastSubModel.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsLastSubModel              PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION RETURNING lsLastSubModel.
021816******************************************************************
021816
021816     MOVE WBALI-LAST-SUB-MODEL TO lsLastSubModel.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getLastSubModel.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelModel.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelModel             PIC S9(09) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelModel.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         MOVE ZERO TO lsSubModelModel
021816     ELSE
021816         MOVE WBALI-SUB-MODEL-MODEL (lsIndex)
021816                       TO lsSubModelModel.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelModel.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelID.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelID OBJECT REFERENCE CLASS-STRING.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelID.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         INVOKE CLASS-STRING "NEW" USING BY VALUE ' '
021816          RETURNING lsSubModelID
021816     ELSE
021816         INVOKE CLASS-STRING "NEW" USING
021816                 BY VALUE WBALI-SUB-MODEL-ID (lsIndex)
021816          RETURNING lsSubModelID.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelID.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelMdlbIdent.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelMdlbIdent         PIC S9(18) COMP-5.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelMdlbIdent.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         MOVE ZERO TO lsSubModelMdlbIdent
021816     ELSE
021816         MOVE WBALI-SUB-MODEL-MDLB-IDENT (lsIndex)
021816                       TO lsSubModelMdlbIdent.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelMdlbIdent.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelBalance.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelBalance           USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelBalance.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         MOVE ZERO TO lsSubModelBalance
021816     ELSE
021816         MOVE WBALI-SUB-MODEL-BALANCE (lsIndex)
021816                       TO lsSubModelBalance.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelBalance.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelHybridCap.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelHybridCap         USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelHybridCap.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         MOVE ZERO TO lsSubModelHybridCap
021816     ELSE
021816         MOVE WBALI-SUB-MODEL-HYBRID-CAP (lsIndex)
021816                       TO lsSubModelHybridCap.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelHybridCap.
021816
021816******************************************************************
021816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
021816******************************************************************
021816 METHOD-ID. getSubModelHybridFloor.
021816 DATA DIVISION.
021816******************************************************************
021816 WORKING-STORAGE SECTION.
021816******************************************************************
021816 LINKAGE SECTION.
021816
021816 01 lsIndex                     PIC S9(09) COMP-5.
021816 01 lsSubModelHybridFloor       USAGE COMP-2.
021816
021816******************************************************************
021816 PROCEDURE DIVISION USING BY VALUE lsIndex
021816                    RETURNING lsSubModelHybridFloor.
021816******************************************************************
021816
021816     IF lsIndex  < 1 OR lsIndex  > WBALI-LAST-SUB-MODEL
021816         MOVE ZERO TO lsSubModelHybridFloor
021816     ELSE
021816         MOVE WBALI-SUB-MODEL-HYBRID-FLOOR (lsIndex)
021816                       TO lsSubModelHybridFloor.
021816
021816     EXIT METHOD.
021816
021816 END METHOD getSubModelHybridFloor.
021816
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getSubModelRebalFlag.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsSubModelRebalFlag       OBJECT REFERENCE CLASS-STRING.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsSubModelRebalFlag.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
091916        INVOKE CLASS-STRING "NEW" USING
091916                   BY VALUE ' '
091916            RETURNING lsSubModelRebalFlag
091916    ELSE
091916        INVOKE CLASS-STRING "NEW" USING
091916                   BY VALUE WBALI-SUB-MODEL-REBAL-FLAG (lsIndex)
091916            RETURNING lsSubModelRebalFlag.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getSubModelRebalFlag.
091916
091916******************************************************************
091916*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
091916******************************************************************
091916 METHOD-ID. getSubModelRebalDate.
091916 DATA DIVISION.
091916******************************************************************
091916 WORKING-STORAGE SECTION.
091916******************************************************************
091916 LINKAGE SECTION.
091916
091916 01 lsIndex                   PIC S9(09) COMP-5.
091916 01 lsSubModelRebalDate       PIC S9(09) COMP-5.
091916
091916******************************************************************
091916 PROCEDURE DIVISION USING BY VALUE lsIndex
091916                   RETURNING lsSubModelRebalDate.
091916******************************************************************
091916
091916    IF lsIndex < 1 OR lsIndex > WBALI-LAST-MODEL
091916        MOVE ZERO TO lsSubModelRebalDate
091916    ELSE
091916        MOVE WBALI-SUB-MODEL-REBAL-DATE (lsIndex)
091916          TO lsSubModelRebalDate.
091916
091916    EXIT METHOD.
091916
091916 END METHOD getSubModelRebalDate.
091916


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
101716******************************************************************
101716 METHOD-ID. setFunctionFlag.
101716 DATA DIVISION.
101716******************************************************************
101716 WORKING-STORAGE SECTION.
101716******************************************************************
101716 LINKAGE SECTION.
101716
101716 01 lsFunctionFlag                OBJECT REFERENCE CLASS-STRING.
101716
101716******************************************************************
101716 PROCEDURE DIVISION USING BY VALUE lsFunctionFlag.
101716******************************************************************
101716
101716     SET WBALI-FUNCTION-FLAG to lsFunctionFlag.
101716
101716     EXIT METHOD.
101716
101716 END METHOD setFunctionFlag.
101716******************************************************************
101716*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
101716******************************************************************

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

           SET WBALI-COMPANY-CODE to lsCompanyCode.

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

           SET WBALI-POLICY-NUMBER to lsPolicyNumber.

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

           MOVE lsEffectiveDate TO WBALI-RQST-DATE.
           EXIT METHOD.

       END METHOD setEffectiveDate.


041516******************************************************************
041516*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
041516******************************************************************
041516 METHOD-ID. setStopSearchDate.
041516 DATA DIVISION.
041516******************************************************************
041516 WORKING-STORAGE SECTION.
041516******************************************************************
041516 LINKAGE SECTION.
041516
041516 01 lsStopSearchDate               PIC S9(09) USAGE COMP-5.
041516
041516******************************************************************
041516 PROCEDURE DIVISION USING BY VALUE lsStopSearchDate
041516******************************************************************
041516
041516     MOVE lsStopSearchDate TO WBALI-STOP-SEARCH-DATE
041516     EXIT METHOD.
041516
041516 END METHOD setStopSearchDate.

       END OBJECT.
       END CLASS OBALINQU.
