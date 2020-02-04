using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace ExlCSR.ModelLayer
{
    public class CustomerSearchByPolicyViewModel 
    {
        public CustomerSearchByPolicyViewModel()
        {
            this.customer = new HashSet<Customer>();
        }
        public  IEnumerable<Customer> customer { get; set; }
        public  ICollection<Customer> customers { get; set; }
    }

    
}
