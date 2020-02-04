using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using exlservice.lifepro.policyvalues.Globals;
using Logging.Contract;
using Logging;
using System.Configuration;
using exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails;
using TXLife = exlservice.lifepro.policyvalues.BaseTransactionHandler.RequestBalanceInquiryDetails.TXLife;

namespace exlservice.lifepro.policyvalues.APILibrary
{
    
    public class BalanceInquiryService
{
        #region InitiateAPISession

        //STEP 1
        private readonly TransactionRequestDetails reqDetails = new TransactionRequestDetails();

        protected ILogger LoggerComponent { get; set; }

        private readonly TXLife _TXLifeRequest;

        //private apirBalInqu apiBalances;
        //CREATE RESPONSE PROPERTY

        public exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails.TXLife TXLifeResponse { get; set; }
      
        #endregion
         #region Constructor

        //CONSTRUCTOR WILL INITIATE THE API SESSION
        public BalanceInquiryService(TXLife objRequest, ILogger loggingComponent)
        {
            LoggerComponent = loggingComponent;
            _TXLifeRequest= objRequest;
             TXLifeResponse = new exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails.TXLife();
             RunBalanceInquiry(objRequest);
        }
       
        #endregion
        #region RunBalanceInquiry (Fill Input and run API)

        //STEP 2 - RUN PREMIUM ILLUSTRATIONS
        public void RunBalanceInquiry(TXLife objRequest)
        {
            var apiRequest = new BalanceInquiryRequest();
            var apiClient=new BalanceInquiryServiceClient();
            var apiResponse = new BalanceInquiryResponse();

            reqDetails.RequestGUID = _TXLifeRequest.TXLifeRequest.TransRefGUID.ToString();
            LoggerComponent.WriteLogRequested(LoggingContext.RoutingComponent, DateTime.Now, "RunBalanceInquiry",
                "BalanceInquiry.cs", reqDetails, "");

            try
            {
               // ValidateRequest();
                apiRequest = CommonInputs(objRequest);
               
            }
            catch (Exception ex)
            {
                LoggerComponent.WriteLog(LoggingLevel.ERROR, DateTime.Now, LoggingContext.RoutingComponent, ex.Message,
                    reqDetails, "", ex);
                throw new ArgumentException(ex.Message);
            }

            //RUN API QUOTE FOR BALANCE INQUIRY
            try
            {
                LoggerComponent.WriteLogRequested(LoggingContext.RoutingComponent, DateTime.Now, "Before run quote",
                    "BalanceInquiry.cs", reqDetails, "");
                var responseRes = apiClient.RunInquiry(apiRequest);
                if (responseRes == null)
                    throw new ArgumentException("Response recieved from API in null");

                if (responseRes.ReturnCode == 0) //SUCCESS
                {
                    LoggerComponent.WriteLogRequested(LoggingContext.RoutingComponent, DateTime.Now, "After run Inquiry", 
                        "BalanceInquiry.cs", reqDetails, "");
                    TXLifeResponse = new exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails.TXLife();
                    GeneralOutput(apiRequest, responseRes);
                    LoggerComponent.WriteLogResponded(LoggingContext.ServiceClass, DateTime.Now, "GeneralOutput",
                        "BalanceInquiry.cs", reqDetails, "");
                }
                else
                {
                    throw new ArgumentException(responseRes.ReturnCode + "-" + responseRes.ErrorMessage);
                }
            }
            catch (Exception ex)
            {
                LoggerComponent.WriteLog(LoggingLevel.ERROR, DateTime.Now, LoggingContext.RoutingComponent, ex.Message,
                    reqDetails, "", ex);
                throw new ArgumentException("API Error: " + ex.Message);
            }
        }

        #endregion
        #region Request Mappping

