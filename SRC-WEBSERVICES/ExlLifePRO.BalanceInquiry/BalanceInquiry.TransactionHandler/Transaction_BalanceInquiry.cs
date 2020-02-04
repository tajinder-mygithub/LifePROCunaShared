using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using exlservice.lifepro.policyvalues.Globals;
using System.Xml.Serialization;


#region RequestBalanceInquiryDetails Class
namespace exlservice.lifepro.policyvalues.BaseTransactionHandler.RequestBalanceInquiryDetails
{

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "http://ACORD.org/Standards/Life/2", IsNullable = false)]
    public  class TXLife
    {

        private TXLifeUserAuthRequest userAuthRequestField;

        private TXLifeTXLifeRequest tXLifeRequestField;

        private string versionField;

        /// <remarks/>
        public TXLifeUserAuthRequest UserAuthRequest
        {
            get
            {
                return this.userAuthRequestField;
            }
            set
            {
                this.userAuthRequestField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequest TXLifeRequest
        {
            get
            {
                return this.tXLifeRequestField;
            }
            set
            {
                this.tXLifeRequestField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string Version
        {
            get
            {
                return this.versionField;
            }
            set
            {
                this.versionField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeUserAuthRequest
    {

        private TXLifeUserAuthRequestVendorApp vendorAppField;

        /// <remarks/>
        public TXLifeUserAuthRequestVendorApp VendorApp
        {
            get
            {
                return this.vendorAppField;
            }
            set
            {
                this.vendorAppField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeUserAuthRequestVendorApp
    {

        private string vendorNameField;

        private string appNameField;

        private string appVerField;

        /// <remarks/>
        public string VendorName
        {
            get
            {
                return this.vendorNameField;
            }
            set
            {
                this.vendorNameField = value;
            }
        }

        /// <remarks/>
        public string AppName
        {
            get
            {
                return this.appNameField;
            }
            set
            {
                this.appNameField = value;
            }
        }

        /// <remarks/>
        public string AppVer
        {
            get
            {
                return this.appVerField;
            }
            set
            {
                this.appVerField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequest
    {

        private Guid transRefGUIDField;

        private TXLifeTXLifeRequestTransType transTypeField;

        private TXLifeTXLifeRequestTransSubType transSubTypeField;

        private System.DateTime transExeDateField;

        private System.DateTime transExeTimeField;

        private TXLifeTXLifeRequestTransMode transModeField;

        private TXLifeTXLifeRequestNoResponseOK noResponseOKField;

        private TXLifeTXLifeRequestTestIndicator testIndicatorField;

        private TXLifeTXLifeRequestInquiryLevel inquiryLevelField;

        private TXLifeTXLifeRequestOLifE oLifEField;

        private string idField;

        private string primaryObjectIDField;

        /// <remarks/>
        public Guid TransRefGUID
        {
            get
            {
                return this.transRefGUIDField;
            }
            set
            {
                this.transRefGUIDField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestTransType TransType
        {
            get
            {
                return this.transTypeField;
            }
            set
            {
                this.transTypeField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestTransSubType TransSubType
        {
            get
            {
                return this.transSubTypeField;
            }
            set
            {
                this.transSubTypeField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public System.DateTime TransExeDate
        {
            get
            {
                return this.transExeDateField;
            }
            set
            {
                this.transExeDateField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType = "time")]
        public System.DateTime TransExeTime
        {
            get
            {
                return this.transExeTimeField;
            }
            set
            {
                this.transExeTimeField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestTransMode TransMode
        {
            get
            {
                return this.transModeField;
            }
            set
            {
                this.transModeField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestNoResponseOK NoResponseOK
        {
            get
            {
                return this.noResponseOKField;
            }
            set
            {
                this.noResponseOKField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestTestIndicator TestIndicator
        {
            get
            {
                return this.testIndicatorField;
            }
            set
            {
                this.testIndicatorField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestInquiryLevel InquiryLevel
        {
            get
            {
                return this.inquiryLevelField;
            }
            set
            {
                this.inquiryLevelField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestOLifE OLifE
        {
            get
            {
                return this.oLifEField;
            }
            set
            {
                this.oLifEField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string id
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string PrimaryObjectID
        {
            get
            {
                return this.primaryObjectIDField;
            }
            set
            {
                this.primaryObjectIDField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestTransType
    {

        private string tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestTransSubType
    {

        private ushort tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public ushort tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestTransMode
    {

        private byte tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public byte tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestNoResponseOK
    {

        private byte tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public byte tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestTestIndicator
    {

        private byte tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public byte tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestInquiryLevel
    {

        private byte tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public byte tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestOLifE
    {

        private TXLifeTXLifeRequestOLifEHolding holdingField;

        /// <remarks/>
        public TXLifeTXLifeRequestOLifEHolding Holding
        {
            get
            {
                return this.holdingField;
            }
            set
            {
                this.holdingField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestOLifEHolding
    {

        private TXLifeTXLifeRequestOLifEHoldingHoldingTypeCode holdingTypeCodeField;

        private TXLifeTXLifeRequestOLifEHoldingHoldingStatus holdingStatusField;

        private string carrierAdminSystemField;

        private TXLifeTXLifeRequestOLifEHoldingPolicy policyField;

        private string idField;

        /// <remarks/>
        public TXLifeTXLifeRequestOLifEHoldingHoldingTypeCode HoldingTypeCode
        {
            get
            {
                return this.holdingTypeCodeField;
            }
            set
            {
                this.holdingTypeCodeField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestOLifEHoldingHoldingStatus HoldingStatus
        {
            get
            {
                return this.holdingStatusField;
            }
            set
            {
                this.holdingStatusField = value;
            }
        }

        /// <remarks/>
        public string CarrierAdminSystem
        {
            get
            {
                return this.carrierAdminSystemField;
            }
            set
            {
                this.carrierAdminSystemField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeRequestOLifEHoldingPolicy Policy
        {
            get
            {
                return this.policyField;
            }
            set
            {
                this.policyField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string id
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestOLifEHoldingHoldingTypeCode
    {

        private string tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestOLifEHoldingHoldingStatus
    {

        private byte tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public byte tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeRequestOLifEHoldingPolicy
    {

        private string carrierCodeField;

        private string polNumberField;

        private string effDateField;

        /// <remarks/>
        public string CarrierCode
        {
            get
            {
                return this.carrierCodeField;
            }
            set
            {
                this.carrierCodeField = value;
            }
        }

        /// <remarks/>
        public string PolNumber
        {
            get
            {
                return this.polNumberField;
            }
            set
            {
                this.polNumberField = value;
            }
        }

        /// <remarks/>
     //   [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public string EffDate
        {
            get
            {
                return this.effDateField;
            }
            set
            {
                this.effDateField = value;
            }
        }
    }

}
#endregion

#region ResponseBalanceInquiryDetails Class
namespace exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails
{
    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "http://ACORD.org/Standards/Life/2", IsNullable = false)]
    public  class TXLife
    {

        private TXLifeTXLifeResponse tXLifeResponseField;

        /// <remarks/>
        public TXLifeTXLifeResponse TXLifeResponse
        {
            get
            {
                return this.tXLifeResponseField;
            }
            set
            {
                this.tXLifeResponseField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponse : BaseTransactionResponse.TXLifeTXLifeResponse
    {

        private Guid transRefGUIDField;

        private TXLifeTXLifeResponseTransType transTypeField;

        private TXLifeTXLifeResponseTransSubType transSubTypeField;

        private string transExeDateField;

        private string transExeTimeField;

        private string pendingResponseOKField;

        private string noResponseOKField;

        private TXLifeTXLifeResponseTransResult transResultField;

        private TXLifeTXLifeResponseOLifE oLifEField;

        private string primaryObjectIDField;

        /// <remarks/>
        public override Guid TransRefGUID
        {
            get
            {
                return this.transRefGUIDField;
            }
            set
            {
                this.transRefGUIDField = value;
            }
        }

        /// <remarks/>
        public override TXLifeTXLifeResponseTransType TransType
        {
            get
            {
                return this.transTypeField;
            }
            set
            {
                this.transTypeField = value;
            }
        }

        /// <remarks/>
        public override TXLifeTXLifeResponseTransSubType TransSubType
        {
            get
            {
                return this.transSubTypeField;
            }
            set
            {
                this.transSubTypeField = value;
            }
        }

        /// <remarks/>
        //  [System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        public override string TransExeDate
        {
            get
            {
                return this.transExeDateField;
            }
            set
            {
                this.transExeDateField = value;
            }
        }

        /// <remarks/>
        //    [System.Xml.Serialization.XmlElementAttribute(DataType = "time")]
        public override string TransExeTime
        {
            get
            {
                return this.transExeTimeField;
            }
            set
            {
                this.transExeTimeField = value;
            }
        }

        /// <remarks/>
        public string PendingResponseOK
        {
            get
            {
                return this.pendingResponseOKField;
            }
            set
            {
                this.pendingResponseOKField = value;
            }
        }

        /// <remarks/>
        public string NoResponseOK
        {
            get
            {
                return this.noResponseOKField;
            }
            set
            {
                this.noResponseOKField = value;
            }
        }

        /// <remarks/>
        public override TXLifeTXLifeResponseTransResult TransResult
        {
            get
            {
                return this.transResultField;
            }
            set
            {
                this.transResultField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifE OLifE
        {
            get
            {
                return this.oLifEField;
            }
            set
            {
                this.oLifEField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string PrimaryObjectID
        {
            get
            {
                return this.primaryObjectIDField;
            }
            set
            {
                this.primaryObjectIDField = value;
            }
        }
    }

    /// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransType
    //{

    //    private byte tcField;

    //    private string valueField;

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlAttributeAttribute()]
    //    public byte tc
    //    {
    //        get
    //        {
    //            return this.tcField;
    //        }
    //        set
    //        {
    //            this.tcField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlTextAttribute()]
    //    public string Value
    //    {
    //        get
    //        {
    //            return this.valueField;
    //        }
    //        set
    //        {
    //            this.valueField = value;
    //        }
    //    }
    //}

    /// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransSubType
    //{

    //    private ushort tcField;

    //    private string valueField;

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlAttributeAttribute()]
    //    public ushort tc
    //    {
    //        get
    //        {
    //            return this.tcField;
    //        }
    //        set
    //        {
    //            this.tcField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlTextAttribute()]
    //    public string Value
    //    {
    //        get
    //        {
    //            return this.valueField;
    //        }
    //        set
    //        {
    //            this.valueField = value;
    //        }
    //    }
    //}

    /// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransResult
    //{

    //    private TXLifeTXLifeResponseTransResultResultCode resultCodeField;

    //    private TXLifeTXLifeResponseTransResultResultInfo resultInfoField;

    //    /// <remarks/>
    //    public TXLifeTXLifeResponseTransResultResultCode ResultCode
    //    {
    //        get
    //        {
    //            return this.resultCodeField;
    //        }
    //        set
    //        {
    //            this.resultCodeField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    public TXLifeTXLifeResponseTransResultResultInfo ResultInfo
    //    {
    //        get
    //        {
    //            return this.resultInfoField;
    //        }
    //        set
    //        {
    //            this.resultInfoField = value;
    //        }
    //    }
    //}

    ///// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransResultResultCode
    //{

    //    private byte tcField;

    //    private string valueField;

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlAttributeAttribute()]
    //    public byte tc
    //    {
    //        get
    //        {
    //            return this.tcField;
    //        }
    //        set
    //        {
    //            this.tcField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlTextAttribute()]
    //    public string Value
    //    {
    //        get
    //        {
    //            return this.valueField;
    //        }
    //        set
    //        {
    //            this.valueField = value;
    //        }
    //    }
    //}

    ///// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransResultResultInfo
    //{

    //    private TXLifeTXLifeResponseTransResultResultInfoResultInfoCode resultInfoCodeField;

    //    private string resultInfoSysMessageCodeField;

    //    private string resultInfoDescField;

    //    /// <remarks/>
    //    public TXLifeTXLifeResponseTransResultResultInfoResultInfoCode ResultInfoCode
    //    {
    //        get
    //        {
    //            return this.resultInfoCodeField;
    //        }
    //        set
    //        {
    //            this.resultInfoCodeField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    public string ResultInfoSysMessageCode
    //    {
    //        get
    //        {
    //            return this.resultInfoSysMessageCodeField;
    //        }
    //        set
    //        {
    //            this.resultInfoSysMessageCodeField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    public string ResultInfoDesc
    //    {
    //        get
    //        {
    //            return this.resultInfoDescField;
    //        }
    //        set
    //        {
    //            this.resultInfoDescField = value;
    //        }
    //    }
    //}

    /// <remarks/>
    //[System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    //public partial class TXLifeTXLifeResponseTransResultResultInfoResultInfoCode
    //{

    //    private byte tcField;

    //    private string valueField;

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlAttributeAttribute()]
    //    public byte tc
    //    {
    //        get
    //        {
    //            return this.tcField;
    //        }
    //        set
    //        {
    //            this.tcField = value;
    //        }
    //    }

    //    /// <remarks/>
    //    [System.Xml.Serialization.XmlTextAttribute()]
    //    public string Value
    //    {
    //        get
    //        {
    //            return this.valueField;
    //        }
    //        set
    //        {
    //            this.valueField = value;
    //        }
    //    }
    //}

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifE
    {

        private TXLifeTXLifeResponseOLifEHolding holdingField;

        private TXLifeTXLifeResponseOLifEOLifEExtension oLifEExtensionField;

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHolding Holding
        {
            get
            {
                return this.holdingField;
            }
            set
            {
                this.holdingField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEOLifEExtension OLifEExtension
        {
            get
            {
                return this.oLifEExtensionField;
            }
            set
            {
                this.oLifEExtensionField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHolding
    {

        private TXLifeTXLifeResponseOLifEHoldingHoldingTypeCode holdingTypeCodeField;

        private TXLifeTXLifeResponseOLifEHoldingHoldingStatus holdingStatusField;

        private string carrierAdminSystemField;

        private TXLifeTXLifeResponseOLifEHoldingPolicy policyField;

        private TXLifeTXLifeResponseOLifEHoldingLoan loanField;

        private string idField;

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHoldingHoldingTypeCode HoldingTypeCode
        {
            get
            {
                return this.holdingTypeCodeField;
            }
            set
            {
                this.holdingTypeCodeField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHoldingHoldingStatus HoldingStatus
        {
            get
            {
                return this.holdingStatusField;
            }
            set
            {
                this.holdingStatusField = value;
            }
        }

        /// <remarks/>
        public string CarrierAdminSystem
        {
            get
            {
                return this.carrierAdminSystemField;
            }
            set
            {
                this.carrierAdminSystemField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHoldingPolicy Policy
        {
            get
            {
                return this.policyField;
            }
            set
            {
                this.policyField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHoldingLoan Loan
        {
            get
            {
                return this.loanField;
            }
            set
            {
                this.loanField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string id
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHoldingHoldingTypeCode
    {

        private string tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHoldingHoldingStatus
    {

        private string tcField;

        private string valueField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string tc
        {
            get
            {
                return this.tcField;
            }
            set
            {
                this.tcField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlTextAttribute()]
        public string Value
        {
            get
            {
                return this.valueField;
            }
            set
            {
                this.valueField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHoldingPolicy
    {

        private string carrierCodeField;

        private string polNumberField;

        private string effDateField;

        private string lastAnniversaryDateField;

        private string lastFinActivityDateField;

        private TXLifeTXLifeResponseOLifEHoldingPolicyLife lifeField;

        private string carrierPartyIDField;

        /// <remarks/>
        public string CarrierCode
        {
            get
            {
                return this.carrierCodeField;
            }
            set
            {
                this.carrierCodeField = value;
            }
        }

        /// <remarks/>
        public string PolNumber
        {
            get
            {
                return this.polNumberField;
            }
            set
            {
                this.polNumberField = value;
            }
        }

        /// <remarks/>
        public string EffDate
        {
            get
            {
                return this.effDateField;
            }
            set
            {
                this.effDateField = value;
            }
        }

        /// <remarks/>
        //[System.Xml.Serialization.XmlElementAttribute(DataType = "date")]
        //[System.Xml.Serialization.XmlTextAttribute()]
        public string LastAnniversaryDate
        {
            get
            {
                return this.lastAnniversaryDateField;
            }
            set
            {
                this.lastAnniversaryDateField = value;
            }
        }

        /// <remarks/>
        public string LastFinActivityDate
        {
            get
            {
                return this.lastFinActivityDateField;
            }
            set
            {
                this.lastFinActivityDateField = value;
            }
        }

        /// <remarks/>
        public TXLifeTXLifeResponseOLifEHoldingPolicyLife Life
        {
            get
            {
                return this.lifeField;
            }
            set
            {
                this.lifeField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string CarrierPartyID
        {
            get
            {
                return this.carrierPartyIDField;
            }
            set
            {
                this.carrierPartyIDField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHoldingPolicyLife
    {

        private double cashValueAmtField;

        private string divOnDepositAmtField;

        /// <remarks/>
        public double CashValueAmt
        {
            get
            {
                return this.cashValueAmtField;
            }
            set
            {
                this.cashValueAmtField = value;
            }
        }

        /// <remarks/>
        public string DivOnDepositAmt
        {
            get
            {
                return this.divOnDepositAmtField;
            }
            set
            {
                this.divOnDepositAmtField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEHoldingLoan
    {

        private string loanAmtField;

        /// <remarks/>
        public string LoanAmt
        {
            get
            {
                return this.loanAmtField;
            }
            set
            {
                this.loanAmtField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEOLifEExtension
    {

        private string eXLActiveRequestField;

        private string eXLMultipleLoanField;

        private string eXLGrossWithdrawlField;

        private TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail[] eXLSourceDetailField;

        private int eXLSourceDetTotalField;

        /// <remarks/>
        public string EXLActiveRequest
        {
            get
            {
                return this.eXLActiveRequestField;
            }
            set
            {
                this.eXLActiveRequestField = value;
            }
        }

        /// <remarks/>
        public string EXLMultipleLoan
        {
            get
            {
                return this.eXLMultipleLoanField;
            }
            set
            {
                this.eXLMultipleLoanField = value;
            }
        }

        /// <remarks/>
        public string EXLGrossWithdrawl
        {
            get
            {
                return this.eXLGrossWithdrawlField;
            }
            set
            {
                this.eXLGrossWithdrawlField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("EXLSourceDetail")]
        public TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail[] EXLSourceDetail
        {
            get
            {
                return this.eXLSourceDetailField;
            }
            set
            {
                this.eXLSourceDetailField = value;
            }
        }

        /// <remarks/>
        public int EXLSourceDetTotal
        {
            get
            {
                return this.eXLSourceDetTotalField;
            }
            set
            {
                this.eXLSourceDetTotalField = value;
            }
        }
    }

    /// <remarks/>
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "http://ACORD.org/Standards/Life/2")]
    public partial class TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail
    {

        private string eXLSourceField;

        private string eXLSourceIDField;

        private string eXLSourceShortDescripField;

        private string eXLSourceLongDescripField;

        private string eXLFundTypeField;

        private double eXLUnitsField;

        private double eXLUnitValueField;

        private string eXLUnitDateField;

        private double eXLBalanceField;

        private int idField;

        /// <remarks/>
        public string EXLSource
        {
            get
            {
                return this.eXLSourceField;
            }
            set
            {
                this.eXLSourceField = value;
            }
        }

        /// <remarks/>
        public string EXLSourceID
        {
            get
            {
                return this.eXLSourceIDField;
            }
            set
            {
                this.eXLSourceIDField = value;
            }
        }

        /// <remarks/>
        public string EXLSourceShortDescrip
        {
            get
            {
                return this.eXLSourceShortDescripField;
            }
            set
            {
                this.eXLSourceShortDescripField = value;
            }
        }

        /// <remarks/>
        public string EXLSourceLongDescrip
        {
            get
            {
                return this.eXLSourceLongDescripField;
            }
            set
            {
                this.eXLSourceLongDescripField = value;
            }
        }

        /// <remarks/>
        public string EXLFundType
        {
            get
            {
                return this.eXLFundTypeField;
            }
            set
            {
                this.eXLFundTypeField = value;
            }
        }

        /// <remarks/>
        public double EXLUnits
        {
            get
            {
                return this.eXLUnitsField;
            }
            set
            {
                this.eXLUnitsField = value;
            }
        }

        /// <remarks/>
        public double EXLUnitValue
        {
            get
            {
                return this.eXLUnitValueField;
            }
            set
            {
                this.eXLUnitValueField = value;
            }
        }

        /// <remarks/>
        public string EXLUnitDate
        {
            get
            {
                return this.eXLUnitDateField;
            }
            set
            {
                this.eXLUnitDateField = value;
            }
        }

        /// <remarks/>
        public double EXLBalance
        {
            get
            {
                return this.eXLBalanceField;
            }
            set
            {
                this.eXLBalanceField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public int ID
        {
            get
            {
                return this.idField;
            }
            set
            {
                this.idField = value;
            }
        }
    }
}
#endregion
