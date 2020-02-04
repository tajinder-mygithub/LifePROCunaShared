using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Policy_summaryViewModel
    {
        public Policy_summaryViewModel()
        {
            this.policy_summary = new HashSet<Policy_summary>();
        }

        public Owner_data owner_data { get; set; }
        

        public IEnumerable<Policy_summary> policy_summary { get; set; }
        public ICollection<Policy_summary> policy_summarys { get; set; }
    }
}
