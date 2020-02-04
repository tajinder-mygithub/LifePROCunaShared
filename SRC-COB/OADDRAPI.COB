       IDENTIFICATION DIVISION.
       CLASS-ID. OADDRAPI AS "LPNETAPI.OADDRAPI".
022703*AUTHOR.         PDMA.
022703*DATE-WRITTEN.   March 2002.
022703*DATE-COMPILED.
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
      *D BAPI object that receives and updates address information.
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
041702*H 20020327-005-01 TSC Added Batch Update.
022703*H 20030213-002-01 DAR Various changes to support latest 1.11 code.
091003*H 50000000-137-01 DAR Rewrote to create .NET API Library.  All API 
091003*H                 objects now are built into one .NET Assembly, 
091003*H                 LPNETAPI.DLL.  Cleared date stamps in program. 
012204*H 20031013-011-01 DAR Fitted to 1.12 base.  
083004*H 20040708-001-01 DAR Fixed udpate logic. 
012805*H 20030410-006-01 DAR Retrofitted 10.09 Galic Version to 11.07, and 
012805*H                     added effective date as property.             
062705*H 20050128-004-01 DAR Retrofit in 20030410-006-01
032907*H 20070329-004-01 DAR Increase WGLOB length.  Pulled in a Fax # fix. 
092308*H 20080402-003-01 JWS .NET testing error corrections
021709*H 20090216-005-01 JWS Added error handling
121009*H 20091112-002-01 JWS Support multiple addresses
010510*H 20091112-002-01 JWS Pass Address Code as well as Type back
062210*H 20100208-006-01 JWS Correct typo found in error message
032411*H 20110311-001-01 JWS Add ability to enter/update Address Type
032411*H                     and Gen Corresp from API if Mgmt Option set
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
022312*H 20111018-004-02 JVR Added Cell Phone Number to Name / Address record.
112612*H 20121126-001-01 DAR Created "Add" operation, and other enhancements
102813*H 20131015-001-01 DAR Support for WCF and Web Services
011116*H 20150601-002-01 AKR Get/Add/Update Address Methods for Co/Pol
011116*H 20150601-002-04 AKR Correct effective date Add and display order for "Q"
011116*H                     Address Code/Type functionality added
012016*H 20150601-001-01 AKR Adjustments to Add/Upd Methods
012116*H 20150601-001-01 AKR Adjustments to "P" vs "R" for WebSrvcs
012616*H 20150601-002-10 AKR Convert Policy Number to UpperCase
012716*H 20150601-002-12 AKR Convert other input fields to UpperCase for all functions
020116*H 20150601-002-13 AKR Retrofit Co/Pol Mod and PTRs into HiTips
020916*H 20160205-001-01 AKR Insert CO/POL Nalk If Update Fails On "P"olicy Update
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
092308     05  PADDRBOX                PIC X(08) VALUE 'PADDRBOX'.
092308     05  PDATECON                PIC X(08) VALUE 'PDATECON'.
092308     05  PNADRBOX                PIC X(08) VALUE 'PNADRBOX'.
092308     05  PSQLFUNC                PIC X(08) VALUE 'PSQLFUNC'.
092308     05  PADDRBTC                PIC X(08) VALUE 'PADDRBTC'.
121009     05  PFILEBTV                PIC X(08) VALUE 'PFILEBTV'.
112612*01  WS-HOLD-WNALK-RECORD        PIC X(72).
           COPY WADDRCPY.
           COPY WADDRBOX.
           COPY WGLOBCPY.
           COPY WGLBXCPY.
121009     COPY WBTRVCPY.
011116     COPY WRELACPY.
011116     COPY WAPPLCPY   REPLACING
011116         WAPPL-CALL-PARAMETERS BY WRELA-CALL-PARAMETERS
011116         WAPPL-FUNCTION        BY WRELA-FUNCTION
011116         WAPPL-KEY-NUMBER      BY WRELA-KEY-NUMBER
011116         WAPPL-RETURN-CODE     BY WRELA-RETURN-CODE
011116         WAPPL-RETURN-NOT-OK   BY WRELA-RETURN-NOT-OK.
           COPY WNALKCPY.
121009     COPY WAPPLCPY   REPLACING
121009         WAPPL-CALL-PARAMETERS BY WNALK-CALL-PARAMETERS
121009         WAPPL-FUNCTION        BY WNALK-FUNCTION
121009         WAPPL-KEY-NUMBER      BY WNALK-KEY-NUMBER
121009         WAPPL-RETURN-CODE     BY WNALK-RETURN-CODE
121009         WAPPL-RETURN-NOT-OK   BY WNALK-RETURN-NOT-OK.

112612 78  WS-NALK-LEN VALUE LENGTH OF WNALK-DATA-RECORD.
112612 01  WS-HOLD-WNALK-RECORD        PIC X(WS-NALK-LEN).

       78  WS-ADDR-LEN VALUE LENGTH OF WADDR-DATA-RECORD.
112612 01  WS-PRE-UPDATE-NALK          PIC X(WS-NALK-LEN).
112612 01  WS-PRE-UPDATE-ADDR          PIC X(WS-ADDR-LEN).

011116 78  WS-RELA-LEN VALUE LENGTH OF WRELA-DATA-RECORD.
011116 01  WS-HOLD-WRELA-RECORD        PIC X(WS-RELA-LEN).

       01  wsAddressReadFlag           PIC X(01)       VALUE 'N'.
           88  wsAddressWasRead                        VALUE 'Y'.
           88  wsAddressNotRead                        VALUE 'N'.

020916* Flag Set During Query which is required prior to Update.
020916* Most likely the default address has been returned
020916* at the Default Relationship Level and NOT the Co/Policy level
020916* since the Co/Policy levels are exceptions.   20150601-002 Mod
020916* requested that in the event the CO/Policy NALK doe NOT exist
020916* when requesting and UPDATE to INSERT one.
020916*
020916 01 WS-NALK-UPDATE-FLAG          PIC X(01)    VALUE SPACES.
020916    88  NALK-WILL-UPDATE                      VALUE 'U'.
020916    88  NALK-WILL-INSERT                      VALUE 'I'.
020916
020916 01 WS-HOLD-QUERY-FLAG           PIC X(01).

      ******************************************************************
      * Object Properties
      ******************************************************************

      * input

      * *** Set the following flag to determine which action you want
      * *** to perform.  The default is a Query.
      *
      *    Q - Query
112612*    N - Get Next record   
      *    U - Update
112612*    A - Add  
041702*    B - Batch Update

       01  wsUpdateQueryFlag           PIC X(01).

       01  wsNameID                    PIC 9(08).

102813*    Used to locate an initial position for web service calls.  
102813 01  wsAddressID                 PIC 9(08).
102813 01  wsEffectiveDate             PIC 9(08).
102813 01  wsAddressCode               PIC X(03).
102813 01  wsIdentifyingNumber         PIC X(14).


041702
041702 01  wsDataSource                PIC X(40).
041702 01  wsUserID                    PIC X(25).
041702 01  wsPassword                  PIC X(20).
041702 01  wsOwningSystemID            PIC X(06).
041702 01  wsUpdateSystemID            PIC X(06).

011116 01  wsCompanyCode               PIC X(02).
011116 01  wsPolicyNumber              PIC X(12).
011116 01  wsRelateCode                PIC X(02).
011116 01  wsInAddressType             PIC X(01).
011116 01  wsInAddressCode             PIC X(03).
011116 01  wsUpdateIndicator           PIC X(01).
      * output

       01  LpReturnCode                PIC S9(09) COMP-5.
       01  LpErrorMessage              PIC X(200).

112612 01  LpOutputGroup.
112612     05  LpAddressID                 PIC 9(08).
112612     05  LpCancelDate                PIC 9(08).
112612     05  LpEffectiveDate             PIC 9(08).
112612     05  LpRecurringStartMonth       PIC 9(02).
112612     05  LpRecurringStartDay         PIC 9(02).
112612     05  LpRecurringStopMonth        PIC 9(02).
112612     05  LpRecurringStopDay          PIC 9(02).
112612     05  LpAlternateNameID           PIC 9(08).
112612     05  LpPhoneNumber               PIC 9(10).
112612     05  LpFaxNumber                 PIC 9(10).
112612     05  LpCellPhoneNumber           PIC 9(10).

      * LpAddressTypeValues:
      *    M - Mailing Address
      *    B - Business Address
      *    R - Residence Address
      *    N - No Address
      *    S - Shipping Address
      *    O - Other Address
      *
112612     05  LpAddressType               PIC X(01).
010510
010510* LpAddressCodeValues:
010510*    '   ' - Primary
010510*    'AGS' - Agent Stmnt
010510*    'ANS' - Annual Stmnt
010510*    'BIL' - Billing Stmnt
010510*    'LTR' - Letters
010510*    'PDS' - Periodic Stmnt
010510*    'TXS' - Tax Reporting
010510*    'BUS' - Business
010510*    'RES' - Residence
010510*    'SHP' - Shipping
010510*    'OTH' - Other
010510*
112612     05  LpAddressCode               PIC X(03).
112612     05  LpAddressLine1              PIC X(35).
112612     05  LpAddressLine2              PIC X(35).
112612     05  LpAddressLine3              PIC X(35).
112612     05  LpAddressCity               PIC X(24).
112612     05  LpAddressState              PIC X(02).
112612     05  LpAddressZipCode            PIC X(05).
112612     05  LpAddressBoxNumber          PIC X(04).
112612     05  LpAddressZipExtension       PIC X(02).
112612     05  LpAddressCountry            PIC X(30).
112612     05  LpAddressCounty             PIC X(19).
112612     05  LpAddressCountyCode         PIC X(10).
112612     05  LpAddressCityCode           PIC X(10).
112612     05  LpBadAddressInd             PIC X(01).

112612     05  LpFormatAddressLine1        PIC X(35).
112612     05  LpFormatAddressLine2        PIC X(35).
112612     05  LpFormatAddressLine3        PIC X(35).
112612     05  LpFormatAddressLine4        PIC X(35).

011116     05  LpUpdateNameId              PIC 9(08).
011116     05  LpRelationshipCode          PIC X(02).
011116 01  WCF-LpOutputGroup.
011116     05  WCF-LpAddressID                 PIC 9(08).
011116     05  WCF-LpCancelDate                PIC 9(08).
011116     05  WCF-LpEffectiveDate             PIC 9(08).
011116     05  WCF-LpRecurringStartMonth       PIC 9(02).
011116     05  WCF-LpRecurringStartDay         PIC 9(02).
011116     05  WCF-LpRecurringStopMonth        PIC 9(02).
011116     05  WCF-LpRecurringStopDay          PIC 9(02).
011116     05  WCF-LpAlternateNameID           PIC 9(08).
011116     05  WCF-LpPhoneNumber               PIC 9(10).
011116     05  WCF-LpFaxNumber                 PIC 9(10).
011116     05  WCF-LpCellPhoneNumber           PIC 9(10).
011116     05  WCF-LpAddressType               PIC X(01).
011116     05  WCF-LpAddressCode               PIC X(03).
011116     05  WCF-LpAddressLine1              PIC X(35).
011116     05  WCF-LpAddressLine2              PIC X(35).
011116     05  WCF-LpAddressLine3              PIC X(35).
011116     05  WCF-LpAddressCity               PIC X(24).
011116     05  WCF-LpAddressState              PIC X(02).
011116     05  WCF-LpAddressZipCode            PIC X(05).
011116     05  WCF-LpAddressBoxNumber          PIC X(04).
011116     05  WCF-LpAddressZipExtension       PIC X(02).
011116     05  WCF-LpAddressCountry            PIC X(30).
011116     05  WCF-LpAddressCounty             PIC X(19).
011116     05  WCF-LpAddressCountyCode         PIC X(10).
011116     05  WCF-LpAddressCityCode           PIC X(10).
011116     05  WCF-LpBadAddressInd             PIC X(01).
011116     05  WCF-LpFormatAddressLine1        PIC X(35).
011116     05  WCF-LpFormatAddressLine2        PIC X(35).
011116     05  WCF-LpFormatAddressLine3        PIC X(35).
011116     05  WCF-LpFormatAddressLine4        PIC X(35).
011116     05  WCF-LpUpdateNameId              PIC 9(08).
011116     05  WCF-LpRelationshipCode          PIC X(02).

112612 78 LP-OUTPUT-LEN VALUE LENGTH OF LpOutputGroup.
112612 01 LpSaveOutputGroup                PIC X(LP-OUTPUT-LEN).

      * Update Name Fields.  Fill these fields with the new name field
      * values for Name Update.

       01  LpUpdatePhoneNumber         PIC 9(10).
       01  LpUpdateFaxNumber           PIC 9(10).
022312 01  LpUpdateCellPhoneNumber     PIC 9(10).
032411 01  LpUpdateAddressType         PIC X(01).
       01  LpUpdateAddressLine1        PIC X(35).
       01  LpUpdateAddressLine2        PIC X(35).
       01  LpUpdateAddressLine3        PIC X(35).
       01  LpUpdateAddressCity         PIC X(24).
       01  LpUpdateAddressState        PIC X(02).
       01  LpUpdateAddressZipCode      PIC X(05).
       01  LpUpdateAddressBoxNumber    PIC X(04).
       01  LpUpdateAddressZipExtension PIC X(02).
       01  LpUpdateAddressCountry      PIC X(30).
       01  LpUpdateAddressCounty       PIC X(19).
       01  LpUpdateAddressCountyCode   PIC X(10).
       01  LpUpdateAddressCityCode     PIC X(10).

112612 01  LpUpdateAddressCode         PIC X(03).
112612 01  LpUpdateCancelDate          PIC 9(08).
112612 01  LpUpdateEffectiveDate       PIC 9(08).
112612 01  LpUpdateRecurringStartMonth PIC 9(02).
112612 01  LpUpdateRecurringStartDay   PIC 9(02).
112612 01  LpUpdateRecurringStopMonth  PIC 9(02).
112612 01  LpUpdateRecurringStopDay    PIC 9(02).
112612 01  LpUpdateAlternateNameID     PIC 9(08).
112612 01  LpUpdateBadAddressInd       PIC X(01).


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
012716
012716     MOVE wsUserType          TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE       TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING     TO wsUserType
012716
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
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunAddressFunction.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.


           COPY WDATECPY.
           COPY WNADRCPY.
           COPY WPGLBCPY.
041702     COPY WADBTCPY.
041702     COPY WSQLFCPY.

       01  WS-PNADRBOX-OPTION          PIC X(01).

       01 wsAddressChangedFlag         PIC X(01).
           88  wsAddressChanged                        VALUE 'Y'.
           88  wsAddressNotChanged                     VALUE 'N'.

      ******************************************************************
       LINKAGE SECTION.


       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************

112612     MOVE ZERO TO lsReturnCode,
112612                  LpReturnCode
112612     MOVE SPACES TO LpErrorMessage

           IF wsUpdateQueryFlag = 'U'
041702                         OR 'B'
               PERFORM 1000-ADDRESS-UPDATE
112612     ELSE
112612     IF wsUpdateQueryFlag = 'A'
112612         PERFORM 1500-ADDRESS-ADD
           ELSE
               PERFORM 2000-ADDRESS-QUERY
           END-IF.
           MOVE 'Q' TO wsUpdateQueryFlag.

           EXIT METHOD.
      ******************************************************************
       1000-ADDRESS-UPDATE.

021709     MOVE wsDataSource TO WSQLF-DATA-SOURCE.
021709     MOVE wsUserID TO WSQLF-USERID.
021709     MOVE wsPassword TO WSQLF-PASSWORD.

           SET wsAddressNotChanged TO TRUE.

112612*    If an error occurs on update, we will revert to original 
112612*    records.  
112612     MOVE WADDR-DATA-RECORD TO WS-PRE-UPDATE-ADDR
112612     MOVE WNALK-DATA-RECORD TO WS-PRE-UPDATE-NALK

112612*    TRY      
             IF wsAddressWasRead
             AND wsNameID = WNALK-NAME-ID
               IF LpUpdatePhoneNumber NOT = WNALK-PHONE-NUMBER
                   MOVE LpUpdatePhoneNumber
                       TO WNALK-PHONE-NUMBER
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateFaxNumber NOT = WNALK-FAX-NUMBER
                   MOVE LpUpdateFaxNumber
                       TO WNALK-FAX-NUMBER
                   SET wsAddressChanged TO TRUE
               END-IF
022312         IF LpUpdateCellPhoneNumber NOT = WNALK-CELL-NUMBER
022312             MOVE LpUpdateCellPhoneNumber
022312                   TO WNALK-CELL-NUMBER
022312             SET wsAddressChanged TO TRUE
022312         END-IF
112612*        IF LpUpdateAddressType NOT = WADDR-CITY-CODE
112612         IF LpUpdateAddressType NOT = WNALK-ADDRESS-TYPE
032411             MOVE LpUpdateAddressType
032411                 TO WNALK-ADDRESS-TYPE
032411             SET wsAddressChanged TO TRUE
032411         END-IF
               IF LpUpdateAddressLine1 NOT = WADDR-ADDR-LINE-1
                   MOVE LpUpdateAddressLine1
                       TO WADDR-ADDR-LINE-1
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressLine2 NOT = WADDR-ADDR-LINE-2
                   MOVE LpUpdateAddressLine2
                       TO WADDR-ADDR-LINE-2
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressLine3 NOT = WADDR-ADDR-LINE-3
                   MOVE LpUpdateAddressLine3
                       TO WADDR-ADDR-LINE-3
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressCity NOT = WADDR-CITY
                   MOVE LpUpdateAddressCity
                       TO WADDR-CITY
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressState NOT = WADDR-STATE
                   MOVE LpUpdateAddressState
                       TO WADDR-STATE
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressZipCode NOT = WADDR-ZIP
                   MOVE LpUpdateAddressZipCode
                       TO WADDR-ZIP
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressBoxNumber NOT = WADDR-BOX-NUMBER
                   MOVE LpUpdateAddressBoxNumber
                       TO WADDR-BOX-NUMBER
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressZipExtension NOT = WADDR-ZIP-EXTENSION
                   MOVE LpUpdateAddressZipExtension
                       TO WADDR-ZIP-EXTENSION
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressCountry NOT = WADDR-COUNTRY
                   MOVE LpUpdateAddressCountry
                       TO WADDR-COUNTRY
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressCounty NOT = WADDR-RESIDENT-COUNTY
                   MOVE LpUpdateAddressCounty
                       TO WADDR-RESIDENT-COUNTY
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressCountyCode NOT = WADDR-COUNTY-CODE
                   MOVE LpUpdateAddressCountyCode
                       TO WADDR-COUNTY-CODE
                   SET wsAddressChanged TO TRUE
               END-IF
               IF LpUpdateAddressCityCode NOT = WADDR-CITY-CODE
                   MOVE LpUpdateAddressCityCode
                       TO WADDR-CITY-CODE
                   SET wsAddressChanged TO TRUE
               END-IF
