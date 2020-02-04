using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class ClientDashBoardViewModel
    {

        public ClientDashBoardViewModel()
        {
            this.address = new HashSet<Additional_addresses>();
            this.bankInfo = new HashSet<BankInfoDetails>();
            this.relationshipDetail = new HashSet<RelationshipDetail>();
            
        }

        public string total_account_Value { get; set; }
        public string total_Face_Value { get; set; }
        public int total_seq { get; set; }

        public Policy_summaryViewModel policy_summaryViewModel { get; set; }

        public IEnumerable<Additional_addresses> address { get; set; }
        public ICollection<Additional_addresses> addresses { get; set; }

        public IEnumerable<BankInfoDetails> bankInfo { get; set; }
        public ICollection<BankInfoDetails> bankInfoDetails { get; set; }

        public IEnumerable<RelationshipDetail> relationshipDetail { get; set; }
        public ICollection<RelationshipDetail> relationshipDetails { get; set; }

    }
}
