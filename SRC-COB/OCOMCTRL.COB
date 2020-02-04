       IDENTIFICATION DIVISION.
       CLASS-ID. OCOMCTRL AS "LPNETAPI.OCOMCTRL".
      *AUTHOR.         D. Ross. 
      *DATE-WRITTEN.   March 2013. 
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
      *D API that allows retrieval and updating of Commission Control 
      *D Split information. 
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
030113*H 20130226-004-01 DAR Initial implementation.                                              
080416*H 20141010-004-01 DAR Allow addition of agent license                                      
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.

       REPOSITORY.

           CLASS OAPPLICA AS "LPNETAPI.OAPPLICA"
           CLASS CLASS-EXCEPTION AS "System.Exception"
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

       01  WS-PROGRAM-INFO.
           05  PCMCTBOX                     PIC X(08) VALUE 'PCMCTBOX'.

           COPY WGLOBCPY.
           COPY WGLB2CPY.
           COPY WGLBXCPY.
           COPY WCMCPCPY.

       01  LpApp                      USAGE OBJECT REFERENCE OAPPLICA.
       01  WS-EXCEPTION        OBJECT REFERENCE CLASS-EXCEPTION.

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

           MOVE wsReturnCode to WCMCP-RETURN-CODE.
           IF wsReturnCode NOT = ZERO
               MOVE wsErrorMessage to WCMCP-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WCMCP-ERROR-MESSAGE.

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
               MOVE wsErrorMessage to WCMCP-ERROR-MESSAGE
           ELSE
               MOVE SPACES TO WCMCP-ERROR-MESSAGE.

       END METHOD Dispose.

      ******************************************************************
       METHOD-ID. AddNewCommissionSplit.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WCMCP-ADD-SPLIT TO TRUE.

           TRY
               CALL PCMCTBOX USING WGLOBAL
                                   WCMCP-PARAMETERS
           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008 TO WCMCP-RETURN-CODE
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                   TO WCMCP-ERROR-MESSAGE
           END-TRY.

           MOVE WCMCP-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.

       END METHOD AddNewCommissionSplit.


      ******************************************************************
       METHOD-ID. RetrieveCommissionSplits.
      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01  lsReturnCode                PIC S9(09) USAGE COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

           SET WCMCP-RETRIEVE-SPLITS TO TRUE.

           TRY
               CALL PCMCTBOX USING WGLOBAL
                                   WCMCP-PARAMETERS
           CATCH WS-EXCEPTION
               INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
               MOVE 8008 TO WCMCP-RETURN-CODE
               MOVE 'Unexpected Abend in API - see Windows Event Log'
                   TO WCMCP-ERROR-MESSAGE
           END-TRY.

           MOVE WCMCP-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.

       END METHOD RetrieveCommissionSplits.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
      * These get and set methods take as input, and provide as output,
      * types that are part of the Common Language Runtime.
      * S9(09) COMP-5 maps to Integer, COMP-2 to Double precision floating point,
      * and CLASS-STRING maps to String.  This allows these get/set methods
      * to be used in VB, C# and in COBOL.NET.
      ******************************************************************

       METHOD-ID. setUpdateRelationshipsFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsRelationshipFlag             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsRelationshipFlag.

           SET WCMCP-RELATIONSHIP-FLAG TO lsRelationshipFlag.

           EXIT METHOD.
       END METHOD setUpdateRelationshipsFlag.

      ******************************************************************

