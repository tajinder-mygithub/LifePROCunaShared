using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public class PolicyGeneral_output
    {
        public PolicyGeneral_output()
        {
            this.other_Insu_Details = new HashSet<Other_Insu_Details>();
            this.relationship_Details = new HashSet<Relationship_Details>();
            this.benefits = new HashSet<Benefits>();
            this.agents = new HashSet<Agent>();
            this.living_Benefits = new HashSet<Living_Benefits>();
        }

        public string policy_Number { get; set; }
        public string company_Code { get; set; }

        public string issue_Date { get; set; }
        public string billing_Status { get; set; }
        public string payment_Status { get; set; }
        public string plan_Code { get; set; }
        public string mode_Prem { get; set; }
        public string paid_to_Date { get; set; }
        public string contract_Status { get; set; }
        public string active_Loans { get; set; }
        public string expire_Date { get; set; }
        public string issue_Age { get; set; }
        public string active_Requests { get; set; }
        public string tax_Qual_Code { get; set; }
        public string policy_Code { get; set; }
        public string LOB { get; set; }
        public string dividend_Option { get; set; }
        public string MPR { get; set; }

        public string owner { get; set; }
        public string owner_DOB { get; set; }
        public string owner_TaxID { get; set; }
        public string owner_Gender { get; set; }
        public string owner_Age { get; set; }
        public string name_id { get; set; }

        public string primary_insured { get; set; }
        public string pi_DOB { get; set; }
        public string pi_TaxID { get; set; }
        public string pi_Gender { get; set; }

        public string annuitant { get; set; }
        public string annu_DOB { get; set; }
        public string annu_TaxID { get; set; }
        public string annu_Gender { get; set; }
        public string annu_Age { get; set; }

        public string servicing_Agent { get; set; }
        public string agent_Status { get; set; }
        public string agency { get; set; }
        public string Broker_Dealer { get; set; }

        public string bank_Name { get; set; }
        public string routing_Number { get; set; }
        public string account_Number { get; set; }
        public string end_Date { get; set; }
        public string account_Type { get; set; }
        public string purpose { get; set; }

        public IEnumerable<Other_Insu_Details> other_Insu_Details { get; set; }
        public IEnumerable<Relationship_Details> relationship_Details { get; set; }
        public IEnumerable<Benefits> benefits { get; set; }
        public IEnumerable<Living_Benefits> living_Benefits { get; set; }

        public Death_benifit death_benifit { get; set; }

        public IEnumerable<Agent> agents { get; set; }
    }
}
