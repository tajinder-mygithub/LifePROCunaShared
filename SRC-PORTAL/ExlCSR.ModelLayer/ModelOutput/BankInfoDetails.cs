using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class BankInfoDetails
    {
        public string company_Code { get; set; }
        public string company_Name { get; set; }
        public string policy_Number { get; set; }
        public string account_Type { get; set; }
        public string aba_Number { get; set; }
        public string bank_Name { get; set; }
        public string account_Number { get; set; }
        public string end_Date{ get; set; }
        public string name_id { get; set; }
        public string purpose { get; set; }

        public ClientDashBoardViewModel clientDashBoardViewModel { get; set; }
    }
}
