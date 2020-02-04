/*@*****************************************************
/*@** 
/*@** Licensed Materials - Property of
/*@** ExlService Holdings, Inc.
/*@**  
/*@** (C) 1983-2013 ExlService Holdings, Inc.  All Rights Reserved.
/*@** 
/*@** Contains confidential and trade secret information.  
/*@** Copyright notice is precautionary only and does not
/*@** imply publication.
/*@** 
/*@*****************************************************

/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20060713-004-01   DAR   07/19/06    14.0 Base changes/additions
*  20080509-003-01   JWS   06/05/08    Correct two missing property inits
*  20100930-006-01   DAR   11/18/10    Correct handling of subscripts. 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/


using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro {
	/// <summary>
	/// Summary description for IllInp.
	/// </summary>
	public class IllInp :  IIllInp {
		OPILLINP apiIllInp ; 
		public static OAPPLICA apiApp ; 
		
		public string UserType ; 

		public BaseResponse Init (string userType) {
			UserType = userType ; 
			apiIllInp = new OPILLINP(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiIllInp.getReturnCode() ; 
			outProps.ErrorMessage = apiIllInp.getErrorMessage() ; 
            return outProps;  


		}
		public void Dispose() {
			apiIllInp.Dispose(); 
			apiIllInp = null ; 
		}

		public IllustrationInputResponse RetrieveParameters (IllustrationInputRequest inProps ) {

			//  Input assignments for server side objects 
			apiIllInp.setProductId(inProps.ProductId);
			apiIllInp.setIssueDate(inProps.IssueDate);
			apiIllInp.setIssueState(inProps.IssueState);
			apiIllInp.setIssueAge(inProps.IssueAge);
			apiIllInp.setBirthDate(inProps.BirthDate);
			apiIllInp.setSexCode(inProps.SexCode);
			apiIllInp.setUwcls(inProps.Uwcls);

			apiIllInp.RetrieveParameters(); 

			IllustrationInputResponse outProps = new IllustrationInputResponse() ; 
			outProps.ReturnCode = apiIllInp.getReturnCode();  
			outProps.ErrorMessage = apiIllInp.getErrorMessage().Trim();  

			outProps.Description = apiIllInp.getDescription();
			outProps.PolicyFormNum = apiIllInp.getPolicyFormNum();
			outProps.MinIssueAge = apiIllInp.getMinIssueAge();
			outProps.MaxIssueAge = apiIllInp.getMaxIssueAge();
			outProps.FaceType = apiIllInp.getFaceType();
			outProps.MinIssueAmt = apiIllInp.getMinIssueAmt();
			outProps.MaxIssueAmt = apiIllInp.getMaxIssueAmt();
			outProps.SexBasis = apiIllInp.getSexBasis();
			outProps.AgeBasis = apiIllInp.getAgeBasis();
			outProps.ParCode = apiIllInp.getParCode();
			outProps.NumberOfDivOptions = apiIllInp.getNumberOfDivOptions();
		
			int count = outProps.NumberOfDivOptions  ; 
			int i ; 
			outProps.DivOption = new short [count];  
			outProps.DivDescription = new string[count];  
			for (i=1;i<=count;i++) {
				outProps.DivOption[i-1] = apiIllInp.getDivOption(i);  
				outProps.DivDescription[i-1] = apiIllInp.getDivDescription(i);  
			}
			outProps.NumberOfSsTables = apiIllInp.getNumberOfSsTables();
			count = outProps.NumberOfSsTables ; 
			outProps.SsTable = new string[count];  
			outProps.SsPrct = new double[count];   
			for (i=1;i<=count;i++) {
				outProps.SsTable[i-1] = apiIllInp.getSsTable(i);  
				outProps.SsPrct[i-1] = apiIllInp.getSsPrct(i);  
			}
			outProps.NumberOfUwcls = apiIllInp.getNumberOfUwcls();
			count = outProps.NumberOfUwcls ; 
			outProps.UwclsCode = new string[count]; 
			outProps.UwclsDesc = new string[count];  
			for (i=1;i<=count;i++) {
				outProps.UwclsCode[i-1] = apiIllInp.getUwclsCode(i);  
				outProps.UwclsDesc[i-1] = apiIllInp.getUwclsDesc(i);  
			}
			
			outProps.UwclsRatingTable = apiIllInp.getUwclsRatingTable();
			outProps.UwclsFlat = apiIllInp.getUwclsFlat();
			outProps.UwclsMaxFlat = apiIllInp.getUwclsMaxFlat();
			outProps.LoansAvailable = apiIllInp.getLoansAvailable();
			outProps.MonthlyIncome = apiIllInp.getMonthlyIncome();
			outProps.MiAge1 = apiIllInp.getMiAge1();
			outProps.MiAge2 = apiIllInp.getMiAge2();
			outProps.MiAge3 = apiIllInp.getMiAge3();
			outProps.PartWdAllowed = apiIllInp.getPartWdAllowed();
			outProps.DbOptionsAllowed = apiIllInp.getDbOptionsAllowed();
			outProps.DbOption1 = apiIllInp.getDbOption1();
			outProps.DbDescription1 = apiIllInp.getDbDescription1();
			outProps.DbOption2 = apiIllInp.getDbOption2();
			outProps.DbDescription2 = apiIllInp.getDbDescription2();
			outProps.AllowOverrideInt = apiIllInp.getAllowOverrideInt();
			outProps.FollowIntPattern = apiIllInp.getFollowIntPattern();
			outProps.IntRate1 = apiIllInp.getIntRate1();
			outProps.IntDur1 = apiIllInp.getIntDur1();
			outProps.IntRate2 = apiIllInp.getIntRate2();
			outProps.IntDur2 = apiIllInp.getIntDur2();
			outProps.IntRate3 = apiIllInp.getIntRate3();
			outProps.IntDur3 = apiIllInp.getIntDur3();
			outProps.NumberOfRiders = apiIllInp.getNumberOfRiders();
			count = outProps.NumberOfRiders ; 
			outProps.RdPlanCode = new string[count] ; 
			outProps.RdDescription = new string[count]; 
			outProps.RdComponentType = new string[count];  
			outProps.RdMaximumNumber = new short[count];  
			outProps.RdMinIssAge = new short[count]; 
			outProps.RdMaxIssAge = new short[count]; 
			outProps.RdFaceType = new string[count]; 
			outProps.RdMinIssueAmt = new int[count]; 
			outProps.RdMaxIssueAmt = new int[count]; 
			outProps.RdSexBasis = new string[count]; 
			outProps.DefaultType = new string[count]; 
			outProps.AbsoluteValue = new double[count];  
			outProps.PercentValue = new short[count];
            outProps.RdNumberOfSsTables = new int[count];
            //outProps.RdSsTable = new string[count, 41]; 
            //outProps.RdSsPrct = new double[count, 41] ;
            //outProps.RdNumberOfUwcls = new int[count];
            //outProps.RdUwclsCode = new string[count, 15];  
            //outProps.RdUwclsDesc = new string[count,15];  
            //outProps.RdUwclsRatingTable = new string[count,15];  
            //outProps.RdUwclsFlat = new string[count,15];  
            //outProps.RdUwclsMaxFlat = new double[count,15];  

            outProps.RdSsTable = new string[count][];
            outProps.RdSsPrct = new double[count][];
            outProps.RdNumberOfUwcls = new int[count];
            outProps.RdUwclsCode = new string[count][];
            outProps.RdUwclsDesc = new string[count][];
            outProps.RdUwclsRatingTable = new string[count][];
            outProps.RdUwclsFlat = new string[count][];
            outProps.RdUwclsMaxFlat = new double[count][];  

			for (i=1;i<=count;i++) {  

				outProps.RdPlanCode[i-1] = apiIllInp.getRdPlanCode(i);
				outProps.RdDescription[i-1] = apiIllInp.getRdDescription(i);
				outProps.RdComponentType[i-1] = apiIllInp.getRdComponentType(i);
				outProps.RdMaximumNumber[i-1] = apiIllInp.getRdMaximumNumber(i);
				outProps.RdMinIssAge[i-1] = apiIllInp.getRdMinIssAge(i);
				outProps.RdMaxIssAge[i-1] = apiIllInp.getRdMaxIssAge(i);
				outProps.RdFaceType[i-1] = apiIllInp.getRdFaceType(i);
				outProps.RdMinIssueAmt[i-1] = apiIllInp.getRdMinIssueAmt(i);
				outProps.RdMaxIssueAmt[i-1] = apiIllInp.getRdMaxIssueAmt(i);
				outProps.RdSexBasis[i-1] = apiIllInp.getRdSexBasis(i);
				outProps.DefaultType[i-1] = apiIllInp.getDefaultType(i);
				outProps.AbsoluteValue[i-1] = apiIllInp.getAbsoluteValue(i);
				outProps.PercentValue[i-1] = apiIllInp.getPercentValue(i);

				outProps.RdNumberOfSsTables[i-1] = apiIllInp.getRdNumberOfSsTables(i);

                outProps.RdSsTable[i - 1] = new string[41];
                outProps.RdSsPrct[i - 1] = new double[41];   

				int count2 = outProps.RdNumberOfSsTables[i-1];  
				for (int i2=1;i2<=count2;i2++) {
					outProps.RdSsTable[i-1][i2-1] = apiIllInp.getRdSsTable(i,i2) ; 
					outProps.RdSsPrct[i-1][i2-1] = apiIllInp.getRdSsPrct(i,i2);
				}

				outProps.RdNumberOfUwcls[i-1] = apiIllInp.getRdNumberOfUwcls(i);
                //count2 = apiIllInp.getRdNumberOfUwcls(i);
                count2 = outProps.RdNumberOfUwcls[i - 1];

                outProps.RdUwclsCode[i - 1] = new string[15];
                outProps.RdUwclsDesc[i - 1] = new string[15];
                outProps.RdUwclsRatingTable[i - 1] = new string[15];
                outProps.RdUwclsFlat[i - 1] = new string[15];
                outProps.RdUwclsMaxFlat[i - 1] = new double[15];  


				for (int i2=1;i2<=count2;i2++) {
					outProps.RdUwclsCode[i-1][i2-1] = apiIllInp.getRdUwclsCode(i,i2);
					outProps.RdUwclsDesc[i-1][i2-1] = apiIllInp.getRdUwclsDesc(i,i2);  
					outProps.RdUwclsRatingTable[i-1][i2-1] = apiIllInp.getRdUwclsRatingTable(i,i2);  
					outProps.RdUwclsFlat[i-1][i2-1] = apiIllInp.getRdUwclsFlat(i,i2);
					outProps.RdUwclsMaxFlat[i-1][i2-1] = apiIllInp.getRdUwclsMaxFlat(i,i2);
				}

			}

			
			return outProps ; 
		
		}
	
	
	}
}
