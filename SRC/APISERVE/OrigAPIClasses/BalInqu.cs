/*@*****************************************************
/*@** 
/*@** Licensed Materials - Property of
/*@** ExlService Holdings, Inc.
/*@**  
/*@** (C) 1983-2013 ExlService Holdings, Inc.  All Rights Reserved.
/*@** 
/*@** Contains confidential and trade secret information.  
/*@** Copyright notice is precautionary only and does not
/*@** imply publication.
/*@** 
/*@*****************************************************

/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20050504-004-01   DAR   02/16/06    Initial implementation  
*  20120706-004-01   DAR   09/24/12    Add bucket-level values to Balance Inquiry API
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services  
*  20100901-003-01   TJO   11/08/13    Add additional bucket-level values to Balance Inquiry API
*  20140220-005-01   DAR   03/26/14    Add Override Future Date Edit Capability
*  20140220-006-01   DAR   05/08/14    Add Guaranteed Withdrawal Values
*  20140220-008-01   DAR   06/17/14    Add additional bucket-level items 
*  20141010-004-01   DAR   10/14/14    Add additional GW values and a Source Summary
*  20141010-004-01   DAR   12/29/14    Add additional GW values 
*  20141010-004-01   DAR   02/17/15    Add Summary row values and Model Allocation Status
*  20141110-008-01   TJO   05/22/15    Add RFIA amounts to Balance Inquiry API    
*  20121115-004-02   DAR   06/26/15    Add Last Anniversary Date
*  20131010-019-01   DAR   07/25/15    Return Guar Retirement Due Amount (GR Segment) 
*  20131010-019-01   DAR   09/03/15    Add GR Overdue Detail and additional Summary related values
*  20151130-001-01   GWT   02/03/16    Add Model/Sub-Model/Profile info  
*  20160331-002-01   GWT   04/08/16    Fix SubModelModelName/SubModelModelVersion
*  20131010-019-01   DAR   04/15/16    Added Rider Fee Change Date and Modal Premium with GR Riders
*  20150805-006-36   SAP   09/19/16    Invest Next Phase2
*  20131010-019-01   DAR   10/17/16    Support additional methods for Balance Inquiry for sub-functions
*  20131010-019-01   DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*/


using System;
using LPNETAPI ;
using System.Data; 
using System.ServiceModel;
using System.ServiceModel.Description;



namespace PDMA.LifePro 
{
	/// <summary>
	/// LifePRO Balance Inquiry object, which returns qutoed fund information separated by Fund Source 
	/// </summary>

