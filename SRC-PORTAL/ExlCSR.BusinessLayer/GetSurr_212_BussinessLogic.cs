using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using Logging;
using Logging.Contract;
using System;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using Request_Surr_212 = ExlCSR.TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLife;
using Response_Surr_212 = ExlCSR.TransactionsLibrary.PolicySummary.ResponseSurrenderQuoteDetails.TXLife;

namespace ExlCSR.BusinessLayer
{
    public class GetSurr_212_BussinessLogic
    {
        private ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private SurrenderQuoteData surrenderQuoteData = null;
        private Response_Surr_212 txlife_Response = null;
        private string transType = string.Empty;
        private string transSubType = string.Empty;
        private double fundCurrentRate;
        private double fundValue;
        private double freeWithdrawl;
        private string surrCharge;
        private string surrValue;
        private double EXLMVAamount;
        private double MVAamount;
        private double cashValue;
        private string efficetive_date;

        public GetSurr_212_BussinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            surrenderQuoteData = new SurrenderQuoteData();
        }

        public async Task<SurrenderQuoteData> Get_Response(SurrenderQuote surr)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetSurr_212_BussinessLogic.cs" + "." + "Get_Response212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            Request_Surr_212 txlife = new Request_Surr_212();
            txlife.UserAuthRequest = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeUserAuthRequestVendorAppVendorName();
            txlife.UserAuthRequest.VendorApp.VendorName.Value = "EXL";
            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "V19";
            txlife.TXLifeRequest = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");
            txlife.TXLifeRequest.TransType = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "212";

            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "21202";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestOLifE();
            txlife.TXLifeRequest.OLifE.Holding = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestOLifEHolding();
            txlife.TXLifeRequest.OLifE.Holding.Policy = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestOLifEHoldingPolicy();

            txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode = string.IsNullOrEmpty(surr.company_code) ? string.Empty : surr.company_code;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber = string.IsNullOrEmpty(surr.policy_number) ? string.Empty : surr.policy_number;
            txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate = string.IsNullOrEmpty(surr.effictive_Date) ? string.Empty : surr.effictive_Date;
            
            txlife.TXLifeRequest.OLifEExtension = new TransactionsLibrary.PolicySummary.RequestSurrenderQuoteDetails.TXLifeTXLifeRequestOLifEExtension();
            txlife.TXLifeRequest.OLifEExtension.VendorCode = 522;
            txlife.TXLifeRequest.OLifEExtension.EXLLoanQuoteFlag = "Yes";
            txlife.TXLifeRequest.OLifEExtension.EXLETIQuoteFlag = "Yes";
            txlife.TXLifeRequest.OLifEExtension.EXLRPUQuoteFlag = "Yes";

            txlife_Response = await Response_As_Object(txlife);

            
            if (txlife_Response != null)
            {
                surrenderQuoteData = Fill_Model_values(txlife_Response, txlife);
            }
            else
            {
                surrenderQuoteData.company_code = string.IsNullOrEmpty(txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode) ? string.Empty : txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode;
                surrenderQuoteData.policy_number = string.IsNullOrEmpty(txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber) ? string.Empty : txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber;
                efficetive_date = string.IsNullOrEmpty(txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate) ? string.Empty : txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate;
                surrenderQuoteData.effictive_Date = Format_Date(efficetive_date);
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetSurr_212_BussinessLogic.cs", "Get_Response212", reqDetails, HttpContext.Current.User.Identity.Name);
            return surrenderQuoteData;
        }

