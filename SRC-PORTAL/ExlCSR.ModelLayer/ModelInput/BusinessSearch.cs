using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;



namespace ExlCSR.ModelLayer
{
    public partial class BusinessSearch : IValidatableObject
    {
        
        [Display(Name = "Business Name")]
        //[RegularExpression("^[a-zA-Z0-9 ]*$", ErrorMessage = "Invalid Business Name")]
        public string businessName { get; set; }
        
                
        [Display(Name = "Tax ID Number")]
        [RegularExpression("^[0-9 ]*$", ErrorMessage = "Expect only Numeric")]
        public string ssn_B { get; set; }

        [Display(Name = "Zip Code")]
        [RegularExpression("^[0-9 ]*$", ErrorMessage = "Expect only Numeric")]
        public string zipB { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext context)
        {
            if (string.IsNullOrEmpty(businessName) && string.IsNullOrEmpty(ssn_B))
            {
                yield return new ValidationResult("Either Business Name or Tax ID must be supplied.", new[] { "businessName", "ssn_B" }); // , "DOB", "SSN" });
            }
        }
        
    }
}
