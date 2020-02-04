using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Response_RelationshipDetail_3020R = ExlCSR.TransactionsLibrary.BusinessSearch.RelationshipDetail.Response_RelationshipDetails_3020R.TXLife;
using Request_RelationshipDetail_3020R = ExlCSR.TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLife;
using Logging;
using Logging.Contract;
using ExlCSR.TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R;
using System.Web;
using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using System.Text.RegularExpressions;


namespace ExlCSR.BusinessLayer
{
    public class GetRelationshipDetail_3020R_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private Response_RelationshipDetail_3020R txlife_Response = null;
        public List<RelationshipDetail> relation_List = null;
        private string org_Name = string.Empty;
        private string company_Code = string.Empty;
        private string benifit = string.Empty;
        private string plan_Name = string.Empty;
        private string relationship = string.Empty;
        private string policyNumber = string.Empty;
        private string status = string.Empty;
        private string name_ID;

        public GetRelationshipDetail_3020R_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            relation_List = new List<RelationshipDetail>();
        }

        //method to initialez Array of Array object
        T[] InitializeArray<T>(int length) where T : new()
        {
            T[] array = new T[length];
            for (int i = 0; i < length; ++i)
            {
                array[i] = new T();
            }

            return array;
        }

        public async Task<List<RelationshipDetail>> Get_Response(string nameId)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetRelationshipDetail_3020R_BusinessLogic.cs" + "." + "Get_RelationshipDetail_3020R" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_RelationshipDetail_3020R txlife = new Request_RelationshipDetail_3020R();
            txlife.Version = "2.35.00";
            txlife.UserAuthRequest = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeUserAuthRequestVendorAppVendorName();
            txlife.UserAuthRequest.VendorApp.VendorName.VendorCode = 522;
            txlife.UserAuthRequest.VendorApp.VendorName.Value = "EXL";

            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "Ver 17.0";

            txlife.TXLifeRequest = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");
            txlife.TXLifeRequest.TransType = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "302";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_SRCHLD";
            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "3020R";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_EXL_RELATIONSHIP_DETAILS";

            txlife.TXLifeRequest.CriteriaExpression = new TransactionsLibrary.BusinessSearch.RelationshipDetail.Request_RelationshipDetails_3020R.TXLifeTXLifeRequestCriteriaExpression();
            txlife.TXLifeRequest.CriteriaExpression.Criteria = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteria>(5);

            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].PropertyName = "FirstName";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[0].PropertyValue.Value = string.Empty;

            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].PropertyName = "MiddleName";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[1].PropertyValue.Value = string.Empty;

            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyName = "LastName";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyValue.Value = string.Empty;

            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyName = "IDReferenceType";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyValue.Value = "OLI_IDREFTYPE_DIRECTORYID";


            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].PropertyName = "IDReferenceNo";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[4].PropertyValue.Value = nameId;

            txlife_Response = await Response_As_Object(txlife);
            if (txlife_Response != null)
            {
                relation_List = Fill_Model_values(txlife_Response);
            }            


            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetRelationshipDetail_3020R_BusinessLogic.cs", "Get_RelationshipDetail_3020R", reqDetails, HttpContext.Current.User.Identity.Name);
            return relation_List;
        }

        public async Task<Response_RelationshipDetail_3020R> Response_As_Object(Request_RelationshipDetail_3020R request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetRelationshipDetail_3020R_BusinessLogic.cs" + "." + "Response_As_Object3020R" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_RelationshipDetail_3020R response = new Response_RelationshipDetail_3020R();
            String request_As_String = Common.GetXmlFromObject(request);
            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            //GetPolicyServiceRefrence.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence.ExlLifePROServiceClient();
            var responseTask = getpolicyservicerefrence.EXLServiceRequestAsync(request_As_String);
            string service_Response = await responseTask;
            bool IS_RESPONSE_FAIL = service_Response.Contains("RESULT_FAILURE");
            if (IS_RESPONSE_FAIL)
            {
                response = null;
            }
            else
            {
                if (service_Response.Contains("Party"))
                {
                    Type type = response.GetType();
                    response = (Response_RelationshipDetail_3020R)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetRelationshipDetail_3020R_BusinessLogic.cs", "Response_As_Object3020R", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        // fill model object from response object.
        public List<RelationshipDetail> Fill_Model_values(Response_RelationshipDetail_3020R response_3020R)
        {


            List<RelationshipDetail> RelationshipDetail = new List<RelationshipDetail>();
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetRelationshipDetail_3020R_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            if (response_3020R.TXLifeResponse.OLifE.Holding != null && response_3020R.TXLifeResponse.OLifE.Party != null &&
                response_3020R.TXLifeResponse.OLifE.Relation != null)
            {
                var HoldingLst = response_3020R.TXLifeResponse.OLifE.Holding.ToList();
                var PartyLst = response_3020R.TXLifeResponse.OLifE.Party.ToList();
                var RelationLst = response_3020R.TXLifeResponse.OLifE.Relation.ToList();


                // getting policy, company code and holding from Holding list.
                foreach (var hold in HoldingLst)
                {
                    var relationList_Details = RelationLst.Where(R => R.OriginatingObjectID == hold.id);


                    this.policyNumber = string.IsNullOrEmpty(hold.Policy.PolNumber) ? string.Empty : hold.Policy.PolNumber.Trim();
                    this.status = string.IsNullOrEmpty(hold.HoldingStatus.Value) ? string.Empty : hold.HoldingStatus.Value;
                    this.company_Code = string.IsNullOrEmpty(hold.Policy.CarrierCode) ? string.Empty : hold.Policy.CarrierCode.Trim();

                    var relationship_Org = relationList_Details.Where(R => (Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var party = PartyLst.Where(P => P.id == relationship_Org.RelatedObjectID).First();
                    this.org_Name = string.IsNullOrEmpty(party.FullName) ? string.Empty : party.FullName.Trim();


                    var relationship_Party = relationList_Details.Where(R => (!Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var coverage_List = hold.Policy.Life.Where(L => L.LifeParticipant.PartyID.Equals(relationship_Party.RelatedObjectID));

                    foreach (var coverage in coverage_List)
                    {
                        this.benifit = string.IsNullOrEmpty(coverage.IndicatorCode.Value) ? string.Empty : coverage.IndicatorCode.Value.Trim();
                        name_ID = string.IsNullOrEmpty(coverage.LifeParticipant.PartyID) ? string.Empty : coverage.LifeParticipant.PartyID.Trim();
                        this.relationship = string.IsNullOrEmpty(coverage.LifeParticipant.LifeParticipantRoleCode.Value) ? string.Empty : coverage.LifeParticipant.LifeParticipantRoleCode.Value.Trim();
                        if (!string.IsNullOrEmpty(this.relationship))
                        {
                            this.relationship = this.relationship.Substring(this.relationship.LastIndexOf("_")+1);                            
                        }
                        RelationshipDetail.Add(new RelationshipDetail()
                        {
                            company_Code = company_Code,
                            company_Name = org_Name,
                            policy_Number = policyNumber,
                            benefit = benifit,
                            status = status,
                            relationship = relationship,
                            Name_Id = name_ID
                        });
                    }
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetRelationshipDetail_3020R_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return RelationshipDetail;
        }

    }
}
