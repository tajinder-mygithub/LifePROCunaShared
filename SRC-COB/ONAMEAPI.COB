       IDENTIFICATION DIVISION.
       CLASS-ID. ONAMEAPI AS "LPNETAPI.ONAMEAPI".
022703*AUTHOR.         PDMA.
022703*DATE-WRITTEN.   March 2002.
022703*DATE-COMPILED.
      *@**20170101*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2017 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20170101*******************************************

      *D****************************************************************
      *D                 PROGRAM DESCRIPTION
      *D****************************************************************
      *D
      *D BAPI object that gets and changes LifePRO name information
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
083004*H 20040708-001-01 DAR Fixed udpate logic. 
060906*H 20051117-002-01 DAR Used spaces for return message instead of low-values. 
032907*H 20070329-004-01 DAR Increase WGLOB length.
061008*H 20080528-001-01 JWS Modify to handle long names
092308*H 20080402-003-01 JWS COBOL .NET conversion revisions.  
021709*H 20090216-005-01 JWS Added error handling
110711*H 20100408-004-01 DAR Added line breaks to allow fixed len compiles
062816*H 20151221-010-01 SAP Added field Foreign Tax ID
010217*H 20161201-003-01 ABH Added field Personal and Business Emails.      
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
092308     05  PNAMEBOX           PIC X(08) VALUE 'PNAMEBOX'.
092308     05  PNADRBOX           PIC X(08) VALUE 'PNADRBOX'.
092308     05  PFILEBTV           PIC X(08) VALUE 'PFILEBTV'.

           COPY WGLOBCPY.
           COPY WGLBXCPY.
           COPY WNAMEBOX.
           COPY WNAMECPY.
061008     COPY WAPPLCPY.
061008     COPY WBTRVCPY.

       01  wsNameReadFlag              PIC X(01)       VALUE 'N'.
           88  wsNameWasRead                           VALUE 'Y'.
           88  wsNameNotRead                           VALUE 'N'.

      ******************************************************************
      * Object Properties
      ******************************************************************

      * input

      * *** Set the following flag to determine which action you want
      * *** to perform.  The default is a Query.
      *
      *    Q - Query
      *    U - Update

       01  wsUpdateQueryFlag           PIC X(01).

       01  wsNameID                    PIC 9(08).

      * output

      * Name Type is 'I' for an individual Name and 'B' for a business.

       01  LpNameType                  PIC X(01).

       01  LpReturnCode                PIC S9(09) COMP-5.
       01  LpErrorMessage              PIC X(200).

      * Individual name fields.

061008* 01  LpIndividualPrefix          PIC X(06).
061008 01  LpIndividualPrefix          PIC X(30).
       01  LpIndividualFirstName       PIC X(20).
       01  LpIndividualMiddleName      PIC X(10).
061008* 01  LpIndividualLastName        PIC X(20).
061008 01  LpIndividualLastName        PIC X(40).
       01  LpIndividualSuffix          PIC X(06).
061008* 01  LpIndividualReverse         PIC X(50).
061008 01  LpIndividualReverse         PIC X(70).
       01  LpIndividualSSN             PIC 9(09).

      * Business name fields.

061008* 01  LpBusinessPrefix            PIC X(06).
061008 01  LpBusinessPrefix            PIC X(30).
061008* 01  LpBusinessName              PIC X(50).
061008 01  LpBusinessName              PIC X(70).
       01  LpBusinessSuffix            PIC X(06).
       01  LpBusinessTaxID             PIC X(09).

      * Other name fields.

061008* 01  LpFormatName                PIC X(50).
061008 01  LpFormatName                PIC X(70).
       01  LpNameDateOfBirth           PIC 9(08).
       01  LpNameGender                PIC X(01).
062816 01  LpForeignTaxID              PIC X(22).
010217 01  LpPersonalEmail             PIC X(256).
010217 01  LpBusinessEmail             PIC X(256).       

      * LpTaxStatus values:
      *    I - Individual
      *    C - Corporation
      *    P - Partnership

       01  LpTaxStatus                 PIC X(01).
       01  LpDeceasedFlag              PIC X(01).
       01  LpDateOfDeath               PIC 9(08).

      * LpTaxWithholdingFlag values:
      *    N - No Exceptions
      *    E - Exxemption
      *    C - Withholding
      *    O - Owner Notify
      *    A - Non-resident alien
      *    1 - Backup Notice
      *    W - New W9
      *    2 - 2 Backups

       01  LpTaxWithholdingFlag        PIC X(01).

      * LpTaxCertificationCode values:
      *    Y - Certified
      *    N - Not Certified
      *    X - Certified No Withholding

       01  LpTaxCertificationCode      PIC X(01).
       01  LpTaxCertificationDate      PIC 9(09).

      * Update Name Fields.  Fill these fields with the new name field
      * values for Name Update.

      * Individual name fields.

061008* 01  LpUpdateIndividualPrefix    PIC X(06).
061008 01  LpUpdateIndividualPrefix    PIC X(30).
       01  LpUpdateIndividualFirstName PIC X(20).
       01  LpUpdateIndividualMiddleName
                                       PIC X(10).
061008* 01  LpUpdateIndividualLastName  PIC X(20).
061008 01  LpUpdateIndividualLastName  PIC X(40).
       01  LpUpdateIndividualSuffix    PIC X(06).
       01  LpUpdateIndividualSSN       PIC 9(09).

      * Business name fields.

061008* 01  LpUpdateBusinessPrefix      PIC X(06).
061008 01  LpUpdateBusinessPrefix      PIC X(30).
061008* 01  LpUpdateBusinessName        PIC X(50).
061008 01  LpUpdateBusinessName        PIC X(70).
       01  LpUpdateBusinessSuffix      PIC X(06).
       01  LpUpdateBusinessTaxID       PIC X(09).

       01  LpUpdateNameDateOfBirth     PIC 9(08).
       01  LpUpdateNameGender          PIC X(01).
062816 01  LpUpdateForeignTaxID        PIC X(22).
010217 01  LpUpdatePersonalEmail       PIC X(256).
010217 01  LpUpdateBusinessEmail       PIC X(256).       

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
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. RunNameFunction.
      ******************************************************************
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.

           COPY WNADRCPY.
           COPY WPGLBCPY.
061008     COPY WOPTNCPY.

       01  WS-PNADRBOX-OPTION          PIC X(01).
