using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using ExlCSR.TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Request_Policy_Summury = ExlCSR.TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary.TXLife;
using Response_Policy_Summury = ExlCSR.TransactionsLibrary.BusinessSearch.PolicySummary.ResponsePolicySummary.TXLife;


namespace ExlCSR.BusinessLayer
{
    public class GetPolicySummury_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        public TransactionRequestDetails reqDetails;
        private Response_Policy_Summury txlife_Response = null;
        //private List<Policy_summary> policy_List = null;
        private Policy_summaryViewModel policy_summaryViewModel = null;
        private string company_Code;
        private string policy_number;
        private string status;
        private string paid_to_Date;
        private string p_Mode;
        private string p_Method;
        private string p_Amount;
        private double face_Amount;
        public string face_Amounts;
        private string plain_Name;
        private string org_Name;
        private string fullName;
        public string name_id;
        //private string billing_total;
        private string prifix;
        private string firstName;
        private string middleName;
        private string lastName;
        private string ssn;
        private string DOB;
        private string state;
        private string city;
        private string zip;
        private string phone_No;


        public GetPolicySummury_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            policy_summaryViewModel = new Policy_summaryViewModel();

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


        public Policy_summaryViewModel Get_Response(string nameId)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicySummury_BusinessLogic.cs" + "." + "Get_ResponsePS" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_Policy_Summury txlife = new Request_Policy_Summury();
            txlife.TXLifeRequest = new TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");


            txlife.TXLifeRequest.TransType = new TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "302";


            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "30200S";

