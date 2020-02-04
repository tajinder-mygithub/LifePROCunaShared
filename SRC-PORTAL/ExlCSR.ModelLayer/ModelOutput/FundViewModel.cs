using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class FundViewModel
    {
        public FundViewModel()
        {
            this.FundTableData = new HashSet<FundTableData>();
        }

        public FundData fundData { get; set; }
        public double account_value { get; set; }
        public IEnumerable<FundTableData> FundTableData { get; set; }
        public ICollection<FundTableData> FundTableDatas { get; set; }
    }
}