061008 01  WS-EXTENDED-NAME-FLAG       PIC X(01).
061008     88  WS-EXTENDED-NAME                        VALUE 'Y'.
061008     88  WS-NOT-EXTENDED-NAME                    VALUE 'N'.

       01 wsNameChangedFlag            PIC X(01).
           88  wsNameChanged                           VALUE 'Y'.
           88  wsNameNotChanged                        VALUE 'N'.

      ******************************************************************
       LINKAGE SECTION.


       01  lsReturnCode                PIC S9(09) COMP-5.

      ******************************************************************
       PROCEDURE DIVISION RETURNING lsReturnCode.
      ******************************************************************
           IF wsUpdateQueryFlag = 'U'
               PERFORM 1000-NAME-UPDATE
           ELSE
               PERFORM 2000-NAME-QUERY
           END-IF.
           MOVE 'Q' TO wsUpdateQueryFlag.

           EXIT METHOD.
      ******************************************************************
       1000-NAME-UPDATE.

           SET wsNameNotChanged TO TRUE.

021709     TRY
             IF wsNameWasRead
             AND wsNameID = WNAME-NAME-ID
               IF WNAME-BUSINESS-FORMAT
061008             IF WS-EXTENDED-NAME
061008                 IF LpUpdateBusinessPrefix
061008                     NOT = WNAME-BUSINESS-LONG-PREFIX
061008                     MOVE LpUpdateBusinessPrefix
061008                         TO WNAME-BUSINESS-LONG-PREFIX
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateBusinessName
061008                     NOT = WNAME-BUSINESS-LONG-NAME
061008                     MOVE LpUpdateBusinessName
061008                         TO WNAME-BUSINESS-LONG-NAME
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateBusinessSuffix
061008                     NOT = WNAME-BUSINESS-LONG-SUFFIX
061008                     MOVE LpUpdateBusinessSuffix
061008                         TO WNAME-BUSINESS-LONG-SUFFIX
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008             ELSE
061008*                 IF LpUpdateBusinessPrefix NOT = WNAME-BUSINESS-PREFIX
061008                 IF LpUpdateBusinessPrefix
061008                     NOT = WNAME-BUSINESS-PREFIX
                           MOVE LpUpdateBusinessPrefix
                               TO WNAME-BUSINESS-PREFIX
                           SET wsNameChanged TO TRUE
                       END-IF
061008*                 IF LpUpdateBusinessName NOT = WNAME-BUSINESS-NAME
061008                 IF LpUpdateBusinessName
061008                     NOT = WNAME-BUSINESS-NAME
                           MOVE LpUpdateBusinessName
                               TO WNAME-BUSINESS-NAME
                           SET wsNameChanged TO TRUE
                       END-IF
061008*                 IF LpUpdateBusinessSuffix NOT = WNAME-BUSINESS-SUFFIX
061008                 IF LpUpdateBusinessSuffix
061008                     NOT = WNAME-BUSINESS-SUFFIX
                           MOVE LpUpdateBusinessSuffix
                               TO WNAME-BUSINESS-SUFFIX
                           SET wsNameChanged TO TRUE
                       END-IF
061008             END-IF
                   IF LpUpdateBusinessTaxID
                       NOT = WNAME-BUSINESS-TAX-CODE
                       MOVE LpUpdateBusinessTaxID
                           TO WNAME-BUSINESS-TAX-CODE
                       SET wsNameChanged TO TRUE
                   END-IF
               ELSE
061008             IF WS-EXTENDED-NAME
061008                 IF LpUpdateIndividualPrefix
061008                     NOT = WNAME-INDIVIDUAL-LONG-PREFIX
061008                     MOVE LpUpdateIndividualPrefix
061008                         TO WNAME-INDIVIDUAL-LONG-PREFIX
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateIndividualLastName
061008                     NOT = WNAME-INDIVIDUAL-LONG-LAST
061008                     MOVE LpUpdateIndividualLastName
061008                         TO WNAME-INDIVIDUAL-LONG-LAST
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateIndividualFirstName
061008                     NOT = WNAME-INDIVIDUAL-LONG-FIRST
061008                     MOVE LpUpdateIndividualFirstName
061008                         TO WNAME-INDIVIDUAL-LONG-FIRST
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateIndividualMiddleName
061008                     NOT = WNAME-INDIVIDUAL-LONG-MIDDLE
061008                     MOVE LpUpdateIndividualMiddleName
061008                         TO WNAME-INDIVIDUAL-LONG-MIDDLE
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008                 IF LpUpdateIndividualSuffix
061008                     NOT = WNAME-INDIVIDUAL-LONG-SUFFIX
061008                     MOVE LpUpdateIndividualSuffix
061008                         TO WNAME-INDIVIDUAL-LONG-SUFFIX
061008                     SET wsNameChanged TO TRUE
061008                 END-IF
061008             ELSE
                       IF LpUpdateIndividualPrefix
                           NOT = WNAME-INDIVIDUAL-PREFIX
                           MOVE LpUpdateIndividualPrefix
                               TO WNAME-INDIVIDUAL-PREFIX
                           SET wsNameChanged TO TRUE
                       END-IF
                       IF LpUpdateIndividualLastName
                           NOT = WNAME-INDIVIDUAL-LAST
                           MOVE LpUpdateIndividualLastName
                               TO WNAME-INDIVIDUAL-LAST
                           SET wsNameChanged TO TRUE
                       END-IF
                       IF LpUpdateIndividualFirstName
                           NOT = WNAME-INDIVIDUAL-FIRST
                           MOVE LpUpdateIndividualFirstName
                               TO WNAME-INDIVIDUAL-FIRST
                           SET wsNameChanged TO TRUE
                       END-IF
                       IF LpUpdateIndividualMiddleName
                           NOT = WNAME-INDIVIDUAL-MIDDLE
                           MOVE LpUpdateIndividualMiddleName
                               TO WNAME-INDIVIDUAL-MIDDLE
                           SET wsNameChanged TO TRUE
                       END-IF
                       IF LpUpdateIndividualSuffix
                           NOT = WNAME-INDIVIDUAL-SUFFIX
                           MOVE LpUpdateIndividualSuffix
                               TO WNAME-INDIVIDUAL-SUFFIX
                           SET wsNameChanged TO TRUE
                       END-IF
