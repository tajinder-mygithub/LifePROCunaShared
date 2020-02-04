--2011212-001-01 SES Delete original NB Benefit Change tables as they have been renamed

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_BENCHG_BENEFIT_REQUEST')
   DROP TABLE [dbo].[NB_BENCHG_BENEFIT_REQUEST]
;

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_BENCHG_EXTENDED_KEY')
   DROP TABLE [dbo].[NB_BENCHG_EXTENDED_KEY]
;

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_BENCHG_HEADER')
   DROP TABLE [dbo].[NB_BENCHG_HEADER]
;

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' AND table_name = 'NB_BENCHG_INSURED')
   DROP TABLE [dbo].[NB_BENCHG_INSURED]
;
