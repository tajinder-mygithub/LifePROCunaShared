using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using ExlCSR.TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Request_BankInfo_3020B = ExlCSR.TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLife;
using Response_BankInfo_3020B = ExlCSR.TransactionsLibrary.BusinessSearch.Bank_Info.Response_BankInfo_3020B.TXLife;


namespace ExlCSR.BusinessLayer
{
    public class GetBankInfo_3020B_BusinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        public TransactionRequestDetails reqDetails;
        public Response_BankInfo_3020B txlife_Response = null;
        public string policyNumber = string.Empty;
        public string account_Type = string.Empty;
        public string aba_Number = string.Empty;
        public string bank_Name = string.Empty;
        public string account_Number = string.Empty;
        public string end_Date = string.Empty;
        public string company_Code = string.Empty;
        public string company_Name = string.Empty;
        public int counter = 0;
        List<BankInfoDetails> bank_List = null;
        private string name_ID;

        public GetBankInfo_3020B_BusinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            bank_List = new List<BankInfoDetails>();
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

        public async Task<List<BankInfoDetails>> Get_Response(string nameId)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBankInfo_3020B_BusinessLogic.cs" + "." + "Get_Response_BankInfo_3020B" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_BankInfo_3020B txlife = new Request_BankInfo_3020B();
            txlife.Version = "2.35.00";
            txlife.UserAuthRequest = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeUserAuthRequestVendorAppVendorName();
            txlife.UserAuthRequest.VendorApp.VendorName.VendorCode = 522;
            txlife.UserAuthRequest.VendorApp.VendorName.Value = "EXL";

            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "Ver 17.0";

            txlife.TXLifeRequest = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");
            txlife.TXLifeRequest.TransType = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "302";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_SRCHLD";
            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "3020B";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_EXL_BANK_DETAILS";

