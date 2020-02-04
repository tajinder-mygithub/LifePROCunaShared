--
--   AADIRADM - Prime LIFEPRO_AD_ADMIN access to AD security sub-menu
--

DELETE FROM [dbo].[XAPP_CONTROL]
      WHERE REC_TYPE IN ('s', 't', 'u')
;

DELETE FROM [dbo].[PADIR_ROLE_RESTRICT_COMPANY]
;

DELETE FROM [dbo].[PADIR_ROLE_SECURITY_DEFINITION]
;

DELETE FROM [dbo].[PADIR_CODER_DEFINITION]
;

DELETE FROM [dbo].[PADIR_ROLE_DEFINITION]
;

INSERT INTO [dbo].[PADIR_ROLE_DEFINITION]
           ([ROLE_DEFINITION_ID]
           ,[ROLE_DEFINITION])
     VALUES
           (1
           ,'LIFEPRO_AD_ADMIN')
;

INSERT INTO [dbo].[XAPP_CONTROL]
           ([REC_TYPE]
           ,[LAST_DAY]
           ,[LAST_ID])
     VALUES
           ('s'
           ,'N/A'
           ,1)
;

INSERT INTO [dbo].[PADIR_CODER_DEFINITION]
           ([CODER_DEFINITION_ID]
           ,[ACCOUNT_ID]
           ,[CODER_ID])
     VALUES
           (1,'DOMAIN\USER','SCTY')
;

INSERT INTO [dbo].[XAPP_CONTROL]
           ([REC_TYPE]
           ,[LAST_DAY]
           ,[LAST_ID])
     VALUES
           ('t'
           ,'N/A'
           ,1)
;

INSERT INTO [dbo].[PADIR_ROLE_SECURITY_DEFINITION]
           ([ROLE_SECURITY_DEFINITION_ID]
           ,[ROLE_DEFINITION_ID]
           ,[SYSTEM_DEFINITION_ID]
           ,[SECURITY_SETTING])
     VALUES
           (1,1,600,9)
          ,(2,1,602,9)
;

INSERT INTO [dbo].[XAPP_CONTROL]
           ([REC_TYPE]
           ,[LAST_DAY]
           ,[LAST_ID])
     VALUES
           ('u'
           ,'N/A'
           ,2)
;



