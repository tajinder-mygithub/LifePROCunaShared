using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Death_benifit
    {
        public Death_benifit()
        {
            this.dB_Policy_coverages = new HashSet<DB_Policy_coverages>();
            this.dbendiscriptions = new HashSet<Death_benifit_Discription>();
            this.deathBenifitTables = new HashSet<DeathBenifitTable>();
        }

        public string effictive_Date { get; set; }
        public string db_Value { get; set; }
       
        public string ac_Value { get; set; }
        public string return_Prem { get; set; }
        public string inherent_Ratchet { get; set; }
        public string GMDB_Rider { get; set; }
        public string inherent_Rider { get; set; }
        public string optional_Ratchet { get; set; }
        public string ep_Rider { get; set; }
        public string LR_Amount { get; set; }

        public IEnumerable<DB_Policy_coverages> dB_Policy_coverages { get; set; }
        public ICollection<DB_Policy_coverages> dB_Policy_coverage { get; set; }
        public IEnumerable<Death_benifit_Discription> dbendiscriptions { get; set; }
        public ICollection<Death_benifit_Discription> dbendiscription { get; set; }

        public IEnumerable<DeathBenifitTable> deathBenifitTables { get; set; }
        public ICollection<DeathBenifitTable> deathBenifitTable { get; set; }
        
       
        public string a_total_DB { get; set; }
    }
}
