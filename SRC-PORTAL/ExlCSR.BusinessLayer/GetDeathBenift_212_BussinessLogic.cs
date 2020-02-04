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
using Request_db_212 = ExlCSR.TransactionsLibrary.PolicySummary.Request_Death.TXLife;
using Response_db_212 = ExlCSR.TransactionsLibrary.PolicySummary.Response_Death.TXLife;


namespace ExlCSR.BusinessLayer
{
    public class GetDeathBenift_212_BussinessLogic
    {
        protected ILogger loggerComponent { get; set; }
        private TransactionRequestDetails reqDetails = null;
        private string transType = string.Empty;
        private string transSubType = string.Empty;
        private Death_benifit death_benifit = null;
        private Response_db_212 txlife_Response = null;

        public GetDeathBenift_212_BussinessLogic()
        {
            loggerComponent = new Log4NetWrapper();
            reqDetails = new TransactionRequestDetails();
            death_benifit = new Death_benifit();
        }


        public async Task<Death_benifit> Get_Response(DeathBenifit_Inp dben)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetDeathBenift_212_BussinessLogic.cs" + "." + "Get_Response212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Request_db_212 txlife = new Request_db_212();

            txlife.UserAuthRequest = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeUserAuthRequest();
            txlife.UserAuthRequest.VendorApp = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeUserAuthRequestVendorApp();
            txlife.UserAuthRequest.VendorApp.VendorName = "EXL";
            txlife.UserAuthRequest.VendorApp.AppName = "LifePRO";
            txlife.UserAuthRequest.VendorApp.AppVer = "V19";

            txlife.TXLifeRequest = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequest();
            txlife.TXLifeRequest.TransRefGUID = Guid.NewGuid();
            txlife.TXLifeRequest.TransExeDate = DateTime.Now.Date;
            txlife.TXLifeRequest.TransExeTime = DateTime.Now.ToString("HH:mm:ss");

            txlife.TXLifeRequest.TransType = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestTransType();
            txlife.TXLifeRequest.TransType.tc = "212";
            txlife.TXLifeRequest.TransType.Value = "OLI_TRANS_INQVAL";

            txlife.TXLifeRequest.TransSubType = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestTransSubType();
            txlife.TXLifeRequest.TransSubType.tc = "21201";
            txlife.TXLifeRequest.TransSubType.Value = "OLI_TRANSSUB_INQVAL";

            txlife.TXLifeRequest.OLifE = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestOLifE();
            txlife.TXLifeRequest.OLifE.Holding = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestOLifEHolding();
            txlife.TXLifeRequest.OLifE.Holding.id = "_Holding1";
            txlife.TXLifeRequest.OLifE.Holding.Policy = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestOLifEHoldingPolicy();

            txlife.TXLifeRequest.OLifE.Holding.Policy.CarrierCode = dben.company_Code;
            txlife.TXLifeRequest.OLifE.Holding.Policy.PolNumber = dben.PolicyNumber;
            if (!string.IsNullOrEmpty(dben.date))
            {
                txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate = FormatDate(dben.date);
            }
            else
            {
                txlife.TXLifeRequest.OLifE.Holding.Policy.EffDate = "";
            }


            txlife.TXLifeRequest.OLifE.OLifEExtension = new TransactionsLibrary.PolicySummary.Request_Death.TXLifeTXLifeRequestOLifEOLifEExtension();
            txlife.TXLifeRequest.OLifE.OLifEExtension.EXLNameId = "";
            txlife.TXLifeRequest.OLifE.OLifEExtension.EXLBenefitSeq = "";


            txlife_Response = await Response_As_Object(txlife);

            if (txlife_Response != null)
            {
                death_benifit = Fill_Model_values(txlife_Response, txlife);
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetDeathBenift_212_BussinessLogic.cs", "Get_Response212", reqDetails, HttpContext.Current.User.Identity.Name);
            return death_benifit;

        }

        public async Task<Response_db_212> Response_As_Object(Request_db_212 request)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetDeathBenift_212_BussinessLogic.cs" + "." + "Response_As_Object212" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            Response_db_212 response = new Response_db_212();
            String request_As_String = Common.GetXmlFromObject(request);

            GetPolicyServiceRefrence302.ExlLifePROServiceClient getpolicyservicerefrence = new GetPolicyServiceRefrence302.ExlLifePROServiceClient();
            var deathTask = getpolicyservicerefrence.EXLServiceRequestAsync(request_As_String);

