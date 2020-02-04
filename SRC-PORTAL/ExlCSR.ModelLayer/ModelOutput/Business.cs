using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Business
    {
        public string name { get; set; }
        public string name_Id { get; set; }
        public string tax_Id { get; set; }
        public string dob { get; set; }
        public string gender { get; set; }
        public string address { get; set; }
        public virtual BusinessSearchByBusiness_SSNViewModel BusinessSearchByBusiness_Ssn { get; set; }
    }
}
