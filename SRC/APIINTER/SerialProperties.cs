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
*  20091112-002-01   JWS   01/06/10    Address API modifications.
*  20100107-002-01   WAR   01/18/10    Modify table rated fields for riders
*                                      used in Reprojections.
*  20101008-003-01   DAR   12/01/10    Implement premium illus and disclosure 
*                                      interfaces.  
*  20120308-005-01   DAR   03/12/12    Implement AIR Primary Insured Flag, Reprojections.
*  20111018-004-02   JVR   02/23/12    Add cell phone number to Name/Address record.                                                                         
*  20110202-002-01   DAR   07/25/11    Health Premium Quote - New Policy Enhancement   
*  20110621-005-01   DAR   07/28/11    Enhancements to quote benefit changes
*  20111117-006-01   DAR   05/17/12    Retrofit 20110621-005-01, 20111205-001-01 
*  20120503-005-01   DAR   07/05/12    Implement ProcessWarningCode and ProcessWarningMessage
*  20120706-004-01   DAR   09/24/12    Add bucket-level values to Balance Inquiry API
*  20111013-006-07   DAR   10/17/12    Add RMD Quote API
*  20120706-004-01   DAR   11/12/12    Add total cost basis and pre tefra basis
*  20121126-001-01   DAR   11/26/12    Add Address API "add" function, along with new properties. 
*  20120524-005-01   DAR   12/03/12    Add output values related to Guideline 
*                                      Premium tracking.    
*  20130104-002-01   DAR   01/07/13    Add transfer-related properties.  
*  20130108-004-01   DAR   01/09/13    Add Hierarchy Reserve Amounts. 
*  20121210-001-01   DAR   02/01/13   Return Benefit Table from Health API
*  20130226-004-01   DAR   03/31/13    Add Commission Control API
*  20121101-001-01   DAR   05/21/13   Shared Care Enhancement to Health API
*  20130311-003-01   DAR   07/01/13   Addition of new Benefit sequence values
*  20130520-005-01   DAR   09/04/13    Add Special Class Loan Rate to Reprojection
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20100901-003-01   TJO   11/08/13    Add additional bucket level values to Balance Inquiry API
*  20131114-004-01   DAR   01/11/14    Add Include* properties for Surrender Quote, to control 
*                                      execution of optional ETI/RPU/Loan quotes. 
*  20140129-005-01   JWS   03/05/14    SPIA Calculator
*  20140220-005-01   DAR   03/26/14    Added OverrideFutureDateEdits properties.
*  20140220-006-01   DAR   03/28/14    Add Gauranteed Mininum and GW Rider values 
*  20140220-007-01   DAR   05/27/14    Add Bucket values with MVA to Surrender Charge API
*  20131208-001-01   TJO   07/10/14    NFO Quoting Additions
*  20130323-002-01   DAR   10/08/14    Additional RMD Output properties added 
*  20141010-004-01   DAR   10/14/14    Add additional GW and Source Summary values to Balance Inquiry
*  20141010-004-01   DAR   12/29/14    Add additional GW items
*  20130508-004-01   AKR   01/07/15    Chgd TrPaidUpAdds&TrCurrDb to double
*  20141010-004-01   DAR   02/17/15    Add Balance Inquiry and Systematic output properties 
*  20150108-001-01   DAV   04/29/15    Add IBA flex modal and annual premiums.
*  20140318-009-01   TJO   04/13/15    Add GWBN amounts to Death Quote API 
*  20141110-008-01   TJO   05/22/15    Add RFIA amounts to Balance Inquiry API    
*  20121115-004-02   DAR   06/26/15    Add Model Allocation info to Deposit Allocation API  
*                                      Also add Last Anniversary Date to Balance Inquiry API 
*  20131010-019-01   DAR   07/25/15    Add Guarantee Retirement (GR) Segment Due Amount                                       
*  20131010-019-01   DAR   09/03/15    Add GR Overdue Detail, Summary Row additional values
*                                      and Rate History, and Minimum Equity  
*  20141110-007-08   TJO   12/04/15    Add ABV description to RMD Quote API   
*  20150601-002-01   AKR   01/11/16    New Co-Pol Enhancements  
*  20151130-001-01   GWT   02/03/16    BalInq - Add Model/Sub-Model/Profile info  
*  20151130-001-01   GWT   02/25/16    DepAlloc - Add Model/Sub-Model/Profile info
*  20131010-019-01   DAR  04/15/16    Added a GW Last Rider Change Fee Date, and Modal Premium to GR Results 
*  20131010-019-01   DAR   06/17/16    Add input elements for RMD quote.      
*  20151221-010-01   SAP   06/28/16    Added Foreign Tax ID
*  20150805-006-01   SES   07/11/16    Member's Horizon
*  20141010-004-01   DAR   08/04/16    Add state license to Commission Control API
*  20131010-019-01   DAR   08/29/16    Deposit allocation, new input and outputs 
*  20150805-006-36   SAP   09/16/16    Invest Next Phase 2
*  20150311-012-32   DAR   09/27/16    Add new API to retrieve Trace Screen rate/premium information.  
*  20140611-015-01   SAP   10/10/16    Added fields for new ENS API
*  20160526-007-01   SAP   10/14/16    Added properties for Mortgage Special Premiums in Proposal 
*  20131010-019-01   DAR   10/17/16    Balance Inquiry:  Add capability to do sub-calls on specific functions. 
*  20131010-019-01   DAR   01/11/17    Surrender Quote, return Deduction nifo  
*  20161201-003-01   ABH   01/02/17    Added field Personal and Business Emails.
*  20161201-003-01   SAP   01/17/16    Added Personal And Business Email Address
*  20131122-010-01   JWS   11/17/14    Add new terminate option.
*/

using System;
using System.Diagnostics;
using System.Data;
using System.ServiceModel;
using System.ServiceModel.Description;


namespace PDMA.LifePro
{
    /// <summary>
    /// Summary description for Class1.
    /// </summary>
    ///
    [Serializable]
    public class BaseRequest
    {
        public string UserType;  // Added for Web Service implementation.  Will include this on "main" method call.  
    }

    [Serializable]
    public class BaseResponse
    {
        public int ReturnCode ;
        public string ErrorMessage ;
    }


    [Serializable]
    public class SurrenderQuoteRequest : BaseRequest
    {
        // This class contains copies of properties that are input to the SurQuote server-side object.
        public string CompanyCode ;
        public string PolicyNumber ;
        public int EffectiveDate ;
        
        public bool OverrideFutureDateEdits; 
        public bool IncludeETIQuote;
        public bool IncludeRPUQuote;
        public bool IncludeLoanQuote; 
    }

    [Serializable]
    public class SurrenderQuoteResponse : BaseResponse
    {
        // This class contains the properties that are output and input/output for the SurQuote object.

        public int EffectiveDateUsed ;

        public double CashValue ;
        public double FundValue ;
        public double DividendAccumulation ;
        public double DividendAdjustment ;
        public double CashValuePUA ;
        public double CashValueOYT ;
        public double SurrenderCharge ;
        public double SurrenderAmount ;
        public double LoanPrincipal ;
        public double LoanInterest ;
        public double LoanBalance ;
        public double UnappliedCash ;
        public double IBAValue01 ;
        public double IBAValue02 ;
        public double IBAValue04 ;
        public double UnprocessedPremium ;
        public double StateFundTax ;
        public double DefPremiumTax ;
        public double RefundPremiumTax ;
        public double FederalWithholding ;
        public double StateWithholding ;
        public double FreeWithdrawal ;
        public double NetFundValue ;
        public double MinimumEquity; 
        public double ARFundValue ;
        public double ARNetFundValue ;
        public double ARFreeWDAvailable ;
        public double ReturnOfPremium;
        public double NFOValue;
        public double CNFOValue;
        public double LNFOValue;
        public string ManualNFO;
        public double PremiumsDue;
        public double WaiverDue;
        public string RopFlag;
        public string NFOType;
        public double PremiumsPaid;
        public double WaiverPremiums;
        public double ClaimsPaidAndTransfers;
        public double MinimumLifetimeLimit;

        public double CurrentIntRate;
        public double ULDeathBenefit;
        public double PrfrLoanAvailable;

        public double MaxLoanAvail;
        public double LoanInterestRate;
        public string InterestMethod;
        public string InterestType;
        public int ExtendedTermDate;
        public double ExtendedTermAmt;
        public double ReducedPaidUpAmt;

        public double GMSVAmount ;
        public double GMSVROP ;
        public double CashValueTest ;
        public double PresentValueTest ;

        public double PolicyEarnings;
        public double TaxableIncome;
        public double MVAAmt;

        public int NumberOfFunds ;

        public string [] FVFundID ;
        public string [] FVFundDescription ;
        public double [] FVFundValue ;
        public double [] FVSurrenderCharge ;
        public double [] FVNetFundValue ;
        public double [] FVFreeWithdrawal ;
        public string [] FVFundType ;
        public double [] FVCurrentInterestRate ;
        public double [] FVGuaranteedIntRate;
        public double [] FVMVA ;
        public double [] FVUnitValue ;
        public double [] FVUnits ;
        public double [] FVGrossDeposits;
        public string [] BenefitPlanCode;
        public string [] BenefitType;
        public int [] BenefitSeq;

        // 20140220-007-01:  Added bucket level values 
        public DataTable BucketLevelValues;  
        // 20131010-019-01 
        public DataTable Deductions; 

        // Deductions columns:  
        //  DeductionBenefitSeq
        //  DeductionBenefitType  
        //  DeductionBenefitPlan  
        //  DeductionType  
        //  DeductionAmount;  


        public double TotalValue ;
        public double TotalMiscCredits ;
        public double TotalMiscTaxes ;
        public double TotalFreeWithdrawal ;
        public double TotalFundValue ;
        public double TotalPUAValue;
        public double TotalOYTValue;
        public double TotalDivAccums;
        public double TotalDivAdjust;
        public double TotalPremRefund;
        public double BonusRate;
        public double FixedReplenishRate;
        public double MinimumPremium;
        public double TargetPremium;
        public double PolicyBillDay;
    }

    [Serializable]
    public class PremiumQuoteRequest : BaseRequest
    {
        // This class contains copies of properties that are input to the SurQuote server-side object.
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public string Function;
        public string InputSpecialMode;
        public string InputForm;
        public int InputMode;
        public double InputModePremium;

    }

    [Serializable]
    public class PremiumQuoteResponse : BaseResponse
    {
        // This class contains the properties that are output and input/output for the SurQuote object.

        public int EffectiveDateUsed ;
        public int CurrentMode;
        public string CurrentSpecialMode;
        public string CurrentForm;
        public double CurrentModePremium;
        public int BilledToDate;
        public int PaidToDate;
        public double PolicyFee;
        public double ModePremiumAnnual;
        public double ModePremiumQuarterly;
        public double ModePremiumSemiAnnual;
        public double ModePremiumMonthly;
        public double ModePremiumNinethly;
        public double ModePremiumTenthly;
        public double ModePremium26Pay;
        public double ModePremium52Pay;
        public double ModePremium13thly;
        public double ModePremiumBiweekly;
        public double ModePremiumWeekly;
        public double ModePremiumCalendar;
        public string CalendarFlag;
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public string Function;
        public string InputSpecialMode;
        public string InputForm;
        public int InputMode;
        public double InputModePremium;

    }