112612*        Address Code will only be input to adds.  On-line LifePRO
112612*        does not allow modification of Address Code in updates.  
112612*        Flag an error if user attempts to change Address Code . 
               IF LpUpdateAddressCode NOT = WNALK-ADDRESS-CODE
112612             MOVE 'Address Code may not be modified on an update'
112612                      TO LpErrorMessage
112612             MOVE 997 TO lsReturnCode
112612                         LpReturnCode
               END-IF
112612         IF LpUpdateCancelDate NOT = WNALK-CANCEL-DATE
112612             MOVE LpUpdateCancelDate
112612                  TO WNALK-CANCEL-DATE
112612             SET wsAddressChanged TO TRUE
112612         END-IF

112612         MOVE WNALK-EFFECTIVE-DATE
112612             TO WADDRBOX-ORIGINAL-EFF-DATE

112612         IF LpUpdateEffectiveDate NOT = WNALK-EFFECTIVE-DATE
112612             MOVE LpUpdateEffectiveDate
112612                  TO WNALK-EFFECTIVE-DATE
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateRecurringStartMonth
112612                    NOT = WNALK-RECURRING-START-MONTH
112612             MOVE LpUpdateRecurringStartMonth
112612                  TO WNALK-RECURRING-START-MONTH
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateRecurringStartDay
112612                    NOT = WNALK-RECURRING-START-DAY
112612             MOVE LpUpdateRecurringStartDay
112612                  TO WNALK-RECURRING-START-DAY
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateRecurringStopMonth
112612                    NOT = WNALK-RECURRING-STOP-MONTH
112612             MOVE LpUpdateRecurringStopMonth
112612                  TO WNALK-RECURRING-STOP-MONTH
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateRecurringStopDay
112612                    NOT = WNALK-RECURRING-STOP-DAY
112612             MOVE LpUpdateRecurringStopDay
112612                  TO WNALK-RECURRING-STOP-DAY
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateAlternateNameID
112612                    NOT = WNALK-ALTERNATE-NAME-ID
112612             MOVE LpUpdateAlternateNameID
112612                   TO WNALK-ALTERNATE-NAME-ID
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612         IF LpUpdateBadAddressInd
112612                   NOT = WNALK-BAD-ADDRESS-IND
112612             MOVE LpUpdateBadAddressInd
112612                   to WNALK-BAD-ADDRESS-IND
112612             SET wsAddressChanged TO TRUE
112612         END-IF
112612
112612         IF LpReturnCode = Zero
112612             PERFORM 1200-CONTINUE-UPDATE
112612         END-IF
112612
083004       ELSE
083004         MOVE 'Address must be read prior to update'
083004                         TO LpErrorMessage
083004         MOVE 999 TO lsReturnCode,
083004                     LpReturnCode
083004       END-IF.
112612*    CATCH WS-EXCEPTION
112612*        INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
112612*        MOVE 8008 TO lsReturnCode,
112612*                     LpReturnCode
112612*        MOVE 'Unexpected Abend in API - see Windows Event Log'
112612*            TO LpErrorMessage
112612*    END-TRY.

112612     IF LpReturnCode NOT = ZERO
112612         MOVE  WS-PRE-UPDATE-ADDR TO WADDR-DATA-RECORD
112612         MOVE WS-PRE-UPDATE-NALK TO WNALK-DATA-RECORD
112612     END-IF.

           CONTINUE.

      ******************************************************************

112612 1200-CONTINUE-UPDATE.
112612
112612
112612     TRY

           IF wsAddressChanged
041702         IF wsUpdateQueryFlag = "B"
041702             SET WSQLF-CONNECT TO TRUE
021709*             PERFORM 8001-CALL-PSQLFUNC
021709             CALL PSQLFUNC USING WGLOBAL
021709                                 WSQLF-PARMS
021709             IF WSQLF-RETURN-CODE NOT = ZERO
021709                 MOVE WSQLF-RETURN-CODE TO lsReturnCode,
021709                                           LpReturnCode
021709                 MOVE WSQLF-ERROR-MESSAGE TO LpErrorMessage
021709             END-IF
041702             IF lsReturnCode = ZERO
041702               SET WADBT-INSERT TO TRUE
      *                    MOVE 'N' TO WGLOB-FILES-READ
      *                    MOVE SPACES TO WFILE,
      *                                WGLOB-PFILEIOP-INIT-FLAG

092308               CALL PADDRBTC USING WGLOBAL
092308                                     WADBT-PARAMETERS
092308                                     WNALK-DATA-RECORD
092308                                     WADDR-DATA-RECORD
041702               IF WADBT-RETURN-CODE NOT = ZERO
041702                 SET WSQLF-ROLLBACK TO TRUE
021709*                 PERFORM 8001-CALL-PSQLFUNC
021709                 CALL PSQLFUNC USING WGLOBAL
021709                                     WSQLF-PARMS
041702                 MOVE WADBT-RETURN-CODE TO lsReturnCode,
                                                 LpReturnCode
041702                 MOVE WADBT-ERROR-MESSAGE
041702                     TO LpErrorMessage
041702               ELSE
041702                 SET WSQLF-COMMIT TO TRUE
021709*                 PERFORM 8001-CALL-PSQLFUNC
021709                 CALL PSQLFUNC USING WGLOBAL
021709                                     WSQLF-PARMS
021709                 IF WSQLF-RETURN-CODE NOT = ZERO
021709                   MOVE WSQLF-RETURN-CODE TO lsReturnCode,
021709                                             LpReturnCode
021709                   MOVE WSQLF-ERROR-MESSAGE TO LpErrorMessage
021709                 END-IF
041702               END-IF
041702               SET WSQLF-DISCONNECT TO TRUE
021709*               PERFORM 8001-CALL-PSQLFUNC
021709               CALL PSQLFUNC USING WGLOBAL
021709                                   WSQLF-PARMS
021709               IF WSQLF-RETURN-CODE NOT = ZERO
021709                   MOVE WSQLF-RETURN-CODE TO lsReturnCode,
021709                                             LpReturnCode
021709                   MOVE WSQLF-ERROR-MESSAGE TO LpErrorMessage
021709               END-IF
041702             END-IF
041702         ELSE
                   SET WADDRBOX-UPDATE TO TRUE

112612*            MOVE WNALK-EFFECTIVE-DATE
112612*                TO WADDRBOX-ORIGINAL-EFF-DATE
                   SET WADDRBOX-OTHERS-ATTACHED-OK TO TRUE

092308             CALL PADDRBOX USING WGLOBAL
092308                                 WADDRBOX-PARAMETERS
092308                                 WNALK-DATA-RECORD
092308                                 WADDR-DATA-RECORD

                   MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
                                                LpReturnCode
                   MOVE WADDRBOX-RETURN-MESSAGE
                       TO LpErrorMessage
               END-IF
           ELSE
112612         MOVE 'No Changes made.  Update canceled '
112612                      TO LpErrorMessage
112612         MOVE 998 TO lsReturnCode
112612                     LpReturnCode

           END-IF

112612     CATCH WS-EXCEPTION
112612         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
112612         MOVE 8008 TO lsReturnCode,
112612                      LpReturnCode
112612         MOVE 'Unexpected Abend in API - see Windows Event Log'
112612             TO LpErrorMessage
112612     END-TRY.

           CONTINUE.


       1500-ADDRESS-ADD.

112612*    Similar to address update, but no pre-read is required, 
112612*    and all WNALK and WADDR fields must be set.  

112612     INITIALIZE WNALK-DATA-RECORD
112612     INITIALIZE WADDR-DATA-RECORD.
112612
112612     TRY
112612         MOVE wsNameID TO WNALK-NAME-ID
112612         MOVE LpUpdatePhoneNumber
112612                 TO WNALK-PHONE-NUMBER
112612         MOVE LpUpdateFaxNumber
112612                 TO WNALK-FAX-NUMBER
112612         MOVE LpUpdateCellPhoneNumber
112612                   TO WNALK-CELL-NUMBER
112612         MOVE LpUpdateAddressType
112612                 TO WNALK-ADDRESS-TYPE
112612         MOVE LpUpdateAddressLine1
112612                 TO WADDR-ADDR-LINE-1
112612         MOVE LpUpdateAddressLine2
112612                 TO WADDR-ADDR-LINE-2
112612         MOVE LpUpdateAddressLine3
112612                 TO WADDR-ADDR-LINE-3
112612         MOVE LpUpdateAddressCity
112612                 TO WADDR-CITY
112612         MOVE LpUpdateAddressState
112612                 TO WADDR-STATE
112612         MOVE LpUpdateAddressZipCode
112612                 TO WADDR-ZIP
112612         MOVE LpUpdateAddressBoxNumber
112612                 TO WADDR-BOX-NUMBER
112612         MOVE LpUpdateAddressZipExtension
112612                 TO WADDR-ZIP-EXTENSION
112612         MOVE LpUpdateAddressCountry
112612                 TO WADDR-COUNTRY
112612         MOVE LpUpdateAddressCounty
112612                 TO WADDR-RESIDENT-COUNTY
112612         MOVE LpUpdateAddressCountyCode
112612                 TO WADDR-COUNTY-CODE
112612         MOVE LpUpdateAddressCityCode
112612                 TO WADDR-CITY-CODE

112612         MOVE LpUpdateAddressCode TO WNALK-ADDRESS-CODE
112612         MOVE LpUpdateCancelDate
112612                  TO WNALK-CANCEL-DATE
112612
011116         IF LpUpdateEffectiveDate NOT > 0
011116            SET WDATE-GET-CURRENT-DATE TO TRUE
011116            CALL PDATECON USING WDATE-PARMS
011116            IF WDATE-FUNCTION-SUCCESSFUL
011116               MOVE WDATE-STR-GREG-DATE TO WNALK-EFFECTIVE-DATE
011116            END-IF
011116         ELSE
011116            MOVE LpUpdateEffectiveDate
011116                 TO WNALK-EFFECTIVE-DATE
011116         END-IF
011116
112612         MOVE LpUpdateRecurringStartMonth
112612                  TO WNALK-RECURRING-START-MONTH
112612         MOVE LpUpdateRecurringStartDay
112612                  TO WNALK-RECURRING-START-DAY
112612
112612         MOVE LpUpdateRecurringStopMonth
112612                  TO WNALK-RECURRING-STOP-MONTH
112612         MOVE LpUpdateRecurringStopDay
112612                  TO WNALK-RECURRING-STOP-DAY
112612         MOVE LpUpdateAlternateNameID
112612                  TO WNALK-ALTERNATE-NAME-ID
112612         MOVE LpUpdateBadAddressInd
112612                  TO WNALK-BAD-ADDRESS-IND
112612
112612         SET WADDRBOX-ADD TO TRUE
112612
112612         SET WADDRBOX-OTHERS-ATTACHED-OK TO TRUE
112612
112612         CALL PADDRBOX USING WGLOBAL
112612                             WADDRBOX-PARAMETERS
112612                             WNALK-DATA-RECORD
112612                             WADDR-DATA-RECORD
112612
112612         MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
112612                                      LpReturnCode
112612         MOVE WADDRBOX-RETURN-MESSAGE
112612                 TO LpErrorMessage
112612
112612     CATCH WS-EXCEPTION
112612         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
112612         MOVE 8008 TO lsReturnCode,
112612                      LpReturnCode
112612         MOVE 'Unexpected Abend in API - see Windows Event Log'
112612             TO LpErrorMessage
112612     END-TRY.
112612
112612     CONTINUE.

      ******************************************************************
       2000-ADDRESS-QUERY.

112612*    In the case of a "Next" hitting EOF, we will restore 
112612*    the last Lp values retrieved and return them, so the user 
112612*    doesn't lose the values of the last record read.  
112612     MOVE LpOutputGroup TO LpSaveOutputGroup.

           MOVE ZERO TO LpAddressID.
           MOVE ZERO TO LpCancelDate.
           MOVE ZERO TO LpRecurringStartMonth.
           MOVE ZERO TO LpRecurringStartDay.
           MOVE ZERO TO LpRecurringStopMonth.
           MOVE ZERO TO LpRecurringStopDay.
           MOVE ZERO TO LpAlternateNameID.
           MOVE ZERO TO LpPhoneNumber.
           MOVE ZERO TO LpFaxNumber.
022312     MOVE ZERO TO LpCellPhoneNumber.
           MOVE SPACES TO LpAddressType.
010510     MOVE SPACES TO LpAddressCode.
           MOVE SPACES TO LpAddressLine1.
           MOVE SPACES TO LpAddressLine2.
           MOVE SPACES TO LpAddressLine3.
           MOVE SPACES TO LpAddressCity.
           MOVE SPACES TO LpAddressState.
           MOVE SPACES TO LpAddressZipCode.
           MOVE SPACES TO LpAddressBoxNumber.
           MOVE SPACES TO LpAddressZipExtension.
           MOVE SPACES TO LpAddressCountry.
           MOVE SPACES TO LpAddressCounty.
           MOVE SPACES TO LpAddressCountyCode.
           MOVE SPACES TO LpAddressCityCode.
           MOVE SPACES TO LpFormatAddressLine1.
           MOVE SPACES TO LpFormatAddressLine2.
           MOVE SPACES TO LpFormatAddressLine3.
           MOVE SPACES TO LpFormatAddressLine4.
112612     MOVE SPACES TO LpBadAddressInd.

102813*    This new function required to restore "state" on web service calls, 
102813*    where the O* module working storage is not retained between calls.  
102813     IF wsUpdateQueryFlag = 'E'
102813         INITIALIZE WNALK-DATA-RECORD
102813         MOVE wsNameID to WNALK-NAME-ID
102813         MOVE wsAddressID to WNALK-ADDRESS-ID
102813         MOVE wsEffectiveDate TO WNALK-EFFECTIVE-DATE
102813         MOVE wsAddressCode TO WNALK-ADDRESS-CODE
102813         MOVE wsIdentifyingNumber TO WNALK-IDENTIFYING-NUMBER
102813         MOVE WBTRV-GET-EQUAL TO WNALK-FUNCTION
102813     ELSE
121009         IF wsUpdateQueryFlag = 'Q'
121009             MOVE SPACES TO WNALK-DATA-RECORD
                   MOVE wsNameID TO WNALK-NAME-ID
121009             MOVE ZEROES TO WNALK-ADDRESS-ID
121009*     MOVE LpAddressID TO WNALK-ADDRESS-CODE

121009*     SET WDATE-GET-CURRENT-DATE TO TRUE
121009*     CALL PDATECON USING WDATE-PARMS
121009*     IF WDATE-FUNCTION-SUCCESSFUL
121009*         MOVE WDATE-STR-GREG-DATE TO WNALK-EFFECTIVE-DATE
121009*     ELSE
011116          MOVE 99999999 TO WNALK-EFFECTIVE-DATE
121009*     END-IF

011116*            MOVE ZEROES TO WNALK-EFFECTIVE-DATE
                   MOVE SPACES TO WNALK-IDENTIFYING-NUMBER
011116*            MOVE WBTRV-GET-GREATER-EQUAL TO WNALK-FUNCTION
011116             MOVE WBTRV-GET-LESS-EQUAL    TO WNALK-FUNCTION
121009         ELSE
121009             MOVE WS-HOLD-WNALK-RECORD TO WNALK-DATA-RECORD
011116*            MOVE WBTRV-GET-GREATER TO WNALK-FUNCTION
011116             MOVE WBTRV-GET-LESS TO WNALK-FUNCTION
121009         END-IF
102813     END-IF.

121009     TRY
121009        MOVE WFILE-NALK-NUM TO DATA-FILE-NUMBER
121009        MOVE WNALK-DATA-RECORD TO DATA-AREA
121009        MOVE ZERO TO WNALK-KEY-NUMBER
121009        CALL PFILEBTV USING WGLOBAL
121009                            WNALK-CALL-PARAMETERS
121009                            WBTRIEVE
121009        MOVE DATA-AREA TO WNALK-DATA-RECORD
121009        IF WBTRV-SUCCESSFUL
121009          IF WNALK-NAME-ID = wsNameID
121009            MOVE WNALK-DATA-RECORD TO WS-HOLD-WNALK-RECORD
121009*     SET WADDRBOX-READ-MATCH-WITH-CODE TO TRUE.
      *    MOVE 'N' TO WGLOB-FILES-READ
      *    MOVE SPACES TO WFILE,
      *                   WGLOB-PFILEIOP-INIT-FLAG
121009            SET WADDRBOX-READ TO TRUE
121009*     TRY
092308            CALL PADDRBOX USING WGLOBAL
092308                                WADDRBOX-PARAMETERS
092308                                WNALK-DATA-RECORD
092308                                WADDR-DATA-RECORD
                  MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
                                               LpReturnCode
                  MOVE WADDRBOX-RETURN-MESSAGE TO LpErrorMessage
                  IF WADDRBOX-SUCCESSFUL
                    SET wsAddressWasRead TO TRUE
                    MOVE WNALK-ADDRESS-ID TO LpAddressID
                    MOVE WNALK-CANCEL-DATE TO LpCancelDate
112612                                        LpUpdateCancelDate
012805              MOVE WNALK-EFFECTIVE-DATE TO LpEffectiveDate
112612                                           LpUpdateEffectiveDate
                    MOVE WNALK-RECURRING-START-MONTH
112612                               TO LpRecurringStartMonth
112612                                  LpUpdateRecurringStartMonth
                    MOVE WNALK-RECURRING-START-DAY
                                     TO LpRecurringStartDay
112612                                  LpUpdateRecurringStartDay
                    MOVE WNALK-RECURRING-STOP-MONTH
                                     TO LpRecurringStopMonth
112612                                  LpUpdateRecurringStopMonth
                    MOVE WNALK-RECURRING-STOP-DAY
                                     TO LpRecurringStopDay
112612                                  LpUpdateRecurringStopDay

                    MOVE WNALK-ALTERNATE-NAME-ID
                                     TO LpAlternateNameID
112612                                  LpUpdateAlternateNameID
112612              MOVE WNALK-BAD-ADDRESS-IND
112612                               TO LpBadAddressInd
112612                                  LpUpdateBadAddressInd

092308              IF WNALK-PHONE-NUMBER IS NUMERIC
                       MOVE WNALK-PHONE-NUMBER
                                     TO LpPhoneNumber,
083004                                  LpUpdatePhoneNumber
092308              ELSE
092308                 MOVE ZEROS TO LpPhoneNumber,
092308                               LpUpdatePhoneNumber
092308              END-IF
092308              IF WNALK-PHONE-NUMBER IS NUMERIC
                       MOVE WNALK-FAX-NUMBER TO LpFaxNumber,