061008             END-IF
                   IF LpUpdateIndividualSSN NOT = WNAME-SOC-SEC-NUMBER
                       MOVE LpUpdateIndividualSSN
                           TO WNAME-SOC-SEC-NUMBER
                       SET wsNameChanged TO TRUE
                   END-IF
               END-IF
               IF LpUpdateNameDateOfBirth NOT = WNAME-DATE-OF-BIRTH
                   MOVE LpUpdateNameDateOfBirth
                       TO WNAME-DATE-OF-BIRTH
                   SET wsNameChanged TO TRUE
               END-IF
               IF LpUpdateNameGender NOT = WNAME-SEX-CODE
                   MOVE LpUpdateNameGender TO WNAME-SEX-CODE
                   SET wsNameChanged TO TRUE
               END-IF
062816         IF LpUpdateForeignTaxID NOT = WNAME-FOREIGN-TAX-ID
062816             MOVE LpUpdateForeignTaxID TO WNAME-FOREIGN-TAX-ID
062816             SET wsNameChanged TO TRUE
062816         END-IF
010217         IF LpUpdatePersonalEmail NOT = WNAME-PERSONAL-EMAIL-ADR
010217            MOVE LpUpdatePersonalEmail TO WNAME-PERSONAL-EMAIL-ADR
010217            SET wsNameChanged TO TRUE
010217         END-IF  
010217         IF LpUpdateBusinessEmail NOT = WNAME-BUSINESS-EMAIL-ADR
010217            MOVE LpUpdateBusinessEmail TO WNAME-BUSINESS-EMAIL-ADR
010217            SET wsNameChanged TO TRUE
010217         END-IF                            
               IF wsNameChanged
                   MOVE wsNameID TO WNAMEBOX-NAME-ID
                   SET WNAMEBOX-UPDATE TO TRUE
      *            MOVE 'N' TO WGLOB-FILES-READ
      *            MOVE SPACES TO WFILE,
      *                   WGLOB-PFILEIOP-INIT-FLAG

092308             CALL PNAMEBOX USING WGLOBAL
092308                                 WNAMEBOX-PARMS
092308                                 WNAME-DATA-RECORD

                   MOVE WNAMEBOX-RETURN-CODE TO lsReturnCode,
                                                LpReturnCode
                   MOVE WNAMEBOX-MESSAGE TO LpErrorMessage
               END-IF
083004       ELSE
083004         MOVE 'Must Read Name Prior to Update' to LpErrorMessage
083004         MOVE 999 TO lsReturnCode,
083004                     LpReturnCode
021709       END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           CONTINUE.
      ******************************************************************
       2000-NAME-QUERY.

           MOVE SPACES TO LpNameType.
           MOVE SPACES TO LpIndividualPrefix.
           MOVE SPACES TO LpIndividualFirstName.
           MOVE SPACES TO LpIndividualMiddleName.
           MOVE SPACES TO LpIndividualLastName.
           MOVE SPACES TO LpIndividualSuffix.
           MOVE SPACES TO LpIndividualReverse.
           MOVE ZERO TO LpIndividualSSN.
           MOVE SPACES TO LpBusinessPrefix.
           MOVE SPACES TO LpBusinessName.
           MOVE SPACES TO LpBusinessSuffix.
           MOVE SPACES TO LpBusinessTaxID.
           MOVE SPACES TO LpFormatName.
           MOVE ZERO TO LpNameDateOfBirth.
           MOVE SPACES TO LpNameGender.
           MOVE SPACES TO LpTaxStatus.
           MOVE SPACES TO LpDeceasedFlag.
           MOVE ZERO TO LpDateOfDeath.
           MOVE SPACES TO LpTaxWithholdingFlag.
           MOVE SPACES TO LpTaxCertificationCode.
           MOVE ZERO TO LpTaxCertificationDate.
062816     MOVE SPACES TO LpForeignTaxID.
010217     MOVE SPACES TO LpPersonalEmail.
010217     MOVE SPACES TO LpBusinessEmail.                      

           MOVE wsNameID TO WNAMEBOX-NAME-ID.
           SET WNAMEBOX-READ TO TRUE.
      *    MOVE 'N' TO WGLOB-FILES-READ
      *    MOVE SPACES TO WFILE,
      *                   WGLOB-PFILEIOP-INIT-FLAG

021709     TRY
092308       CALL PNAMEBOX USING WGLOBAL
092308                           WNAMEBOX-PARMS
092308                           WNAME-DATA-RECORD
             MOVE WNAMEBOX-RETURN-CODE TO lsReturnCode,
021709                                    LpReturnCode
021709       MOVE WNAMEBOX-MESSAGE TO LpErrorMessage
             IF WNAMEBOX-PROCESSING-OK
               SET wsNameWasRead TO TRUE
061008         MOVE 'N'                    TO WS-EXTENDED-NAME-FLAG
061008         MOVE 'ADDREDITS '           TO WOPTN-TYPE-KEY
061008         MOVE ZEROES                 TO WAPPL-KEY-NUMBER
061008                                        WOPTN-COMPANY-CODE
061008         MOVE WBTRV-GET-EQUAL        TO WAPPL-FUNCTION
061008         MOVE WFILE-OPTN-NUM         TO DATA-FILE-NUMBER
061008         MOVE WOPTN-DATA-RECORD      TO DATA-AREA
092308         CALL PFILEBTV USING WGLOBAL
092308                             WAPPL-CALL-PARAMETERS
092308                             WBTRIEVE
061008         IF WAPPL-RETURN-NOT-OK
061008             CONTINUE
061008         ELSE
061008             MOVE DATA-AREA          TO WOPTN-DATA-RECORD
061008             MOVE WOPTN-NAME-EXTENDED-FLAG
061008                                     TO WS-EXTENDED-NAME-FLAG
061008         END-IF
               MOVE WNAME-NAME-FORMAT-CODE TO LpNameType
               MOVE WNAME-NAME-FORMAT-CODE TO WNADR-NAME-FORMAT-CODE
               IF WNAME-INDIVIDUAL-FORMAT