            txlife.TXLifeRequest.CriteriaExpression = new TransactionsLibrary.BusinessSearch.PolicySummary.RequestPolicySummary.TXLifeTXLifeRequestCriteriaExpression();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpression();


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteria>(1);


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].PropertyName = "IDReferenceNo";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria[0].PropertyValue.Value = nameId;



            txlife_Response = Response_As_Object(txlife);
            if (txlife_Response != null)
            {
                policy_summaryViewModel = Fill_Model_values(txlife_Response, txlife);
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "Get_ResponsePS", reqDetails, HttpContext.Current.User.Identity.Name);
            return policy_summaryViewModel;
        }

        public Response_Policy_Summury Response_As_Object(Request_Policy_Summury request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicySummury_BusinessLogic.cs" + "." + "Response_As_ObjectPS" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Policy_Summury response = new Response_Policy_Summury();
            String request_As_String = Common.GetXmlFromObject(request);

            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            string service_Response = getpolicyservicerefrence.EXLServiceRequest(request_As_String);
            //string service_Response = await policySummaryTask;
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
                    response = (Response_Policy_Summury)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "Response_As_ObjectPS", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        public Policy_summaryViewModel Fill_Model_values(Response_Policy_Summury response_ps, Request_Policy_Summury request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicySummury_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            List<Policy_summary> policy_summary_List = new List<Policy_summary>();

            if (response_ps.TXLifeResponse.OLifE.Holding == null && response_ps.TXLifeResponse.OLifE.Party != null &&
                response_ps.TXLifeResponse.OLifE.Relation == null)
            {
                var PartyLst = response_ps.TXLifeResponse.OLifE.Party.ToList();
                name_id = request.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria.Where(x => x.PropertyName == "IDReferenceNo").Select(x => x.PropertyValue.Value).First();


                var owner_data = PartyLst.Where(p => p.id == name_id).First();
                prifix = string.IsNullOrEmpty(owner_data.IndividualPrefix) ? string.Empty : owner_data.IndividualPrefix.Trim();
                firstName = string.IsNullOrEmpty(owner_data.IndividualFirst) ? string.Empty : owner_data.IndividualFirst.Trim();
                middleName = string.IsNullOrEmpty(owner_data.IndividualMiddle) ? string.Empty : owner_data.IndividualMiddle.Trim();
                lastName = string.IsNullOrEmpty(owner_data.IndividualLast) ? string.Empty : owner_data.IndividualLast.Trim();

                if (!string.IsNullOrEmpty(prifix))
                {
                    lastName = prifix + " " + lastName;
                }
                fullName = format_String(lastName,firstName, middleName);

                policy_summaryViewModel.owner_data = new Owner_data();

                policy_summaryViewModel.owner_data.ownerName = fullName;
                ssn = string.IsNullOrEmpty(owner_data.SSN) ? string.Empty : owner_data.SSN.Trim();
                policy_summaryViewModel.owner_data.ssn = ssn.Substring(5);
                DOB = string.IsNullOrEmpty(owner_data.dob) ? string.Empty : owner_data.dob.Trim();
                policy_summaryViewModel.owner_data.dob = Format_Date(DOB);
                policy_summaryViewModel.owner_data.gender = string.IsNullOrEmpty(owner_data.Gender) ? string.Empty : owner_data.Gender.Trim();
                policy_summaryViewModel.owner_data.address = string.IsNullOrEmpty(owner_data.address) ? string.Empty : owner_data.address.Trim();
                state = string.IsNullOrEmpty(owner_data.state) ? string.Empty : owner_data.state.Trim();
                city = string.IsNullOrEmpty(owner_data.city) ? string.Empty : owner_data.city.Trim();
                zip = string.IsNullOrEmpty(owner_data.zip) ? string.Empty : owner_data.zip.Trim();
                
                policy_summaryViewModel.owner_data.city_State_Zip = city + " " + state + " " + zip;
                policy_summaryViewModel.owner_data.email_ID = string.IsNullOrEmpty(owner_data.emailaddr) ? string.Empty : owner_data.emailaddr.Trim();
                phone_No = string.IsNullOrEmpty(owner_data.phoneno) ? string.Empty : owner_data.phoneno.Trim();
                if (!string.IsNullOrEmpty(phone_No))
                {
                    phone_No = Format_Phone_Number(phone_No);
                }
                policy_summaryViewModel.owner_data.phone_No = phone_No;
                policy_summaryViewModel.owner_data.deceased = string.IsNullOrEmpty(owner_data.deceased) ? string.Empty : owner_data.deceased;
            }

            if (response_ps.TXLifeResponse.OLifE.Holding != null && response_ps.TXLifeResponse.OLifE.Party != null &&
                response_ps.TXLifeResponse.OLifE.Relation != null)
            {
                var holdingLst = response_ps.TXLifeResponse.OLifE.Holding.ToList();
                var PartyLst = response_ps.TXLifeResponse.OLifE.Party.ToList();
                var RelationLst = response_ps.TXLifeResponse.OLifE.Relation.ToList();
                name_id = request.TXLifeRequest.CriteriaExpression.CriteriaExpression.Criteria.Where(x => x.PropertyName == "IDReferenceNo").Select(x => x.PropertyValue.Value).First();

                foreach (var hold in holdingLst)
                {
                    var relationList_Details = RelationLst.Where(R => R.OriginatingObjectID == hold.id);

                    var relationship_Org = relationList_Details.Where(R => (Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var org = PartyLst.Where(P => P.id == relationship_Org.RelatedObjectID).First();
                    org_Name = string.IsNullOrEmpty(org.FullName) ? string.Empty : org.FullName.Trim();

                    var relationship_Party = relationList_Details.Where(R => (!Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var party = PartyLst.Where(P => P.id == relationship_Party.RelatedObjectID);

                    company_Code = string.IsNullOrEmpty(hold.Policy.CarrierCode) ? string.Empty : hold.Policy.CarrierCode;
                    policy_number = string.IsNullOrEmpty(hold.Policy.PolNumber) ? string.Empty : hold.Policy.PolNumber;
                    status = string.IsNullOrEmpty(hold.Policy.PolicyStatus.Value) ? string.Empty : hold.Policy.PolicyStatus.Value;
                    if (!string.IsNullOrEmpty(status))
                    {
                        var statu_split = Regex.Split(status, "_");
                        status = statu_split[2];
                    }
                    paid_to_Date = string.IsNullOrEmpty(hold.Policy.PaidToDate) ? string.Empty : Format_Date(hold.Policy.PaidToDate);
                    p_Mode = string.IsNullOrEmpty(hold.Policy.PaymentMode.Value) ? string.Empty : hold.Policy.PaymentMode.Value;

                    p_Method = string.IsNullOrEmpty(hold.Policy.PaymentMethod.Value) ? string.Empty : hold.Policy.PaymentMethod.Value;
                    p_Amount = string.IsNullOrEmpty(hold.Policy.PaymentAmt) ? string.Empty : hold.Policy.PaymentAmt;
                    if (!string.IsNullOrEmpty(p_Amount))
                    {
                        p_Amount = System.Convert.ToDouble(p_Amount).ToString("C", CultureInfo.CurrentCulture);
                    }
                    

                    face_Amount = (hold.Policy.Life.FaceAmt == 0 ) ? 0.00 : hold.Policy.Life.FaceAmt;
                    face_Amounts = string.IsNullOrEmpty(System.Convert.ToString(hold.Policy.Life.FaceAmt)) ? "$0.00" : hold.Policy.Life.FaceAmt.ToString("C", CultureInfo.CurrentCulture);
                    plain_Name = string.IsNullOrEmpty(hold.Policy.Life.Coverage.PlanName) ? string.Empty : hold.Policy.Life.Coverage.PlanName;



                    foreach (var item in party)
                    {
                        prifix = string.IsNullOrEmpty(System.Convert.ToString(item.Person.Prefix)) ? string.Empty : System.Convert.ToString(item.Person.Prefix);
                        firstName = string.IsNullOrEmpty(item.Person.FirstName) ? string.Empty : item.Person.FirstName.Trim();
                        middleName = string.IsNullOrEmpty(item.Person.MiddleName) ? string.Empty : item.Person.MiddleName.Trim();
                        lastName = string.IsNullOrEmpty(item.Person.LastName) ? string.Empty : item.Person.LastName.Trim();
                        if (!string.IsNullOrEmpty(prifix))
                        {
                            lastName = prifix + " " + lastName;
                        }

                        fullName = format_String(lastName,firstName, middleName);

                        policy_summary_List.Add(new Policy_summary()
                        {
                            name_Id = name_id,
                            company_Code = company_Code,
                            company_Name = org_Name,
                            policy_Number = policy_number,
                            status = status,
                            plan_Code = plain_Name,
                            face_Amount = face_Amount,
                            p_Amount = p_Amount,
                            p_mode = p_Mode,
                            p_Method = p_Method,
                            paid_to_Date = paid_to_Date,
                            agent = fullName,
                            face_Amounts = face_Amounts
                        });
                    }
                }

                policy_summaryViewModel.policy_summary = policy_summary_List;


                var owner_data = PartyLst.Where(p => p.id == name_id).First();
                prifix = string.IsNullOrEmpty(owner_data.IndividualPrefix) ? string.Empty : owner_data.IndividualPrefix.Trim();
                firstName = string.IsNullOrEmpty(owner_data.IndividualFirst) ? string.Empty : owner_data.IndividualFirst.Trim();
                middleName = string.IsNullOrEmpty(owner_data.IndividualMiddle) ? string.Empty : owner_data.IndividualMiddle.Trim();
                lastName = string.IsNullOrEmpty(owner_data.IndividualLast) ? string.Empty : owner_data.IndividualLast.Trim();

                if (!string.IsNullOrEmpty(prifix))
                {
                    lastName = prifix + " " + lastName;
                }
                fullName = format_String(lastName,firstName, middleName);

                policy_summaryViewModel.owner_data = new Owner_data();

                policy_summaryViewModel.owner_data.ownerName = fullName;
                ssn = string.IsNullOrEmpty(owner_data.SSN) ? string.Empty : owner_data.SSN.Trim();
                policy_summaryViewModel.owner_data.ssn = ssn.Substring(5);
                DOB = string.IsNullOrEmpty(owner_data.dob) ? string.Empty : owner_data.dob.Trim();
                policy_summaryViewModel.owner_data.dob = Format_Date(DOB);
                policy_summaryViewModel.owner_data.gender = string.IsNullOrEmpty(owner_data.Gender) ? string.Empty : owner_data.Gender.Trim();
                policy_summaryViewModel.owner_data.address = string.IsNullOrEmpty(owner_data.address) ? string.Empty : owner_data.address.Trim();
                state = string.IsNullOrEmpty(owner_data.state) ? string.Empty : owner_data.state.Trim();
                city = string.IsNullOrEmpty(owner_data.city) ? string.Empty : owner_data.city.Trim();
                zip = string.IsNullOrEmpty(owner_data.zip) ? string.Empty : owner_data.zip.Trim();
                policy_summaryViewModel.owner_data.city_State_Zip = city + " " + state + " " + zip;
                policy_summaryViewModel.owner_data.email_ID = string.IsNullOrEmpty(owner_data.emailaddr) ? string.Empty : owner_data.emailaddr.Trim();
                phone_No = string.IsNullOrEmpty(owner_data.phoneno) ? string.Empty : owner_data.phoneno.Trim();
                if (!string.IsNullOrEmpty(phone_No))
                {
                    phone_No = Format_Phone_Number(phone_No);
                }
                policy_summaryViewModel.owner_data.phone_No = phone_No;
                policy_summaryViewModel.owner_data.deceased = string.IsNullOrEmpty(owner_data.deceased) ? string.Empty : owner_data.deceased;
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return policy_summaryViewModel;
        }

        public string Format_Phone_Number(string p_Number)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicySummury_BusinessLogic.cs" + "." + "Format_Phone_Number" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string first = p_Number.Insert(3, "-");
            string second = first.Insert(7, "-");
            string final = second;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "Format_Phone_Number", reqDetails, HttpContext.Current.User.Identity.Name);
            return final;
        }

        public string Format_Date(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicySummury_BusinessLogic.cs" + "." + "Format_Date" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            var split_value = Regex.Split(date, "-");

            var yyyy = split_value[0];
            var mm = split_value[1];
            var dd = split_value[2];
            string date_L = mm + "/" + dd + "/" + yyyy;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "Format_Date", reqDetails, HttpContext.Current.User.Identity.Name);
            return date_L;
        }

        public string format_String(string first, string middle, string last)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicySummury_BusinessLogic.cs" + "." + "format_String" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string full = string.Empty;

            if (string.IsNullOrEmpty(first))
            {
                if (string.IsNullOrEmpty(middle))
                {
                    if (string.IsNullOrEmpty(last))
                    {
                        full = string.Empty;
                    }
                    else
                    {
                        full = last;
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(last))
                    {
                        full = middle;
                    }
                    else
                    {
                        full = middle + " " + last;
                    }
                }
            }
            else
            {
                if (string.IsNullOrEmpty(middle))
                {
                    if (string.IsNullOrEmpty(last))
                    {
                        full = first;
                    }
                    else
                    {
                        full = first + "," + last;
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(last))
                    {
                        full = first + "," + middle;
                    }
                    else
                    {
                        full = first + "," + middle + " " + last;
                    }
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicySummury_BusinessLogic.cs", "format_String", reqDetails, HttpContext.Current.User.Identity.Name);
            return full;
        }
    }
}
