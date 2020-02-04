﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class ClientDashBoardPerson
    {
        public string ownerName { get; set; }
        public string ssn { get; set; }
        public string dob { get; set; }
        public string gender { get; set; }
        public string address { get; set; }
        public string city_State_Zip { get; set; }
        public string nameId { get; set; }

        public ClientDashBoardViewModel clientDashBoardViewModel { get; set; }
    }
}