        /// <summary>
        ///     Add common inputs present on API first page
        /// </summary>
        private BalanceInquiryRequest CommonInputs(TXLife objRequest)
        {
            var apiRequest = new BalanceInquiryRequest();
            apiRequest.UserType = ConfigurationManager.AppSettings["UserType"];
                          
            apiRequest.CompanyCode =
                Util.StringParse(_TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.CarrierCode.Trim());

           apiRequest.PolicyNumber=
            Util.StringParse(_TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.PolNumber.Trim());

            DateTime dt;
            if (DateTime.TryParseExact(_TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.EffDate, "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
            {
                var effDate = DateTime.Parse(_TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.EffDate);
                apiRequest.EffectiveDate = Util.FormatDate(effDate.ToString("MM/dd/yyyy"));

                
            }
            else
                throw new ArgumentException("Invalid_Request: EffectiveDate should be in yyyy-MM-dd format");

            

            return apiRequest;
        }

      

        /// <summary>
        ///     Add insured inputs to API
        /// </summary>
        /// 
       
       
        #endregion
        private void GeneralOutput(BalanceInquiryRequest apiRequest, BalanceInquiryResponse apiResponse)
        {
            reqDetails.RequestGUID = _TXLifeRequest.TXLifeRequest.TransRefGUID.ToString();
            LoggerComponent.WriteLogRequested(LoggingContext.RoutingComponent, DateTime.Now, "GeneralOutput started",
                "BalanceInquiry.cs", reqDetails, "");
            var objTXLife = new BaseTransactionHandler.ResponseBalanceInquiryDetails.TXLife();
           
            objTXLife.TXLifeResponse = new TXLifeTXLifeResponse();

            objTXLife.TXLifeResponse.TransRefGUID = _TXLifeRequest.TXLifeRequest.TransRefGUID;

            objTXLife.TXLifeResponse.TransType = new TXLifeTXLifeResponseTransType();
            objTXLife.TXLifeResponse.TransType.tc = "212";
            objTXLife.TXLifeResponse.TransType.Value = "OLI_TRANS_ILLCAL";
            objTXLife.TXLifeResponse.TransSubType=new TXLifeTXLifeResponseTransSubType();
            objTXLife.TXLifeResponse.TransSubType.tc = "21200";
            objTXLife.TXLifeResponse.TransSubType.Value = "OLI_TRANSSUB_INQVAL";
            objTXLife.TXLifeResponse.TransExeDate = DateTime.Now.ToString("yyyy-MM-dd");
            objTXLife.TXLifeResponse.TransExeTime = DateTime.Now.ToString("HH:mm:ss");

            objTXLife.TXLifeResponse.PendingResponseOK = "false";
            objTXLife.TXLifeResponse.NoResponseOK = "false";

            objTXLife.TXLifeResponse.TransResult = new TXLifeTXLifeResponseTransResult();
            objTXLife.TXLifeResponse.TransResult.ResultCode = new TXLifeTXLifeResponseTransResultResultCode();
            objTXLife.TXLifeResponse.TransResult.ResultCode.tc = "1";
            objTXLife.TXLifeResponse.TransResult.ResultCode.Value = "Success";
            objTXLife.TXLifeResponse.TransResult.ResultInfo = new TXLifeTXLifeResponseTransResultResultInfo();
            objTXLife.TXLifeResponse.TransResult.ResultInfo.ResultInfoCode = new TXLifeTXLifeResponseTransResultResultInfoResultInfoCode();
            objTXLife.TXLifeResponse.TransResult.ResultInfo.ResultInfoCode.tc = "101";
            objTXLife.TXLifeResponse.TransResult.ResultInfo.ResultInfoCode.Value = "Status Information";
            objTXLife.TXLifeResponse.TransResult.ResultInfo.ResultInfoSysMessageCode = "";
            objTXLife.TXLifeResponse.TransResult.ResultInfo.ResultInfoDesc = "";

            objTXLife.TXLifeResponse.OLifE = new TXLifeTXLifeResponseOLifE();
            objTXLife.TXLifeResponse.OLifE.Holding = new TXLifeTXLifeResponseOLifEHolding();
            objTXLife.TXLifeResponse.OLifE.Holding.id = _TXLifeRequest.TXLifeRequest.OLifE.Holding.id;
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingTypeCode = new TXLifeTXLifeResponseOLifEHoldingHoldingTypeCode();
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingTypeCode.tc = "";
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingTypeCode.Value = "Policy";
         
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingStatus = new TXLifeTXLifeResponseOLifEHoldingHoldingStatus();
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingStatus.tc = "3";
            objTXLife.TXLifeResponse.OLifE.Holding.HoldingStatus.Value = "Proposed";

            objTXLife.TXLifeResponse.OLifE.Holding.CarrierAdminSystem = "LifePRO";
           
            objTXLife.TXLifeResponse.OLifE.Holding.Policy = new TXLifeTXLifeResponseOLifEHoldingPolicy();
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.CarrierPartyID = apiRequest.CompanyCode;
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.CarrierCode = apiRequest.CompanyCode;
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.PolNumber = apiRequest.PolicyNumber;
            
            DateTime dt;
            if (DateTime.TryParseExact(_TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.EffDate, "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
            {
                var effDate = _TXLifeRequest.TXLifeRequest.OLifE.Holding.Policy.EffDate;
                objTXLife.TXLifeResponse.OLifE.Holding.Policy.EffDate = effDate;
                                
            }
            string LastAnniversaryDate = apiResponse.ProcessToDate.ToString();
            LastAnniversaryDate = LastAnniversaryDate.Insert(6, "-");
            LastAnniversaryDate = LastAnniversaryDate.Insert(4, "-");
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.LastAnniversaryDate = LastAnniversaryDate;

            string LastValuationDate = apiResponse.LastValuationDate.ToString();
            LastValuationDate = LastValuationDate.Insert(6, "-");
            LastValuationDate = LastValuationDate.Insert(4, "-");
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.LastFinActivityDate = LastValuationDate; 

            objTXLife.TXLifeResponse.OLifE.Holding.Policy.Life = new TXLifeTXLifeResponseOLifEHoldingPolicyLife();
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.Life.CashValueAmt =apiResponse.TotalFundBalance;
            objTXLife.TXLifeResponse.OLifE.Holding.Policy.Life.DivOnDepositAmt = System.Convert.ToString(apiResponse.GrossDeposits);


            objTXLife.TXLifeResponse.OLifE.Holding.Loan = new TXLifeTXLifeResponseOLifEHoldingLoan();
            objTXLife.TXLifeResponse.OLifE.Holding.Loan.LoanAmt =System.Convert.ToString(apiResponse.LoanBalance);

           

            objTXLife.TXLifeResponse.OLifE.OLifEExtension = new TXLifeTXLifeResponseOLifEOLifEExtension();
            objTXLife.TXLifeResponse.OLifE.OLifEExtension.EXLActiveRequest = apiResponse.ActiveRequests;
            objTXLife.TXLifeResponse.OLifE.OLifEExtension.EXLMultipleLoan = apiResponse.MultipleLoans;
            objTXLife.TXLifeResponse.OLifE.OLifEExtension.EXLGrossWithdrawl =System.Convert.ToString(apiResponse.GrossWithdrawals);


            var count = apiResponse.RowCount ;
            List<TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail> lstEXLSourceDetails = new List<TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail>();
            for (int i = 0; i < count; i++)
            {
                string UnitDate=apiResponse.UnitValueDate[i].ToString();
                UnitDate = UnitDate.Insert(6, "-");
                UnitDate = UnitDate.Insert(4, "-");
                string EXLSourceShortDescription = !string.IsNullOrEmpty(apiResponse.ShortDescription[i]) ? apiResponse.ShortDescription[i] : string.Empty;
                if(EXLSourceShortDescription.Contains("\0\0"))
                {
                    EXLSourceShortDescription = string.Empty;
                }
                string EXLSourceLongDescription = !string.IsNullOrEmpty(apiResponse.LongDescription[i]) ? apiResponse.LongDescription[i] : string.Empty;
                if (EXLSourceLongDescription.Contains("\0\0"))
                {
                    EXLSourceLongDescription = string.Empty;
                }
                    lstEXLSourceDetails.Add(new TXLifeTXLifeResponseOLifEOLifEExtensionEXLSourceDetail()
                {
                    ID = i + 1,
                    EXLSource = apiResponse.MoneySource[i],
                    EXLSourceID = apiResponse.FundID[i],
                    EXLSourceShortDescrip=EXLSourceShortDescription,
                    EXLSourceLongDescrip = EXLSourceLongDescription,
                    EXLFundType = apiResponse.FundType[i],
                    EXLUnits = apiResponse.Units[i],
                    EXLUnitValue = apiResponse.UnitValue[i],
                    EXLUnitDate = UnitDate.ToString(),
                    EXLBalance = apiResponse.FundBalance[i]
                });

            }
            objTXLife.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetail = lstEXLSourceDetails.ToArray();
            objTXLife.TXLifeResponse.OLifE.OLifEExtension.EXLSourceDetTotal = count;

            TXLifeResponse.TXLifeResponse = objTXLife.TXLifeResponse;
            LoggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "Genral Output Responded",
                "BalanceInquiry.cs", reqDetails, "");
        }
        #region variable & properties

      ////  protected ILogger LoggerComponent { get; set; }

      //  private readonly TXLife _TXLifeRequest;
      //  //CREATE RESPONSE PROPERTY

      //  public exlservice.lifepro.policyvalues.BaseTransactionHandler.ResponseBalanceInquiryDetails.TXLife TXLifeResponse { get; set; }
      
        #endregion
}
    
}
