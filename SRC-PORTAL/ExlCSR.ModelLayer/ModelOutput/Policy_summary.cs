using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class Policy_summary
    {       

        public string company_Code { get; set; }
        public string company_Name { get; set; }
        public string policy_Number { get; set; }
        public string status { get; set; }
        public string plan_Code { get; set; }
        public double account_Value { get; set; }
        public string account_Values { get; set; }
        
        public double face_Amount { get; set; }
        public string face_Amounts { get; set; }
        public string total_face_Amount { get; set; }
        public string billing { get; set; }
        public string agent { get; set; }
        public string name_Id { get; set; }
        public string p_mode { get; set; }
        public string p_Amount { get; set; }
        public string p_Method { get; set; }
        public string paid_to_Date { get; set; }
        
        public Policy_summaryViewModel policy_summaryViewModel { get; set; }
    }
}
