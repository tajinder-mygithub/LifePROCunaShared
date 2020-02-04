
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class PersonSearchByPerson_SSNViewModel
    {
        public PersonSearchByPerson_SSNViewModel()
        {
            this.person = new HashSet<Person>();
        }
        public  IEnumerable<Person> person { get; set; }
        public  ICollection<Person> persons { get; set; }
    }
}
