

--ALLENR 20140318-002-01 AMR Add Due Control Number column

ALTER TABLE dbo.BILLING_FMT12_HISTORY
  ADD DUE_CONTROL_NUMBER BIGINT NOT NULL
  CONSTRAINT DUE_CONTROL_NUMBER_def DEFAULT 0;
ALTER TABLE dbo.BILLING_FMT12_HISTORY
  DROP CONSTRAINT DUE_CONTROL_NUMBER_def;