083004                                          LpUpdateFaxNumber
092308              ELSE
092308                 MOVE ZEROS TO LpFaxNumber,
092308                               LpUpdateFaxNumber
092308              END-IF
022312              IF WNALK-CELL-NUMBER IS NUMERIC
022312                       MOVE WNALK-CELL-NUMBER TO LpCellPhoneNumber,
022312                                          LpUpdateCellPhoneNumber
022312              ELSE
022312                 MOVE ZEROS TO LpCellPhoneNumber,
022312                               LpUpdateCellPhoneNumber
022312              END-IF
010510              IF WNALK-ADDRESS-TYPE = LOW-VALUES
010510              OR WNALK-ADDRESS-TYPE = HIGH-VALUES
010510                  MOVE SPACES TO LpAddressType
010510              ELSE
                        MOVE WNALK-ADDRESS-TYPE TO LpAddressType
010510              END-IF
112612              MOVE LpAddressType to LpUpdateAddressType
010510              IF WNALK-ADDRESS-CODE = LOW-VALUES
010510              OR WNALK-ADDRESS-CODE = HIGH-VALUES
010510                  MOVE SPACES TO LpAddressCode
010510              ELSE
010510                  MOVE WNALK-ADDRESS-CODE TO LpAddressCode
010510              END-IF
112612              Move LpAddressCode to LpUpdateAddressCode
                    MOVE WADDR-ADDR-LINE-1 TO LpAddressLine1,
083004                                        LpUpdateAddressLine1
                    MOVE WADDR-ADDR-LINE-2 TO LpAddressLine2,
083004                                        LpUpdateAddressLine2
                    MOVE WADDR-ADDR-LINE-3 TO LpAddressLine3,
083004                                        LpUpdateAddressLine3
                    MOVE WADDR-CITY TO LpAddressCity,
083004                                 LpUpdateAddressCity
                    MOVE WADDR-STATE TO LpAddressState,
083004                                  LpUpdateAddressState
                    MOVE WADDR-ZIP TO LpAddressZipCode,
083004                                LpUpdateAddressZipCode
                    MOVE WADDR-BOX-NUMBER TO LpAddressBoxNumber,
083004                                       LpUpdateAddressBoxNumber
                    MOVE WADDR-ZIP-EXTENSION
                                       TO LpAddressZipExtension,
083004                                    LpUpdateAddressZipExtension
                    MOVE WADDR-COUNTRY TO LpAddressCountry,
083004                                    LpUpdateAddressCountry
                    MOVE WADDR-RESIDENT-COUNTY
                                       TO LpAddressCounty,
083004                                    LpUpdateAddressCounty
                    MOVE WADDR-COUNTY-CODE
                                       TO LpAddressCountyCode,
083004                                    LpUpdateAddressCountyCode
                    MOVE WADDR-CITY-CODE TO LpAddressCityCode,
083004                                      LpUpdateAddressCityCode
                    MOVE WADDR-ADDR-LINE-1 TO WNADR-ADDR-LINE-1
                    MOVE WADDR-ADDR-LINE-2 TO WNADR-ADDR-LINE-2
                    MOVE WADDR-ADDR-LINE-3 TO WNADR-ADDR-LINE-3
                    MOVE WADDR-CITY TO WNADR-CITY
                    MOVE WADDR-STATE TO WNADR-STATE
                    MOVE WADDR-ZIP-CODE TO WNADR-ZIP-CODE
                    MOVE '5' TO WS-PNADRBOX-OPTION
      *        MOVE 'N' TO WGLOB-FILES-READ
      *        MOVE SPACES TO WFILE,
      *                       WGLOB-PFILEIOP-INIT-FLAG
092308              CALL PNADRBOX USING WGLOBAL
092308                                  GLOBAL-PARAMETERS
092308                                  WNADR-DATA-RECORD
092308                                  WS-PNADRBOX-OPTION
                    IF LINK-RETURN-STATUS = ZERO
                      MOVE WNADR-ADDR-LINE-1 TO LpFormatAddressLine1
                      MOVE WNADR-ADDR-LINE-2 TO LpFormatAddressLine2
                      MOVE WNADR-ADDR-LINE-3 TO LpFormatAddressLine3
                      MOVE WNADR-ADDR-LINE-4 TO LpFormatAddressLine4
                    END-IF
121009            END-IF
121009          ELSE