083004*            Also load Update fields so that user does not have to manually load 
083004*            them for fields they do not want to update.
061008*            All restructured to take into account if extended name info applies.
061008             IF WS-EXTENDED-NAME
061008                 MOVE WNAME-INDIVIDUAL-LONG-PREFIX
061008                     TO LpIndividualPrefix,
061008                        LpUpdateIndividualPrefix,
061008                        WNADR-INDIVIDUAL-LONG-PREFIX
061008                 MOVE WNAME-INDIVIDUAL-LONG-FIRST
061008                     TO LpIndividualFirstName,
061008                        LpUpdateIndividualFirstName,
061008                        WNADR-INDIVIDUAL-LONG-FIRST
061008                 MOVE WNAME-INDIVIDUAL-LONG-MIDDLE
061008                     TO LpIndividualMiddleName,
061008                        LpUpdateIndividualMiddleName,
061008                        WNADR-INDIVIDUAL-LONG-MIDDLE
061008                 MOVE WNAME-INDIVIDUAL-LONG-LAST
061008                     TO LpIndividualLastName,
061008                        LpUpdateIndividualLastName,
061008                        WNADR-INDIVIDUAL-LONG-LAST
061008                 MOVE WNAME-INDIVIDUAL-LONG-SUFFIX
061008                     TO LpIndividualSuffix,
061008                        LpUpdateIndividualSuffix,
061008                        WNADR-INDIVIDUAL-LONG-SUFFIX
061008             ELSE
                       MOVE WNAME-INDIVIDUAL-PREFIX
                           TO LpIndividualPrefix,
083004                        LpUpdateIndividualPrefix,
061008                        WNADR-INDIVIDUAL-PREFIX
                       MOVE WNAME-INDIVIDUAL-FIRST
                           TO LpIndividualFirstName,
083004                        LpUpdateIndividualFirstName,
061008                        WNADR-INDIVIDUAL-FIRST
                       MOVE WNAME-INDIVIDUAL-MIDDLE
                           TO LpIndividualMiddleName,
083004                        LpUpdateIndividualMiddleName,
061008                        WNADR-INDIVIDUAL-MIDDLE
                       MOVE WNAME-INDIVIDUAL-LAST
                           TO LpIndividualLastName,
083004                        LpUpdateIndividualLastName,
061008                        WNADR-INDIVIDUAL-LAST
                       MOVE WNAME-INDIVIDUAL-SUFFIX
                           TO LpIndividualSuffix,
083004                        LpUpdateIndividualSuffix,
061008                        WNADR-INDIVIDUAL-SUFFIX
061008             END-IF
                   MOVE WNAME-SOC-SEC-NUMBER TO LpIndividualSSN,
083004                                          LpUpdateIndividualSSN
061008*             MOVE WNAME-INDIVIDUAL-PREFIX
061008*                 TO WNADR-INDIVIDUAL-PREFIX
061008*             MOVE WNAME-INDIVIDUAL-FIRST TO WNADR-INDIVIDUAL-FIRST
061008*             MOVE WNAME-INDIVIDUAL-MIDDLE
061008*                 TO WNADR-INDIVIDUAL-MIDDLE
061008*             MOVE WNAME-INDIVIDUAL-LAST TO WNADR-INDIVIDUAL-LAST
061008*             MOVE WNAME-INDIVIDUAL-SUFFIX
061008*                 TO WNADR-INDIVIDUAL-SUFFIX
               ELSE
061008             IF WS-EXTENDED-NAME
061008                 MOVE WNAME-BUSINESS-LONG-PREFIX
061008                     TO LpBusinessPrefix,
061008                        LpUpdateBusinessPrefix,
061008                        WNADR-BUSINESS-LONG-PREFIX
061008                 MOVE WNAME-BUSINESS-LONG-NAME
061008                     TO LpBusinessName,
061008                        LpUpdateBusinessName,
061008                        WNADR-BUSINESS-LONG-NAME
061008                 MOVE WNAME-BUSINESS-LONG-SUFFIX
061008                     TO LpBusinessSuffix,
061008                        LpUpdateBusinessSuffix,
061008                        WNADR-BUSINESS-LONG-SUFFIX
061008             ELSE
                       MOVE WNAME-BUSINESS-PREFIX
                           TO LpBusinessPrefix,
083004                        LpUpdateBusinessPrefix,
061008                        WNADR-BUSINESS-PREFIX
                       MOVE WNAME-BUSINESS-NAME
                           TO LpBusinessName,
083004                        LpUpdateBusinessName,
061008                        WNADR-BUSINESS-NAME
                       MOVE WNAME-BUSINESS-SUFFIX
                           TO LpBusinessSuffix,
083004                        LpUpdateBusinessSuffix,
061008                        WNADR-BUSINESS-SUFFIX
061008             END-IF
                   MOVE WNAME-BUSINESS-TAX-CODE TO LpBusinessTaxID,
083004                                             LpUpdateBusinessTaxId
061008*             MOVE WNAME-BUSINESS-PREFIX TO WNADR-BUSINESS-PREFIX
061008*             MOVE WNAME-BUSINESS-NAME TO WNADR-BUSINESS-NAME
061008*             MOVE WNAME-BUSINESS-SUFFIX TO WNADR-BUSINESS-SUFFIX
               END-IF
061008         IF WNAME-DATE-OF-BIRTH NUMERIC
061008         AND WNAME-DATE-OF-BIRTH > ZERO
                   MOVE WNAME-DATE-OF-BIRTH TO LpNameDateOfBirth,
083004                                         LpUpdateNameDateOfBirth
061008         ELSE
061008             MOVE ZEROS TO LpNameDateOfBirth,
061008                           LpUpdateNameDateOfBirth
061008         END-IF
               MOVE WNAME-SEX-CODE TO LpNameGender,
083004                                LpUpdateNameGender
               MOVE WNAME-TAX-STATUS TO LpTaxStatus
               MOVE WNAME-DECEASED-FLAG TO LpDeceasedFlag
               MOVE WNAME-DATE-OF-DEATH TO LpDateOfDeath
               MOVE WNAME-TAX-WITHHOLDING-FLAG TO LpTaxWithholdingFlag
               MOVE WNAME-TAX-CERTIFICATION-CODE
                   TO LpTaxCertificationCode
               MOVE WNAME-TAX-CERTIFICATION-DATE
                   TO LpTaxCertificationDate
