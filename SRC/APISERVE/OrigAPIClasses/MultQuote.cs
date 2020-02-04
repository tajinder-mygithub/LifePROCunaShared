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
*  SR#              INIT      DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20070806-003-01  DAR/JWS   01/15/08    Initial implementation  
*  20100204-002-01  DAR       05/10/10    Health Requote enhancements
*  20110202-002-01  DAR       07/25/11    Health Premium Quote - New Policy Enhancement                                    
*  20110621-005-01  DAR       07/28/11    Enhancements to quote benefit changes
*  20111117-006-01  DAR       05/18/12    Retrofit in 20110621-005-01 and 20110202-002-01
*  20130307-007-01  DAR       03/13/13    Fix for missing variable creation
*  20131015-001-01  DAR       10/28/13    Support WCF and Web Services
*/


using System;
using LPNETAPI ; 
using System.Data;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro 
{
	/// <summary>
	/// Summary description for MultQuote.
	/// </summary>

	public class MultQuote : IMultQuote  
	{
		OMULTDVR apiMultQuote ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 
        private const int CoverageMax = 99;  
        private const int NameMax = 20; 
        private const int ModalMax = 20;
        private const int TargetMax = 10;
        private const int KDefMax = 1000;  

		public BaseResponse Init (string userType)
		{
			UserType = userType ; 
			apiMultQuote = new OMULTDVR(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ;
			outProps.ReturnCode = apiMultQuote.getReturnCode() ; 
			outProps.ErrorMessage = apiMultQuote.getErrorMessage() ;
            return outProps;  

		}
		public void Dispose() 
		{
			apiMultQuote.Dispose(); 
			apiMultQuote = null ; 
		}

        public MultipleInsuredQuoteRequest LoadWithTarget(string company, string policy, int effectivedate, string [] targetBenefitCode, double [] targetMaxBenefit, 
                                              out int returncode, out string message)
        {
            MultipleInsuredQuoteRequest inProps = new MultipleInsuredQuoteRequest();

            apiMultQuote.setCompanyCode(company);
            apiMultQuote.setPolicyNumber(policy);
            apiMultQuote.setEffectiveDate(effectivedate);

            for (int i = 0; i < TargetMax; i++)
            {
                // We need to pass in what we are going to load ...  
                apiMultQuote.setTargetBenefitCode(i + 1, targetBenefitCode[i]);
                apiMultQuote.setTargetMaxBenefit(i + 1, targetMaxBenefit[i]);  
            }

            apiMultQuote.LoadWithTarget();  

            LoadOutputHandling(company, policy, effectivedate, inProps, out returncode, out message);


            return inProps; 
            
           
        }


        public MultipleInsuredQuoteRequest LoadExistingBenefits(string company, string policy, int effectivedate, out int returncode, out string message)
        {
            MultipleInsuredQuoteRequest inProps = new MultipleInsuredQuoteRequest();

            apiMultQuote.setCompanyCode(company);
            apiMultQuote.setPolicyNumber(policy);
            apiMultQuote.setEffectiveDate(effectivedate);

            apiMultQuote.LoadExistingBenefits();

            LoadOutputHandling(company, policy, effectivedate, inProps, out returncode, out message);
            
            return inProps; 

        }

        private void LoadOutputHandling(string company, string policy, int effectivedate, MultipleInsuredQuoteRequest inProps, out int returncode, out string message)
        {
            returncode = apiMultQuote.getReturnCode();
            message = apiMultQuote.getErrorMessage();

            //if (returncode == 0)  // There are now warning codes, < 100, but even in a critical case we should init the inProps properties.  
            {
                inProps.CompanyCode = company;
                inProps.PolicyNumber = policy;
                inProps.EffectiveDate = effectivedate;

                // Fill inProps, giving client a start point for their own input revisions.  

                inProps.BenefitRequest = new string[CoverageMax];
                inProps.BenefitSequence = new short[CoverageMax];
                inProps.BenefitType = new string[CoverageMax];
                inProps.ValuePerUnit = new double[CoverageMax];
                inProps.UnitsOrFaceFlag = new string[CoverageMax];  
                inProps.CoverageID = new string[CoverageMax];

                inProps.Units = new double[CoverageMax];

                //inProps.NameID = new int[CoverageMax, NameMax];
                //inProps.Uwcls = new string[CoverageMax, NameMax];
                //inProps.AgeRateUp = new int[CoverageMax, NameMax];
                //inProps.TableRating = new string[CoverageMax, NameMax];
                //inProps.PctRating = new double[CoverageMax, NameMax];
                //inProps.PctDuration = new int[CoverageMax, NameMax];
                //inProps.Flat = new double[CoverageMax, NameMax];
                //inProps.FlatDuration = new int[CoverageMax, NameMax];
                //inProps.SecondFlat = new double[CoverageMax, NameMax];
                //inProps.SecondFlatDur = new int[CoverageMax, NameMax];
                //inProps.ExtendedKey = new string[CoverageMax, NameMax];
                //inProps.ExtendedKeyID = new string[CoverageMax, NameMax]; 
                //inProps.State = new string[CoverageMax, NameMax];
                //inProps.AreaCode = new int[CoverageMax, NameMax];

                inProps.NameID = new int[CoverageMax][];
                inProps.Uwcls = new string[CoverageMax][];
                // 20130307-003-01:  DAR.  Added initialization of Sex, DOB, and Issue Age 
                inProps.Sex = new string[CoverageMax] [];
                inProps.DOB = new int[CoverageMax] [];
                inProps.IssueAge = new int[CoverageMax] []; 
                // End 20130307-003-01 
                inProps.AgeRateUp = new int[CoverageMax][];
                inProps.TableRating = new string[CoverageMax][];
                inProps.PctRating = new double[CoverageMax][];
                inProps.PctDuration = new int[CoverageMax][];
                inProps.Flat = new double[CoverageMax][];
                inProps.FlatDuration = new int[CoverageMax][];
                inProps.SecondFlat = new double[CoverageMax][];
                inProps.SecondFlatDur = new int[CoverageMax][];
                inProps.ExtendedKey = new string[CoverageMax][];
                inProps.ExtendedKeyID = new string[CoverageMax][];
                inProps.State = new string[CoverageMax][];
                inProps.AreaCode = new int[CoverageMax][];


                for (int i = 0; i < CoverageMax; i++)
                {
                    //inProps.BenefitRequest[i] = "M"; // Set all benefits to a "Modify" default for existing benefits.  Other options that user 
                    // can specify are "A" for Add, and "D" for Delete.  Default will be modify, and if 
                    // no changes are made the policy will quote as is.  

                    inProps.BenefitRequest[i] = apiMultQuote.getBenefitRequest(i + 1);  
                    inProps.BenefitSequence[i] = apiMultQuote.getBenefitSequence(i + 1);
                    inProps.BenefitType[i] = apiMultQuote.getBenefitType(i + 1);
                    inProps.ValuePerUnit[i] = apiMultQuote.getValuePerUnit(i + 1);
                    inProps.UnitsOrFaceFlag[i] = apiMultQuote.getUnitsOrFaceFlag(i + 1); 
                    inProps.CoverageID[i] = apiMultQuote.getCoverageID(i + 1);
                    inProps.Units[i] = apiMultQuote.getUnits(i + 1);

                    inProps.NameID[i] = new int[NameMax];
                    inProps.Uwcls[i] = new string[NameMax];
                    inProps.Sex[i] = new string[NameMax];
                    inProps.DOB[i] = new int[NameMax];
                    inProps.IssueAge[i] = new int[NameMax]; 
                    inProps.AgeRateUp[i] = new int[NameMax];
                    inProps.TableRating[i] = new string[NameMax];
                    inProps.PctRating[i] = new double[NameMax];
                    inProps.PctDuration[i] = new int[NameMax];
                    inProps.Flat[i] = new double[NameMax];
                    inProps.FlatDuration[i] = new int[NameMax];
                    inProps.SecondFlat[i] = new double[NameMax];
                    inProps.SecondFlatDur[i] = new int[NameMax];
                    inProps.ExtendedKey[i] = new string[NameMax];
                    inProps.ExtendedKeyID[i] = new string[NameMax];
                    inProps.State[i] = new string[NameMax];
                    inProps.AreaCode[i] = new int[NameMax];

                    for (int i2 = 0; i2 < NameMax; i2++)
                    {
                        inProps.NameID[i] [i2] = apiMultQuote.getNameID(i + 1, i2 + 1);
                        inProps.Uwcls[i] [i2] = apiMultQuote.getUWCLS(i + 1, i2 + 1);
                        inProps.Sex[i] [i2] = apiMultQuote.getSex(i + 1, i2 + 1);
                        inProps.DOB[i] [i2] = apiMultQuote.getDOB(i + 1, i2 + 1);
                        inProps.IssueAge[i] [i2] = apiMultQuote.getIssueAge(i + 1, i2 + 1);  
                        inProps.AgeRateUp[i] [i2] = apiMultQuote.getAgeRateUp(i + 1, i2 + 1);
                        inProps.TableRating[i] [i2] = apiMultQuote.getTableRating(i + 1, i2 + 1);
                        inProps.PctRating[i] [i2] = apiMultQuote.getPCTRating(i + 1, i2 + 1);
                        inProps.PctDuration[i] [i2] = apiMultQuote.getPCTDuration(i + 1, i2 + 1);
                        inProps.Flat[i] [i2] = apiMultQuote.getFlat(i + 1, i2 + 1);
                        inProps.FlatDuration[i] [i2] = apiMultQuote.getFlatDuration(i + 1, i2 + 1);
                        inProps.SecondFlat[i] [i2] = apiMultQuote.get2ndFlat(i + 1, i2 + 1);
                        inProps.SecondFlatDur[i] [i2] = apiMultQuote.get2ndFlatDur(i + 1, i2 + 1);
                        inProps.ExtendedKey[i] [i2] = apiMultQuote.getExtendedKey(i + 1, i2 + 1);
                        inProps.ExtendedKeyID[i] [i2] = apiMultQuote.getExtendedKeyID(i + 1, i2 + 1);  
                        inProps.State[i] [i2] = apiMultQuote.getState(i + 1, i2 + 1);
                        inProps.AreaCode[i] [i2] = apiMultQuote.getAreaCode(i + 1, i2 + 1);

                    }
                }

                // Although Target amounts are primarily input to LoadWithTarget, we load them into 
                // inProps and return them because they may have been revised in processing.  

                inProps.TargetBenefitCode = new string[TargetMax];
                inProps.TargetMaxBenefit = new double[TargetMax];

                for (int i = 0; i < TargetMax; i++)
                {
                    inProps.TargetBenefitCode[i] = apiMultQuote.getTargetBenefitCode(i + 1);
                    inProps.TargetMaxBenefit[i] = apiMultQuote.getTargetMaxBenefit(i + 1);
                }

                inProps.KDDefinitions = new DataTable("KDDefinitions");
                inProps.KDDefinitions.Columns.Add("KeyID");
                inProps.KDDefinitions.Columns.Add("EntryType");
                inProps.KDDefinitions.Columns.Add("EntrySequence",typeof(Int16));
                inProps.KDDefinitions.Columns.Add("ParentDescriptionSequence",typeof(Int16));
                inProps.KDDefinitions.Columns.Add("EntryText");

                for (int i = 0; i < KDefMax; i++)
                {

                    if (apiMultQuote.getKDExtendedKeyID(i + 1).Trim() != "")
                    {
                        DataRow row = inProps.KDDefinitions.NewRow();

                        row[0] = apiMultQuote.getKDExtendedKeyID(i + 1);
                        row[1] = apiMultQuote.getKDEntryType(i + 1);
                        row[2] = apiMultQuote.getKDEntrySequence(i + 1);  
                        row[3] = apiMultQuote.getKDParentDescription(i + 1);
                        row[4] = apiMultQuote.getKDEntryText(i + 1);

                        inProps.KDDefinitions.Rows.Add(row);
                    }

                }
            }
        }
        

		public MultipleInsuredQuoteResponse RunRequote (MultipleInsuredQuoteRequest inProps ) 
		{
            apiMultQuote.setFunction(inProps.Function); 
			apiMultQuote.setCompanyCode(inProps.CompanyCode);
			apiMultQuote.setPolicyNumber(inProps.PolicyNumber);
			apiMultQuote.setEffectiveDate(inProps.EffectiveDate);

            apiMultQuote.setProductID(inProps.ProductID);
            apiMultQuote.setBillingForm(inProps.BillingForm);  

            for (int i = 0; i < CoverageMax; i++)
            {
                apiMultQuote.setBenefitRequest(i + 1, inProps.BenefitRequest[i]);  
                apiMultQuote.setBenefitSequence(i + 1, inProps.BenefitSequence[i]);  
                apiMultQuote.setCoverageID(i + 1, inProps.CoverageID[i]);
                apiMultQuote.setUnits(i + 1, inProps.Units[i]);
                for (int i2 = 0; i2 < NameMax; i2++)
                {
                    apiMultQuote.setNameID(i + 1, i2 + 1, inProps.NameID[i] [i2]);
                    apiMultQuote.setUWCLS(i + 1, i2 + 1, inProps.Uwcls[i] [i2]);
                    apiMultQuote.setSex(i + 1, i2 + 1, inProps.Sex[i] [i2]);
                    apiMultQuote.setDOB(i + 1, i2 + 1, inProps.DOB[i] [i2]);
                    apiMultQuote.setIssueAge(i + 1, i2 + 1, inProps.IssueAge[i] [i2]); 
                    apiMultQuote.setAgeRateUp(i + 1, i2 + 1, inProps.AgeRateUp[i] [i2]);
                    apiMultQuote.setTableRating(i + 1, i2 + 1, inProps.TableRating[i] [i2]);
                    apiMultQuote.setPCTRating(i + 1, i2 + 1, inProps.PctRating[i] [i2]);
                    apiMultQuote.setPCTDuration(i + 1, i2 + 1, inProps.PctDuration[i] [i2]);
                    apiMultQuote.setFlat(i + 1, i2 + 1, inProps.Flat[i] [i2]);
                    apiMultQuote.setFlatDuration(i + 1, i2 + 1, inProps.FlatDuration[i] [i2]);
                    apiMultQuote.set2ndFlat(i + 1, i2 + 1, inProps.SecondFlat[i] [i2]);
                    apiMultQuote.set2ndFlatDur(i + 1, i2 + 1, inProps.SecondFlatDur[i] [i2]);
                    apiMultQuote.set2ndFlatDur(i + 1, i2 + 1, inProps.SecondFlatDur[i] [i2]);
                    apiMultQuote.setExtendedKey(i + 1, i2 + 1, inProps.ExtendedKey[i] [i2]);
                    apiMultQuote.setState(i + 1, i2 + 1, inProps.State[i] [i2]);
                    apiMultQuote.setAreaCode(i + 1, i2 + 1, inProps.AreaCode[i] [i2]);
                }
            }

			apiMultQuote.RunRequote(); 

			MultipleInsuredQuoteResponse outProps = new MultipleInsuredQuoteResponse() ;

            outProps.EffectiveDateUsed = apiMultQuote.getEffectiveDateUsed();
            outProps.LifePROMessageNumber = apiMultQuote.getLifePROMessageNumber();
            outProps.CurrPolcTotal = apiMultQuote.getCurrPolcTotal(); 
            outProps.QuotePolcTotal = apiMultQuote.getQuotePolcTotal();  
            outProps.ReturnCode = apiMultQuote.getReturnCode(); 
            outProps.ErrorMessage = apiMultQuote.getErrorMessage();  

            outProps.ModalPremiumDescription = new string[ModalMax];
            outProps.ModalPremiumCode = new string[ModalMax];  
            outProps.ModalPremiumAmount = new double[ModalMax];  

            for (int i = 0; i < ModalMax; i++)
            {
                outProps.ModalPremiumDescription[i] = apiMultQuote.getModalPremiumDescription(i + 1);
                outProps.ModalPremiumCode[i] = apiMultQuote.getModalPremiumCode(i + 1);  
                outProps.ModalPremiumAmount[i] = apiMultQuote.getModalPremiumAmount(i + 1);  
            }
           
			return outProps ; 
		}


	}
}