    [Serializable]
    public class LoanQuoteRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public bool OverrideFutureDateEdits; 
    }

    [Serializable]
    public class LoanQuoteResponse : BaseResponse
    {
        public int EffectiveDateUsed;
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public double DividendsAccums;
        public double CashValuePaidup;
        public double CurLoanBalance;
        public double FundOrCashValue;
        public double SurrenderCharge;
        public double AccruedInterest;
        public double PremiumDue;
        public double MaxLoanAvail;
        public double InterestToAnniv;
        public double NetLoanAvail;
        public double LoanInterestRate;
        public string InterestMethod;
        public string InterestType;
        public int LastAccruedDate;
        public string FundOrCash;
        public string MinEquityText;
        public string IntAdjustText;
    }

    [Serializable]
    public class NameRequest : BaseRequest  
    {
        public string UpdateQueryFlag;
        public int      NameID;
        public string NameType;
        public string UpdateIndividualPrefix;
        public string UpdateIndividualFirstName;
        public string UpdateIndividualMiddleName;
        public string UpdateIndividualLastName;
        public string UpdateIndividualSuffix;
        public int    UpdateIndividualSSN;
        public string UpdateBusinessPrefix;
        public string UpdateBusinessName;
        public string UpdateBusinessSuffix;
        public string UpdateBusinessTaxID;
        public int    UpdateNameDateOfBirth;
        public string UpdateNameGender;
        public string UpdateForeignTaxID;
        //20161201-003-01 
        public string UpdatePersonalEmail;
        public string UpdateBusinessEmail;
        //20161201-003-01
    }



    [Serializable]
    public class NameResponse : BaseResponse
    {
        public string NameType;
        public string IndividualPrefix;
        public string IndividualFirstName;
        public string IndividualMiddleName;
        public string IndividualLastName;
        public string IndividualSuffix;
        public string IndividualReverse;
        public int    IndividualSSN;
        public string BusinessPrefix;
        public string BusinessName;
        public string BusinessSuffix;
        public string BusinessTaxID;
        public string FormatName;
        public int    NameDateOfBirth;
        public string NameGender;
        public string TaxStatus;
        public string DeceasedFlag;
        public int    DateOfDeath;
        public string TaxWithholdingFlag;
        public string TaxCertificationCode;
        public int    TaxCertificationDate;
        public string ForeignTaxID;
        //20161201-003-01
        public string PersonalEmail;
        public string BusinessEmail;
        //20161201-003-01

    }

    [Serializable]
    public class AddressRequest : BaseRequest
    {
        public string UpdateQueryFlag;
        public int NameID;
        // Additional Input Parameters - 01/11/16 AKR Mod:20150601-002-01
        public string CompanyCode;
        public string PolicyNumber;
        public string RelateCode;
        public string InAddressType;
        public string InAddressCode;
        public string UpdateIndicator;
        public int UpdateNameId;
        // End 20150601-002-01
        // The following inputs support stateless web service calls, since this information cannot be "remembered" between calls.  These values will be passed back 
        // to the caller so they don't have to be filled in or modified.  They'll support update and Get Next operations. These are not used or accessible from LPREMAPI 
        // at this time.  
        public int AddressID;
        public int EffectiveDate;
        public string AddressCode;
        public string IdentifyingNumber; 
        // End web service additions 


        // Added additional inputs - 11/19/2012, DAR, for SR #1021126-001-01 
        public int UpdateCancelDate;
        public int UpdateEffectiveDate;
        public int UpdateRecurringStartMonth;
        public int UpdateRecurringStartDay;
        public int UpdateRecurringStopMonth;
        public int UpdateRecurringStopDay;
        public int UpdateAlternateNameID;
        public long UpdatePhoneNumber;
        public long UpdateFaxNumber;
        public long UpdateCellPhoneNumber;
        public string UpdateAddressCode;
        public string UpdateAddressType;
        public string UpdateAddressLine1;
        public string UpdateAddressLine2;
        public string UpdateAddressLine3;
        public string UpdateAddressCity;
        public string UpdateAddressState;
        public string UpdateAddressZipCode;
        public string UpdateAddressBoxNumber;
        public string UpdateAddressZipExtension;
        public string UpdateAddressCountry;
        public string UpdateAddressCounty;
        public string UpdateAddressCountyCode;
        public string UpdateAddressCityCode;
        public string UpdateBadAddressIndicator; 



    }

    [Serializable]
    public class AddressResponse : BaseResponse
    {
        public int AddressID;
        public int CancelDate;
        public int EffectiveDate;
        public string IdentifyingNumber; 
        public int RecurringStartMonth;
        public int RecurringStartDay;
        public int RecurringStopMonth;
        public int RecurringStopDay;
        public int AlternateNameID;
        public long PhoneNumber;
        public long FaxNumber;
        public long CellPhoneNumber;
        public string AddressType;
        public string AddressCode;
        public string AddressLine1;
        public string AddressLine2;
        public string AddressLine3;
        public string AddressCity;
        public string AddressState;
        public string AddressZipCode;
        public string AddressBoxNumber;
        public string AddressZipExtension;
        public string AddressCountry;
        public string AddressCounty;
        public string AddressCountyCode;
        public string AddressCityCode;
        // Added additional output - 11/19/2012, DAR, for SR #1021126-001-01 
        public string BadAddressIndicator;  
        public string FormatAddressLine1;
        public string FormatAddressLine2;
        public string FormatAddressLine3;
        public string FormatAddressLine4;
        // Added additional output - 20150601-002
        public int UpdateNameId;
    }

    [Serializable]
    public class PolicyInquiryRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
    }


    [Serializable]
    public class PolicyInquiryResponse : BaseResponse
    {
        public int OwnerID;
        public int InsuredID;
        public int Annuitant1ID;
        public int Annuitant2ID;
        public int Annuitant3ID;
        public string ProductID;
        public string ProductDesc;
        public int IssueDate;
        public double FaceAmount;
        public double NumberOfUnits;
        public double FlexModalPrem;
        public double FlexAnnualPrem;
        public string Status;
        public int PaidToDate;
        public double ModePremium;
        public int BillingFrequency;
        public string BillingMethod;
        public int ServiceAgentID;
        public string CompanyCode;
        public string PolicyNumber;
    }


    [Serializable]
    public class PolicyListRequest : BaseRequest
    {
        public int CurrentNameID;
        public string IncAccountant;
        public string IncAffiliate;
        public string IncAssignee;
        public string IncAttorney;
        public string IncBeneficiary1;
        public string IncBeneficiary2;
        public string IncCorporation;
        public string IncPACBank;
        public string IncGroup;
        public string IncGuardian;
        public string IncInsured;
        public string IncJointEqual;
        public string IncJointInsured;
        public string IncMiscellaneous;
        public string IncAdditionalOwner;
        public string IncAdditionalPayor;
        public string IncPayor;
        public string IncPayee;
        public string IncPolicyOwner;
        public string IncPartner;
        public string IncPowerOfAttorney;
        public string IncServicingAgent;
        public string IncTrustee;
        public string IncTemporaryOwner;
        public string IncWritingAgent;
        public string IncMultInsured;
        public string IncGroupInsured;
        public string IncAuthorizedInfo;
        public string IncLegalInterest;
        public string IncSubowner;
        public string IncCustodian;
        public string IncGroupEmployer;
        public string IncAnnuitant1;
        public string IncAnnuitant2;
        public string IncReplInsurer;
        public string IncDependInsured;
        public string IncMasterPolicy;
        public string IncContact1;
        public string IncContact2Addl;
        public string IncContact3Addl;
        public string IncContact4Addl;

    }

    [Serializable]
    public class PolicyListResponse : BaseResponse
    {
        public int NumberOfRecordsFound;
        public string [] CompanyCodeFromList;
        public string [] PolicyNumberFromList;
        public string [] RelateCodeFromList;
        public string [] LOBFromList;
        public string [] StatusFromList;
        public string [] ProductIDFromList;
        public string [] ProductDescFromList;
        public double [] FaceAmountFromList;
        public double [] NumberOfUnitsFromList;
        public int [] InsuredIDFromList;
        public int [] OwnerIDFromList;
    }


    [Serializable]
    public class BalanceInquiryRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public bool OverrideFutureDateEdits; 
        public int StopSearchDate;  // Only used for retrieval of GWLastRateChangeDate  
    }

    [Serializable]
    public class BalanceInquiryResponse : BaseResponse
    {
        public string ActiveRequests;
        public string MultipleLoans;
        public int QuoteDate;
        public int ProcessToDate;
        public int LastValuationDate;
        public int LastAnniversaryDate; 
        public double GrossDeposits;
        public double GrossWithdrawals;
        public double LoanBalance;
        public double TotalFundBalance;
        public double TotalCostBasis;
        public double PreTefraCostBasis;
        public double CurrentEarningsRate;
        public double IndexEarningsRate;
        public double GuaranteedEarningsRate;
        public double CurrentEarningsAmountToDate;
        public double IndexEarningsAmountToDate;
        public string AssetAllocationModelFlag;
        public string AssetAllocationModelStatus; 
        // These are Source Summary values.  The fund balance will be the total of all funds for the given row.  
        // These arrays will have one value per row.  

        public string PremiumIncrementRule; //  This segment value comes from the CE Segment that decides information for the Row Summary below.  
        public int SumRowCount;
        public int[] SumRow;
        public string[] SumSource;
        public string[] SumSourceDesc;
        public double[] SumFundBalance;
        public double[] SumFreeAmount;
        public double[] SumLoad;
        public double[] SumGrossDeposits;
        public double[] SumGrossWithdrawals;
        public int[] SumStartDate;
        public int[] SumIncomeStartDate;
        public int[] SumPeriodCertain;
        public string[] SumGuaranteeStatus;
        public int[] SumGuaranteeStatusDate;
        public double[] SumGuaranteeIncomeFactor;
        public double[] SumGuaranteeIncome;
        public double[] SumVestedAnnualIncome;
        public double[] SumVestedMonthlyIncome;
        public double[] SumScheduledTransferAmount;
        public double[] SumAccumulatedPrepaymentAmount;
        public double[] SumRemainingPrepaymentTransfers;
        public double[] SumAmountToFullyFund;


        // This set of arrays will have one entry per fund, per row.  
        public int RowCount;
        public int[] RowNumber;  
        public string [] MoneySource;
        public string [] FundID;
        public string [] ShortDescription;
        public string [] LongDescription;
        public string [] FundType;
        public double [] Units;
        public double [] UnitValue;
        public int [] UnitValueDate;
        public double [] FundBalance;
        // Added additional output - 02/03/2016, GWT, for 20151130-001-01 
        public int[]    FundModelTableIndex;  // Identifies the position within the model table, if applicable (returns a 1-based value, although C# array subscripts start at zero).    
        public int[]    FundSubModelTableIndex;  // Identifies a position in the sub-model table, if applicable.    
        public string[] FundModelName;  // repeated here for convenience.  Equivalent of using ModelName[FundModelTableIndex-1]; 
        public int[]    FundModelVersion; // repeated here for convenience.  
        public string[] FundSubModelName;  // repeated here for convenience.  Equivalent of using SubModelName[FundSubModelTableIndex-1]; 
        public double[] FundSubModelAllocation;
        public double[] FundHybridCap;
        public double[] FundHybridFloor;
        //20150805-006-36 SAP Invest Next Phase2 
        public double[] FundBOTAnnvIndex;
        public double[] FundCurrIndex;

        public int ModelCount;
        public string[] ModelName;
        public int[]    ModelVersion;
        public long[]   ModelMDLMIdent;
        public string[] ModelType;
        public double[] ModelBalance;
        public int[]    ModelSubModelCount; // number of sub-models linked to this model.
        //20150805-006-36 SAP Invest Next Phase2 
        public string[] ModelRebalFlag;
        public int[] ModelRebalDate;

        public int SubModelCount;
        public int[] SubModelModelTableIndex; // Identifies the position within the model table (returns a 1-based value).
        public string[] SubModelModelName; // repeated here for convenience.
        public int[] SubModelModelVersion; // repeated here for convenience.
        public string[] SubModelName;
        public long[]   SubModelMDLBIdent;
        public double[] SubModelBalance;
        public double[] SubModelHybridCap;
        public double[] SubModelHybridFloor;
        //20150805-006-36 SAP Invest Next Phase2 
        public string[] SubModelRebalFlag;
        public int[] SubModelRebalDate;

        public string ProfileID;
        public string ProfileDescription;
        //20150805-006-36 SAP Invest Next Phase2 
        public string FinancialRptInd;
        public string PolicyCode;
        public int PolicyMatureExpDate;
        public string PolicyRebalFlag;
        public int PolicyRebalDate;
        public int HybridBOTDate;
        public int HybridEOTDate;
        public int HybridEOTHoldDate;
        public string HybridHoldAcctStatus;


        public DataTable BucketLevelValues;
        public DataTable PointToPointValues; 

        // This table contains another view on buckets, where you can find 
        // interest start and end dates historically for each bucket.  
        public DataTable RateHistory; 


        // The following values are all related to the Guaranteed Withdrawal (GW) benefit, if applicable.  
        public string GWResetStatus;
        public string GWWithdrawalBenefitAvailable;
        public string GWSingleBenefitAvailable;
        public string GWJointBenefitAvailable;
        public double GWWithdrawalEligiblePremiums;
        public double GWRemainingWithdrawalBenefit;
        public int GWWithdrawalBenefitLastWithdrawalDate;
        public double GWWithdrawalGMWBPercentage;
        public double GWWithdrawalAnnualBenefit;
        public double GWWithdrawalBenefitWithdrawals;
        public double GWWithdrawalExcessRMD;
        public double GWWithdrawalAvailableAmount; 
        public int GWWaitPeriodEndDate;  
        public double GWLifetimeSingleLifetimeBasis;
        public double GWLifetimeSingleCarryoverAmount;
        public double GWLifetimeSingleExcessRMD;
        public double GWLifetimeSingleWithdrawals;
        public int GWLifetimeSingleLastWithdrawalDate;
        public double GWLifetimeSingleGMWBPercentage;
        public double GWLifetimeSingleAnnualBenefit;
        public double GWLifetimeSingleAvailableAmount;
        public int GWLifetimeSingleEarliestIncomeDate;
        public double GWLifetimeSingleBasisRolledUpValue;
        public int GWLifetimeSingleRollupToDate;  
        public double GWLifetimeSingleDepositBonus;
        public double GWLifetimeSingleDepositBasis;
        public double GWLifetimeSingleDeathBasis; 
        public double GWLifetimeSingleMaxAnniversaryValue;
        public bool GWLifetimeSingleExcessWithdrawalTaken;
        public bool GWLifetimeSingleRestoreUsed; 
        public double GWLifetimeJointLifetimeBasis;
        public double GWLifetimeJointCarryoverAmount;
        public double GWLifetimeJointExcessRMD;
        public double GWLifetimeJointWithdrawals;
        public int GWLifetimeJointLastWithdrawalDate;  
        public double GWLifetimeJointGMWBPercentage;
        public double GWLifetimeJointAnnualBenefit;
        public double GWLifetimeJointAvailableAmount;
        public int GWLifetimeJointEarliestIncomeDate;
        public double GWLifetimeJointBasisRolledUpValue;
        public int GWLifetimeJointRollupToDate;  
        public double GWLifetimeJointDepositBonus;
        public double GWLifetimeJointDepositBasis;
        public double GWLifetimeJointDeathBasis; 
        public double GWLifetimeJointMaxAnniversaryValue;
        public bool GWLifetimeJointExcessWithdrawalTaken;
        public bool GWLifetimeJointRestoreUsed; 

        public int GWBenefitPhaseStartDate;
        public int GWLastResetDate;  
        public int GWLastPremiumDate;
        public int GWNextResetDate; 
        public int GWLastRateChangeDate;   // The Last Reset associated with a rate change.  

        // 20131010-019-01:  This value pertains to the GR segment, and identififes a due amount on a guaranteed retirement type of annuity. 
        public double GuarRetireTotalDue;   

        // The following are a detail of overdue payments that factor into the above GuarRetire amount, 
        // but only overdue amounts ...  
       //  4/15/2016 - Added in billable amounts for riders.  Benefit Sequence 02 and above.  
        public int[] GRPaymentDueBenefitSeq;
        public int[] GRPaymentDueDueDate;
        public int[] GRPaymentDueEffectiveDate;  // This is the effective date of the MPR that created the record.  
        public int[] GRPaymentDueWithdrawalEffectiveDate;  // only relevant to withdrawals, as there are also regular due payments in this list.  
        public string [] GRPaymentDueDueType;
        public double[] GRPaymentDueAmountDue;
        public double [] GRPaymentDueAmountPaid; 
        public double[] GRPaymentDueModePremium;   


    }
    
    [Serializable] 
    public class BalanceInquiryQuoteResponse : BaseResponse
    {
        // Limited to Quote only items from Balance Inquiry for "RunQuoteOnly" method.  
        // Will also be used in full response.  
        public string ActiveRequests;
        public string MultipleLoans;
        public int QuoteDate;
        public int ProcessToDate;
        public int LastValuationDate;
        public int LastAnniversaryDate; 
        public double GrossDeposits;
        public double GrossWithdrawals;
        public double LoanBalance;
        public double TotalFundBalance;
        public double TotalCostBasis;
        public double PreTefraCostBasis;
        public double CurrentEarningsRate;
        public double IndexEarningsRate;
        public double GuaranteedEarningsRate;
        public double CurrentEarningsAmountToDate;
        public double IndexEarningsAmountToDate;
        public string AssetAllocationModelFlag;
        public string AssetAllocationModelStatus; 
        // These are Source Summary values.  The fund balance will be the total of all funds for the given row.  
        // These arrays will have one value per row.  

        public string PremiumIncrementRule; //  This segment value comes from the CE Segment that decides information for the Row Summary below.  
        public int SumRowCount;
        public int[] SumRow;
        public string[] SumSource;
        public string[] SumSourceDesc;
        public double[] SumFundBalance;
        public double[] SumFreeAmount;
        public double[] SumLoad;
        public double[] SumGrossDeposits;
        public double[] SumGrossWithdrawals;
        public int[] SumStartDate;
        public int[] SumIncomeStartDate;
        public int[] SumPeriodCertain;
        public string[] SumGuaranteeStatus;
        public int[] SumGuaranteeStatusDate;
        public double[] SumGuaranteeIncomeFactor;
        public double[] SumGuaranteeIncome;
        public double[] SumVestedAnnualIncome;
        public double[] SumVestedMonthlyIncome;
        public double[] SumScheduledTransferAmount;
        public double[] SumAccumulatedPrepaymentAmount;
        public double[] SumRemainingPrepaymentTransfers;
        public double[] SumAmountToFullyFund;


        // This set of arrays will have one entry per fund, per row.  
        public int RowCount;
        public int[] RowNumber;  
        public string [] MoneySource;
        public string [] FundID;
        public string [] ShortDescription;
        public string [] LongDescription;
        public string [] FundType;
        public double [] Units;
        public double [] UnitValue;
        public int [] UnitValueDate;
        public double [] FundBalance;
        // Added additional output - 02/03/2016, GWT, for 20151130-001-01 
        public int[]    FundModelTableIndex;  // Identifies the position within the model table, if applicable (returns a 1-based value, although C# array subscripts start at zero).    
        public int[]    FundSubModelTableIndex;  // Identifies a position in the sub-model table, if applicable.    
        public string[] FundModelName;  // repeated here for convenience.  Equivalent of using ModelName[FundModelTableIndex-1]; 
        public int[]    FundModelVersion; // repeated here for convenience.  
        public string[] FundSubModelName;  // repeated here for convenience.  Equivalent of using SubModelName[FundSubModelTableIndex-1]; 
        public double[] FundSubModelAllocation;
        public double[] FundHybridCap;
        public double[] FundHybridFloor;
        //20150805-006-36 SAP Invest Next Phase2 
        public double[] FundBOTAnnvIndex;
        public double[] FundCurrIndex;

        public int ModelCount;
        public string[] ModelName;
        public int[]    ModelVersion;
        public long[]   ModelMDLMIdent;
        public string[] ModelType;
        public double[] ModelBalance;
        public int[]    ModelSubModelCount; // number of sub-models linked to this model.
        //20150805-006-36 SAP Invest Next Phase2 
        public string[] ModelRebalFlag;
        public int[] ModelRebalDate;

        public int SubModelCount;
        public int[] SubModelModelTableIndex; // Identifies the position within the model table (returns a 1-based value).
        public string[] SubModelModelName; // repeated here for convenience.
        public int[] SubModelModelVersion; // repeated here for convenience.
        public string[] SubModelName;
        public long[]   SubModelMDLBIdent;
        public double[] SubModelBalance;
        public double[] SubModelHybridCap;
        public double[] SubModelHybridFloor;
        //20150805-006-36 SAP Invest Next Phase2 
        public string[] SubModelRebalFlag;
        public int[] SubModelRebalDate;

        public string ProfileID;
        public string ProfileDescription;
        //20150805-006-36 SAP Invest Next Phase2 
        public string FinancialRptInd;
        public string PolicyCode;
        public int PolicyMatureExpDate;
        public string PolicyRebalFlag;
        public int PolicyRebalDate;
        public int HybridBOTDate;
        public int HybridEOTDate;
        public int HybridEOTHoldDate;
        public string HybridHoldAcctStatus;


        public DataTable BucketLevelValues;
        public DataTable PointToPointValues; 

        // This table contains another view on buckets, where you can find 
        // interest start and end dates historically for each bucket.  
        public DataTable RateHistory; 

    }
    
    [Serializable]
    public class BalanceInquiryGuaranteedWithdrawalResponse : BaseResponse
    {

        // The following values are all related to the Guaranteed Withdrawal (GW) benefit, if applicable.  
        public string GWResetStatus;
        public string GWWithdrawalBenefitAvailable;
        public string GWSingleBenefitAvailable;
        public string GWJointBenefitAvailable;
        public double GWWithdrawalEligiblePremiums;
        public double GWRemainingWithdrawalBenefit;
        public int GWWithdrawalBenefitLastWithdrawalDate;
        public double GWWithdrawalGMWBPercentage;
        public double GWWithdrawalAnnualBenefit;
        public double GWWithdrawalBenefitWithdrawals;
        public double GWWithdrawalExcessRMD;
        public double GWWithdrawalAvailableAmount;
        public int GWWaitPeriodEndDate;
        public double GWLifetimeSingleLifetimeBasis;
        public double GWLifetimeSingleCarryoverAmount;
        public double GWLifetimeSingleExcessRMD;
        public double GWLifetimeSingleWithdrawals;
        public int GWLifetimeSingleLastWithdrawalDate;
        public double GWLifetimeSingleGMWBPercentage;
        public double GWLifetimeSingleAnnualBenefit;
        public double GWLifetimeSingleAvailableAmount;
        public int GWLifetimeSingleEarliestIncomeDate;
        public double GWLifetimeSingleBasisRolledUpValue;
        public int GWLifetimeSingleRollupToDate;
        public double GWLifetimeSingleDepositBonus;
        public double GWLifetimeSingleDepositBasis;
        public double GWLifetimeSingleDeathBasis;
        public double GWLifetimeSingleMaxAnniversaryValue;
        public bool GWLifetimeSingleExcessWithdrawalTaken;
        public bool GWLifetimeSingleRestoreUsed;
        public double GWLifetimeJointLifetimeBasis;
        public double GWLifetimeJointCarryoverAmount;
        public double GWLifetimeJointExcessRMD;
        public double GWLifetimeJointWithdrawals;
        public int GWLifetimeJointLastWithdrawalDate;
        public double GWLifetimeJointGMWBPercentage;
        public double GWLifetimeJointAnnualBenefit;
        public double GWLifetimeJointAvailableAmount;
        public int GWLifetimeJointEarliestIncomeDate;
        public double GWLifetimeJointBasisRolledUpValue;
        public int GWLifetimeJointRollupToDate;
        public double GWLifetimeJointDepositBonus;
        public double GWLifetimeJointDepositBasis;
        public double GWLifetimeJointDeathBasis;
        public double GWLifetimeJointMaxAnniversaryValue;
        public bool GWLifetimeJointExcessWithdrawalTaken;
        public bool GWLifetimeJointRestoreUsed;

        public int GWBenefitPhaseStartDate;
        public int GWLastResetDate;
        public int GWLastPremiumDate;
        public int GWNextResetDate;
        public int GWLastRateChangeDate;   // The Last Reset associated with a rate change.  

    }
    
    [Serializable]
    public class BalanceInquiryGuaranteedRetirementResponse : BaseResponse
    {
        public double GuarRetireTotalDue;

        public int[] GRPaymentDueBenefitSeq;
        public int[] GRPaymentDueDueDate;
        public int[] GRPaymentDueEffectiveDate;  
        public int[] GRPaymentDueWithdrawalEffectiveDate;  
        public string[] GRPaymentDueDueType;
        public double[] GRPaymentDueAmountDue;
        public double[] GRPaymentDueAmountPaid;
        public double[] GRPaymentDueModePremium;

    }
    

    [Serializable]
    public class DepositAllocationRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;

        public bool ShowFundsOnly;  // Do not retrieve models, only funds.  

        // In cases where models are involved, here is an example:  
        // Customer invests 50% of their money in ModelA, identified in "ModelSelectionPercent" below. 
        // Customer invests 50% of their money in ModelB.  
        // "FundA" is a part of ModelA, and wiithin this model, the customer placed 25% of their money. 
        // This means that FundA, within ModelA, has 25% * 50% of their money, or 12.5% of their money. 
        // So, 12.5% would be in DepositAllocation[].
        public double [] DepositAllocation;
    }

    [Serializable]
    public class DepositAllocationResponse : BaseResponse
    {

        public string AssetAllocationModelFlag;
        public string AssetAllocationModelStatus; 
        public int    ModelAllocEffectiveDate;
        public string ProfileID;
        public string ProfileDescription; 

        public string [] ModelName;
        public int [] ModelVersion; 
        public string [] ModelDescription;
        public short[] ModelAvailableRank;
        public double[] ModelMinPercent;
        public double[] ModelMaxPercent;
        public double[] ModelSelectionPercent;
        public short[] ModelMappingIndicator;

        public int [] SubModelModelTableIndex;
        public string[] SubModelModelName;
        public int[] SubModelModelVersion;
        public string[] SubModelName;
        public string[] SubModelDescription;
        public string[] SubModelPercentFlag;
        public double[] SubModelConstantPercent;
        public double[] SubModelMinPercent;
        public double[] SubModelMaxPercent;  
        public double[] SubModelSelectionPercent;
        public short[] SubModelMappingIndicator;

        public int [] CategoryModelTableIndex;
        public string[] CategoryModelName;
        public int[] CategoryModelVersion;
        public string[] CategoryName;
        public string[] CategoryPercentFlag;
        public double[] CategoryConstantPercent;
        public double[] CategoryMinPercent;
        public double[] CategoryMaxPercent;  

        public int RowCount;

        // 20121115-004-02:  Expanding outputs to include new items that will identify the 
        // fund as a part of a model, if applicable, but existing columns will all still exist. 
        // If Model Allocations are not involved, everything works the same as it did.  If Models 
        // are involved, the Fund list below will identify funds from all models, whether invested 
        // in or not.  The original "DepositAllocation[]" percentage gives the absolute percentage 
        // of how much money is invested in a particular fund/model.  DepositAllocation[] still 
        // totals 100% in all cases.  

        // Updates and refreshes on availability are not permitted for Model cases at this time. 
        // Currently, only inquiries are supported when the policy is setup to use Models.  

        public int[] FundModelTableIndex;  // Identifies the position within the model table above, if applicable, for the model the fund is a part of (returns a 1-based value, although C# array subscripts start at zero).    
        public int[] FundCategoryTableIndex;  // Identifies a position in the Category table, if applicable.    
        public string[] FundModelName;  // repeated here from Model table above for convenience.  Equivalent of using ModelName[ModelTableIndex-1]; 
        public int[] FundModelVersion; // repeated here for convenience.  
        public bool[] InvestedInThisModel; // Convenience feature, if ModelSelectionPercentage in corresponding table above is > 0, this is true. 
        public int[] FundSubModelTableIndex;
        public string[] FundSubModelName;
        public string[] FundSubModelDescription;
        public double[] FundModelAllocation;
        public double[] FundSubModelAllocation;


        public string [] FundID;
        public string [] FundAvailable;
        public string[] FundApprovalIndicator; // Referred to internally as the State Approval Flag.  
        public string[] TerminatedAlternateFundID;  // Only used when the FundID specified is terminated, and an alternate fund is given.  
        public string [] ShortDescription;
        public string [] LongDescription;
        public string [] FundType;
        public string[] CusipNumber;
        public string[] FundModelPercentFlag;   // values are "C" for Cosntant percentage, "M" for Min/Max  
        public double[] FundModelConstantPercent;
        public double[] FundModelMinPercent;
        public double[] FundModelMaxPercent;   


        // Note that DepositAllocation, defined in Input, is both input and output in nature.
    }

    [Serializable]
    // For Systematic input, we start with BalanceInput and add to it.  SysRqst will use
    // BalanceInput for the RunInquiry method, and this for the SaveSystematic method.
    public class SystematicRequest : BalanceInquiryRequest
    {
        public int DateAdded; // Date Added and Time Added only used to locate systematics for cancellation.  They are optional even in this case.  
        public int TimeAdded; // Uses HHMMSSXY format (where X is 1/10 and Y is 1/100 of a second). 
        public string SystematicType;
        public double ProcessingFee;
        public double WithdrawalAmount;
        public double LoanAmount;
        public string DistributionCode;
        public int LoanTerm;
        public string RepaymentMode;
        public string LoanPurpose;
        public string TransferInType;  // 'P' is percentages, and 'A' is amounts.  
        public double [] TransferOutPercent;
        public double[] TransferOutAmount;

        // TransferIn can be percentage or amount, depending on above flag.
        public double[] TransferIn; 
    }

    [Serializable]
    // We use BalanceOutput for the RunInquiry method of SysRqst.  This class is used
    // when submitting a SaveSystematic request.
    public class SystematicResponse : BaseResponse
    {
        public string ConfirmationNumber;
        public short TransferCount;
        public short TransferLimit;  

    }

    [Serializable]
    public class ProposalRequest: BaseRequest
    {
        public string Function;
        //public string WebLang;
        public double MoneyPurchasePremPct;
        public string UseDefaultRules;
        public int MinAge;
        public int MaxAge;
        public int MaxMaturityAge;
        public int MinMaturityAge;
        public int PrMinIssueAmount;
        public int PrMaxIssueAmount;
        public int MinMonthlyPrem;
        public int MaxMonthlyPrem;
        public int MinQuarterlyPrem;
        public int MaxQuarterlyPrem;
        public int MinAnnualPrem;
        public int MaxAnnualPrem;
        public int MinCoverPeriod;
        public int MaxCoverPeriod;
        public int MinMthlyPremPeriod;
        public int MinQtrlyPremPeriod;
        public int MinAnnualPremPeriod;
        public int MinSinglePrem;
        public int MaxSinglePrem;
        public string AgeBasis;
        public int LastAccessDate;
        public string Plancode;
        public string PlanMarketName;
        public string CoverageId;
        public string Lob;
        public int IssueDate;
        public int Dob;
        public string DobDdate;
        public int IssueAge;
        public string SexCode;
        public string Uwcls;
        public string UwclsDesc;
        public int Dob2;
        public string Dob2Ddate;
        public int IssueAge2;
        public string SexCode2;
        public string Uwcls2;
        public string UwclsDesc2;

        public int Specified;
        public string SuppressSpecAmtChg;
        public string CoveragePeriodFlag;
        public int CoveragePeriodYears;
        public string CoverageOption;  // CoverageOption and DividendOption will ultimately be placed in the same copybook byte, within LPNETAPI
        public string DividendOption;
        public string ExcessDividendOption;
        public int CalModesOverride;
        public string PaymentMode;
        public string BillingForm;
        public string LoanRepayMode;
        public string PaymentPeriodFlag;
        public int PaymentPeriodYears;
        public string RedPayForDefra;
        public double AddlLumpSum;
        public double NewWDAmount;
        public string IndexRule;
        public double IndexRate;
        public int IndexYear;
        public int SearchCv;
        public string SearchFlag;
        public int SearchYear;
        public string SearchBasis;
        public string Table;
        public int TableRating;
        public int TableDuration;
        public double FlatRating;
        public int FlatDuration;
        public string Table2;
        public int TableRating2;
        public int TableDuration2;
        public double FlatRating2;
        public int FlatDuration2;
        public double StartingRate;
        public int StartingYear;
        public double UltimateRate;
        public int UltimateYear;
        public double SecondRate;
        public int SecondYear;
        public int MinIssueAmount;
        public int MaxIssueAmount;
        public short MiAge1;
        public short MiAge2;
        public short MiAge3;
        public int FutrMaxIndex;
        public string ClientName;
        public string ClientStreet;
        public string ClientCity;
        public string ClientState;
        public string ClientZipCode;
        public long ClientPhoneNumber;
        public string AgentName;
        public string AgentAddress;
        public string AgentStreet;
        public string AgentCity;
        public string AgentState;
        public string AgentZipCode;
        public long AgentPhoneNumber;
        public int AirMaxIndex;
        public string PrintScreen;
        public string PrintCover;
        public string PrintSummary;
        public string PrintDetailFlag;
        public int PrintDetailYears;
        public string CompanyCode;

        public string PolicyNumber;
        public int EffectiveDate;
        public int PolicyYear;
        public int PolicyMonth;
        public double InfPuaAmount;
        public double InfDivAccums;
        public double InfPremDepFund;
        public double InfLoanBalance;
        public int InfLoanAccrualDate;
        public double InfLoanAmtAvail;

        public double NewLoanAmt;

        // public int MaturityDate;
        public string MoneyPurchaseFlag;
        public int ProposalNumberKey;
        public double Premium;

        public int [] FutrYear;
        public int [] FutrAge;
        public double [] FutrPremium;
        public int [] FutrSpecified;
        public string [] FutrDbOption;
        public int [] FutrTargetCv;
        public int [] FutrDepositWithdrl;
        public int [] FutrLoan;
        public string [] FutrLoanOption;

        public  string [] AirCoverageCode;
        public  string [] AirCoverageId;
        public  int [] AirDob;
        public  int [] AirAge;
        public  string [] AirSexCode;
        public  string [] AirUwcls;
        public  double [] AirAmount;
        public string [] AirStatus;
        public int [] AirIssueDate;
        public double [] AirModePremium;
        public string[] AirPrimaryInsured; 
        public  string [] AirInForceFlag;
        public  int [] AirInForceYears;
        public string [] AirTable;
        public int[] AirTableRating;
        public  int [] AirTableDur;
        public  double [] AirFlat;
        public  int [] AirFlatDur;
        public  int [] AirComponentNum;
        public  string [] AirDefaultType;
        public  string [] AirAmtBasis;
        public  int [] AirMinIssueAmt;
        public  int [] AirMaxIssueAmt;

        //20160526-007-01   SAP  Added properties for Mortgage Special Premiums in Proposal 
        public int[] IllustrationID;
        public int[] DraftDate;
        public string[] PayType;
        public double[] PremiumOutlayPayment;

    }

    [Serializable]
    public class ProposalResponse: BaseResponse
	{
        public int[] ProcessWarningCode;
        public string[] ProcessWarningMessage; 

        public int CurrLastEntry;
        public int GuarLastEntry;
        public int MidPointLastEntry;
        public int MaturityDate;
        public int CurrMinPremPerd;
        public int GuarMinPremPerd;
        public int MidptMinPremPerd;
        public double MinimumPrem;
        public double TargetPrem;
        public double GuidelineLevelPrem;
        public double GuidelineSinglePrem;
        public double Tamra7PayPrem;
        public int TamraMecDate;
        public int IssueDate;
        public int CurrEndingDate;
        public int MidEndingDate;
        public int GuarEndingDate;
        public string CurrEndIndicator;
        public string MidEndIndicator;
        public string GuarEndIndicator; 

        public int PvMaxIndex;
        public double NetpCurr10;
        public double NetpCurr20;
        public double NetpGuar10;
        public double NetpGuar20;
        public double SurrCurr10;
        public double SurrCurr20;
        public double SurrGuar10;
        public double SurrGuar20;
        public double Elad10;
        public double Elad20;
        public double NetpCurr10Lp;
        public double NetpCurr20Lp;
        public double NetpGuar10Lp;
        public double NetpGuar20Lp;
        public double CurrIntRate;
        public double GuarIntRate;
        public double Proj1IntRate;
        public double Proj2IntRate;
        public double Proj3IntRate;
        public double Proj4IntRate;
        public double LoanIntRate;
        public double SpecialClassLoanRate; 
        public string ImpairedRule;
        public double ImpairedIntRate;
        public string PrfrImpRule;
        public double PrfrImpIntRate;
        public string VarIllusFlag;
        public double PctExpenseChg;
        public double ExpenseCharge;
        public double AdminChg1st;
        public double AdminChgAfter;
        public double GtdYield10;
        public double GtdYieldMat;
        public double CurrYield10;
        public double CurrYieldMat;
        public double AnnualPolicyFee;
        public double CurrModalSemiAnnual;
        public double CurrModalQuarterly;
        public double CurrModalMonthly;
        public double CurrModalMonthlyPac;
        public double GuarModalSemiAnnual;
        public double GuarModalQuarterly;
        public double GuarModalMonthly;
        public double GuarModalMonthlyPac;
        public double CurrModalBase;
        public double CurrModalRiders;
        public double GuarModalBase;
        public double GuarModalRiders;
        public string LevelDbOptionCode;
        public string IncrsDbOptionCode;
        public string LoanTiming;
        public string QualCode;
        public string TrLoanTiming;
        public double TrLoanIntRate;
        public double AccumIntRate;
        public string ProcMsgFlag;
        public string ProcessingMessage;
        public int ErrorField;
        public double TotalPremiums;

        public int [] PolicyYear;
        public int [] AttainedAge;
        public double [] AnnualPrem;
        public int [] SpecifiedAmt;
        public double [] Withdrawal;
        public double [] LoanActivity;
        public double [] LoanBalance;
        public double [] LoanIntPaid;
        public double [] GuidlnSngPrm;
        public double [] GuidlnLvlPrm;
        public double [] GuidlnLimit ;
        public int[] GuidlnViolationDate;
        public double[] PlannedPremium;
        public double[] RejectedPremium;
        public double[] PremiumBasis;
        public double[] CumulativePremium; 

        public double [] CurrCoiRate;
        public double [] AsmdIntRate;
        public double [] GtdIntRate;
        public double [] SurrChgRate;
        public double [] CurrCashVal;
        public double [] CurrSurrVal;
        public double [] CurrDeathBen;
        public double [] GuarCoiRate;
        public double [] GuarCashVal;
        public double [] GuarSurrVal;
        public double [] GuarDeathBen;
        public double [] MidptCoiRate;
        public double [] MidptCashVal;
        public double [] MidptSurrVal;
        public double [] MidptDeathBen;

        public double [] CurrMinimumPremium;
        public double [] CurrTargetPremium;
        public double [] CurrTamraPremium;

        public double [] TrCurrAnnualPrem;
        public double [] TrGuarAnnualPrem;
        public double [] TrDeathBenefit;
        public double [] TrGtdCashValue;
        public double [] TrCashDividend;
        public double [] TrTrmlDividend;
        public double [] TrDivReducePrem;
        public double [] TrPaidUpAdds;
        public double [] TrPaidUpAddsCv;
        public double [] TrDividendAccums;
        public int [] TrOytAdds;
        public double [] TrOytAddsCv;
        public double [] TrAnnualDividend;
        public double [] TrCurrCashValue;
        public double [] TrCurrDb;
        public double [] TrLoanAct;
        public double [] TrLoanBal;
        public double [] TrLoanIntPd;
        public double [] TrMidPtPremium;
        public double [] TrMidPtSurrVal;
        public int [] TrMidPtDeathBen;
        public double [] TrmMidPtPremium;
        public double [] TrmLpGtdPrem;
        public int [] TrmLpGtdDb;
        public double [] TrmLbGtdPrem;
        public int [] TrmLbGtdDb;
        public double [] TrmLpCurrPrem;
        public int [] TrmLpCurrDb;
        public double [] TrmLbCurrPrem;
        public int [] TrmLbCurrDb;
        public double [] TrInitCurrAnnual;
        public double [] TrInitCurrSemi;
        public double [] TrInitCurrQtrly;
        public double [] TrInitCurrMnthly;
        public double [] TrInitCurrPac;
        public double [] TrInitGuarAnnual;
        public double [] TrInitGuarSemi;
        public double [] TrInitGuarQtrly;
        public double [] TrInitGuarMnthly;
        public double [] TrInitGuarPac;
        public double [][]  ProjCoiRate;
        public double [][] ProjCashVal;
        public double [][] ProjSurrVal;
        public double [][] ProjDeathBen;
        public double [][] ProjMiAtD12;
        public double[][] ProjMiAtMat;
        public double [] CurrMiAge;
        public double [] GuarMiAge ;
        public double [] PdfAccountBal;
        public double [] DivWd;
        public double [] PpWd;
        public double [] PdfWd;
        public double [] PpGtdSingleAmt;
        public double [] PpGtdSingleCv;
        public double [] PpGtdRecurAmt;
        public double [] PpGtdRecurCv;
        public double [] PpCurrSingleAmt;
        public double [] PpCurrSingleCv;
        public double [] PpCurrRecurAmt;
        public double [] PpCurrRecurCv;
        public double [] RecurringPpDiv;
        public double [] DumpinPpDiv;
        public double [] DivToPua;
        public double [] DivToAccum;
        public double [] WithDeathBenefit;
        public double [] GtdReducePaidUp;
        public double [] CurReducePaidUp;

    }

    // We don't include a separate output class for Agent (aiefapi), because
    // all input items are also output.

    [Serializable]
    public class AgentRequest: BaseRequest {

        public string NameDel;
        public string AddrDel;
        public string MasterDel;
        public string LicenseDel;
        public string ContedDel;
        public string ContedH1Del;
        public string ContedH2Del;
        public string AppointmentDel;
		public string NASDDel;
        public string CoursesDel;
        public string PrinciplerepDel;
        public string PersonalinfoDel;
        public string HierDel;
        public string VestDel;
        public string AffiliateDel;
        public string FunctionType;
        public string FunctionSubtype;
        public string CompanyCode;
        public string AgentNumber;
		public string SsnTaxId;
        public string BusinessName;
        public string NameLast;
        public string NameFirst;
        public string NameMiddle;
        public string NameType;
        public int NameId;
		public string NewSsnTin;
        public string NewBusName;
        public string NewLast;
        public string NewFirst;
        public string NewMiddle;
        public string NamePrefix;
        public string NameSuffix;
        public string NameSexCode;
        public string NameDeceased;
        public int Dob;
        public string TaxStatus;
        public string TaxWithholdingFlag;
        public int TaxCertificationDate;
        public string TaxCertificationCode;
        public string DirectDepositFlag;
        public int NextPrenoteDate;
        public int EndDate;
        public int NewEndDate;
        //20170117 SAP 20161201-003-01 - Begin
        public string PersonalEmailAdr;
        public string BusinessEmailAdr;
        //20170117 SAP 20161201-003-01 - End
        public short TranCode;
        public int BankNameId;
        public string PayeeBankAccount;
        public int LastPrenoteDate;
        public short PrenoteLagDays;
        public int AddressId;
        public string NameAddr1;
        public string NameAddr2;
        public string NameAddr3;
        public string NameCity;
        public string NameState;
        public int Zip;
        public short Zip4;
        public string NameCntry;
        public string NameCounty;
        public string CityCode;
        public string CountyCode;
        public string AddressType;
        public string AddressCode;
        public string BadAddressInd;
        public int CancelDate;
        public int EffectiveDate;
        public int NewEffectiveDate;
        public short RecurringStartMonth;
        public short RecurringStartDay;
        public short RecurringStopMonth;
        public short RecurringStopDay;
        public short AreaCode;
        public short TelePrefix;
        public short TeleNumber;
        public short FaxAreaCode;
        public short FaxTelePrefix;
        public short FaxTeleNumber;
        public short CellAreaCode;
        public short CellTelePrefix;
        public short CellTeleNumber;        
        public string AddrCompany;
        public string AddrPolicy;
        public string StatusCode;
        public int StatusDate;
        public string Classification1;
        public string Classification2;
        public string Classification3;
        public int StartDate;
        public string BasicAsscAgent;
        public string DbaState;
        public string CertificationCode;
        public int ContractDate;
		public string AgntReasonCode;
		public string AutoIssueFlag;
		public string AgntDivisionCode;
        public string AgntConsolNum;
        public string [] StateLicensed;
        public string [] LicenseStatusCode;
        public string [] LicenseReasonCode;
        public int [] LicenseGranted;
        public int [] LicenseExpires;
        public string [] ResidentCode;
        public string [] Nasd;
        public string [] Life;
        public string [] Health;
        public string [] Annuity;
        public string [] BasicLtc;
        public int [] BasicLastRenewal;
        public int [] BasicNextRenewal;
        public string [] LicenseNumber;
        public string [] LicenseType;
        public string MarketingCode;
        public string AgentLevel;
        public int StopDate;
        public string NewMarketingCode;
        public string NewAgentLevel;
        public int NewStopDate;
        public string ReportDesc;
        public string RegionCode;
        public string DealCode;
        public string AddlCommIndicator;
        public string AddlDealCode;
        public string PayCode;
        public string PayFrequency;
        public string AdvanceIndicator;
        public string AdvancePayFrequency;
        public string HierarchyAgent;
        public string HierarchyMarketCode;
        public string HierarchyAgentLevel;
        public string FinancialAgent;
        public string AllocatedAgent;
        public double AllocatedPercent;
        public int AllocatedAmount;
        public int DebitMaximum;
        public double RecovPercent;
        public int RecovAmount;
        public double DeferredPercent;
        public int DeferredAmount;
        public string AdvancePointer;
        public string FicaInd;
        public string AddlUpHier;
        public string ReportForm;
        public string ApplyToUnsecPolicy;
        public string ApplyToUnsecNonPol;
        public string ApplyToUnsecBalance;
        public double FicaPercent;
        public int FicaMaximum;
        public string StatementAgent;
        public string StatementInd;
        public double AllocRenewalPercent;
        public int AllocRenewalAmount;
        public string PayReason;
        public string AgencyCode;
        public int Mga;
        public int Control;
        public short ControlId;
        public string ServicingAgency;
        public string MailSortKey;
        public string AssignmentFlag;
        public string ReasonCode;
		public string DivisionIndicator;
		public double ProdPercent;
		public string NetComm;
		public string CommType;
		public string BonusAllowed;
		public short BonusLevel;
		public string BonusCode;
		public string DbBalIntFlag;
		public double DbBalIntPct;
		public string DfltCommOptn;
		public string AllocationOption;
        public string ReserveFlag;
        public string ReserveRateID;
        public double ReserveFlatAmount;
        public double ReserveMaxBalance;
        public double ReserveMinBalance;
        public string VestMarketCode;
        public string VestAgentLevel;
        public string ClassCode;
        public int VestStartDate;
        public string VestDealType;
        public string VestOrRevCode;
        public string VestDurationCode;
        public short VestDuration;
        public int VestStopDate;
        public int VestMaxAmount;
        public double VestMaxBalance;
        public string VestCode;
        public double VestPercent;
        public string VestRevToAgent;
        public string VestRevToMarket;
        public short VestRevToLevel;
        public string VestCheckRevToAgent;
        public string [] ContEdReqState;
        public string [] ContEdReqFlag;
        public int [] ContEdReqStrtDate;
        public int [] ContEdReqStopDate;
        public string [] ContEdQualified;
        public string [] ContEdNonQual;
        public string [] ContEdPartnership;
        public string [] ContEdH1ReqState;
        public string [] ContEdH1ReqFlag;
        public int [] ContEdH1ReqStrtDate;
        public int [] ContEdH1ReqStopDate;
        public string [] ContEdH1Qualified;
        public string [] ContEdH1NonQual;
        public string [] ContEdH1Partnership;
        public string [] ContEdH2ReqState;
        public string [] ContEdH2ReqFlag;
        public int [] ContEdH2ReqStrtDate;
        public int [] ContEdH2ReqStopDate;
        public string [] ContEdH2Qualified;
        public string [] ContEdH2NonQual;
        public string [] ContEdH2Partnership;
        public string [] ApptState;
        public string [] ApptStatusCode;
        public string [] ApptReasonCode;
        public int [] ApptGranted;
        public int [] ApptExpires;
		public string [] NASDState;
		public string [] NASDStatus;
		public string [] NASDReason;
		public int [] NASDDateGranted;
		public int [] NASDDateExpired;
        public int [] CourseActDate;
        public int [] CourseCeuDate;
        public string [] CourseNumber;
        public string [] PrincipleState;
        public string [] PrincipleAgent;
        public string [] ParamResponse;
        public string [] Affiliate;
    }

    [Serializable]

    public class DatabaseRequest: BaseRequest {

        public string FileName;
        public short Function;
        public short KeyNumber;
        public short FileNumber;
        public int FileLength;
        public string PassKeyValues;
        public string[] KeyBuffer;
        public byte[] DataBuffer;
    }


    [Serializable]
    public class IllustrationInputRequest : BaseRequest {
        public string ProductId;
        public int IssueDate;
        public string IssueState;
        public short IssueAge;
        public int BirthDate;
        public string SexCode;
        public string Uwcls;
    }


    [Serializable]
    public class IllustrationInputResponse : BaseResponse {

        public string Description;
        public string PolicyFormNum;
        public int MinIssueAge;
        public int MaxIssueAge;
        public string FaceType;
        public int MinIssueAmt;
        public int MaxIssueAmt;
        public string SexBasis;
        public string AgeBasis;
        public string ParCode;
        public int NumberOfDivOptions;
        public short [] DivOption;
        public string [] DivDescription;
        public int NumberOfSsTables;
        public string [] SsTable;
        public double [] SsPrct;
        public int NumberOfUwcls;
        public string [] UwclsCode;
        public string [] UwclsDesc;
        public string UwclsRatingTable;
        public string UwclsFlat;
        public double UwclsMaxFlat;
        public string LoansAvailable;
        public string MonthlyIncome;
        public int MiAge1;
        public int MiAge2;
        public int MiAge3;
        public string PartWdAllowed;
        public string DbOptionsAllowed;
        public string DbOption1;
        public string DbDescription1;
        public string DbOption2;
        public string DbDescription2;
        public string AllowOverrideInt;
        public string FollowIntPattern;
        public double IntRate1;
        public int IntDur1;
        public double IntRate2;
        public int IntDur2;
        public double IntRate3;
        public int IntDur3;
        public int NumberOfRiders;
        public string [] RdPlanCode;
        public string [] RdDescription;
        public string [] RdComponentType;
        public short [] RdMaximumNumber;
        public short [] RdMinIssAge;
        public short [] RdMaxIssAge;
        public string [] RdFaceType;
        public int [] RdMinIssueAmt;
        public int [] RdMaxIssueAmt;
        public string [] RdSexBasis;
        public string [] DefaultType;
        public double [] AbsoluteValue;
        public short [] PercentValue;
        public int [] RdNumberOfSsTables;
        public string [][] RdSsTable;
        public double [][] RdSsPrct;
        public int [] RdNumberOfUwcls;
        public string [][] RdUwclsCode;
        public string [][] RdUwclsDesc;
        public string [][] RdUwclsRatingTable;
        public string [][] RdUwclsFlat;
        public double [][] RdUwclsMaxFlat;
    }

    [Serializable]
    public class CreditInsuranceNewBusinessRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public string ProductId;
        public int TransactionDate;
        public string LoanNumber;
        public int LoanDate;
        public string LanguagePreference;
        public string BranchNumber;
        public int RescissionDate;
        public int LoanTerm;
        public int LoanMaturityDate;
        public int NextLoanPaymentDate;
        public int LoanDueDay;
        public string BranchState;
        public string IndividualOrJoint;
        public double MonthlyPayment;
        public double PrincipalAmount;
        public double InterestRate;
        public double AmountFinanced;
        public double APR;
        public int InceptionDate;
        public string IssueState;
        public int CoverageTerm;
        public double LifeInsuranceAmount;
        public double DICoverageAmount;
        public string ReportingOnly;
        public string [] Feature;
        public string [] ApplicantFirstName;
        public string [] ApplicantMiddleName;
        public string [] ApplicantLastName;
        public string [] ApplicantAddressLine1;
        public string [] ApplicantAddressLine2;
        public string [] ApplicantAddressLine3;
        public string [] ApplicantCity;
        public string [] ApplicantState;
        public string [] ApplicantZip;
        public string [] ApplicantBoxNumber;
        public string [] ApplicantZipExtension;
        public string [] ApplicantSSN;
        public long []ApplicantPhone;
        public int [] ApplicantDOB;
        public string [] ApplicantGender;
        public string [] ApplicantUWCLS;
        public string [] ApplicantBorrowerType;
        public string [] ApplicantCreditLife;
        public string [] ApplicantCreditDisability;
        public string [] ApplicantUnemployment;
        public string [] ApplicantOccupationCode;
        public string [] ApplicantEmploymentStatus;
        public string [] ApplicantHoursWorked;
    }

    [Serializable]
    public class CreditInsuranceNewBusinessResponse : BaseResponse
    {
        public int LastError ;
        public int [] ErrorNumber;
        public string [] ErrorType;
        public string [] ErrorCoverageType;
        public string [] ErrorDetailMessage;
        public double [] CoverageAmount;
        public int [] TermOfCoverage;
        public string [] PremiumType;
        public double [] MonthlySinglePremium;
        public double [] MonthlyJointPremium;
        public double [] MonthlyBilledPremium;
        public double [] AllSinglePremium;
        public double [] AllJointPremium;
        public double [] AllBilledPremium;
        public double TotalMonthlySinglePremium;
        public double TotalMonthlyJointPremium;
        public double TotalMonthlyBilledPremium;
        public double TotalAllSinglePremium;
        public double TotalAllJointPremium;
        public double TotalAllBilledPremium;
        public string GeneratedPolicyNumber;
        public string OutputIssueState;
        public int OutputInceptionDate;
        public string [][] YEIRequested;
        public string [][] YEIAllowed;
    }


    [Serializable]
    public class APIListenerInfo {

        public int FirstPort ;
        public int LastPort ;
        public int SessionLimit ;
        public int [] CountPerPort ;
        public int [] PidPerPort ;
    }

    [Serializable]
    public class SessionFactoryInfo {

        // These properties can be passed back to a caller on request,
        // from method GetInfo().
        public string Path ;
        public string WorkareaPath ;
        public string ImagePath ;
        public string ODBCInf ;
        public string SQLDataSrc ;
    }

    [Serializable]
    public class DeathQuoteRequest : BaseRequest
    {
        // This class contains copies of properties that are input to the DthQuote server-side object.
        public string CompanyCode ;
        public string PolicyNumber ;
        public int EffectiveDate ;
        public int InputNameId ;
        public int InputBenefitSeq ;
        public bool OverrideFutureDateEdits; 
    }

    [Serializable]
    public class DeathQuoteResponse : BaseResponse
    {
        // This class contains the properties that are output and input/output for the DthQuote object.

        public int EffectiveDateUsed ;
        public string CompanyCode ;
        public string PolicyNumber ;
        public int EffectiveDate ;
        public int InputNameId ;
        public int InputBenefitSeq ;

        public int NumberOfInsureds ;
        public double LoanPrincipal ;
        public double LoanInterest ;
        public double LoanWriteoff ;
        public double LoanBalance ;
        public double UnappliedCash ;
        public double Iba01Amt ;
        public double Iba02Amt ;
        public double Iba04Amt ;
        public double AdbFaceAmt ;
        public double FundTax ;
        public double DeferedPremTax ;
        public double RefundPremTax ;
        public double ReturnOfPremium;
        public int [] InsuredNameId ;
        public string [] InsuredRelateCode ;
        public int [] InsuredRelateSeq ;
        public double [] TotDeathBenefit ;
        public double [] TotFaceAmt ;
        public double [] TotPuaFaceAmt ;
        public double [] TotOytFaceAmt ;
        public double [] TotEtiFaceAmt ;
        public double [] TotRpuFaceAmt ;
        public double [] TotDivAccums ;
        public double [] TotDivAdjust ;
        public double [] TotPremRefund ;
        public double [] TotSpecifiedAmt ;
        public double [] TotUlDeathBenefit ;
        public double [] TotUlFundValue ;
        public string [] UlDeathBenefitOpt ;
        public string [] UlDeathBenefitOptDesc ;
        public double [] TotArFundValue ;
        public double [] AnnuitizationBenefit ;
        public double [] AnnuitizationAnnualAmt ;
        public int [] AnnuitizationNumberYears ;
        public double [] LumpSumBenefit ;
        public string [] GWBNWaitPeriodFlag ;

        // New GMB additions are subscripted first by insured, and then by a row number, 
        // from 0 - 9 currently. NumberOfGMB holds number actually used.  
        public int[] NumberOfGMB; 
        public string[][] GMBDescription;
        public string[][] GMBCoverageID;
        public double[][] GMBGrossAmount;
        public double[][] GMBPremiumTax;
        public double[][] GMBLoanAmount;
        public double[][] GMBNetAmount;
        public double[][] GMBEarningsEnhancement;  
        public double[][] GMBLumpSum;
        public double[][] GMBAnnuitized;  

        public int [] NumberOfBenefits ;
        public int [][] BenefitSeq ;
        public string [][] BenefitType ;
        public string [][] BenefitPlanCode ;
        public string [][] BenefitDescription ;
        public double [][] BenefitDeathBenefit ;
        public double [][] BenefitFaceAmt ;
        public double [][] BenefitPuaFaceAmt ;
        public double [][] BenefitOytFaceAmt ;
        public double [][] BenefitEtiFaceAmt ;
        public double [][] BenefitRpuFaceAmt ;
        public double [][] BenefitDivAccums ;
        public double [][] BenefitDivAdjust ;
        public double [][] BenefitPremRefund ;
        public double [][] BenefitSpecifiedAmt ;
        public double [][] BenefitUlDeathBenefit ;
        public double [][] BenefitUlFundValue ;
        public string [][] BenefitUlDeathBenOpt ;
        public string [][] BenefitUlDeathBenOptDesc ;
        public double [][] BenefitArFundValue ;
        public double [][] BenefitFundTax ;
        //public string[][] BenefitGWBNWaitPeriodFlag ;
    }

    [Serializable]
    public class MultipleInsuredQuoteRequest : BaseRequest
    {
        public string Function; 
        public string CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public string BillingForm; 
        public string ProductID; 

        public string[] TargetBenefitCode;
        public double[] TargetMaxBenefit; 

        public string [] BenefitRequest ; // "A" or "Add", "M" or "Modify", "D" or "Delete".  
        public short[] BenefitSequence;
        // Benefit Type, Value Per Unit, and UnitsOrFaceFlag (U/F), are loaded by LoadExistingBenefits, 
        // along with other properties here, but are not actually needed or used in quote. 
        public string[] BenefitType;  
        public string [] CoverageID ;
        public double[] ValuePerUnit;  
        public string[] UnitsOrFaceFlag; 
		public double [] Units ; 
		public int [][] NameID ; 
		public string [][] Uwcls ; 
        public string[][] Sex;
        public int[][] DOB;
        public int[][] IssueAge; 
		public int [][] AgeRateUp;  
		public string [][] TableRating; 
		public double [][] PctRating;  
		public int [][] PctDuration; 
		public double [][] Flat;  
		public int [][] FlatDuration;
		public double [][] SecondFlat; 
		public int [][] SecondFlatDur;
        public string[][] ExtendedKeyID; 
		public string [][] ExtendedKey; 
		public string [][] State;  
		public int [][] AreaCode ;

        // This DataTable will be exposing a COBOL array with multiple columns, for read 
        // only usage, returned by the LoadExistingBenefits method.  
        public DataTable KDDefinitions; 
	}

    [Serializable]
    public class MultipleInsuredQuoteResponse : BaseResponse
    {
        public int EffectiveDateUsed ;
        public int LifePROMessageNumber ;
        public double CurrPolcTotal ;
        public double QuotePolcTotal ;
        public string[] ModalPremiumDescription;
        public string[] ModalPremiumCode; 
        public double[] ModalPremiumAmount;  

	}

    [Serializable]
    public class HealthBenefitQuoteRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public int BenefitSeq;
        public int EffectiveDate;
        public string BenefitCode;
    }

    [Serializable]
    public class HealthBenefitQuoteResponse : BaseResponse
    {
        public int EffectiveDateUsed;
        public int InsCount;
        public string LinkedPolicyType;
        public string LinkedCompanyCode;
        public string LinkedPolicyNumber;
        public string LinkedPolicyStatus; 

        public int[] NameID;
        public string[] Name;
        public string[] BenBenefitCode;
        public string[] BenBenefitCodeDesc;
        public double[] BenBenefitAmount;
        public double[] BenAccumClaimPays;
        public double[] BenTransferredBenefitAmount;
        public double[] BenSharedBenefitRemaining;
        public double[] BenRemainLifeMax;
        public string[] BenRemainLifeDaysFlag;
        public double[] BenAccumLifeDays;
        public double[] BenRemainLifeDays;
        public string[] BenInflateSelectDescription;
        public string[] BenInflateSelectState;
        public double[] BenInflateDailyRate;
        public double[] BenInflateLifetimeRate;
        public string[] BenDailyNFOFlag;
        public string[] BenLifeNFOFlag;
        public int[] BenAdjCount;
        public int[][] BenSeq;
        public int[][] BenIssueDate;
        public double[][] BenDMBAdj;
        public double[][] BenLMBAdj;
        public double[][] BenAllocatedReserve;
        public double[][] BenPortfolioRate;
        public double[][] BenGuaranteeRate; 
        public double[][] BenPriorNegativeCredit;
        public double[][] BenExcessEarnings;
        public double[][] BenNetSinglePremiumPerDollar;
        public double[][] BenAutomaticBenefitIncrease; 

        public int[] BenErrorCode;
        public string[] BenErrorMessage;

        // See APIServe and module HealthCalc for a definition of 
        // the columns that AllBenefitsTable contains.   This table 
        // lists all the benefit codes and related columns of information 
        // available for the policy.  
        public DataTable AllBenefitsTable; 

    }

    [Serializable]
    public class PremiumIllustrationRequest : BaseRequest
    {
        public string BillingForm;
        public short BillingMode;
        public string IssueState;
        public int EffectiveDate;
        public int IssueDate; 
        public string CompanyCode;
        public short[] IssueAge;
        public int[] Dob;
        public string[] Gender;
        public string[] Uwcls;
        public string[][] CoverageID;
        public int[][] CovFaceAmount;
        public double[][] CovUnits;
        public string[][] CovTable;
        public double[][] CovPctRating;
        public short[][] CovPctRatingDur;
        public double[][] CovFlatExtra;
        public short[][] CovFlatExtraDur;
        public string[][][] SuppCoverageID;
        public int[][][] SuppFaceAmount;
        public double[][][] SuppUnits;
        public string[][][] SuppTable;
        public double[][][] SuppPctRating;
        public short[][][] SuppPctRatingDur;
        public double[][][] SuppFlatExtra;
        public short[][][] SuppFlatExtraDur;

    }

    [Serializable]
    public class PremiumIllustrationResponse : BaseResponse
    {
        public int ContReturnCode;
        public string ContMessage;
        public double ContPolicyFee;
        public double ContAnnualPrem;
        public double ContSemiAnnPrem;
        public double ContQtrlyPrem;
        public double ContMonthlyPrem;
        public double ContBiweeklyPrem;
        public double ContWeeklyPrem;
        public int[][] CovReturnCode;
        public string[][] CovMessage;
        public double[][] CovAnnualPrem;
        public double[][] CovSemiAnnlPrem;
        public double[][] CovQtrlyPrem;
        public double[][] CovMonthlyPrem;
        public double[][] CovBiweeklyPrem;
        public double[][] CovWeeklyPrem;
        public int[][][] SuppReturnCode;
        public string[][][] SuppMessage;
        public double[][][] SuppAnnualPrem;
        public double[][][] SuppSemiAnnlPrem;
        public double[][][] SuppQuarterlyPrem;
        public double[][][] SuppMonthlyPrem;
        public double[][][] SuppBiweeklyPrem;
        public double[][][] SuppWeeklyPrem;
    }

    [Serializable]
    public class DisclosureQuoteRequest : BaseRequest
    {
        public string Function;
        public string CoverageId;
        public string SuppCoverageId;
        public string BenefitType;
        public string BenefitSubType;
        public string CompanyCode;
        public string PolicyNumber;
        public int BenefitSeq;
        public int ParentBenefitSeq;
        public int SubstSeq;
        public int IssueDate;
        public int EffectiveDate;
        public string BillingForm;
        public int BillingMode;
        public double FaceUnitsOrAmount;
        public string FaceType;
        public string[] Gender;
        public string[] Uwcls;
        public int[] Dob;
        public int[] IssueAge;
        public string[] RatingTable;
        public double[] PercentRating;
        public int[] PercentRatingDur;
        public double[] FlatExtra;
        public int[] FlatExtraDur;
        public string PremBasedOnDate;
        public int PremiumRank;
        public int RatingRank;
        public int CurrPercent;
        public int GuarPercent;
        public string CurrBasis;
        public string GuarBasis;
        public string InputIssueState;
    }

    [Serializable]
    public class DisclosureQuoteResponse : BaseResponse
    {
        public int PriReturnCode;
        public string PriReturnMessage;
        public int PrrReturnCode;
        public string PrrReturnMessage;
        public int GpiReturnCode;
        public string GpiReturnMessage;
        public int CviReturnCode;
        public string CviReturnMessage;
        public int DbiReturnCode;
        public string DbiReturnMessage;
        public int DviReturnCode;
        public string DviReturnMessage;
        public int RpuReturnCode;
        public string RpuReturnMessage;
        public int EtiReturnCode;
        public string EtiReturnMessage;
        public int SpiReturnCode;
        public string SpiReturnMessage;
        public int SgiReturnCode;
        public string SgiReturnMessage;
        public int DatePaidUp;
        public int ExpirationDate;
        public int NextPremDate;
        public int NextPremDur;
        public string Description;
        public string IssueState;
        public double DirectMonthlyPrem;
        public double DirectQuarterlyPrem;
        public double DirectSemiAnnualPrem;
        public double AnnualPolicyFee;
        public double[] InitialModalPrem;
        public double[] InitialPrem;
        public double[] RenewalPrem;
        public double[] GuarPrem;
        public double[] CashValue;
        public double[] DeathBenefit;
        public double[] DivAtIssue;
        public double[] RpuValue;
        public double[] EtiYear;
        public double[] EtiDay;
        public double[] SubstCurr;
        public double[] SubstGuar;
        public double NetCurrIndex05;
        public double NetCurrIndex10;
        public double NetCurrIndex20;
        public double NetCurrIndex25;
        public double NetGuarIndex05;
        public double NetGuarIndex10;
        public double NetGuarIndex20;
        public double NetGuarIndex25;
        public double SurrCurrIndex05;
        public double SurrCurrIndex10;
        public double SurrCurrIndex20;
        public double SurrCurrIndex25;
        public double SurrGuarIndex05;
        public double SurrGuarIndex10;
        public double SurrGuarIndex20;
        public double SurrGuarIndex25;
        public double EquivCurrIndex10;
        public double EquivCurrIndex20;
        public double EquivCurrIndex25;
        public double EquivGuarIndex10;
        public double EquivGuarIndex20;
        public double EquivGuarIndex25;
        public double CalifCurrIndex05;
        public double CalifCurrIndex10;
        public double CalifCurrIndex20;
        public double CalifCurrIndex25;
        public double CalifGuarIndex05;
        public double CalifGuarIndex10;
        public double CalifGuarIndex20;
        public double CalifGuarIndex25;
        public int InitModalPremCnt;
        public int InitPremCnt;
        public int RenewalPremCnt;
        public int GuarPremCnt;
        public int CashValuesCnt;
        public int DeathBenefitCnt;
        public int DivAtIssueCnt;
        public int RpuCnt;
        public int EtiYearsCnt;
        public int EtiDaysCnt;
        public int SubstCurrCnt;
        public int SubstGuarCnt;
    }

    [Serializable]
    public class TerminatePolicyBenefitRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public int NameID;
        public int EffectiveDate;
        public string RequestType; // "Policy" or "Benefit" ("P" or "B" also allowed, not case sensitive)  
        public string SurrenderValueOption;  //"P" is current behavior, "S" is to suspend, not terminate if non-zero surrender value.
        public string ReasonCode;
        public short BenefitSequence;
        public string PolicyNotes;

    }

    [Serializable]
    public class TerminatePolicyBenefitResponse : BaseResponse
    {

        public int PaidToDate;
        public int StatusEffectiveDate;
        public string ContractCode;
        public string OutReasonCode;
        public double Suspense;
        public double SurrenderValue;

        public DataTable Benefits;
        public DataTable MultipleInsureds;   

    }

    [Serializable]
    public class RMDQuoteResponse : BaseResponse
    {
        public int EffectiveDateUsed; 
        public int RMDTaxYear;
        public double PriorYearEndValue;
        public bool AdjustedBenefitValue;
        public string AdjustedBenefitValueDesc;
        public short LifeExpectencyMethodCode;
        public string LifeExpectencyMethodDesc;
        public double RMDFactor;
        public double RMDAmount;
        public double WithdrawalsYTD; 
        public double RMDRemainingAmount;
        public double RMDDeferredAmount;
        public bool DeferredAmtInitRmd;
        public bool ActiveRMDRequest; 

        //  20130323-002-01: Begin changes    
        public double AdjustedBenefitValueAmount;
        public double SumDiscountedAdditionalBenefits;
        public double AdjustedBenefitValueExemptionPercentage;
        public double AdjustedBenefitValueExemptionFloor; 
        // End 20130323-002-01  

    }

    [Serializable]
    public class RMDQuoteRequest : BaseRequest
    {
        public string  CompanyCode;
        public string PolicyNumber;
        public int EffectiveDate;
        public bool OverrideFutureDateEdits; 

        // These do not need to be set if the defaults used by the system are acceptible.  
        // User may choose to use one or the other of these.  

        // If this propery is left zero, the system default will be used: 
        public short OverrideLifeExpectencyMethod;

        // If this property is left blank, the system default will be used.  
        public string OverrideDeferredAmountInInitRMD;  

    }


    [Serializable]
    public class CommissionControlResponse : BaseResponse
    {

        // Returns all matching Commission Control Split entries based on input criteria.  

        public short [] SplitControl;
        public int[] IssueDate;
        public int[] EffectiveDate;
        public int[] EndDate;
        public string[] RateOverrideFlag;
        public string[] ReferralFlag;
        public string[] ProdCrFlag;
        public short[] AttainedAge;
        public string[] PremiumIncrease;
        public string[] OverrideFlag; 
        public string[] CoderId;

        public string[][] AgentNumber;
        public double[][] CommissionPercent;
        public double[][] ProductionPercent;
        public string[][] ServiceAgentIndicator;
        public string[][] MarketCode;
        public string[][] AgentLevel; 

    }

    [Serializable]
    public class CommissionControlRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public short SplitControl;
        public int IssueDate;
        public int EffectiveDate;

        // The following inputs are used for adds only. 
        public bool UpdateRelationships;   // true updates the Relationship table with WA/SA entries.  
        public bool AddStateLicense;  // set to true to provide an optional state license entry to the agent master.  

        public string RateOverrideFlag;
        public string ReferralFlag;
        public string ProdCrFlag;
        public short AttainedAge;
        public string PremiumIncrease;
        public string OverrideFlag; 

        public string[] AgentNumber;
        public double[] CommissionPercent;
        public double[] ProductionPercent;
        public string[] ServiceAgentIndicator;
        public string[] MarketCode;
        public string[] AgentLevel; 

        // State License info.  This wil constitute one line on the Agent Master State License detail 
        // if provided, and if AddStateLicense, above, is true.  This currently only supports addition 
        // of one row (per agent number).  

        public string[] LicenseState;
        public string[] LicenseStatus; 
        public string[] LicenseReasonCode;
        public int[] LicenseGrantedDate;
        public int[] LicenseExpiresDate;
        public string[] LicenseResidentCode;
        public string[] LicenseNASD;
        public string[] LicenseLife;
        public string[] LicenseHealth;
        public string[] LicenseAnnuity;
        public string[] LicenseBasicLTC;
        public int[] LicenseBasicLastRenewalDate;
        public int[] LicenseBasicNextRenewalDate;
        public string[] LicenseNumber;
        public string[] LicenseType;  

    }

    public class SPIACalcInput : BaseRequest
    {
        public string CoverageID;
        public int IssueDate;
        public int StartDate;
        public string Function;
        public string Lives;
        public double FedWthdRate;
        public double StWthdRate;
        public string WaivePolFee;
        public string WaiveLoads;
        public string AnnuitantSex01;
        public int AnnuitantDOB01;
        public int IssueAge01;
        public int RateYears01;
        public string UWCLS01;
        public double SurvivorPct01;
        public string AnnuitantSex02;
        public int AnnuitantDOB02;
        public int IssueAge02;
        public int RateYears02;
        public string UWCLS02;
        public double SurvivorPct02;
        public string TerminationType;
        public string CalcType;
        public double InputAmount;
        public double Pre86Basis;
        public double Pst86Basis;
        public string Mode;
        public string Method;
        public int CertainPeriod;
        public int TemporaryPeriod;
        public double ConstIncrPct;
        public string PercentIncreaseType;
        public double AmtIncr;
        public double[] ModalPayments;
        public double[] PctIncreases;
        public int[] LumpPaytDate;
        public double[] LumpSumPayts;
        public double Result;
        public double ExclusionRatio;
        public string IssueState;
        public string Qualified;
        public string ValCode;
        public int ReturnCode;
        public string ErrorMessage;
        public int ValueDate;
        public string CompanyCode;
        public string PolicyNumber;
        public double PurchaseBasis;
        public double InterestRateOverride;
        public string CalcMethod;
    }


    [Serializable]
    public class ValueRetrieveGWResponse : BaseResponse
    {

        public double GWRiderFeeRate;  // PR defined periodic fee rate.   
        public double GWRiderMERate;   // Mortality and expense unit value factor.  

    }


    [Serializable]
    public class ValueRetrieveResponse : BaseResponse
    {
        public double ValuePerUnit; // This will become OutvaluePerUnit in the LPREMAPI module, but will be named as is here when using the HTTP method of access.  
                                    // This naming principle will apply to various properties here, and will be documented.  
        public double Premium;
        public double DirectAnnualPremium; 
        public double DirectSemiAnnualPremium;
        public double DirectQuarterlyPremium;
        public double DirectMonthlyPremium;
        public double DirectNinethlyPremium;
        public double DirectTenthlyPremium;
        public double Direct26PayPremium;
        public double Direct52PayPremium;
        public double Direct13thlyPremium;
        public double DirectWeeklyPremium;
        public double DirectBiWeeklyPremium;
        public double DirectAnnualPolicyFee;
        public int NextPremiumDate;
        public int PaidUpDate;
        public int ExpirationDate;
        public int ExtendedTermYears;
        public int ExtendedTermDays;
        public int ExtendedTermExpirationDate;

    }

    [Serializable]
    public class ValueRetrieveRequest : BaseRequest
    {
        public string ValueWanted;   // 'PR', for example. 
        public int EffectiveDate;
        public string CoverageID;
        public string SuppCoverageID;
        public int DateOfBirth;
        public int IssueAge;
        public int CurrentAge;
        public string Gender;
        public string Uwcls;
        public string Table;
        public double PercentRating;
        public int PercentRatingDur;
        public double FlatExtra;
        public int FlatExtraDur;
        public int SecondDateOfBirth;
        public int SecondIssueAge;
        public int SecondCurrentAge;
        public string SecondGender;
        public string SecondUwcls;
        public string SecondTable;
        public double SecondPercentRating;
        public int SecondPercentRatingDur;
        public double SecondFlatExtra;
        public int SecondFlatExtraDur;
        public int BillingMode;
        public string BillingForm; 
        public int IssueDate;
        public int PaidToDate;
        public int Duration;
        public double FaceUnitsOrAmount;
        public string FaceType;
        public double LoanOutstanding;
        public int AuxiliaryIssueAge;
        public double Premium;
        public double CashValueRequested;
        public double DeathBenefitRequested;
        public double SurrenderChargeRequested;
        public double DividendRequested;
        public double DividendAdjustmentRequested;
        public double PaidUpAdditionsRequested;
        public double ReducedPaidUpRequested;
        public int RateUpAge;
        public int SecondRateUpAge;
        public double ValuePerUnit;
        public string ProcessTypeIndicator;
        public string CompanyCode;
        public string PolicyNumber;
        public int BenefitSeq;
        public string BenefitType;
        public int LastResetDate;
        public int ExpirationDate; 
    }

    [Serializable]
    public class ValueRetrieveGWRequest : BaseRequest
    {
        public string CompanyCode;   
        public string PolicyNumber;
        public int EffectiveDate;  
    }

    //20140611-015-01   SAP   Added fields for new ENS API
    [Serializable]
    public class EnsRequest : BaseRequest
    {
        public string CompanyCode;
        public string PolicyNumber;
        public string AgentNumber;
        public string ClaimNumber;
        public string FunctionFlag;
        public int EventDate;
        public string EventCode;
        public int EventSequence;
        public string UpdateLine1;
        public string UpdateLine2;
        public string UpdateLine3;
        public string UpdateCmpOperID;
        public int UpdateCmpDate;
    }

    [Serializable]
    public class EnsResponse : BaseResponse
    {
        public int NumOfRecords;
        public int[] EventDate;
        public string[] EventCode;
        public string[] Description;
        public int[] EventSequence;
        public string[] Line1;
        public string[] Line2;
        public string[] Line3;
        public string[] OrgOperID;
        public int[] OrgDate;
        public string[] CmpOperID;
        public int[] CmpDate;
    }
}