121009            MOVE 9 TO lsReturnCode,
121009                      LpReturnCode
121009            IF wsUpdateQueryFlag = "N"
121009              MOVE 'No more addresses for this Name ID'
121009                  TO LpErrorMessage
112612              MOVE WS-HOLD-WNALK-RECORD
112612                            TO WNALK-DATA-RECORD
112612              MOVE LpSaveOutputGroup TO LpOutputGroup
121009            ELSE
121009              MOVE 7 TO lsReturnCode,
121009                        LpReturnCode
121009              MOVE 'No addresses found for this Name ID'
121009                  TO LpErrorMessage
121009            END-IF
121009          END-IF
121009        ELSE
121009          MOVE 8 TO lsReturnCode,
121009                    LpReturnCode
062210*          MOVE 'Name ID not fuond' TO LpErrorMessage
062210          MOVE 'Name ID not found' TO LpErrorMessage
121009        END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           CONTINUE.
021709******************************************************************
021709* 8001-CALL-PSQLFUNC.
021709*
021709*     MOVE wsDataSource TO WSQLF-DATA-SOURCE.
021709*     MOVE wsUserID TO WSQLF-USERID.
021709*     MOVE wsPassword TO WSQLF-PASSWORD.
021709*
021709*         CALL PSQLFUNC USING WGLOBAL
021709*                             WSQLF-PARMS
021709*         IF WSQLF-RETURN-CODE NOT = ZERO
021709*             MOVE WSQLF-RETURN-CODE TO lsReturnCode,
021709*                                   LpReturnCode
021709*             MOVE WSQLF-ERROR-MESSAGE TO LpErrorMessage
021709*         END-IF
021709*
021709*     CONTINUE.
      ******************************************************************
       END METHOD RunAddressFunction.
      ******************************************************************
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. GetAddress.
011116******************************************************************
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116
011116
011116     COPY WDATECPY.
011116     COPY WNADRCPY.
011116     COPY WPGLBCPY.
011116     COPY WADBTCPY.
011116     COPY WSQLFCPY.
011116
011116 01  WS-PNADRBOX-OPTION          PIC X(01).
011116
011116 01  WS-IDENTIFYING-NUMBER.
011116     05 wsRelaCompanyCode        PIC X(02).
011116     05 wsRelaPolicyNumber       PIC X(12).
011116
011116 01 wsRelaFoundFlag         PIC X(01).
011116     88  wsRelaFound                          VALUE 'Y'.
011116     88  wsRelaNotFound                       VALUE 'N'.
011116
011116 01 wsAddrFoundFlag              PIC X(01).
011116    88  wsAddressFound                        VALUE 'Y'.
011116    88  wsAddressNotFound                     VALUE 'N'.
011116
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsReturnCode                PIC S9(09) COMP-5.
011116
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsReturnCode.
011116******************************************************************
011116
011116     MOVE ZERO TO lsReturnCode,
011116                  LpReturnCode
011116     MOVE SPACES TO LpErrorMessage
011116                    wsAddrFoundFlag
011116*    MOVE ZEROS  TO wsNameId
011116
012716     MOVE wsUpdateQueryFlag TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateQueryFlag
012716     MOVE wsUpdateIndicator TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateIndicator
012716     MOVE wsInAddressCode TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressCode
012716     MOVE wsInAddressType    TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressType
012716
011116     IF  wsCompanyCode > ' '
011116     AND wsPolicyNumber > ' '
011116     AND wsRelateCode > ' '
012616         MOVE wsPolicyNumber TO WFUNC-INPUT-STRING
012616         SET  WFUNC-UPPER-CASE           TO TRUE
012616         CALL POPFUNCN USING WGLOBAL
012616         MOVE WFUNC-INPUT-STRING TO wsPolicyNumber
011116         IF wsUpdateQueryFlag = 'Q' OR
011116            wsUpdateQueryFlag = 'N' OR
012016            wsUpdateQueryFlag = 'E' OR
012016            wsUpdateQueryFlag = 'M' OR
012116            wsUpdateQueryFlag = 'S'
011116            PERFORM 1500-LOOKUP-NAME-ADDRESS
011116            PERFORM 2000-ADDRESS-QUERY
011116         ELSE
011116            IF wsUpdateIndicator = 'P'
011116               IF wsUpdateQueryFlag = "A"
020916               OR NALK-WILL-INSERT
020916                  MOVE ZEROS TO WNALK-ADDRESS-ID
011116                  INVOKE Self 'AddAddressForPolicy'
011116               ELSE
011116                  IF wsUpdateQueryFlag = "U"
011116                     INVOKE Self 'UpdateAddressForPolicy'
011116                  END-IF
011116               END-IF
011116            ELSE
020916               MOVE wsUpdateQueryFlag TO WS-HOLD-QUERY-FLAG
011116               PERFORM 1500-LOOKUP-NAME-ADDRESS
011116               IF wsRelaFound
011116                  INVOKE Self 'RunAddressFunction'
020916                  MOVE WS-HOLD-QUERY-FLAG TO wsUpdateQueryFlag
011116               END-IF
011116            END-IF
011116         END-IF
011116     ELSE
011116         MOVE 'Input Parameters Incorrect'
011116            TO LpErrorMessage
011116         MOVE 9   TO lsReturnCode
011116                     LpReturnCode
011116     END-IF
011116     EXIT METHOD.
011116
011116******************************************************************
011116 1500-LOOKUP-NAME-ADDRESS.
011116
011116     INITIALIZE wsRelaFoundFlag
012716
012716     IF  wsCompanyCode > ' '
012716         MOVE wsCompanyCode          TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsCompanyCode
012716     END-IF
012716     IF  wsPolicyNumber > ' '
012716         MOVE wsPolicyNumber         TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsPolicyNumber
012716     END-IF
012716     IF  wsRelateCode > ' '
012716         MOVE wsRelateCode           TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsRelateCode
012716     END-IF
012716
011116     MOVE SPACES TO WRELA-DATA-RECORD
011116     MOVE wsCompanyCode   TO WRELA-COMPANY-CODE
011116     MOVE wsPolicyNumber  TO WRELA-POLICY-NUMBER
011116     MOVE wsRelateCode to WRELA-RELATE-CODE
011116     PERFORM UNTIL WRELA-RETURN-NOT-OK OR
011116                   wsRelaFound         OR
011116                   wsRelaNotFound
011116       MOVE WBTRV-GET-GREATER
011116                   TO WRELA-FUNCTION
011116       MOVE 1                 TO WRELA-KEY-NUMBER
011116       MOVE WFILE-RELA-NUM    TO DATA-FILE-NUMBER
011116       MOVE WRELA-DATA-RECORD TO DATA-AREA
011116       CALL PFILEBTV USING       WGLOBAL
011116                                 WRELA-CALL-PARAMETERS
011116                                 WBTRIEVE
011116       MOVE DATA-AREA         TO WRELA-DATA-RECORD
011116       IF WRELA-RETURN-CODE = ZEROS
011116          IF WRELA-POLICY-NUMBER = wsPolicyNumber
011116             IF WRELA-RELATE-CODE = wsRelateCode
011116                MOVE WRELA-NAME-ID TO wsNameId
011116                                      LpUpdateNameId
011116                MOVE 'Y' TO wsRelaFoundFlag
011116             ELSE
011116                CONTINUE
011116*               MOVE ZEROS TO wsNameId
011116*                             LpUpdateNameId 
011116*               MOVE 'N' TO wsRelaFoundFlag
011116             END-IF
011116          ELSE
011116             MOVE 'N' TO wsRelaFoundFlag
011116*            MOVE ZEROS TO wsNameId
011116*                          LpUpdateNameId 
011116          END-IF
011116       END-IF
011116    END-PERFORM
011116
011116    IF WRELA-RETURN-NOT-OK OR wsRelaNotFound
011116       MOVE 'Relationship for Policy Not Found'
011116            TO LpErrorMessage
011116         MOVE 9   TO lsReturnCode
011116                     LpReturnCode
011116         MOVE ZEROS TO wsNameId
011116                       LpUpdateNameId
011116    END-IF
011116
011116    CONTINUE.
011116
011116******************************************************************
011116 2000-ADDRESS-QUERY.
011116
011116*    In the case of a "Next" hitting EOF, we will restore 
011116*    the last Lp values retrieved and return them, so the user 
011116*    doesn't lose the values of the last record read.  
011116     MOVE LpOutputGroup TO LpSaveOutputGroup.
011116
011116     MOVE ZERO TO LpAddressID.
011116     MOVE ZERO TO LpCancelDate.
011116     MOVE ZERO TO LpRecurringStartMonth.
011116     MOVE ZERO TO LpRecurringStartDay.
011116     MOVE ZERO TO LpRecurringStopMonth.
011116     MOVE ZERO TO LpRecurringStopDay.
011116     MOVE ZERO TO LpAlternateNameID.
011116     MOVE ZERO TO LpPhoneNumber.
011116     MOVE ZERO TO LpFaxNumber.
011116     MOVE ZERO TO LpCellPhoneNumber.
011116     MOVE SPACES TO LpAddressType.
011116     MOVE SPACES TO LpAddressCode.
011116     MOVE SPACES TO LpAddressLine1.
011116     MOVE SPACES TO LpAddressLine2.
011116     MOVE SPACES TO LpAddressLine3.
011116     MOVE SPACES TO LpAddressCity.
011116     MOVE SPACES TO LpAddressState.
011116     MOVE SPACES TO LpAddressZipCode.
011116     MOVE SPACES TO LpAddressBoxNumber.
011116     MOVE SPACES TO LpAddressZipExtension.
011116     MOVE SPACES TO LpAddressCountry.
011116     MOVE SPACES TO LpAddressCounty.
011116     MOVE SPACES TO LpAddressCountyCode.
011116     MOVE SPACES TO LpAddressCityCode.
011116     MOVE SPACES TO LpFormatAddressLine1.
011116     MOVE SPACES TO LpFormatAddressLine2.
011116     MOVE SPACES TO LpFormatAddressLine3.
011116     MOVE SPACES TO LpFormatAddressLine4.
011116     MOVE SPACES TO LpBadAddressInd.
011116
011116*    This new function required to restore "state" on web service calls, 
011116*    where the O* module working storage is not retained between calls.  
011116     IF wsUpdateQueryFlag = 'E'
011116         INITIALIZE WNALK-DATA-RECORD
011116         MOVE wsNameID to WNALK-NAME-ID
011116         MOVE wsAddressID to WNALK-ADDRESS-ID
011116         MOVE wsEffectiveDate TO WNALK-EFFECTIVE-DATE
011116         MOVE wsAddressCode TO WNALK-ADDRESS-CODE
011116         MOVE wsIdentifyingNumber TO WNALK-IDENTIFYING-NUMBER
011116         MOVE WBTRV-GET-EQUAL TO WNALK-FUNCTION
011116     ELSE
011116         IF wsUpdateQueryFlag = 'Q'
012016         OR wsUpdateQueryFlag = 'U'
012016         OR wsUpdateQueryFlag = 'M'
012116         OR wsUpdateQueryFlag = 'S'
012116            IF (wsUpdateQueryFlag = 'Q'
012116            OR  wsUpdateQueryFlag = 'S')
012116            AND wsInAddressCode = ' '
011116                MOVE SPACES TO WNALK-DATA-RECORD
011116                MOVE wsNameID TO WNALK-NAME-ID
011116                MOVE ZEROS    TO WNALK-ADDRESS-ID
011116                MOVE 99999999 TO WNALK-EFFECTIVE-DATE
011116                MOVE WBTRV-GET-LESS-EQUAL TO WNALK-FUNCTION
012116            ELSE
012116                IF wsUpdateIndicator = 'P'
012116                   MOVE SPACES TO WNALK-DATA-RECORD
012116                   MOVE wsNameID TO WNALK-NAME-ID
012116                   MOVE ZEROS    TO WNALK-ADDRESS-ID
012116                   IF ( wsUpdateQueryFlag = 'M'
012116                   OR   wsUpdateQueryFlag = 'S')
012116                   AND wsEffectiveDate > 0
012116                       MOVE wsEffectiveDate TO
012116                            WNALK-EFFECTIVE-DATE
012116                       MOVE 99999999 TO WNALK-ADDRESS-ID
012116                   ELSE
012116                       MOVE 99999999 TO WNALK-EFFECTIVE-DATE
012116                   END-IF
012116                   MOVE wsPolicyNumber to WNALK-POLICY-NUMBER
012116                   MOVE wsCompanyCode  TO WNALK-COMPANY-CODE
012116                   IF ( wsInAddressCode = ' ' OR 'PRI' )
012116                      MOVE SPACES TO WNALK-ADDRESS-CODE
012116                   ELSE
012116                      MOVE wsInAddressCode to WNALK-ADDRESS-CODE
012116                   END-IF
012116                   MOVE WBTRV-GET-LESS-EQUAL TO WNALK-FUNCTION
012116                ELSE
012116                   MOVE SPACES TO WNALK-DATA-RECORD
012116                   MOVE wsNameID TO WNALK-NAME-ID
011116                   MOVE ZEROS    TO WNALK-ADDRESS-ID
012116                   IF ( wsUpdateQueryFlag = 'M'
012116                   OR   wsUpdateQueryFlag = 'S')
012116                   AND wsEffectiveDate > 0
012116                       MOVE wsEffectiveDate TO
012116                            WNALK-EFFECTIVE-DATE
012116                       MOVE 99999999 TO WNALK-ADDRESS-ID
012116                   ELSE
012116                       MOVE 99999999 TO WNALK-EFFECTIVE-DATE
012116                   END-IF
012116                   IF ( wsInAddressCode = ' ' OR 'PRI' )
012116                      MOVE SPACES TO WNALK-ADDRESS-CODE
012116                   ELSE
012116                      MOVE wsInAddressCode to WNALK-ADDRESS-CODE
012116                   END-IF
012116                   MOVE WBTRV-GET-LESS-EQUAL TO WNALK-FUNCTION
012116             END-IF
011116         ELSE
011116            MOVE WS-HOLD-WNALK-RECORD TO WNALK-DATA-RECORD
011116            MOVE WBTRV-GET-LESS    TO WNALK-FUNCTION
011116         END-IF
011116     END-IF.
011116
011116     MOVE WFILE-NALK-NUM TO DATA-FILE-NUMBER
011116     MOVE WNALK-DATA-RECORD TO DATA-AREA
011116     MOVE ZERO TO WNALK-KEY-NUMBER
011116
011116     PERFORM 2001-FIND-ADDRESS UNTIL
011116             wsAddressFound
011116          OR wsAddressNotFound
011116          OR LpReturnCode > 0
011116
011116     CONTINUE.
011116
011116***************************************************************
011116 2001-FIND-ADDRESS.
011116
011116     TRY
011116        CALL PFILEBTV USING WGLOBAL
011116                            WNALK-CALL-PARAMETERS
011116                            WBTRIEVE
011116        MOVE DATA-AREA TO WNALK-DATA-RECORD
011116        IF WBTRV-SUCCESSFUL
011116          IF WNALK-NAME-ID = wsNameID
011116           IF  (WNALK-ADDRESS-CODE = wsInAddressCode
011116           AND  WNALK-ADDRESS-TYPE = wsInAddressType)
011116           OR ( wsInAddressCode NOT > " "
011116           AND  wsInAddressType NOT > " ")
011116           OR ( wsInAddressCode NOT > " "
011116           AND  wsInAddressType = WNALK-ADDRESS-TYPE)
011116           OR ( wsInAddressCode > " "
011116           AND  wsInAddressCode = WNALK-ADDRESS-CODE)
012116           OR ( wsInAddressCode = 'PRI'
012116           AND  WNALK-ADDRESS-CODE = SPACES)
012116            IF ( wsUpdateIndicator = 'R'
012116            AND  WNALK-IDENTIFYING-NUMBER NOT = ' '
012116            AND wsInAddressCode > ' ' )
012116            OR ( wsUpdateIndicator = 'P'
012116            AND  WNALK-IDENTIFYING-NUMBER = ' '
012116            AND  wsInAddressCode > ' '
012116            AND  wsInAddressCode NOT = 'PRI')
012116                 MOVE WBTRV-GET-LESS TO WNALK-FUNCTION
012116            ELSE
011116             MOVE WNALK-DATA-RECORD TO WS-HOLD-WNALK-RECORD
011116             SET WADDRBOX-READ TO TRUE
011116             CALL PADDRBOX USING WGLOBAL
011116                                 WADDRBOX-PARAMETERS
011116                                 WNALK-DATA-RECORD
011116                                 WADDR-DATA-RECORD
011116             MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
011116                                          LpReturnCode
011116             MOVE WADDRBOX-RETURN-MESSAGE TO LpErrorMessage
011116             IF WADDRBOX-SUCCESSFUL
020916               IF wsUpdateIndicator = 'P'
020916                  IF  WNALK-COMPANY-CODE  = wsCompanyCode
020916                  AND WNALK-POLICY-NUMBER = wsPolicyNumber
020916                      SET NALK-WILL-UPDATE TO TRUE
020916                  ELSE
020916                      SET NALK-WILL-INSERT TO TRUE
020916                  END-IF
020916               END-IF
011116               SET wsAddressWasRead TO TRUE
011116               SET wsAddressFound   TO TRUE
011116               MOVE WNALK-ADDRESS-ID TO LpAddressID
011116               MOVE WNALK-CANCEL-DATE TO LpCancelDate
011116                                         LpUpdateCancelDate
011116               MOVE WNALK-EFFECTIVE-DATE TO LpEffectiveDate
011116                                            LpUpdateEffectiveDate
011116               MOVE WNALK-RECURRING-START-MONTH
011116                                TO LpRecurringStartMonth
011116                                   LpUpdateRecurringStartMonth
011116               MOVE WNALK-RECURRING-START-DAY
011116                                TO LpRecurringStartDay
011116                                   LpUpdateRecurringStartDay
011116               MOVE WNALK-RECURRING-STOP-MONTH
011116                                TO LpRecurringStopMonth
011116                                  LpUpdateRecurringStopMonth
011116               MOVE WNALK-RECURRING-STOP-DAY
011116                                TO LpRecurringStopDay
011116                                   LpUpdateRecurringStopDay
011116               MOVE WNALK-ALTERNATE-NAME-ID
011116                                TO LpAlternateNameID
011116                                   LpUpdateAlternateNameID
011116               MOVE WNALK-BAD-ADDRESS-IND
011116                                TO LpBadAddressInd
011116                                  LpUpdateBadAddressInd
011116               IF WNALK-PHONE-NUMBER IS NUMERIC
011116                  MOVE WNALK-PHONE-NUMBER TO LpPhoneNumber,
011116                                             LpUpdatePhoneNumber
011116               ELSE
011116                  MOVE ZEROS TO LpPhoneNumber,
121215                                LpUpdatePhoneNumber
011116               END-IF
011116               IF WNALK-PHONE-NUMBER IS NUMERIC
011116                  MOVE WNALK-FAX-NUMBER TO LpFaxNumber,
011116                                           LpUpdateFaxNumber
011116               ELSE
011116                  MOVE ZEROS TO LpFaxNumber,
011116                                LpUpdateFaxNumber
011116               END-IF
011116               IF WNALK-CELL-NUMBER IS NUMERIC
011116                  MOVE WNALK-CELL-NUMBER TO
011116                       LpCellPhoneNumber,
011116                       LpUpdateCellPhoneNumber
011116               ELSE
011116                  MOVE ZEROS TO LpCellPhoneNumber,
011116                                LpUpdateCellPhoneNumber
011116               END-IF
011116               IF WNALK-ADDRESS-TYPE = LOW-VALUES
011116               OR WNALK-ADDRESS-TYPE = HIGH-VALUES
011116                  MOVE SPACES TO LpAddressType
011116               ELSE
011116                  MOVE WNALK-ADDRESS-TYPE TO LpAddressType
011116               END-IF
011116               MOVE LpAddressType to LpUpdateAddressType
011116               IF WNALK-ADDRESS-CODE = LOW-VALUES
011116               OR WNALK-ADDRESS-CODE = HIGH-VALUES
011116                  MOVE SPACES TO LpAddressCode
011116               ELSE
011116                  MOVE WNALK-ADDRESS-CODE TO LpAddressCode
011116               END-IF
011116               Move LpAddressCode to LpUpdateAddressCode
011116               MOVE WADDR-ADDR-LINE-1 TO LpAddressLine1,
011116                                         LpUpdateAddressLine1
011116               MOVE WADDR-ADDR-LINE-2 TO LpAddressLine2,
011116                                         LpUpdateAddressLine2
011116               MOVE WADDR-ADDR-LINE-3 TO LpAddressLine3,
011116                                         LpUpdateAddressLine3
011116               MOVE WADDR-CITY TO LpAddressCity,
011116                                  LpUpdateAddressCity
011116               MOVE WADDR-STATE TO LpAddressState,
011116                                   LpUpdateAddressState
011116               MOVE WADDR-ZIP TO LpAddressZipCode,
011116                                 LpUpdateAddressZipCode
011116               MOVE WADDR-BOX-NUMBER TO LpAddressBoxNumber,
011116                                        LpUpdateAddressBoxNumber
011116               MOVE WADDR-ZIP-EXTENSION
011116                                 TO LpAddressZipExtension,
011116                                    LpUpdateAddressZipExtension
011116               MOVE WADDR-COUNTRY TO LpAddressCountry,
011116                                    LpUpdateAddressCountry
011116               MOVE WADDR-RESIDENT-COUNTY
011116                                 TO LpAddressCounty,
011116                                    LpUpdateAddressCounty
011116               MOVE WADDR-COUNTY-CODE
011116                                 TO LpAddressCountyCode,
011116                                    LpUpdateAddressCountyCode
011116               MOVE WADDR-CITY-CODE TO LpAddressCityCode,
011116                                       LpUpdateAddressCityCode
011116               MOVE WADDR-ADDR-LINE-1 TO WNADR-ADDR-LINE-1
011116               MOVE WADDR-ADDR-LINE-2 TO WNADR-ADDR-LINE-2
011116               MOVE WADDR-ADDR-LINE-3 TO WNADR-ADDR-LINE-3
011116               MOVE WADDR-CITY TO WNADR-CITY
011116               MOVE WADDR-STATE TO WNADR-STATE
011116               MOVE WADDR-ZIP-CODE TO WNADR-ZIP-CODE
011116               MOVE '5' TO WS-PNADRBOX-OPTION
011116               CALL PNADRBOX USING WGLOBAL
011116                                   GLOBAL-PARAMETERS
011116                                   WNADR-DATA-RECORD
011116                                   WS-PNADRBOX-OPTION
011116               IF LINK-RETURN-STATUS = ZERO
011116                  MOVE WNADR-ADDR-LINE-1 TO LpFormatAddressLine1
011116                  MOVE WNADR-ADDR-LINE-2 TO LpFormatAddressLine2
011116                  MOVE WNADR-ADDR-LINE-3 TO LpFormatAddressLine3
011116                  MOVE WNADR-ADDR-LINE-4 TO LpFormatAddressLine4
011116               END-IF
011116            END-IF
012116           END-IF
011116          ELSE
011116           MOVE WBTRV-GET-LESS TO WNALK-FUNCTION
011116          END-IF
011116         ELSE
011116            MOVE 9 TO lsReturnCode,
011116                      LpReturnCode
011116            SET wsAddressNotFound TO TRUE
011116            IF wsUpdateQueryFlag = "N"
011116              MOVE 'No more addresses for this Input Combination'
011116                  TO LpErrorMessage
112315              MOVE WS-HOLD-WNALK-RECORD
112315                            TO WNALK-DATA-RECORD
112315              MOVE LpSaveOutputGroup TO LpOutputGroup
011116            ELSE
011116              MOVE 7 TO lsReturnCode,
011116                        LpReturnCode
011116              MOVE 'No addresses found for this Input Combination'
011116                  TO LpErrorMessage
011116            END-IF
011116         END-IF
011116        ELSE
011116          SET wsAddressNotFound TO TRUE
011116          MOVE 8 TO lsReturnCode,
011116                    LpReturnCode
011116          MOVE 'Name ID not found' TO LpErrorMessage
011116        END-IF
011116     CATCH WS-EXCEPTION
011116         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
011116         MOVE 8008 TO lsReturnCode,
011116                      LpReturnCode
011116         MOVE 'Unexpected Abend in API - see Windows Event Log'
011116             TO LpErrorMessage
011116     END-TRY.
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 END METHOD GetAddress.
011116******************************************************************
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. UpdateAddressForPolicy.
011116******************************************************************
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116
011116
011116     COPY WDATECPY.
011116     COPY WNADRCPY.
011116     COPY WPGLBCPY.
011116     COPY WADBTCPY.
011116     COPY WSQLFCPY.
011116
011116 01  WS-PNADRBOX-OPTION          PIC X(01).
011116
011116 01 wsAddressChangedFlag         PIC X(01).
011116     88  wsAddressChanged                        VALUE 'Y'.
011116     88  wsAddressNotChanged                     VALUE 'N'.
011116
011116 01  WS-IDENTIFYING-NUMBER.
011116     05 wsRelaCompanyCode        PIC X(02).
011116     05 wsRelaPolicyNumber       PIC X(12).
011116
011116 01 wsRelaFoundFlag         PIC X(01).
011116     88  wsRelaFound                          VALUE 'Y'.
011116     88  wsRelaNotFound                       VALUE 'N'.
011116
011416
012116 01 WS-HOLD-QUERY-FUNCTION       PIC X(01).
012116
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116
011116 01  lsReturnCode                PIC S9(09) COMP-5.
011116
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsReturnCode.
011116******************************************************************
011116
011116     MOVE ZERO TO lsReturnCode,
123152                  LpReturnCode
011116     MOVE SPACES TO LpErrorMessage
011116
020916*    MOVE ZERO TO LpAddressID.
012016     MOVE ZERO TO LpCancelDate.
012016     MOVE ZERO TO LpRecurringStartMonth.
012016     MOVE ZERO TO LpRecurringStartDay.
012016     MOVE ZERO TO LpRecurringStopMonth.
012016     MOVE ZERO TO LpRecurringStopDay.
012016     MOVE ZERO TO LpAlternateNameID.
012016     MOVE ZERO TO LpPhoneNumber.
012016     MOVE ZERO TO LpFaxNumber.
012016     MOVE ZERO TO LpCellPhoneNumber.
012016     MOVE SPACES TO LpAddressType.
012016     MOVE SPACES TO LpAddressCode.
012016     MOVE SPACES TO LpAddressLine1.
012016     MOVE SPACES TO LpAddressLine2.
012016     MOVE SPACES TO LpAddressLine3.
012016     MOVE SPACES TO LpAddressCity.
012016     MOVE SPACES TO LpAddressState.
012016     MOVE SPACES TO LpAddressZipCode.
012016     MOVE SPACES TO LpAddressBoxNumber.
012016     MOVE SPACES TO LpAddressZipExtension.
012016     MOVE SPACES TO LpAddressCountry.
012016     MOVE SPACES TO LpAddressCounty.
012016     MOVE SPACES TO LpAddressCountyCode.
012016     MOVE SPACES TO LpAddressCityCode.
012016     MOVE SPACES TO LpFormatAddressLine1.
012016     MOVE SPACES TO LpFormatAddressLine2.
012016     MOVE SPACES TO LpFormatAddressLine3.
012016     MOVE SPACES TO LpFormatAddressLine4.
012016     MOVE SPACES TO LpBadAddressInd.
012016
012716     MOVE wsUpdateQueryFlag TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateQueryFlag
012716     MOVE wsUpdateIndicator TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateIndicator
012716     MOVE wsInAddressCode TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressCode
012716     MOVE wsInAddressType    TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressType
012716
012016     IF wsUpdateQueryFlag = 'M'
011116        PERFORM 1000-SAVE-WCF-UPDATE-FIELDS
012016        INVOKE Self "GetAddress"
012016        if LpReturnCode = Zeros
011116           PERFORM 1000-ADDRESS-UPDATE-FROM-WCF
011116           PERFORM 1200-CONTINUE-UPDATE
011116        END-IF
011116     ELSE
011116        IF wsUpdateQueryFlag = 'U'
011116           PERFORM 1000-ADDRESS-UPDATE
011116        END-IF
011116     END-IF
011116
011116     EXIT METHOD.
011116
011116******************************************************************
011116 1000-SAVE-WCF-UPDATE-FIELDS.
011116
011116     INITIALIZE WCF-LpOutputGroup.
011116
011116     MOVE LpUpdatePhoneNumber         TO
011116          WCF-LpPhoneNumber
011116     MOVE LpUpdateFaxNumber           TO
011116          WCF-LpFaxNumber
011116     MOVE LpUpdateCellPhoneNumber     TO
011116          WCF-LpCellPhoneNumber
011116     MOVE LpUpdateAddressType         TO
011116          WCF-LpAddressType
011116     MOVE LpUpdateAddressLine1        TO
011116          WCF-LpAddressLine1
011116     MOVE LpUpdateAddressLine2        TO
011116          WCF-LpAddressLine2
011116     MOVE LpUpdateAddressLine3        TO
011116          WCF-LpAddressLine3
011116     MOVE LpUpdateAddressCity         TO
011116          WCF-LpAddressCity
011116     MOVE LpUpdateAddressState        TO
011116          WCF-LpAddressState
011116     MOVE LpUpdateAddressZipCode      TO
011116          WCF-LpAddressZipCode
011116     MOVE LpUpdateAddressBoxNumber    TO
011116          WCF-LpAddressBoxNumber
011116     MOVE LpUpdateAddressZipExtension TO
011116          WCF-LpAddressZipExtension
011116     MOVE LpUpdateAddressCountry      TO
011116          WCF-LpAddressCountry
011116     MOVE LpUpdateAddressCounty       TO
011116          WCF-LpAddressCounty
011116     MOVE LpUpdateAddressCountyCode   TO
011116          WCF-LpAddressCountyCode
011116     MOVE LpUpdateAddressCityCode     TO
011116          WCF-LpAddressCityCode
011116     MOVE LpUpdateCancelDate          TO
011116          WCF-LpCancelDate
011116     MOVE LpUpdateEffectiveDate       TO
011116          WCF-LpEffectiveDate
011116     MOVE LpUpdateRecurringStartMonth TO
011116          WCF-LpRecurringStartMonth
011116     MOVE LpUpdateRecurringStartDay   TO
011116          WCF-LpRecurringStartDay
011116     MOVE LpUpdateRecurringStopMonth  TO
011116          WCF-LpRecurringStopMonth
011116     MOVE LpUpdateRecurringStopDay    TO
011116          WCF-LpRecurringStopDay
011116     MOVE LpUpdateAlternateNameID     TO
011116          WCF-LpAlternateNameID
011116     MOVE LpUpdateBadAddressInd       TO
011116          WCF-LpBadAddressInd
011116
012716     MOVE WCF-LpAddressType          TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressType
012716     MOVE WCF-LpAddressLine1         TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressLine1
012716     MOVE WCF-LpAddressLine2         TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressLine2
012716     MOVE WCF-LpAddressLine3         TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressLine3
012716     MOVE WCF-LpAddressCity          TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressCity
012716     MOVE WCF-LpAddressState         TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressState
012716     MOVE WCF-LpAddressZipCode       TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressZipCode
012716     MOVE LpAddressBoxNumber         TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO LpAddressBoxNumber
012716     MOVE WCF-LpAddressZipExtension  TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressZipExtension
012716     MOVE WCF-LpAddressCountry       TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressCountry
012716     MOVE WCF-LpAddressCounty        TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressCounty
012716     MOVE WCF-LpAddressCountyCode    TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressCountyCode
012716     MOVE WCF-LpAddressCityCode      TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpAddressCityCode
012716     MOVE WCF-LpBadAddressInd        TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING         TO WCF-LpBadAddressInd
012716
011116     CONTINUE.
011116
011116******************************************************************
011116 1000-ADDRESS-UPDATE-FROM-WCF.
011116
011116     SET wsAddressNotChanged to TRUE
011116
011116     IF LpUpdatePhoneNumber NOT = WCF-LpPhoneNumber
012016*    AND WCF-LpPhoneNumber > LOW-VALUES
011116         MOVE WCF-LpPhoneNumber
011116             TO WNALK-PHONE-NUMBER
011116                LpUpdatePhoneNumber
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF LpUpdateFaxNumber NOT = WCF-LpFaxNumber
012016*    AND WCF-LpFaxNumber > LOW-VALUES
011116         MOVE WCF-LpFaxNumber
011116              TO WNALK-FAX-NUMBER
011116                 LpUpdateFaxNumber
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF LpUpdateCellPhoneNumber NOT = WCF-LpCellPhoneNumber
012016*    AND WCF-LpCellPhoneNumber > LOW-VALUES
011116         MOVE WCF-LpCellPhoneNumber
011116               TO WNALK-CELL-NUMBER
011116                  LpUpdateCellPhoneNumber
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressType NOT = LpUpdateAddressType
012016*    AND WCF-LpAddressType > LOW-VALUES
011116         MOVE WCF-LpAddressType
011116             TO WNALK-ADDRESS-TYPE
011116                  LpUpdateAddressType
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressLine1 NOT = LpUpdateAddressLine1
011116*    AND WCF-LpAddressLine1 > SPACES
011116         MOVE WCF-LpAddressLine1
011116              TO WADDR-ADDR-LINE-1
011116                  LpUpdateAddressLine1
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressLine2 NOT = LpUpdateAddressLine2
011116*    AND WCF-LpAddressLine2 > LOW-VALUES
011116         MOVE WCF-LpAddressLine2
011116              TO WADDR-ADDR-LINE-2
011116                 LpUpdateAddressLine2
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressLine3 NOT = LpUpdateAddressLine3
011116*    AND WCF-LpAddressLine3 > LOW-VALUES
011116         MOVE WCF-LpAddressLine3
011116              TO WADDR-ADDR-LINE-3
011116                 LpUpdateAddressLine3
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressCity NOT = LpUpdateAddressCity
011116*    AND WCF-LpAddressCity > SPACES
011116         MOVE WCF-LpAddressCity
011116            TO WADDR-CITY
011116               LpUpdateAddressCity
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressState NOT = LpUpdateAddressState
011116*    AND WCF-LpAddressState > SPACES
011116         MOVE WCF-LpAddressState
011116              TO WADDR-STATE
011116                 LpUpdateAddressState
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressZipCode NOT = LpUpdateAddressZipCode
011116*    AND WCF-LpAddressZipCode > ZEROS
011116         MOVE WCF-LpAddressZipCode
011116              TO WADDR-ZIP
011116                 LpUpdateAddressZipCode
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressBoxNumber NOT = LpUpdateAddressBoxNumber
011116*    AND WCF-LpAddressBoxNumber > LOW-VALUES
011116         MOVE WCF-LpAddressBoxNumber
011116              TO WADDR-BOX-NUMBER
011116                 LpUpdateAddressBoxNumber
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressZipExtension NOT =
011116        LpUpdateAddressZipExtension
011116*    AND WCF-LpAddressZipExtension > ZEROS
011116         MOVE WCF-LpAddressZipExtension
011116              TO WADDR-ZIP-EXTENSION
011116                 LpUpdateAddressZipExtension
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressCountry NOT = LpUpdateAddressCountry
011116*    AND WCF-LpAddressCountry > LOW-VALUES
011116         MOVE WCF-LpAddressCountry
011116              TO WADDR-COUNTRY
011116                 LpUpdateAddressCountry
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressCounty NOT =
011116        LpUpdateAddressCounty
011116*    AND WCF-LpAddressCounty > LOW-VALUES
011116         MOVE WCF-LpAddressCounty
011116                TO WADDR-RESIDENT-COUNTY
011116                   LpUpdateAddressCounty
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressCountyCode NOT =
011116        LpUpdateAddressCountyCode
011116*    AND WCF-LpAddressCountyCode > LOW-VALUES
011116         MOVE WCF-LpAddressCountyCode
011116              TO WADDR-COUNTY-CODE
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAddressCityCode NOT =
011116        LpUpdateAddressCityCode
011116*    AND WCF-LpAddressCityCode > LOW-VALUES
011116         MOVE WCF-LpAddressCityCode
011116              TO WADDR-CITY-CODE
011116                 LpUpdateAddressCityCode
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpCancelDate NOT =
011116        LpUpdateCancelDate
011116*    AND WCF-LpCancelDate > LOW-VALUES
011116         MOVE WCF-LpCancelDate
011116              TO WNALK-CANCEL-DATE
011116                 LpUpdateCancelDate
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116
012016     MOVE WNALK-EFFECTIVE-DATE
012016          TO WADDRBOX-ORIGINAL-EFF-DATE
012016
012016*    IF WCF-LpEffectiveDate NOT = 
012016*       LpUpdateEffectiveDate
012016*    AND WCF-LpEffectiveDate > LOW-VALUES
012016*        MOVE WCF-LpEffectiveDate
012016*             TO WNALK-EFFECTIVE-DATE
012016*                LpUpdateEffectiveDate
012016*        SET wsAddressChanged TO TRUE
012016*    END-IF
012016
011116     IF WCF-LpRecurringStartMonth NOT =
011116        LpUpdateRecurringStartMonth
011116*    AND WCF-LpRecurringStartMonth > LOW-VALUES
011116         MOVE WCF-LpRecurringStartMonth
011116              TO WNALK-RECURRING-START-MONTH
011116                 LpUpdateRecurringStartMonth
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpRecurringStartDay
011116                NOT = LpUpdateRecurringStartDay
011116*    AND WCF-LpRecurringStartDay > LOW-VALUES
011116         MOVE WCF-LpRecurringStartDay
011116              TO WNALK-RECURRING-START-DAY
011116                 LpUpdateRecurringStartDay
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpRecurringStopMonth
011116                NOT = LpUpdateRecurringStopMonth
011116*    AND WCF-LpRecurringStopMonth > LOW-VALUES
011116         MOVE WCF-LpRecurringStopMonth
011116              TO WNALK-RECURRING-STOP-MONTH
011116                 LpUpdateRecurringStopMonth
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpRecurringStopDay
011116                NOT = LpUpdateRecurringStopDay
011116*    AND WCF-LpRecurringStopDay > LOW-VALUES
011116         MOVE WCF-LpRecurringStopDay
011116              TO WNALK-RECURRING-STOP-DAY
011116                 LpUpdateRecurringStopDay
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpAlternateNameID
011116                NOT = LpUpdateAlternateNameID
011116*    AND WCF-LpAlternateNameID > LOW-VALUES
011116         MOVE WCF-LpAlternateNameID
011116               TO WNALK-ALTERNATE-NAME-ID
011116                  LpUpdateAlternateNameID
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116     IF WCF-LpBadAddressInd
011116               NOT = LpUpdateBadAddressInd
011116*    AND WCF-LpBadAddressInd > LOW-VALUES
011116         MOVE WCF-LpBadAddressInd
011116               to WNALK-BAD-ADDRESS-IND
011116                  LpUpdateBadAddressInd
011116         SET wsAddressChanged TO TRUE
011116     END-IF
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 1000-ADDRESS-UPDATE.
011116
011116     MOVE wsDataSource TO WSQLF-DATA-SOURCE.
011116     MOVE wsUserID TO WSQLF-USERID.
011116     MOVE wsPassword TO WSQLF-PASSWORD.
011116
011116     SET wsAddressNotChanged TO TRUE.
011116
011116*    If an error occurs on update, we will revert to original 
011116*    records.  
011116     MOVE WADDR-DATA-RECORD TO WS-PRE-UPDATE-ADDR
011116     MOVE WNALK-DATA-RECORD TO WS-PRE-UPDATE-NALK
011116
011116       IF wsAddressWasRead
011116       AND wsNameID = WNALK-NAME-ID
011116         IF LpUpdatePhoneNumber NOT = WNALK-PHONE-NUMBER
011116         AND LpUpdatePhoneNumber > LOW-VALUES
011116             MOVE LpUpdatePhoneNumber
011116                 TO WNALK-PHONE-NUMBER
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateFaxNumber NOT = WNALK-FAX-NUMBER
011116         AND LpUpdateFaxNumber > LOW-VALUES
011116             MOVE LpUpdateFaxNumber
011116                 TO WNALK-FAX-NUMBER
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateCellPhoneNumber NOT = WNALK-CELL-NUMBER
011116         AND LpUpdateCellPhoneNumber > LOW-VALUES
011116             MOVE LpUpdateCellPhoneNumber
011116                   TO WNALK-CELL-NUMBER
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressType NOT = WNALK-ADDRESS-TYPE
011116         AND LpUpdateAddressType > LOW-VALUES
011116             MOVE LpUpdateAddressType
011116                 TO WNALK-ADDRESS-TYPE
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressLine1 NOT = WADDR-ADDR-LINE-1
011116         AND LpUpdateAddressLine1 > LOW-VALUES
011116             MOVE LpUpdateAddressLine1
011116                 TO WADDR-ADDR-LINE-1
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressLine2 NOT = WADDR-ADDR-LINE-2
011116         AND LpUpdateAddressLine2 > LOW-VALUES
011116             MOVE LpUpdateAddressLine2
011116                 TO WADDR-ADDR-LINE-2
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressLine3 NOT = WADDR-ADDR-LINE-3
011116         AND LpUpdateAddressLine3 > LOW-VALUES
011116             MOVE LpUpdateAddressLine3
011116                 TO WADDR-ADDR-LINE-3
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressCity NOT = WADDR-CITY
011116         AND LpUpdateAddressCity > LOW-VALUES
011116            MOVE LpUpdateAddressCity
011116                TO WADDR-CITY
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressState NOT = WADDR-STATE
011116         AND LpUpdateAddressState > LOW-VALUES
011116            MOVE LpUpdateAddressState
011116                TO WADDR-STATE
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressZipCode NOT = WADDR-ZIP
011116         AND LpUpdateAddressZipCode > LOW-VALUES
011116            MOVE LpUpdateAddressZipCode
011116                TO WADDR-ZIP
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressBoxNumber NOT = WADDR-BOX-NUMBER
011116         AND LpUpdateAddressBoxNumber > LOW-VALUES
011116            MOVE LpUpdateAddressBoxNumber
011116                TO WADDR-BOX-NUMBER
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressZipExtension NOT = WADDR-ZIP-EXTENSION
011116         AND LpUpdateAddressZipExtension > LOW-VALUES
011116            MOVE LpUpdateAddressZipExtension
011116                TO WADDR-ZIP-EXTENSION
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressCountry NOT = WADDR-COUNTRY
011116         AND LpUpdateAddressCountry > LOW-VALUES
011116            MOVE LpUpdateAddressCountry
011116                TO WADDR-COUNTRY
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressCounty NOT = WADDR-RESIDENT-COUNTY
011116         AND LpUpdateAddressCounty > LOW-VALUES
011116            MOVE LpUpdateAddressCounty
011116                TO WADDR-RESIDENT-COUNTY
011116            SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressCountyCode NOT = WADDR-COUNTY-CODE
011116         AND LpUpdateAddressCountyCode > LOW-VALUES
011116            MOVE LpUpdateAddressCountyCode
011116                TO WADDR-COUNTY-CODE
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAddressCityCode NOT = WADDR-CITY-CODE
011116         AND LpUpdateAddressCityCode > LOW-VALUES
011116             MOVE LpUpdateAddressCityCode
011116                 TO WADDR-CITY-CODE
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116*        Address Code will only be input to adds.  On-line LifePRO
011116*        does not allow modification of Address Code in updates.  
011116*        Flag an error if user attempts to change Address Code . 
011116         IF LpUpdateAddressCode NOT = WNALK-ADDRESS-CODE
011116         AND LpUpdateAddressCode > LOW-VALUES
011116             MOVE 'Address Code may not be modified on an update'
011116                      TO LpErrorMessage
011116             MOVE 997 TO lsReturnCode
011116                         LpReturnCode
011116         END-IF
011116         IF LpUpdateCancelDate NOT = WNALK-CANCEL-DATE
011116         AND LpUpdateCancelDate > LOW-VALUES
011116             MOVE LpUpdateCancelDate
011116                  TO WNALK-CANCEL-DATE
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116
011116         MOVE WNALK-EFFECTIVE-DATE
011116             TO WADDRBOX-ORIGINAL-EFF-DATE
011116
012016*        IF LpUpdateEffectiveDate NOT = WNALK-EFFECTIVE-DATE
012016*        AND LpUpdateEffectiveDate > LOW-VALUES
012016*            MOVE LpUpdateEffectiveDate
012016*                 TO WNALK-EFFECTIVE-DATE
012016*            SET wsAddressChanged TO TRUE
012016*        END-IF
020916*        IF WNALK-EFFECTIVE-DATE NOT > 0
020916*           SET WDATE-GET-CURRENT-DATE TO TRUE
020916*           CALL PDATECON USING WDATE-PARMS
020916*           IF WDATE-FUNCTION-SUCCESSFUL
020916*              MOVE WDATE-STR-GREG-DATE TO WNALK-EFFECTIVE-DATE
020916*           END-IF
020916*        END-IF
011116
011116         IF LpUpdateRecurringStartMonth
011116                    NOT = WNALK-RECURRING-START-MONTH
011116         AND LpUpdateRecurringStartMonth > LOW-VALUES
011116             MOVE LpUpdateRecurringStartMonth
011116                  TO WNALK-RECURRING-START-MONTH
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateRecurringStartDay
011116                    NOT = WNALK-RECURRING-START-DAY
011116         AND LpUpdateRecurringStartDay > LOW-VALUES
011116             MOVE LpUpdateRecurringStartDay
011116                  TO WNALK-RECURRING-START-DAY
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateRecurringStopMonth
011116                    NOT = WNALK-RECURRING-STOP-MONTH
011116         AND LpUpdateRecurringStopMonth > LOW-VALUES
011116             MOVE LpUpdateRecurringStopMonth
011116                  TO WNALK-RECURRING-STOP-MONTH
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateRecurringStopDay
011116                    NOT = WNALK-RECURRING-STOP-DAY
011116         AND LpUpdateRecurringStopDay > LOW-VALUES
011116             MOVE LpUpdateRecurringStopDay
011116                  TO WNALK-RECURRING-STOP-DAY
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateAlternateNameID
011116                    NOT = WNALK-ALTERNATE-NAME-ID
011116         AND LpUpdateAlternateNameID > LOW-VALUES
011116             MOVE LpUpdateAlternateNameID
011116                   TO WNALK-ALTERNATE-NAME-ID
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116         IF LpUpdateBadAddressInd
011116                   NOT = WNALK-BAD-ADDRESS-IND
011116         AND LpUpdateBadAddressInd > LOW-VALUES
011116             MOVE LpUpdateBadAddressInd
011116                   to WNALK-BAD-ADDRESS-IND
011116             SET wsAddressChanged TO TRUE
011116         END-IF
011116
011116         IF LpReturnCode = Zero
011116             PERFORM 1200-CONTINUE-UPDATE
011116         END-IF
011116
011116       ELSE
011116         MOVE 'Address must be read prior to update'
011116                         TO LpErrorMessage
011116         MOVE 999 TO lsReturnCode,
011116                     LpReturnCode
011116       END-IF.
011116
011116     IF LpReturnCode NOT = ZERO
011116         MOVE  WS-PRE-UPDATE-ADDR TO WADDR-DATA-RECORD
011116         MOVE WS-PRE-UPDATE-NALK TO WNALK-DATA-RECORD
011116     END-IF.
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 1200-CONTINUE-UPDATE.
011116
011116
011116     TRY
011116     IF wsAddressChanged
011116        SET WADDRBOX-UPDATE TO TRUE
011116
011116        SET WADDRBOX-OTHERS-ATTACHED-OK TO TRUE
012116        IF wsUpdateIndicator = 'P'
011116           MOVE wsCompanyCode  TO WNALK-COMPANY-CODE
011116           MOVE wsPolicyNumber TO WNALK-POLICY-NUMBER
012116        ELSE
012116           MOVE SPACES TO WNALK-IDENTIFYING-NUMBER
012116        END-IF
011116        CALL PADDRBOX USING WGLOBAL
011116                            WADDRBOX-PARAMETERS
011116                            WNALK-DATA-RECORD
011116                            WADDR-DATA-RECORD
011116
011116        MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
011116                                     LpReturnCode
011116        MOVE WADDRBOX-RETURN-MESSAGE
011116             TO LpErrorMessage
011116     ELSE
011116         MOVE 'No Changes made.  Update canceled '
011116                      TO LpErrorMessage
011116         MOVE 998 TO lsReturnCode
011116                     LpReturnCode
011116     END-IF
011116
011116     CATCH WS-EXCEPTION
011116         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
011116         MOVE 8008 TO lsReturnCode,
011116                      LpReturnCode
011116         MOVE 'Unexpected Abend in API - see Windows Event Log'
011116             TO LpErrorMessage
011116     END-TRY.
011116
011116
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 1500-LOOKUP-NAME-ADDRESS.
011116
011116     INITIALIZE wsRelaFoundFlag
012716
012716     IF  wsCompanyCode > ' '
012716         MOVE wsCompanyCode          TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsCompanyCode
012716     END-IF
012716     IF  wsPolicyNumber > ' '
012716         MOVE wsPolicyNumber         TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsPolicyNumber
012716     END-IF
012716     IF  wsRelateCode > ' '
012716         MOVE wsRelateCode           TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsRelateCode
012716     END-IF
012716
011116     MOVE SPACES TO WRELA-DATA-RECORD
011116     MOVE wsCompanyCode   TO WRELA-COMPANY-CODE
011116     MOVE wsPolicyNumber  TO WRELA-POLICY-NUMBER
011116*    IF wsRelateCode = ' '
011116*       MOVE 'PO' TO WRELA-RELATE-CODE
011116*                    wsRelateCode
011116*    ELSE
011116        MOVE wsRelateCode to WRELA-RELATE-CODE
011116*    END-IF
011116     PERFORM UNTIL WRELA-RETURN-NOT-OK OR
011116                   wsRelaFound         OR
011116                   wsRelaNotFound
011116*      MOVE WBTRV-GET-GREATER-EQUAL
011116       MOVE WBTRV-GET-GREATER
011116                   TO WRELA-FUNCTION
011116       MOVE 1                 TO WRELA-KEY-NUMBER
011116       MOVE WFILE-RELA-NUM    TO DATA-FILE-NUMBER
011116       MOVE WRELA-DATA-RECORD TO DATA-AREA
011116       CALL PFILEBTV USING       WGLOBAL
011116                                 WRELA-CALL-PARAMETERS
011116                                 WBTRIEVE
011116       MOVE DATA-AREA         TO WRELA-DATA-RECORD
011116       IF WRELA-RETURN-CODE = ZEROS
011116          IF WRELA-POLICY-NUMBER = wsPolicyNumber
011116             IF WRELA-RELATE-CODE = wsRelateCode
011116                MOVE WRELA-NAME-ID TO wsNameId
011116                                      LpUpdateNameId
011116                MOVE 'Y' TO wsRelaFoundFlag
011116             ELSE
011116                CONTINUE
011116*               MOVE ZEROS TO wsNameId
011116*                             LpUpdateNameId 
011116*               MOVE 'N' TO wsRelaFoundFlag
011116             END-IF
011116          ELSE
011116             MOVE 'N' TO wsRelaFoundFlag
011116*            MOVE ZEROS TO wsNameId
011116*                          LpUpdateNameId 
011116          END-IF
011116       END-IF
011116    END-PERFORM
011116
011116    IF WRELA-RETURN-NOT-OK OR wsRelaNotFound
011116       MOVE 'Relationship for Policy Not Found'
011116            TO LpErrorMessage
011116         MOVE 9   TO lsReturnCode
011116                     LpReturnCode
011116         MOVE ZEROS TO wsNameId
011116                       LpUpdateNameId
011116    END-IF
011116
011116    CONTINUE.
011116
011116******************************************************************
012116 2000-ADDRESS-REQUERY.
011116
012116     MOVE SPACES   TO WNALK-IDENTIFYING-NUMBER.
011116     MOVE WBTRV-GET-LESS-EQUAL TO WNALK-FUNCTION
011116
011116     TRY
011116        MOVE WFILE-NALK-NUM TO DATA-FILE-NUMBER
011116        MOVE WNALK-DATA-RECORD TO DATA-AREA
012116        MOVE ZERO TO WNALK-KEY-NUMBER
011116        CALL PFILEBTV USING WGLOBAL
011116                            WNALK-CALL-PARAMETERS
011116                            WBTRIEVE
011116        MOVE DATA-AREA TO WNALK-DATA-RECORD
011116        IF WBTRV-SUCCESSFUL
011116          IF WNALK-NAME-ID = wsNameID
011116            MOVE WNALK-DATA-RECORD TO WS-HOLD-WNALK-RECORD
011116            SET WADDRBOX-READ TO TRUE
011116            CALL PADDRBOX USING WGLOBAL
011116                                WADDRBOX-PARAMETERS
011116                                WNALK-DATA-RECORD
011116                                WADDR-DATA-RECORD
011116            MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
011116                                         LpReturnCode
011116            MOVE WADDRBOX-RETURN-MESSAGE TO LpErrorMessage
011116            IF WADDRBOX-SUCCESSFUL
011116              SET wsAddressWasRead TO TRUE
011116              MOVE WNALK-ADDRESS-ID TO LpAddressID
011116              MOVE WNALK-CANCEL-DATE TO LpCancelDate
011116                                        LpUpdateCancelDate
011116              MOVE WNALK-EFFECTIVE-DATE TO LpEffectiveDate
011116                                           LpUpdateEffectiveDate
011116              MOVE WNALK-RECURRING-START-MONTH
011116                               TO LpRecurringStartMonth
011116                                  LpUpdateRecurringStartMonth
011116              MOVE WNALK-RECURRING-START-DAY
011116                               TO LpRecurringStartDay
011116                                  LpUpdateRecurringStartDay
011116              MOVE WNALK-RECURRING-STOP-MONTH
011116                               TO LpRecurringStopMonth
011116                                  LpUpdateRecurringStopMonth
011116              MOVE WNALK-RECURRING-STOP-DAY
011116                               TO LpRecurringStopDay
011116                                  LpUpdateRecurringStopDay
011116              MOVE WNALK-ALTERNATE-NAME-ID
011116                               TO LpAlternateNameID
011116                                  LpUpdateAlternateNameID
011116              MOVE WNALK-BAD-ADDRESS-IND
011116                               TO LpBadAddressInd
011116                                  LpUpdateBadAddressInd
011116              IF WNALK-PHONE-NUMBER IS NUMERIC
011116                 MOVE WNALK-PHONE-NUMBER TO LpPhoneNumber,
011116                                            LpUpdatePhoneNumber
011116              ELSE
011116                 MOVE ZEROS TO LpPhoneNumber,
121215                               LpUpdatePhoneNumber
011116              END-IF
011116              IF WNALK-PHONE-NUMBER IS NUMERIC
011116                 MOVE WNALK-FAX-NUMBER TO LpFaxNumber,
011116                                          LpUpdateFaxNumber
011116              ELSE
011116                 MOVE ZEROS TO LpFaxNumber,
011116                               LpUpdateFaxNumber
011116              END-IF
011116              IF WNALK-CELL-NUMBER IS NUMERIC
011116                       MOVE WNALK-CELL-NUMBER TO LpCellPhoneNumber,
011116                                          LpUpdateCellPhoneNumber
011116              ELSE
011116                 MOVE ZEROS TO LpCellPhoneNumber,
011116                               LpUpdateCellPhoneNumber
011116              END-IF
011116              IF WNALK-ADDRESS-TYPE = LOW-VALUES
011116              OR WNALK-ADDRESS-TYPE = HIGH-VALUES
011116                  MOVE SPACES TO LpAddressType
011116              ELSE
011116                  MOVE WNALK-ADDRESS-TYPE TO LpAddressType
011116              END-IF
011116              MOVE LpAddressType to LpUpdateAddressType
011116              IF WNALK-ADDRESS-CODE = LOW-VALUES
011116              OR WNALK-ADDRESS-CODE = HIGH-VALUES
011116                  MOVE SPACES TO LpAddressCode
011116              ELSE
011116                  MOVE WNALK-ADDRESS-CODE TO LpAddressCode
011116              END-IF
011116              Move LpAddressCode to LpUpdateAddressCode
011116              MOVE WADDR-ADDR-LINE-1 TO LpAddressLine1,
011116                                        LpUpdateAddressLine1
011116              MOVE WADDR-ADDR-LINE-2 TO LpAddressLine2,
011116                                        LpUpdateAddressLine2
011116              MOVE WADDR-ADDR-LINE-3 TO LpAddressLine3,
011116                                        LpUpdateAddressLine3
011116              MOVE WADDR-CITY TO LpAddressCity,
011116                                 LpUpdateAddressCity
011116              MOVE WADDR-STATE TO LpAddressState,
011116                                  LpUpdateAddressState
011116              MOVE WADDR-ZIP TO LpAddressZipCode,
011116                                LpUpdateAddressZipCode
011116              MOVE WADDR-BOX-NUMBER TO LpAddressBoxNumber,
011116                                       LpUpdateAddressBoxNumber
011116              MOVE WADDR-ZIP-EXTENSION
011116                                 TO LpAddressZipExtension,
011116                                    LpUpdateAddressZipExtension
011116              MOVE WADDR-COUNTRY TO LpAddressCountry,
011116                                    LpUpdateAddressCountry
011116              MOVE WADDR-RESIDENT-COUNTY
011116                                 TO LpAddressCounty,
011116                                    LpUpdateAddressCounty
011116              MOVE WADDR-COUNTY-CODE
011116                                 TO LpAddressCountyCode,
011116                                    LpUpdateAddressCountyCode
011116              MOVE WADDR-CITY-CODE TO LpAddressCityCode,
011116                                      LpUpdateAddressCityCode
011116              MOVE WADDR-ADDR-LINE-1 TO WNADR-ADDR-LINE-1
011116              MOVE WADDR-ADDR-LINE-2 TO WNADR-ADDR-LINE-2
011116              MOVE WADDR-ADDR-LINE-3 TO WNADR-ADDR-LINE-3
011116              MOVE WADDR-CITY TO WNADR-CITY
011116              MOVE WADDR-STATE TO WNADR-STATE
011116              MOVE WADDR-ZIP-CODE TO WNADR-ZIP-CODE
011116              MOVE '5' TO WS-PNADRBOX-OPTION
011116              CALL PNADRBOX USING WGLOBAL
011116                                  GLOBAL-PARAMETERS
011116                                  WNADR-DATA-RECORD
011116                                  WS-PNADRBOX-OPTION
011116              IF LINK-RETURN-STATUS = ZERO
011116                MOVE WNADR-ADDR-LINE-1 TO LpFormatAddressLine1
011116                MOVE WNADR-ADDR-LINE-2 TO LpFormatAddressLine2
011116                MOVE WNADR-ADDR-LINE-3 TO LpFormatAddressLine3
011116                MOVE WNADR-ADDR-LINE-4 TO LpFormatAddressLine4
011116              END-IF
011116            END-IF
011116          ELSE
011116            MOVE 9 TO lsReturnCode,
011116                      LpReturnCode
011116            IF wsUpdateQueryFlag = "N"
011116              MOVE 'No more addresses for this Name ID'
011116                  TO LpErrorMessage
112315              MOVE WS-HOLD-WNALK-RECORD
112315                            TO WNALK-DATA-RECORD
112315              MOVE LpSaveOutputGroup TO LpOutputGroup
011116            ELSE
011116              MOVE 7 TO lsReturnCode,
011116                        LpReturnCode
011116              MOVE 'No addresses found for this Name ID'
011116                  TO LpErrorMessage
011116            END-IF
011116          END-IF
011116        ELSE
011116          MOVE 8 TO lsReturnCode,
011116                    LpReturnCode
011116          MOVE 'Name ID not found' TO LpErrorMessage
011116        END-IF
011116     CATCH WS-EXCEPTION
011116         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
011116         MOVE 8008 TO lsReturnCode,
011116                      LpReturnCode
011116         MOVE 'Unexpected Abend in API - see Windows Event Log'
011116             TO LpErrorMessage
011116     END-TRY.
011116
011116     CONTINUE.
011116******************************************************************
011116 END METHOD UpdateAddressForPolicy.
011116******************************************************************
011116******************************************************************
011116 METHOD-ID. AddAddressForPolicy.
011116******************************************************************
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116
011116
011116     COPY WDATECPY.
011116     COPY WNADRCPY.
011116     COPY WPGLBCPY.
011116     COPY WADBTCPY.
011116     COPY WSQLFCPY.
011116
011116 01  WS-PNADRBOX-OPTION          PIC X(01).
011116
011116 01 wsAddressChangedFlag         PIC X(01).
011116     88  wsAddressChanged                        VALUE 'Y'.
011116     88  wsAddressNotChanged                     VALUE 'N'.
011116
011116 01  WS-IDENTIFYING-NUMBER.
011116     05 wsRelaCompanyCode        PIC X(02).
011116     05 wsRelaPolicyNumber       PIC X(12).
011116
011116 01 wsRelaFoundFlag         PIC X(01).
011116     88  wsRelaFound                          VALUE 'Y'.
011116     88  wsRelaNotFound                       VALUE 'N'.
012116
012116 01  WS-HOLD-QUERY-FUNCTION      PIC X(01).
012116
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116
011116 01  lsReturnCode                PIC S9(09) COMP-5.
011116
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsReturnCode.
011116******************************************************************
011116
011116     MOVE ZERO TO lsReturnCode,
123152                  LpReturnCode
011116     MOVE SPACES TO LpErrorMessage
011116
020916
020916     IF  wsUpdateIndicator = 'P'
020916     AND wsUpdateQueryFlag = 'U'
020916     AND NALK-WILL-INSERT
020916         MOVE ZERO TO LpAddressID
020916         SET NALK-WILL-UPDATE TO TRUE
020916     ELSE
012016         MOVE ZERO TO LpAddressID
012016         MOVE ZERO TO LpCancelDate
012016         MOVE ZERO TO LpRecurringStartMonth
012016         MOVE ZERO TO LpRecurringStartDay
012016         MOVE ZERO TO LpRecurringStopMonth
012016         MOVE ZERO TO LpRecurringStopDay
012016         MOVE ZERO TO LpAlternateNameID
012016         MOVE ZERO TO LpPhoneNumber
012016         MOVE ZERO TO LpFaxNumber
012016         MOVE ZERO TO LpCellPhoneNumber
012016         MOVE SPACES TO LpAddressType
012016         MOVE SPACES TO LpAddressCode
012016         MOVE SPACES TO LpAddressLine1
012016         MOVE SPACES TO LpAddressLine2
012016         MOVE SPACES TO LpAddressLine3
012016         MOVE SPACES TO LpAddressCity
012016         MOVE SPACES TO LpAddressState
012016         MOVE SPACES TO LpAddressZipCode
012016         MOVE SPACES TO LpAddressBoxNumber
012016         MOVE SPACES TO LpAddressZipExtension
012016         MOVE SPACES TO LpAddressCountry
012016         MOVE SPACES TO LpAddressCounty
012016         MOVE SPACES TO LpAddressCountyCode
012016         MOVE SPACES TO LpAddressCityCode
012016         MOVE SPACES TO LpFormatAddressLine1
012016         MOVE SPACES TO LpFormatAddressLine2
012016         MOVE SPACES TO LpFormatAddressLine3
012016         MOVE SPACES TO LpFormatAddressLine4
012016         MOVE SPACES TO LpBadAddressInd
020916     END-IF
012016
012716     MOVE wsUpdateQueryFlag TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateQueryFlag
012716     MOVE wsUpdateIndicator TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsUpdateIndicator
012716     MOVE wsInAddressCode TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressCode
012716     MOVE wsInAddressType    TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE           TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING TO wsInAddressType
012716
011116     PERFORM 1500-LOOKUP-NAME-ADDRESS
012116     IF wsUpdateIndicator = 'P'
011116        PERFORM 1500-ADDRESS-ADD
012116     ELSE
012116        MOVE wsUpdateQueryFlag to WS-HOLD-QUERY-FUNCTION
012116        MOVE 'A' TO wsUpdateQueryFlag
012116        INVOKE Self 'RunAddressFunction'
012116        MOVE WS-HOLD-QUERY-FUNCTION TO wsUpdateQueryFlag
011116     END-IF
011116
011116     EXIT METHOD.
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 1500-ADDRESS-ADD.
011116
012716     MOVE wsCompanyCode       TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE    TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING  TO wsCompanyCode
012716     MOVE wsPolicyNumber      TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE    TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING  TO wsPolicyNumber
012716     MOVE LpUpdateAddressType TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE    TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING  TO LpUpdateAddressType
012716     MOVE LpUpdateAddressCode TO WFUNC-INPUT-STRING
012716     SET  WFUNC-UPPER-CASE    TO TRUE
012716     CALL POPFUNCN USING WGLOBAL
012716     MOVE WFUNC-INPUT-STRING  TO LpUpdateAddressCode
012716
011116*    Similar to address update, but no pre-read is required, 
011116*    and all WNALK and WADDR fields must be set.  
011116
011116     INITIALIZE WNALK-DATA-RECORD
011116     INITIALIZE WADDR-DATA-RECORD.
011116
011116     TRY
011116         MOVE wsNameID TO WNALK-NAME-ID
011116         MOVE wsCompanyCode  TO WNALK-COMPANY-CODE
011116         MOVE wsPolicyNumber TO WNALK-POLICY-NUMBER
011116         MOVE LpUpdatePhoneNumber
011116                 TO WNALK-PHONE-NUMBER
011116         MOVE LpUpdateFaxNumber
011116                 TO WNALK-FAX-NUMBER
011116         MOVE LpUpdateCellPhoneNumber
011116                   TO WNALK-CELL-NUMBER
011116         MOVE LpUpdateAddressType
011116                 TO WNALK-ADDRESS-TYPE
011116         MOVE LpUpdateAddressLine1
011116                 TO WADDR-ADDR-LINE-1
011116         MOVE LpUpdateAddressLine2
011116                 TO WADDR-ADDR-LINE-2
011116         MOVE LpUpdateAddressLine3
011116                 TO WADDR-ADDR-LINE-3
011116         MOVE LpUpdateAddressCity
011116                 TO WADDR-CITY
011116         MOVE LpUpdateAddressState
011116                 TO WADDR-STATE
011116         MOVE LpUpdateAddressZipCode
011116                 TO WADDR-ZIP
011116         MOVE LpUpdateAddressBoxNumber
011116                 TO WADDR-BOX-NUMBER
011116         MOVE LpUpdateAddressZipExtension
011116                 TO WADDR-ZIP-EXTENSION
011116         MOVE LpUpdateAddressCountry
011116                 TO WADDR-COUNTRY
011116         MOVE LpUpdateAddressCounty
011116                 TO WADDR-RESIDENT-COUNTY
011116         MOVE LpUpdateAddressCountyCode
011116                 TO WADDR-COUNTY-CODE
011116         MOVE LpUpdateAddressCityCode
011116                 TO WADDR-CITY-CODE
011116
011116         MOVE LpUpdateAddressCode TO WNALK-ADDRESS-CODE
011116         MOVE LpUpdateCancelDate
011116                  TO WNALK-CANCEL-DATE
011116
011116         IF LpUpdateEffectiveDate NOT > 0
011116            SET WDATE-GET-CURRENT-DATE TO TRUE
011116            CALL PDATECON USING WDATE-PARMS
011116            IF WDATE-FUNCTION-SUCCESSFUL
011116               MOVE WDATE-STR-GREG-DATE TO WNALK-EFFECTIVE-DATE
011116            END-IF
011116         ELSE
011116            MOVE LpUpdateEffectiveDate
011116                 TO WNALK-EFFECTIVE-DATE
011116         END-IF
011116
011116         MOVE LpUpdateRecurringStartMonth
011116                  TO WNALK-RECURRING-START-MONTH
011116         MOVE LpUpdateRecurringStartDay
011116                  TO WNALK-RECURRING-START-DAY
011116
011116         MOVE LpUpdateRecurringStopMonth
011116                  TO WNALK-RECURRING-STOP-MONTH
011116         MOVE LpUpdateRecurringStopDay
011116                  TO WNALK-RECURRING-STOP-DAY
011116         MOVE LpUpdateAlternateNameID
011116                  TO WNALK-ALTERNATE-NAME-ID
011116         MOVE LpUpdateBadAddressInd
011116                  TO WNALK-BAD-ADDRESS-IND
121215
011116         SET WADDRBOX-ADD TO TRUE
011116
011116*        SET WADDRBOX-OTHERS-ATTACHED-OK TO TRUE
011116
011116         CALL PADDRBOX USING WGLOBAL
011116                             WADDRBOX-PARAMETERS
011116                             WNALK-DATA-RECORD
011116                             WADDR-DATA-RECORD
011116
011116         MOVE WADDRBOX-RETURN-CODE TO lsReturnCode,
011116                                      LpReturnCode
011116         MOVE WADDRBOX-RETURN-MESSAGE
011116                 TO LpErrorMessage
011116
011116     CATCH WS-EXCEPTION
011116         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
011116         MOVE 8008 TO lsReturnCode,
011116                      LpReturnCode
011116         MOVE 'Unexpected Abend in API - see Windows Event Log'
011116             TO LpErrorMessage
011116     END-TRY.
011116
011116     CONTINUE.
011116
011116******************************************************************
011116 1500-LOOKUP-NAME-ADDRESS.
011116
011116     INITIALIZE wsRelaFoundFlag
012716
012716     IF  wsCompanyCode > ' '
012716         MOVE wsCompanyCode          TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsCompanyCode
012716     END-IF
012716     IF  wsPolicyNumber > ' '
012716         MOVE wsPolicyNumber         TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsPolicyNumber
012716     END-IF
012716     IF  wsRelateCode > ' '
012716         MOVE wsRelateCode           TO WFUNC-INPUT-STRING
012716         SET  WFUNC-UPPER-CASE       TO TRUE
012716         CALL POPFUNCN USING WGLOBAL
012716         MOVE WFUNC-INPUT-STRING     TO wsRelateCode
012716     END-IF
012716
011116     MOVE SPACES TO WRELA-DATA-RECORD
011116     MOVE wsCompanyCode   TO WRELA-COMPANY-CODE
011116     MOVE wsPolicyNumber  TO WRELA-POLICY-NUMBER
011116     MOVE wsRelateCode to WRELA-RELATE-CODE
011116     PERFORM UNTIL WRELA-RETURN-NOT-OK OR
011116                   wsRelaFound         OR
011116                   wsRelaNotFound
011116       MOVE WBTRV-GET-GREATER
011116                   TO WRELA-FUNCTION
011116       MOVE 1                 TO WRELA-KEY-NUMBER
011116       MOVE WFILE-RELA-NUM    TO DATA-FILE-NUMBER
011116       MOVE WRELA-DATA-RECORD TO DATA-AREA
011116       CALL PFILEBTV USING       WGLOBAL
011116                                 WRELA-CALL-PARAMETERS
011116                                 WBTRIEVE
011116       MOVE DATA-AREA         TO WRELA-DATA-RECORD
011116       IF WRELA-RETURN-CODE = ZEROS
011116          IF WRELA-POLICY-NUMBER = wsPolicyNumber
011116             IF WRELA-RELATE-CODE = wsRelateCode
011116                MOVE WRELA-NAME-ID TO wsNameId
011116                                      LpUpdateNameId
011116                MOVE 'Y' TO wsRelaFoundFlag
011116             ELSE
011116                CONTINUE
011116             END-IF
011116          ELSE
011116             MOVE 'N' TO wsRelaFoundFlag
011116          END-IF
011116       END-IF
011116    END-PERFORM
011116
011116    IF WRELA-RETURN-NOT-OK OR wsRelaNotFound
011116       MOVE 'Relationship for Policy Not Found'
011116            TO LpErrorMessage
011116         MOVE 9   TO lsReturnCode
011116                     LpReturnCode
011116         MOVE ZEROS TO wsNameId
011116                       LpUpdateNameId
011116    END-IF
011116
011116    CONTINUE.
011116
011116******************************************************************
011116 END METHOD AddAddressForPolicy.
011116******************************************************************
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
        METHOD-ID. getUpdateQueryFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateQueryFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateQueryFlag.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE wsUpdateQueryFlag
                RETURNING lsUpdateQueryFlag.

           EXIT METHOD.

       END METHOD getUpdateQueryFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNameID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNameID.
      ******************************************************************

           MOVE wsNameID TO lsNameID.
