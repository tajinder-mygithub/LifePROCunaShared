using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Request_Address_204 = ExlCSR.TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLife;
using Response_Address_204 = ExlCSR.TransactionsLibrary.BusinessSearch.Address.Response_Address_204.TXLife;

namespace ExlCSR.BusinessLayer
{
    public class GetAddress_204_BusinessLogic
    {

        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private Response_Address_204 txlife_Response = null;
        private List<Additional_addresses> address_List = null;
        private string end_Date = string.Empty;
        private string start_Date = string.Empty;
        private string address_Code = string.Empty;
        private string addr_Type = string.Empty;
        private string line1 = string.Empty;
        private string city = string.Empty;
        private string state = string.Empty;
        private string zip = string.Empty;
        private string phone_Number = string.Empty;
        private string bad_Address = string.Empty;

        public GetAddress_204_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            address_List = new List<Additional_addresses>();
        }
        

        public async Task<List<Additional_addresses>> Get_Response(string nameId)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetAddress_204_BusinessLogic.cs" + "." + "Get_Response204" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_Address_204 txlife = new Request_Address_204();
            txlife.TXLifeRequest = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");


            txlife.TXLifeRequest.TransType = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "204";


            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.TC = "20400";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestOLifE();

            txlife.TXLifeRequest.OLifE.Party = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestOLifEParty();
            txlife.TXLifeRequest.OLifE.Party.ID = nameId;

            txlife.TXLifeRequest.OLifE.Party.PartyTypeCode = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestOLifEPartyPartyTypeCode();
            txlife.TXLifeRequest.OLifE.Party.PartyTypeCode.tc = "0";
            txlife.TXLifeRequest.OLifE.Party.PartyTypeCode.Value = "Unknown";

            txlife.TXLifeRequest.OLifE.Party.IDReferenceType = new TransactionsLibrary.BusinessSearch.Address.Request_Address_204.TXLifeTXLifeRequestOLifEPartyIDReferenceType();
            txlife.TXLifeRequest.OLifE.Party.IDReferenceType.tc = "35";
            txlife.TXLifeRequest.OLifE.Party.IDReferenceType.Value = "OLI_IDREFTYPE_CUSTNUM";

            txlife.TXLifeRequest.OLifE.Party.IDReferenceNo = nameId;

            txlife_Response = await Response_As_Object(txlife);
            if (txlife_Response != null)
            {
                address_List = Fill_Model_values(txlife_Response);
            }
            
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetAddress_204_BusinessLogic.cs", "Get_Response204", reqDetails, HttpContext.Current.User.Identity.Name);
            return address_List;
        }

        public async Task<Response_Address_204> Response_As_Object(Request_Address_204 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetAddress_204_BusinessLogic.cs" + "." + "Response_As_Object204" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Address_204 response = new Response_Address_204();
            String request_As_String = Common.GetXmlFromObject(request);

            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            var task1 = getpolicyservicerefrence.EXLServiceRequestAsync(request_As_String);
            string service_Response = await task1;
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
                    response = (Response_Address_204)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetAddress_204_BusinessLogic.cs", "Response_As_Object204", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        public List<Additional_addresses> Fill_Model_values(Response_Address_204 response_204)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetAddress_204_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            List<Additional_addresses> additional_Address_List = new List<Additional_addresses>();
            var address_List = response_204.TXLifeResponse.OLifE.Party.Address.ToList();
            var phone_List = response_204.TXLifeResponse.OLifE.Party.Phone.ToList();
            var address_Bad_Indicator = response_204.TXLifeResponse.OLifE.Party.OLifEExtension.EXLAddData.ToList();



            foreach (var item in address_List)
            {
                var phone_Number_Details = phone_List.Where(P => P.id == item.ID).First();
                var bad_Indicator_Details = address_Bad_Indicator.Where(A => A.AddID == item.ID).First();


                end_Date = string.IsNullOrEmpty(item.EndDate) ? string.Empty : item.EndDate.Trim();
                if (end_Date.Equals("0"))
                {
                    end_Date = "0000/00/00";
                }
                if (!end_Date.Equals(string.Empty))
                {
                    end_Date = Format_Date(end_Date);
                }


                start_Date = string.IsNullOrEmpty(item.StartDate) ? string.Empty : item.StartDate.Trim();
                if (start_Date.Equals("0"))
                {
                    start_Date = "0000/00/00";
                }
                if (!start_Date.Equals(string.Empty))
                {
                    start_Date = Format_Date(start_Date);
                }


                line1 = string.IsNullOrEmpty(item.Line1) ? string.Empty : item.Line1.Trim();
                city = string.IsNullOrEmpty(item.City) ? string.Empty : item.City.Trim();
                state = string.IsNullOrEmpty(item.AddressStateTC.Value) ? string.Empty : item.AddressStateTC.Value.Trim();
                if(!state.Equals(""))
                {
                    var state_Split = Regex.Split(state, "_");
                    state = state_Split[2];
                }                
                zip = string.IsNullOrEmpty(item.Zip) ? string.Empty : item.Zip.Trim();

                addr_Type = string.IsNullOrEmpty(item.AddressTypeCode.Value) ? string.Empty : item.AddressTypeCode.Value.Trim();
                if (addr_Type.Equals("0"))
                {
                    addr_Type = string.Empty;
                }
                if (!addr_Type.Equals(string.Empty))
                {
                    var address_Type_Split = Regex.Split(addr_Type, "_");
                    addr_Type = address_Type_Split[3];
                }

                address_Code = string.IsNullOrEmpty(bad_Indicator_Details.EXLAddressCode) ? string.Empty : bad_Indicator_Details.EXLAddressCode.Trim();
                if (address_Code.Equals("")) address_Code = "DEFAULT";

                string p_Number = string.IsNullOrEmpty(phone_Number_Details.PhoneValue) ? string.Empty : phone_Number_Details.PhoneValue.Trim();
                if (p_Number.Equals("0"))
                {
                    phone_Number = string.Empty;
                }
                if (!string.IsNullOrEmpty(p_Number) || p_Number.Length > 9)
                {
                    phone_Number = Format_Phone_Number(p_Number);
                }
                else
                {
                    phone_Number = p_Number;
                }

                bad_Address = string.IsNullOrEmpty(bad_Indicator_Details.EXLBadIndicator) ? string.Empty : bad_Indicator_Details.EXLBadIndicator.Trim();


                additional_Address_List.Add(new Additional_addresses()
                {
                    effective_Date = start_Date,
                    cancel_Date = end_Date,
                    addr_Code = address_Code,
                    addr_Type = addr_Type,
                    address = line1,
                    city = city,
                    state = state,
                    zip = zip,
                    phone_Number = phone_Number,
                    bad_Address = bad_Address
                });
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetAddress_204_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return additional_Address_List;
        }

        public string Format_Phone_Number(string p_Number)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetAddress_204_BusinessLogic.cs" + "." + "Format_Phone_Number" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            
            string first = p_Number.Insert(3, "-");
            string second = first.Insert(7, "-");
            string final = second;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetAddress_204_BusinessLogic.cs", "Format_Phone_Number", reqDetails, HttpContext.Current.User.Identity.Name);
            return final;
        }

        public string Format_Date(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetAddress_204_BusinessLogic.cs" + "." + "Format_Date" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            
            var yyyy = date.Substring(0, 4);
            var mm = date.Substring(5, 2);
            var dd = date.Substring(8, 2);
            string date_L = mm + "/" + dd + "/" + yyyy;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetAddress_204_BusinessLogic.cs", "Format_Date", reqDetails, HttpContext.Current.User.Identity.Name);
            return date_L;
        }
    }
}
