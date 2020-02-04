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
using Request_Fund_212 = ExlCSR.TransactionsLibrary.PolicySummary.RequestFund.TXLife;
using Response_Fund_212 = ExlCSR.TransactionsLibrary.PolicySummary.ResponseFund.TXLife;

namespace ExlCSR.BusinessLayer
{
    public class GetFund_212_BussinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails = null;
        private FundViewModel fundView_Model = null;
        private string transType = string.Empty;
        private string transSubType = string.Empty;
        private Response_Fund_212 txlife_Response = null;
        private string units_lcl = string.Empty;
        private string unit_value_Lcl = string.Empty;
        private string fund_Value_Lcl = string.Empty;
        private string percent_total;
        private double Total;
        private int total_FundType;
        private string interest_Rate;
        DateTime effectiveDate = DateTime.MinValue;

        public GetFund_212_BussinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            fundView_Model = new FundViewModel();
        }

        public async Task<FundViewModel> Get_Response(Fund fund)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetFund_212_BussinessLogic.cs" + "." + "Get_Response212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_Fund_212 txlife = new Request_Fund_212();

            txlife.UserAuthRequest = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = "EXL";
            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "V19";

            txlife.TXLifeRequest = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");

            txlife.TXLifeRequest.TransType = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "212";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_ILLCAL";

            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "21200";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_TRANSSUB_INQVAL";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequestOLifE();
            txlife.TXLifeRequest.OLifE.Holding = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequestOLifEHolding();
            txlife.TXLifeRequest.OLifE.Holding.Policy = new TransactionsLibrary.PolicySummary.RequestFund.TXLifeTXLifeRequestOLifEHoldingPolicy();

            txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode = fund.company_code;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber = fund.policy_number;
            txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate = fund.effictive_Date;

            txlife_Response = await Response_As_Object(txlife);

            if (txlife_Response != null)
            {
                if(fund.flag)
                {
                    fundView_Model = Fill_Account_value(txlife_Response, txlife);
                }
                else
                {
                    fundView_Model = Fill_Model_values(txlife_Response, txlife);
                }                
            }
            else
            {
                fundView_Model = null;
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetFund_212_BussinessLogic.cs", "Get_Response212", reqDetails, HttpContext.Current.User.Identity.Name);
            return fundView_Model;

        }

        public async Task<Response_Fund_212> Response_As_Object(Request_Fund_212 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetFund_212_BussinessLogic.cs" + "." + "Response_As_Object212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_Fund_212 response = new Response_Fund_212();
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
                    response = (Response_Fund_212)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetFund_212_BussinessLogic.cs", "Response_As_Object212", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }

        public FundViewModel Fill_Model_values(Response_Fund_212 response_212, Request_Fund_212 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetFund_212_BussinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            List<FundTableData> fundTable = new List<FundTableData>();
            FundViewModel fundViewModel = new FundViewModel();
            fundViewModel.fundData = new FundData();

            if (response_212.TXLifeResponse.OLifE.Holding.Policy.Life.CashValueAmt == 0)
            {
                Total = 0;
            }
            else
            {
                Total = response_212.TXLifeResponse.OLifE.Holding.Policy.Life.CashValueAmt;
            }

            if (string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.CarrierCode))
            {
                fundViewModel.fundData.company_Code = string.Empty;
            }
            else
            {
                fundViewModel.fundData.company_Code = req.TXLifeRequest.OLifE.Holding.Policy.CarrierCode;
            }
            if (string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.PolNumber))
            {
                fundViewModel.fundData.policy_Number = string.Empty;
            }
            else
            {
                fundViewModel.fundData.policy_Number = req.TXLifeRequest.OLifE.Holding.Policy.PolNumber;
            }
            
            if (!string.IsNullOrEmpty(req.TXLifeRequest.OLifE.Holding.Policy.EffDate))
            {
                effectiveDate = DateTime.Parse(req.TXLifeRequest.OLifE.Holding.Policy.EffDate);
            }

            if (string.IsNullOrEmpty(effectiveDate.ToString("MM-dd-yyyy")))
            {
                fundViewModel.fundData.req_Eff_Date = string.Empty;
            }
            else
            {
                fundViewModel.fundData.req_Eff_Date = effectiveDate.ToString("MM/dd/yyyy");
                fundViewModel.fundData.quoted_As_Of = effectiveDate.ToString("MM/dd/yyyy");
            }

            fundViewModel.fundData.total = Total.ToString("C", CultureInfo.CurrentCulture);

            if(response_212.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetail != null)
            {            
            var sourceDetails_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetail.ToList();

            if (sourceDetails_Lst.Where(f => f.EXLFundType.Equals("U")).Any())
            {
                total_FundType = sourceDetails_Lst.Where(f => f.EXLFundType.Equals("U")).Count();
            }
            else
            {
                total_FundType = 0;
            }
            fundViewModel.fundData.funds_Currently = string.IsNullOrEmpty(System.Convert.ToString(total_FundType)) ? "0" : System.Convert.ToString(total_FundType);

            foreach (var data in sourceDetails_Lst)
            {
                units_lcl = System.Convert.ToString(data.EXLUnits);
                unit_value_Lcl = data.EXLUnitValue.ToString("C", CultureInfo.CurrentCulture);
                fund_Value_Lcl = data.EXLBalance.ToString("C", CultureInfo.CurrentCulture);
                interest_Rate = System.Convert.ToString(data.EXInterestRate);
                if (interest_Rate.Equals("0") || string.IsNullOrEmpty(interest_Rate))
                {
                    interest_Rate = "0%";
                }
                else
                {
                    interest_Rate = interest_Rate + "%";
                }

                if (fund_Value_Lcl.Equals("0") || string.IsNullOrEmpty(fund_Value_Lcl))
                {
                    fund_Value_Lcl = string.Empty;
                }
                //else
                //{
                //    fund_Value_Lcl = "$" + fund_Value_Lcl;
                //}
                if (data.EXLBalance == 0 && Total == 0 || data.EXLBalance == 0 || Total == 0)
                {
                    percent_total = "0.00";
                }
                else
                {
                    percent_total = System.Convert.ToString(Math.Round((data.EXLBalance / Total), 2));
                    if(percent_total.Equals("1"))
                    {
                        percent_total = "100";
                    }
                }
                if (percent_total.Equals("0") || percent_total.Equals("0.00"))
                {
                    percent_total = string.Empty;
                }
                else
                {
                    percent_total = percent_total + "%";
                }

                fundTable.Add(new FundTableData()
                {
                    fund_Id = data.EXLSourceID,
                    fund_Name = data.EXLSourceShortDescrip,
                    interest_Rate = interest_Rate,
                    units = units_lcl,
                    unit_Value = unit_value_Lcl,
                    fund_Value = fund_Value_Lcl,
                    per_Of_Total = percent_total,
                    fund_Type = data.EXLFundType
                });
            }
        }
            fundViewModel.FundTableData = fundTable;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetFund_212_BussinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return fundViewModel;
        }

        public FundViewModel Fill_Account_value(Response_Fund_212 response_212, Request_Fund_212 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetFund_212_BussinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            FundViewModel fundViewModel = new FundViewModel();
            
            if (response_212.TXLifeResponse.OLifE.Holding.Policy.Life.CashValueAmt == 0)
            {
                fundViewModel.account_value = 0.00;
            }
            else
            {
                fundViewModel.account_value = System.Convert.ToDouble(response_212.TXLifeResponse.OLifE.Holding.Policy.Life.CashValueAmt);
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetFund_212_BussinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return fundViewModel;
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

    }
}
