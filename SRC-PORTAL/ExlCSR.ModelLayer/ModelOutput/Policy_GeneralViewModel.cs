using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace ExlCSR.ModelLayer
{
    public class Policy_GeneralViewModel
    {        
        public PremiumQuoteBilling PremiumQuoteBilling { get; set; }
        
        public FundViewModel fundViewModel { get; set; }
        public SurrenderQuoteData surrenderQuoteData { get; set; }
        public PolicyGeneral_output policyGeneral_output { get; set; }
        public Death_benifit death_benifit { get; set; }
        public string name_ID { get; set; }
        public string company_Code { get; set; }

        public IEnumerable<BankInfoDetails> bankInfo { get; set; }       


        public IList<SelectListItem> Policy_list { get; set; }
        public string requested_Policy { get; set; }
    }
}
