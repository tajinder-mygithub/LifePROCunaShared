using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace ExlCSR.ModelLayer
{
    public class PremiumQuoteBilling
    {
        public string company_Code { get; set; }
        public string policy_Number { get; set; }
        public string current_Mode_Premium { get; set; }
        public string current_Mode { get; set; }
        public string current_Form { get; set; }
        public string billed_To_Date { get; set; }
        public string paid_To_Date { get; set; }
        public string policy_Fee { get; set; }
        public string annual_Policy_Fee { get; set; }

        public string annual_Amount { get; set; }
        public string semi_Annual_Amount { get; set; }
        public string quaterly_Amount { get; set; }
        public string monthly_Amount { get; set; }
        public string ninthly_Amount { get; set; }
        public string tenthly_Amount { get; set; }
        public string thirteenthly_Amount { get; set; }
        public string weekly_Amount { get; set; }
        public string bi_Weekly_Amount { get; set; }
        public string pay_26_Amount { get; set; }
        public string pay_52_Amount { get; set; }
        public string calander_Amount { get; set; }

        public Int64 requested_Mode_id { get; set;  }
        public int requested_Form_id { get; set; }

        public IList<SelectListItem> mode_List { get; set; }
        public IList<SelectListItem> form_list { get; set; }

        public PremiumQuoteBilling()
        {
            mode_List = new List<SelectListItem>();
            form_list = new List<SelectListItem>();
        }
    }

    public enum Mode_E
    {
    Annually = 1,
    Monthly = 4,
    Quarterly = 3,
    Bi_Annual = 2,
    Weekly = 6,
    Biweekly = 7,
    Every9mths = 20,
    Every10mths = 21,
    Thirtteenly = 44,
    Pay26 = 25,
    Pay52 = 24,
    Calender = 26
    }

    public enum Form_E
    {
        Direct = 2,
        List_Bill = 5,
        Preauthorized_Collection = 26,
        Govt_Allot = 8,
        Credit_card = 9,
        Premium_Deposit_Fund = 12
    }
}
