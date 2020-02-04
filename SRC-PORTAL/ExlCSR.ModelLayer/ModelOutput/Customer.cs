using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Customer
    {
        
            public string companyName { get; set; }
            public string Company_code { get; set; }
            public string policyNumber { get; set; }
            public string ownerName { get; set; }
            public string address { get; set; }
            public string nameID { get; set; }
            public CustomerSearchByPolicyViewModel customerSearchByPolicy { get; set; }
    }
}