080416 METHOD-ID. setAddStateLicense.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsRelationshipFlag             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsRelationshipFlag.
080416
080416     SET WCMP-ADD-STATE-LICENSE-FLAG
080416                TO lsRelationshipFlag.
080416
080416     EXIT METHOD.
080416 END METHOD setAddStateLicense.
080416
080416******************************************************************
       METHOD-ID. setCompanyCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsCompanyCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsCompanyCode.

           SET WCMCP-COMPANY-CODE TO lsCompanyCode.

           EXIT METHOD.
       END METHOD setCompanyCode.

      ******************************************************************

       METHOD-ID. setPolicyNumber.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsPolicyNumber             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.

           SET WCMCP-POLICY-NUMBER TO lsPolicyNumber.

           EXIT METHOD.
       END METHOD setPolicyNumber.
      **************************************************************************

       METHOD-ID. setSplitControl.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsSplitControl             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsSplitControl.

           MOVE lsSplitControl TO WCMCP-SPLIT-CONTROL.

           EXIT METHOD.
       END METHOD setSplitControl.
      **************************************************************************

       METHOD-ID. setIssueDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIssueDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIssueDate.

           MOVE lsIssueDate TO WCMCP-ISSUE-DATE.

           EXIT METHOD.
       END METHOD setIssueDate.
      **************************************************************************

       METHOD-ID. setEffectiveDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsEffectiveDate             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.

           MOVE lsEffectiveDate TO WCMCP-EFFECTIVE-DATE.

           EXIT METHOD.
       END METHOD setEffectiveDate.
      **************************************************************************

       METHOD-ID. setAddRateOverrideFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddRateOverrideFlag  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddRateOverrideFlag.

           SET WCMCP-ADD-RATE-OVERRIDE-FLAG TO lsAddRateOverrideFlag.

           EXIT METHOD.
       END METHOD setAddRateOverrideFlag.
      **************************************************************************

       METHOD-ID. setAddReferralFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddReferralFlag             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddReferralFlag.

           SET WCMCP-ADD-REFERRAL-FLAG TO lsAddReferralFlag.

           EXIT METHOD.
       END METHOD setAddReferralFlag.
      **************************************************************************

       METHOD-ID. setAddProdCrFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddProdCrFlag             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddProdCrFlag.

           SET WCMCP-ADD-PROD-CR-FLAG TO lsAddProdCrFlag.

           EXIT METHOD.
       END METHOD setAddProdCrFlag.
      **************************************************************************

       METHOD-ID. setAddAttainedAge.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddAttainedAge             PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsAddAttainedAge.

           MOVE lsAddAttainedAge TO WCMCP-ADD-ATTAINED-AGE.

           EXIT METHOD.
       END METHOD setAddAttainedAge.
      **************************************************************************

       METHOD-ID. setAddPremiumIncrease.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddPremiumIncrease  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddPremiumIncrease.

           SET WCMCP-ADD-PREMIUM-INCREASE TO lsAddPremiumIncrease.

           EXIT METHOD.
       END METHOD setAddPremiumIncrease.

      **************************************************************************

       METHOD-ID. setAddOverrideFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsAddOverrideFlag  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsAddOverrideFlag.

           SET WCMCP-ADD-OVERRIDE-FLAG TO lsAddOverrideFlag.

           EXIT METHOD.
       END METHOD setAddOverrideFlag.

      **************************************************************************

       METHOD-ID. setAddAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsAddAgent             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAddAgent.

           SET WCMCP-ADD-AGENT (lsIndex) TO lsAddAgent.

           EXIT METHOD.
       END METHOD setAddAgent.

      **************************************************************************

       METHOD-ID. setAddCommPcnt.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAddCommPcnt             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAddCommPcnt.

           MOVE lsAddCommPcnt TO WCMCP-ADD-COMM-PCNT (lsIndex).

           EXIT METHOD.
       END METHOD setAddCommPcnt.
      **************************************************************************

       METHOD-ID. setAddProdPcnt.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                   PIC S9(09) COMP-5.
       01  lsAddProdPcnt             USAGE IS COMP-2.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAddProdPcnt.

           MOVE lsAddProdPcnt TO WCMCP-ADD-PROD-PCNT (lsIndex).

           EXIT METHOD.
       END METHOD setAddProdPcnt.
      **************************************************************************

       METHOD-ID. setAddServiceAgentInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsAddServiceAgentInd   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING   BY VALUE lsIndex
                                  BY VALUE lsAddServiceAgentInd.

           SET WCMCP-ADD-SERVICE-AGENT-IND (lsIndex)
                              TO lsAddServiceAgentInd

           EXIT METHOD.
       END METHOD setAddServiceAgentInd.
      **************************************************************************

       METHOD-ID. setAddMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsAddMarketCode             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAddMarketCode.

           SET WCMCP-ADD-MARKET-CODE (lsIndex) TO lsAddMarketCode.

           EXIT METHOD.
       END METHOD setAddMarketCode.
      **************************************************************************

       METHOD-ID. setAddAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                     PIC S9(09) COMP-5.
       01  lsAddAgentLevel             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                                BY VALUE lsAddAgentLevel.

           SET WCMCP-ADD-AGENT-LEVEL (lsIndex) TO lsAddAgentLevel.

           EXIT METHOD.
       END METHOD setAddAgentLevel.
      **************************************************************************

