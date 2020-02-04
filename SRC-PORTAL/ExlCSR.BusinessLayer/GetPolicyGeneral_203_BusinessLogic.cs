using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Request_Genr_203 = ExlCSR.TransactionsLibrary.PolicySummary.Request_General_203.TXLife;
using Response_Genr_203 = ExlCSR.TransactionsLibrary.PolicySummary.Response_General_203.TXLife;

namespace ExlCSR.BusinessLayer
{
    public class GetPolicyGeneral_203_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private PolicyGeneral_output policyGeneral_output = null;
        private Response_Genr_203 txlife_Response = null;
        private string transType = string.Empty;
        private string transSubType = string.Empty;
        private string issue_Date_L;
        private string paid_toDate_L;
        private string payment_Method;
        private string expire_Date_L;
        private string owner_TaxID;
        private string owner_dob;
        private string annuitant_dob;
        private string annuitant_TaxID;
        private string contract_Status;
        private string primary_insured_dob;
        private string primary_insured_TaxID;
        private string other_insured_fullname;
        private string other_insured_dob;
        private string other_insured_TaxID;
        private string other_insured_Gender;

        public GetPolicyGeneral_203_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
        }

        public PolicyGeneral_output Get_Response(PolicyGeneral_Input pol)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "Get_Response203" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            Request_Genr_203 txlife = new Request_Genr_203();

            txlife.TXLifeRequest = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");
            txlife.TXLifeRequest.TransType = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "203";

            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "20300";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequestOLifE();
            txlife.TXLifeRequest.OLifE.Holding = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequestOLifEHolding();
            txlife.TXLifeRequest.OLifE.Holding.Policy = new TransactionsLibrary.PolicySummary.Request_General_203.TXLifeTXLifeRequestOLifEHoldingPolicy();

            txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode = pol.company_code;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber = pol.policy_number;

            txlife_Response = Response_As_Object(txlife);

            if (txlife_Response != null)
            {

                policyGeneral_output = Fill_Model_values(txlife_Response, txlife);
            }
            else
            {
                policyGeneral_output = null;
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "Get_Response203", reqDetails, HttpContext.Current.User.Identity.Name);
            return policyGeneral_output;
        }

        public Response_Genr_203 Response_As_Object(Request_Genr_203 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetSurr_212_BussinessLogic.cs" + "." + "Response_As_Object203" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Genr_203 response = new Response_Genr_203();
            String request_As_String = Common.GetXmlFromObject(request);

            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            string service_Response = getpolicyservicerefrence.EXLServiceRequest(request_As_String);
            bool IS_RESPONSE_FAIL = service_Response.Contains("RESULT_FAILURE");
            if (IS_RESPONSE_FAIL)
            {
                response = null;
            }
            else
            {
                if (service_Response.Contains("Holding"))
                {
                    Type type = response.GetType();
                    response = (Response_Genr_203)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "Response_As_Object203", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        public PolicyGeneral_output Fill_Model_values(Response_Genr_203 response_212, Request_Genr_203 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            string agent_Status;
            PolicyGeneral_output policyGeneral_output = new PolicyGeneral_output();
            if (response_212.TXLifeResponse.OLifE.Holding != null && response_212.TXLifeResponse.OLifE.Party != null &&
                response_212.TXLifeResponse.OLifE.Relation != null)
            {

                var hold_List_All = response_212.TXLifeResponse.OLifE.Holding.ToList();
                var hold_List = hold_List_All.Where(h => (!Regex.IsMatch(h.id, "Holding_Bank*")));
                var PartyLst = response_212.TXLifeResponse.OLifE.Party.ToList();
                var RelationLst = response_212.TXLifeResponse.OLifE.Relation.ToList();

                foreach (var hold in hold_List)
                {
                    policyGeneral_output.policy_Number = string.IsNullOrEmpty(hold.Policy.PolNumber) ? string.Empty : hold.Policy.PolNumber;
                    policyGeneral_output.LOB = string.IsNullOrEmpty(hold.Policy.LineOfBusiness.Value) ? string.Empty : hold.Policy.LineOfBusiness.Value;
                    issue_Date_L = string.IsNullOrEmpty(hold.Policy.IssueDate) ? string.Empty : hold.Policy.IssueDate;


                    if (string.IsNullOrEmpty(issue_Date_L) || issue_Date_L.Equals("0"))
                    {
                        policyGeneral_output.issue_Date = Format_Date("0000/00/00");
                    }
                    else
                    {
                        policyGeneral_output.issue_Date = Format_Date(issue_Date_L);
                    }

                    policyGeneral_output.contract_Status = string.IsNullOrEmpty(hold.Policy.PolicyStatus.Value) ? string.Empty : hold.Policy.PolicyStatus.Value;
                    if (!string.IsNullOrEmpty(policyGeneral_output.contract_Status))
                    {
                        var contract_Split = Regex.Split(policyGeneral_output.contract_Status, "_");
                        policyGeneral_output.contract_Status = contract_Split[2];
                    }
                    payment_Method = string.IsNullOrEmpty(hold.Policy.PaymentMethod.Value) ? string.Empty : hold.Policy.PaymentMethod.Value;
                    if (!string.IsNullOrEmpty(payment_Method) || !string.IsNullOrEmpty(payment_Method))
                    {
                        var contract_Split = Regex.Split(payment_Method, "_");
                        payment_Method = contract_Split[2];
                    }
                    contract_Status = string.IsNullOrEmpty(policyGeneral_output.contract_Status) ? string.Empty : policyGeneral_output.contract_Status;

                    policyGeneral_output.mode_Prem = string.IsNullOrEmpty(hold.Policy.PaymentAmt) ? "$0.00" : ("$"+hold.Policy.PaymentAmt.Trim());
                    policyGeneral_output.billing_Status = payment_Method + "    " + contract_Status;
                    policyGeneral_output.mode_Prem = string.IsNullOrEmpty(hold.Policy.PaymentAmt) ? "$0.00" : ("$" + hold.Policy.PaymentAmt);
                    paid_toDate_L = string.IsNullOrEmpty(hold.Policy.PaidToDate) ? string.Empty : hold.Policy.PaidToDate;
                    if (string.IsNullOrEmpty(paid_toDate_L) || paid_toDate_L.Equals("0"))
                    {
                        policyGeneral_output.paid_to_Date = Format_Date("0000/00/00");
                    }
                    else
                    {
                        policyGeneral_output.paid_to_Date = Format_Date(paid_toDate_L);
                    }

                    if (hold.Policy.Life != null)
                    {
                        var life_Lst = hold.Policy.Life.ToList();
                        foreach (var life in life_Lst)
                        {
                            if (policyGeneral_output.LOB.Equals("OLI_LINEBUS_LIFE") || policyGeneral_output.LOB.Equals("OLI_LINEBUS_HEALTH"))
                            {

                                if (life.id.Equals("1") && life.IndicatorCode.tc.Equals("1"))
                                {
                                    var participant_List = life.CovOption.Participant.ToList(); //participant List
                                    var participant_insured = participant_List.Where(p => p.ID == 1).First(); // participant whose id is 1.
                                    var rel_insured_list = RelationLst.Where(r => r.RelationRoleCode.Value == "OLI_REL_INSURED");// relation list of Insured 
                                    var rel_insured = rel_insured_list.Where(r => r.RelatedObjectID.Equals(participant_insured.Idref)).First();// relation list of Insured whose RelatedObjectID is equals to Idref

                                    var primary_insured = PartyLst.Where(p => p.ID.Equals(rel_insured.RelatedObjectID)).First(); //party whose id is equls to RelatedObjectID of relation
                                    string prifix = string.IsNullOrEmpty(primary_insured.Person.Prefix) ? string.Empty : primary_insured.Person.Prefix.Trim();
                                    string firstName = string.IsNullOrEmpty(primary_insured.Person.FirstName) ? string.Empty : primary_insured.Person.FirstName.Trim();
                                    string middleName = string.IsNullOrEmpty(primary_insured.Person.MiddleName) ? string.Empty : primary_insured.Person.MiddleName.Trim();
                                    string lastName = string.IsNullOrEmpty(primary_insured.Person.LastName) ? string.Empty : primary_insured.Person.LastName.Trim();
                                    if (!string.IsNullOrEmpty(prifix))
                                    {
                                        lastName = prifix + " " + lastName;
                                    }
                                    policyGeneral_output.primary_insured = format_String(lastName,firstName, middleName);
                                    primary_insured_dob = string.IsNullOrEmpty(primary_insured.Person.BirthDate) ? string.Empty : primary_insured.Person.BirthDate.Trim();
                                    if (primary_insured_dob.Equals(0) || string.IsNullOrEmpty(primary_insured_dob))
                                    {
                                        primary_insured_dob = "0000/00/00";
                                    }
                                    policyGeneral_output.pi_DOB = Format_Date(primary_insured_dob);
                                    primary_insured_TaxID = string.IsNullOrEmpty(primary_insured.GovtID) ? string.Empty : primary_insured.GovtID.Trim();
                                    if (primary_insured_TaxID.Equals("0"))
                                    {
                                        primary_insured_TaxID = string.Empty;
                                    }
                                    if (!string.IsNullOrEmpty(primary_insured_TaxID))
                                    {
                                        var last_Four_Digit = primary_insured_TaxID.Substring(5);
                                        policyGeneral_output.pi_TaxID = "*****" + last_Four_Digit;
                                    }
                                    policyGeneral_output.pi_Gender = string.IsNullOrEmpty(primary_insured.Person.Gender.Value) ? string.Empty : primary_insured.Person.Gender.Value;

                                    // for other insured start.
                                    var participant_other_insured = participant_List.Where(p => p.ID != 1); // participants list whose id is not equlas to 1.                                    
                                    List<Other_Insu_Details> other_Insu_Details = new List<Other_Insu_Details>();

                                    foreach (var other_insured in participant_other_insured)
                                    {
                                        foreach (var relation in rel_insured_list)
                                        {
                                            if (other_insured.Idref.Equals(relation.RelatedObjectID))
                                            {
                                                var other_Insured_Party = PartyLst.Where(p => p.ID.Equals(relation.RelatedObjectID)).First(); //party whose id is equls to RelatedObjectID of relation
                                                prifix = string.IsNullOrEmpty(other_Insured_Party.Person.Prefix) ? string.Empty : other_Insured_Party.Person.Prefix.Trim();
                                                firstName = string.IsNullOrEmpty(other_Insured_Party.Person.FirstName) ? string.Empty : other_Insured_Party.Person.FirstName.Trim();
                                                middleName = string.IsNullOrEmpty(other_Insured_Party.Person.MiddleName) ? string.Empty : other_Insured_Party.Person.MiddleName.Trim();
                                                lastName = string.IsNullOrEmpty(other_Insured_Party.Person.LastName) ? string.Empty : other_Insured_Party.Person.LastName.Trim();
                                                if (!string.IsNullOrEmpty(prifix))
                                                {
                                                    lastName = prifix + " " + lastName;
                                                }
                                                other_insured_fullname = format_String(lastName,firstName, middleName);
                                                other_insured_dob = string.IsNullOrEmpty(other_Insured_Party.Person.BirthDate) ? string.Empty : other_Insured_Party.Person.BirthDate.Trim();
                                                if (other_insured_dob.Equals(0) || string.IsNullOrEmpty(other_insured_dob))
                                                {
                                                    primary_insured_dob = "0000/00/00";
                                                }
                                                other_insured_dob = Format_Date(other_insured_dob);

                                                other_insured_TaxID = string.IsNullOrEmpty(other_Insured_Party.GovtID) ? string.Empty : other_Insured_Party.GovtID.Trim();
                                                if (other_insured_TaxID.Equals("0"))
                                                {
                                                    other_insured_TaxID = string.Empty;
                                                }
                                                if (!string.IsNullOrEmpty(other_insured_TaxID))
                                                {
                                                    var last_Four_Digit = other_insured_TaxID.Substring(5);
                                                    other_insured_TaxID = "*****" + last_Four_Digit;
                                                }
                                                other_insured_Gender = string.IsNullOrEmpty(other_Insured_Party.Person.Gender.Value) ? string.Empty : other_Insured_Party.Person.Gender.Value.Trim();

                                                other_Insu_Details.Add(new Other_Insu_Details()
                                                {
                                                    other_insured = other_insured_fullname,
                                                    other_DOB = other_insured_dob,
                                                    other_Gender = other_insured_Gender,
                                                    other_TaxID = other_insured_TaxID
                                                });
                                            }
                                        }
                                    }
                                    // for other insured end
                                }
                            } // LIFE primary insured details ends here.

                            policyGeneral_output.plan_Code = string.IsNullOrEmpty(life.ShortName) ? string.Empty : life.ShortName.Trim();
                            expire_Date_L = string.IsNullOrEmpty(life.ExpiryDate) ? string.Empty : life.ExpiryDate.Trim();
                            if (expire_Date_L.Equals("0"))
                            {
                                policyGeneral_output.expire_Date = string.Empty;
                            }
                            else
                            {
                                policyGeneral_output.expire_Date = Format_Date(expire_Date_L);
                            }
                            policyGeneral_output.issue_Age = string.IsNullOrEmpty(life.CovOption.IssueAge) ? string.Empty : life.CovOption.IssueAge.Trim();
                        }// foreach Life List Loop end.
                    }
                } // foreach Hold Loop end.

                policyGeneral_output.payment_Status = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.FinancialActivity.Payment.PaymentStatus.Value) ? string.Empty : response_212.TXLifeResponse.OLifE.FinancialActivity.Payment.PaymentStatus.Value;
                policyGeneral_output.active_Loans = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLActiveLoanFlag) ? string.Empty : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLActiveLoanFlag;
                policyGeneral_output.MPR = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLMPRDate) ? string.Empty : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLMPRDate;
                if (string.IsNullOrEmpty(policyGeneral_output.MPR) || policyGeneral_output.MPR.Equals("0"))
                {
                    policyGeneral_output.MPR = string.Empty;
                }
                else
                {
                    policyGeneral_output.MPR = Format_Date(policyGeneral_output.MPR);
                }

                policyGeneral_output.tax_Qual_Code = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.OLifEExtension.QualPlanType) ? string.Empty : response_212.TXLifeResponse.OLifE.OLifEExtension.QualPlanType;


                //var modal_Prem_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLModalPremium.ToList();
                //var modal_Prem = modal_Prem_Lst.Where(m => m.CovID.Equals("1")).First(); // need to confirm from Saurabh P
                //policyGeneral_output.mode_Prem = string.IsNullOrEmpty(modal_Prem.Value) ? string.Empty : modal_Prem.Value;
                policyGeneral_output.policy_Code = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLPolicyCode) ? string.Empty : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLPolicyCode;
                var dividend_option_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDividendOption.ToList();
                var dividend_option = dividend_option_Lst.Where(d => d.CovID.Equals("1")).First();
                policyGeneral_output.dividend_Option = string.IsNullOrEmpty(dividend_option.CovID) ? string.Empty : dividend_option.CovID.Trim();// need to confirm from Saurabh P


                var rel_Owner = RelationLst.Where(o => o.RelationRoleCode.Value == "OLI_REL_OWNER");
                if (rel_Owner.Count() > 0)
                {
                    foreach (var owner_data in rel_Owner)
                    {
                        var party_data_Lst = PartyLst.Where(p => p.ID.Equals(owner_data.RelatedObjectID));
                        string name_ID = owner_data.RelatedObjectID;

                        foreach (var data in party_data_Lst)
                        {

                            string prifix = string.IsNullOrEmpty(data.Person.Prefix) ? string.Empty : data.Person.Prefix.Trim();
                            string firstName = string.IsNullOrEmpty(data.Person.FirstName) ? string.Empty : data.Person.FirstName.Trim();
                            string middleName = string.IsNullOrEmpty(data.Person.MiddleName) ? string.Empty : data.Person.MiddleName.Trim();
                            string lastName = string.IsNullOrEmpty(data.Person.LastName) ? string.Empty : data.Person.LastName.Trim();
                            if (!string.IsNullOrEmpty(prifix))
                            {
                                lastName = prifix + " " + lastName;
                            }
                            policyGeneral_output.owner = format_String(lastName, firstName, middleName);
                            owner_dob = string.IsNullOrEmpty(data.Person.BirthDate) ? string.Empty : data.Person.BirthDate.Trim();
                            if (owner_dob.Equals(0) || string.IsNullOrEmpty(owner_dob))
                            {
                                owner_dob = "0000/00/00";
                            }
                            policyGeneral_output.owner_DOB = Format_Date(owner_dob);
                            owner_TaxID = string.IsNullOrEmpty(data.GovtID) ? string.Empty : data.GovtID.Trim();
                            if (owner_TaxID.Equals("0"))
                            {
                                owner_TaxID = string.Empty;
                            }
                            if (!string.IsNullOrEmpty(owner_TaxID))
                            {
                                var last_Four_Digit = owner_TaxID.Substring(5);
                                policyGeneral_output.owner_TaxID = "*****" + last_Four_Digit;
                            }
                            policyGeneral_output.owner_Gender = string.IsNullOrEmpty(data.Person.Gender.Value) ? string.Empty : data.Person.Gender.Value.Trim();
                            policyGeneral_output.owner_Age = string.IsNullOrEmpty(data.Person.Age) ? string.Empty : data.Person.Age.Trim();
                            policyGeneral_output.name_id = name_ID;
                        }
                    }
                }
                else
                {
                    policyGeneral_output.owner = string.Empty;
                    policyGeneral_output.owner_DOB = string.Empty;
                    policyGeneral_output.owner_TaxID = string.Empty;
                    policyGeneral_output.owner_Gender = string.Empty;
                    policyGeneral_output.owner_Age = string.Empty;
                }

                if (policyGeneral_output.LOB.Equals("OLI_LINEBUS_ANNUITY"))
                {
                    policyGeneral_output.living_Benefits = GetLivingBenefitList(response_212);

                    var rel_Annu = RelationLst.Where(o => o.RelationRoleCode.Value == "OLI_REL_ANNUITANT");
                    if (rel_Annu.Count() > 0)
                    {
                        foreach (var Ann_data in rel_Annu)
                        {
                            var party_data_Lst = PartyLst.Where(p => p.ID.Equals(Ann_data.RelatedObjectID));

                            foreach (var data in party_data_Lst)
                            {
                                string prifix = string.IsNullOrEmpty(data.Person.Prefix) ? string.Empty : data.Person.Prefix.Trim();
                                string firstName = string.IsNullOrEmpty(data.Person.FirstName) ? string.Empty : data.Person.FirstName.Trim();
                                string middleName = string.IsNullOrEmpty(data.Person.MiddleName) ? string.Empty : data.Person.MiddleName.Trim();
                                string lastName = string.IsNullOrEmpty(data.Person.LastName) ? string.Empty : data.Person.LastName.Trim();
                                if (!string.IsNullOrEmpty(prifix))
                                {
                                    lastName = prifix + " " + lastName;
                                }
                                policyGeneral_output.annuitant = format_String(lastName, firstName, middleName);
                                annuitant_dob = string.IsNullOrEmpty(data.Person.BirthDate) ? string.Empty : data.Person.BirthDate.Trim();
                                if (annuitant_dob.Equals(0) || string.IsNullOrEmpty(annuitant_dob))
                                {
                                    annuitant_dob = "0000/00/00";
                                }
                                policyGeneral_output.annu_DOB = Format_Date(annuitant_dob);
                                annuitant_TaxID = string.IsNullOrEmpty(data.GovtID) ? string.Empty : data.GovtID.Trim();
                                if (annuitant_TaxID.Equals("0"))
                                {
                                    annuitant_TaxID = string.Empty;
                                }
                                if (!string.IsNullOrEmpty(annuitant_TaxID))
                                {
                                    var last_Four_Digit = annuitant_TaxID.Substring(5);
                                    policyGeneral_output.annu_TaxID = "*****" + last_Four_Digit;
                                }
                                policyGeneral_output.annu_Gender = string.IsNullOrEmpty(data.Person.Gender.Value) ? string.Empty : data.Person.Gender.Value;
                                policyGeneral_output.annu_Age = string.IsNullOrEmpty(data.Person.Age) ? string.Empty : data.Person.Age;
                            }
                        }
                        
                    }
                    else
                    {
                        policyGeneral_output.annuitant = string.Empty;
                        policyGeneral_output.annu_DOB = string.Empty;
                        policyGeneral_output.annu_TaxID = string.Empty;
                        policyGeneral_output.annu_Gender = string.Empty;
                        policyGeneral_output.annu_Age = string.Empty;
                    }

                } // if condition for OLI_LINEBUS_ANNUITY end.

                var ser_Agent = RelationLst.Where(o => o.RelationRoleCode.Value == "OLI_REL_SERVAGENT");
                if (ser_Agent.Count() > 0)
                {
                    foreach (var Ser_data in ser_Agent)
                    {
                        var party_data_Lst = PartyLst.Where(p => p.ID.Equals(Ser_data.RelatedObjectID));
                        foreach (var data in party_data_Lst)
                        {
                            string prifix = string.IsNullOrEmpty(data.Person.Prefix) ? string.Empty : data.Person.Prefix.Trim();
                            string firstName = string.IsNullOrEmpty(data.Person.FirstName) ? string.Empty : data.Person.FirstName.Trim();
                            string middleName = string.IsNullOrEmpty(data.Person.MiddleName) ? string.Empty : data.Person.MiddleName.Trim();
                            string lastName = string.IsNullOrEmpty(data.Person.LastName) ? string.Empty : data.Person.LastName.Trim();
                            if (!string.IsNullOrEmpty(prifix))
                            {
                                lastName = prifix + " " + lastName;
                            }
                            policyGeneral_output.servicing_Agent = format_String(lastName, firstName, middleName);
                        }

                        var agent_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLAgentDetail.ToList();
                        var agent_data = agent_Lst.Where(a => a.ID.Equals(Ser_data.RelatedObjectID)).First();
                        agent_Status = string.IsNullOrEmpty(agent_data.EXLAgentStatusCode) ? string.Empty : agent_data.EXLAgentStatusCode.Trim();
                        policyGeneral_output.agent_Status = agent_Status;

                    }
                }
                else
                {
                    policyGeneral_output.servicing_Agent = string.Empty;
                }

                policyGeneral_output.relationship_Details = GetRelationshipList(response_212);
                policyGeneral_output.agents = GetAgentList(response_212);
                if (!policyGeneral_output.LOB.Equals("OLI_LINEBUS_ANNUITY"))
                {
                    policyGeneral_output.benefits = GetBenefitList(response_212);
                }

            }
            return policyGeneral_output;
        }


        public List<Relationship_Details> GetRelationshipList(Response_Genr_203 response_212)
        {
            string subType;
            string per_Interest;
            string amt_Interest;
            string relationship;
            string r_name;
            string r_dob;
            string r_TaxID;
            string r_Gender;
            string r_Age;
            string add_Line;
            string city;
            string state;
            string zip;
            string phone;
            string deceased;
            string r_bene_seq;

            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "GetRelationshipList" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            List<Relationship_Details> relationship_Details = new List<Relationship_Details>();

            var hold_List_All = response_212.TXLifeResponse.OLifE.Holding.ToList();
            var hold_List = hold_List_All.Where(h => (!Regex.IsMatch(h.id, "Holding_Bank*")));
            var PartyLst = response_212.TXLifeResponse.OLifE.Party.ToList();
            var RelationLst = response_212.TXLifeResponse.OLifE.Relation.ToList();

            foreach (var relation in RelationLst)
            {
                subType = string.IsNullOrEmpty(relation.RelationDescription.Value) ? string.Empty : relation.RelationDescription.Value.Trim();
                per_Interest = string.IsNullOrEmpty(relation.InterestPercent) ? string.Empty : relation.InterestPercent.Trim();
                amt_Interest = string.IsNullOrEmpty(relation.InterestAmt) ? string.Empty : relation.InterestAmt.Trim();
                if(!string.IsNullOrEmpty(amt_Interest))
                {
                    amt_Interest = System.Convert.ToDouble(amt_Interest).ToString("C", CultureInfo.CurrentCulture);
                }                

                relationship = string.IsNullOrEmpty(relation.RelationRoleCode.Value) ? string.Empty : relation.RelationRoleCode.Value.Trim();
                var split_rel = Regex.Split(relationship, "_");
                if (split_rel.Length == 3) relationship = split_rel[2];

                var party_relation_Data = PartyLst.Where(p => p.ID.Equals(relation.RelatedObjectID)).First();

                string prifix = string.IsNullOrEmpty(party_relation_Data.Person.Prefix) ? string.Empty : party_relation_Data.Person.Prefix.Trim();
                string firstName = string.IsNullOrEmpty(party_relation_Data.Person.FirstName) ? string.Empty : party_relation_Data.Person.FirstName.Trim();
                string middleName = string.IsNullOrEmpty(party_relation_Data.Person.MiddleName) ? string.Empty : party_relation_Data.Person.MiddleName.Trim();
                string lastName = string.IsNullOrEmpty(party_relation_Data.Person.LastName) ? string.Empty : party_relation_Data.Person.LastName.Trim();
                if (!string.IsNullOrEmpty(prifix))
                {
                    lastName = prifix + " " + lastName;
                }
                r_name = format_String(lastName, firstName, middleName);

                r_dob = string.IsNullOrEmpty(party_relation_Data.Person.BirthDate) ? string.Empty : party_relation_Data.Person.BirthDate.Trim();

                if (r_dob.Equals(0) || string.IsNullOrEmpty(r_dob))
                {
                    r_dob = "0000-00-00";
                }
                r_dob = Format_Date(r_dob);

                r_TaxID = string.IsNullOrEmpty(party_relation_Data.GovtID) ? string.Empty : party_relation_Data.GovtID.Trim();
                if (r_TaxID.Equals("0"))
                {
                    r_TaxID = string.Empty;
                }
                if (!string.IsNullOrEmpty(r_TaxID))
                {
                    var last_Four_Digit = r_TaxID.Substring(5);
                    r_TaxID = "*****" + last_Four_Digit;
                }
                r_Gender = string.IsNullOrEmpty(party_relation_Data.Person.Gender.Value) ? string.Empty : party_relation_Data.Person.Gender.Value.Trim();
                r_Age = string.IsNullOrEmpty(party_relation_Data.Person.Age) ? string.Empty : party_relation_Data.Person.Age.Trim();
                add_Line = string.IsNullOrEmpty(party_relation_Data.Address.Line1) ? string.Empty : party_relation_Data.Address.Line1;
                city = string.IsNullOrEmpty(party_relation_Data.Address.City) ? string.Empty : party_relation_Data.Address.City.Trim();
                state = string.IsNullOrEmpty(party_relation_Data.Address.AddressStateTC.Value) ? string.Empty : party_relation_Data.Address.AddressStateTC.Value.Trim();
                zip = string.IsNullOrEmpty(party_relation_Data.Address.Zip) ? string.Empty : party_relation_Data.Address.Zip.Trim();

                var phone_Lst = party_relation_Data.Phone.ToList();
                var phone_No = phone_Lst.Where(p => p.PhoneTypeCode.tc.Equals("12")).First();
                phone = string.IsNullOrEmpty(phone_No.PhoneTypeCode.Value) ? string.Empty : phone_No.PhoneTypeCode.Value.Trim();
                if (!string.IsNullOrEmpty(phone) || phone.Length > 9)
                {
                    phone = Format_Phone_Number(phone);
                }

                var hold_Lst_rel = hold_List.Where(h => h.id.Equals(relation.OriginatingObjectID)).First(); // error
                var life_Lst = hold_Lst_rel.Policy.Life.ToList();
                var life_Lst_rel = life_Lst.Where(l => l.IndicatorCode.Value.Equals("Base")).First();
                var participant_Lst = life_Lst_rel.CovOption.Participant.ToList();
                var ben_seq = participant_Lst.Where(p => p.Idref.Equals(relation.RelatedObjectID)).First();
                r_bene_seq = string.IsNullOrEmpty(ben_seq.BeneficiarySeqNum) ? string.Empty : ben_seq.BeneficiarySeqNum.Trim();

                var deceas_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDeceasedFlag.ToList();
                var deceasd = deceas_Lst.Where(d => d.PartyID.Equals(relation.RelatedObjectID)).First();
                deceased = string.IsNullOrEmpty(deceasd.Value) ? string.Empty : deceasd.Value.Trim();

                relationship_Details.Add(new Relationship_Details()
                {
                    name = r_name,
                    seq = r_bene_seq,
                    relationship = relationship,
                    subType = subType,
                    per_Interest = per_Interest + "%",
                    amt_Interest = amt_Interest,
                    r_Dob = r_dob,
                    r_Gender = r_Gender,
                    r_TaxID = r_TaxID,
                    r_Current_Age = r_Age,
                    r_Add_Line = add_Line,
                    city = city,
                    state = state,
                    zip = zip,
                    r_Phone = phone,
                    r_Deceased = deceased
                });
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "GetRelationshipList", reqDetails, HttpContext.Current.User.Identity.Name);
            return relationship_Details;
        }


        public List<Benefits> GetBenefitList(Response_Genr_203 response_212)
        {
            string Cov_Code;
            string Cov_Name;
            string ben_Seq;
            string status;
            string issue_Date;
            string face_Amt;
            double model_Premium;
            string under_Writing;
            string start_Date;
            string end_Date;
            string Ben_Name;
            string Ben_Gender;
            string ben_Relation;

            List<Benefits> benefits = new List<Benefits>();
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "GetBenefitList" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            var hold_List_All = response_212.TXLifeResponse.OLifE.Holding.ToList();
            var hold_List = hold_List_All.Where(h => (!Regex.IsMatch(h.id, "Holding_Bank*")));
            var PartyLst = response_212.TXLifeResponse.OLifE.Party.ToList();
            var RelationLst = response_212.TXLifeResponse.OLifE.Relation.ToList();

            foreach (var hold in hold_List)
            {
                var life_list = hold.Policy.Life.ToList();
                foreach (var life in life_list)
                {
                    Cov_Code = string.IsNullOrEmpty(life.ShortName) ? string.Empty : life.ShortName.Trim();
                    Cov_Name = string.IsNullOrEmpty(life.PlanName) ? string.Empty : life.PlanName.Trim();

                    var participant_List_All = life.CovOption.Participant.ToList();
                    var participant_Lst = participant_List_All.Where(p => System.Convert.ToInt16(p.BeneficiarySeqNum) >= 1);

                    foreach (var participant in participant_Lst)
                    {
                        ben_Seq = string.IsNullOrEmpty(participant.BeneficiarySeqNum) ? string.Empty : participant.BeneficiarySeqNum;
                        status = string.IsNullOrEmpty(participant.ParticipantStatus.Value) ? string.Empty : participant.ParticipantStatus.Value.Trim();
                        issue_Date = string.IsNullOrEmpty(participant.EffDate) ? string.Empty : participant.EffDate;
                        if (string.IsNullOrEmpty(issue_Date) || issue_Date.Equals("0"))
                        {
                            issue_Date = "0000-00-00";
                        }
                        issue_Date = Format_Date(issue_Date);
                        face_Amt = string.IsNullOrEmpty(System.Convert.ToString(participant.FaceAmt)) ? string.Empty : participant.FaceAmt.ToString("C", CultureInfo.CurrentCulture);
                        
                        under_Writing = string.IsNullOrEmpty(participant.UnderwritingClass) ? string.Empty : participant.UnderwritingClass.Trim();
                        start_Date = string.IsNullOrEmpty(participant.EffDate) ? string.Empty : participant.EffDate.Trim();
                        if (string.IsNullOrEmpty(start_Date) || start_Date.Equals("0"))
                        {
                            start_Date = "0000-00-00";
                        }
                        start_Date = Format_Date(start_Date);

                        end_Date = string.IsNullOrEmpty(participant.TermDate) ? string.Empty : participant.TermDate.Trim();
                        if (string.IsNullOrEmpty(end_Date) || end_Date.Equals("0"))
                        {
                            end_Date = "0000-00-00";
                        }
                        end_Date = Format_Date(end_Date);

                        var model_Prem_lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLModalPremiumML.ToList();
                        var model_Prem_cov = model_Prem_lst.Where(m => m.CovID.Equals(life.id));
                        var model_prem = model_Prem_cov.Where(p => p.ParticipantID.Equals(System.Convert.ToString(participant.ID))).First();
                        model_Premium = string.IsNullOrEmpty(model_prem.Value) ? 0 : (System.Convert.ToDouble(model_prem.Value.Trim()));                        
                        string model_pre = model_Premium.ToString("C", CultureInfo.CurrentCulture);

                        var party_ls = PartyLst.Where(p => p.ID.Equals(participant.Idref)).First();

                        string prifix = string.IsNullOrEmpty(party_ls.Person.Prefix) ? string.Empty : party_ls.Person.Prefix.Trim();
                        string firstName = string.IsNullOrEmpty(party_ls.Person.FirstName) ? string.Empty : party_ls.Person.FirstName.Trim();
                        string middleName = string.IsNullOrEmpty(party_ls.Person.MiddleName) ? string.Empty : party_ls.Person.MiddleName.Trim();
                        string lastName = string.IsNullOrEmpty(party_ls.Person.LastName) ? string.Empty : party_ls.Person.LastName.Trim();
                        if (!string.IsNullOrEmpty(prifix))
                        {
                            lastName = prifix + " " + lastName;
                        }
                        Ben_Name = format_String(lastName, firstName, middleName);
                        Ben_Gender = string.IsNullOrEmpty(party_ls.Person.Gender.Value) ? string.Empty : party_ls.Person.Gender.Value;

                        var relation_ls = RelationLst.Where(r => r.RelatedObjectID.Equals(participant.Idref)).First();
                        ben_Relation = string.IsNullOrEmpty(relation_ls.RelationRoleCode.Value) ? string.Empty : relation_ls.RelationRoleCode.Value;
                        var rel_arr = Regex.Split(ben_Relation, "_");
                        ben_Relation = rel_arr[2];

                        benefits.Add(new Benefits()
                        {
                            ben_Seq = ben_Seq,
                            ben_status = status,
                            ben_Cov_Code = Cov_Code,
                            ben_Cov_Name = Cov_Name,
                            ben_Issue_Date = issue_Date,
                            ben_Face_Amt = face_Amt,
                            ben_Mode_Prem = model_pre,
                            ben_Insured = Ben_Name,
                            ben_Relation = ben_Relation,
                            ben_Gender = Ben_Gender,
                            ben_Un_Class = under_Writing,
                            ben_Start_Date = start_Date,
                            ben_Stop_date = end_Date,
                            ben_Mode_Prem_child = model_pre
                        });
                    }
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "GetBenefitList", reqDetails, HttpContext.Current.User.Identity.Name);
            return benefits;
        }

        public List<Living_Benefits> GetLivingBenefitList(Response_Genr_203 response_212)
        {
            string Cov_Code;
            string Cov_Name;
            string ben_Seq;

            List<Living_Benefits> living_Benefits = new List<Living_Benefits>();

            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "GetLivingBenefitList" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            var hold_List_All = response_212.TXLifeResponse.OLifE.Holding.ToList();
            var hold_List = hold_List_All.Where(h => (!Regex.IsMatch(h.id, "Holding_Bank*")));
            var PartyLst = response_212.TXLifeResponse.OLifE.Party.ToList();
            var RelationLst = response_212.TXLifeResponse.OLifE.Relation.ToList();

            foreach (var hold in hold_List)
            {
                var life_list = hold.Policy.Life.ToList();
                foreach (var life in life_list)
                {
                    Cov_Code = string.IsNullOrEmpty(life.ShortName) ? string.Empty : life.ShortName.Trim();
                    Cov_Name = string.IsNullOrEmpty(life.PlanName) ? string.Empty : life.PlanName.Trim();

                    var participant_List_All = life.CovOption.Participant.ToList();
                    var participant_Lst = participant_List_All.Where(p => System.Convert.ToInt16(p.BeneficiarySeqNum) >= 1);
                    var living_Lst = participant_Lst.Where(l => l.ParticipantStatus.Value == "A");

                    foreach (var participant in living_Lst)
                    {
                        ben_Seq = string.IsNullOrEmpty(participant.BeneficiarySeqNum) ? string.Empty : participant.BeneficiarySeqNum;

                        living_Benefits.Add(new Living_Benefits()
                        {
                            sequence = ben_Seq,
                            coverage_Name = Cov_Name,
                            plan_Code = Cov_Code
                        });
                    }
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "GetLivingBenefitList", reqDetails, HttpContext.Current.User.Identity.Name);
            return living_Benefits;
        }

        public List<Agent> GetAgentList(Response_Genr_203 response_212)
        {
            List<Agent> agent = new List<Agent>();

            string agent_num;
            string agent_Status;
            string agent_Type;
            string agent_com_share;
            string agent_Name;
            string agent_add_Line;
            string agent_city;
            string agent_state;
            string agent_zip;
            string cel_phone;
            string tel_phone;

            var hold_List_All = response_212.TXLifeResponse.OLifE.Holding.ToList();
            var hold_List = hold_List_All.Where(h => (!Regex.IsMatch(h.id, "Holding_Bank*")));
            var PartyLst = response_212.TXLifeResponse.OLifE.Party.ToList();
            var RelationLst = response_212.TXLifeResponse.OLifE.Relation.ToList();
            // var relation_Agent = RelationLst.Where(r => (!Regex.IsMatch(r.RelationRoleCode.Value, "*AGENT")));
            var agent_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLAgentDetail.ToList();


            foreach (var relation in RelationLst)
            {

                if (relation.RelationRoleCode.Value.Contains("AGENT"))
                {
                    var party_relation_Data = PartyLst.Where(p => p.ID.Equals(relation.RelatedObjectID)).First();
                    string prifix = string.IsNullOrEmpty(party_relation_Data.Person.Prefix) ? string.Empty : party_relation_Data.Person.Prefix.Trim();
                    string firstName = string.IsNullOrEmpty(party_relation_Data.Person.FirstName) ? string.Empty : party_relation_Data.Person.FirstName.Trim();
                    string middleName = string.IsNullOrEmpty(party_relation_Data.Person.MiddleName) ? string.Empty : party_relation_Data.Person.MiddleName.Trim();
                    string lastName = string.IsNullOrEmpty(party_relation_Data.Person.LastName) ? string.Empty : party_relation_Data.Person.LastName.Trim();
                    if (!string.IsNullOrEmpty(prifix))
                    {
                        lastName = prifix + " " + lastName;
                    }
                    agent_Name = format_String(lastName, firstName, middleName);
                    agent_add_Line = string.IsNullOrEmpty(party_relation_Data.Address.Line1) ? string.Empty : party_relation_Data.Address.Line1;
                    agent_city = string.IsNullOrEmpty(party_relation_Data.Address.City) ? string.Empty : party_relation_Data.Address.City.Trim();
                    agent_state = string.IsNullOrEmpty(party_relation_Data.Address.AddressStateTC.Value) ? string.Empty : party_relation_Data.Address.AddressStateTC.Value.Trim();
                    agent_zip = string.IsNullOrEmpty(party_relation_Data.Address.Zip) ? string.Empty : party_relation_Data.Address.Zip.Trim();

                    var agent_data = agent_Lst.Where(a => a.ID.Equals(relation.RelatedObjectID)).First();
                    agent_num = string.IsNullOrEmpty(agent_data.EXLAgentNum) ? string.Empty : agent_data.EXLAgentNum.Trim();
                    agent_Type = string.IsNullOrEmpty(agent_data.EXLAgentType) ? string.Empty : agent_data.EXLAgentType.Trim();
                    agent_Status = string.IsNullOrEmpty(agent_data.EXLAgentStatusCode) ? string.Empty : agent_data.EXLAgentStatusCode.Trim();
                    agent_com_share = string.IsNullOrEmpty(agent_data.EXLAgentCommPercnt) ? string.Empty : agent_data.EXLAgentCommPercnt.Trim();
                    
                    var phone_Lst = party_relation_Data.Phone.ToList();
                    var cel_phone_No = phone_Lst.Where(p => p.PhoneTypeCode.tc.Equals("12")).First();
                    cel_phone = string.IsNullOrEmpty(cel_phone_No.PhoneTypeCode.Value) ? string.Empty : cel_phone_No.PhoneTypeCode.Value.Trim();
                    if (!string.IsNullOrEmpty(cel_phone) || cel_phone.Length > 9)
                    {
                        cel_phone = Format_Phone_Number(cel_phone);
                    }
                    var tel_phone_No = phone_Lst.Where(p => p.PhoneTypeCode.tc.Equals("26")).First();
                    tel_phone = string.IsNullOrEmpty(tel_phone_No.PhoneTypeCode.Value) ? string.Empty : tel_phone_No.PhoneTypeCode.Value.Trim();
                    if (!string.IsNullOrEmpty(tel_phone) || tel_phone.Length > 9)
                    {
                        tel_phone = Format_Phone_Number(tel_phone);
                    }
                    agent.Add(new Agent()
                    {
                        agent = agent_num,
                        type = agent_Type,
                        agent_name = agent_Name,
                        agent_status = agent_Status,
                        agent_com_share = agent_com_share + "%",
                        agent_Address = agent_add_Line,
                        agent_City = agent_city,
                        agent_State = agent_state,
                        agent_Zip = agent_zip,
                        agent_cell_Phone = cel_phone,
                        agent_Pri_Phone = tel_phone
                    });
                }


            }
            return agent;
        }

        public string Format_Phone_Number(string p_Number)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "Format_Phone_Number" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string first = p_Number.Insert(3, "-");
            string second = first.Insert(7, "-");
            string final = second;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "Format_Phone_Number", reqDetails, HttpContext.Current.User.Identity.Name);
            return final;
        }
        public string Format_Date(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetPolicyGeneral_203_BusinessLogic.cs" + "." + "Format_Date" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            string date_L= string.Empty;         
            var split_value = Regex.Split(date, "-");

                var yyyy = split_value[0];
                var mm = split_value[1];
                var dd = split_value[2];
                date_L = mm + "/" + dd + "/" + yyyy;
            
            
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicyGeneral_203_BusinessLogic.cs", "Format_Date", reqDetails, HttpContext.Current.User.Identity.Name);
            return date_L;
        }

        public string format_String(string first, string middle, string last)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetPolicy_302_BusinessLogic.cs" + "." + "format_String" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

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
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetPolicy_302_BusinessLogic.cs", "format_String", reqDetails, HttpContext.Current.User.Identity.Name);
            return full;
        }
    }
}