062816         MOVE WNAME-FOREIGN-TAX-ID     TO LpForeignTaxID
062816                                          LpUpdateForeignTaxID
062816                                          WNADR-FOREIGN-TAX-ID
010217         MOVE WNAME-PERSONAL-EMAIL-ADR TO LpPersonalEmail
010217                                          LpUpdatePersonalEmail
010217                                          WNADR-PERSONAL-EMAIL-ADR
010217         MOVE WNAME-BUSINESS-EMAIL-ADR TO LpBusinessEmail  
010217                                          LpUpdateBusinessEmail
010217                                          WNADR-BUSINESS-EMAIL-ADR                                                                                             

               MOVE '4' TO WS-PNADRBOX-OPTION
               MOVE 'Y' TO LINK-RETURN-NAME
      *        MOVE 'N' TO WGLOB-FILES-READ
      *        MOVE SPACES TO WFILE,
      *                       WGLOB-PFILEIOP-INIT-FLAG

092308         CALL PNADRBOX USING WGLOBAL
092308                             GLOBAL-PARAMETERS
092308                             WNADR-DATA-RECORD
092308                             WS-PNADRBOX-OPTION

               IF LINK-RETURN-STATUS = ZERO
061008             IF WS-EXTENDED-NAME
061008                 MOVE WNADR-LONG-NAME TO LpFormatName
061008             ELSE
061008                 MOVE LINK-BUSINESS TO LpFormatName
061008             END-IF
061008*             IF WNADR-BUSINESS-FORMAT
061008*                 MOVE LINK-BUSINESS TO LpFormatName
061008*             ELSE
061008*                 MOVE LINK-BUSINESS TO LpFormatName
061008             IF WNADR-INDIVIDUAL-FORMAT
                       MOVE 'R' TO LINK-RETURN-NAME

      *                MOVE 'N' TO WGLOB-FILES-READ
      *                MOVE SPACES TO WFILE,
      *                   WGLOB-PFILEIOP-INIT-FLAG

092308                 CALL PNADRBOX USING WGLOBAL
092308                                     GLOBAL-PARAMETERS
092308                                     WNADR-DATA-RECORD
092308                                     WS-PNADRBOX-OPTION

                       IF LINK-RETURN-STATUS = ZERO
061008*                     MOVE LINK-BUSINESS TO LpIndividualReverse
061008                     IF WS-EXTENDED-NAME
061008                         MOVE WNADR-LONG-NAME
061008                             TO LpIndividualReverse
061008                     ELSE
061008                         MOVE LINK-BUSINESS
061008                             TO LpIndividualReverse
061008                     END-IF
                       END-IF
                   END-IF
               END-IF
021709       END-IF
021709     CATCH WS-EXCEPTION
021709         INVOKE LpApp "writeErrorLog" USING WS-EXCEPTION
021709         MOVE 8008 TO lsReturnCode,
021709                      LpReturnCode
021709         MOVE 'Unexpected Abend in API - see Windows Event Log'
021709             TO LpErrorMessage
021709     END-TRY.

           CONTINUE.
      ******************************************************************
       END METHOD RunNameFunction.
      ******************************************************************

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

           EXIT METHOD.

       END METHOD getNameID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNameType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameType        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNameType.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpNameType
                RETURNING lsNameType.

           EXIT METHOD.

       END METHOD getNameType.
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

060906     IF LpErrorMessage = LOW-VALUES
060906         MOVE SPACES TO LpErrorMessage
060906     End-If.
060906
           INVOKE CLASS-STRING "NEW" USING BY VALUE LpErrorMessage
                RETURNING lsErrorMessage.

           EXIT METHOD.

       END METHOD getErrorMessage.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualPrefix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpIndividualPrefix
                RETURNING lsIndividualPrefix.

           EXIT METHOD.

       END METHOD getIndividualPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualFirstName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualFirstName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualFirstName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                 BY VALUE LpIndividualFirstName
                RETURNING lsIndividualFirstName.

           EXIT METHOD.

       END METHOD getIndividualFirstName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualMiddleName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualMiddleName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualMiddleName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpIndividualMiddleName
                RETURNING lsIndividualMiddleName.

           EXIT METHOD.

       END METHOD getIndividualMiddleName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualLastName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualLastName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualLastName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpIndividualLastName
                RETURNING lsIndividualLastName.

           EXIT METHOD.

       END METHOD getIndividualLastName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualSuffix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpIndividualSuffix
                RETURNING lsIndividualSuffix.

           EXIT METHOD.

       END METHOD getIndividualSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualReverse.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualReverse        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualReverse.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpIndividualReverse
                RETURNING lsIndividualReverse.

           EXIT METHOD.

       END METHOD getIndividualReverse.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getIndividualSSN.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualSSN        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsIndividualSSN.
      ******************************************************************

           MOVE LpIndividualSSN TO lsIndividualSSN.

           EXIT METHOD.

       END METHOD getIndividualSSN.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBusinessPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsBusinessPrefix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpBusinessPrefix
                RETURNING lsBusinessPrefix.

           EXIT METHOD.

       END METHOD getBusinessPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBusinessName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsBusinessName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpBusinessName
                RETURNING lsBusinessName.

           EXIT METHOD.

       END METHOD getBusinessName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBusinessSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsBusinessSuffix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpBusinessSuffix
                RETURNING lsBusinessSuffix.

           EXIT METHOD.

       END METHOD getBusinessSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getBusinessTaxID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessTaxID        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsBusinessTaxID.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpBusinessTaxID
                RETURNING lsBusinessTaxID.

           EXIT METHOD.

       END METHOD getBusinessTaxID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getFormatName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsFormatName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpFormatName
                RETURNING lsFormatName.

           EXIT METHOD.

       END METHOD getFormatName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNameDateOfBirth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameDateOfBirth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNameDateOfBirth.
      ******************************************************************

           MOVE LpNameDateOfBirth TO lsNameDateOfBirth.

           EXIT METHOD.

       END METHOD getNameDateOfBirth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getNameGender.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameGender        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsNameGender.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpNameGender
                RETURNING lsNameGender.

           EXIT METHOD.

       END METHOD getNameGender.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTaxStatus.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxStatus        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsTaxStatus.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpTaxStatus
                RETURNING lsTaxStatus.

           EXIT METHOD.

       END METHOD getTaxStatus.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDeceasedFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDeceasedFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsDeceasedFlag.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpDeceasedFlag
                RETURNING lsDeceasedFlag.

           EXIT METHOD.

       END METHOD getDeceasedFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getDateOfDeath.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDateOfDeath        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsDateOfDeath.
      ******************************************************************

           MOVE LpDateOfDeath TO lsDateOfDeath.

           EXIT METHOD.

       END METHOD getDateOfDeath.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTaxWithholdingFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxWithholdingFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsTaxWithholdingFlag.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpTaxWithholdingFlag
                RETURNING lsTaxWithholdingFlag.

           EXIT METHOD.

       END METHOD getTaxWithholdingFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTaxCertificationCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxCertificationCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsTaxCertificationCode.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpTaxCertificationCode
                RETURNING lsTaxCertificationCode.

           EXIT METHOD.

       END METHOD getTaxCertificationCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getTaxCertificationDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxCertificationDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsTaxCertificationDate.
      ******************************************************************

           MOVE LpTaxCertificationDate TO lsTaxCertificationDate.

           EXIT METHOD.

       END METHOD getTaxCertificationDate.
