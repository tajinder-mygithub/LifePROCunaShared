using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Additional_addresses
    {
        public string effective_Date { get; set; }
        public string cancel_Date { get; set; }
        public string addr_Code { get; set; }
        public string addr_Type { get; set; }
        public string address { get; set; }
        public string city { get; set; }
        public string state { get; set; }
        public string zip { get; set; }
        public string phone_Number { get; set; }
        public string bad_Address { get; set; }

        public ClientDashBoardViewModel clientDashBoardViewModel { get; set; }


    }
}
