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
--@********************************************************************
-- 20170102 20161201-003-01 SAP Add Personal and Business Email Address
--@********************************************************************

-- ADD new column/s into NB_NAMES and NB_MUL_PERSONAL_DETAILS

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_NAMES') AND name='PERSONAL_EMAIL_ADDRESS')
  ALTER TABLE dbo.NB_NAMES
    ADD PERSONAL_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_NAMES') AND name='BUSINESS_EMAIL_ADDRESS')
  ALTER TABLE dbo.NB_NAMES
    ADD BUSINESS_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_NAMES') AND name='EMAIL_ADDRESS')
UPDATE dbo.NB_NAMES SET PERSONAL_EMAIL_ADDRESS = (CASE WHEN INDIV_OR_BUSINESS = 'I' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END),
                    BUSINESS_EMAIL_ADDRESS = (CASE WHEN INDIV_OR_BUSINESS = 'B' THEN EMAIL_ADDRESS
                                                   ELSE ' ' END)
; 

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_NAMES') AND name='EMAIL_ADDRESS')
ALTER TABLE dbo.NB_NAMES
       DROP COLUMN EMAIL_ADDRESS
;       
       
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_MUL_PERSONAL_DETAILS') AND name='MUL_PERSONAL_EMAIL_ADDRESS')
  ALTER TABLE dbo.NB_MUL_PERSONAL_DETAILS
    ADD MUL_PERSONAL_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_MUL_PERSONAL_DETAILS') AND name='MUL_BUSINESS_EMAIL_ADDRESS')
  ALTER TABLE dbo.NB_MUL_PERSONAL_DETAILS
    ADD MUL_BUSINESS_EMAIL_ADDRESS NVARCHAR(256) NOT NULL DEFAULT ' '
;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_MUL_PERSONAL_DETAILS') AND name='MUL_EMAIL_ADDRESS')
UPDATE dbo.NB_MUL_PERSONAL_DETAILS SET MUL_PERSONAL_EMAIL_ADDRESS = (CASE WHEN MUL_FORMAT_CODE = 'I' THEN MUL_EMAIL_ADDRESS
                                                   ELSE ' ' END),
                    MUL_BUSINESS_EMAIL_ADDRESS = (CASE WHEN MUL_FORMAT_CODE = 'B' THEN MUL_EMAIL_ADDRESS
                                                   ELSE ' ' END)
; 

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.NB_MUL_PERSONAL_DETAILS') AND name='MUL_EMAIL_ADDRESS')
ALTER TABLE dbo.NB_MUL_PERSONAL_DETAILS
       DROP COLUMN MUL_EMAIL_ADDRESS
;              