011116     IF wsNameID > 0
011116        MOVE SPACES TO wsCompanyCode
011116                       wsPolicyNumber
011116     END-IF

           EXIT METHOD.

       END METHOD getNameID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
011116
011116 METHOD-ID. getCompanyCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsCompanyCode   PIC X(02).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsCompanyCode.
011116******************************************************************
011116
011116     MOVE wsCompanyCode TO lsCompanyCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD getCompanyCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getPolicyNumber.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsPolicyNumber  PIC X(12).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsPolicyNumber.
011116******************************************************************
011116
011116     MOVE wsPolicyNumber TO lsPolicyNumber
011116
011116     EXIT METHOD.
011116
011116 END METHOD getPolicyNumber.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getRelateCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsRelateCode  PIC X(02).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsRelateCode.
011116******************************************************************
011116
011116     MOVE wsRelateCode to lsRelateCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD getRelateCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getInAddressType.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsInAddressType  PIC X(01).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsInAddressType.
011116******************************************************************
011116
011116      MOVE wsInAddressType TO lsInAddressType
011116
011116     EXIT METHOD.
011116
011116 END METHOD getInAddressType.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getInAddressCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsInAddressCode  PIC X(03).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsInAddressCode.
011116******************************************************************
011116
011116      MOVE wsInAddressCode TO lsInAddressCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD getInAddressCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getUpdateIndicator.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsUpdateIndicator  PIC X(01).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsUpdateIndicator.
011116******************************************************************
011116
011116      MOVE wsUpdateIndicator TO lsUpdateIndicator
011116
011116     EXIT METHOD.
011116
011116 END METHOD getUpdateIndicator.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getUpdateNameId.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsUpdateNameId  PIC S9(09) COMP-5.
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsUpdateNameId.
011116******************************************************************
011116
011116      MOVE LpUpdateNameId TO lsUpdateNameId
011116
011116     EXIT METHOD.
011116
011116 END METHOD getUpdateNameId.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. getRelationshipCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsRelationshipCode  PIC X(03).
011116******************************************************************
011116 PROCEDURE DIVISION RETURNING lsRelationshipCode.
011116******************************************************************
011116
011116      MOVE LpRelationshipCode TO lsRelationshipCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD getRelationshipCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
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

       METHOD-ID. getAddressID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressID.
      ******************************************************************

           MOVE LpAddressID TO lsAddressID.

           EXIT METHOD.

       END METHOD getAddressID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getCancelDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCancelDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsCancelDate.
      ******************************************************************

           MOVE LpCancelDate TO lsCancelDate.

           EXIT METHOD.

       END METHOD getCancelDate.

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

           MOVE LpEffectiveDate TO lsEffectiveDate.

           EXIT METHOD.

       END METHOD getEffectiveDate.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRecurringStartMonth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStartMonth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRecurringStartMonth.
      ******************************************************************

           MOVE LpRecurringStartMonth TO lsRecurringStartMonth.

           EXIT METHOD.

       END METHOD getRecurringStartMonth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRecurringStartDay.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStartDay        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRecurringStartDay.
      ******************************************************************

           MOVE LpRecurringStartDay TO lsRecurringStartDay.

           EXIT METHOD.

       END METHOD getRecurringStartDay.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRecurringStopMonth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStopMonth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRecurringStopMonth.
      ******************************************************************

           MOVE LpRecurringStopMonth TO lsRecurringStopMonth.

           EXIT METHOD.

       END METHOD getRecurringStopMonth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getRecurringStopDay.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStopDay        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsRecurringStopDay.
      ******************************************************************

           MOVE LpRecurringStopDay TO lsRecurringStopDay.

           EXIT METHOD.

       END METHOD getRecurringStopDay.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAlternateNameID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAlternateNameID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAlternateNameID.
      ******************************************************************

           MOVE LpAlternateNameID TO lsAlternateNameID.

           EXIT METHOD.

       END METHOD getAlternateNameID.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

