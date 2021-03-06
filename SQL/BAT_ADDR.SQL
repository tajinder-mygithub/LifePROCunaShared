--@**20100811*******************************************
--@** 
--@** Licensed Materials - Property of
--@** ExlService Holdings, Inc.
--@**  
--@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved.
--@** 
--@** Contains confidential and trade secret information.  
--@** Copyright notice is precautionary only and does not
--@** imply publication.
--@** 
--@**20100811*******************************************
DROP TABLE BATCH_ADDR
;

CREATE TABLE  BATCH_ADDR  (
    DATESTAMP INTEGER NOT NULL,
    TIMESTAMP INTEGER NOT NULL,
    CODER_ID CHAR(4) NOT NULL,
    NAME_ID INTEGER NOT NULL,
    EFFECTIVE_DATE INTEGER NOT NULL,
    ADDRESS_CODE CHAR(3) NOT NULL,
    COMPANY_CODE CHAR(2) NOT NULL,
    POLICY_NUMBER CHAR(12) NOT NULL,
    NALK_ADDRESS_ID INTEGER NOT NULL,
    CANCEL_DATE INTEGER NOT NULL,
    RECUR_START_MM SMALLINT NOT NULL,
    RECUR_START_DD SMALLINT NOT NULL,
    RECUR_END_MM SMALLINT NOT NULL,
    RECUR_END_DD SMALLINT NOT NULL,
    ALT_NAME_ID INTEGER NOT NULL,
    PHONE_AREA_CODE SMALLINT NOT NULL,
    PHONE_PREFIX SMALLINT NOT NULL,
    PHONE_NUMBER SMALLINT NOT NULL,
    FAX_AREA_CODE SMALLINT NOT NULL,
    FAX_PREFIX SMALLINT NOT NULL,
    FAX_NUMBER SMALLINT NOT NULL,
    ADDRESS_TYPE CHAR(1) NOT NULL,
    ADDR_ADDRESS_ID INTEGER NOT NULL,
    ADDR_LINE_1 CHAR(35) NOT NULL,
    ADDR_LINE_2 CHAR(35) NOT NULL,
    ADDR_LINE_3 CHAR(35) NOT NULL,
    ADDR_CITY CHAR(24) NOT NULL,
    ADDR_STATE CHAR(2) NOT NULL,
    ADDR_ZIP_CODE CHAR(9) NOT NULL,
    ZIP_EXTENSION CHAR(2) NOT NULL,
    ADDR_COUNTRY CHAR(30) NOT NULL,
    RES_COUNTY CHAR(19) NOT NULL,
    COUNTY_CODE CHAR(10) NOT NULL,
    CITY_CODE CHAR(10) NOT NULL)
;


ALTER TABLE  BATCH_ADDR
    ADD PRIMARY KEY
    (DATESTAMP,
    TIMESTAMP,
    CODER_ID,
    NAME_ID,
    ADDR_ADDRESS_ID)
;

