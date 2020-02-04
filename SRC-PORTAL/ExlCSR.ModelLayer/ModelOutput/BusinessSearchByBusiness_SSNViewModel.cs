using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class BusinessSearchByBusiness_SSNViewModel
    {
        public BusinessSearchByBusiness_SSNViewModel()
        {
            this.business = new HashSet<Business>();
        }
        public virtual IEnumerable<Business> business { get; set; }
        public virtual ICollection<Business> businesses {get; set;}

    }
}
