--@**20100102*******************************************
--@**
--@** Licensed Materials - Property of
--@** Professional Data Management Again, Inc.
--@** (C)Copyright Professional Data Management Again,
--@** Inc.  1983-2010.
--@**
--@** All Rights Reserved.  Contains confidential and
--@** trade secret information.  Copyright notice is
--@** precautionary only and does not imply publication.
--@**
--@*****************************************************
-- 20170102 20161201-003-01 SAP Added  column
--@*****************************************************

-- ADD new column/s into PANST_ANNUAL_STATEMENT_NAMES and PANST_ANNUAL_STATEMENT_COPIES

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_NAMES') AND name='PERSONAL_EMAIL_ADDRESS')
  ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_NAMES
    ADD PERSONAL_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_NAMES') AND name='BUSINESS_EMAIL_ADDRESS')
  ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_NAMES
    ADD BUSINESS_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_NAMES') AND name='EMAIL_ADDRESS')
UPDATE dbo.PANST_ANNUAL_STATEMENT_NAMES SET PERSONAL_EMAIL_ADDRESS = (CASE WHEN GENDER <> ' ' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END),
                    BUSINESS_EMAIL_ADDRESS = (CASE WHEN GENDER = ' ' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END)
; 

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_NAMES') AND name='EMAIL_ADDRESS')
ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_NAMES
       DROP COLUMN EMAIL_ADDRESS
;       
       
       

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_COPIES') AND name='PERSONAL_EMAIL_ADDRESS')
  ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_COPIES
    ADD PERSONAL_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_COPIES') AND name='BUSINESS_EMAIL_ADDRESS')
  ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_COPIES
    ADD BUSINESS_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_COPIES') AND name='EMAIL_ADDRESS')
UPDATE dbo.PANST_ANNUAL_STATEMENT_COPIES SET PERSONAL_EMAIL_ADDRESS = (CASE WHEN GENDER <> ' ' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END),
                    BUSINESS_EMAIL_ADDRESS = (CASE WHEN GENDER = ' ' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END)
; 

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.PANST_ANNUAL_STATEMENT_COPIES') AND name='EMAIL_ADDRESS')
ALTER TABLE dbo.PANST_ANNUAL_STATEMENT_COPIES
       DROP COLUMN EMAIL_ADDRESS;       