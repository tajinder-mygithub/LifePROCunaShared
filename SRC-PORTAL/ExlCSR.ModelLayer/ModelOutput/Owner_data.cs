using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Owner_data
    {
        public string ownerName { get; set; }
        public string ssn { get; set; }
        public string dob { get; set; }
        public string gender { get; set; }
        public string address { get; set; }
        public string city_State_Zip { get; set; }
        public string nameId { get; set; }
        public string phone_No { get; set; }
        public string email_ID { get; set; }
        public string deceased { get; set; }

        public Policy_summaryViewModel policy_summaryViewModel { get; set; }

    }
}
