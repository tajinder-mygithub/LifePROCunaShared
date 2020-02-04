using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using ExlCSR.ModelLayer;
using Logging;
using System.Web;
using System.Text.RegularExpressions;
using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302;
using ExlCSR.TransactionsLibrary.PolicySearch_302.Request_302;

namespace ExlCSR.BusinessLayer
{
    public class GetPolicy_302_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302.TXLife txlife_response = null;
        private TransactionRequestDetails reqDetails;
        private Dictionary<string, string> Company_Holding_dic = new Dictionary<string, string>();
        private Dictionary<string, string> Company_Party_dic = new Dictionary<string, string>();
        private string fullName = string.Empty;
        private string line1 = string.Empty;
        private string state = string.Empty;
        private string zip = string.Empty;
        private string address = string.Empty;
        private string nameId = string.Empty;
        private string policyNumber = string.Empty;
        private string ownerName = string.Empty;
        private string org_Name = string.Empty;
        public List<Customer> customer_Lst = null;

        public GetPolicy_302_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            customer_Lst = new List<Customer>();
        }

        public List<Customer> Get_Response(PolicySearch customersearch)
        {


            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicy_302_BusinessLogic.cs" + "." + "Get_Response302" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            ExlCSR.TransactionsLibrary.PolicySearch_302.Request_302.TXLife txlife = new ExlCSR.TransactionsLibrary.PolicySearch_302.Request_302.TXLife();
            txlife.UserAuthRequest = new TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.AppName = "CSR PORTAL";
            txlife.UserAuthRequest.VendorApp.AppVer = "Version-1.0";
            txlife.UserAuthRequest.VendorApp.VendorName = new TXLifeUserAuthRequestVendorAppVendorName();
            txlife.UserAuthRequest.VendorApp.VendorName.VendorCode = "522";
            txlife.UserAuthRequest.VendorApp.VendorName.Value = "EXL";
            txlife.UserAuthRequest.VendorApp.AppVer = "Version-1.0";
            txlife.TXLifeRequest = new TXLifeTXLifeRequest();

            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now;
            txlife.TXLifeRequest.TransType = new TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "302";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_SRCHLD";
            txlife.TXLifeRequest.TransSubType = new TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "30200";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_TRANSSUB_SRCHLD";
            txlife.TXLifeRequest.CriteriaExpression = new TXLifeTXLifeRequestCriteriaExpression();
            txlife.TXLifeRequest.CriteriaExpression.Criteria = new TXLifeTXLifeRequestCriteriaExpressionCriteria();
            txlife.TXLifeRequest.CriteriaExpression.Criteria.PropertyName = "PolNumber";
            if (string.IsNullOrEmpty(customersearch.policyNumber))
            {
                txlife.TXLifeRequest.CriteriaExpression.Criteria.PropertyValue = customersearch.policyNumber;
            }
            else
            {
                txlife.TXLifeRequest.CriteriaExpression.Criteria.PropertyValue = customersearch.policyNumber.ToUpper();
            }
            
            txlife.TXLifeRequest.CriteriaExpression.Criteria.ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria.ObjectType.tc = "18";
            txlife_response = Response_As_Object(txlife);
            if (txlife_response != null)
            {
                customer_Lst = Fill_Model_values(txlife_response);
            }
            else
            {
                customer_Lst = null;
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "CustomerController.cs", "Get_Response302", reqDetails, HttpContext.Current.User.Identity.Name);
            return customer_Lst;
        }

        public ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302.TXLife Response_As_Object(ExlCSR.TransactionsLibrary.PolicySearch_302.Request_302.TXLife request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicy_302_BusinessLogic.cs" + "." + "Response_As_Object302" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302.TXLife response = new TransactionsLibrary.PolicySearch_302.Response_302.TXLife();
            String request_as_string = Common.GetXmlFromObject(request);
            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            //GetPolicyServiceRefrence.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence.ExlLifePROServiceClient();
            string service_response = getpolicyservicerefrence.EXLServiceRequest(request_as_string);
            bool IS_RESPONSE_FAIL = service_response.Contains("RESULT_FAILURE");
            if (IS_RESPONSE_FAIL)
            {
                response = null;
            }
            else
            {
                if (service_response.Contains("Policy"))
                {
                    Type type = response.GetType();
                    response = (ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302.TXLife)Common.XmlToObject(service_response, type);
                }
                else
                {
                    response = null;
                }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicy_302_BusinessLogic.cs", "Response_As_Object", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        // fill model object from response object.
        public List<Customer> Fill_Model_values(ExlCSR.TransactionsLibrary.PolicySearch_302.Response_302.TXLife response_302)
        {


            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicy_302_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            if (response_302.TXLifeResponse.OLifE.Holding != null && response_302.TXLifeResponse.OLifE.Party != null &&
               response_302.TXLifeResponse.OLifE.Relation != null)
            {
                var HoldingLst = response_302.TXLifeResponse.OLifE.Holding.ToList();
                var PartyLst = response_302.TXLifeResponse.OLifE.Party.ToList();
                var RelationLst = response_302.TXLifeResponse.OLifE.Relation.ToList();

                foreach (var hold in HoldingLst)
                {
                    var relationList_Details = RelationLst.Where(R => R.OriginatingObjectID == hold.ID);

                    policyNumber = string.IsNullOrEmpty(hold.Policy.PolNumber) ? " " : hold.Policy.PolNumber.Trim();

                    var relationship_Org = relationList_Details.Where(R => (Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var org = PartyLst.Where(P => P.ID == relationship_Org.RelatedObjectID).First();
                    org_Name = string.IsNullOrEmpty(org.FullName) ? string.Empty : org.FullName.Trim();
                    var cc = org.Carrier.CarrierCode;


                    var relationship_Party = relationList_Details.Where(R => (!Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var party = PartyLst.Where(P => P.ID == relationship_Party.RelatedObjectID);

                    foreach (var item in party)
                    {
                        if (string.IsNullOrEmpty(item.FullName))
                        {
                            nameId = string.IsNullOrEmpty(item.ID) ? string.Empty : item.ID.Trim();
                            string prifix = string.IsNullOrEmpty(item.Person.Prefix) ? string.Empty : item.Person.Prefix;
                            string firstName = string.IsNullOrEmpty(item.Person.FirstName) ? string.Empty : item.Person.FirstName.Trim();
                            string middleName = string.IsNullOrEmpty(item.Person.MiddleName) ? string.Empty : item.Person.MiddleName.Trim();
                            string lastName = string.IsNullOrEmpty(item.Person.LastName) ? string.Empty : item.Person.LastName.Trim();
                            if(!string.IsNullOrEmpty(prifix))
                            {
                                lastName = prifix + " " + lastName;
                            }

                            fullName = format_String(lastName,firstName,middleName);

                            line1 = string.IsNullOrEmpty(item.Address.Line1) ? string.Empty : item.Address.Line1.Trim();

                            var db_State = string.IsNullOrEmpty(item.Address.AddressStateTC.Value) ? string.Empty : item.Address.AddressStateTC.Value.Trim();
                            if (state.Equals("0")) state = string.Empty;
                            if (!db_State.Equals(string.Empty))
                            {
                                var state_split = Regex.Split(db_State, "_");
                                state = state_split[2];
                            }

                            zip = string.IsNullOrEmpty(item.Address.Zip) ? string.Empty : item.Address.Zip.Trim();
                            if (zip.Equals("0")) zip = string.Empty;
                            address = format_String(line1, state, zip);
                        }
                        else
                        {
                            nameId = string.IsNullOrEmpty(item.ID) ? string.Empty : item.ID.Trim();
                            fullName = string.IsNullOrEmpty(item.FullName) ? string.Empty : item.FullName.Trim();
                            line1 = string.IsNullOrEmpty(item.Address.Line1) ? string.Empty : item.Address.Line1.Trim();
                            var db_State = string.IsNullOrEmpty(item.Address.AddressStateTC.Value) ? string.Empty : item.Address.AddressStateTC.Value.Trim();

                            if (state.Equals("0")) state = string.Empty;
                            if (!db_State.Equals(string.Empty))
                            {
                                var state_split = Regex.Split(db_State, "_");
                                state = state_split[2];
                            }

                            zip = string.IsNullOrEmpty(item.Address.Zip) ? string.Empty : item.Address.Zip.Trim();
                            if (zip.Equals("0")) zip = string.Empty;

                            address = format_String(line1, state, zip);
                        }

                        customer_Lst.Add(new Customer()
                        {
                            nameID = nameId,
                            companyName = org_Name,
                            ownerName = fullName,
                            policyNumber = policyNumber,
                            address = address,
                            Company_code = cc
                        });
                    }

                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicy_302_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return customer_Lst;
        }

        public string format_String(string first, string second, string last)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicy_302_BusinessLogic.cs" + "." + "format_String" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string full = string.Empty;

            if (string.IsNullOrEmpty(first))
            {
                if (string.IsNullOrEmpty(second))
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
                        full = second;
                    }
                    else
                    {
                        full = second + " " + last;
                    }
                }
            }
            else
            {
                if (string.IsNullOrEmpty(second))
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
                        full = first + "," + second;
                    }
                    else
                    {
                        full = first + "," + second + " " + last;
                    }
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicy_302_BusinessLogic.cs", "format_String", reqDetails, HttpContext.Current.User.Identity.Name);
            return full;
        }
    }
}

