﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PDMA.LifePro
{
    using System.Runtime.Serialization;
    
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="BaseRequest", Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
    [System.Runtime.Serialization.KnownTypeAttribute(typeof(PDMA.LifePro.BalanceInquiryRequest))]
    public partial class BaseRequest : object, System.Runtime.Serialization.IExtensibleDataObject
    {
        
        private System.Runtime.Serialization.ExtensionDataObject extensionDataField;
        
        private string UserTypeField;
        
        public System.Runtime.Serialization.ExtensionDataObject ExtensionData
        {
            get
            {
                return this.extensionDataField;
            }
            set
            {
                this.extensionDataField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string UserType
        {
            get
            {
                return this.UserTypeField;
            }
            set
            {
                this.UserTypeField = value;
            }
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="BalanceInquiryRequest", Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
    public partial class BalanceInquiryRequest : PDMA.LifePro.BaseRequest
    {
        
        private string CompanyCodeField;
        
        private int EffectiveDateField;
        
        private string PolicyNumberField;
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string CompanyCode
        {
            get
            {
                return this.CompanyCodeField;
            }
            set
            {
                this.CompanyCodeField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int EffectiveDate
        {
            get
            {
                return this.EffectiveDateField;
            }
            set
            {
                this.EffectiveDateField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string PolicyNumber
        {
            get
            {
                return this.PolicyNumberField;
            }
            set
            {
                this.PolicyNumberField = value;
            }
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="BaseResponse", Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
    [System.Runtime.Serialization.KnownTypeAttribute(typeof(PDMA.LifePro.BalanceInquiryResponse))]
    public partial class BaseResponse : object, System.Runtime.Serialization.IExtensibleDataObject
    {
        
        private System.Runtime.Serialization.ExtensionDataObject extensionDataField;
        
        private string ErrorMessageField;
        
        private int ReturnCodeField;
        
        public System.Runtime.Serialization.ExtensionDataObject ExtensionData
        {
            get
            {
                return this.extensionDataField;
            }
            set
            {
                this.extensionDataField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string ErrorMessage
        {
            get
            {
                return this.ErrorMessageField;
            }
            set
            {
                this.ErrorMessageField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int ReturnCode
        {
            get
            {
                return this.ReturnCodeField;
            }
            set
            {
                this.ReturnCodeField = value;
            }
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="BalanceInquiryResponse", Namespace="http://schemas.datacontract.org/2004/07/PDMA.LifePro")]
    public partial class BalanceInquiryResponse : PDMA.LifePro.BaseResponse
    {
        
        private string ActiveRequestsField;
        
        private double[] FundBalanceField;
        
        private string[] FundIDField;
        
        private string[] FundTypeField;
        
        private double GrossDepositsField;
        
        private double GrossWithdrawalsField;
        
        private int LastValuationDateField;
        
        private double LoanBalanceField;
        
        private string[] LongDescriptionField;
        
        private string[] MoneySourceField;
        
        private string MultipleLoansField;
        
        private int ProcessToDateField;
        
        private int QuoteDateField;
        
        private int RowCountField;
        
        private string[] ShortDescriptionField;
        
        private double TotalFundBalanceField;
        
        private double[] UnitValueField;
        
        private int[] UnitValueDateField;
        
        private double[] UnitsField;
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string ActiveRequests
        {
            get
            {
                return this.ActiveRequestsField;
            }
            set
            {
                this.ActiveRequestsField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double[] FundBalance
        {
            get
            {
                return this.FundBalanceField;
            }
            set
            {
                this.FundBalanceField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string[] FundID
        {
            get
            {
                return this.FundIDField;
            }
            set
            {
                this.FundIDField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string[] FundType
        {
            get
            {
                return this.FundTypeField;
            }
            set
            {
                this.FundTypeField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double GrossDeposits
        {
            get
            {
                return this.GrossDepositsField;
            }
            set
            {
                this.GrossDepositsField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double GrossWithdrawals
        {
            get
            {
                return this.GrossWithdrawalsField;
            }
            set
            {
                this.GrossWithdrawalsField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int LastValuationDate
        {
            get
            {
                return this.LastValuationDateField;
            }
            set
            {
                this.LastValuationDateField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double LoanBalance
        {
            get
            {
                return this.LoanBalanceField;
            }
            set
            {
                this.LoanBalanceField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string[] LongDescription
        {
            get
            {
                return this.LongDescriptionField;
            }
            set
            {
                this.LongDescriptionField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string[] MoneySource
        {
            get
            {
                return this.MoneySourceField;
            }
            set
            {
                this.MoneySourceField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string MultipleLoans
        {
            get
            {
                return this.MultipleLoansField;
            }
            set
            {
                this.MultipleLoansField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int ProcessToDate
        {
            get
            {
                return this.ProcessToDateField;
            }
            set
            {
                this.ProcessToDateField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int QuoteDate
        {
            get
            {
                return this.QuoteDateField;
            }
            set
            {
                this.QuoteDateField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int RowCount
        {
            get
            {
                return this.RowCountField;
            }
            set
            {
                this.RowCountField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public string[] ShortDescription
        {
            get
            {
                return this.ShortDescriptionField;
            }
            set
            {
                this.ShortDescriptionField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double TotalFundBalance
        {
            get
            {
                return this.TotalFundBalanceField;
            }
            set
            {
                this.TotalFundBalanceField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double[] UnitValue
        {
            get
            {
                return this.UnitValueField;
            }
            set
            {
                this.UnitValueField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public int[] UnitValueDate
        {
            get
            {
                return this.UnitValueDateField;
            }
            set
            {
                this.UnitValueDateField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute(IsRequired=true)]
        public double[] Units
        {
            get
            {
                return this.UnitsField;
            }
            set
            {
                this.UnitsField = value;
            }
        }
    }
}


[System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
[System.ServiceModel.ServiceContractAttribute(Namespace="http://pdma.net", ConfigurationName="IBalanceInquiryService")]
public interface IBalanceInquiryService
{
    
    [System.ServiceModel.OperationContractAttribute(Action="http://pdma.net/IBalanceInquiryService/RunInquiry", ReplyAction="http://pdma.net/IBalanceInquiryService/RunInquiryResponse")]
    PDMA.LifePro.BalanceInquiryResponse RunInquiry(PDMA.LifePro.BalanceInquiryRequest inProps);
    
    [System.ServiceModel.OperationContractAttribute(Action="http://pdma.net/IBalanceInquiryService/RunInquiry", ReplyAction="http://pdma.net/IBalanceInquiryService/RunInquiryResponse")]
    System.Threading.Tasks.Task<PDMA.LifePro.BalanceInquiryResponse> RunInquiryAsync(PDMA.LifePro.BalanceInquiryRequest inProps);
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
    
    public PDMA.LifePro.BalanceInquiryResponse RunInquiry(PDMA.LifePro.BalanceInquiryRequest inProps)
    {
        return base.Channel.RunInquiry(inProps);
    }
    
    public System.Threading.Tasks.Task<PDMA.LifePro.BalanceInquiryResponse> RunInquiryAsync(PDMA.LifePro.BalanceInquiryRequest inProps)
    {
        return base.Channel.RunInquiryAsync(inProps);
    }
}
