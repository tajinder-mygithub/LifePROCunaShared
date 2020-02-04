using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public partial class PolicySearch
    {
        [Required(ErrorMessage = "Policy Number must be supplied")]
        [Display(Name = "Policy Number")]
        [RegularExpression("^[a-zA-Z0-9 ]*$", ErrorMessage = "Invalid Policy")]
        public string policyNumber { get; set; }
    }
}
