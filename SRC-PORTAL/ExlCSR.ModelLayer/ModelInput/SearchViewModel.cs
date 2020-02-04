using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class SearchViewModel
    {
        public PersonSearch personSearch { get; set; }
        public BusinessSearch businessSearch { get; set; }
        public PolicySearch customerSearch { get; set; }                
    }
}
