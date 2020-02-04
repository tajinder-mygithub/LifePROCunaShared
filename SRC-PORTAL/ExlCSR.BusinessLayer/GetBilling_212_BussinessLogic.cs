using ExlCSR.BusinessLayer.Proxy;
using ExlCSR.ModelLayer;
using Logging;
using Logging.Contract;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web;
using Request_Billing_212 = ExlCSR.TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLife;
using Response_Billing_212 = ExlCSR.TransactionsLibrary.PolicySummary.ResponsePremiumQuoteDetails.TXLife;
using System.Text.RegularExpressions;
using System.Globalization;

namespace ExlCSR.BusinessLayer
{
    public class GetBilling_212_BussinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails;
        private PremiumQuoteBilling premiumQuoteBilling = null;
        private Response_Billing_212 txlife_Response = null;
        List<SelectListItem> mode_PremiumBilling = null;
        List<SelectListItem> form_PremiumBilling = null;
        private string mode_val = string.Empty;
        private string form_val = string.Empty;
        private string billed_to_date = string.Empty;
        private string paid_to_date = string.Empty;
        private string transType = string.Empty;
        private string transSubType = string.Empty;
        private string current_Mode_Premium;
        private string policy_Fee;
        private string annual_Policy_Fee;
        private double annual_Amount;
        private double semi_Annual_Amount;
        private double quaterly_Amount;
        private double monthly_Amount;
        private double ninthly_Amount;
        private double tenthly_Amount;
        private double thirteenthly_Amount;
        private double weekly_Amount;
        private double bi_Weekly_Amount;
        private double pay_26_Amount;
        private double pay_52_Amount;
        private double calander_Amount;


