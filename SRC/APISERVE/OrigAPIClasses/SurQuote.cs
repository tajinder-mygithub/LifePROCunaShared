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
*  20070802-001-01   DAR   10/25/07    Surrender quote enhancements
*  20070730-003-01   DAR   10/24/08    Reprojection enhancements. 
*  20120326-004-01   DAR   05/25/12    Convert communication to WCF 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20131114-004-01   DAR   01/11/14    Add Include* properties for Surrender Quote, to control 
*                                      execution of optional ETI/RPU/Loan quotes. 
*  20140220-005-01   DAR   03/26/14    Add Override Future Date Edit property
*  20140220-007-01   DAR   05/27/14    Add bucket level values with MVA information
*  20131208-001-01   TJO   07/10/2014  NFO Quoting Additions                                      
*  20140220-005-02   DAR   08/06/14    Fix handling of Override Future Date property 
*  20150805-006-37   SES   09/07/16    Member's Horizon Phase II
*  20131010-019-01   DAR   12/21/16    Added detailed logging to help diagnose potential load issues.  
*  20131010-019-01   DAR   01/11/17    Add deduction information in return reply  
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  
using System.Data;  



namespace PDMA.LifePro 
{
	/// <summary>
	/// The LifePRO Surrender Quote object, used to calculate surrender values on an active policy 
	/// </summary>

