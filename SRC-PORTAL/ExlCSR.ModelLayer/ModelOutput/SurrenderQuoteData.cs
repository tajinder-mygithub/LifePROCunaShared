using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class SurrenderQuoteData
    {
        public string company_code { get; set; }
        public string policy_number { get; set; }
        public string effictive_Date { get; set; }
        public string quotedAsOf { get; set; }
        public string accum_Value { get; set; }
        public string total_Free { get; set; }
        public string surr_Charge { get; set; }
        public string surr_Value { get; set; }
        public string Adjustments { get; set; }
        public string Withdrawals { get; set; }
        public string prem_Paid { get; set; }
        public string interest_Rate { get; set; }
        public string MVA_Amount { get; set; }

        public string cashValue { get; set; }
        public string dividend_Acc { get; set; }
        public string dividend_Adj { get; set; }
        public string cashValue_PUA { get; set; }
        public string cashValue_OYT { get; set; }
        public string unapplied_Cash { get; set; }
        public string IBAType_01 { get; set; }
        public string IBAType_02 { get; set; }
        public string unprocessed_Premium { get; set; }
        public string federal_Withholding { get; set; }
        public string state_Withholding { get; set; }
        public string totalSurrAmt { get; set; }        

    }
}