            string service_Response = await deathTask;

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
                    response = (Response_db_212)Common.XmlToObject(service_Response, type);
                }
                else
                {
                    response = null;
                }
            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetDeathBenift_212_BussinessLogic.cs", "Response_As_Object212", reqDetails, HttpContext.Current.User.Identity.Name);
            return response;
        }


        public Death_benifit Fill_Model_values(Response_db_212 response_212, Request_db_212 req)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetDeathBenift_212_BussinessLogic.cs" + "." + "Fill_Model_values" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);

            int benseq = 0;
            string covcode = string.Empty;
            string covname = string.Empty;
            Death_benifit death_benifit = new Death_benifit();

            death_benifit.effictive_Date = DateTime.Now.Month.ToString() + "/" + DateTime.Now.Day.ToString() + "/" + DateTime.Now.Year.ToString();
            List<DB_Policy_coverages> dB_Policy_coverages = new List<DB_Policy_coverages>();


            var olifeExtDB_Lst = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLDateBen.ToList();
            var olifeExtBen = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLBenefits.ToList();

            var relation_Lst = response_212.TXLifeResponse.OLifE.Relation.ToList();
            List<DeathBenifitTable> deathBenifitTableLst = new List<DeathBenifitTable>();


            foreach (var relation in relation_Lst)
            {
                var databen = olifeExtDB_Lst.Where(o => o.NameID.Equals(relation.RelatedObjectID) && o.Cov.Equals("**")).First();
                double total_Db = databen.EXLDeathBenefit;
                death_benifit.a_total_DB = total_Db.ToString("C", CultureInfo.CurrentCulture);

                var benefits = olifeExtBen.Where(b => b.id.Equals(relation.RelatedObjectID));

                foreach (var benefit in benefits)
                {
                    benseq = benefit.EXLSeq;
                    covcode = string.IsNullOrEmpty(benefit.EXLPlanCode) ? string.Empty : benefit.EXLPlanCode.Trim();
                    covname = string.IsNullOrEmpty(benefit.EXLPlanDesc) ? string.Empty : benefit.EXLPlanDesc.Trim();

                    dB_Policy_coverages.Add(new DB_Policy_coverages()
                    {
                        sequence = benseq,
                        plan_Code = covcode,
                        coverage_Name = covname
                    });
                }
                death_benifit.dB_Policy_coverages = dB_Policy_coverages;



                var lifelst = response_212.TXLifeResponse.OLifE.Holding.Policy.Life.ToList();

                var databenpar = olifeExtDB_Lst.Where(o => o.NameID.Equals(relation.RelatedObjectID) && o.Cov.Equals("**"));
                //var databenpar = olifeExtDB_Lst.Where(o => o.NameID.Equals(relation.RelatedObjectID) && !o.Cov.Equals(cov.id)).First();
                double interestondb = 0;
                foreach (var databene in databenpar)
                {
                    interestondb = System.Convert.ToDouble(databene.EXLInterestOnDb);

                    deathBenifitTableLst.Add(new DeathBenifitTable()
                    {
                        p_Face_Amt = databene.EXLFaceAmt.ToString("C", CultureInfo.CurrentCulture),
                        pu_Addtion = databene.EXLPUAFaceAmt.ToString("C", CultureInfo.CurrentCulture),
                        one_Year_Term = databene.EXLFaceAmntOYT.ToString("C", CultureInfo.CurrentCulture),
                        extended_Term = databene.EXLFaceAmntETI.ToString("C", CultureInfo.CurrentCulture),
                        rp_Up = databene.EXLFaceAmntRPU.ToString("C", CultureInfo.CurrentCulture),
                        div_acc = databene.EXLDividendAcc.ToString("C", CultureInfo.CurrentCulture),
                        div_Adj = databene.EXLDividendAdj.ToString("C", CultureInfo.CurrentCulture),
                        int_On_Death_Amt = interestondb.ToString("C", CultureInfo.CurrentCulture),
                        acc_Death = databene.EXLAccidentalDeath.ToString("C", CultureInfo.CurrentCulture),
                        total_DB = databene.EXLDeathBenefit.ToString("C", CultureInfo.CurrentCulture),
                        unproc_Prem = databene.EXLUnprocessPrem.ToString("C", CultureInfo.CurrentCulture),
                        unapp_Cash = databene.EXLUnAppliedCash.ToString("C", CultureInfo.CurrentCulture),
                    });
                }

                death_benifit.deathBenifitTables = deathBenifitTableLst;

                List<Death_benifit_Discription> dbDescription = new List<Death_benifit_Discription>();

                if (response_212.TXLifeResponse.OLifE.OLifEExtension.EXLGMBVal != null)
                {
                    var GMBVal = response_212.TXLifeResponse.OLifE.OLifEExtension.EXLGMBVal.ToList();
                    var description = GMBVal.Where(d => System.Convert.ToString(d.id).Equals(relation.RelatedObjectID));

                    string desc = string.Empty;
                    string val = string.Empty;

                    foreach (var GMB in description)
                    {
                        desc = string.IsNullOrEmpty(GMB.EXLDesc) ? string.Empty : GMB.EXLDesc;                        
                        val = GMB.EXLNetAmt.ToString("C",CultureInfo.CurrentCulture);


                        dbDescription.Add(new Death_benifit_Discription()
                        {
                            Description = desc,
                            Value = val
                        });
                    }
                    death_benifit.dbendiscriptions = dbDescription;
                }

            }
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetDeathBenift_212_BussinessLogic.cs", "Fill_Model_values", reqDetails, HttpContext.Current.User.Identity.Name);
            return death_benifit;
        }


        public string FormatDate(string date)
        {
            loggerComponent.WriteLog(LoggingLevel.INFO, DateTime.Now, LoggingContext.RoutingComponent,
                                            "GetDeathBenift_212_BussinessLogic.cs" + "." + "FormatDate" + " : " + "" + "  " + "", reqDetails, HttpContext.Current.User.Identity.Name, null);
            var split_date = Regex.Split(date, "/");
            string mm = split_date[0];
            string dd = split_date[1];
            string year = split_date[2];
            string final_Date = year + "-" + mm + "-" + dd;
            loggerComponent.WriteLogResponded(LoggingContext.RoutingComponent, DateTime.Now, "GetDeathBenift_212_BussinessLogic.cs", "FormatDate", reqDetails, HttpContext.Current.User.Identity.Name);
            return final_Date;
        }
    }
}
