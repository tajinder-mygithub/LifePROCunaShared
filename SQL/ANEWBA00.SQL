--@**20040102*******************************************
--@** 
--@** Licensed Materials - Property of
--@** Professional Data Management Again, Inc.
--@** (C)Copyright Professional Data Management Again,
--@** Inc.  1983-2009.
--@** 
--@** All Rights Reserved.  Contains confidential and
--@** trade secret information.  Copyright notice is
--@** precautionary only and does not imply publication.
--@** 
--@**20040102*******************************************
--
-- 090616*H 20160607-003-11 ABK  Pre-Billing Welcome Kit Data.
-- 121416*H 20161212-001-01 CDM  Add changes made to PNMLNEWB.SQL with V19

/*   START SQL SCRIPT   */
/* drop constraints */

IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_APP_FIELDS')
BEGIN
  ALTER TABLE NB_NEW_APP_FIELDS DROP CONSTRAINT NB_NEW_APP_FIELDS_FK_0

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_NEW_APP_FIELDS' 
  AND COLUMN_NAME = 'SECOND_BILL_DAY' )
  BEGIN
     ALTER TABLE NB_NEW_APP_FIELDS ADD SECOND_BILL_DAY           SMALLINT  NOT NULL DEFAULT 0
  END
   
  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_NEW_APP_FIELDS' 
  AND COLUMN_NAME = 'MULTIPLE_PREMIUMS' )
  BEGIN
   ALTER TABLE NB_NEW_APP_FIELDS ADD MULTIPLE_PREMIUMS         NCHAR (1) NOT NULL DEFAULT ''
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_NEW_APP_FIELDS' 
  AND COLUMN_NAME = 'GENERATE_PRE_BILLING_INFO' )
  BEGIN
     ALTER TABLE NB_NEW_APP_FIELDS ADD GENERATE_PRE_BILLING_INFO     NCHAR (1) NOT NULL DEFAULT ''
  END
  
  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_NEW_APP_FIELDS' 
  AND COLUMN_NAME = 'SUPPRESS_INITIAL_BILL' )
  BEGIN
   ALTER TABLE NB_NEW_APP_FIELDS ADD SUPPRESS_INITIAL_BILL     NCHAR (1)  NOT NULL DEFAULT ''
  END

  ALTER TABLE  NB_NEW_APP_FIELDS ADD CONSTRAINT NB_NEW_APP_FIELDS_FK_0
    FOREIGN KEY (NB_KEY)
    REFERENCES  NB_NEW_BUSINESS (NB_KEY)
    ON DELETE CASCADE
         
END
;

-- OWN_BENF_RELA_DATA SECTION OF NEW BUSINESS TABLE
-- OCCURS ONCE WITHIN NB_NEW_BUSINESS

IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_OWN_BENF_RELA_DATA')
BEGIN
  ALTER TABLE NB_OWN_BENF_RELA_DATA DROP CONSTRAINT NB_OWN_BENF_RELA_DATA_FK_0

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'PAY_SUB_TYPE' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD PAY_SUB_TYPE              NCHAR (2) NOT NULL DEFAULT ''
  END
   
  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN1_SUB_TYPE' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN1_SUB_TYPE             NCHAR (2) NOT NULL DEFAULT ''
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN2_SUB_TYPE' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN2_SUB_TYPE             NCHAR (2) NOT NULL DEFAULT ''
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN3_SUB_TYPE' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN3_SUB_TYPE             NCHAR (2) NOT NULL DEFAULT ''
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN1_PCT_INT' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN1_PCT_INT              DECIMAL (5,2) NOT NULL DEFAULT 0
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN2_PCT_INT' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN2_PCT_INT              DECIMAL (5,2) NOT NULL DEFAULT 0
  END

  IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'NB_OWN_BENF_RELA_DATA' 
  AND COLUMN_NAME = 'ANN3_PCT_INT' )
  BEGIN
     ALTER TABLE NB_OWN_BENF_RELA_DATA ADD ANN3_PCT_INT              DECIMAL (5,2) NOT NULL DEFAULT 0
  END
  ALTER TABLE  NB_OWN_BENF_RELA_DATA ADD CONSTRAINT NB_OWN_BENF_RELA_DATA_FK_0
      FOREIGN KEY (NB_KEY)
      REFERENCES  NB_NEW_BUSINESS (NB_KEY)
      ON DELETE CASCADE
END
;


-- POLICY_PROFILE SECTION OF NEW BUSINESS TABLE
IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND NOT EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_POLICY_PROFILE')
BEGIN
  CREATE TABLE NB_POLICY_PROFILE (
    NB_KEY                    INT         NOT NULL ,
    BENEFIT_SEQUENCE          SMALLINT    NOT NULL ,
    EFFECTIVE_DATE            INTEGER     NOT NULL ,
    SPLIT                     SMALLINT    NOT NULL ,
    PROFILE_SELECTED          NCHAR(10)   NOT NULL ,
    REBALANCE                 CHAR(01)    NOT NULL ,
    AUTO_POPULATE             CHAR(01)    NOT NULL)

  ALTER TABLE NB_POLICY_PROFILE WITH NOCHECK ADD CONSTRAINT [PK_NB_POLICY_PROFILE] PRIMARY KEY CLUSTERED
    (
    NB_KEY                ASC
    )
    ON [PRIMARY]
    
  ALTER TABLE  NB_POLICY_PROFILE ADD CONSTRAINT NB_POLICY_PROFILE_FK_0
      FOREIGN KEY (NB_KEY)
      REFERENCES  NB_NEW_BUSINESS (NB_KEY)
      ON DELETE CASCADE