	public class BalInqu : IBalInqu  
	{
		OBALINQU apiBalance ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType)
		{
            Log.AddDetailedLogEntry("In TCP Balance Inquiry Init Call.  About to Init OBALINQU");  
			UserType = userType ; 
			apiBalance = new OBALINQU(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiBalance.getReturnCode() ; 
			outProps.ErrorMessage = apiBalance.getErrorMessage() ;

            Log.AddDetailedLogEntry("In TCP Balance Inquiry Init Call.  About to exit with Return Code: " + outProps.ReturnCode.ToString());  

            return outProps;  

		}
		public void Dispose() 
		{
			apiBalance.Dispose(); 
			apiBalance = null ; 
		}


        public BalanceInquiryResponse RunInquiry(BalanceInquiryRequest inProps)
        {
            // Changes made here must be made to the RunQuoteOnly, GetGuaranteedWithdrawalValues, and GetGauranteedRetirementValues.  
            // Right now, consolidation is difficult because each method has its own return type, and using hierarchical classes, 
            // inheritance, etc., could alter the responses clients receive, especially if using HTTP, and I'm concerned about 
            // breaking existing applications ...   David R.  

            
                Log.AddDetailedLogEntry("Starting TCP Balance Inquiry RunInquiry Call.  Call is for policy " + inProps.PolicyNumber);

                apiBalance.setCompanyCode(inProps.CompanyCode);
                apiBalance.setPolicyNumber(inProps.PolicyNumber);
                apiBalance.setEffectiveDate(inProps.EffectiveDate);
                apiBalance.setStopSearchDate(inProps.StopSearchDate);   // only used in retrieval of GWLastRateChangeDate  

                if (inProps.OverrideFutureDateEdits)
                    apiBalance.setOverrideFutureDateEdits("Y");
                else
                    apiBalance.setOverrideFutureDateEdits("N");


                apiBalance.setFunctionFlag("A");  // Decides operation ... "A" means ALL supported quote functions.  
                // The programmer of the API decides the method call, and is not aware of this indicator. 
                Log.AddDetailedLogEntry("TCP Balance Inquiry RunInquiry Call.  Just before OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);
                apiBalance.RunInquiry();
                Log.AddDetailedLogEntry("TCP Balance Inquiry RunInquiry Call.  Just after OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);


                BalanceInquiryResponse outProps = new BalanceInquiryResponse();
                outProps.ReturnCode = apiBalance.getReturnCode();
                outProps.ErrorMessage = apiBalance.getErrorMessage();

                outProps.ActiveRequests = apiBalance.getActiveRequests().Trim();
                outProps.MultipleLoans = apiBalance.getMultipleLoans().Trim();
                outProps.QuoteDate = apiBalance.getQuoteDate();
                outProps.ProcessToDate = apiBalance.getProcessToDate();
                outProps.LastValuationDate = apiBalance.getLastValuationDate();
                outProps.LastAnniversaryDate = apiBalance.getLastAnniversaryDate();
                outProps.GrossDeposits = apiBalance.getGrossDeposits();
                outProps.GrossWithdrawals = apiBalance.getGrossWithdrawals();
                outProps.LoanBalance = apiBalance.getLoanBalance();
                outProps.TotalFundBalance = apiBalance.getTotalFundBalance();
                outProps.AssetAllocationModelFlag = apiBalance.getAssetAllocationModelFlag();
                outProps.AssetAllocationModelStatus = apiBalance.getAssetAllocationModelStatus();

                outProps.PremiumIncrementRule = apiBalance.getPremiumIncrementRule();
                outProps.SumRowCount = apiBalance.getSumRowCount();
                int count = outProps.SumRowCount;
                outProps.SumRow = new int[count];
                outProps.SumSource = new string[count];
                outProps.SumSourceDesc = new string[count];
                outProps.SumFundBalance = new double[count];


                // Values below this point are stubbed for GIA Riders: 
                outProps.SumFreeAmount = new double[count];
                outProps.SumLoad = new double[count];
                outProps.SumGrossDeposits = new double[count];
                outProps.SumGrossWithdrawals = new double[count];
                outProps.SumStartDate = new int[count];
                outProps.SumIncomeStartDate = new int[count];
                outProps.SumIncomeStartDate = new int[count];
                outProps.SumPeriodCertain = new int[count];
                outProps.SumGuaranteeStatus = new string[count];
                outProps.SumGuaranteeStatusDate = new int[count];
                outProps.SumGuaranteeIncomeFactor = new double[count];
                outProps.SumGuaranteeIncome = new double[count];
                outProps.SumVestedAnnualIncome = new double[count];
                outProps.SumVestedMonthlyIncome = new double[count];
                outProps.SumScheduledTransferAmount = new double[count];
                outProps.SumAccumulatedPrepaymentAmount = new double[count];
                outProps.SumRemainingPrepaymentTransfers = new double[count];
                outProps.SumAmountToFullyFund = new double[count];
                // End stubbed values for GIA Riders


                for (int i = 1; i <= count; i++)
                {
                    outProps.SumRow[i - 1] = apiBalance.getSumRow(i);
                    outProps.SumSource[i - 1] = apiBalance.getSumSource(i);
                    outProps.SumSourceDesc[i - 1] = apiBalance.getSumSourceDesc(i);
                    outProps.SumFundBalance[i - 1] = apiBalance.getSumFundBalance(i);
                    outProps.SumFreeAmount[i - 1] = apiBalance.getSumFreeAmount(i);
                    outProps.SumLoad[i - 1] = apiBalance.getSumLoad(i);
                    outProps.SumGrossDeposits[i - 1] = apiBalance.getSumGrossDeposits(i);
                    outProps.SumGrossWithdrawals[i - 1] = apiBalance.getSumGrossWithdrawals(i);
                    outProps.SumStartDate[i - 1] = apiBalance.getSumStartDate(i);
                    outProps.SumIncomeStartDate[i - 1] = apiBalance.getSumIncomeStartDate(i);
                    outProps.SumPeriodCertain[i - 1] = apiBalance.getSumPeriodCertain(i);
                    outProps.SumGuaranteeStatus[i - 1] = apiBalance.getSumGuaranteeStatus(i);
                    outProps.SumGuaranteeStatusDate[i - 1] = apiBalance.getSumGuaranteeStatusDate(i);
                    outProps.SumGuaranteeIncomeFactor[i - 1] = apiBalance.getSumGuaranteeIncomeFactor(i);
                    outProps.SumGuaranteeIncome[i - 1] = apiBalance.getSumGuaranteeIncomeFactor(i);
                    outProps.SumVestedAnnualIncome[i - 1] = apiBalance.getSumVestedAnnualIncome(i);
                    outProps.SumVestedMonthlyIncome[i - 1] = apiBalance.getSumVestedMonthlyIncome(i);
                    outProps.SumScheduledTransferAmount[i - 1] = apiBalance.getSumScheduledTransferAmount(i);
                    outProps.SumAccumulatedPrepaymentAmount[i - 1] = apiBalance.getSumAccumPrepaymentAmount(i);
                    outProps.SumRemainingPrepaymentTransfers[i - 1] = apiBalance.getSumRemainPrepayTransfers(i);
                    outProps.SumAmountToFullyFund[i - 1] = apiBalance.getSumAmountToFullyFund(i);
                }

                outProps.RowCount = apiBalance.getRowCount();
                outProps.TotalCostBasis = apiBalance.getTotalCostBasis();
                outProps.PreTefraCostBasis = apiBalance.getPreTefraCostBasis();
                outProps.CurrentEarningsRate = apiBalance.getCurrentEarningsRate();
                outProps.IndexEarningsRate = apiBalance.getIndexEarningsRate();
                outProps.GuaranteedEarningsRate = apiBalance.getGuarEarningsRate();
                outProps.CurrentEarningsAmountToDate = apiBalance.getCurrentEarningsAmountToDate();
                outProps.IndexEarningsAmountToDate = apiBalance.getIndexEarningsAmountToDate();
                //20150805-006-36 SAP Invest Next Phase2
                outProps.FinancialRptInd = apiBalance.getFinancialRptInd();
                outProps.PolicyCode = apiBalance.getPolicyCode();
                outProps.PolicyMatureExpDate = apiBalance.getPolicyMatureExpDate();
                outProps.PolicyRebalDate = apiBalance.getPolicyRebalDate();
                outProps.PolicyRebalFlag = apiBalance.getPolicyRebalFlag();
                outProps.HybridBOTDate = apiBalance.getHybridBOTDate();
                outProps.HybridEOTDate = apiBalance.getHybridEOTDate();
                outProps.HybridEOTHoldDate = apiBalance.getHybridEOTHoldDate();
                outProps.HybridHoldAcctStatus = apiBalance.getHybridHoldAcctStatus();

                count = outProps.RowCount;
                outProps.RowNumber = new int[count];
                outProps.MoneySource = new string[count];
                outProps.FundID = new string[count];
                outProps.ShortDescription = new string[count];
                outProps.LongDescription = new string[count];
                outProps.FundType = new string[count];
                outProps.Units = new double[count];
                outProps.UnitValue = new double[count];
                outProps.UnitValueDate = new int[count];
                outProps.FundBalance = new double[count];
                // Added Fund Table items - 02/03/2016, GWT, for 20151130-001-01 
                outProps.FundModelTableIndex = new int[count];
                outProps.FundSubModelTableIndex = new int[count];
                outProps.FundModelName = new string[count];
                outProps.FundModelVersion = new int[count];
                outProps.FundSubModelName = new string[count];
                outProps.FundSubModelAllocation = new double[count];
                outProps.FundHybridCap = new double[count];
                outProps.FundHybridFloor = new double[count];
                //20150805-006-36 SAP Invest Next Phase2 
                outProps.FundBOTAnnvIndex = new double[count];
                outProps.FundCurrIndex = new double[count];

                for (int i = 1; i <= count; i++)
                {
                    outProps.RowNumber[i - 1] = apiBalance.getRowNumber(i);
                    outProps.MoneySource[i - 1] = apiBalance.getMoneySource(i).Trim();
                    outProps.FundID[i - 1] = apiBalance.getFundID(i).Trim();
                    outProps.ShortDescription[i - 1] = apiBalance.getShortDescription(i).Trim();
                    outProps.LongDescription[i - 1] = apiBalance.getLongDescription(i).Trim();
                    outProps.FundType[i - 1] = apiBalance.getFundType(i).Trim();
                    outProps.Units[i - 1] = apiBalance.getUnits(i);
                    outProps.UnitValue[i - 1] = apiBalance.getUnitValue(i);
                    outProps.UnitValueDate[i - 1] = apiBalance.getUnitValueDate(i);
                    outProps.FundBalance[i - 1] = apiBalance.getFundBalance(i);
                    // Added Fund Table items - 02/03/2016, GWT, for 20151130-001-01 
                    outProps.FundModelTableIndex[i - 1] = apiBalance.getFundModel(i);
                    outProps.FundSubModelTableIndex[i - 1] = apiBalance.getFundSubModel(i);
                    outProps.FundModelName[i - 1] = apiBalance.getModelID(outProps.FundModelTableIndex[i - 1]);
                    outProps.FundModelVersion[i - 1] = apiBalance.getModelVersion(outProps.FundModelTableIndex[i - 1]);
                    outProps.FundSubModelName[i - 1] = apiBalance.getSubModelID(outProps.FundSubModelTableIndex[i - 1]);
                    outProps.FundSubModelAllocation[i - 1] = apiBalance.getFundSubAlloc(i);
                    outProps.FundHybridCap[i - 1] = apiBalance.getFundHybridCap(i);
                    outProps.FundHybridFloor[i - 1] = apiBalance.getFundHybridFloor(i);
                    //20150805-006-36 SAP Invest Next Phase2 
                    outProps.FundBOTAnnvIndex[i - 1] = apiBalance.getFundBOTAnnvIndex(i);
                    outProps.FundCurrIndex[i - 1] = apiBalance.getFundCurrIndex(i);
                }

                // Added additional output - 02/03/2016, GWT, for 20151130-001-01
                outProps.ProfileID = apiBalance.getProfileID();
                outProps.ProfileDescription = apiBalance.getProfileDesc();

                // Added Model Table - 02/03/2016, GWT, for 20151130-001-01 
                outProps.ModelCount = apiBalance.getLastModel();
                int mCount = outProps.ModelCount;
                outProps.ModelName = new string[mCount];
                outProps.ModelVersion = new int[mCount];
                outProps.ModelMDLMIdent = new long[mCount];
                outProps.ModelType = new string[mCount];
                outProps.ModelBalance = new double[mCount];
                outProps.ModelSubModelCount = new int[mCount];
                //20150805-006-36 SAP Invest Next Phase2 
                outProps.ModelRebalFlag = new string[mCount];
                outProps.ModelRebalDate = new int[mCount];

                for (int i = 1; i <= mCount; i++)
                {
                    outProps.ModelName[i - 1] = apiBalance.getModelID(i).Trim();
                    outProps.ModelVersion[i - 1] = apiBalance.getModelVersion(i);
                    outProps.ModelMDLMIdent[i - 1] = apiBalance.getModelMdlmIdent(i);
                    outProps.ModelType[i - 1] = apiBalance.getModelType(i).Trim();
                    outProps.ModelBalance[i - 1] = apiBalance.getModelBalance(i);
                    outProps.ModelSubModelCount[i - 1] = apiBalance.getModelSubModelCount(i);
                    //20150805-006-36 SAP Invest Next Phase2 
                    outProps.ModelRebalFlag[i - 1] = apiBalance.getModelRebalFlag(i);
                    outProps.ModelRebalDate[i - 1] = apiBalance.getModelRebalDate(i);
                }

                // Added Sub-Model Table - 02/03/2016, GWT, for 20151130-001-01 
                outProps.SubModelCount = apiBalance.getLastSubModel();
                int sCount = outProps.SubModelCount;
                outProps.SubModelModelTableIndex = new int[sCount];
                outProps.SubModelModelName = new string[sCount];
                outProps.SubModelModelVersion = new int[sCount];
                outProps.SubModelName = new string[sCount];
                outProps.SubModelMDLBIdent = new long[sCount];
                outProps.SubModelBalance = new double[sCount];
                outProps.SubModelHybridCap = new double[sCount];
                outProps.SubModelHybridFloor = new double[sCount];
                //20150805-006-36 SAP Invest Next Phase2 
                outProps.SubModelRebalFlag = new string[sCount];
                outProps.SubModelRebalDate = new int[sCount];

                for (int i = 1; i <= sCount; i++)
                {
                    outProps.SubModelModelTableIndex[i - 1] = apiBalance.getSubModelModel(i);
                    outProps.SubModelModelName[i - 1] = outProps.ModelName[apiBalance.getSubModelModel(i) - 1];
                    outProps.SubModelModelVersion[i - 1] = outProps.ModelVersion[apiBalance.getSubModelModel(i) - 1];
                    outProps.SubModelName[i - 1] = apiBalance.getSubModelID(i).Trim();
                    outProps.SubModelMDLBIdent[i - 1] = apiBalance.getSubModelMdlbIdent(i);
                    outProps.SubModelBalance[i - 1] = apiBalance.getSubModelBalance(i);
                    outProps.SubModelHybridCap[i - 1] = apiBalance.getSubModelHybridCap(i);
                    outProps.SubModelHybridFloor[i - 1] = apiBalance.getSubModelHybridFloor(i);
                    //20150805-006-36 SAP Invest Next Phase2 
                    outProps.SubModelRebalFlag[i - 1] = apiBalance.getSubModelRebalFlag(i);
                    outProps.SubModelRebalDate[i - 1] = apiBalance.getSubModelRebalDate(i);
                }

                // Load up a DataTable structure with bucket-level values.  We use a DataTable here 
                // because it provides the best option given the large number of possible records involved, 
                // is searchable using query-based techniques, etc.  

                DataTable buckets = new DataTable();
                buckets.TableName = "BucketLevelValues";
                outProps.BucketLevelValues = buckets;

                buckets.Columns.Add("ParentSequence", System.Type.GetType("System.Int32"));

                // The following three items are copied in from the array above.  The redundancy is provided 
                // for convenience in searching, etc.  
                buckets.Columns.Add("FundID", System.Type.GetType("System.String"));
                buckets.Columns.Add("FundType", System.Type.GetType("System.String"));
                buckets.Columns.Add("MoneySource", System.Type.GetType("System.String"));

                // Recording the original line or row number so that Point to Point row can refer back 
                // to this bucket.  These rows may be reordered by user since this is a Data Table. 
                buckets.Columns.Add("LineNumber", System.Type.GetType("System.Int32"));

                buckets.Columns.Add("WindowDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("BucketValue", System.Type.GetType("System.Double"));
                buckets.Columns.Add("BucketDuration", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("CurrentRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("CurrentSegmentID", System.Type.GetType("System.String"));
                buckets.Columns.Add("CurrentRateID", System.Type.GetType("System.String"));
                buckets.Columns.Add("CurrentRule", System.Type.GetType("System.Int16"));
                buckets.Columns.Add("CurrentRateEffectiveDate", System.Type.GetType("System.Int32"));
                // 20140220-008:  Add Current Begin and End Date 
                buckets.Columns.Add("CurrentRateBeginDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("CurrentRateEndDate", System.Type.GetType("System.Int32"));

                buckets.Columns.Add("GuaranteedRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("GuaranteedSegmentID", System.Type.GetType("System.String"));
                buckets.Columns.Add("GuaranteedRateID", System.Type.GetType("System.String"));
                buckets.Columns.Add("GuaranteedRule", System.Type.GetType("System.Int16"));
                buckets.Columns.Add("GuaranteedRateEffectiveDate", System.Type.GetType("System.Int32"));
                // 20140220-008:  Add Guaranteed Begin and End Date 
                buckets.Columns.Add("GuaranteedRateBeginDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("GuaranteedRateEndDate", System.Type.GetType("System.Int32"));

                buckets.Columns.Add("OriginalPaymentDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("AppSignedDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("AppReceivedDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("AccountingTransCode", System.Type.GetType("System.Int16"));
                buckets.Columns.Add("RateLockEligible", System.Type.GetType("System.String"));
                buckets.Columns.Add("MaturityDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("EndingBalance", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InitialAmount", System.Type.GetType("System.Double"));
                buckets.Columns.Add("Withdrawals", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterestCredited", System.Type.GetType("System.Double"));
                buckets.Columns.Add("EstimatedIndexRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimParticipationDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimParticipationRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalParticipationDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalParticipationRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimBonusParticipationDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimBonusParticipationRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalBonusParticipationDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalBonusParticipationRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimVestingFactorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimVestingFactorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalVestingFactorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalVestingFactorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimCapDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimCapRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalCapDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalCapRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimFloorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimFloorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalFloorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalFloorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimSpreadDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("InterimSpreadRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalSpreadDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("FinalSpreadRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("StateMinParticipationRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("StartingIndexAverage", System.Type.GetType("System.Double"));
                buckets.Columns.Add("EndingIndexAverage", System.Type.GetType("System.Double"));
                buckets.Columns.Add("CreditedIndexRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("InterimRenewalCap", System.Type.GetType("System.Double"));
                buckets.Columns.Add("FinalRenewalCap", System.Type.GetType("System.Double"));
                buckets.Columns.Add("IndexEndCapDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("IndexEndCapRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("IndexEndFloorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("IndexEndFloorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("BailoutCapDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("BailoutCapRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("DailyOptionFactorDate", System.Type.GetType("System.Int32"));
                buckets.Columns.Add("DailyOptionFactorRate", System.Type.GetType("System.Double"));
                buckets.Columns.Add("OriginalSweepDate", System.Type.GetType("System.Int32"));
                //add bucket columns
                int bucketCount = apiBalance.getBucketRowCount();

                for (int b = 1; b <= bucketCount; b++)
                {
                    DataRow r = buckets.NewRow();
                    r["ParentSequence"] = apiBalance.getBucketParentSequence(b) - 1;

                    if (((int)r["ParentSequence"]) > -1 &&
                          ((int)r["ParentSequence"]) < count)
                    {
                        r["FundID"] = outProps.FundID[(int)r["ParentSequence"]];
                        r["FundType"] = outProps.FundType[(int)r["ParentSequence"]];
                        r["MoneySource"] = outProps.MoneySource[(int)r["ParentSequence"]];
                    }
                    r["LineNumber"] = b;
                    r["WindowDate"] = apiBalance.getBucketEffectiveDate(b);
                    r["BucketValue"] = apiBalance.getBucketValue(b);
                    r["BucketDuration"] = apiBalance.getBucketDuration(b);
                    r["CurrentRate"] = apiBalance.getBucketCurrentRate(b);
                    r["CurrentSegmentID"] = apiBalance.getBucketCurrentSegmentID(b);
                    r["CurrentRateID"] = apiBalance.getBucketCurrentRateID(b);
                    r["CurrentRule"] = apiBalance.getBucketCurrentRule(b);
                    r["CurrentRateEffectiveDate"] = apiBalance.getBucketCurrRateEffectiveDate(b);
                    r["CurrentRateBeginDate"] = apiBalance.getBucketCurrRateBeginDate(b);
                    r["CurrentRateEndDate"] = apiBalance.getBucketCurrRateEndDate(b);
                    r["GuaranteedRate"] = apiBalance.getBucketGuaranteedRate(b);
                    r["GuaranteedSegmentID"] = apiBalance.getBucketGuaranteedSegmentID(b);
                    r["GuaranteedRateID"] = apiBalance.getBucketGuaranteedRateID(b);
                    r["GuaranteedRule"] = apiBalance.getBucketGuaranteedRule(b);
                    r["GuaranteedRateEffectiveDate"] = apiBalance.getBucketGuarRateEffectiveDate(b);
                    r["GuaranteedRateBeginDate"] = apiBalance.getBucketGuarRateBeginDate(b);
                    r["GuaranteedRateEndDate"] = apiBalance.getBucketGuarRateEndDate(b);
                    r["OriginalPaymentDate"] = apiBalance.getBucketOriginalPaymentDate(b);
                    r["AppSignedDate"] = apiBalance.getBucketAppSignedDate(b);
                    r["AppReceivedDate"] = apiBalance.getBucketAppReceivedDate(b);
                    r["AccountingTransCode"] = apiBalance.getBucketAccountingTransCode(b);
                    r["RateLockEligible"] = apiBalance.getBucketRateLockEligible(b);
                    r["MaturityDate"] = apiBalance.getBucketMaturityDate(b);
                    r["EndingBalance"] = apiBalance.getBucketEndingBalance(b);
                    r["InitialAmount"] = apiBalance.getBucketInitialAmount(b);
                    r["Withdrawals"] = apiBalance.getBucketWithdrawals(b);
                    r["InterestCredited"] = apiBalance.getBucketInterestCredited(b);
                    r["EstimatedIndexRate"] = apiBalance.getBucketIndexRate(b);
                    r["InterimParticipationDate"] = apiBalance.getBucketItrmParticipDate(b);
                    r["InterimParticipationRate"] = apiBalance.getBucketItrmParticipRate(b);
                    r["FinalParticipationDate"] = apiBalance.getBucketFinalParticipDate(b);
                    r["FinalParticipationRate"] = apiBalance.getBucketFinalParticipRate(b);
                    r["InterimBonusParticipationDate"] = apiBalance.getBucketItrmBonParticipDate(b);
                    r["InterimBonusParticipationRate"] = apiBalance.getBucketItrmBonParticipRate(b);
                    r["FinalBonusParticipationDate"] = apiBalance.getBucketFinalBonParticipDate(b);
                    r["FinalBonusParticipationRate"] = apiBalance.getBucketFinalBonParticipRate(b);
                    r["InterimVestingFactorDate"] = apiBalance.getBucketItrmVestFactorDate(b);
                    r["InterimVestingFactorRate"] = apiBalance.getBucketItrmVestFactorRate(b);
                    r["FinalVestingFactorDate"] = apiBalance.getBucketFinalVestFactorDate(b);
                    r["FinalVestingFactorRate"] = apiBalance.getBucketFinalVestFactorRate(b);
                    r["InterimCapDate"] = apiBalance.getBucketItrmCapDate(b);
                    r["InterimCapRate"] = apiBalance.getBucketItrmCapRate(b);
                    r["FinalCapDate"] = apiBalance.getBucketFinalCapDate(b);
                    r["FinalCapRate"] = apiBalance.getBucketFinalCapRate(b);
                    r["InterimFloorDate"] = apiBalance.getBucketItrmFloorDate(b);
                    r["InterimFloorRate"] = apiBalance.getBucketItrmFloorRate(b);
                    r["FinalFloorDate"] = apiBalance.getBucketFinalFloorDate(b);
                    r["FinalFloorRate"] = apiBalance.getBucketFinalFloorRate(b);
                    r["InterimSpreadDate"] = apiBalance.getBucketItrmSpreadDate(b);
                    r["InterimSpreadRate"] = apiBalance.getBucketItrmSpreadRate(b);
                    r["FinalSpreadDate"] = apiBalance.getBucketFinalSpreadDate(b);
                    r["FinalSpreadRate"] = apiBalance.getBucketFinalSpreadRate(b);
                    r["StateMinParticipationRate"] = apiBalance.getBucketStateMinParticipRate(b);
                    r["StartingIndexAverage"] = apiBalance.getBucketStartingIndexAverage(b);
                    r["EndingIndexAverage"] = apiBalance.getBucketEndingIndexAverage(b);
                    r["CreditedIndexRate"] = apiBalance.getBucketCreditedIndexRate(b);
                    r["InterimRenewalCap"] = apiBalance.getBucketItrmRenewalCap(b);
                    r["FinalRenewalCap"] = apiBalance.getBucketFinalRenewalCap(b);
                    r["IndexEndCapDate"] = apiBalance.getBucketIndexEndCapDate(b);
                    r["IndexEndCapRate"] = apiBalance.getBucketIndexEndCapRate(b);
                    r["IndexEndFloorDate"] = apiBalance.getBucketIndexEndFloorDate(b);
                    r["IndexEndFloorRate"] = apiBalance.getBucketIndexEndFloorRate(b);
                    r["BailoutCapDate"] = apiBalance.getBucketBailoutCapDate(b);
                    r["BailoutCapRate"] = apiBalance.getBucketBailoutCapRate(b);
                    r["DailyOptionFactorDate"] = apiBalance.getBucketDailyOptionFactorDate(b);
                    r["DailyOptionFactorRate"] = apiBalance.getBucketDailyOptionFactorRate(b);
                    r["OriginalSweepDate"] = apiBalance.getBucketOriginalSweepDate(b);

                    buckets.Rows.Add(r);
                }


                DataTable points = new DataTable();
                points.TableName = "PointToPointValues";
                outProps.PointToPointValues = points;

                points.Columns.Add("BucketLine", System.Type.GetType("System.Int32"));
                points.Columns.Add("ADate", System.Type.GetType("System.Int32"));
                points.Columns.Add("ARate", System.Type.GetType("System.Double"));
                points.Columns.Add("BDate", System.Type.GetType("System.Int32"));
                points.Columns.Add("BRate", System.Type.GetType("System.Double"));
                points.Columns.Add("P2PDate", System.Type.GetType("System.Int32"));
                points.Columns.Add("P2PRate", System.Type.GetType("System.Double"));
                points.Columns.Add("P2PGrowth", System.Type.GetType("System.Double"));
                points.Columns.Add("P2PCapGrowth", System.Type.GetType("System.Double"));

                int pointRowCount = apiBalance.getPointRowCount();

                for (int p = 0; p < pointRowCount; p++)
                {

                    int bucketLine = apiBalance.getPointBucketLine(p + 1);
                    if (bucketLine != 0)
                    {

                        DataRow r = points.NewRow();
                        r["BucketLine"] = bucketLine;
                        r["ADate"] = apiBalance.getPointADate(p + 1);
                        r["ARate"] = apiBalance.getPointARate(p + 1);
                        r["BDate"] = apiBalance.getPointBDate(p + 1);
                        r["BRate"] = apiBalance.getPointBRate(p + 1);
                        r["P2PDate"] = apiBalance.getPointP2PDate(p + 1);
                        r["P2PRate"] = apiBalance.getPointP2PRate(p + 1);
                        r["P2PGrowth"] = apiBalance.getPointP2PGrowth(p + 1);
                        r["P2PCapGrowth"] = apiBalance.getPointP2PCapGrowth(p + 1);

                        points.Rows.Add(r);

                    }
                }




                outProps.GWResetStatus = apiBalance.getGWResetStatus();

                outProps.GWWithdrawalBenefitAvailable = apiBalance.getGWWithdrawalBenAvailable();
                outProps.GWSingleBenefitAvailable = apiBalance.getGWSingleBenAvailable();
                outProps.GWJointBenefitAvailable = apiBalance.getGWJointBenAvailable();

                outProps.GWWithdrawalEligiblePremiums = apiBalance.getGWWithdrawalEligiblePrems();
                outProps.GWRemainingWithdrawalBenefit = apiBalance.getGWRemainingWithdrawalBen();
                outProps.GWWithdrawalBenefitLastWithdrawalDate = apiBalance.getGWWithdBenLastWithdDate();
                outProps.GWWithdrawalGMWBPercentage = apiBalance.getGWWithdrawalGMWBPercentage();
                outProps.GWWithdrawalAnnualBenefit = apiBalance.getGWWithdrawalAnnualBen();
                outProps.GWWithdrawalBenefitWithdrawals = apiBalance.getGWWithdrawalBenWithdrawals();
                outProps.GWWithdrawalExcessRMD = apiBalance.getGWWithdrawalExcessRMD();
                outProps.GWWithdrawalAvailableAmount = apiBalance.getGWWithdrawalAvailableAmount();
                outProps.GWWaitPeriodEndDate = apiBalance.getGWWaitPeriodEndDate();


                outProps.GWLifetimeSingleLifetimeBasis = apiBalance.getGWLifeSingleLifetimeBasis();
                outProps.GWLifetimeSingleCarryoverAmount = apiBalance.getGWLifeSingleCarryoverAmount();
                outProps.GWLifetimeSingleExcessRMD = apiBalance.getGWLifeSingleExcessRMD();
                outProps.GWLifetimeSingleWithdrawals = apiBalance.getGWLifeSingleWithdrawals();
                outProps.GWLifetimeSingleLastWithdrawalDate = apiBalance.getGWLifeSingleLastWithdDate();
                outProps.GWLifetimeSingleGMWBPercentage = apiBalance.getGWLifeSingleGMWBPercentage();
                outProps.GWLifetimeSingleAnnualBenefit = apiBalance.getGWLifeSingleAnnualBen();
                outProps.GWLifetimeSingleAvailableAmount = apiBalance.getGWLifeSingleAvailableAmt();
                outProps.GWLifetimeSingleEarliestIncomeDate = apiBalance.getGWLifeSingleEarliestIncDate();
                outProps.GWLifetimeSingleBasisRolledUpValue = apiBalance.getGWLifeSingleRolledUp();
                outProps.GWLifetimeSingleRollupToDate = apiBalance.getGWLifeSingleRolledUpToDate();

                outProps.GWLifetimeSingleDepositBonus = apiBalance.getGWLifeSingleDepositBonus();
                outProps.GWLifetimeSingleDepositBasis = apiBalance.getGWLifeSingleDepositBasis();
                outProps.GWLifetimeSingleDeathBasis = apiBalance.getGWLifeSingleDeathBasis();
                outProps.GWLifetimeSingleMaxAnniversaryValue = apiBalance.getGWLifeSingleMaxAnniv();
                outProps.GWLifetimeSingleExcessWithdrawalTaken = (apiBalance.getGWLifeSingleExcessWithd() == "Y") ? true : false;
                outProps.GWLifetimeSingleRestoreUsed = (apiBalance.getGWLifeSingleRestore() == "Y") ? true : false;

                outProps.GWLifetimeJointLifetimeBasis = apiBalance.getGWLifeJointLifetimeBasis();
                outProps.GWLifetimeJointCarryoverAmount = apiBalance.getGWLifeJointCarryoverAmount();
                outProps.GWLifetimeJointExcessRMD = apiBalance.getGWLifeJointExcessRMD();
                outProps.GWLifetimeJointWithdrawals = apiBalance.getGWLifeJointWithdrawals();
                outProps.GWLifetimeJointLastWithdrawalDate = apiBalance.getGWLifeJointLastWithdDate();
                outProps.GWLifetimeJointGMWBPercentage = apiBalance.getGWLifeJointGMWBPercentage();
                outProps.GWLifetimeJointAnnualBenefit = apiBalance.getGWLifeJointAnnualBen();
                outProps.GWLifetimeJointAvailableAmount = apiBalance.getGWLifeJointAvailableAmt();
                outProps.GWLifetimeJointEarliestIncomeDate = apiBalance.getGWLifeJointEarliestIncDate();

                outProps.GWLifetimeJointBasisRolledUpValue = apiBalance.getGWLifeJointRolledUp();
                outProps.GWLifetimeJointRollupToDate = apiBalance.getGWLifeJointRolledUpToDate();
                outProps.GWLifetimeJointDepositBonus = apiBalance.getGWLifeJointDepositBonus();
                outProps.GWLifetimeJointDepositBasis = apiBalance.getGWLifeJointDepositBasis();
                outProps.GWLifetimeJointDeathBasis = apiBalance.getGWLifeJointDeathBasis();
                outProps.GWLifetimeJointMaxAnniversaryValue = apiBalance.getGWLifeJointMaxAnniv();
                outProps.GWLifetimeJointExcessWithdrawalTaken = (apiBalance.getGWLifeJointExcessWithd() == "Y") ? true : false;
                outProps.GWLifetimeJointRestoreUsed = (apiBalance.getGWLifeJointRestore() == "Y") ? true : false;



                outProps.GWBenefitPhaseStartDate = apiBalance.getGWBenPhaseStartDate();
                outProps.GWLastResetDate = apiBalance.getGWLastResetDate();
                outProps.GWLastPremiumDate = apiBalance.getGWLastPremiumDate();
                outProps.GWNextResetDate = apiBalance.getGWNextResetDate();
                outProps.GWLastRateChangeDate = apiBalance.getGWLastRateChangeDate();

                outProps.GuarRetireTotalDue = apiBalance.getGuarRetireTotalDue();
                count = apiBalance.getGuarRetirePaymentDueCount();
                outProps.GRPaymentDueBenefitSeq = new int[count];
                outProps.GRPaymentDueDueDate = new int[count];
                outProps.GRPaymentDueEffectiveDate = new int[count];
                outProps.GRPaymentDueWithdrawalEffectiveDate = new int[count];
                outProps.GRPaymentDueDueType = new string[count];
                outProps.GRPaymentDueAmountDue = new double[count];
                outProps.GRPaymentDueAmountPaid = new double[count];
                outProps.GRPaymentDueModePremium = new double[count];

                for (int i = 1; i <= count; i++)
                {
                    outProps.GRPaymentDueBenefitSeq[i - 1] = apiBalance.getGRPaymentDueBenefitSeq(i);
                    outProps.GRPaymentDueDueDate[i - 1] = apiBalance.getGRPaymentDueDueDate(i);
                    outProps.GRPaymentDueEffectiveDate[i - 1] = apiBalance.getGRPaymentDueEffectiveDate(i);
                    outProps.GRPaymentDueWithdrawalEffectiveDate[i - 1] = apiBalance.getGRPaymentDueWithdEffDate(i);
                    outProps.GRPaymentDueDueType[i - 1] = apiBalance.getGRPaymentDueDueType(i);
                    outProps.GRPaymentDueAmountDue[i - 1] = apiBalance.getGRPaymentDueAmountDue(i);
                    outProps.GRPaymentDueAmountPaid[i - 1] = apiBalance.getGRPaymentDueAmountPaid(i);
                    outProps.GRPaymentDueModePremium[i - 1] = apiBalance.getGRPaymentDueModePremium(i);
                }


                Log.AddDetailedLogEntry("TCP Balance Inquiry RunInquiry Call.  Returning from RunInquiry now for policy  " + inProps.PolicyNumber);  
                return outProps;
        
        }


        public BalanceInquiryQuoteResponse RunQuoteOnly(BalanceInquiryRequest inProps)
        {
			apiBalance.setCompanyCode(inProps.CompanyCode);
			apiBalance.setPolicyNumber(inProps.PolicyNumber);
			apiBalance.setEffectiveDate(inProps.EffectiveDate);
            apiBalance.setStopSearchDate(inProps.StopSearchDate);   // only used in retrieval of GWLastRateChangeDate  

            if (inProps.OverrideFutureDateEdits)
                apiBalance.setOverrideFutureDateEdits("Y");
            else
                apiBalance.setOverrideFutureDateEdits("N"); 

			apiBalance.RunInquiry(); 

			BalanceInquiryQuoteResponse outProps = new BalanceInquiryQuoteResponse() ; 
			outProps.ReturnCode = apiBalance.getReturnCode();  
			outProps.ErrorMessage = apiBalance.getErrorMessage();  

			outProps.ActiveRequests = apiBalance.getActiveRequests().Trim();
			outProps.MultipleLoans = apiBalance.getMultipleLoans().Trim();
			outProps.QuoteDate = apiBalance.getQuoteDate();
			outProps.ProcessToDate = apiBalance.getProcessToDate();
			outProps.LastValuationDate = apiBalance.getLastValuationDate();
            outProps.LastAnniversaryDate = apiBalance.getLastAnniversaryDate(); 
			outProps.GrossDeposits = apiBalance.getGrossDeposits();
			outProps.GrossWithdrawals = apiBalance.getGrossWithdrawals();
			outProps.LoanBalance = apiBalance.getLoanBalance();
			outProps.TotalFundBalance = apiBalance.getTotalFundBalance();
            outProps.AssetAllocationModelFlag = apiBalance.getAssetAllocationModelFlag();
            outProps.AssetAllocationModelStatus = apiBalance.getAssetAllocationModelStatus();  

            outProps.PremiumIncrementRule = apiBalance.getPremiumIncrementRule();  
            outProps.SumRowCount = apiBalance.getSumRowCount();
            int count = outProps.SumRowCount;
            outProps.SumRow = new int[count];
            outProps.SumSource = new string[count];
            outProps.SumSourceDesc = new string[count];
            outProps.SumFundBalance = new double[count];  

            
            // Values below this point are stubbed for GIA Riders: 
            outProps.SumFreeAmount = new double[count];
            outProps.SumLoad = new double[count];
            outProps.SumGrossDeposits = new double[count];
            outProps.SumGrossWithdrawals = new double[count];  
            outProps.SumStartDate = new int[count]; 
            outProps.SumIncomeStartDate = new int[count];            
            outProps.SumIncomeStartDate = new int[count]; 
            outProps.SumPeriodCertain = new int[count];  
            outProps.SumGuaranteeStatus = new string[count];  
            outProps.SumGuaranteeStatusDate = new int[count];   
            outProps.SumGuaranteeIncomeFactor = new double[count];  
            outProps.SumGuaranteeIncome = new double[count];   
            outProps.SumVestedAnnualIncome = new double[count];
            outProps.SumVestedMonthlyIncome = new double[count];   
            outProps.SumScheduledTransferAmount = new double[count];
            outProps.SumAccumulatedPrepaymentAmount = new double[count];   
            outProps.SumRemainingPrepaymentTransfers = new double[count];
            outProps.SumAmountToFullyFund = new double[count];
            // End stubbed values for GIA Riders


            for (int i = 1; i <= count; i++)
            {
                outProps.SumRow[i - 1] = apiBalance.getSumRow(i);
                outProps.SumSource[i - 1] = apiBalance.getSumSource(i);
                outProps.SumSourceDesc[i - 1] = apiBalance.getSumSourceDesc(i);
                outProps.SumFundBalance[i - 1] = apiBalance.getSumFundBalance(i);
                outProps.SumFreeAmount[i - 1] = apiBalance.getSumFreeAmount(i);
                outProps.SumLoad[i - 1] = apiBalance.getSumLoad(i);
                outProps.SumGrossDeposits[i - 1] = apiBalance.getSumGrossDeposits(i);
                outProps.SumGrossWithdrawals[i - 1] = apiBalance.getSumGrossWithdrawals(i);  
                outProps.SumStartDate[i - 1] = apiBalance.getSumStartDate(i);
                outProps.SumIncomeStartDate[i - 1] = apiBalance.getSumIncomeStartDate(i);
                outProps.SumPeriodCertain[i-1] = apiBalance.getSumPeriodCertain(i);
                outProps.SumGuaranteeStatus[i - 1] = apiBalance.getSumGuaranteeStatus(i);
                outProps.SumGuaranteeStatusDate[i - 1] = apiBalance.getSumGuaranteeStatusDate(i); 
                outProps.SumGuaranteeIncomeFactor[i - 1] = apiBalance.getSumGuaranteeIncomeFactor(i);
                outProps.SumGuaranteeIncome[i - 1] = apiBalance.getSumGuaranteeIncomeFactor(i);
                outProps.SumVestedAnnualIncome[i - 1] = apiBalance.getSumVestedAnnualIncome(i);
                outProps.SumVestedMonthlyIncome[i - 1] = apiBalance.getSumVestedMonthlyIncome(i);
                outProps.SumScheduledTransferAmount[i - 1] = apiBalance.getSumScheduledTransferAmount(i);
                outProps.SumAccumulatedPrepaymentAmount[i - 1] = apiBalance.getSumAccumPrepaymentAmount(i);
                outProps.SumRemainingPrepaymentTransfers[i - 1] = apiBalance.getSumRemainPrepayTransfers(i);
                outProps.SumAmountToFullyFund[i - 1] = apiBalance.getSumAmountToFullyFund(i);
            }

			outProps.RowCount = apiBalance.getRowCount();
            outProps.TotalCostBasis = apiBalance.getTotalCostBasis();
            outProps.PreTefraCostBasis = apiBalance.getPreTefraCostBasis();
            outProps.CurrentEarningsRate = apiBalance.getCurrentEarningsRate();
            outProps.IndexEarningsRate = apiBalance.getIndexEarningsRate();
            outProps.GuaranteedEarningsRate = apiBalance.getGuarEarningsRate();
            outProps.CurrentEarningsAmountToDate = apiBalance.getCurrentEarningsAmountToDate();
            outProps.IndexEarningsAmountToDate = apiBalance.getIndexEarningsAmountToDate();
            //20150805-006-36 SAP Invest Next Phase2
            outProps.FinancialRptInd = apiBalance.getFinancialRptInd();
            outProps.PolicyCode = apiBalance.getPolicyCode();
            outProps.PolicyMatureExpDate = apiBalance.getPolicyMatureExpDate();
            outProps.PolicyRebalDate = apiBalance.getPolicyRebalDate();
            outProps.PolicyRebalFlag = apiBalance.getPolicyRebalFlag();
            outProps.HybridBOTDate = apiBalance.getHybridBOTDate();
            outProps.HybridEOTDate = apiBalance.getHybridEOTDate();
            outProps.HybridEOTHoldDate = apiBalance.getHybridEOTHoldDate();
            outProps.HybridHoldAcctStatus = apiBalance.getHybridHoldAcctStatus();

			count = outProps.RowCount ; 
            outProps.RowNumber = new int[count];  
			outProps.MoneySource = new string[count];  
			outProps.FundID = new string[count]; 
			outProps.ShortDescription = new string[count];  
			outProps.LongDescription = new string[count]; 
			outProps.FundType = new string[count];  
			outProps.Units = new double[count];  
			outProps.UnitValue = new double[count]; 
			outProps.UnitValueDate = new int[count];  
			outProps.FundBalance = new double[count];
            // Added Fund Table items - 02/03/2016, GWT, for 20151130-001-01 
            outProps.FundModelTableIndex = new int[count];
            outProps.FundSubModelTableIndex = new int[count];
            outProps.FundModelName = new string[count];
            outProps.FundModelVersion = new int[count];
            outProps.FundSubModelName = new string[count];
            outProps.FundSubModelAllocation = new double[count];
            outProps.FundHybridCap = new double[count];
            outProps.FundHybridFloor = new double[count];
            //20150805-006-36 SAP Invest Next Phase2 
            outProps.FundBOTAnnvIndex = new double[count];
            outProps.FundCurrIndex = new double[count];

			for (int i=1;i<=count;i++) 
			{
                outProps.RowNumber[i - 1] = apiBalance.getRowNumber(i); 
				outProps.MoneySource[i-1] = apiBalance.getMoneySource(i).Trim();  
				outProps.FundID[i-1] = apiBalance.getFundID(i).Trim();  
				outProps.ShortDescription[i-1] = apiBalance.getShortDescription(i).Trim();  
				outProps.LongDescription[i-1] = apiBalance.getLongDescription(i).Trim();  
				outProps.FundType[i-1] = apiBalance.getFundType(i).Trim();  
				outProps.Units[i-1] = apiBalance.getUnits(i);  
				outProps.UnitValue[i-1] = apiBalance.getUnitValue(i);  
				outProps.UnitValueDate[i-1] = apiBalance.getUnitValueDate(i);  
				outProps.FundBalance[i-1] = apiBalance.getFundBalance(i);  
                // Added Fund Table items - 02/03/2016, GWT, for 20151130-001-01 
                outProps.FundModelTableIndex[i-1] = apiBalance.getFundModel(i);
                outProps.FundSubModelTableIndex[i-1] = apiBalance.getFundSubModel(i);
                outProps.FundModelName[i-1] = apiBalance.getModelID(outProps.FundModelTableIndex[i-1]);
                outProps.FundModelVersion[i-1] = apiBalance.getModelVersion(outProps.FundModelTableIndex[i-1]);
                outProps.FundSubModelName[i-1] = apiBalance.getSubModelID(outProps.FundSubModelTableIndex[i-1]);
                outProps.FundSubModelAllocation[i-1] = apiBalance.getFundSubAlloc(i);
                outProps.FundHybridCap[i-1] = apiBalance.getFundHybridCap(i);
                outProps.FundHybridFloor[i-1] = apiBalance.getFundHybridFloor(i);
                //20150805-006-36 SAP Invest Next Phase2 
                outProps.FundBOTAnnvIndex[i - 1] = apiBalance.getFundBOTAnnvIndex(i);
                outProps.FundCurrIndex[i - 1] = apiBalance.getFundCurrIndex(i);
			}

            // Added additional output - 02/03/2016, GWT, for 20151130-001-01
            outProps.ProfileID = apiBalance.getProfileID();
            outProps.ProfileDescription = apiBalance.getProfileDesc();

            // Added Model Table - 02/03/2016, GWT, for 20151130-001-01 
            outProps.ModelCount = apiBalance.getLastModel();
            int mCount = outProps.ModelCount;
            outProps.ModelName = new string[mCount];
            outProps.ModelVersion = new int[mCount];
            outProps.ModelMDLMIdent = new long[mCount];
            outProps.ModelType = new string[mCount];
            outProps.ModelBalance = new double[mCount];
            outProps.ModelSubModelCount = new int[mCount];
            //20150805-006-36 SAP Invest Next Phase2 
            outProps.ModelRebalFlag = new string[mCount];
            outProps.ModelRebalDate = new int[mCount];

            for (int i = 1; i <= mCount; i++)
            {
                outProps.ModelName[i-1] = apiBalance.getModelID(i).Trim();
                outProps.ModelVersion[i-1] = apiBalance.getModelVersion(i);
                outProps.ModelMDLMIdent[i-1] = apiBalance.getModelMdlmIdent(i);
                outProps.ModelType[i-1] = apiBalance.getModelType(i).Trim();
                outProps.ModelBalance[i-1] = apiBalance.getModelBalance(i);
                outProps.ModelSubModelCount[i-1] = apiBalance.getModelSubModelCount(i);
                //20150805-006-36 SAP Invest Next Phase2 
                outProps.ModelRebalFlag[i - 1] = apiBalance.getModelRebalFlag(i);
                outProps.ModelRebalDate[i - 1] = apiBalance.getModelRebalDate(i);
            }

            // Added Sub-Model Table - 02/03/2016, GWT, for 20151130-001-01 
            outProps.SubModelCount = apiBalance.getLastSubModel();
            int sCount = outProps.SubModelCount;
            outProps.SubModelModelTableIndex = new int[sCount];
            outProps.SubModelModelName = new string[sCount];
            outProps.SubModelModelVersion = new int[sCount];
            outProps.SubModelName = new string[sCount];
            outProps.SubModelMDLBIdent = new long[sCount];
            outProps.SubModelBalance = new double[sCount];
            outProps.SubModelHybridCap = new double[sCount];
            outProps.SubModelHybridFloor = new double[sCount];
            //20150805-006-36 SAP Invest Next Phase2 
            outProps.SubModelRebalFlag = new string[sCount];
            outProps.SubModelRebalDate = new int[sCount];

            for (int i = 1; i <= sCount; i++)
            {
                 outProps.SubModelModelTableIndex[i-1] = apiBalance.getSubModelModel(i);
                 outProps.SubModelModelName[i-1] = outProps.ModelName[apiBalance.getSubModelModel(i)-1];
                 outProps.SubModelModelVersion[i-1] = outProps.ModelVersion[apiBalance.getSubModelModel(i)-1];
                 outProps.SubModelName[i-1] = apiBalance.getSubModelID(i).Trim();
                 outProps.SubModelMDLBIdent[i-1] = apiBalance.getSubModelMdlbIdent(i);
                 outProps.SubModelBalance[i-1] = apiBalance.getSubModelBalance(i);
                 outProps.SubModelHybridCap[i-1] = apiBalance.getSubModelHybridCap(i);
                 outProps.SubModelHybridFloor[i-1] = apiBalance.getSubModelHybridFloor(i);
                 //20150805-006-36 SAP Invest Next Phase2 
                 outProps.SubModelRebalFlag[i - 1] = apiBalance.getSubModelRebalFlag(i);
                 outProps.SubModelRebalDate[i - 1] = apiBalance.getSubModelRebalDate(i);
            }
		
            // Load up a DataTable structure with bucket-level values.  We use a DataTable here 
            // because it provides the best option given the large number of possible records involved, 
            // is searchable using query-based techniques, etc.  

            DataTable buckets = new DataTable();
            buckets.TableName = "BucketLevelValues";
            outProps.BucketLevelValues = buckets;

            buckets.Columns.Add("ParentSequence", System.Type.GetType("System.Int32"));

            // The following three items are copied in from the array above.  The redundancy is provided 
            // for convenience in searching, etc.  
            buckets.Columns.Add("FundID", System.Type.GetType("System.String"));
            buckets.Columns.Add("FundType", System.Type.GetType("System.String"));
            buckets.Columns.Add("MoneySource", System.Type.GetType("System.String"));

            // Recording the original line or row number so that Point to Point row can refer back 
            // to this bucket.  These rows may be reordered by user since this is a Data Table. 
            buckets.Columns.Add("LineNumber", System.Type.GetType("System.Int32")); 

            buckets.Columns.Add("WindowDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("BucketValue", System.Type.GetType("System.Double"));
            buckets.Columns.Add("BucketDuration", System.Type.GetType("System.Int32"));  
            buckets.Columns.Add("CurrentRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("CurrentSegmentID", System.Type.GetType("System.String"));
            buckets.Columns.Add("CurrentRateID", System.Type.GetType("System.String"));
            buckets.Columns.Add("CurrentRule", System.Type.GetType("System.Int16"));       
            buckets.Columns.Add("CurrentRateEffectiveDate", System.Type.GetType("System.Int32"));
            // 20140220-008:  Add Current Begin and End Date 
            buckets.Columns.Add("CurrentRateBeginDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("CurrentRateEndDate", System.Type.GetType("System.Int32"));

            buckets.Columns.Add("GuaranteedRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("GuaranteedSegmentID", System.Type.GetType("System.String")); 
            buckets.Columns.Add("GuaranteedRateID", System.Type.GetType("System.String"));
            buckets.Columns.Add("GuaranteedRule", System.Type.GetType("System.Int16"));       
            buckets.Columns.Add("GuaranteedRateEffectiveDate", System.Type.GetType("System.Int32"));
            // 20140220-008:  Add Guaranteed Begin and End Date 
            buckets.Columns.Add("GuaranteedRateBeginDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("GuaranteedRateEndDate", System.Type.GetType("System.Int32"));

            buckets.Columns.Add("OriginalPaymentDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("AppSignedDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("AppReceivedDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("AccountingTransCode", System.Type.GetType("System.Int16"));
            buckets.Columns.Add("RateLockEligible", System.Type.GetType("System.String"));
            buckets.Columns.Add("MaturityDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("EndingBalance", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InitialAmount", System.Type.GetType("System.Double"));
            buckets.Columns.Add("Withdrawals", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterestCredited", System.Type.GetType("System.Double"));
            buckets.Columns.Add("EstimatedIndexRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimParticipationDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimParticipationRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalParticipationDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalParticipationRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimBonusParticipationDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimBonusParticipationRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalBonusParticipationDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalBonusParticipationRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimVestingFactorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimVestingFactorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalVestingFactorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalVestingFactorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimCapDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimCapRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalCapDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalCapRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimFloorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimFloorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalFloorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalFloorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimSpreadDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("InterimSpreadRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalSpreadDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("FinalSpreadRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("StateMinParticipationRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("StartingIndexAverage", System.Type.GetType("System.Double"));
            buckets.Columns.Add("EndingIndexAverage", System.Type.GetType("System.Double"));
            buckets.Columns.Add("CreditedIndexRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("InterimRenewalCap", System.Type.GetType("System.Double"));
            buckets.Columns.Add("FinalRenewalCap", System.Type.GetType("System.Double"));
            buckets.Columns.Add("IndexEndCapDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("IndexEndCapRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("IndexEndFloorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("IndexEndFloorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("BailoutCapDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("BailoutCapRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("DailyOptionFactorDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("DailyOptionFactorRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("OriginalSweepDate", System.Type.GetType("System.Int32"));
            //add bucket columns
            int bucketCount = apiBalance.getBucketRowCount();  

            for (int b = 1; b <= bucketCount; b++)
            {
                DataRow r = buckets.NewRow();
                r["ParentSequence"] = apiBalance.getBucketParentSequence(b) - 1 ;

                if (((int)r["ParentSequence"]) > -1 &&
                      ((int)r["ParentSequence"]) < count)
                {
                    r["FundID"] = outProps.FundID[(int)r["ParentSequence"]];
                    r["FundType"] = outProps.FundType[(int)r["ParentSequence"]];
                    r["MoneySource"] = outProps.MoneySource[(int)r["ParentSequence"]];
                }
                r["LineNumber"] = b;    
                r["WindowDate"] = apiBalance.getBucketEffectiveDate(b);
                r["BucketValue"] = apiBalance.getBucketValue(b);
                r["BucketDuration"] = apiBalance.getBucketDuration(b);   
                r["CurrentRate"] = apiBalance.getBucketCurrentRate(b);
                r["CurrentSegmentID"] = apiBalance.getBucketCurrentSegmentID(b);  
                r["CurrentRateID"] = apiBalance.getBucketCurrentRateID(b);
                r["CurrentRule"] = apiBalance.getBucketCurrentRule(b);   
                r["CurrentRateEffectiveDate"] = apiBalance.getBucketCurrRateEffectiveDate(b);
                r["CurrentRateBeginDate"] = apiBalance.getBucketCurrRateBeginDate(b);
                r["CurrentRateEndDate"] = apiBalance.getBucketCurrRateEndDate(b); 
                r["GuaranteedRate"] = apiBalance.getBucketGuaranteedRate(b);
                r["GuaranteedSegmentID"] = apiBalance.getBucketGuaranteedSegmentID(b);  
                r["GuaranteedRateID"] = apiBalance.getBucketGuaranteedRateID(b);
                r["GuaranteedRule"] = apiBalance.getBucketGuaranteedRule(b);  
                r["GuaranteedRateEffectiveDate"] = apiBalance.getBucketGuarRateEffectiveDate(b);
                r["GuaranteedRateBeginDate"] = apiBalance.getBucketGuarRateBeginDate(b);
                r["GuaranteedRateEndDate"] = apiBalance.getBucketGuarRateEndDate(b);
                r["OriginalPaymentDate"] = apiBalance.getBucketOriginalPaymentDate(b);
                r["AppSignedDate"] = apiBalance.getBucketAppSignedDate(b);
                r["AppReceivedDate"] = apiBalance.getBucketAppReceivedDate(b);
                r["AccountingTransCode"] = apiBalance.getBucketAccountingTransCode(b);
                r["RateLockEligible"] = apiBalance.getBucketRateLockEligible(b);
                r["MaturityDate"] = apiBalance.getBucketMaturityDate(b);
                r["EndingBalance"] = apiBalance.getBucketEndingBalance(b);
                r["InitialAmount"] = apiBalance.getBucketInitialAmount(b);
                r["Withdrawals"] = apiBalance.getBucketWithdrawals(b);
                r["InterestCredited"] = apiBalance.getBucketInterestCredited(b);
                r["EstimatedIndexRate"] = apiBalance.getBucketIndexRate(b);
                r["InterimParticipationDate"] = apiBalance.getBucketItrmParticipDate(b);
                r["InterimParticipationRate"] = apiBalance.getBucketItrmParticipRate(b);
                r["FinalParticipationDate"] = apiBalance.getBucketFinalParticipDate(b);
                r["FinalParticipationRate"] = apiBalance.getBucketFinalParticipRate(b);
                r["InterimBonusParticipationDate"] = apiBalance.getBucketItrmBonParticipDate(b);
                r["InterimBonusParticipationRate"] = apiBalance.getBucketItrmBonParticipRate(b);
                r["FinalBonusParticipationDate"] = apiBalance.getBucketFinalBonParticipDate(b);
                r["FinalBonusParticipationRate"] = apiBalance.getBucketFinalBonParticipRate(b);
                r["InterimVestingFactorDate"] = apiBalance.getBucketItrmVestFactorDate(b);
                r["InterimVestingFactorRate"] = apiBalance.getBucketItrmVestFactorRate(b);
                r["FinalVestingFactorDate"] = apiBalance.getBucketFinalVestFactorDate(b);
                r["FinalVestingFactorRate"] = apiBalance.getBucketFinalVestFactorRate(b);
                r["InterimCapDate"] = apiBalance.getBucketItrmCapDate(b);
                r["InterimCapRate"] = apiBalance.getBucketItrmCapRate(b);
                r["FinalCapDate"] = apiBalance.getBucketFinalCapDate(b);
                r["FinalCapRate"] = apiBalance.getBucketFinalCapRate(b);
                r["InterimFloorDate"] = apiBalance.getBucketItrmFloorDate(b);
                r["InterimFloorRate"] = apiBalance.getBucketItrmFloorRate(b);
                r["FinalFloorDate"] = apiBalance.getBucketFinalFloorDate(b);
                r["FinalFloorRate"] = apiBalance.getBucketFinalFloorRate(b);
                r["InterimSpreadDate"] = apiBalance.getBucketItrmSpreadDate(b);
                r["InterimSpreadRate"] = apiBalance.getBucketItrmSpreadRate(b);
                r["FinalSpreadDate"] = apiBalance.getBucketFinalSpreadDate(b);
                r["FinalSpreadRate"] = apiBalance.getBucketFinalSpreadRate(b);
                r["StateMinParticipationRate"] = apiBalance.getBucketStateMinParticipRate(b);
                r["StartingIndexAverage"] = apiBalance.getBucketStartingIndexAverage(b);
                r["EndingIndexAverage"] = apiBalance.getBucketEndingIndexAverage(b);
                r["CreditedIndexRate"] = apiBalance.getBucketCreditedIndexRate(b);
                r["InterimRenewalCap"] = apiBalance.getBucketItrmRenewalCap(b);
                r["FinalRenewalCap"] = apiBalance.getBucketFinalRenewalCap(b);
                r["IndexEndCapDate"] = apiBalance.getBucketIndexEndCapDate(b);
                r["IndexEndCapRate"] = apiBalance.getBucketIndexEndCapRate(b);
                r["IndexEndFloorDate"] = apiBalance.getBucketIndexEndFloorDate(b);
                r["IndexEndFloorRate"] = apiBalance.getBucketIndexEndFloorRate(b);
                r["BailoutCapDate"] = apiBalance.getBucketBailoutCapDate(b);
                r["BailoutCapRate"] = apiBalance.getBucketBailoutCapRate(b);
                r["DailyOptionFactorDate"] = apiBalance.getBucketDailyOptionFactorDate(b);
                r["DailyOptionFactorRate"] = apiBalance.getBucketDailyOptionFactorRate(b);
                r["OriginalSweepDate"] = apiBalance.getBucketOriginalSweepDate(b);

                buckets.Rows.Add(r);  
            }


            DataTable points = new DataTable();
            points.TableName = "PointToPointValues";
            outProps.PointToPointValues = points;

            points.Columns.Add("BucketLine", System.Type.GetType("System.Int32"));
            points.Columns.Add("ADate", System.Type.GetType("System.Int32"));
            points.Columns.Add("ARate", System.Type.GetType("System.Double"));
            points.Columns.Add("BDate", System.Type.GetType("System.Int32"));
            points.Columns.Add("BRate", System.Type.GetType("System.Double"));
            points.Columns.Add("P2PDate", System.Type.GetType("System.Int32"));
            points.Columns.Add("P2PRate", System.Type.GetType("System.Double"));
            points.Columns.Add("P2PGrowth", System.Type.GetType("System.Double"));
            points.Columns.Add("P2PCapGrowth", System.Type.GetType("System.Double"));

            int pointRowCount = apiBalance.getPointRowCount(); 

            for (int p = 0; p < pointRowCount; p++) 
            {

                int bucketLine =  apiBalance.getPointBucketLine(p + 1);  
                if (bucketLine != 0)
                {

                    DataRow r = points.NewRow();
                    r["BucketLine"] = bucketLine;
                    r["ADate"] = apiBalance.getPointADate(p + 1);
                    r["ARate"] = apiBalance.getPointARate(p + 1);
                    r["BDate"] = apiBalance.getPointBDate(p + 1);
                    r["BRate"] = apiBalance.getPointBRate(p + 1);
                    r["P2PDate"] = apiBalance.getPointP2PDate(p + 1);
                    r["P2PRate"] = apiBalance.getPointP2PRate(p + 1);
                    r["P2PGrowth"] = apiBalance.getPointP2PGrowth(p + 1); 
                    r["P2PCapGrowth"] = apiBalance.getPointP2PCapGrowth(p + 1); 

                    points.Rows.Add(r); 

                }
            }
            Log.AddDetailedLogEntry("TCP Balance Inquiry RunQuoteOnly Call.  Returning from RunQuoteOnly now for policy  " + inProps.PolicyNumber);  
            return outProps;  

        }
        
        public BalanceInquiryGuaranteedWithdrawalResponse GetGuaranteedWithdrawalValues(BalanceInquiryRequest inProps)
        {

            Log.AddDetailedLogEntry("Starting TCP Balance Inquiry GetGuaranteedWithdrawalValues Call.  Call is for policy " + inProps.PolicyNumber);  


            apiBalance.setCompanyCode(inProps.CompanyCode);
            apiBalance.setPolicyNumber(inProps.PolicyNumber);
            apiBalance.setEffectiveDate(inProps.EffectiveDate);
            apiBalance.setStopSearchDate(inProps.StopSearchDate);   // only used in retrieval of GWLastRateChangeDate  

            apiBalance.setFunctionFlag("G");  // Decides operation ... "G" means GW Rider info only  

            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedWithdrawalValues Call.  Just before OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);  
            apiBalance.RunInquiry();
            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedWithdrawalValues  Call.  Just after OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);  


            BalanceInquiryGuaranteedWithdrawalResponse outProps = new BalanceInquiryGuaranteedWithdrawalResponse();
            outProps.ReturnCode = apiBalance.getReturnCode();
            outProps.ErrorMessage = apiBalance.getErrorMessage();
            outProps.GWResetStatus = apiBalance.getGWResetStatus();

            outProps.GWWithdrawalBenefitAvailable = apiBalance.getGWWithdrawalBenAvailable();
            outProps.GWSingleBenefitAvailable = apiBalance.getGWSingleBenAvailable();
            outProps.GWJointBenefitAvailable = apiBalance.getGWJointBenAvailable();

            outProps.GWWithdrawalEligiblePremiums = apiBalance.getGWWithdrawalEligiblePrems();
            outProps.GWRemainingWithdrawalBenefit = apiBalance.getGWRemainingWithdrawalBen();
            outProps.GWWithdrawalBenefitLastWithdrawalDate = apiBalance.getGWWithdBenLastWithdDate();
            outProps.GWWithdrawalGMWBPercentage = apiBalance.getGWWithdrawalGMWBPercentage();
            outProps.GWWithdrawalAnnualBenefit = apiBalance.getGWWithdrawalAnnualBen();
            outProps.GWWithdrawalBenefitWithdrawals = apiBalance.getGWWithdrawalBenWithdrawals();
            outProps.GWWithdrawalExcessRMD = apiBalance.getGWWithdrawalExcessRMD();
            outProps.GWWithdrawalAvailableAmount = apiBalance.getGWWithdrawalAvailableAmount();
            outProps.GWWaitPeriodEndDate = apiBalance.getGWWaitPeriodEndDate();


            outProps.GWLifetimeSingleLifetimeBasis = apiBalance.getGWLifeSingleLifetimeBasis();
            outProps.GWLifetimeSingleCarryoverAmount = apiBalance.getGWLifeSingleCarryoverAmount();
            outProps.GWLifetimeSingleExcessRMD = apiBalance.getGWLifeSingleExcessRMD();
            outProps.GWLifetimeSingleWithdrawals = apiBalance.getGWLifeSingleWithdrawals();
            outProps.GWLifetimeSingleLastWithdrawalDate = apiBalance.getGWLifeSingleLastWithdDate();
            outProps.GWLifetimeSingleGMWBPercentage = apiBalance.getGWLifeSingleGMWBPercentage();
            outProps.GWLifetimeSingleAnnualBenefit = apiBalance.getGWLifeSingleAnnualBen();
            outProps.GWLifetimeSingleAvailableAmount = apiBalance.getGWLifeSingleAvailableAmt();
            outProps.GWLifetimeSingleEarliestIncomeDate = apiBalance.getGWLifeSingleEarliestIncDate();
            outProps.GWLifetimeSingleBasisRolledUpValue = apiBalance.getGWLifeSingleRolledUp();
            outProps.GWLifetimeSingleRollupToDate = apiBalance.getGWLifeSingleRolledUpToDate();

            outProps.GWLifetimeSingleDepositBonus = apiBalance.getGWLifeSingleDepositBonus();
            outProps.GWLifetimeSingleDepositBasis = apiBalance.getGWLifeSingleDepositBasis();
            outProps.GWLifetimeSingleDeathBasis = apiBalance.getGWLifeSingleDeathBasis();
            outProps.GWLifetimeSingleMaxAnniversaryValue = apiBalance.getGWLifeSingleMaxAnniv();
            outProps.GWLifetimeSingleExcessWithdrawalTaken = (apiBalance.getGWLifeSingleExcessWithd() == "Y") ? true : false;
            outProps.GWLifetimeSingleRestoreUsed = (apiBalance.getGWLifeSingleRestore() == "Y") ? true : false;

            outProps.GWLifetimeJointLifetimeBasis = apiBalance.getGWLifeJointLifetimeBasis();
            outProps.GWLifetimeJointCarryoverAmount = apiBalance.getGWLifeJointCarryoverAmount();
            outProps.GWLifetimeJointExcessRMD = apiBalance.getGWLifeJointExcessRMD();
            outProps.GWLifetimeJointWithdrawals = apiBalance.getGWLifeJointWithdrawals();
            outProps.GWLifetimeJointLastWithdrawalDate = apiBalance.getGWLifeJointLastWithdDate();
            outProps.GWLifetimeJointGMWBPercentage = apiBalance.getGWLifeJointGMWBPercentage();
            outProps.GWLifetimeJointAnnualBenefit = apiBalance.getGWLifeJointAnnualBen();
            outProps.GWLifetimeJointAvailableAmount = apiBalance.getGWLifeJointAvailableAmt();
            outProps.GWLifetimeJointEarliestIncomeDate = apiBalance.getGWLifeJointEarliestIncDate();

            outProps.GWLifetimeJointBasisRolledUpValue = apiBalance.getGWLifeJointRolledUp();
            outProps.GWLifetimeJointRollupToDate = apiBalance.getGWLifeJointRolledUpToDate();
            outProps.GWLifetimeJointDepositBonus = apiBalance.getGWLifeJointDepositBonus();
            outProps.GWLifetimeJointDepositBasis = apiBalance.getGWLifeJointDepositBasis();
            outProps.GWLifetimeJointDeathBasis = apiBalance.getGWLifeJointDeathBasis();
            outProps.GWLifetimeJointMaxAnniversaryValue = apiBalance.getGWLifeJointMaxAnniv();
            outProps.GWLifetimeJointExcessWithdrawalTaken = (apiBalance.getGWLifeJointExcessWithd() == "Y") ? true : false;
            outProps.GWLifetimeJointRestoreUsed = (apiBalance.getGWLifeJointRestore() == "Y") ? true : false;

            outProps.GWBenefitPhaseStartDate = apiBalance.getGWBenPhaseStartDate();
            outProps.GWLastResetDate = apiBalance.getGWLastResetDate();
            outProps.GWLastPremiumDate = apiBalance.getGWLastPremiumDate();
            outProps.GWNextResetDate = apiBalance.getGWNextResetDate();
            outProps.GWLastRateChangeDate = apiBalance.getGWLastRateChangeDate();
            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedWithdrawals Call.  Returning from GetGuaranteedWithdarwals now for policy  " + inProps.PolicyNumber);  

            return outProps;
        }

        
        public BalanceInquiryGuaranteedRetirementResponse GetGuaranteedRetirementValues(BalanceInquiryRequest inProps)
        {

            Log.AddDetailedLogEntry("Starting TCP Balance Inquiry GetGuaranteedRetirementValues Call.  Call is for policy " + inProps.PolicyNumber);  

            apiBalance.setCompanyCode(inProps.CompanyCode);
            apiBalance.setPolicyNumber(inProps.PolicyNumber);
            apiBalance.setEffectiveDate(inProps.EffectiveDate);

            apiBalance.setFunctionFlag("D");  // Decides operation ... "G" means GW Rider info only  

            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedRetirementValues Call.  Just before OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);  
            apiBalance.RunInquiry();
            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedRetirementValues Call.  Just after OBALINQU RunInquiry for policy  " + inProps.PolicyNumber);  


            BalanceInquiryGuaranteedRetirementResponse outProps = new BalanceInquiryGuaranteedRetirementResponse();
            outProps.ReturnCode = apiBalance.getReturnCode();
            outProps.ErrorMessage = apiBalance.getErrorMessage();

            outProps.GuarRetireTotalDue = apiBalance.getGuarRetireTotalDue();
            int count = apiBalance.getGuarRetirePaymentDueCount();

            outProps.GRPaymentDueBenefitSeq = new int[count];
            outProps.GRPaymentDueDueDate = new int[count];
            outProps.GRPaymentDueEffectiveDate = new int[count];
            outProps.GRPaymentDueWithdrawalEffectiveDate = new int[count];
            outProps.GRPaymentDueDueType = new string[count];
            outProps.GRPaymentDueAmountDue = new double[count];
            outProps.GRPaymentDueAmountPaid = new double[count];
            outProps.GRPaymentDueModePremium = new double[count];

            for (int i = 1; i <= count; i++)
            {
                outProps.GRPaymentDueBenefitSeq[i - 1] = apiBalance.getGRPaymentDueBenefitSeq(i);
                outProps.GRPaymentDueDueDate[i - 1] = apiBalance.getGRPaymentDueDueDate(i);
                outProps.GRPaymentDueEffectiveDate[i - 1] = apiBalance.getGRPaymentDueEffectiveDate(i);
                outProps.GRPaymentDueWithdrawalEffectiveDate[i - 1] = apiBalance.getGRPaymentDueWithdEffDate(i);
                outProps.GRPaymentDueDueType[i - 1] = apiBalance.getGRPaymentDueDueType(i);
                outProps.GRPaymentDueAmountDue[i - 1] = apiBalance.getGRPaymentDueAmountDue(i);
                outProps.GRPaymentDueAmountPaid[i - 1] = apiBalance.getGRPaymentDueAmountPaid(i);
                outProps.GRPaymentDueModePremium[i - 1] = apiBalance.getGRPaymentDueModePremium(i);
            }

            Log.AddDetailedLogEntry("TCP Balance Inquiry GetGuaranteedRetirementValues Call.  Returning from GetGuaranteedRetirementValues now for policy  " + inProps.PolicyNumber);  
            return outProps;
        }
        

	}
}