112612 METHOD-ID. getBadAddressInd.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsBadAddressInd        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsBadAddressInd.
112612******************************************************************
112612
112612     SET lsBadAddressInd TO LpBadAddressInd.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getBadAddressInd.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getPhoneNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsPhoneNumber        PIC S9(18) USAGE COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsPhoneNumber.
      ******************************************************************

           MOVE LpPhoneNumber TO lsPhoneNumber.

           EXIT METHOD.

       END METHOD getPhoneNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFaxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsFaxNumber        PIC S9(18) USAGE COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFaxNumber.
      ******************************************************************

           MOVE LpFaxNumber TO lsFaxNumber.

           EXIT METHOD.

       END METHOD getFaxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
022312
022312 METHOD-ID. getCellPhoneNumber.
022312 DATA DIVISION.
022312******************************************************************
022312 WORKING-STORAGE SECTION.
022312******************************************************************
022312 LINKAGE SECTION.
022312
022312 01  lsCellPhoneNumber  PIC S9(18) USAGE COMP-5.
022312******************************************************************
022312 PROCEDURE DIVISION RETURNING lsCellPhoneNumber.
022312******************************************************************
022312
022312     MOVE LpCellPhoneNumber TO lsCellPhoneNumber.
022312
022312     EXIT METHOD.
022312
022312 END METHOD getCellPhoneNumber.
022312******************************************************************
022312*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022312******************************************************************

       METHOD-ID. getAddressType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressType        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressType.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressType
                RETURNING lsAddressType.

           EXIT METHOD.

       END METHOD getAddressType.