END
;


-- POLICY MODEL SECTION OF NEW BUSINESS TABLE

IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND NOT EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_POLICY_MODEL')
BEGIN
  CREATE TABLE NB_POLICY_MODEL (
    NB_KEY              INT            NOT NULL ,
    ENTRY_SEQUENCE      SMALLINT       NOT NULL ,
    MODEL_NAME          NCHAR(10)      NOT NULL ,
    MODEL_VERSION       INTEGER        NOT NULL ,
    MODEL_ALLOC_PCT     DECIMAL(05,02) NOT NULL ,
    REBALANCE           CHAR(01)       NOT NULL)

  ALTER TABLE NB_POLICY_MODEL WITH NOCHECK ADD CONSTRAINT [PK_NB_POLICY_MODEL] PRIMARY KEY CLUSTERED
    (
    NB_KEY                ASC ,
    ENTRY_SEQUENCE        ASC
    )
    ON [PRIMARY]

  ALTER TABLE  NB_POLICY_MODEL ADD CONSTRAINT NB_POLICY_MODEL_FK_0
      FOREIGN KEY (NB_KEY)
      REFERENCES  NB_POLICY_PROFILE (NB_KEY)
      ON DELETE CASCADE
END
;

-- POLICY SUB MODEL SECTION OF NEW BUSINESS TABLE
IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND NOT EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_POLICY_SUB_MODEL')
BEGIN
  CREATE TABLE NB_POLICY_SUB_MODEL (
    NB_KEY              INT            NOT NULL ,
    PARENT_SEQUENCE     SMALLINT       NOT NULL ,
    ENTRY_SEQUENCE      SMALLINT       NOT NULL ,
    SUB_MODEL_NAME      NCHAR(10)      NOT NULL ,
    SUB_MODEL_ALLOC_PCT DECIMAL(05,02) NOT NULL ,
    REBALANCE           CHAR(01)       NOT NULL)

  ALTER TABLE NB_POLICY_SUB_MODEL WITH NOCHECK ADD CONSTRAINT [PK_NB_POLICY_SUB_MODEL] PRIMARY KEY CLUSTERED
    (
    NB_KEY                ASC ,
    PARENT_SEQUENCE       ASC ,
    ENTRY_SEQUENCE        ASC
    )
    ON [PRIMARY]

  ALTER TABLE  NB_POLICY_SUB_MODEL ADD CONSTRAINT NB_POLICY_SUB_MODEL_FK_0
      FOREIGN KEY (NB_KEY, PARENT_SEQUENCE)
      REFERENCES  NB_POLICY_MODEL (NB_KEY, ENTRY_SEQUENCE)
      ON DELETE CASCADE
END
;

-- DEPOSIT ALLOCATION SECTION OF NEW BUSINESS TABLE

IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND NOT EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_DEPOSIT_ALLOCATION')
BEGIN 
  CREATE TABLE NB_DEPOSIT_ALLOCATION (
    NB_KEY                    INT           NOT NULL ,
    PARENT_SEQUENCE           SMALLINT      NOT NULL ,
    ENTRY_SEQUENCE            SMALLINT      NOT NULL ,
    PARENT_SEQUENCE_TYPE      CHAR(01)      NOT NULL ,
    BENEFIT_SEQUENCE          SMALLINT      NOT NULL ,
    EFFECTIVE_DATE            INTEGER       NOT NULL ,
    ONE_TIME_FLAG             CHAR(01)      NOT NULL)

  ALTER TABLE NB_DEPOSIT_ALLOCATION WITH NOCHECK ADD CONSTRAINT [PK_NB_DEPOSIT_ALLOCATION] PRIMARY KEY CLUSTERED
    (
    NB_KEY            ASC ,
    PARENT_SEQUENCE   ASC ,
    ENTRY_SEQUENCE    ASC
    )
    ON [PRIMARY]

ALTER TABLE  NB_DEPOSIT_ALLOCATION ADD CONSTRAINT NB_DEPOSIT_ALLOCATION_FK_0
    FOREIGN KEY (NB_KEY)
    REFERENCES  NB_NEW_BUSINESS (NB_KEY)
    ON DELETE CASCADE
END
;

-- DEPOSIT ALLOCATION DETAILS SECTION OF NEW BUSINESS TABLE

IF  EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_NEW_BUSINESS')
AND NOT EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_DEPOSIT_ALLOCATION_DETAILS')
BEGIN
  CREATE TABLE NB_DEPOSIT_ALLOCATION_DETAILS (
    NB_KEY              INT           NOT NULL ,
    PARENT_SEQUENCE     SMALLINT      NOT NULL ,
    ENTRY_SEQUENCE      SMALLINT      NOT NULL ,
    FV_FUND_ID          NCHAR(10)     NOT NULL ,
    VALUE               DECIMAL(15,7) NOT NULL)

  ALTER TABLE NB_DEPOSIT_ALLOCATION_DETAILS WITH NOCHECK ADD CONSTRAINT [PK_NB_DEPOSIT_ALLOCATION_DETAILS] PRIMARY KEY CLUSTERED
    (
    NB_KEY                ASC ,
    PARENT_SEQUENCE       ASC ,
    ENTRY_SEQUENCE        ASC
    )
    ON [PRIMARY]

  ALTER TABLE  NB_DEPOSIT_ALLOCATION_DETAILS ADD CONSTRAINT NB_DEPOSIT_ALLOCATION_DETAILS_FK_0
      FOREIGN KEY (NB_KEY)
      REFERENCES  NB_NEW_BUSINESS (NB_KEY)
      ON DELETE CASCADE
END
;