	public class SurQuote : ISurQuote  
	{
		OSURQUOT apiQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init(string userType)
		{
            Log.AddDetailedLogEntry("In TCP Surrender Quote Init Call.  About to Init OSURQUOT");  

			UserType = userType ; 
			apiQuote = new OSURQUOT(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiQuote.getReturnCode() ; 
			outProps.ErrorMessage = apiQuote.getErrorMessage() ;

            Log.AddDetailedLogEntry("In TCP Surrender Quote Init Call.  About to exit with Return Code: " + outProps.ReturnCode.ToString());  
            return outProps;  

		}

		public void Dispose() 
		{
			apiQuote.Dispose(); 
			apiQuote = null ; 
		}

		public SurrenderQuoteResponse RunQuote (SurrenderQuoteRequest inProps ) 
		{

            Log.AddDetailedLogEntry("Starting TCP Surrender Quote RunQuote Call.  Call is for policy " + inProps.PolicyNumber);  

			apiQuote.setCompanyCode(inProps.CompanyCode); 
			apiQuote.setPolicyNumber(inProps.PolicyNumber);  
			apiQuote.setEffectiveDate(inProps.EffectiveDate); 

            if (inProps.IncludeETIQuote)
                apiQuote.setIncludeETIQuote("Y");
            else
                apiQuote.setIncludeETIQuote("N");

            if (inProps.IncludeRPUQuote)
                apiQuote.setIncludeRPUQuote("Y");
            else
                apiQuote.setIncludeRPUQuote("N");

            if (inProps.IncludeLoanQuote)
                apiQuote.setIncludeLoanQuote("Y");
            else
                apiQuote.setIncludeLoanQuote("N");   

            if (inProps.OverrideFutureDateEdits)
                apiQuote.setOverrideFutureDateEdits("Y");
            else
                apiQuote.setOverrideFutureDateEdits("N");

            Log.AddDetailedLogEntry("TCP Surrender Quote RunQuote Call.  Just before OSURQUOT RunQuote for policy  " + inProps.PolicyNumber);  
			apiQuote.RunQuote() ;
            Log.AddDetailedLogEntry("TCP Surrender Quote RunQuote Call.  Just after OSURQUOT RunQuote for policy  " + inProps.PolicyNumber);  

            SurrenderQuoteResponse outProps = new SurrenderQuoteResponse() ; 
			outProps.ReturnCode = apiQuote.getReturnCode();  
			outProps.ErrorMessage = apiQuote.getErrorMessage();  
            outProps.EffectiveDateUsed = apiQuote.getEffectiveDateUsed();  
			outProps.CashValue = apiQuote.getCashValue();  
			outProps.FundValue = apiQuote.getFundValue();  
			outProps.DividendAccumulation = apiQuote.getDividendAccumulation(); 
			outProps.DividendAdjustment = apiQuote.getDividendAdjustment();  
			outProps.CashValueOYT = apiQuote.getCashValueOYT(); 
			outProps.CashValuePUA = apiQuote.getCashValuePUA(); 
			outProps.SurrenderCharge = apiQuote.getSurrenderCharge();  
			outProps.SurrenderAmount = apiQuote.getSurrenderAmount();  
			outProps.LoanPrincipal = apiQuote.getLoanPrincipal();  
			outProps.LoanInterest = apiQuote.getLoanInterest();  
			outProps.LoanBalance = apiQuote.getLoanBalance(); 
			outProps.UnappliedCash = apiQuote.getUnappliedCash(); 
			outProps.IBAValue01 = apiQuote.getIBAValue01(); 
			outProps.IBAValue02 = apiQuote.getIBAValue02(); 
			outProps.IBAValue04 = apiQuote.getIBAValue04();  
			outProps.UnprocessedPremium = apiQuote.getUnprocessedPremium(); 
			outProps.StateFundTax = apiQuote.getStateFundTax(); 
			outProps.DefPremiumTax = apiQuote.getDefPremiumTax(); 
			outProps.RefundPremiumTax = apiQuote.getRefundPremiumTax(); 
			outProps.FederalWithholding = apiQuote.getFederalWithholding(); 
			outProps.StateWithholding = apiQuote.getStateWithholding(); 
			outProps.FreeWithdrawal = apiQuote.getFreeWithdrawal(); 
			outProps.NetFundValue = apiQuote.getNetFundValue(); 
            outProps.MinimumEquity = apiQuote.getMinimumEquity();   
			outProps.ARFundValue = apiQuote.getARFundValue(); 
			outProps.ARNetFundValue = apiQuote.getARNetFundValue(); 
			outProps.ARFreeWDAvailable = apiQuote.getARFreeWDAvailable(); 

            outProps.MaxLoanAvail = apiQuote.getMaxLoanAvail(); 
            outProps.LoanInterestRate = apiQuote.getLoanInterestRate();     
            outProps.InterestMethod = apiQuote.getInterestMethod(); 
            outProps.InterestType = apiQuote.getInterestType();  
            outProps.ExtendedTermDate = apiQuote.getExtendedTermDate();  
            outProps.ExtendedTermAmt = apiQuote.getExtendedTermAmt(); 
            outProps.ReducedPaidUpAmt = apiQuote.getReducedPaidUpAmt();
            outProps.PolicyEarnings = apiQuote.getPolicyEarnings();
            outProps.TaxableIncome = apiQuote.getTaxableIncome();
            outProps.MVAAmt = apiQuote.getMVAAmount();

            // New fields added with 20070802-001:
            outProps.CurrentIntRate = apiQuote.getCurrentIntRate();
            outProps.ULDeathBenefit = apiQuote.getULDeathBenefit();
            outProps.PrfrLoanAvailable = apiQuote.getPrfrLoanAvailable();
            outProps.BonusRate = apiQuote.getBonusRate();
            outProps.FixedReplenishRate = apiQuote.getFixedReplenishRate();
            outProps.MinimumPremium = apiQuote.getMinimumPremium();
            outProps.TargetPremium = apiQuote.getTargetPremium();
            outProps.PolicyBillDay = apiQuote.getPolicyBillDay(); 
                        
			outProps.NumberOfFunds = apiQuote.getNumberofFunds(); 
                        
            int count = outProps.NumberOfFunds; 
            outProps.FVFundID = new string[count];  
			outProps.FVFundDescription = new string[count];  
			outProps.FVFundValue = new double[count];  
			outProps.FVSurrenderCharge = new double[count];  
			outProps.FVNetFundValue = new double[count];  
			outProps.FVFreeWithdrawal = new double[count];  
			outProps.FVFundType = new string[count];  
			outProps.FVCurrentInterestRate = new double[count];  
			outProps.FVGuaranteedIntRate = new double[count];  
			outProps.FVMVA = new double[count];  
			outProps.FVUnitValue = new double[count];  
			outProps.FVUnits = new double[count];
            outProps.FVGrossDeposits = new double[count];
            outProps.BenefitPlanCode = new string[count];
            outProps.BenefitType = new string[count];
            outProps.BenefitSeq = new int[count];  

            for (int i = 1; i <= count; i++) {
                outProps.FVFundID[i - 1] = apiQuote.getFVFundID(i).Trim();
                outProps.FVFundDescription[i - 1] = apiQuote.getFVFundDescription(i).Trim();
                outProps.FVFundValue[i - 1] = apiQuote.getFVFundValue(i);
                outProps.FVSurrenderCharge[i - 1] = apiQuote.getFVSurrenderCharge(i);
                outProps.FVNetFundValue[i - 1] = apiQuote.getFVNetFundValue(i);
                outProps.FVFreeWithdrawal[i - 1] = apiQuote.getFVFreeWithdrawal(i);
                outProps.FVFundType[i - 1] = apiQuote.getFVFundType(i).Trim();
                outProps.FVCurrentInterestRate[i - 1] = apiQuote.getFVCurrentInterestRate(i);
                outProps.FVGuaranteedIntRate[i - 1] = apiQuote.getFVGuaranteedIntRate(i); ;
                outProps.FVMVA[i - 1] = apiQuote.getFVMVA(i);
                outProps.FVUnitValue[i - 1] = apiQuote.getFVUnitvalue(i);
                outProps.FVUnits[i - 1] = apiQuote.getFVUnits(i);
                outProps.FVGrossDeposits[i - 1] = apiQuote.getFVGrossDeposits(i);
                outProps.BenefitPlanCode [i-1]= apiQuote.getBenefitPlanCode(i);
                outProps.BenefitType[i-1] = apiQuote.getBenefitType(i);
                outProps.BenefitSeq[i-1] = apiQuote.getBenefitSeq(i);
            }



            DataTable buckets = new DataTable();
            buckets.TableName = "Buckets";
            outProps.BucketLevelValues = buckets;

            buckets.Columns.Add("ParentSequence", System.Type.GetType("System.Int32"));

            // The following two items are copied in from the array above.  The redundancy is provided 
            // for convenience in searching, etc.  
            buckets.Columns.Add("FundID", System.Type.GetType("System.String"));
            buckets.Columns.Add("FundType", System.Type.GetType("System.String"));
            buckets.Columns.Add("Row", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("WindowDate", System.Type.GetType("System.Int32"));
            buckets.Columns.Add("BucketValue", System.Type.GetType("System.Double"));
            buckets.Columns.Add("CurrentRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("GuaranteedRate", System.Type.GetType("System.Double"));
            buckets.Columns.Add("MVA", System.Type.GetType("System.Double"));
            buckets.Columns.Add("MVAFactor", System.Type.GetType("System.Double"));   


            for (int b = 1; b <= apiQuote.getBucketRowCount(); b++)
            {
                DataRow r = buckets.NewRow();
                r["ParentSequence"] = apiQuote.getBucketParentSequence(b) - 1;

                if (((int)r["ParentSequence"]) > -1 &&
                      ((int)r["ParentSequence"]) < count)
                {
                    r["FundID"] = outProps.FVFundID[(int)r["ParentSequence"]];
                    r["FundType"] = outProps.FVFundType[(int)r["ParentSequence"]];
                }

                r["Row"] = apiQuote.getBucketRow(b); 
                r["WindowDate"] = apiQuote.getBucketWindowDate(b);
                r["BucketValue"] = apiQuote.getBucketValue(b);
                r["CurrentRate"] = apiQuote.getBucketCurrentRate(b);
                r["GuaranteedRate"] = apiQuote.getBucketGuaranteedRate(b);
                r["MVA"] = apiQuote.getBucketMVA(b);
                r["MVAFactor"] = apiQuote.getBucketMVAFactor(b);   
                buckets.Rows.Add(r);
            }

            DataTable deductions = new DataTable();
            deductions.TableName = "Deductions";
            outProps.Deductions = deductions;

            deductions.Columns.Add("DeductionBenefitSeq", System.Type.GetType("System.Int32"));
            deductions.Columns.Add("DeductionBenefitType", System.Type.GetType("System.String"));
            deductions.Columns.Add("DeductionBenefitPlan", System.Type.GetType("System.String"));
            deductions.Columns.Add("DeductionType", System.Type.GetType("System.String"));
            deductions.Columns.Add("DeductionAmount", System.Type.GetType("System.Double"));

            for (int d = 1; d <= apiQuote.getDeductionRowCount(); d++)
            {
                DataRow r = deductions.NewRow();
                r["DeductionBenefitSeq"] = apiQuote.getDeductionBenefitSeq(d);
                r["DeductionBenefitType"] = apiQuote.getDeductionBenefitType(d);
                r["DeductionBenefitPlan"] = apiQuote.getDeductionBenefitPlan(d);
                r["DeductionType"] = apiQuote.getDeductionType(d);
                r["DeductionAmount"] = apiQuote.getDeductionAmount(d);

                deductions.Rows.Add(r);

            }
            
			outProps.TotalValue = apiQuote.getTotalValue(); 
			outProps.TotalMiscCredits = apiQuote.getTotalMiscCredits(); 
			outProps.TotalMiscTaxes = apiQuote.getTotalMiscTaxes(); 
			outProps.TotalFreeWithdrawal = apiQuote.getTotalFreeWithdrawal(); 
			outProps.TotalFundValue = apiQuote.getTotalFundValue(); 
            outProps.TotalPUAValue = apiQuote.getTotalPUAValue();
            outProps.TotalOYTValue = apiQuote.getTotalOYTValue();
            outProps.TotalDivAccums = apiQuote.getTotalDivAccums();
            outProps.TotalDivAdjust = apiQuote.getTotalDivAdjust();
            outProps.TotalPremRefund = apiQuote.getTotalPremRefund();
            outProps.ReturnOfPremium = apiQuote.getReturnOfPremium();
            outProps.NFOValue = apiQuote.getNFOValue();
            outProps.CNFOValue = apiQuote.getCNFOValue();
            outProps.LNFOValue = apiQuote.getLNFOValue();
            outProps.ManualNFO = apiQuote.getManualNFO();
            outProps.PremiumsDue = apiQuote.getPremiumsDue();
            outProps.WaiverDue = apiQuote.getWaiverDue();
            outProps.PremiumsPaid = apiQuote.getPremiumsPaid();
            outProps.WaiverPremiums = apiQuote.getWaiverPremiums();
            outProps.ClaimsPaidAndTransfers = apiQuote.getClaimsPaidAndTransfers();
            outProps.MinimumLifetimeLimit = apiQuote.getMinimumLifetimeLimit();

            Log.AddDetailedLogEntry("TCP Surrender Quote RunQuote Call.  Returning from RunQuote now for policy  " + inProps.PolicyNumber);  			
			return outProps ; 
		}


        public OSURQUOT ReturnSurQuoteObj()
        {
            return apiQuote; 
        }

	}
}