        public GetBilling_212_BussinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            mode_PremiumBilling = new List<SelectListItem>();
            form_PremiumBilling = new List<SelectListItem>();
        }

        public async Task<PremiumQuoteBilling> Get_Response(Billing bill)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "Get_Response212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_Billing_212 txlife = new Request_Billing_212();

            txlife.UserAuthRequest = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = "EXL";
            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "V19";

            txlife.TXLifeRequest = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");

            txlife.TXLifeRequest.TransType = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "212";

            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "21200P";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifE();
            txlife.TXLifeRequest.OLifE.Holding = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEHolding();
            txlife.TXLifeRequest.OLifE.Holding.Policy = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEHoldingPolicy();

            txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode = bill.company_code;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber = bill.policy_number;
            txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate = bill.effictive_Date;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PaymentMode = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEHoldingPolicyPaymentMode();
            txlife.TXLifeRequest.OLifE.Holding.Policy.PaymentMode.tc = System.Convert.ToString(bill.requested_Mode);

            txlife.TXLifeRequest.OLifE.Holding.Policy.PaymentMethod = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEHoldingPolicyPaymentMethod();
            txlife.TXLifeRequest.OLifE.Holding.Policy.PaymentMethod.tc = System.Convert.ToString(bill.requested_Form);
            txlife.TXLifeRequest.OLifE.Holding.Policy.Coverage = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEHoldingPolicyCoverage();
            txlife.TXLifeRequest.OLifE.Holding.Policy.Coverage.ModalPremAmt = bill.mode_Prem.Substring(1);            
            txlife.TXLifeRequest.OLifE.OLifEExtension = new TransactionsLibrary.PolicySummary.RequestPremiumQuoteDetails.TXLifeTXLifeRequestOLifEOLifEExtension();
            txlife.TXLifeRequest.OLifE.OLifEExtension.EXLpaymentModeFlag = bill.payment_Mode_Flag;
            txlife.TXLifeRequest.OLifE.OLifEExtension.EXLQuoteFunction = "N";

            txlife_Response = await Response_As_Object(txlife);

            if (txlife_Response != null)
            {
                premiumQuoteBilling = Fill_Model_values(txlife_Response, txlife);
            }
            else
            {
                premiumQuoteBilling = null;
            }

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Get_Response212", reqDetails, HttpContext.Current.User.Identity.Name);
            return premiumQuoteBilling;
        }


        public async Task<Response_Billing_212> Response_As_Object(Request_Billing_212 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "Response_As_Object212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Billing_212 response = new Response_Billing_212();
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
                    response = (Response_Billing_212)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Response_As_Object212", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }

        public PremiumQuoteBilling Fill_Model_values(Response_Billing_212 response_212, Request_Billing_212 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                                "GetBilling_212_BussinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            PremiumQuoteBilling premiumQuoteBilling = new PremiumQuoteBilling();
            premiumQuoteBilling.company_Code = req.TXLifeRequest.OLifE.Holding.Policy.CarrierCode;
            premiumQuoteBilling.policy_Number = req.TXLifeRequest.OLifE.Holding.Policy.PolNumber;

            current_Mode_Premium = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.Coverage.ModalPremAmt.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.Coverage.ModalPremAmt.Trim();
            premiumQuoteBilling.current_Mode_Premium = System.Convert.ToDouble(current_Mode_Premium).ToString("C", CultureInfo.CurrentCulture);

            mode_val = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMode.Value.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMode.Value.Trim();
            premiumQuoteBilling.current_Mode = Payment_Mode(mode_val);

            form_val = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMethod.Value.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMethod.Value.Trim();
            premiumQuoteBilling.current_Form = Payment_Method(form_val);

            billed_to_date = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.BilledToDate.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.BilledToDate.Trim();
            premiumQuoteBilling.billed_To_Date = Format_Date(billed_to_date);

            paid_to_date = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PaidToDate.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PaidToDate.Trim();
            premiumQuoteBilling.paid_To_Date = Format_Date(paid_to_date);

            policy_Fee = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PolFee.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PolFee.Trim();
            premiumQuoteBilling.policy_Fee = System.Convert.ToDouble(policy_Fee).ToString("C", CultureInfo.CurrentCulture); 

            mode_val = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMode.tc)?string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMode.tc;
            premiumQuoteBilling.requested_Mode_id = System.Convert.ToInt16(convertMode(mode_val));

            premiumQuoteBilling.requested_Form_id = System.Convert.ToInt16(response_212.TXLifeResponse.OLifE.Holding.Policy.PaymentMethod.tc);

            annual_Policy_Fee = string.IsNullOrEmpty(response_212.TXLifeResponse.OLifE.Holding.Policy.PolFee.Trim()) ? string.Empty : response_212.TXLifeResponse.OLifE.Holding.Policy.PolFee.Trim();
            premiumQuoteBilling.annual_Policy_Fee = System.Convert.ToDouble(annual_Policy_Fee).ToString("C", CultureInfo.CurrentCulture);

            annual_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLannualPrem)) ? 0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLannualPrem ;
            premiumQuoteBilling.annual_Amount = annual_Amount.ToString("C", CultureInfo.CurrentCulture);

            semi_Annual_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLsemiAnnualPrem))? 0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLsemiAnnualPrem;
            premiumQuoteBilling.semi_Annual_Amount = semi_Annual_Amount.ToString("C", CultureInfo.CurrentCulture);

            quaterly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLquarterlyPrem))? 0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLquarterlyPrem;
            premiumQuoteBilling.quaterly_Amount = quaterly_Amount.ToString("C", CultureInfo.CurrentCulture);

            monthly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLmonthlyPrem))? 0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLmonthlyPrem ;
            premiumQuoteBilling.monthly_Amount = monthly_Amount.ToString("C", CultureInfo.CurrentCulture);

            ninthly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLninethlyPrem))?0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLninethlyPrem;
            premiumQuoteBilling.ninthly_Amount = ninthly_Amount.ToString("C", CultureInfo.CurrentCulture);

            tenthly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLtenthlyPrem))? 0: response_212.TXLifeResponse.OLifE.OLifEExtension.EXLtenthlyPrem;
            premiumQuoteBilling.tenthly_Amount = tenthly_Amount.ToString("C", CultureInfo.CurrentCulture);

            thirteenthly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXL13thlyPrem))?0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXL13thlyPrem;
            premiumQuoteBilling.thirteenthly_Amount = thirteenthly_Amount.ToString("C", CultureInfo.CurrentCulture);

            weekly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLweeklyPrem))?0: response_212.TXLifeResponse.OLifE.OLifEExtension.EXLweeklyPrem;
            premiumQuoteBilling.weekly_Amount = weekly_Amount.ToString("C", CultureInfo.CurrentCulture);

            bi_Weekly_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLbiweeklyPrem))? 0: response_212.TXLifeResponse.OLifE.OLifEExtension.EXLbiweeklyPrem;
            premiumQuoteBilling.bi_Weekly_Amount = bi_Weekly_Amount.ToString("C", CultureInfo.CurrentCulture);

            pay_26_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXL26payPrem))? 0: response_212.TXLifeResponse.OLifE.OLifEExtension.EXL26payPrem;
            premiumQuoteBilling.pay_26_Amount = pay_26_Amount.ToString("C", CultureInfo.CurrentCulture);

            pay_52_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXL52payPrem))?0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXL52payPrem;
            premiumQuoteBilling.pay_52_Amount = pay_52_Amount.ToString("C", CultureInfo.CurrentCulture);

            calander_Amount = string.IsNullOrEmpty(System.Convert.ToString(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLcalendarPrem)) ? 0 : response_212.TXLifeResponse.OLifE.OLifEExtension.EXLcalendarPrem;
            premiumQuoteBilling.calander_Amount = calander_Amount.ToString("C", CultureInfo.CurrentCulture);

            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return premiumQuoteBilling;
        }

        public string Payment_Mode(string mode)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "Payment_Mode" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string mode_Str = string.Empty;
            if (!string.IsNullOrEmpty(mode))
            {
                var split_value = Regex.Split(mode, "_");
                if (split_value.Length == 3)
                {
                    mode_Str = split_value[2];
                }
                else
                {
                    if (split_value.Length == 4)
                    {
                        mode_Str = split_value[3];
                    }
                }
            }
            else
            {
                mode_Str = mode;
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Payment_Mode", reqDetails, HttpContext.Current.User.Identity.Name);
            return mode_Str;
        }

        public string Format_Date(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "Format_Date" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            var split_value = Regex.Split(date, "-");

            var yyyy = split_value[0];
            var mm = split_value[1];
            var dd = split_value[2];
            string date_L = mm + "/" + dd + "/" + yyyy;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Format_Date", reqDetails, HttpContext.Current.User.Identity.Name);
            return date_L;
        }

        public string convertMode(String modeval)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "convertMode" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            String mode = string.Empty;

            if (modeval.Length > 3)
            {
                mode = modeval.Substring(8, 2);
            }
            else
            {
                mode = modeval;
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "convertMode", reqDetails, HttpContext.Current.User.Identity.Name);
            return mode;
        }

        public string Payment_Method(String method)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "Payment_Method" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string full_Name = string.Empty;

            switch (method)
            {
                case "DIR":
                    {
                        full_Name = "DIRECT";
                        break;
                    }
                case "LST":
                    {
                        full_Name = "List Bill";
                        break;
                    }
                case "GVT":
                    {
                        full_Name = "Govt Allot";
                        break;
                    }

                case "CRD":
                    {
                        full_Name = "Credit Card";
                        break;
                    }
                case "PDF":
                    {
                        full_Name = "Premium Deposit Fund";
                        break;
                    }

                case "PAC":
                    {
                        full_Name = "Preauthorized Collection";
                        break;
                    }
                default:
                    {
                        full_Name = "DIRECT";
                        break;
                    }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "Payment_Method", reqDetails, HttpContext.Current.User.Identity.Name);
            return full_Name;
        }

        public string GetPayment_Flag(Int64 requested_Mode)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetBilling_212_BussinessLogic.cs" + "." + "GetPayment_Flag" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            string payment_Mode_Flag = string.Empty;
            if (requested_Mode == 1 || requested_Mode == 2 || requested_Mode == 3 ||
                requested_Mode == 4 || requested_Mode == 6 || requested_Mode == 7 ||
                requested_Mode == 44)
            {
                payment_Mode_Flag = "00";
            }
            else
            {
                if (requested_Mode == 20 || requested_Mode == 21 || requested_Mode == 5226000024 ||
                    requested_Mode == 5226000025 || requested_Mode == 5226000026)
                {
                    payment_Mode_Flag = "01";
                }
                else
                {
                    payment_Mode_Flag = "00";
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetBilling_212_BussinessLogic.cs", "GetPayment_Flag", reqDetails, HttpContext.Current.User.Identity.Name);
            return payment_Mode_Flag;
        }


    }
}
