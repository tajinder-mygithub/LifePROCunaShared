using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class FundTableData
    {
        public string fund_Id { get; set; }
        public string fund_Name { get; set; }
        public string interest_Rate { get; set; }
        public string units { get; set; }
        public string unit_Value { get; set; }
        public string fund_Value { get; set; }
        public string per_Of_Total { get; set; }
        public string fund_Type { get; set; }
    }
}