010510******************************************************************
010510*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010510******************************************************************
010510
010510 METHOD-ID. getAddressCode.
010510 DATA DIVISION.
010510******************************************************************
010510 WORKING-STORAGE SECTION.
010510******************************************************************
010510 LINKAGE SECTION.
010510
010510 01  lsAddressCode        OBJECT REFERENCE CLASS-STRING.
010510******************************************************************
010510 PROCEDURE DIVISION RETURNING lsAddressCode.
010510******************************************************************
010510
010510     INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCode
010510          RETURNING lsAddressCode.
010510
010510     EXIT METHOD.
010510
010510 END METHOD getAddressCode.

102813******************************************************************
102813*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102813******************************************************************
102813
102813 METHOD-ID. getIdentifyingNumber.
102813 DATA DIVISION.
102813******************************************************************
102813 WORKING-STORAGE SECTION.
102813******************************************************************
102813 LINKAGE SECTION.
102813
102813 01  lsIdentifyingNumber        OBJECT REFERENCE CLASS-STRING.
102813******************************************************************
102813 PROCEDURE DIVISION RETURNING lsIdentifyingNumber.
102813******************************************************************
102813
102813     SET lsIdentifyingNumber TO WNALK-IDENTIFYING-NUMBER (1:14).
102813
102813     EXIT METHOD.
102813
102813 END METHOD getIdentifyingNumber.


      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressLine1.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressLine1
                RETURNING lsAddressLine1.

           EXIT METHOD.

       END METHOD getAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressLine2.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressLine2
                RETURNING lsAddressLine2.

           EXIT METHOD.

       END METHOD getAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressLine3.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressLine3
                RETURNING lsAddressLine3.

           EXIT METHOD.

       END METHOD getAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressCity.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCity        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressCity.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCity
                RETURNING lsAddressCity.

           EXIT METHOD.

       END METHOD getAddressCity.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressState.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressState        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressState.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressState
                RETURNING lsAddressState.

           EXIT METHOD.

       END METHOD getAddressState.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressZipCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressZipCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressZipCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressZipCode
                RETURNING lsAddressZipCode.

           EXIT METHOD.

       END METHOD getAddressZipCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressBoxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressBoxNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressBoxNumber.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressBoxNumber
                RETURNING lsAddressBoxNumber.

           EXIT METHOD.

       END METHOD getAddressBoxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressZipExtension.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressZipExtension        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressZipExtension.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                     LpAddressZipExtension
                RETURNING lsAddressZipExtension.

           EXIT METHOD.

       END METHOD getAddressZipExtension.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressCountry.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCountry        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressCountry.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCountry
                RETURNING lsAddressCountry.

           EXIT METHOD.

       END METHOD getAddressCountry.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressCounty.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCounty        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressCounty.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCounty
                RETURNING lsAddressCounty.

           EXIT METHOD.

       END METHOD getAddressCounty.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressCountyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCountyCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressCountyCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCountyCode
                RETURNING lsAddressCountyCode.

           EXIT METHOD.

       END METHOD getAddressCountyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getAddressCityCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCityCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsAddressCityCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpAddressCityCode
                RETURNING lsAddressCityCode.

           EXIT METHOD.

       END METHOD getAddressCityCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFormatAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFormatAddressLine1.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFormatAddressLine1
                RETURNING lsFormatAddressLine1.

           EXIT METHOD.

       END METHOD getFormatAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFormatAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFormatAddressLine2.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFormatAddressLine2
                RETURNING lsFormatAddressLine2.

           EXIT METHOD.

       END METHOD getFormatAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFormatAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFormatAddressLine3.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFormatAddressLine3
                RETURNING lsFormatAddressLine3.

           EXIT METHOD.

       END METHOD getFormatAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFormatAddressLine4.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine4        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFormatAddressLine4.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFormatAddressLine4
                RETURNING lsFormatAddressLine4.

           EXIT METHOD.

       END METHOD getFormatAddressLine4.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdatePhoneNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsUpdatePhoneNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdatePhoneNumber.
      ******************************************************************

           MOVE LpUpdatePhoneNumber TO lsUpdatePhoneNumber.

           EXIT METHOD.

       END METHOD getUpdatePhoneNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateFaxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsUpdateFaxNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateFaxNumber.
      ******************************************************************

           MOVE LpUpdateFaxNumber TO lsUpdateFaxNumber.

           EXIT METHOD.

       END METHOD getUpdateFaxNumber.
022312******************************************************************
022312*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022312******************************************************************
022312
022312 METHOD-ID. getUpdateCellPhoneNumber.
022312 DATA DIVISION.
022312******************************************************************
022312 WORKING-STORAGE SECTION.
022312******************************************************************
022312 LINKAGE SECTION.
022312
022312 01  lsUpdateCellPhoneNumber        PIC S9(18) COMP-5.
022312******************************************************************
022312 PROCEDURE DIVISION RETURNING lsUpdateCellPhoneNumber.
022312******************************************************************
022312
022312     MOVE LpUpdateCellPhoneNumber TO lsUpdateCellPhoneNumber.
022312
022312     EXIT METHOD.
022312
022312 END METHOD getUpdateCellPhoneNumber.
032411******************************************************************
032411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032411******************************************************************
032411
032411 METHOD-ID. getUpdateAddressType.
032411 DATA DIVISION.
032411******************************************************************
032411 WORKING-STORAGE SECTION.
032411******************************************************************
032411 LINKAGE SECTION.
032411
032411 01  lsUpdateAddressType        OBJECT REFERENCE CLASS-STRING.
032411******************************************************************
032411 PROCEDURE DIVISION RETURNING lsUpdateAddressType.
032411******************************************************************
032411
032411     INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressType
032411          RETURNING lsUpdateAddressType.
032411
032411     EXIT METHOD.
032411
032411 END METHOD getUpdateAddressType.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateAddressCode.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateAddressCode        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateAddressCode.
112612******************************************************************
112612
112612     INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressCode
112612          RETURNING lsUpdateAddressCode.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateAddressCode.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressLine1.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressLine1
                RETURNING lsUpdateAddressLine1.

           EXIT METHOD.

       END METHOD getUpdateAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressLine2.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressLine2
                RETURNING lsUpdateAddressLine2.

           EXIT METHOD.

       END METHOD getUpdateAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressLine3.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressLine3
                RETURNING lsUpdateAddressLine3.

           EXIT METHOD.

       END METHOD getUpdateAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressCity.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCity        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressCity.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressCity
                RETURNING lsUpdateAddressCity.

           EXIT METHOD.

       END METHOD getUpdateAddressCity.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressState.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressState        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressState.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateAddressState
                RETURNING lsUpdateAddressState.

           EXIT METHOD.

       END METHOD getUpdateAddressState.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressZipCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressZipCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressZipCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                     LpUpdateAddressZipCode
                RETURNING lsUpdateAddressZipCode.

           EXIT METHOD.

       END METHOD getUpdateAddressZipCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressBoxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressBoxNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressBoxNumber.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                      LpUpdateAddressBoxNumber
                RETURNING lsUpdateAddressBoxNumber.

           EXIT METHOD.

       END METHOD getUpdateAddressBoxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressZipExtension.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressZipExtension  OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressZipExtension.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                              LpUpdateAddressZipExtension
                RETURNING lsUpdateAddressZipExtension.

           EXIT METHOD.

       END METHOD getUpdateAddressZipExtension.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressCountry.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCountry        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressCountry.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                      LpUpdateAddressCountry
                RETURNING lsUpdateAddressCountry.

           EXIT METHOD.

       END METHOD getUpdateAddressCountry.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressCounty.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCounty        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressCounty.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                     LpUpdateAddressCounty
                RETURNING lsUpdateAddressCounty.

           EXIT METHOD.

       END METHOD getUpdateAddressCounty.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressCountyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCountyCode    OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressCountyCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                     LpUpdateAddressCountyCode
                RETURNING lsUpdateAddressCountyCode.

           EXIT METHOD.

       END METHOD getUpdateAddressCountyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateAddressCityCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCityCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateAddressCityCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE
                                     LpUpdateAddressCityCode
                RETURNING lsUpdateAddressCityCode.

           EXIT METHOD.

       END METHOD getUpdateAddressCityCode.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateCancelDate.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateCancelDate        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateCancelDate.
112612******************************************************************
112612
112612     MOVE LpUpdateCancelDate TO lsUpdateCancelDate.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateCancelDate.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateEffectiveDate.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateEffectiveDate        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateEffectiveDate.
112612******************************************************************
112612
112612     MOVE LpUpdateEffectiveDate TO lsUpdateEffectiveDate.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateEffectiveDate.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateRecurringStartMonth.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStartMonth        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateRecurringStartMonth.
112612******************************************************************
112612
112612     MOVE LpUpdateRecurringStartMonth
112612                    TO lsUpdateRecurringStartMonth.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateRecurringStartMonth.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateRecurringStartDay.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStartDay        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateRecurringStartDay.
112612******************************************************************
112612
112612     MOVE LpUpdateRecurringStartDay TO lsUpdateRecurringStartDay.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateRecurringStartDay.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateRecurringStopMonth.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStopMonth        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateRecurringStopMonth.
112612******************************************************************
112612
112612     MOVE LpUpdateRecurringStopMonth TO lsUpdateRecurringStopMonth.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateRecurringStopMonth.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateRecurringStopDay.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStopDay        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateRecurringStopDay.
112612******************************************************************
112612
112612     MOVE LpUpdateRecurringStopDay TO lsUpdateRecurringStopDay.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateRecurringStopDay.


112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateAlternateNameID.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateAlternateNameID        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateAlternateNameID.
112612******************************************************************
112612
112612     MOVE LpUpdateAlternateNameID TO lsUpdateAlternateNameID.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateAlternateNameID.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. getUpdateBadAddressInd.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateBadAddressInd        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION RETURNING lsUpdateBadAddressInd.
112612******************************************************************
112612
112612     SET lsUpdateBadAddressInd TO LpUpdateBadAddressInd.
112612
112612     EXIT METHOD.
112612
112612 END METHOD getUpdateBadAddressInd.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

      ******************************************************************
      *  Set methods 
      ******************************************************************
       METHOD-ID. setUpdateQueryFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateQueryFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateQueryFlag.
      ******************************************************************

           SET wsUpdateQueryFlag TO lsUpdateQueryFlag.

           EXIT METHOD.

       END METHOD setUpdateQueryFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setNameID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsNameID.
      ******************************************************************

011116*    IF wsCompanyCode > '00'
011116*    AND wsPolicyNumber > '00'
011116*        MOVE LpUpdateNameId TO lsNameID
011116*    ELSE
011116     IF lsNameID > 0
               MOVE lsNameID TO wsNameID
