using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class PolicySearchByNumber
    {
        public string carrierCode { get; set; }
        public string policyNumber { get; set; }
        public string policyStatus { get; set; }
        public string productCode { get; set; }
        public string billingStatus { get; set; }
        public string issueDate { get; set; }
        public string paidToDate { get; set; }
    }
}