062816******************************************************************
062816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062816******************************************************************
062816
062816 METHOD-ID. getForeignTaxID.
062816 DATA DIVISION.
062816******************************************************************
062816 WORKING-STORAGE SECTION.
062816******************************************************************
062816 LINKAGE SECTION.
062816
062816 01  lsForeignTaxID        OBJECT REFERENCE CLASS-STRING.
062816******************************************************************
062816 PROCEDURE DIVISION RETURNING lsForeignTaxID.
062816******************************************************************
062816
062816     INVOKE CLASS-STRING "NEW" USING
062816          BY VALUE LpForeignTaxID
062816          RETURNING lsForeignTaxID.
062816
062816     EXIT METHOD.
062816
062816 END METHOD getForeignTaxID.
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. getPersonalEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsPersonalEmail        OBJECT REFERENCE CLASS-STRING.      
010217******************************************************************
010217 PROCEDURE DIVISION RETURNING lsPersonalEmail.
010217******************************************************************
010217
010217     INVOKE CLASS-STRING "NEW" USING
010217          BY VALUE LpPersonalEmail
010217          RETURNING lsPersonalEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD getPersonalEmail.       
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. getBusinessEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsBusinessEmail        OBJECT REFERENCE CLASS-STRING.      
010217******************************************************************
010217 PROCEDURE DIVISION RETURNING lsBusinessEmail.
010217******************************************************************
010217
010217     INVOKE CLASS-STRING "NEW" USING
010217          BY VALUE LpBusinessEmail
010217          RETURNING lsBusinessEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD getBusinessEmail.          
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateIndividualPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualPrefix OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateIndividualPrefix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateIndividualPrefix
                RETURNING lsUpdateIndividualPrefix.

           EXIT METHOD.

       END METHOD getUpdateIndividualPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateIndividualFirstName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualFirstName  OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateIndividualFirstName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                          BY VALUE LpUpdateIndividualFirstName
                RETURNING lsUpdateIndividualFirstName.

           EXIT METHOD.

       END METHOD getUpdateIndividualFirstName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
083004 METHOD-ID. getUpdateIndividualMiddleName.
083004 DATA DIVISION.
083004******************************************************************
083004 WORKING-STORAGE SECTION.
083004******************************************************************
083004 LINKAGE SECTION.

083004 01  lsUpdateIndividualMiddleName  OBJECT REFERENCE CLASS-STRING.
083004******************************************************************
083004 PROCEDURE DIVISION RETURNING lsUpdateIndividualMiddleName.
083004******************************************************************

083004     INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateIndividualMiddleName
083004          RETURNING lsUpdateIndividualMiddleName.

083004     EXIT METHOD.

083004 END METHOD getUpdateIndividualMiddleName.
083004******************************************************************
083004*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
083004******************************************************************
       METHOD-ID. getUpdateIndividualLastName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualLastName OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateIndividualLastName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateIndividualLastName
                RETURNING lsUpdateIndividualLastName.

           EXIT METHOD.

       END METHOD getUpdateIndividualLastName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateIndividualSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualSuffix OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateIndividualSuffix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateIndividualSuffix
                RETURNING lsUpdateIndividualSuffix.

           EXIT METHOD.

       END METHOD getUpdateIndividualSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateIndividualSSN.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualSSN        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateIndividualSSN.
      ******************************************************************

           MOVE LpUpdateIndividualSSN TO lsUpdateIndividualSSN.

           EXIT METHOD.

       END METHOD getUpdateIndividualSSN.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateBusinessPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessPrefix OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateBusinessPrefix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateBusinessPrefix
                RETURNING lsUpdateBusinessPrefix.

           EXIT METHOD.

       END METHOD getUpdateBusinessPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateBusinessName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateBusinessName.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateBusinessName
                RETURNING lsUpdateBusinessName.

           EXIT METHOD.

       END METHOD getUpdateBusinessName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateBusinessSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessSuffix OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateBusinessSuffix.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateBusinessSuffix
                RETURNING lsUpdateBusinessSuffix.

           EXIT METHOD.

       END METHOD getUpdateBusinessSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateBusinessTaxID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessTaxID OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateBusinessTaxID.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING
                BY VALUE LpUpdateBusinessTaxID
                RETURNING lsUpdateBusinessTaxID.

           EXIT METHOD.

       END METHOD getUpdateBusinessTaxID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateNameDateOfBirth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateNameDateOfBirth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateNameDateOfBirth.
      ******************************************************************

           MOVE LpUpdateNameDateOfBirth TO lsUpdateNameDateOfBirth.

           EXIT METHOD.

       END METHOD getUpdateNameDateOfBirth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. getUpdateNameGender.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateNameGender        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION RETURNING lsUpdateNameGender.
      ******************************************************************

           INVOKE CLASS-STRING "NEW" USING BY VALUE LpUpdateNameGender
                RETURNING lsUpdateNameGender.

           EXIT METHOD.

       END METHOD getUpdateNameGender.