011116                          LpUpdateNameId
011116     ELSE
011116         MOVE LpUpdateNameId TO lsNameID
011116     END-IF

           EXIT METHOD.

       END METHOD setNameID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
011116
011116 METHOD-ID. setCompanyCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsCompanyCode  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsCompanyCode.
011116******************************************************************
011116
011116     SET wsCompanyCode TO lsCompanyCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD setCompanyCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setPolicyNumber.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsPolicyNumber  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsPolicyNumber.
011116******************************************************************
011116
011116      SET wsPolicyNumber To lsPolicyNumber
011116
011116     EXIT METHOD.
011116
011116 END METHOD setPolicyNumber.
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116
011116 METHOD-ID. setRelateCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsRelateCode  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsRelateCode.
011116******************************************************************
011116
011116*     IF wsRelateCode > " "
011116*     AND wsRelateCode NOT = lsRelateCode
011116*         MOVE ZEROES TO wsNameId 
011116*                        LpUpdateNameId
011116*     END-IF
011116      SET wsRelateCode TO lsRelateCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD setRelateCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setInAddressType.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsInAddressType  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsInAddressType.
011116******************************************************************
011116
011116      SET wsInAddressType TO lsInAddressType
011116
011116     EXIT METHOD.
011116
011116 END METHOD setInAddressType.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setInAddressCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsInAddressCode  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsInAddressCode.
011116******************************************************************
011116
011116      SET wsInAddressCode TO lsInAddressCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD setInAddressCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setUpdateIndicator.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsUpdateIndicator  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsUpdateIndicator.
011116******************************************************************
011116
011116      SET wsUpdateIndicator TO lsUpdateIndicator
011116
011116     EXIT METHOD.
011116
011116 END METHOD setUpdateIndicator.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setUpdateNameId.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsUpdateNameId PIC S9(09) COMP-5.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsUpdateNameId.
011116******************************************************************
011116
011116      MOVE lsUpdateNameId TO LpUpdateNameId
011116
011116     EXIT METHOD.
011116
011116 END METHOD setUpdateNameId.
011116*
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
011116 METHOD-ID. setRelationshipCode.
011116 DATA DIVISION.
011116******************************************************************
011116 WORKING-STORAGE SECTION.
011116******************************************************************
011116 LINKAGE SECTION.
011116
011116 01  lsRelationshipCode  USAGE OBJECT REFERENCE CLASS-STRING.
011116******************************************************************
011116 PROCEDURE DIVISION USING BY VALUE lsRelationshipCode.
011116******************************************************************
011116
011116      SET lpRelationshipCode TO lsRelationshipCode
011116
011116     EXIT METHOD.
011116
011116 END METHOD setRelationshipCode.
011116
011116******************************************************************
011116*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
011116******************************************************************
       METHOD-ID. setAddressID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressID.
      ******************************************************************

102813*    The set of an output item (lpaddressID) is not used anymore. 
102813*    MOVE lsAddressID TO LpAddressID.  
102813     MOVE lsAddressID to wsAddressID.

           EXIT METHOD.

       END METHOD setAddressID.
102813******************************************************************
102813*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102813******************************************************************
102813
102813 METHOD-ID. setAddressCode.
102813 DATA DIVISION.
102813******************************************************************
102813 WORKING-STORAGE SECTION.
102813******************************************************************
102813 LINKAGE SECTION.
102813
102813 01  lsAddressCode  USAGE OBJECT REFERENCE CLASS-STRING.
102813******************************************************************
102813 PROCEDURE DIVISION USING BY VALUE lsAddressCode.
102813******************************************************************
102813
102813     SET wsAddressCode to lsAddressCode.
102813
102813     EXIT METHOD.
102813
102813 END METHOD setAddressCode.

102813******************************************************************
102813*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102813******************************************************************
102813
102813 METHOD-ID. setEffectiveDate.
102813 DATA DIVISION.
102813******************************************************************
102813 WORKING-STORAGE SECTION.
102813******************************************************************
102813 LINKAGE SECTION.
102813
102813 01  lsEffectiveDate        PIC S9(09) COMP-5.
102813******************************************************************
102813 PROCEDURE DIVISION USING BY VALUE lsEffectiveDate.
102813******************************************************************
102813
102813     MOVE lsEffectiveDate to wsEffectiveDate.
102813
102813     EXIT METHOD.
102813
102813 END METHOD setEffectiveDate.

102813******************************************************************
102813*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102813******************************************************************
102813
102813 METHOD-ID. setIdentifyingNumber.
102813 DATA DIVISION.
102813******************************************************************
102813 WORKING-STORAGE SECTION.
102813******************************************************************
102813 LINKAGE SECTION.
102813
102813 01  lsIdentifyingNumber USAGE OBJECT REFERENCE CLASS-STRING.
102813******************************************************************
102813 PROCEDURE DIVISION USING BY VALUE lsIdentifyingNumber.
102813******************************************************************
102813
102813     SET wsIdentifyingNumber to lsIdentifyingNumber.
102813
102813     EXIT METHOD.
102813
102813 END METHOD setIdentifyingNumber.
102813
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setCancelDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsCancelDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsCancelDate.
      ******************************************************************

           MOVE lsCancelDate TO LpCancelDate.

           EXIT METHOD.

       END METHOD setCancelDate.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setRecurringStartMonth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStartMonth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsRecurringStartMonth.
      ******************************************************************

           MOVE lsRecurringStartMonth TO LpRecurringStartMonth.

           EXIT METHOD.

       END METHOD setRecurringStartMonth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setRecurringStartDay.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStartDay        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsRecurringStartDay.
      ******************************************************************

           MOVE lsRecurringStartDay TO LpRecurringStartDay.

           EXIT METHOD.

       END METHOD setRecurringStartDay.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setRecurringStopMonth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStopMonth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsRecurringStopMonth.
      ******************************************************************

           MOVE lsRecurringStopMonth TO LpRecurringStopMonth.

           EXIT METHOD.

       END METHOD setRecurringStopMonth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setRecurringStopDay.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsRecurringStopDay        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsRecurringStopDay.
      ******************************************************************

           MOVE lsRecurringStopDay TO LpRecurringStopDay.

           EXIT METHOD.

       END METHOD setRecurringStopDay.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAlternateNameID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAlternateNameID        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAlternateNameID.
      ******************************************************************

           MOVE lsAlternateNameID TO LpAlternateNameID.

           EXIT METHOD.

       END METHOD setAlternateNameID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setPhoneNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsPhoneNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsPhoneNumber.
      ******************************************************************

           MOVE lsPhoneNumber TO LpPhoneNumber.

           EXIT METHOD.

       END METHOD setPhoneNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFaxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsFaxNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFaxNumber.
      ******************************************************************

           MOVE lsFaxNumber TO LpFaxNumber.

           EXIT METHOD.

       END METHOD setFaxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
022312*
022312 METHOD-ID. setCellPhoneNumber.
022312 DATA DIVISION.
022312******************************************************************
022312 WORKING-STORAGE SECTION.
022312******************************************************************
022312 LINKAGE SECTION.
022312
022312 01  lsCellPhoneNumber        PIC S9(18) COMP-5.
022312******************************************************************
022312 PROCEDURE DIVISION USING BY VALUE lsCellPhoneNumber.
022312******************************************************************
022312
022312     MOVE lsCellPhoneNumber TO LpCellPhoneNumber.
022312
022312     EXIT METHOD.
022312
022312 END METHOD setCellPhoneNumber.
022312******************************************************************
022312*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022312******************************************************************      

       METHOD-ID. setAddressType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressType        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressType.
      ******************************************************************

           SET LpAddressType TO lsAddressType.

           EXIT METHOD.

       END METHOD setAddressType.
102813******************************************************************
102813*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
102813******************************************************************
102813*
102813*METHOD-ID. setAddressCode.
102813*DATA DIVISION.
102813******************************************************************
102813*WORKING-STORAGE SECTION.
102813******************************************************************
102813*LINKAGE SECTION.
102813*
102813*01  lsAddressCode        OBJECT REFERENCE CLASS-STRING.
102813******************************************************************
102813*PROCEDURE DIVISION USING BY VALUE lsAddressCode.
102813******************************************************************
102813*
102813*    SET LpAddressCode TO lsAddressCode.
102813*
102813*    EXIT METHOD.
102813*
102813*END METHOD setAddressCode.

022312******************************************************************
022312*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022312******************************************************************      

112612 METHOD-ID. setBadAddressInd.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsBadAddressInd        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsBadAddressInd.
112612******************************************************************
112612
112612     SET LpBadAddressInd TO lsBadAddressInd.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setBadAddressInd.

      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressLine1.
      ******************************************************************

           SET LpAddressLine1 TO lsAddressLine1.

           EXIT METHOD.

       END METHOD setAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressLine2.
      ******************************************************************

           SET LpAddressLine2 TO lsAddressLine2.

           EXIT METHOD.

       END METHOD setAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressLine3.
      ******************************************************************

           SET LpAddressLine3 TO lsAddressLine3.

           EXIT METHOD.

       END METHOD setAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressCity.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCity        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressCity.
      ******************************************************************

           SET LpAddressCity TO lsAddressCity.

           EXIT METHOD.

       END METHOD setAddressCity.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressState.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressState        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressState.
      ******************************************************************

           SET LpAddressState TO lsAddressState.

           EXIT METHOD.

       END METHOD setAddressState.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressZipCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressZipCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressZipCode.
      ******************************************************************

           SET LpAddressZipCode TO lsAddressZipCode.

           EXIT METHOD.

       END METHOD setAddressZipCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressBoxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressBoxNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressBoxNumber.
      ******************************************************************

           SET LpAddressBoxNumber TO lsAddressBoxNumber.

           EXIT METHOD.

       END METHOD setAddressBoxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressZipExtension.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressZipExtension        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressZipExtension.
      ******************************************************************

           SET LpAddressZipExtension TO lsAddressZipExtension.

           EXIT METHOD.

       END METHOD setAddressZipExtension.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressCountry.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCountry        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressCountry.
      ******************************************************************

           SET LpAddressCountry TO lsAddressCountry.

           EXIT METHOD.

       END METHOD setAddressCountry.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressCounty.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCounty        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressCounty.
      ******************************************************************

           SET LpAddressCounty TO lsAddressCounty.

           EXIT METHOD.

       END METHOD setAddressCounty.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressCountyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCountyCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressCountyCode.
      ******************************************************************

           SET LpAddressCountyCode TO lsAddressCountyCode.

           EXIT METHOD.

       END METHOD setAddressCountyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setAddressCityCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsAddressCityCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsAddressCityCode.
      ******************************************************************

           SET LpAddressCityCode TO lsAddressCityCode.

           EXIT METHOD.

       END METHOD setAddressCityCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFormatAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFormatAddressLine1.
      ******************************************************************

           SET LpFormatAddressLine1 TO lsFormatAddressLine1.

           EXIT METHOD.

       END METHOD setFormatAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFormatAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFormatAddressLine2.
      ******************************************************************

           SET LpFormatAddressLine2 TO lsFormatAddressLine2.

           EXIT METHOD.

       END METHOD setFormatAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFormatAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFormatAddressLine3.
      ******************************************************************

           SET LpFormatAddressLine3 TO lsFormatAddressLine3.

           EXIT METHOD.

       END METHOD setFormatAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFormatAddressLine4.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatAddressLine4        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFormatAddressLine4.
      ******************************************************************

           SET LpFormatAddressLine4 TO lsFormatAddressLine4.

           EXIT METHOD.

       END METHOD setFormatAddressLine4.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdatePhoneNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsUpdatePhoneNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdatePhoneNumber.
      ******************************************************************

           MOVE lsUpdatePhoneNumber TO LpUpdatePhoneNumber.

           EXIT METHOD.

       END METHOD setUpdatePhoneNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateFaxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

012805 01  lsUpdateFaxNumber        PIC S9(18) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateFaxNumber.
      ******************************************************************

           MOVE lsUpdateFaxNumber TO LpUpdateFaxNumber.

           EXIT METHOD.

       END METHOD setUpdateFaxNumber.
022312******************************************************************
022312*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
022312******************************************************************
022312
022312 METHOD-ID. setUpdateCellPhoneNumber.
022312 DATA DIVISION.
022312******************************************************************
022312 WORKING-STORAGE SECTION.
022312******************************************************************
022312 LINKAGE SECTION.
022312
022312 01  lsUpdateCellPhoneNumber        PIC S9(18) COMP-5.
022312******************************************************************
022312 PROCEDURE DIVISION USING BY VALUE lsUpdateCellPhoneNumber.
022312******************************************************************
022312
022312     MOVE lsUpdateCellPhoneNumber TO LpUpdateCellPhoneNumber.
022312
022312     EXIT METHOD.
022312
022312 END METHOD setUpdateCellPhoneNumber.
032411******************************************************************
032411*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
032411******************************************************************
032411
032411 METHOD-ID. setUpdateAddressType.
032411 DATA DIVISION.
032411******************************************************************
032411 WORKING-STORAGE SECTION.
032411******************************************************************
032411 LINKAGE SECTION.
032411
032411 01  lsUpdateAddressType        OBJECT REFERENCE CLASS-STRING.
032411******************************************************************
032411 PROCEDURE DIVISION USING BY VALUE lsUpdateAddressType.
032411******************************************************************
032411
032411     SET LpUpdateAddressType TO lsUpdateAddressType.
032411
032411     EXIT METHOD.
032411
032411 END METHOD setUpdateAddressType.

112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateAddressCode.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateAddressCode        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCode.
112612******************************************************************
112612
112612     SET LpUpdateAddressCode TO lsUpdateAddressCode.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateAddressCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressLine1.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine1        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressLine1.
      ******************************************************************

           SET LpUpdateAddressLine1 TO lsUpdateAddressLine1.

           EXIT METHOD.

       END METHOD setUpdateAddressLine1.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressLine2.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine2        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressLine2.
      ******************************************************************

           SET LpUpdateAddressLine2 TO lsUpdateAddressLine2.

           EXIT METHOD.

       END METHOD setUpdateAddressLine2.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressLine3.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressLine3        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressLine3.
      ******************************************************************

           SET LpUpdateAddressLine3 TO lsUpdateAddressLine3.

           EXIT METHOD.

       END METHOD setUpdateAddressLine3.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressCity.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCity        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCity.
      ******************************************************************

           SET LpUpdateAddressCity TO lsUpdateAddressCity.

           EXIT METHOD.

       END METHOD setUpdateAddressCity.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressState.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressState        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressState.
      ******************************************************************

           SET LpUpdateAddressState TO lsUpdateAddressState.

           EXIT METHOD.

       END METHOD setUpdateAddressState.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressZipCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressZipCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressZipCode.
      ******************************************************************

           SET LpUpdateAddressZipCode TO lsUpdateAddressZipCode.

           EXIT METHOD.

       END METHOD setUpdateAddressZipCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressBoxNumber.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressBoxNumber        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressBoxNumber.
      ******************************************************************

           SET LpUpdateAddressBoxNumber TO lsUpdateAddressBoxNumber.

           EXIT METHOD.

       END METHOD setUpdateAddressBoxNumber.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressZipExtension.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressZipExtension   OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressZipExtension.
      ******************************************************************

           SET LpUpdateAddressZipExtension
                        TO lsUpdateAddressZipExtension.

           EXIT METHOD.

       END METHOD setUpdateAddressZipExtension.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressCountry.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCountry        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCountry.
      ******************************************************************

           SET LpUpdateAddressCountry TO lsUpdateAddressCountry.

           EXIT METHOD.

       END METHOD setUpdateAddressCountry.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressCounty.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCounty        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCounty.
      ******************************************************************

           SET LpUpdateAddressCounty TO lsUpdateAddressCounty.

           EXIT METHOD.

       END METHOD setUpdateAddressCounty.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressCountyCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCountyCode   OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCountyCode.
      ******************************************************************

           SET LpUpdateAddressCountyCode TO lsUpdateAddressCountyCode.

           EXIT METHOD.

       END METHOD setUpdateAddressCountyCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateAddressCityCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateAddressCityCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateAddressCityCode.
      ******************************************************************

           SET LpUpdateAddressCityCode TO lsUpdateAddressCityCode.

           EXIT METHOD.

       END METHOD setUpdateAddressCityCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

112612 METHOD-ID. setUpdateCancelDate.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateCancelDate        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateCancelDate.
112612******************************************************************
112612
112612     MOVE lsUpdateCancelDate TO LpUpdateCancelDate.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateCancelDAte.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateEffectiveDate.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateEffectiveDate        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateEffectiveDate.
112612******************************************************************
112612
112612     MOVE lsUpdateEffectiveDate TO LpUpdateEffectiveDate.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateEffectiveDate.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

112612 METHOD-ID. setUpdateRecurringStartMonth.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStartMonth        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateRecurringStartMonth.
112612******************************************************************
112612
112612     MOVE lsUpdateRecurringStartMonth
112612                              TO LpUpdateRecurringStartMonth.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateRecurringStartMonth.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateRecurringStartDay.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStartDay        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateRecurringStartDay.
112612******************************************************************
112612
112612     MOVE lsUpdateRecurringStartDay TO LpUpdateRecurringStartDay.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateRecurringStartDay.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateRecurringStopMonth.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStopMonth        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateRecurringStopMonth.
112612******************************************************************
112612
112612     MOVE lsUpdateRecurringStopMonth TO LpUpdateRecurringStopMonth.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateRecurringStopMonth.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateRecurringStopDay.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateRecurringStopDay        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateRecurringStopDay.
112612******************************************************************
112612
112612     MOVE lsUpdateRecurringStopDay TO LpUpdateRecurringStopDay.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateRecurringStopDay.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateAlternateNameID.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateAlternateNameID        PIC S9(09) COMP-5.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateAlternateNameID.
112612******************************************************************
112612
112612     MOVE lsUpdateAlternateNameID TO LpUpdateAlternateNameID.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateAlternateNameID.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612 METHOD-ID. setUpdateBadAddressInd.
112612 DATA DIVISION.
112612******************************************************************
112612 WORKING-STORAGE SECTION.
112612******************************************************************
112612 LINKAGE SECTION.
112612
112612 01  lsUpdateBadAddressInd        OBJECT REFERENCE CLASS-STRING.
112612******************************************************************
112612 PROCEDURE DIVISION USING BY VALUE lsUpdateBadAddressInd.
112612******************************************************************
112612
112612     SET LpUpdateBadAddressInd TO lsUpdateBadAddressInd.
112612
112612     EXIT METHOD.
112612
112612 END METHOD setUpdateBadAddressInd.
112612******************************************************************
112612*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
112612******************************************************************
112612
112612  END OBJECT.
112612  END CLASS OADDRAPI.

