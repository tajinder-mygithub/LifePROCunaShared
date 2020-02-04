using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ExlCSR.ModelLayer
{
    public partial class PersonSearch : IValidatableObject
    {
        
        [Display(Name = "First Name")]
        //[RegularExpression("^[a-zA-Z ]*$", ErrorMessage = "Invalid First Name")]
        public string firstName { get; set; }

        
        [Display(Name = "Last Name")]
        //[RegularExpression("^[a-zA-Z ]*$", ErrorMessage = "Invalid Last Name")]
        public string lastName { get; set; }

        
        [Display(Name = "SSN Number")]
        [RegularExpression("^[0-9 ]*$", ErrorMessage = "Expect only Numeric")]
        public string ssn { get; set; }

        [Display(Name = "Date Of Birth")]
        //[RegularExpression("^([0-9]{2})\([0-9]{2})\([0-9]{4})$", ErrorMessage = "Invalid Date Of Birth")]
        public string dob { get; set; }

        public string gender { get; set; }

        [Display(Name = "ResidentState")]
        [RegularExpression("^[a-zA-Z0-9 ]*$", ErrorMessage = "Invalid ResidentState")]
        public string residentState { get; set; }

        [Display(Name = "Zip Code")]
        [RegularExpression("^[0-9]*$", ErrorMessage = "Expect only Numeric")]
        public string zip { get; set; }


        public IEnumerable<ValidationResult> Validate(ValidationContext context)
        {
            if (string.IsNullOrEmpty(firstName) && string.IsNullOrEmpty(lastName) && string.IsNullOrEmpty(ssn))
            {
                yield return new ValidationResult("Either First Name, Last Name or SSN must be supplied.", new[] { "firstName", "lastName", "ssn" }); // , "DOB", "SSN" });
            }
        }
    }
}