062816******************************************************************
062816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062816******************************************************************
062816
062816 METHOD-ID. getUpdateForeignTaxID.
062816 DATA DIVISION.
062816******************************************************************
062816 WORKING-STORAGE SECTION.
062816******************************************************************
062816 LINKAGE SECTION.
062816
062816 01  lsUpdateForeignTaxID      OBJECT REFERENCE CLASS-STRING.
062816******************************************************************
062816 PROCEDURE DIVISION RETURNING lsUpdateForeignTaxID.
062816******************************************************************
062816
062816     INVOKE CLASS-STRING "NEW" USING
062816          BY VALUE LpUpdateForeignTaxID
062816          RETURNING lsUpdateForeignTaxID.
062816
062816     EXIT METHOD.
062816
062816 END METHOD getUpdateForeignTaxID.
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. getUpdatePersonalEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsUpdatePersonalEmail        OBJECT REFERENCE CLASS-STRING.      
010217******************************************************************
010217 PROCEDURE DIVISION RETURNING lsUpdatePersonalEmail.
010217******************************************************************
010217
010217     INVOKE CLASS-STRING "NEW" USING
010217          BY VALUE LpUpdatePersonalEmail
010217          RETURNING lsUpdatePersonalEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD getUpdatePersonalEmail.       
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. getUpdateBusinessEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsUpdateBusinessEmail        OBJECT REFERENCE CLASS-STRING.      
010217******************************************************************
010217 PROCEDURE DIVISION RETURNING lsUpdateBusinessEmail.
010217******************************************************************
010217
010217     INVOKE CLASS-STRING "NEW" USING
010217          BY VALUE LpUpdateBusinessEmail
010217          RETURNING lsUpdateBusinessEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD getUpdateBusinessEmail.          
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

      ******************************************************************
      * Set methods.  
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

           MOVE lsNameID TO wsNameID.

           EXIT METHOD.

       END METHOD setNameID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setNameType.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameType        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsNameType.
      ******************************************************************

           SET LpNameType TO lsNameType.

           EXIT METHOD.

       END METHOD setNameType.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************


       METHOD-ID. setIndividualPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualPrefix.
      ******************************************************************

           SET LpIndividualPrefix TO lsIndividualPrefix.

           EXIT METHOD.

       END METHOD setIndividualPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualFirstName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualFirstName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualFirstName.
      ******************************************************************

           SET LpIndividualFirstName TO lsIndividualFirstName.

           EXIT METHOD.

       END METHOD setIndividualFirstName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualMiddleName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualMiddleName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualMiddleName.
      ******************************************************************

           SET LpIndividualMiddleName TO lsIndividualMiddleName.

           EXIT METHOD.

       END METHOD setIndividualMiddleName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualLastName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualLastName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualLastName.
      ******************************************************************

           SET LpIndividualLastName TO lsIndividualLastName.

           EXIT METHOD.

       END METHOD setIndividualLastName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualSuffix.
      ******************************************************************

           SET LpIndividualSuffix TO lsIndividualSuffix.

           EXIT METHOD.

       END METHOD setIndividualSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualReverse.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualReverse        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualReverse.
      ******************************************************************

           SET LpIndividualReverse TO lsIndividualReverse.

           EXIT METHOD.

       END METHOD setIndividualReverse.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setIndividualSSN.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsIndividualSSN        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsIndividualSSN.
      ******************************************************************

           MOVE lsIndividualSSN TO LpIndividualSSN.

           EXIT METHOD.

       END METHOD setIndividualSSN.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setBusinessPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBusinessPrefix.
      ******************************************************************

           SET LpBusinessPrefix TO lsBusinessPrefix.

           EXIT METHOD.

       END METHOD setBusinessPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setBusinessName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBusinessName.
      ******************************************************************

           SET LpBusinessName TO lsBusinessName.

           EXIT METHOD.

       END METHOD setBusinessName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setBusinessSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBusinessSuffix.
      ******************************************************************

           SET LpBusinessSuffix TO lsBusinessSuffix.

           EXIT METHOD.

       END METHOD setBusinessSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setBusinessTaxID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsBusinessTaxID        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsBusinessTaxID.
      ******************************************************************

           SET LpBusinessTaxID TO lsBusinessTaxID.

           EXIT METHOD.

       END METHOD setBusinessTaxID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setFormatName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsFormatName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsFormatName.
      ******************************************************************

           SET LpFormatName TO lsFormatName.

           EXIT METHOD.

       END METHOD setFormatName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setNameDateOfBirth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameDateOfBirth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsNameDateOfBirth.
      ******************************************************************

           MOVE lsNameDateOfBirth TO LpNameDateOfBirth.

           EXIT METHOD.

       END METHOD setNameDateOfBirth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setNameGender.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsNameGender        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsNameGender.
      ******************************************************************

           SET LpNameGender TO lsNameGender.

           EXIT METHOD.

       END METHOD setNameGender.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setTaxStatus.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxStatus        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsTaxStatus.
      ******************************************************************

           SET LpTaxStatus TO lsTaxStatus.

           EXIT METHOD.

       END METHOD setTaxStatus.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setDeceasedFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDeceasedFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsDeceasedFlag.
      ******************************************************************

           SET LpDeceasedFlag TO lsDeceasedFlag.

           EXIT METHOD.

       END METHOD setDeceasedFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setDateOfDeath.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsDateOfDeath        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsDateOfDeath.
      ******************************************************************

           MOVE lsDateOfDeath TO LpDateOfDeath.

           EXIT METHOD.

       END METHOD setDateOfDeath.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setTaxWithholdingFlag.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxWithholdingFlag        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsTaxWithholdingFlag.
      ******************************************************************

           SET LpTaxWithholdingFlag TO lsTaxWithholdingFlag.

           EXIT METHOD.

       END METHOD setTaxWithholdingFlag.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setTaxCertificationCode.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxCertificationCode        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsTaxCertificationCode.
      ******************************************************************

           SET LpTaxCertificationCode TO lsTaxCertificationCode.

           EXIT METHOD.

       END METHOD setTaxCertificationCode.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setTaxCertificationDate.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsTaxCertificationDate        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsTaxCertificationDate.
      ******************************************************************

           MOVE lsTaxCertificationDate TO LpTaxCertificationDate.

           EXIT METHOD.

       END METHOD setTaxCertificationDate.
