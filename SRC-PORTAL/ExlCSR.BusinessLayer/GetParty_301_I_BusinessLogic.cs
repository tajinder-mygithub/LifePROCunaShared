using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using ExlCSR.TransactionsLibrary.BusinessSearch.Request_301;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using Request_301 = ExlCSR.TransactionsLibrary.BusinessSearch.Request_301.TXLife;
using Response_I_301 = ExlCSR.TransactionsLibrary.BusinessSearch.Response_I_301.TXLife;

namespace ExlCSR.BusinessLayer
{
    public class GetParty_301_I_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private Response_I_301 txlife_Response = null;
        private List<Person> person_Data_Saved = new List<Person>();
        PersonSearchByPerson_SSNViewModel personSearchByPerson_Ssn = null;
        private List<Person> person_List = null;
        private string fullname = string.Empty;
        private string line1 = string.Empty;
        private string state = string.Empty;
        private string zip = string.Empty;
        private string address = string.Empty;
        private string nameId = string.Empty;
        private string dob = string.Empty;
        private string gender = string.Empty;
        private string govtId = string.Empty;
        DateTime effectiveDate = DateTime.MinValue;
        private string genderform;


        public GetParty_301_I_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            personSearchByPerson_Ssn = new PersonSearchByPerson_SSNViewModel();
            person_List = new List<Person>();
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

        public List<Person> Get_Response(PersonSearch search)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetParty_301_I_BusinessLogic.cs" + "." + "Get_Response_I_302" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_301 txlife = new Request_301();
            txlife.Version = "2.35.00";
            txlife.UserAuthRequest = new TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = new TXLifeUserAuthRequestVendorAppVendorName();
            txlife.UserAuthRequest.VendorApp.VendorName.VendorCode = 522;
            txlife.UserAuthRequest.VendorApp.VendorName.Value = "EXL";

            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "Ver 17.0";

            txlife.TXLifeRequest = new TransactionsLibrary.BusinessSearch.Request_301.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");
            txlife.TXLifeRequest.TransType = new TransactionsLibrary.BusinessSearch.Request_301.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "301";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_SRCHLD";
            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.BusinessSearch.Request_301.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "30200";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_TRANSSUB_SRCHLD";