080416 METHOD-ID. setLicenseState.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseState             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseState.
080416
080416     SET WCMCP-STATE-LICENSED (lsIndex) TO lsLicenseState.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseState.
080416**************************************************************************
080416 METHOD-ID. setLicenseStatus.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseStatus             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseStatus.
080416
080416     SET WCMCP-LICENSE-STATUS-CODE (lsIndex)
080416               TO lsLicenseStatus.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseStatus.
080416**************************************************************************
080416 METHOD-ID. setLicenseReasonCode.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseReasonCode             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseReasonCode.
080416
080416     SET WCMCP-LICENSE-REASON-CODE  (lsIndex)
080416               TO lsLicenseReasonCode.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseReasonCode.
080416**************************************************************************
080416 METHOD-ID. setLicenseGrantedDate.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                         PIC S9(09) COMP-5.
080416 01  lsLicenseGrantedDate            PIC S9(09) COMP-5.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseGrantedDate.
080416
080416     MOVE lsLicenseGrantedDate
080416         TO WCMCP-LICENSE-GRANTED  (lsIndex).
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseGrantedDate.
080416**************************************************************************
080416 METHOD-ID. setLicenseExpiresDate.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                         PIC S9(09) COMP-5.
080416 01  lsLicenseExpiresDate            PIC S9(09) COMP-5.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseExpiresDate.
080416
080416     MOVE lsLicenseExpiresDate
080416         TO WCMCP-LICENSE-EXPIRES (lsIndex).
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseExpiresDate.
080416**************************************************************************
080416 METHOD-ID. setLicenseResidentCode.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseResidentCode       OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseResidentCode.
080416
080416     SET WCMCP-RESIDENT-CODE (lsIndex)
080416               TO lsLicenseResidentCode.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseResidentCode.
080416**************************************************************************
080416 METHOD-ID. setLicenseNASD.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseNASD             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseNASD.
080416
080416     SET WCMCP-NASD (lsIndex)
080416               TO lsLicenseNASD.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseNASD.
080416**************************************************************************
080416 METHOD-ID. setLicenseLife.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseLife             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseLife.
080416
080416     SET WCMCP-LIFE (lsIndex)
080416               TO lsLicenseLife.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseLife.
080416**************************************************************************
080416 METHOD-ID. setLicenseHealth.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseHealth             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseHealth.
080416
080416     SET WCMCP-HEALTH (lsIndex)
080416               TO lsLicenseHealth.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseHealth.
080416**************************************************************************
080416 METHOD-ID. setLicenseAnnuity.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseAnnuity             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseAnnuity.
080416
080416     SET WCMCP-ANNUITY (lsIndex)
080416               TO lsLicenseAnnuity.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseAnnuity.
080416**************************************************************************
080416 METHOD-ID. setLicenseBasicLTC.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseBasicLTC             OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseBasicLTC.
080416
080416     SET WCMCP-BASIC-LTC (lsIndex)
080416               TO lsLicenseBasicLTC.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseBasicLTC.
080416**************************************************************************
080416 METHOD-ID. setLicenseBasicLastRenewal.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                         PIC S9(09) COMP-5.
080416 01  lsLicenseBasicLastRenewal       PIC S9(09) COMP-5.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseBasicLastRenewal.
080416
080416     MOVE lsLicenseBasicLastRenewal
080416         TO WCMCP-BASIC-LAST-RENEWAL  (lsIndex).
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseBasicLastRenewal.
080416**************************************************************************
080416 METHOD-ID. setLicenseBasicNextRenewal.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                         PIC S9(09) COMP-5.
080416 01  lsLicenseBasicNextRenewal       PIC S9(09) COMP-5.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseBasicNextRenewal.
080416
080416     MOVE lsLicenseBasicNextRenewal
080416         TO WCMCP-BASIC-NEXT-RENEWAL  (lsIndex).
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseBasicNextRenewal.
080416**************************************************************************
080416 METHOD-ID. setLicenseNumber.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseNumber      OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseNumber.
080416
080416     SET WCMCP-LICENSE-NUMBER (lsIndex)
080416               TO lsLicenseNumber.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseNumber.
080416**************************************************************************
080416 METHOD-ID. setLicenseType.
080416 DATA DIVISION.
080416 WORKING-STORAGE SECTION.
080416 LINKAGE SECTION.
080416 01  lsIndex                     PIC S9(09) COMP-5.
080416 01  lsLicenseType        OBJECT REFERENCE CLASS-STRING.
080416 PROCEDURE DIVISION USING BY VALUE lsIndex
080416                          BY VALUE lsLicenseType.
080416
080416     SET WCMCP-LICENSE-TYPE(lsIndex)
080416               TO lsLicenseType.
080416
080416     EXIT METHOD.
080416 END METHOD setLicenseType.
      **************************************************************************

       METHOD-ID. getReturnCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsReturnCode               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsReturnCode.

           MOVE WCMCP-RETURN-CODE TO lsReturnCode.

           EXIT METHOD.
       END METHOD getReturnCode.

      **************************************************************************

       METHOD-ID. getErrorMessage.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsErrorMessage               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION RETURNING lsErrorMessage.

           SET lsErrorMessage TO WCMCP-ERROR-MESSAGE

           EXIT METHOD.
       END METHOD getErrorMessage.


      **************************************************************************

       METHOD-ID. getOutLastSplitEntry.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsOutLastSplitEntry               PIC S9(09) COMP-5.
       PROCEDURE DIVISION RETURNING lsOutLastSplitEntry.

           MOVE WCMCP-OUT-LAST-SPLIT-ENTRY TO lsOutLastSplitEntry.

           EXIT METHOD.
       END METHOD getOutLastSplitEntry.

      **************************************************************************

       METHOD-ID. getOutSplitControl.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                         PIC S9(09) COMP-5.
       01  lsOutSplitControl               PIC S9(04) COMP-5.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutSplitControl.

           MOVE WCMCP-OUT-SPLIT-CONTROL (lsIndex) TO lsOutSplitControl.

           EXIT METHOD.
       END METHOD getOutSplitControl.

      **************************************************************************

       METHOD-ID. getOutIssueDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                         PIC S9(09) COMP-5.
       01  lsOutIssueDate                  PIC S9(09) COMP-5.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutIssueDate.

           MOVE WCMCP-OUT-ISSUE-DATE (lsIndex) TO lsOutIssueDate.

           EXIT METHOD.
       END METHOD getOutIssueDate.

      **************************************************************************

       METHOD-ID. getOutEffectiveDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                          PIC S9(09) COMP-5.
       01  lsOutEffectiveDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsOutEffectiveDate.

           MOVE WCMCP-OUT-EFFECTIVE-DATE (lsIndex)
                                    TO lsOutEffectiveDate.

           EXIT METHOD.
       END METHOD getOutEffectiveDate.

      **************************************************************************

       METHOD-ID. getOutEndDate.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                          PIC S9(09) COMP-5.
       01  lsOutEndDate               PIC S9(09) COMP-5.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsOutEndDate.

           MOVE WCMCP-OUT-END-DATE (lsIndex) TO lsOutEndDate.

           EXIT METHOD.
       END METHOD getOutEndDate.

      **************************************************************************

       METHOD-ID. getOutRateOverrideFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsOutRateOverrideFlag  OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsOutRateOverrideFlag.

           SET lsOutRateOverrideFlag
                    TO WCMCP-OUT-RATE-OVERRIDE-FLAG (lsIndex)

           EXIT METHOD.
       END METHOD getOutRateOverrideFlag.

      **************************************************************************

       METHOD-ID. getOutReferralFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsOutReferralFlag      OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutReferralFlag.

           SET lsOutReferralFlag TO WCMCP-OUT-REFERRAL-FLAG (lsIndex).


           EXIT METHOD.
       END METHOD getOutReferralFlag.

      **************************************************************************

       METHOD-ID. getOutProdCrFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                       PIC S9(09) COMP-5.
       01  lsOutProdCrFlag               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex
                          RETURNING lsOutProdCrFlag.

           SET lsOutProdCrFlag TO WCMCP-OUT-PROD-CR-FLAG (lsIndex).


           EXIT METHOD.
       END METHOD getOutProdCrFlag.

      **************************************************************************

       METHOD-ID. getOutAttainedAge.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsOutAttainedAge       PIC S9(04) COMP-5.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutAttainedAge.

           MOVE WCMCP-OUT-ATTAINED-AGE (lsIndex) TO lsOutAttainedAge.

           EXIT METHOD.
       END METHOD getOutAttainedAge.

      **************************************************************************

       METHOD-ID. getOutPremiumIncrease.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsOutPremiumIncrease   OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsOutPremiumIncrease.

           SET lsOutPremiumIncrease
                    TO WCMCP-OUT-PREMIUM-INCREASE (lsIndex).


           EXIT METHOD.
       END METHOD getOutPremiumIncrease.

      **************************************************************************

       METHOD-ID. getOutCoderId.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                  PIC S9(09) COMP-5.
       01  lsOutCoderId             OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutCoderId.

           SET lsOutCoderId TO WCMCP-OUT-CODER-ID (lsIndex).

           EXIT METHOD.
       END METHOD getOutCoderId.

      **************************************************************************
       METHOD-ID. getOutOverrideFlag.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                PIC S9(09) COMP-5.
       01  lsOutOverrideFlag      OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION   USING BY VALUE lsIndex
                            RETURNING lsOutOverrideFlag.

           SET lsOutOverrideFlag TO WCMCP-OUT-OVERRIDE-FLAG (lsIndex).


           EXIT METHOD.
       END METHOD getOutOverrideFlag.

      **************************************************************************

       METHOD-ID. getOutLastSplitAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex                           PIC S9(09) COMP-5.
       01  lsOutLastSplitAgent               PIC S9(09) COMP-5.
       PROCEDURE DIVISION  USING BY VALUE lsIndex
                           RETURNING lsOutLastSplitAgent.

           MOVE WCMCP-OUT-LAST-SPLIT-AGENT (lsIndex)
                                    TO lsOutLastSplitAgent.

           EXIT METHOD.
       END METHOD getOutLastSplitAgent.


      **************************************************************************

       METHOD-ID. getOutAgent.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1                 PIC S9(09) COMP-5.
       01  lsIndex2                 PIC S9(09) COMP-5.
       01  lsOutAgent               OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION USING BY VALUE lsIndex1
                                BY VALUE lsIndex2
                          RETURNING lsOutAgent.

           SET lsOutAgent TO WCMCP-OUT-AGENT (lsIndex1, lsIndex2).

           EXIT METHOD.
       END METHOD getOutAgent.

      **************************************************************************

       METHOD-ID. getOutCommPcnt.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1                 PIC S9(09) COMP-5.
       01  lsIndex2                 PIC S9(09) COMP-5.
       01  lsOutCommPcnt            USAGE IS COMP-2.
       PROCEDURE DIVISION  USING BY VALUE lsIndex1
                                 BY VALUE lsIndex2
                           RETURNING lsOutCommPcnt.

           MOVE WCMCP-OUT-COMM-PCNT (lsIndex1, lsIndex2)
                                TO lsOutCommPcnt.

           EXIT METHOD.

       END METHOD getOutCommPcnt.

      **************************************************************************

       METHOD-ID. getOutProdPcnt.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1                 PIC S9(09) COMP-5.
       01  lsIndex2                 PIC S9(09) COMP-5.
       01  lsOutProdPcnt            USAGE IS COMP-2.
       PROCEDURE DIVISION  USING BY VALUE lsIndex1
                                 BY VALUE lsIndex2
                           RETURNING lsOutProdPcnt.

           MOVE WCMCP-OUT-PROD-PCNT (lsIndex1, lsIndex2)
                                    TO lsOutProdPcnt.

           EXIT METHOD.
       END METHOD getOutProdPcnt.

      **************************************************************************

       METHOD-ID. getOutServiceAgentInd.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1                 PIC S9(09) COMP-5.
       01  lsIndex2                 PIC S9(09) COMP-5.
       01  lsOutServiceAgentInd     OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION  USING BY VALUE lsIndex1
                                 BY VALUE lsIndex2
                           RETURNING lsOutServiceAgentInd.

           SET lsOutServiceAgentInd
                TO WCMCP-OUT-SERVICE-AGENT-IND (lsIndex1, lsIndex2)

           EXIT METHOD.
       END METHOD getOutServiceAgentInd.

      **************************************************************************

       METHOD-ID. getOutMarketCode.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1          PIC S9(09) COMP-5.
       01  lsIndex2          PIC S9(09) COMP-5.
       01  lsOutMarketCode   OBJECT REFERENCE CLASS-STRING.

       PROCEDURE DIVISION  USING BY VALUE lsIndex1
                                 BY VALUE lsIndex2
                           RETURNING lsOutMarketCode.

           SET lsOutMarketCode
                TO WCMCP-OUT-MARKET-CODE (lsIndex1, lsIndex2)

           EXIT METHOD.
       END METHOD getOutMarketCode.

      **************************************************************************

       METHOD-ID. getOutAgentLevel.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
       01  lsIndex1                 PIC S9(09) COMP-5.
       01  lsIndex2                 PIC S9(09) COMP-5.
       01  lsOutAgentLevel          OBJECT REFERENCE CLASS-STRING.
       PROCEDURE DIVISION  USING BY VALUE lsIndex1
                                 BY VALUE lsIndex2
                           RETURNING lsOutAgentLevel.

           SET lsOutAgentLevel
                      TO WCMCP-OUT-AGENT-LEVEL (lsIndex1, lsIndex2)

           EXIT METHOD.

       END METHOD getOutAgentLevel.

      **************************************************************************

       END OBJECT.
       END CLASS OCOMCTRL.