            txlife.TXLifeRequest.CriteriaExpression = new TransactionsLibrary.BusinessSearch.Bank_Info.Request_BankInfo_3020B.TXLifeTXLifeRequestCriteriaExpression();
            txlife.TXLifeRequest.CriteriaExpression.Criteria = InitializeArray<TXLifeTXLifeRequestCriteriaExpressionCriteria>(4);

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
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyName = "IDReferenceType";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[2].PropertyValue.Value = "OLI_IDREFTYPE_DIRECTORYID";


            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType = new TXLifeTXLifeRequestCriteriaExpressionCriteriaObjectType();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType.tc = "6";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].ObjectType.Value = "Party";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyName = "IDReferenceNo";
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyValue = new TXLifeTXLifeRequestCriteriaExpressionCriteriaPropertyValue();
            txlife.TXLifeRequest.CriteriaExpression.Criteria[3].PropertyValue.Value = nameId;
            txlife_Response = await Response_As_Object(txlife);
            if (txlife_Response != null)
            {
                bank_List = Fill_Model_values(txlife_Response);
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBankInfo_3020B_BusinessLogic.cs", "Get_Response_BankInfo_3020B", reqDetails, HttpContext.Current.User.Identity.Name);
            return bank_List;
        }

        public async Task<Response_BankInfo_3020B> Response_As_Object(Request_BankInfo_3020B request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBankInfo_3020B_BusinessLogic.cs" + "." + "Response_As_Object3020B" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_BankInfo_3020B response = new Response_BankInfo_3020B();
            String request_As_String = Common.GetXmlFromObject(request);
            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();            
            var bankTask = getpolicyservicerefrence.EXLServiceRequestAsync(request_As_String);
            string service_Response = await bankTask;
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
                    response = (Response_BankInfo_3020B)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBankInfo_3020B_BusinessLogic.cs", "Response_As_Object3020B", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }

        public List<BankInfoDetails> Fill_Model_values(Response_BankInfo_3020B response_3020B)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetBankInfo_3020B_BusinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            List<BankInfoDetails> bankInfo_List = new List<BankInfoDetails>();

            var holdingLst = response_3020B.TXLifeResponse.OLifE.Holding.ToList();
            var holdingLst_policy = holdingLst.Where(H => (Regex.IsMatch(H.id, "_Holding*")));
            var holdingLst_Bank = holdingLst.Where(H => (Regex.IsMatch(H.id, "Holding*")));

            var partyLst = response_3020B.TXLifeResponse.OLifE.Party.ToList();
            var relationLst = response_3020B.TXLifeResponse.OLifE.Relation.ToList();
            var oLifEExtension_Lst = response_3020B.TXLifeResponse.OLifE.OLifEExtension.ToList();
            int total_Company = relationLst.Where(R => (Regex.IsMatch(R.RelatedObjectID, "CC_*"))).Count();

            foreach (var hold in holdingLst_policy)
            {

                policyNumber = string.IsNullOrEmpty(hold.Policy.PolNumber) ? string.Empty : hold.Policy.PolNumber.Trim();

                var holding_Link = hold.FinancialActivity.Payment.ToList();

                foreach (var bankLink in holding_Link)
                {
                    var bank_detail = holdingLst_Bank.Where(B => B.id.Equals(bankLink.BankHoldingID)).First();
                    account_Type = string.IsNullOrEmpty(bank_detail.Banking.BankAcctType.Value) ? string.Empty : bank_detail.Banking.BankAcctType.Value.Trim();
                    if (account_Type.Equals("0"))
                    {
                        account_Type = string.Empty;
                    }
                    if (!string.IsNullOrEmpty(account_Type))
                    {
                        var split = Regex.Split(account_Type, "_");
                        account_Type = split[3];
                    }
                    account_Number = string.IsNullOrEmpty(bank_detail.Banking.AccountNumber) ? string.Empty : bank_detail.Banking.AccountNumber.Trim();

                    if (account_Number.Equals("0"))
                    {
                        account_Number = string.Empty;
                    }
                    else
                    {
                        string star = "";
                        int lenght = account_Number.Length;
                        if (lenght > 4)
                        {
                            for (int i = 0; i <= lenght - 5; i++)
                            {
                                star += "*";
                            }
                            account_Number = star + account_Number.Substring(lenght - 4);
                        }

                    }

                    aba_Number = string.IsNullOrEmpty(bank_detail.Banking.RoutingNum) ? string.Empty : bank_detail.Banking.RoutingNum.Trim();
                    if (aba_Number.Equals("0")) aba_Number = string.Empty;
                    bank_Name = string.IsNullOrEmpty(bank_detail.Banking.BankName) ? string.Empty : bank_detail.Banking.BankName.Trim();

                    var relationList_Details = relationLst.Where(R => R.OriginatingObjectID == hold.id);
                    var relationship_Name_ID = relationList_Details.Where(R => (!Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                    var Party_Name_Id = partyLst.Where(P => P.ID == relationship_Name_ID.RelatedObjectID).First();
                    name_ID = Party_Name_Id.IDReferenceNo;
                    counter++;
                    if (counter == total_Company)
                    {

                        var relationship_Org = relationList_Details.Where(R => (Regex.IsMatch(R.RelatedObjectID, "CC_*"))).First();
                        var Party = partyLst.Where(P => P.ID == relationship_Org.RelatedObjectID).First();
                        company_Name = string.IsNullOrEmpty(Party.FullName) ? string.Empty : Party.FullName.Trim();
                        company_Code = string.IsNullOrEmpty(Party.Carrier.CarrierCode) ? string.Empty : Party.Carrier.CarrierCode.Trim();
                    }
                    foreach (var OLifEExtension in oLifEExtension_Lst)
                    {
                        var endDateList = OLifEExtension.EXLendDate.ToList();
                        var end_Date_details = endDateList.Where(Ed => Ed.HoldingID.Equals(hold.id)).First();
                        end_Date = end_Date_details.Value;

                        if (end_Date.Equals("0") || string.IsNullOrEmpty(end_Date))
                        {
                            end_Date = "0000-00-00";
                        }

                        if (!end_Date.Equals(string.Empty))
                        {
                            var split = Regex.Split(end_Date, "-");
                            var yyyy = split[0];
                            var mm = split[1];
                            var dd = split[2];
                            end_Date = mm + "/" + dd + "/" + yyyy;
                        }

                        bankInfo_List.Add(new BankInfoDetails()
                        {
                            company_Code = company_Code,
                            company_Name = company_Name,
                            policy_Number = policyNumber,
                            account_Type = account_Type,
                            account_Number = account_Number,
                            aba_Number = aba_Number,
                            bank_Name = bank_Name,
                            end_Date = end_Date,
                            name_id = name_ID
                        });
                    }
                }
            }
            counter = 0;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBankInfo_3020B_BusinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return bankInfo_List;
        }

    }
}