            txlife.TXLifeRequest.CriteriaExpression = new TransactionsLibrary.BusinessSearch.Request_301.TXLifeTXLifeRequestCriteriaExpression();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteriaExpression>(2);

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteria>(9);


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].PropertyName = "FirstName";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            if (string.IsNullOrEmpty(search.firstName))
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].PropertyValue.Value = search.firstName;
            }
            else
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[0].PropertyValue.Value = search.firstName.ToUpper();
            }            

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].PropertyName = "MiddleName";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[1].PropertyValue.Value = string.Empty;


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].PropertyName = "LastName";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            if (string.IsNullOrEmpty(search.lastName))
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].PropertyValue.Value = search.lastName;
            }
            else
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[2].PropertyValue.Value = search.lastName.ToUpper();
            }            

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyName = "Gender";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            genderform = string.IsNullOrEmpty(search.gender)? string.Empty : search.gender.Substring(0,1);
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyValue.tcSpecified = true;
            if (genderform.Equals("M"))
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyValue.tc = "1";
            }
            if (genderform.Equals("F"))
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyValue.tc = "2";
            }  

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[3].PropertyValue.Value = genderform;
                     

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].PropertyName = "BirthDate";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();

            if (!string.IsNullOrEmpty(search.dob))
            {
                effectiveDate = DateTime.Parse(search.dob);
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].PropertyValue.Value = effectiveDate.ToString("yyyy-MM-dd");
            }
            else
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[4].PropertyValue.Value =  search.dob;
            }

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].PropertyName = "GovtIDTC";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[5].PropertyValue.Value = "OLI_GOVTID_SSN";


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].PropertyName = "GovtID";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[6].PropertyValue.Value = search.ssn;

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].ObjectType.tc = "2";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].ObjectType.Value = "ADDRESS";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].PropertyName = "Zip";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[7].PropertyValue.Value = search.zip;

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].ObjectType.tc = "2";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].ObjectType.Value = "ADDRESS";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].PropertyName = "AddressStateTC";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            if(string.IsNullOrEmpty(search.residentState))
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].PropertyValue.Value = search.residentState;
            }else
            {
                txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[0].Criteria[8].PropertyValue.Value = search.residentState.ToUpper();
            }
            


            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteria>(4);

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].ObjectType.tc = "115";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].ObjectType.Value = "Person";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].PropertyName = "FullName";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[0].PropertyValue.Value = String.Empty;

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].PropertyName = "GovtIDTC";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[1].PropertyValue.Value = "OLI_GOVTID_SSN";

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].PropertyName = "GovtID";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[2].PropertyValue.Value = String.Empty;

            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].ObjectType.tc = "2";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].ObjectType.Value = "ADDRESS";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].PropertyName = "Zip";
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.CriteriaExpression[1].Criteria[3].PropertyValue.Value = string.Empty;


            txlife_Response = Response_As_Object(txlife);
            if (txlife_Response != null)
            {
                person_List = Fill_Model_values(txlife_Response);

            }
            else
            {
                person_List = null;
            }
            
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetParty_301_I_BusinessLogic.cs", "Get_Response_I_302", reqDetails, HttpContext.Current.User.Identity.Name);
            return person_List;
        }

        public Response_I_301 Response_As_Object(Request_301 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetParty_301_I_BusinessLogic.cs" + "." + "Response_As_Object301_I" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_I_301 response = new Response_I_301();
            String request_As_String = Common.GetXmlFromObject(request);
            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            //GetPolicyServiceRefrence.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence.ExlLifePROServiceClient();
            string service_Response = getpolicyservicerefrence.EXLServiceRequest(request_As_String);
            bool IS_RESPONSE_FAIL = service_Response.Contains("RESULT_FAILURE");
            if (IS_RESPONSE_FAIL)
            {
                response = null;
            }
            else
            {
                if (service_Response.Contains("Person"))
                {
                    Type type = response.GetType();
                    response = (Response_I_301)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetParty_301_I_BusinessLogic.cs", "Response_As_Object301_I", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }

        public List<Person> Fill_Model_values(Response_I_301 response_301)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetParty_301_I_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            var partyLst = response_301.TXLifeResponse.OLifE.Party.ToList();
            List<Person> personLst = new List<Person>();

            foreach (var party in partyLst)
            {
                if (string.IsNullOrEmpty(party.FullName))
                {
                    nameId = string.IsNullOrEmpty(party.ID) ? string.Empty : party.ID;
                    string prifix = string.IsNullOrEmpty(party.Person.Prefix)? string.Empty : party.Person.Prefix.Trim();
                    string firstname = string.IsNullOrEmpty(party.Person.FirstName) ? string.Empty : party.Person.FirstName.Trim();
                    string middlename = string.IsNullOrEmpty(party.Person.MiddleName) ? string.Empty : party.Person.MiddleName.Trim();
                    string lastname = string.IsNullOrEmpty(party.Person.LastName) ? string.Empty : party.Person.LastName.Trim();
                    if (!string.IsNullOrEmpty(prifix))
                    {
                        lastname = prifix + " " + lastname;
                    }
                    fullname = format_String(lastname, firstname, middlename);
                    dob = string.IsNullOrEmpty(party.Person.BirthDate) ? string.Empty : party.Person.BirthDate.Trim();
                    if (dob.Equals("0"))
                    {
                        dob = string.Empty;
                    }
                    if (!string.IsNullOrEmpty(dob))
                    {
                        var dateofbirth = Regex.Split(dob, "-");
                        var yyyy = dateofbirth[0];
                        var mm = dateofbirth[1];
                        var dd = dateofbirth[2];
                        dob = mm + "/" + dd + "/" + yyyy;
                    }

                    gender = string.IsNullOrEmpty(party.Person.Gender.Value) ? string.Empty : party.Person.Gender.Value.Trim();

                    line1 = string.IsNullOrEmpty(party.Address.Line1) ? string.Empty : party.Address.Line1.Trim();
                    state = string.IsNullOrEmpty(party.Address.AddressStateTC.Value) ? string.Empty : party.Address.AddressStateTC.Value.Trim();
                    if (state.Equals("0")) state = string.Empty;
                    if (!string.IsNullOrEmpty(state))
                    {
                        state = state.Substring(state.LastIndexOf("_") + 1);
                    }

                    zip = string.IsNullOrEmpty(party.Address.Zip) ? string.Empty : party.Address.Zip.Trim();
                    if (zip.Equals("0")) zip = string.Empty;

                    if (string.IsNullOrEmpty(line1))
                    {
                        if (string.IsNullOrEmpty(state))
                        {
                            if (string.IsNullOrEmpty(zip))
                            {
                                address = string.Empty;
                            }
                            else
                            {
                                address = zip;
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(zip))
                            {
                                address = state;
                            }
                            else
                            {
                                address = state + "," + zip;
                            }
                        }
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(state))
                        {
                            if (string.IsNullOrEmpty(zip))
                            {
                                address = line1;
                            }
                            else
                            {
                                address = line1 + "," + zip;
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(zip))
                            {
                                address = line1 + "," + state;
                            }
                            else
                            {
                                address = line1 + "," + state + "," + zip;
                            }
                        }
                    }

                    govtId = string.IsNullOrEmpty(party.GovtID) ? string.Empty : party.GovtID;
                    if (govtId.Equals("0"))
                    {
                        govtId = string.Empty;
                    }
                    else
                    {
                        govtId = "*****" + govtId.Substring(5);
                    }
                }
                else
                {
                    nameId = string.IsNullOrEmpty(party.ID) ? string.Empty : party.ID;                    
                    fullname = string.IsNullOrEmpty(party.FullName) ? string.Empty : party.FullName.Trim();
                    line1 = string.IsNullOrEmpty(party.Address.Line1) ? string.Empty : party.Address.Line1.Trim();
                    state = string.IsNullOrEmpty(party.Address.AddressStateTC.Value) ? string.Empty : party.Address.AddressStateTC.Value.Trim();
                    if (state.Equals("0")) state = string.Empty;
                    if (!string.IsNullOrEmpty(state))
                    {
                        var State_split = Regex.Split(state, "_");
                        state = State_split[2];
                    }

                    zip = string.IsNullOrEmpty(party.Address.Zip) ? string.Empty : party.Address.Zip.Trim();
                    if (zip.Equals("0")) zip = string.Empty;

                    if (string.IsNullOrEmpty(line1))
                    {
                        address = state + "," + zip;
                    }
                    if (string.IsNullOrEmpty(state))
                    {
                        address = line1 + "," + zip;
                    }
                    if (string.IsNullOrEmpty(zip))
                    {
                        address = line1 + "," + state;
                    }
                    if (string.IsNullOrEmpty(line1) && string.IsNullOrEmpty(state) && string.IsNullOrEmpty(zip))
                    {
                        address = string.Empty;
                    }
                    govtId = string.IsNullOrEmpty(party.GovtID) ? string.Empty : party.GovtID;
                    if (govtId.Equals("0"))
                    {
                        govtId = string.Empty;
                    }
                    else
                    {
                        govtId = "*****" + govtId.Substring(5);
                    }
                }
                personLst.Add(new Person
                {
                    nameId = nameId,
                    ownerName = fullname,
                    dob = dob,
                    gender = gender,
                    ssn = govtId,
                    address = address
                });
            }
            
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetParty_301_I_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);

            return personLst;
        }

        public string format_String(string first, string middle, string last)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetParty_301_I_BusinessLogic.cs" + "." + "format_String" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

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
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetParty_301_I_BusinessLogic.cs", "format_String", reqDetails, HttpContext.Current.User.Identity.Name);
            return full;
        }
              
    }
}
