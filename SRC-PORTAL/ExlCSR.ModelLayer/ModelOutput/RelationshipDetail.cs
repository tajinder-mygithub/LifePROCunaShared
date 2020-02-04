using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class RelationshipDetail
    {
        public string company_Code { get; set; }
        public string company_Name { get; set; }
        public string policy_Number { get; set; }
        public string benefit { get; set; }
        public string status { get; set; }
        public string relationship { get; set; }
        public string Name_Id { get; set; }

        public ClientDashBoardViewModel clientDashBoardViewModel { get; set; }
    }
}