        public async Task<Response_Surr_212> Response_As_Object(Request_Surr_212 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetSurr_212_BussinessLogic.cs" + "." + "Response_As_Object212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Surr_212 response = new Response_Surr_212();
            String request_As_String = Common.GetXmlFromObject(request);

            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            var responseTask = getpolicyservicerefrence.EXLServiceRequestAsync(request_As_String);
            string service_Response = await responseTask;
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
                    response = (Response_Surr_212)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetSurr_212_BussinessLogic.cs", "Response_As_Object212", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }

        public SurrenderQuoteData Fill_Model_values(Response_Surr_212 response_212, Request_Surr_212 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetSurr_212_BussinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);            
            surrenderQuoteData.company_code = string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.CarrierCode) ? string.Empty : req.TXLifeRequest.OLifE.Holding.Policy.CarrierCode;
            surrenderQuoteData.policy_number = string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.PolNumber) ? string.Empty : req.TXLifeRequest.OLifE.Holding.Policy.PolNumber;
            efficetive_date = string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.EffDate) ? string.Empty : req.TXLifeRequest.OLifE.Holding.Policy.EffDate;
            surrenderQuoteData.effictive_Date = Format_Date(efficetive_date);

            surrenderQuoteData.quotedAsOf = string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.EffDate) ? string.Empty : req.TXLifeRequest.OLifE.Holding.Policy.EffDate;
            
            surrCharge = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.Life.Coverage.SurrCharge)? string.Empty :response_212.TXLifeResponse.OLifE.Holding.Policy.Life.Coverage.SurrCharge;
            if (!string.IsNullOrEmpty(surrCharge)) surrenderQuoteData.surr_Charge = System.Convert.ToDouble(surrCharge).ToString("C", CultureInfo.CurrentCulture);

            surrValue = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.Life.Coverage.SurrChargeAmt) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.Life.Coverage.SurrChargeAmt;
            
            if (!string.IsNullOrEmpty(surrValue))
            {
                surrenderQuoteData.surr_Value = System.Convert.ToDouble(surrValue).ToString("C", CultureInfo.CurrentCulture);
                surrenderQuoteData.totalSurrAmt = System.Convert.ToDouble(surrValue).ToString("C", CultureInfo.CurrentCulture);
            }

            if (response_212.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetail != null)
            {
                var sourcedetail = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetail.ToList();
                foreach (var source in sourcedetail)
                {
                    if (source.EXLFundCurrRate != 0)
                    {
                        fundCurrentRate = source.EXLFundCurrRate;
                    }
                    else
                    {
                        fundCurrentRate = 0;
                    }
                    surrenderQuoteData.interest_Rate = fundCurrentRate + "%";

                    if (source.EXLFundValue != 0)
                    {
                        fundValue = source.EXLFundValue;
                    }
                    else
                    {
                        fundValue = 0;
                    }
                    surrenderQuoteData.accum_Value = System.Convert.ToDouble(fundValue).ToString("C", CultureInfo.CurrentCulture);

                    if (source.EXLFundFreeWithd != 0)
                    {
                        freeWithdrawl = source.EXLFundFreeWithd;
                    }
                    else
                    {
                        freeWithdrawl = 0;
                    }
                    surrenderQuoteData.total_Free = System.Convert.ToDouble(freeWithdrawl).ToString("C", CultureInfo.CurrentCulture);
                    if (source.EXLFundMVA != 0)
                    {
                        EXLMVAamount = source.EXLFundMVA;
                    }
                    else
                    {
                        EXLMVAamount = 0;
                    }
                    surrenderQuoteData.Adjustments = System.Convert.ToDouble(MVAamount).ToString("C", CultureInfo.CurrentCulture);

                    surrenderQuoteData.Withdrawals = "$0.00";//tag not available
                    surrenderQuoteData.prem_Paid = "$0.00";//tag not available
                }
            }
            else
            {
                surrenderQuoteData.interest_Rate = "0%";
                surrenderQuoteData.accum_Value = "$0";
                surrenderQuoteData.total_Free = "$0";
                surrenderQuoteData.Adjustments = "$0";
                surrenderQuoteData.Withdrawals = "$0.0";//tag not available
                surrenderQuoteData.prem_Paid = "$0.0";//tag not available

            }


            if (response_212.TXLifeResponse.OLifE.OLifEExtension.EXLMVA != 0)
            {
                MVAamount = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLMVA;
            }
            else
            {
                MVAamount = 0;
            }

            surrenderQuoteData.MVA_Amount = string.IsNullOrEmpty(System.Convert.ToString(MVAamount)) ? "$0.00" : MVAamount.ToString("C", CultureInfo.CurrentCulture);

            if (response_212.TXLifeResponse.OLifE.OLifEExtension.EXLCashValue != 0)
            {
                cashValue = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLCashValue;
            }
            else
            {
                cashValue = 0;
            }

            surrenderQuoteData.cashValue = string.IsNullOrEmpty(System.Convert.ToString(cashValue)) ? "$0.00" : cashValue.ToString("C", CultureInfo.CurrentCulture);


            surrenderQuoteData.dividend_Acc = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDividendAcc)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDividendAcc.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.dividend_Adj = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDividendAdj)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDividendAdj.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.cashValue_PUA = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.Life.TotalPUA) ? "$0.00" : System.Convert.ToDouble(response_212.TXLifeResponse.OLifE.Holding.Policy.Life.TotalPUA).ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.cashValue_OYT = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLCashValueOYT)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLCashValueOYT.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.unapplied_Cash = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLUnappCash)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLUnappCash.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.IBAType_01 = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLIBAVal01)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLIBAVal01.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.IBAType_02 = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLIBAVal02)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLIBAVal02.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.unprocessed_Premium = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLUnprocessPrem)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLUnprocessPrem.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.federal_Withholding = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLFedralWithHolding)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLFedralWithHolding.ToString("C", CultureInfo.CurrentCulture);
            surrenderQuoteData.state_Withholding = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLStateWithHolding)) ? "$0.00" : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLStateWithHolding.ToString("C", CultureInfo.CurrentCulture);
            //surrenderQuoteData.totalSurrAmt = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLNetFundValue)) ? "$0.00" : System.Convert.ToString("$" + response_212.TXLifeResponse.OLifE.OLifEExtension.EXLNetFundValue);//tag not available            
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetSurr_212_BussinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return surrenderQuoteData;
        }

        public string Format_Date(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetSurr_212_BussinessLogic.cs" + "." + "Format_Date" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            var split_value = Regex.Split(date, "-");

            var yyyy = split_value[0];
            var mm = split_value[1];
            var dd = split_value[2];
            string date_L = mm + "/" + dd + "/" + yyyy;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetSurr_212_BussinessLogic.cs", "Format_Date", reqDetails, HttpContext.Current.User.Identity.Name);
            return date_L;
        }


    }
}
