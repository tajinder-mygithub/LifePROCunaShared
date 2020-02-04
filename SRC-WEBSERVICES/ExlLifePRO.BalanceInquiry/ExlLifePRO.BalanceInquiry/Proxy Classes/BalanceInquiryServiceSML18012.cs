﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System.Data;



[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
[System.ServiceModel.ServiceContractAttribute(Namespace="http://pdma.net", ConfigurationName="IBalanceInquiryService")]
public interface IBalanceInquiryService
{
    
    // CODEGEN: Parameter 'RunInquiryResult' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlElementAttribute'.
    [System.ServiceModel.OperationContractAttribute(Action="http://pdma.net/IBalanceInquiryService/RunInquiry", ReplyAction="http://pdma.net/IBalanceInquiryService/RunInquiryResponse")]
    [System.ServiceModel.XmlSerializerFormatAttribute()]
    [System.ServiceModel.ServiceKnownTypeAttribute(typeof(BaseResponse))]
    [System.ServiceModel.ServiceKnownTypeAttribute(typeof(BaseRequest))]
    RunInquiryResponse RunInquiry(RunInquiryRequest request);
    
    [System.ServiceModel.OperationContractAttribute(Action="http://pdma.net/IBalanceInquiryService/RunInquiry", ReplyAction="http://pdma.net/IBalanceInquiryService/RunInquiryResponse")]
    System.Threading.Tasks.Task<RunInquiryResponse> RunInquiryAsync(RunInquiryRequest request);
}

/// <remarks/>
[System.CodeDom.Compiler.GeneratedCodeAttribute("svcutil", "4.0.30319.33440")]
[System.SerializableAttribute()]
[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.ComponentModel.DesignerCategoryAttribute("code")]
[System.Xml.Serialization.XmlTypeAttribute(Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
public partial class BalanceInquiryRequest : BaseRequest
{
    
    private string companyCodeField;
    
    private int effectiveDateField;
    
    private bool overrideFutureDateEditsField;
    
    private string policyNumberField;
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=0)]
    public string CompanyCode
    {
        get
        {
            return this.companyCodeField;
        }
        set
        {
            this.companyCodeField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=1)]
    public int EffectiveDate
    {
        get
        {
            return this.effectiveDateField;
        }
        set
        {
            this.effectiveDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=2)]
    public bool OverrideFutureDateEdits
    {
        get
        {
            return this.overrideFutureDateEditsField;
        }
        set
        {
            this.overrideFutureDateEditsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=3)]
    public string PolicyNumber
    {
        get
        {
            return this.policyNumberField;
        }
        set
        {
            this.policyNumberField = value;
        }
    }
}

/// <remarks/>
[System.Xml.Serialization.XmlIncludeAttribute(typeof(BalanceInquiryRequest))]
[System.CodeDom.Compiler.GeneratedCodeAttribute("svcutil", "4.0.30319.33440")]
[System.SerializableAttribute()]
[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.ComponentModel.DesignerCategoryAttribute("code")]
[System.Xml.Serialization.XmlTypeAttribute(Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
public partial class BaseRequest
{
    
    private string userTypeField;
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=0)]
    public string UserType
    {
        get
        {
            return this.userTypeField;
        }
        set
        {
            this.userTypeField = value;
        }
    }
}

/// <remarks/>
[System.Xml.Serialization.XmlIncludeAttribute(typeof(BalanceInquiryResponse))]
[System.CodeDom.Compiler.GeneratedCodeAttribute("svcutil", "4.0.30319.33440")]
[System.SerializableAttribute()]
[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.ComponentModel.DesignerCategoryAttribute("code")]
[System.Xml.Serialization.XmlTypeAttribute(Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
public partial class BaseResponse
{
    
    private string errorMessageField;
    
    private int returnCodeField;
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=0)]
    public string ErrorMessage
    {
        get
        {
            return this.errorMessageField;
        }
        set
        {
            this.errorMessageField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=1)]
    public int ReturnCode
    {
        get
        {
            return this.returnCodeField;
        }
        set
        {
            this.returnCodeField = value;
        }
    }
}

/// <remarks/>
[System.CodeDom.Compiler.GeneratedCodeAttribute("svcutil", "4.0.30319.33440")]
[System.SerializableAttribute()]
[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.ComponentModel.DesignerCategoryAttribute("code")]
[System.Xml.Serialization.XmlTypeAttribute(Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
public partial class BalanceInquiryResponse : BaseResponse
{
    
    private string activeRequestsField;
    
    private System.Data.DataTable bucketLevelValuesField;
    
    private double currentEarningsAmountToDateField;
    
    private double currentEarningsRateField;
    
    private double[] fundBalanceField;
    
    private string[] fundIDField;
    
    private string[] fundTypeField;
    
    private int gWBenefitPhaseStartDateField;
    
    private string gWJointBenefitAvailableField;
    
    private int gWLastPremiumDateField;
    
    private int gWLastResetDateField;
    
    private double gWLifetimeJointAnnualBenefitField;
    
    private double gWLifetimeJointBenefitAvailableField;
    
    private double gWLifetimeJointCarryoverAmountField;
    
    private int gWLifetimeJointEarliestIncomeDateField;
    
    private double gWLifetimeJointEligiblePremiumsField;
    
    private double gWLifetimeJointExcessRMDField;
    
    private double gWLifetimeJointGMWBPercentageField;
    
    private int gWLifetimeJointLastWithdrawalDateField;
    
    private double gWLifetimeJointWithdrawalsField;
    
    private double gWLifetimeSingleAnnualBenefitField;
    
    private double gWLifetimeSingleBenefitAvailableField;
    
    private double gWLifetimeSingleCarryoverAmountField;
    
    private int gWLifetimeSingleEarliestIncomeDateField;
    
    private double gWLifetimeSingleEligiblePremiumsField;
    
    private double gWLifetimeSingleExcessRMDField;
    
    private double gWLifetimeSingleGMWBPercentageField;
    
    private int gWLifetimeSingleLastWithdrawalDateField;
    
    private double gWLifetimeSingleWithdrawalsField;
    
    private double gWRemainingWithdrawalBenefitField;
    
    private string gWResetStatusField;
    
    private string gWSingleBenefitAvailableField;
    
    private double gWWithdrawalAnnualBenefitField;
    
    private string gWWithdrawalBenefitAvailableField;
    
    private int gWWithdrawalBenefitLastWithdrawalDateField;
    
    private double gWWithdrawalBenefitWithdrawalsField;
    
    private double gWWithdrawalEligiblePremiumsField;
    
    private double gWWithdrawalExcessRMDField;
    
    private double gWWithdrawalGMWBPercentageField;
    
    private double grossDepositsField;
    
    private double grossWithdrawalsField;
    
    private double guaranteedEarningsRateField;
    
    private double indexEarningsAmountToDateField;
    
    private double indexEarningsRateField;
    
    private int lastValuationDateField;
    
    private double loanBalanceField;
    
    private string[] longDescriptionField;
    
    private string[] moneySourceField;
    
    private string multipleLoansField;
    
    private System.Data.DataTable pointToPointValuesField;
    
    private double preTefraCostBasisField;
    
    private int processToDateField;
    
    private int quoteDateField;
    
    private int rowCountField;
    
    private string[] shortDescriptionField;
    
    private double totalCostBasisField;
    
    private double totalFundBalanceField;
    
    private double[] unitValueField;
    
    private int[] unitValueDateField;
    
    private double[] unitsField;
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=0)]
    public string ActiveRequests
    {
        get
        {
            return this.activeRequestsField;
        }
        set
        {
            this.activeRequestsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=1)]
    public System.Data.DataTable BucketLevelValues
    {
        get
        {
            return this.bucketLevelValuesField;
        }
        set
        {
            this.bucketLevelValuesField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=2)]
    public double CurrentEarningsAmountToDate
    {
        get
        {
            return this.currentEarningsAmountToDateField;
        }
        set
        {
            this.currentEarningsAmountToDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=3)]
    public double CurrentEarningsRate
    {
        get
        {
            return this.currentEarningsRateField;
        }
        set
        {
            this.currentEarningsRateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=4)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays", IsNullable=false)]
    public double[] FundBalance
    {
        get
        {
            return this.fundBalanceField;
        }
        set
        {
            this.fundBalanceField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=5)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays")]
    public string[] FundID
    {
        get
        {
            return this.fundIDField;
        }
        set
        {
            this.fundIDField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=6)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays")]
    public string[] FundType
    {
        get
        {
            return this.fundTypeField;
        }
        set
        {
            this.fundTypeField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=7)]
    public int GWBenefitPhaseStartDate
    {
        get
        {
            return this.gWBenefitPhaseStartDateField;
        }
        set
        {
            this.gWBenefitPhaseStartDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=8)]
    public string GWJointBenefitAvailable
    {
        get
        {
            return this.gWJointBenefitAvailableField;
        }
        set
        {
            this.gWJointBenefitAvailableField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=9)]
    public int GWLastPremiumDate
    {
        get
        {
            return this.gWLastPremiumDateField;
        }
        set
        {
            this.gWLastPremiumDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=10)]
    public int GWLastResetDate
    {
        get
        {
            return this.gWLastResetDateField;
        }
        set
        {
            this.gWLastResetDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=11)]
    public double GWLifetimeJointAnnualBenefit
    {
        get
        {
            return this.gWLifetimeJointAnnualBenefitField;
        }
        set
        {
            this.gWLifetimeJointAnnualBenefitField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=12)]
    public double GWLifetimeJointBenefitAvailable
    {
        get
        {
            return this.gWLifetimeJointBenefitAvailableField;
        }
        set
        {
            this.gWLifetimeJointBenefitAvailableField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=13)]
    public double GWLifetimeJointCarryoverAmount
    {
        get
        {
            return this.gWLifetimeJointCarryoverAmountField;
        }
        set
        {
            this.gWLifetimeJointCarryoverAmountField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=14)]
    public int GWLifetimeJointEarliestIncomeDate
    {
        get
        {
            return this.gWLifetimeJointEarliestIncomeDateField;
        }
        set
        {
            this.gWLifetimeJointEarliestIncomeDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=15)]
    public double GWLifetimeJointEligiblePremiums
    {
        get
        {
            return this.gWLifetimeJointEligiblePremiumsField;
        }
        set
        {
            this.gWLifetimeJointEligiblePremiumsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=16)]
    public double GWLifetimeJointExcessRMD
    {
        get
        {
            return this.gWLifetimeJointExcessRMDField;
        }
        set
        {
            this.gWLifetimeJointExcessRMDField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=17)]
    public double GWLifetimeJointGMWBPercentage
    {
        get
        {
            return this.gWLifetimeJointGMWBPercentageField;
        }
        set
        {
            this.gWLifetimeJointGMWBPercentageField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=18)]
    public int GWLifetimeJointLastWithdrawalDate
    {
        get
        {
            return this.gWLifetimeJointLastWithdrawalDateField;
        }
        set
        {
            this.gWLifetimeJointLastWithdrawalDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=19)]
    public double GWLifetimeJointWithdrawals
    {
        get
        {
            return this.gWLifetimeJointWithdrawalsField;
        }
        set
        {
            this.gWLifetimeJointWithdrawalsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=20)]
    public double GWLifetimeSingleAnnualBenefit
    {
        get
        {
            return this.gWLifetimeSingleAnnualBenefitField;
        }
        set
        {
            this.gWLifetimeSingleAnnualBenefitField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=21)]
    public double GWLifetimeSingleBenefitAvailable
    {
        get
        {
            return this.gWLifetimeSingleBenefitAvailableField;
        }
        set
        {
            this.gWLifetimeSingleBenefitAvailableField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=22)]
    public double GWLifetimeSingleCarryoverAmount
    {
        get
        {
            return this.gWLifetimeSingleCarryoverAmountField;
        }
        set
        {
            this.gWLifetimeSingleCarryoverAmountField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=23)]
    public int GWLifetimeSingleEarliestIncomeDate
    {
        get
        {
            return this.gWLifetimeSingleEarliestIncomeDateField;
        }
        set
        {
            this.gWLifetimeSingleEarliestIncomeDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=24)]
    public double GWLifetimeSingleEligiblePremiums
    {
        get
        {
            return this.gWLifetimeSingleEligiblePremiumsField;
        }
        set
        {
            this.gWLifetimeSingleEligiblePremiumsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=25)]
    public double GWLifetimeSingleExcessRMD
    {
        get
        {
            return this.gWLifetimeSingleExcessRMDField;
        }
        set
        {
            this.gWLifetimeSingleExcessRMDField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=26)]
    public double GWLifetimeSingleGMWBPercentage
    {
        get
        {
            return this.gWLifetimeSingleGMWBPercentageField;
        }
        set
        {
            this.gWLifetimeSingleGMWBPercentageField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=27)]
    public int GWLifetimeSingleLastWithdrawalDate
    {
        get
        {
            return this.gWLifetimeSingleLastWithdrawalDateField;
        }
        set
        {
            this.gWLifetimeSingleLastWithdrawalDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=28)]
    public double GWLifetimeSingleWithdrawals
    {
        get
        {
            return this.gWLifetimeSingleWithdrawalsField;
        }
        set
        {
            this.gWLifetimeSingleWithdrawalsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=29)]
    public double GWRemainingWithdrawalBenefit
    {
        get
        {
            return this.gWRemainingWithdrawalBenefitField;
        }
        set
        {
            this.gWRemainingWithdrawalBenefitField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=30)]
    public string GWResetStatus
    {
        get
        {
            return this.gWResetStatusField;
        }
        set
        {
            this.gWResetStatusField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=31)]
    public string GWSingleBenefitAvailable
    {
        get
        {
            return this.gWSingleBenefitAvailableField;
        }
        set
        {
            this.gWSingleBenefitAvailableField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=32)]
    public double GWWithdrawalAnnualBenefit
    {
        get
        {
            return this.gWWithdrawalAnnualBenefitField;
        }
        set
        {
            this.gWWithdrawalAnnualBenefitField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=33)]
    public string GWWithdrawalBenefitAvailable
    {
        get
        {
            return this.gWWithdrawalBenefitAvailableField;
        }
        set
        {
            this.gWWithdrawalBenefitAvailableField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=34)]
    public int GWWithdrawalBenefitLastWithdrawalDate
    {
        get
        {
            return this.gWWithdrawalBenefitLastWithdrawalDateField;
        }
        set
        {
            this.gWWithdrawalBenefitLastWithdrawalDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=35)]
    public double GWWithdrawalBenefitWithdrawals
    {
        get
        {
            return this.gWWithdrawalBenefitWithdrawalsField;
        }
        set
        {
            this.gWWithdrawalBenefitWithdrawalsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=36)]
    public double GWWithdrawalEligiblePremiums
    {
        get
        {
            return this.gWWithdrawalEligiblePremiumsField;
        }
        set
        {
            this.gWWithdrawalEligiblePremiumsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=37)]
    public double GWWithdrawalExcessRMD
    {
        get
        {
            return this.gWWithdrawalExcessRMDField;
        }
        set
        {
            this.gWWithdrawalExcessRMDField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=38)]
    public double GWWithdrawalGMWBPercentage
    {
        get
        {
            return this.gWWithdrawalGMWBPercentageField;
        }
        set
        {
            this.gWWithdrawalGMWBPercentageField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=39)]
    public double GrossDeposits
    {
        get
        {
            return this.grossDepositsField;
        }
        set
        {
            this.grossDepositsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=40)]
    public double GrossWithdrawals
    {
        get
        {
            return this.grossWithdrawalsField;
        }
        set
        {
            this.grossWithdrawalsField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=41)]
    public double GuaranteedEarningsRate
    {
        get
        {
            return this.guaranteedEarningsRateField;
        }
        set
        {
            this.guaranteedEarningsRateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=42)]
    public double IndexEarningsAmountToDate
    {
        get
        {
            return this.indexEarningsAmountToDateField;
        }
        set
        {
            this.indexEarningsAmountToDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=43)]
    public double IndexEarningsRate
    {
        get
        {
            return this.indexEarningsRateField;
        }
        set
        {
            this.indexEarningsRateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=44)]
    public int LastValuationDate
    {
        get
        {
            return this.lastValuationDateField;
        }
        set
        {
            this.lastValuationDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=45)]
    public double LoanBalance
    {
        get
        {
            return this.loanBalanceField;
        }
        set
        {
            this.loanBalanceField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=46)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays")]
    public string[] LongDescription
    {
        get
        {
            return this.longDescriptionField;
        }
        set
        {
            this.longDescriptionField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=47)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays")]
    public string[] MoneySource
    {
        get
        {
            return this.moneySourceField;
        }
        set
        {
            this.moneySourceField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=48)]
    public string MultipleLoans
    {
        get
        {
            return this.multipleLoansField;
        }
        set
        {
            this.multipleLoansField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true, Order=49)]
    public System.Data.DataTable PointToPointValues
    {
        get
        {
            return this.pointToPointValuesField;
        }
        set
        {
            this.pointToPointValuesField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=50)]
    public double PreTefraCostBasis
    {
        get
        {
            return this.preTefraCostBasisField;
        }
        set
        {
            this.preTefraCostBasisField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=51)]
    public int ProcessToDate
    {
        get
        {
            return this.processToDateField;
        }
        set
        {
            this.processToDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=52)]
    public int QuoteDate
    {
        get
        {
            return this.quoteDateField;
        }
        set
        {
            this.quoteDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=53)]
    public int RowCount
    {
        get
        {
            return this.rowCountField;
        }
        set
        {
            this.rowCountField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=54)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays")]
    public string[] ShortDescription
    {
        get
        {
            return this.shortDescriptionField;
        }
        set
        {
            this.shortDescriptionField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=55)]
    public double TotalCostBasis
    {
        get
        {
            return this.totalCostBasisField;
        }
        set
        {
            this.totalCostBasisField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlElementAttribute(Order=56)]
    public double TotalFundBalance
    {
        get
        {
            return this.totalFundBalanceField;
        }
        set
        {
            this.totalFundBalanceField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=57)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays", IsNullable=false)]
    public double[] UnitValue
    {
        get
        {
            return this.unitValueField;
        }
        set
        {
            this.unitValueField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=58)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays", IsNullable=false)]
    public int[] UnitValueDate
    {
        get
        {
            return this.unitValueDateField;
        }
        set
        {
            this.unitValueDateField = value;
        }
    }
    
    /// <remarks/>
    [System.Xml.Serialization.XmlArrayAttribute(IsNullable=true, Order=59)]
    [System.Xml.Serialization.XmlArrayItemAttribute(Namespace="http://schemas.microsoft.com/2003/10/Serialization/Arrays", IsNullable=false)]
    public double[] Units
    {
        get
        {
            return this.unitsField;
        }
        set
        {
            this.unitsField = value;
        }
    }
}

[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
[System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
[System.ServiceModel.MessageContractAttribute(WrapperName="RunInquiry", WrapperNamespace="http://pdma.net", IsWrapped=true)]
public partial class RunInquiryRequest
{
    
    [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://pdma.net", Order=0)]
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true)]
    public BalanceInquiryRequest inProps;
    
    public RunInquiryRequest()
    {
    }
    
    public RunInquiryRequest(BalanceInquiryRequest inProps)
    {
        this.inProps = inProps;
    }
}

[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
[System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
[System.ServiceModel.MessageContractAttribute(WrapperName="RunInquiryResponse", WrapperNamespace="http://pdma.net", IsWrapped=true)]
public partial class RunInquiryResponse
{
    
    [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://pdma.net", Order=0)]
    [System.Xml.Serialization.XmlElementAttribute(IsNullable=true)]
    public BalanceInquiryResponse RunInquiryResult;
    
    public RunInquiryResponse()
    {
    }
    
    public RunInquiryResponse(BalanceInquiryResponse RunInquiryResult)
    {
        this.RunInquiryResult = RunInquiryResult;
    }
}

[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
public interface IBalanceInquiryServiceChannel : IBalanceInquiryService, System.ServiceModel.IClientChannel
{
}

[System.Diagnostics.DebuggerStepThroughAttribute()]
[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
public partial class BalanceInquiryServiceClient : System.ServiceModel.ClientBase<IBalanceInquiryService>, IBalanceInquiryService
{
    
    public BalanceInquiryServiceClient()
    {
    }
    
    public BalanceInquiryServiceClient(string endpointConfigurationName) : 
            base(endpointConfigurationName)
    {
    }
    
    public BalanceInquiryServiceClient(string endpointConfigurationName, string remoteAddress) : 
            base(endpointConfigurationName, remoteAddress)
    {
    }
    
    public BalanceInquiryServiceClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
            base(endpointConfigurationName, remoteAddress)
    {
    }
    
    public BalanceInquiryServiceClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
            base(binding, remoteAddress)
    {
    }
    
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    RunInquiryResponse IBalanceInquiryService.RunInquiry(RunInquiryRequest request)
    {
        return base.Channel.RunInquiry(request);
    }
    
    public BalanceInquiryResponse RunInquiry(BalanceInquiryRequest inProps)
    {
        RunInquiryRequest inValue = new RunInquiryRequest();
        inValue.inProps = inProps;
        RunInquiryResponse retVal = ((IBalanceInquiryService)(this)).RunInquiry(inValue);
        return retVal.RunInquiryResult;
    }
    
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    System.Threading.Tasks.Task<RunInquiryResponse> IBalanceInquiryService.RunInquiryAsync(RunInquiryRequest request)
    {
        return base.Channel.RunInquiryAsync(request);
    }
    
    public System.Threading.Tasks.Task<RunInquiryResponse> RunInquiryAsync(BalanceInquiryRequest inProps)
    {
        RunInquiryRequest inValue = new RunInquiryRequest();
        inValue.inProps = inProps;
        return ((IBalanceInquiryService)(this)).RunInquiryAsync(inValue);
    }
}