062816******************************************************************
062816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062816******************************************************************
062816
062816 METHOD-ID. setForeignTaxID.
062816 DATA DIVISION.
062816******************************************************************
062816 WORKING-STORAGE SECTION.
062816******************************************************************
062816 LINKAGE SECTION.
062816
062816 01  lsForeignTaxID        OBJECT REFERENCE CLASS-STRING.
062816******************************************************************
062816 PROCEDURE DIVISION USING BY VALUE lsForeignTaxID.
062816******************************************************************
062816
062816     SET LpForeignTaxID TO lsForeignTaxID.
062816
062816     EXIT METHOD.
062816
062816 END METHOD setForeignTaxID.
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. setPersonalEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsPersonalEmail        OBJECT REFERENCE CLASS-STRING.
010217******************************************************************
010217 PROCEDURE DIVISION USING BY VALUE lsPersonalEmail.
010217******************************************************************
010217
010217     SET LpPersonalEmail TO lsPersonalEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD setPersonalEmail. 
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. setBusinessEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsBusinessEmail        OBJECT REFERENCE CLASS-STRING.
010217******************************************************************
010217 PROCEDURE DIVISION USING BY VALUE lsBusinessEmail.
010217******************************************************************
010217
010217     SET LpBusinessEmail TO lsBusinessEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD setBusinessEmail.              
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateIndividualPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualPrefix.
      ******************************************************************

           SET LpUpdateIndividualPrefix TO lsUpdateIndividualPrefix.

           EXIT METHOD.

       END METHOD setUpdateIndividualPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateIndividualFirstName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualFirstName OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualFirstName.
      ******************************************************************

           SET LpUpdateIndividualFirstName
                  TO lsUpdateIndividualFirstName.

           EXIT METHOD.

       END METHOD setUpdateIndividualFirstName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
083004 METHOD-ID. setUpdateIndividualMiddleName.
083004 DATA DIVISION.
083004******************************************************************
083004 WORKING-STORAGE SECTION.
083004******************************************************************
083004 LINKAGE SECTION.

083004 01  lsUpdateIndividualMiddleName  OBJECT REFERENCE CLASS-STRING.
083004******************************************************************
083004 PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualMiddleName.
083004******************************************************************

083004     SET LpUpdateIndividualMiddleName
                      TO lsUpdateIndividualMiddleName.

083004     EXIT METHOD.

083004 END METHOD setUpdateIndividualMiddleName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************
       METHOD-ID. setUpdateIndividualLastName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualLastName  OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualLastName.
      ******************************************************************

           SET LpUpdateIndividualLastName
                    TO lsUpdateIndividualLastName.

           EXIT METHOD.

       END METHOD setUpdateIndividualLastName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateIndividualSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualSuffix.
      ******************************************************************

           SET LpUpdateIndividualSuffix TO lsUpdateIndividualSuffix.

           EXIT METHOD.

       END METHOD setUpdateIndividualSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateIndividualSSN.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateIndividualSSN        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateIndividualSSN.
      ******************************************************************

           MOVE lsUpdateIndividualSSN TO LpUpdateIndividualSSN.

           EXIT METHOD.

       END METHOD setUpdateIndividualSSN.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateBusinessPrefix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessPrefix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateBusinessPrefix.
      ******************************************************************

           SET LpUpdateBusinessPrefix TO lsUpdateBusinessPrefix.

           EXIT METHOD.

       END METHOD setUpdateBusinessPrefix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateBusinessName.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessName        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateBusinessName.
      ******************************************************************

           SET LpUpdateBusinessName TO lsUpdateBusinessName.

           EXIT METHOD.

       END METHOD setUpdateBusinessName.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateBusinessSuffix.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessSuffix        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateBusinessSuffix.
      ******************************************************************

           SET LpUpdateBusinessSuffix TO lsUpdateBusinessSuffix.

           EXIT METHOD.

       END METHOD setUpdateBusinessSuffix.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateBusinessTaxID.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateBusinessTaxID        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateBusinessTaxID.
      ******************************************************************

           SET LpUpdateBusinessTaxID TO lsUpdateBusinessTaxID.

           EXIT METHOD.

       END METHOD setUpdateBusinessTaxID.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateNameDateOfBirth.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateNameDateOfBirth        PIC S9(09) COMP-5.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateNameDateOfBirth.
      ******************************************************************

           MOVE lsUpdateNameDateOfBirth TO LpUpdateNameDateOfBirth.

           EXIT METHOD.

       END METHOD setUpdateNameDateOfBirth.
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       METHOD-ID. setUpdateNameGender.
       DATA DIVISION.
      ******************************************************************
       WORKING-STORAGE SECTION.
      ******************************************************************
       LINKAGE SECTION.

       01  lsUpdateNameGender        OBJECT REFERENCE CLASS-STRING.
      ******************************************************************
       PROCEDURE DIVISION USING BY VALUE lsUpdateNameGender.
      ******************************************************************

           SET LpUpdateNameGender TO lsUpdateNameGender.

           EXIT METHOD.

       END METHOD setUpdateNameGender.
062816******************************************************************
062816*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
062816******************************************************************
062816
062816 METHOD-ID. setUpdateForeignTaxID.
062816 DATA DIVISION.
062816******************************************************************
062816 WORKING-STORAGE SECTION.
062816******************************************************************
062816 LINKAGE SECTION.
062816
062816 01  lsUpdateForeignTaxID      OBJECT REFERENCE CLASS-STRING.
062816******************************************************************
062816 PROCEDURE DIVISION USING BY VALUE lsUpdateForeignTaxID.
062816******************************************************************
062816
062816     SET LpUpdateForeignTaxID TO lsUpdateForeignTaxID.
062816
062816     EXIT METHOD.
062816
062816 END METHOD setUpdateForeignTaxID.
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. setUpdatePersonalEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsUpdatePersonalEmail        OBJECT REFERENCE CLASS-STRING.
010217******************************************************************
010217 PROCEDURE DIVISION USING BY VALUE lsUpdatePersonalEmail.
010217******************************************************************
010217
010217     SET LpUpdatePersonalEmail TO lsUpdatePersonalEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD setUpdatePersonalEmail. 
010217******************************************************************
010217*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
010217******************************************************************
010217
010217 METHOD-ID. setUpdateBusinessEmail.
010217 DATA DIVISION.
010217******************************************************************
010217 WORKING-STORAGE SECTION.
010217******************************************************************
010217 LINKAGE SECTION.
010217
010217 01  lsUpdateBusinessEmail        OBJECT REFERENCE CLASS-STRING.
010217******************************************************************
010217 PROCEDURE DIVISION USING BY VALUE lsUpdateBusinessEmail.
010217******************************************************************
010217
010217     SET LpUpdateBusinessEmail TO lsUpdateBusinessEmail.
010217
010217     EXIT METHOD.
010217
010217 END METHOD setUpdateBusinessEmail.         
      ******************************************************************
      *XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      ******************************************************************

       END OBJECT.
       END CLASS ONAMEAPI.
