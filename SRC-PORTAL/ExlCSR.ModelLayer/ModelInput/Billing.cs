using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Billing
    {
        public string company_code { get; set; }
        public string policy_number { get; set; }
        public string effictive_Date { get; set; }
        public Int64 requested_Mode { get; set; }
        public int requested_Form { get; set; }
        public string payment_Mode_Flag { get; set; }
        public string mode_Prem { get; set; }
    }
}
