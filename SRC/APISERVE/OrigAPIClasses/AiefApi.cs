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
*  20111018-004-02   JVR   02/23/12    Add cell phone number to Name / Address record 
*  20120326-004-01   DAR   05/25/12    Convert communication to WCF 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20161201-003-01   SAP   01/17/17    Added Personal And Business Email Address 
*  20161201-003-01   SAP   02/17/17    Corrected the movement of name 
*/



using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  

namespace PDMA.LifePro {
	/// <summary>
	/// The Agent Interface API, used to inquire on and update agent information 
	/// </summary>

	public class AiefApi : IAiefApi {
		OAIEFAPI apiAgent ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType ) {
			UserType = userType ; 
			apiAgent = new OAIEFAPI(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiAgent.getReturnCode() ; 
			outProps.ErrorMessage = apiAgent.getErrorMessage() ;
            return outProps; 

		}
		public void Dispose() {
			apiAgent.Dispose(); 
			apiAgent = null ; 
		}


		public BaseResponse RunInterfaceFunction (ref AgentRequest inProps ) {
			
			apiAgent.setNameDel(inProps.NameDel);
			apiAgent.setAddrDel(inProps.AddrDel);
			apiAgent.setMasterDel(inProps.MasterDel);
			apiAgent.setLicenseDel(inProps.LicenseDel);
			apiAgent.setContedDel(inProps.ContedDel);
			apiAgent.setContedH1Del(inProps.ContedH1Del);
			apiAgent.setContedH2Del(inProps.ContedH2Del);
			apiAgent.setAppointmentDel(inProps.AppointmentDel);
			apiAgent.setNASDDel(inProps.NASDDel);
			apiAgent.setCoursesDel(inProps.CoursesDel);
			apiAgent.setPrinciplerepDel(inProps.PrinciplerepDel);
			apiAgent.setPersonalinfoDel(inProps.PersonalinfoDel);
			apiAgent.setHierDel(inProps.HierDel);
			apiAgent.setVestDel(inProps.VestDel);
			apiAgent.setAffiliateDel(inProps.AffiliateDel);
			apiAgent.setFunctionType(inProps.FunctionType);
			apiAgent.setFunctionSubtype(inProps.FunctionSubtype);

			// For this object, only do a set when needed, because otherwise flags get set within OAIEFAPI that cause 
			// it to try to update every type of record.  
			
			if (Util.Format(apiAgent.getCompanyCode()) != Util.Format(inProps.CompanyCode)) 
				apiAgent.setCompanyCode(inProps.CompanyCode);
			if (Util.Format(apiAgent.getAgentNumber()) != Util.Format(inProps.AgentNumber))
				apiAgent.setAgentNumber(inProps.AgentNumber);
			if (Util.Format(apiAgent.getSsnTaxId()) != Util.Format(inProps.SsnTaxId))
				apiAgent.setSsnTaxId(inProps.SsnTaxId);
            //02172017 SAP 20161201-003-01 - Begin
            if (inProps.NameType == "B")
            {
                if (Util.Format(apiAgent.getBusinessName()) != Util.Format(inProps.BusinessName))
                    apiAgent.setBusinessName(inProps.BusinessName);
            }
            else
            {
                if (Util.Format(apiAgent.getNameLast()) != Util.Format(inProps.NameLast))
                    apiAgent.setNameLast(inProps.NameLast);
                if (Util.Format(apiAgent.getNameFirst()) != Util.Format(inProps.NameFirst))
                    apiAgent.setNameFirst(inProps.NameFirst);
                if (Util.Format(apiAgent.getNameMiddle()) != Util.Format(inProps.NameMiddle))
                    apiAgent.setNameMiddle(inProps.NameMiddle);
            }
            //if (Util.Format(apiAgent.getBusinessName()) != Util.Format(inProps.BusinessName))
            //    apiAgent.setBusinessName(inProps.BusinessName);
            //if (Util.Format(apiAgent.getNameLast()) != Util.Format(inProps.NameLast))
            //    apiAgent.setNameLast(inProps.NameLast);
            //if (Util.Format(apiAgent.getNameFirst()) != Util.Format(inProps.NameFirst))
            //    apiAgent.setNameFirst(inProps.NameFirst);
            //if (Util.Format(apiAgent.getNameMiddle()) != Util.Format(inProps.NameMiddle))
            //    apiAgent.setNameMiddle(inProps.NameMiddle);
            //02172017 SAP 20161201-003-01 - End
            if (Util.Format(apiAgent.getNameType()) != Util.Format(inProps.NameType))
				apiAgent.setNameType(inProps.NameType);
			if (apiAgent.getNameId() != inProps.NameId)
				apiAgent.setNameId(inProps.NameId);
			if (Util.Format(apiAgent.getNewSsnTin()) != Util.Format(inProps.NewSsnTin))
				apiAgent.setNewSsnTin(inProps.NewSsnTin);
			if (Util.Format(apiAgent.getNewBusName()) != Util.Format(inProps.NewBusName))
				apiAgent.setNewBusName(inProps.NewBusName);
			if (Util.Format(apiAgent.getNewLast()) != Util.Format(inProps.NewLast))
				apiAgent.setNewLast(inProps.NewLast);
			if (Util.Format(apiAgent.getNewFirst()) != Util.Format(inProps.NewFirst))
				apiAgent.setNewFirst(inProps.NewFirst);
            if (Util.Format(apiAgent.getNewMiddle()) != Util.Format(inProps.NewMiddle))
				apiAgent.setNewMiddle(inProps.NewMiddle);
			if (Util.Format(apiAgent.getNamePrefix()) != Util.Format(inProps.NamePrefix))
				apiAgent.setNamePrefix(inProps.NamePrefix);
			if (Util.Format(apiAgent.getNameSuffix()) != Util.Format(inProps.NameSuffix))
				apiAgent.setNameSuffix(inProps.NameSuffix);
			if (Util.Format(apiAgent.getNameSexCode()) != Util.Format(inProps.NameSexCode))
				apiAgent.setNameSexCode(inProps.NameSexCode);
			if (Util.Format(apiAgent.getNameDeceased()) != Util.Format(inProps.NameDeceased))
				apiAgent.setNameDeceased(inProps.NameDeceased);
			if (apiAgent.getDob() != inProps.Dob)
				apiAgent.setDob(inProps.Dob);
			if (Util.Format(apiAgent.getTaxStatus()) != Util.Format(inProps.TaxStatus))
				apiAgent.setTaxStatus(inProps.TaxStatus);
			if (Util.Format(apiAgent.getTaxWithholdingFlag()) != Util.Format(inProps.TaxWithholdingFlag))
				apiAgent.setTaxWithholdingFlag(inProps.TaxWithholdingFlag);
			if (apiAgent.getTaxCertificationDate() != inProps.TaxCertificationDate)
				apiAgent.setTaxCertificationDate(inProps.TaxCertificationDate);
			if (Util.Format(apiAgent.getTaxCertificationCode()) != Util.Format(inProps.TaxCertificationCode))
				apiAgent.setTaxCertificationCode(inProps.TaxCertificationCode);
			if (Util.Format(apiAgent.getDirectDepositFlag()) != Util.Format(inProps.DirectDepositFlag))
				apiAgent.setDirectDepositFlag(inProps.DirectDepositFlag);
			if (apiAgent.getNextPrenoteDate() != inProps.NextPrenoteDate)
				apiAgent.setNextPrenoteDate(inProps.NextPrenoteDate);
			if (apiAgent.getNewEndDate() != inProps.NewEndDate)
				apiAgent.setNewEndDate(inProps.NewEndDate);
            if (apiAgent.getEndDate() != inProps.EndDate)
                apiAgent.setEndDate(inProps.EndDate);
            //20170117 SAP 20161201-003-01 - Begin
            if (apiAgent.getPersonalEmailAdr() != inProps.PersonalEmailAdr)
                apiAgent.setPersonalEmailAdr(inProps.PersonalEmailAdr);
            if (apiAgent.getBusinessEmailAdr() != inProps.BusinessEmailAdr)
                apiAgent.setBusinessEmailAdr(inProps.BusinessEmailAdr);
            //20170117 SAP 20161201-003-01 - End
            if (apiAgent.getTranCode() != inProps.TranCode)
				apiAgent.setTranCode(inProps.TranCode);
			if (apiAgent.getBankNameId() != inProps.BankNameId)
				apiAgent.setBankNameId(inProps.BankNameId);
			if (Util.Format(apiAgent.getPayeeBankAccount()) != Util.Format(inProps.PayeeBankAccount))
				apiAgent.setPayeeBankAccount(inProps.PayeeBankAccount);
			if (apiAgent.getLastPrenoteDate() != inProps.LastPrenoteDate)
				apiAgent.setLastPrenoteDate(inProps.LastPrenoteDate);
			if (apiAgent.getPrenoteLagDays() != inProps.PrenoteLagDays)
				apiAgent.setPrenoteLagDays(inProps.PrenoteLagDays);
			if (apiAgent.getAddressId() != inProps.AddressId)
				apiAgent.setAddressId(inProps.AddressId);
			if (Util.Format(apiAgent.getNameAddr1()) != Util.Format(inProps.NameAddr1))
				apiAgent.setNameAddr1(inProps.NameAddr1);
			if (Util.Format(apiAgent.getNameAddr2()) != Util.Format(inProps.NameAddr2))
				apiAgent.setNameAddr2(inProps.NameAddr2);
			if (Util.Format(apiAgent.getNameAddr3()) != Util.Format(inProps.NameAddr3))
				apiAgent.setNameAddr3(inProps.NameAddr3);
			if (Util.Format(apiAgent.getNameCity()) != Util.Format(inProps.NameCity))
				apiAgent.setNameCity(inProps.NameCity);
			if (Util.Format(apiAgent.getNameState()) != Util.Format(inProps.NameState))
				apiAgent.setNameState(inProps.NameState);
			if (apiAgent.getZip() != inProps.Zip)
				apiAgent.setZip(inProps.Zip);
			if (apiAgent.getZip4() != inProps.Zip4)
				apiAgent.setZip4(inProps.Zip4);
			if (Util.Format(apiAgent.getNameCntry()) != Util.Format(inProps.NameCntry))
				apiAgent.setNameCntry(inProps.NameCntry);
			if (Util.Format(apiAgent.getNameCounty()) != Util.Format(inProps.NameCounty))
				apiAgent.setNameCounty(inProps.NameCounty);
			if (Util.Format(apiAgent.getCityCode()) != Util.Format(inProps.CityCode))
				apiAgent.setCityCode(inProps.CityCode);
			if (Util.Format(apiAgent.getCountyCode()) != Util.Format(inProps.CountyCode))
				apiAgent.setCountyCode(inProps.CountyCode);
			if (Util.Format(apiAgent.getAddressType()) != Util.Format(inProps.AddressType))
				apiAgent.setAddressType(inProps.AddressType);
			if (Util.Format(apiAgent.getAddressCode()) != Util.Format(inProps.AddressCode))
				apiAgent.setAddressCode(inProps.AddressCode);
            if (Util.Format(apiAgent.getBadAddressInd()) != Util.Format(inProps.BadAddressInd))
                apiAgent.setBadAddressInd(inProps.BadAddressInd);
            if (apiAgent.getCancelDate() != inProps.CancelDate)
				apiAgent.setCancelDate(inProps.CancelDate);
			if (apiAgent.getNewEffectiveDate() != inProps.NewEffectiveDate)
				apiAgent.setNewEffectiveDate(inProps.NewEffectiveDate);
            if (apiAgent.getEffectiveDate() != inProps.EffectiveDate)
                apiAgent.setEffectiveDate(inProps.EffectiveDate);
            if (apiAgent.getRecurringStartMonth() != inProps.RecurringStartMonth)
				apiAgent.setRecurringStartMonth(inProps.RecurringStartMonth);
			if (apiAgent.getRecurringStartDay() != inProps.RecurringStartDay)
				apiAgent.setRecurringStartDay(inProps.RecurringStartDay);
			if (apiAgent.getRecurringStopMonth() != inProps.RecurringStopMonth)
				apiAgent.setRecurringStopMonth(inProps.RecurringStopMonth);
			if (apiAgent.getRecurringStopDay() != inProps.RecurringStopDay)
				apiAgent.setRecurringStopDay(inProps.RecurringStopDay);
			if (apiAgent.getAreaCode() != inProps.AreaCode)
				apiAgent.setAreaCode(inProps.AreaCode);
			if (apiAgent.getTelePrefix() != inProps.TelePrefix)
				apiAgent.setTelePrefix(inProps.TelePrefix);
			if (apiAgent.getTeleNumber() != inProps.TeleNumber)
				apiAgent.setTeleNumber(inProps.TeleNumber);
			if (apiAgent.getFaxAreaCode() != inProps.FaxAreaCode)
				apiAgent.setFaxAreaCode(inProps.FaxAreaCode);
			if (apiAgent.getFaxTelePrefix() != inProps.FaxTelePrefix)
				apiAgent.setFaxTelePrefix(inProps.FaxTelePrefix);
			if (apiAgent.getFaxTeleNumber() != inProps.FaxTeleNumber)
				apiAgent.setFaxTeleNumber(inProps.FaxTeleNumber);
            if (apiAgent.getCellAreaCode() != inProps.CellAreaCode)
                apiAgent.setCellAreaCode(inProps.CellAreaCode);
            if (apiAgent.getCellTelePrefix() != inProps.CellTelePrefix)
                apiAgent.setCellTelePrefix(inProps.CellTelePrefix);
            if (apiAgent.getCellTeleNumber() != inProps.CellTeleNumber)
                apiAgent.setCellTeleNumber(inProps.CellTeleNumber);
			if (Util.Format(apiAgent.getAddrCompany()) != Util.Format(inProps.AddrCompany))
				apiAgent.setAddrCompany(inProps.AddrCompany);
			if (Util.Format(apiAgent.getAddrPolicy()) != Util.Format(inProps.AddrPolicy))
				apiAgent.setAddrPolicy(inProps.AddrPolicy);
			if (Util.Format(apiAgent.getStatusCode()) != Util.Format(inProps.StatusCode))
				apiAgent.setStatusCode(inProps.StatusCode);
			if (apiAgent.getStatusDate() != inProps.StatusDate)
				apiAgent.setStatusDate(inProps.StatusDate);
			if (Util.Format(apiAgent.getClassification1()) != Util.Format(inProps.Classification1))
				apiAgent.setClassification1(inProps.Classification1);
			if (Util.Format(apiAgent.getClassification2()) != Util.Format(inProps.Classification2))
				apiAgent.setClassification2(inProps.Classification2);
			if (Util.Format(apiAgent.getClassification3()) != Util.Format(inProps.Classification3))
				apiAgent.setClassification3(inProps.Classification3);
			if (apiAgent.getStartDate() != inProps.StartDate)
				apiAgent.setStartDate(inProps.StartDate);
			if (Util.Format(apiAgent.getBasicAsscAgent()) != Util.Format(inProps.BasicAsscAgent))
				apiAgent.setBasicAsscAgent(inProps.BasicAsscAgent);
			if (Util.Format(apiAgent.getDbaState()) != Util.Format(inProps.DbaState))
				apiAgent.setDbaState(inProps.DbaState);
			if (Util.Format(apiAgent.getCertificationCode()) != Util.Format(inProps.CertificationCode))
				apiAgent.setCertificationCode(inProps.CertificationCode);
			if (apiAgent.getContractDate() != inProps.ContractDate)
				apiAgent.setContractDate(inProps.ContractDate);

			if (Util.Format(apiAgent.getAgntReasonCode()) != Util.Format(inProps.AgntReasonCode))
				apiAgent.setAgntReasonCode(inProps.AgntReasonCode);
			if (Util.Format(apiAgent.getAutoIssueFlag()) != Util.Format(inProps.AutoIssueFlag))
				apiAgent.setAutoIssueFlag(inProps.AutoIssueFlag);
			if (Util.Format(apiAgent.getAgntDivisionCode()) != Util.Format(inProps.AgntDivisionCode))
				apiAgent.setAgntDivisionCode(inProps.AgntDivisionCode);
            if (Util.Format(apiAgent.getAgntConsolNum()) != Util.Format(inProps.AgntConsolNum))
                apiAgent.setAgntConsolNum(inProps.AgntConsolNum);

            // Inputs coming from the web service calls may not include initialized input arrays.  This may be valid 
            // if particular input is not required.  Use Throw-away catch blocks to keep from crashing on 
            // null input arrays or improperly sized arrays.  

            try
            {
                for (int i = 0; i < inProps.StateLicensed.Length; i++)
                    if (Util.Format(apiAgent.getStateLicensed(i + 1)) != Util.Format(inProps.StateLicensed[i]))
                        apiAgent.setStateLicensed(i + 1, inProps.StateLicensed[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseStatusCode.Length; i++)
                    if (Util.Format(apiAgent.getLicenseStatusCode(i + 1)) != Util.Format(inProps.LicenseStatusCode[i]))
                        apiAgent.setLicenseStatusCode(i + 1, inProps.LicenseStatusCode[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseReasonCode.Length; i++)
                    if (Util.Format(apiAgent.getLicenseReasonCode(i + 1)) != Util.Format(inProps.LicenseReasonCode[i]))
                        apiAgent.setLicenseReasonCode(i + 1, inProps.LicenseReasonCode[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseGranted.Length; i++)
                    if (apiAgent.getLicenseGranted(i + 1) != inProps.LicenseGranted[i])
                        apiAgent.setLicenseGranted(i + 1, inProps.LicenseGranted[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseExpires.Length; i++)
                    if (apiAgent.getLicenseExpires(i + 1) != inProps.LicenseExpires[i])
                        apiAgent.setLicenseExpires(i + 1, inProps.LicenseExpires[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ResidentCode.Length; i++)
                    if (Util.Format(apiAgent.getResidentCode(i + 1)) != Util.Format(inProps.ResidentCode[i]))
                        apiAgent.setResidentCode(i + 1, inProps.ResidentCode[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.Nasd.Length; i++)
                    if (Util.Format(apiAgent.getNasd(i + 1)) != Util.Format(inProps.Nasd[i]))
                        apiAgent.setNasd(i + 1, inProps.Nasd[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.Life.Length; i++)
                    if (Util.Format(apiAgent.getLife(i + 1)) != Util.Format(inProps.Life[i]))
                        apiAgent.setLife(i + 1, inProps.Life[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.Health.Length; i++)
                    if (Util.Format(apiAgent.getHealth(i + 1)) != Util.Format(inProps.Health[i]))
                        apiAgent.setHealth(i + 1, inProps.Health[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.Annuity.Length; i++)
                    if (Util.Format(apiAgent.getAnnuity(i + 1)) != Util.Format(inProps.Annuity[i]))
                        apiAgent.setAnnuity(i + 1, inProps.Annuity[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.BasicLtc.Length; i++)
                    if (Util.Format(apiAgent.getBasicLtc(i + 1)) != Util.Format(inProps.BasicLtc[i]))
                        apiAgent.setBasicLtc(i + 1, inProps.BasicLtc[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.BasicLastRenewal.Length; i++)
                    if (apiAgent.getBasicLastRenewal(i + 1) != inProps.BasicLastRenewal[i])
                        apiAgent.setBasicLastRenewal(i + 1, inProps.BasicLastRenewal[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.BasicNextRenewal.Length; i++)
                    if (apiAgent.getBasicNextRenewal(i + 1) != inProps.BasicNextRenewal[i])
                        apiAgent.setBasicNextRenewal(i + 1, inProps.BasicNextRenewal[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseNumber.Length; i++)
                    if (Util.Format(apiAgent.getLicenseNumber(i + 1)) != Util.Format(inProps.LicenseNumber[i]))
                        apiAgent.setLicenseNumber(i + 1, inProps.LicenseNumber[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.LicenseType.Length; i++)
                    if (Util.Format(apiAgent.getLicenseType(i + 1)) != Util.Format(inProps.LicenseType[i]))
                        apiAgent.setLicenseType(i + 1, inProps.LicenseType[i]);
            }
            catch { }  

			if (Util.Format(apiAgent.getMarketingCode()) != Util.Format(inProps.MarketingCode))
				apiAgent.setMarketingCode(inProps.MarketingCode);
			if (Util.Format(apiAgent.getAgentLevel()) != Util.Format(inProps.AgentLevel))
				apiAgent.setAgentLevel(inProps.AgentLevel);
			if (apiAgent.getStopDate() != inProps.StopDate)
				apiAgent.setStopDate(inProps.StopDate);
			if (Util.Format(apiAgent.getNewMarketingCode()) != Util.Format(inProps.NewMarketingCode))
				apiAgent.setNewMarketingCode(inProps.NewMarketingCode);
			if (Util.Format(apiAgent.getNewAgentLevel()) != Util.Format(inProps.NewAgentLevel))
				apiAgent.setNewAgentLevel(inProps.NewAgentLevel);
			if (apiAgent.getNewStopDate() != inProps.NewStopDate)
				apiAgent.setNewStopDate(inProps.NewStopDate);
			if (Util.Format(apiAgent.getReportDesc()) != Util.Format(inProps.ReportDesc))
				apiAgent.setReportDesc(inProps.ReportDesc);
			if (Util.Format(apiAgent.getRegionCode()) != Util.Format(inProps.RegionCode))
				apiAgent.setRegionCode(inProps.RegionCode);
			if (Util.Format(apiAgent.getDealCode()) != Util.Format(inProps.DealCode))
				apiAgent.setDealCode(inProps.DealCode);
			if (Util.Format(apiAgent.getAddlCommIndicator()) != Util.Format(inProps.AddlCommIndicator))
				apiAgent.setAddlCommIndicator(inProps.AddlCommIndicator);
			if (Util.Format(apiAgent.getAddlDealCode()) != Util.Format(inProps.AddlDealCode))
				apiAgent.setAddlDealCode(inProps.AddlDealCode);
			if (Util.Format(apiAgent.getPayCode()) != Util.Format(inProps.PayCode))
				apiAgent.setPayCode(inProps.PayCode);
			if (Util.Format(apiAgent.getPayFrequency()) != Util.Format(inProps.PayFrequency))
				apiAgent.setPayFrequency(inProps.PayFrequency);
			if (Util.Format(apiAgent.getAdvanceIndicator()) != Util.Format(inProps.AdvanceIndicator))
				apiAgent.setAdvanceIndicator(inProps.AdvanceIndicator);
			if (Util.Format(apiAgent.getAdvancePayFrequency()) != Util.Format(inProps.AdvancePayFrequency))
				apiAgent.setAdvancePayFrequency(inProps.AdvancePayFrequency);
			if (Util.Format(apiAgent.getHierarchyAgent()) != Util.Format(inProps.HierarchyAgent))
				apiAgent.setHierarchyAgent(inProps.HierarchyAgent);
			if (Util.Format(apiAgent.getHierarchyMarketCode()) != Util.Format(inProps.HierarchyMarketCode))
				apiAgent.setHierarchyMarketCode(inProps.HierarchyMarketCode);
			if (Util.Format(apiAgent.getHierarchyAgentLevel()) != Util.Format(inProps.HierarchyAgentLevel))
				apiAgent.setHierarchyAgentLevel(inProps.HierarchyAgentLevel);
			if (Util.Format(apiAgent.getFinancialAgent()) != Util.Format(inProps.FinancialAgent))
				apiAgent.setFinancialAgent(inProps.FinancialAgent);
			if (Util.Format(apiAgent.getAllocatedAgent()) != Util.Format(inProps.AllocatedAgent))
				apiAgent.setAllocatedAgent(inProps.AllocatedAgent);
			if (apiAgent.getAllocatedPercent() != inProps.AllocatedPercent)
				apiAgent.setAllocatedPercent(inProps.AllocatedPercent);
			if (apiAgent.getAllocatedAmount() != inProps.AllocatedAmount)
				apiAgent.setAllocatedAmount(inProps.AllocatedAmount);
			if (apiAgent.getDebitMaximum() != inProps.DebitMaximum)
				apiAgent.setDebitMaximum(inProps.DebitMaximum);
			if (apiAgent.getRecovPercent() != inProps.RecovPercent)
				apiAgent.setRecovPercent(inProps.RecovPercent);
			if (apiAgent.getRecovAmount() != inProps.RecovAmount)
				apiAgent.setRecovAmount(inProps.RecovAmount);
			if (apiAgent.getDeferredPercent() != inProps.DeferredPercent)
				apiAgent.setDeferredPercent(inProps.DeferredPercent);
			if (apiAgent.getDeferredAmount() != inProps.DeferredAmount)
				apiAgent.setDeferredAmount(inProps.DeferredAmount);
			if (Util.Format(apiAgent.getAdvancePointer()) != Util.Format(inProps.AdvancePointer))
				apiAgent.setAdvancePointer(inProps.AdvancePointer);
			if (Util.Format(apiAgent.getFicaInd()) != Util.Format(inProps.FicaInd))
				apiAgent.setFicaInd(inProps.FicaInd);
			if (Util.Format(apiAgent.getAddlUpHier()) != Util.Format(inProps.AddlUpHier))
				apiAgent.setAddlUpHier(inProps.AddlUpHier);
			if (Util.Format(apiAgent.getReportForm()) != Util.Format(inProps.ReportForm))
				apiAgent.setReportForm(inProps.ReportForm);
			if (Util.Format(apiAgent.getApplyToUnsecPolicy()) != Util.Format(inProps.ApplyToUnsecPolicy))
				apiAgent.setApplyToUnsecPolicy(inProps.ApplyToUnsecPolicy);
			if (Util.Format(apiAgent.getApplyToUnsecNonPol()) != Util.Format(inProps.ApplyToUnsecNonPol))
				apiAgent.setApplyToUnsecNonPol(inProps.ApplyToUnsecNonPol);
			if (Util.Format(apiAgent.getApplyToUnsecBalance()) != Util.Format(inProps.ApplyToUnsecBalance))
				apiAgent.setApplyToUnsecBalance(inProps.ApplyToUnsecBalance);
			if (apiAgent.getFicaPercent() != inProps.FicaPercent)
				apiAgent.setFicaPercent(inProps.FicaPercent);
			if (apiAgent.getFicaMaximum() != inProps.FicaMaximum)
				apiAgent.setFicaMaximum(inProps.FicaMaximum);
			if (Util.Format(apiAgent.getStatementAgent()) != Util.Format(inProps.StatementAgent))
				apiAgent.setStatementAgent(inProps.StatementAgent);
			if (Util.Format(apiAgent.getStatementInd()) != Util.Format(inProps.StatementInd))
				apiAgent.setStatementInd(inProps.StatementInd);
			if (apiAgent.getAllocRenewalPercent() != inProps.AllocRenewalPercent)
				apiAgent.setAllocRenewalPercent(inProps.AllocRenewalPercent);
			if (apiAgent.getAllocRenewalAmount() != inProps.AllocRenewalAmount)
				apiAgent.setAllocRenewalAmount(inProps.AllocRenewalAmount);
			if (Util.Format(apiAgent.getPayReason()) != Util.Format(inProps.PayReason))
				apiAgent.setPayReason(inProps.PayReason);
			if (Util.Format(apiAgent.getAgencyCode()) != Util.Format(inProps.AgencyCode))
				apiAgent.setAgencyCode(inProps.AgencyCode);
			if (apiAgent.getMga() != inProps.Mga)
				apiAgent.setMga(inProps.Mga);
			if (apiAgent.getControl() != inProps.Control)
				apiAgent.setControl(inProps.Control);
			if (apiAgent.getControlId() != inProps.ControlId)
				apiAgent.setControlId(inProps.ControlId);
			if (Util.Format(apiAgent.getServicingAgency()) != Util.Format(inProps.ServicingAgency))
				apiAgent.setServicingAgency(inProps.ServicingAgency);
			if (Util.Format(apiAgent.getMailSortKey()) != Util.Format(inProps.MailSortKey))
				apiAgent.setMailSortKey(inProps.MailSortKey);
			if (Util.Format(apiAgent.getAssignmentFlag()) != Util.Format(inProps.AssignmentFlag))
				apiAgent.setAssignmentFlag(inProps.AssignmentFlag);
			if (Util.Format(apiAgent.getReasonCode()) != Util.Format(inProps.ReasonCode))
				apiAgent.setReasonCode(inProps.ReasonCode);

			if (Util.Format(apiAgent.getDivisionIndicator()) != Util.Format(inProps.DivisionIndicator))
				apiAgent.setDivisionIndicator(inProps.DivisionIndicator);
			if (apiAgent.getProdPercent() != inProps.ProdPercent)
				apiAgent.setProdPercent(inProps.ProdPercent);
			if (Util.Format(apiAgent.getNetComm()) != Util.Format(inProps.NetComm))
				apiAgent.setNetComm(inProps.NetComm);
			if (Util.Format(apiAgent.getCommType()) != Util.Format(inProps.CommType))
				apiAgent.setCommType(inProps.CommType);
			if (Util.Format(apiAgent.getBonusAllowed()) != Util.Format(inProps.BonusAllowed))
				apiAgent.setBonusAllowed(inProps.BonusAllowed);
			if (apiAgent.getBonusLevel() != inProps.BonusLevel)
				apiAgent.setBonusLevel(inProps.BonusLevel);
			if (Util.Format(apiAgent.getBonusCode()) != Util.Format(inProps.BonusCode))
				apiAgent.setBonusCode(inProps.BonusCode);
			if (Util.Format(apiAgent.getDbBalIntFlag()) != Util.Format(inProps.DbBalIntFlag))
				apiAgent.setDbBalIntFlag(inProps.DbBalIntFlag);
			if (apiAgent.getDbBalIntPct() != inProps.DbBalIntPct)
				apiAgent.setDbBalIntPct(inProps.DbBalIntPct);
			if (Util.Format(apiAgent.getDfltCommOptn()) != Util.Format(inProps.DfltCommOptn))
				apiAgent.setDfltCommOptn(inProps.DfltCommOptn);
			if (Util.Format(apiAgent.getAllocationOption()) != Util.Format(inProps.AllocationOption))
				apiAgent.setAllocationOption(inProps.AllocationOption);
            if (Util.Format(apiAgent.getReserveFlag()) != Util.Format(inProps.ReserveFlag))
                apiAgent.setReserveFlag(inProps.ReserveFlag);
            if (Util.Format(apiAgent.getReserveRateID()) != Util.Format(inProps.ReserveRateID))
                apiAgent.setReserveRateID(inProps.ReserveRateID);
            if (apiAgent.getReserveFlatAmount() != inProps.ReserveFlatAmount)
                apiAgent.setReserveFlatAmount(inProps.ReserveFlatAmount);
            if (apiAgent.getReserveMaxBalance() != inProps.ReserveMaxBalance)
                apiAgent.setReserveMaxBalance(inProps.ReserveMaxBalance);
            if (apiAgent.getReserveMinBalance() != inProps.ReserveMinBalance)
                apiAgent.setReserveMinBalance(inProps.ReserveMinBalance);

			if (Util.Format(apiAgent.getVestMarketCode()) != Util.Format(inProps.VestMarketCode)  )
				apiAgent.setVestMarketCode(inProps.VestMarketCode);
			if (Util.Format(apiAgent.getVestAgentLevel()) != Util.Format(inProps.VestAgentLevel))  
				apiAgent.setVestAgentLevel(inProps.VestAgentLevel);
			if (Util.Format(apiAgent.getClassCode()) != Util.Format(inProps.ClassCode)) 
				apiAgent.setClassCode(inProps.ClassCode);
			if (apiAgent.getVestStartDate() != inProps.VestStartDate) 
				apiAgent.setVestStartDate(inProps.VestStartDate);
			if (Util.Format(apiAgent.getVestDealType()) != Util.Format(inProps.VestDealType))  
				apiAgent.setVestDealType(inProps.VestDealType);
			if (Util.Format(apiAgent.getVestOrRevCode()) != Util.Format(inProps.VestOrRevCode)) 
				apiAgent.setVestOrRevCode(inProps.VestOrRevCode);
			if (Util.Format(apiAgent.getVestDurationCode()) != Util.Format(inProps.VestDurationCode)) 	
				apiAgent.setVestDurationCode(inProps.VestDurationCode);
			if (apiAgent.getVestDuration() != inProps.VestDuration)  
				apiAgent.setVestDuration(inProps.VestDuration);
			if (apiAgent.getVestStopDate() != inProps.VestStopDate) 
				apiAgent.setVestStopDate(inProps.VestStopDate);
			if (apiAgent.getVestMaxAmount() != inProps.VestMaxAmount) 
				apiAgent.setVestMaxAmount(inProps.VestMaxAmount);
			if (apiAgent.getVestMaxBalance() != inProps.VestMaxBalance) 			
				apiAgent.setVestMaxBalance(inProps.VestMaxBalance);
			if (Util.Format(apiAgent.getVestCode()) != Util.Format(inProps.VestCode)) 
				apiAgent.setVestCode(inProps.VestCode);
			if (apiAgent.getVestPercent() != inProps.VestPercent) 
				apiAgent.setVestPercent(inProps.VestPercent);
			if (Util.Format(apiAgent.getVestRevToAgent()) != Util.Format(inProps.VestRevToAgent)) 
				apiAgent.setVestRevToAgent(inProps.VestRevToAgent);
			if (Util.Format(apiAgent.getVestRevToMarket()) != Util.Format(inProps.VestRevToMarket)) 
				apiAgent.setVestRevToMarket(inProps.VestRevToMarket);
			if (apiAgent.getVestRevToLevel() != inProps.VestRevToLevel) 
				apiAgent.setVestRevToLevel(inProps.VestRevToLevel);
			if (Util.Format(apiAgent.getVestCheckRevToAgent()) != Util.Format(inProps.VestCheckRevToAgent)) 
				apiAgent.setVestCheckRevToAgent(inProps.VestCheckRevToAgent);

            try
            {
                for (int i = 0; i < inProps.ContEdReqState.Length; i++)
                    if (Util.Format(apiAgent.getContEdReqState(i + 1)) != Util.Format(inProps.ContEdReqState[i]))
                        apiAgent.setContEdReqState(i + 1, inProps.ContEdReqState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdReqFlag.Length; i++)
                    if (Util.Format(apiAgent.getContEdReqFlag(i + 1)) != Util.Format(inProps.ContEdReqFlag[i]))
                        apiAgent.setContEdReqFlag(i + 1, inProps.ContEdReqFlag[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdReqStrtDate.Length; i++)
                    if (apiAgent.getContEdReqStrtDate(i + 1) != inProps.ContEdReqStrtDate[i])
                        apiAgent.setContEdReqStrtDate(i + 1, inProps.ContEdReqStrtDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdReqStopDate.Length; i++)
                    if (apiAgent.getContEdReqStopDate(i + 1) != inProps.ContEdReqStopDate[i])
                        apiAgent.setContEdReqStopDate(i + 1, inProps.ContEdReqStopDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdQualified.Length; i++)
                    if (Util.Format(apiAgent.getContEdQualified(i + 1)) != Util.Format(inProps.ContEdQualified[i]))
                        apiAgent.setContEdQualified(i + 1, inProps.ContEdQualified[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdNonQual.Length; i++)
                    if (Util.Format(apiAgent.getContEdNonQual(i + 1)) != Util.Format(inProps.ContEdNonQual[i]))
                        apiAgent.setContEdNonQual(i + 1, inProps.ContEdNonQual[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdPartnership.Length; i++)
                    if (Util.Format(apiAgent.getContEdPartnership(i + 1)) != Util.Format(inProps.ContEdPartnership[i]))
                        apiAgent.setContEdPartnership(i + 1, inProps.ContEdPartnership[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqState.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1ReqState(i + 1)) != Util.Format(inProps.ContEdH1ReqState[i]))
                        apiAgent.setContEdH1ReqState(i + 1, inProps.ContEdH1ReqState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqFlag.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1ReqFlag(i + 1)) != Util.Format(inProps.ContEdH1ReqFlag[i]))
                        apiAgent.setContEdH1ReqFlag(i + 1, inProps.ContEdH1ReqFlag[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqStrtDate.Length; i++)
                    if (apiAgent.getContEdH1ReqStrtDate(i + 1) != inProps.ContEdH1ReqStrtDate[i])
                        apiAgent.setContEdH1ReqStrtDate(i + 1, inProps.ContEdH1ReqStrtDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqStopDate.Length; i++)
                    if (apiAgent.getContEdH1ReqStopDate(i + 1) != inProps.ContEdH1ReqStopDate[i])
                        apiAgent.setContEdH1ReqStopDate(i + 1, inProps.ContEdH1ReqStopDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1Qualified.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1Qualified(i + 1)) != Util.Format(inProps.ContEdH1Qualified[i]))
                        apiAgent.setContEdH1Qualified(i + 1, inProps.ContEdH1Qualified[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1NonQual.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1NonQual(i + 1)) != Util.Format(inProps.ContEdH1NonQual[i]))
                        apiAgent.setContEdH1NonQual(i + 1, inProps.ContEdH1NonQual[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1Partnership.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1Partnership(i + 1)) != Util.Format(inProps.ContEdH1Partnership[i]))
                        apiAgent.setContEdH1Partnership(i + 1, inProps.ContEdH1Partnership[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqState.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1ReqState(i + 1)) != Util.Format(inProps.ContEdH1ReqState[i]))
                        apiAgent.setContEdH1ReqState(i + 1, inProps.ContEdH1ReqState[i]);
            }
            catch { }


            try
            {
                for (int i = 0; i < inProps.ContEdH1ReqState.Length; i++)
                    if (Util.Format(apiAgent.getContEdH1ReqState(i + 1)) != Util.Format(inProps.ContEdH1ReqState[i]))
                        apiAgent.setContEdH1ReqState(i + 1, inProps.ContEdH1ReqState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2ReqFlag.Length; i++)
                    if (Util.Format(apiAgent.getContEdH2ReqFlag(i + 1)) != Util.Format(inProps.ContEdH2ReqFlag[i]))
                        apiAgent.setContEdH2ReqFlag(i + 1, inProps.ContEdH2ReqFlag[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2ReqStrtDate.Length; i++)
                    if (apiAgent.getContEdH2ReqStrtDate(i + 1) != inProps.ContEdH2ReqStrtDate[i])
                        apiAgent.setContEdH2ReqStrtDate(i + 1, inProps.ContEdH2ReqStrtDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2ReqStopDate.Length; i++)
                    if (apiAgent.getContEdH2ReqStopDate(i + 1) != inProps.ContEdH2ReqStopDate[i])
                        apiAgent.setContEdH2ReqStopDate(i + 1, inProps.ContEdH2ReqStopDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2Qualified.Length; i++)
                    if (Util.Format(apiAgent.getContEdH2Qualified(i + 1)) != Util.Format(inProps.ContEdH2Qualified[i]))
                        apiAgent.setContEdH2Qualified(i + 1, inProps.ContEdH2Qualified[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2NonQual.Length; i++)
                    if (Util.Format(apiAgent.getContEdH2NonQual(i + 1)) != Util.Format(inProps.ContEdH2NonQual[i]))
                        apiAgent.setContEdH2NonQual(i + 1, inProps.ContEdH2NonQual[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ContEdH2Partnership.Length; i++)
                    if (Util.Format(apiAgent.getContEdH2Partnership(i + 1)) != Util.Format(inProps.ContEdH2Partnership[i]))
                        apiAgent.setContEdH2Partnership(i + 1, inProps.ContEdH2Partnership[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ApptState.Length; i++)
                    if (Util.Format(apiAgent.getApptState(i + 1)) != Util.Format(inProps.ApptState[i]))
                        apiAgent.setApptState(i + 1, inProps.ApptState[i]);
            }
            catch { }  

			//for (int i=0;i<inProps.ApptStatusCode.Length;i++)
			//	if (Util.Format(apiAgent.getApptStatusCode(i+1)) != Util.Format(inProps.ApptStatusCode[i]))
			//		apiAgent.setApptStatusCode(i+1,inProps.ApptStatusCode[i]);


            try
            {
                for (int i = 0; i < inProps.ApptStatusCode.Length; i++)
                    if (Util.Format(apiAgent.getApptStatusCode(i + 1)) != Util.Format(inProps.ApptStatusCode[i]))
                        apiAgent.setApptStatusCode(i + 1, inProps.ApptStatusCode[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ApptReasonCode.Length; i++)
                    if (Util.Format(apiAgent.getApptReasonCode(i + 1)) != Util.Format(inProps.ApptReasonCode[i]))
                        apiAgent.setApptReasonCode(i + 1, inProps.ApptReasonCode[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ApptGranted.Length; i++)
                    if (apiAgent.getApptGranted(i + 1) != inProps.ApptGranted[i])
                        apiAgent.setApptGranted(i + 1, inProps.ApptGranted[i]);
            }
            catch { }


            try
            {
                for (int i = 0; i < inProps.ApptExpires.Length; i++)
                    if (apiAgent.getApptExpires(i + 1) != inProps.ApptExpires[i])
                        apiAgent.setApptExpires(i + 1, inProps.ApptExpires[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.Affiliate.Length; i++)
                    if (Util.Format(apiAgent.getAffiliate(i + 1)) != Util.Format(inProps.Affiliate[i]))
                        apiAgent.setAffiliate(i + 1, inProps.Affiliate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.NASDState.Length; i++)
                    if (Util.Format(apiAgent.getNASDState(i + 1)) != Util.Format(inProps.NASDState[i]))
                        apiAgent.setNASDState(i + 1, inProps.NASDState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.NASDStatus.Length; i++)
                    if (Util.Format(apiAgent.getNASDStatus(i + 1)) != Util.Format(inProps.NASDStatus[i]))
                        apiAgent.setNASDStatus(i + 1, inProps.NASDStatus[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.NASDReason.Length; i++)
                    if (Util.Format(apiAgent.getNASDReason(i + 1)) != Util.Format(inProps.NASDReason[i]))
                        apiAgent.setNASDReason(i + 1, inProps.NASDReason[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.NASDDateGranted.Length; i++)
                    if (apiAgent.getNASDDateGranted(i + 1) != inProps.NASDDateGranted[i])
                        apiAgent.setNASDDateGranted(i + 1, inProps.NASDDateGranted[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.NASDDateExpired.Length; i++)
                    if (apiAgent.getNASDDateExpired(i + 1) != inProps.NASDDateExpired[i])
                        apiAgent.setNASDDateExpired(i + 1, inProps.NASDDateExpired[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.CourseActDate.Length; i++)
                    if (apiAgent.getCourseActDate(i + 1) != inProps.CourseActDate[i])
                        apiAgent.setCourseActDate(i + 1, inProps.CourseActDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.CourseCeuDate.Length; i++)
                    if (apiAgent.getCourseCeuDate(i + 1) != inProps.CourseCeuDate[i])
                        apiAgent.setCourseCeuDate(i + 1, inProps.CourseCeuDate[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.CourseNumber.Length; i++)
                    if (Util.Format(apiAgent.getCourseNumber(i + 1)) != Util.Format(inProps.CourseNumber[i]))
                        apiAgent.setCourseNumber(i + 1, inProps.CourseNumber[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.PrincipleState.Length; i++)
                    if (Util.Format(apiAgent.getPrincipleState(i + 1)) != Util.Format(inProps.PrincipleState[i]))
                        apiAgent.setPrincipleState(i + 1, inProps.PrincipleState[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.PrincipleAgent.Length; i++)
                    if (Util.Format(apiAgent.getPrincipleAgent(i + 1)) != Util.Format(inProps.PrincipleAgent[i]))
                        apiAgent.setPrincipleAgent(i + 1, inProps.PrincipleAgent[i]);
            }
            catch { }

            try
            {
                for (int i = 0; i < inProps.ParamResponse.Length; i++)
                    if (Util.Format(apiAgent.getParamResponse(i + 1)) != Util.Format(inProps.ParamResponse[i]))
                        apiAgent.setParamResponse(i + 1, inProps.ParamResponse[i]);
            }
            catch { }   

			apiAgent.RunInterfaceFunction(); 
		
			inProps.CompanyCode = apiAgent.getCompanyCode();  
			inProps.AgentNumber = apiAgent.getAgentNumber();  
			inProps.SsnTaxId = apiAgent.getSsnTaxId();  				
			inProps.BusinessName = apiAgent.getBusinessName();  
			inProps.NameLast = apiAgent.getNameLast();  
			inProps.NameFirst = apiAgent.getNameFirst();  
			inProps.NameMiddle = apiAgent.getNameMiddle();  
			inProps.NameType = apiAgent.getNameType();  
			inProps.NameId = apiAgent.getNameId();  
			inProps.NewSsnTin = apiAgent.getNewSsnTin();  
			inProps.NewBusName = apiAgent.getNewBusName();
			inProps.NewLast = apiAgent.getNewLast();
			inProps.NewFirst = apiAgent.getNewFirst();
			inProps.NewMiddle = apiAgent.getNewMiddle();
			inProps.NamePrefix = apiAgent.getNamePrefix();
			inProps.NameSuffix = apiAgent.getNameSuffix();
			inProps.NameSexCode = apiAgent.getNameSexCode();
			inProps.NameDeceased = apiAgent.getNameDeceased();
			inProps.Dob = apiAgent.getDob();
			inProps.TaxStatus = apiAgent.getTaxStatus();
			inProps.TaxWithholdingFlag = apiAgent.getTaxWithholdingFlag();
			inProps.TaxCertificationDate = apiAgent.getTaxCertificationDate();
			inProps.TaxCertificationCode = apiAgent.getTaxCertificationCode();
			inProps.DirectDepositFlag = apiAgent.getDirectDepositFlag();
			inProps.NextPrenoteDate = apiAgent.getNextPrenoteDate();
			inProps.EndDate = apiAgent.getEndDate();
            inProps.NewEndDate = apiAgent.getNewEndDate();
            //20170117 SAP 20161201-003-01 - Begin
            inProps.PersonalEmailAdr = apiAgent.getPersonalEmailAdr();
            inProps.BusinessEmailAdr = apiAgent.getBusinessEmailAdr();
            //20170117 SAP 20161201-003-01 - End
            inProps.TranCode = apiAgent.getTranCode();
			inProps.BankNameId = apiAgent.getBankNameId();
			inProps.PayeeBankAccount = apiAgent.getPayeeBankAccount();
			inProps.LastPrenoteDate = apiAgent.getLastPrenoteDate();
			inProps.PrenoteLagDays = apiAgent.getPrenoteLagDays();
			inProps.AddressId = apiAgent.getAddressId();
			inProps.NameAddr1 = apiAgent.getNameAddr1();
			inProps.NameAddr2 = apiAgent.getNameAddr2();
			inProps.NameAddr3 = apiAgent.getNameAddr3();
			inProps.NameCity = apiAgent.getNameCity();
			inProps.NameState = apiAgent.getNameState();
			inProps.Zip = apiAgent.getZip();
			inProps.Zip4 = apiAgent.getZip4();
			inProps.NameCntry = apiAgent.getNameCntry();
			inProps.NameCounty = apiAgent.getNameCounty();
			inProps.CityCode = apiAgent.getCityCode();
			inProps.CountyCode = apiAgent.getCountyCode();
			inProps.AddressType = apiAgent.getAddressType();
			inProps.AddressCode = apiAgent.getAddressCode();
            inProps.BadAddressInd = apiAgent.getBadAddressInd();
            inProps.CancelDate = apiAgent.getCancelDate();
			inProps.EffectiveDate = apiAgent.getEffectiveDate();
            inProps.NewEffectiveDate = apiAgent.getNewEffectiveDate();
            inProps.RecurringStartMonth = apiAgent.getRecurringStartMonth();
			inProps.RecurringStartDay = apiAgent.getRecurringStartDay();
			inProps.RecurringStopMonth = apiAgent.getRecurringStopMonth();
			inProps.RecurringStopDay = apiAgent.getRecurringStopDay();
			inProps.AreaCode = apiAgent.getAreaCode();
			inProps.TelePrefix = apiAgent.getTelePrefix();
			inProps.TeleNumber = apiAgent.getTeleNumber();
			inProps.FaxAreaCode = apiAgent.getFaxAreaCode();
			inProps.FaxTelePrefix = apiAgent.getFaxTelePrefix();
			inProps.FaxTeleNumber = apiAgent.getFaxTeleNumber();
            inProps.CellAreaCode = apiAgent.getCellAreaCode();
            inProps.CellTelePrefix = apiAgent.getCellTelePrefix();
            inProps.CellTeleNumber = apiAgent.getCellTeleNumber();
			inProps.AddrCompany = apiAgent.getAddrCompany();
			inProps.AddrPolicy = apiAgent.getAddrPolicy();
			inProps.StatusCode = apiAgent.getStatusCode();
			inProps.StatusDate = apiAgent.getStatusDate();
			inProps.Classification1 = apiAgent.getClassification1();
			inProps.Classification2 = apiAgent.getClassification2();
			inProps.Classification3 = apiAgent.getClassification3();
			inProps.StartDate = apiAgent.getStartDate();
			inProps.BasicAsscAgent = apiAgent.getBasicAsscAgent();
			inProps.DbaState = apiAgent.getDbaState();
			inProps.CertificationCode = apiAgent.getCertificationCode();
			inProps.ContractDate = apiAgent.getContractDate();
			inProps.AgntReasonCode = apiAgent.getAgntReasonCode();
			inProps.AutoIssueFlag = apiAgent.getAutoIssueFlag();
			inProps.AgntDivisionCode = apiAgent.getAgntDivisionCode();
            inProps.AgntConsolNum = apiAgent.getAgntConsolNum();

            if (inProps.FunctionType == "I")
            {
                inProps.NewSsnTin = apiAgent.getSsnTaxId();
                inProps.NewBusName = apiAgent.getBusinessName();
                inProps.NewLast = apiAgent.getNameLast();
                inProps.NewFirst = apiAgent.getNameFirst();
                inProps.NewMiddle = apiAgent.getNameMiddle();
                apiAgent.setNewSsnTin(apiAgent.getSsnTaxId());
                apiAgent.setNewBusName(apiAgent.getBusinessName());
                apiAgent.setNewLast(apiAgent.getNameLast());
                apiAgent.setNewFirst(apiAgent.getNameFirst());
                apiAgent.setNewMiddle(apiAgent.getNameMiddle());
                apiAgent.setNewEndDate(apiAgent.getEndDate());
            }

			inProps.MarketingCode = apiAgent.getMarketingCode();
			inProps.AgentLevel = apiAgent.getAgentLevel();
			inProps.StopDate = apiAgent.getStopDate();
			inProps.NewMarketingCode = apiAgent.getNewMarketingCode();
			inProps.NewAgentLevel = apiAgent.getNewAgentLevel();
			inProps.NewStopDate = apiAgent.getNewStopDate();
			inProps.ReportDesc = apiAgent.getReportDesc();
			inProps.RegionCode = apiAgent.getRegionCode();
			inProps.DealCode = apiAgent.getDealCode();
			inProps.AddlCommIndicator = apiAgent.getAddlCommIndicator();
			inProps.AddlDealCode = apiAgent.getAddlDealCode();
			inProps.PayCode = apiAgent.getPayCode();
			inProps.PayFrequency = apiAgent.getPayFrequency();
			inProps.AdvanceIndicator = apiAgent.getAdvanceIndicator();
			inProps.AdvancePayFrequency = apiAgent.getAdvancePayFrequency();
			inProps.HierarchyAgent = apiAgent.getHierarchyAgent();
			inProps.HierarchyMarketCode = apiAgent.getHierarchyMarketCode();
			inProps.HierarchyAgentLevel = apiAgent.getHierarchyAgentLevel();
			inProps.FinancialAgent = apiAgent.getFinancialAgent();
			inProps.AllocatedAgent = apiAgent.getAllocatedAgent();
			inProps.AllocatedPercent = apiAgent.getAllocatedPercent();
			inProps.AllocatedAmount = apiAgent.getAllocatedAmount();
			inProps.DebitMaximum = apiAgent.getDebitMaximum();
			inProps.RecovPercent = apiAgent.getRecovPercent();
			inProps.RecovAmount = apiAgent.getRecovAmount();
			inProps.DeferredPercent = apiAgent.getDeferredPercent();
			inProps.DeferredAmount = apiAgent.getDeferredAmount();
			inProps.AdvancePointer = apiAgent.getAdvancePointer();
			inProps.FicaInd = apiAgent.getFicaInd();
			inProps.AddlUpHier = apiAgent.getAddlUpHier();
			inProps.ReportForm = apiAgent.getReportForm();
			inProps.ApplyToUnsecPolicy = apiAgent.getApplyToUnsecPolicy();
			inProps.ApplyToUnsecNonPol = apiAgent.getApplyToUnsecNonPol();
			inProps.ApplyToUnsecBalance = apiAgent.getApplyToUnsecBalance();
			inProps.FicaPercent = apiAgent.getFicaPercent();
			inProps.FicaMaximum = apiAgent.getFicaMaximum();
			inProps.StatementAgent = apiAgent.getStatementAgent();
			inProps.StatementInd = apiAgent.getStatementInd();
			inProps.AllocRenewalPercent = apiAgent.getAllocRenewalPercent();
			inProps.AllocRenewalAmount = apiAgent.getAllocRenewalAmount();
			inProps.PayReason = apiAgent.getPayReason();
			inProps.AgencyCode = apiAgent.getAgencyCode();
			inProps.Mga = apiAgent.getMga();
			inProps.Control = apiAgent.getControl();
			inProps.ControlId = apiAgent.getControlId();
			inProps.ServicingAgency = apiAgent.getServicingAgency();
			inProps.MailSortKey = apiAgent.getMailSortKey();
			inProps.AssignmentFlag = apiAgent.getAssignmentFlag();
			inProps.ReasonCode = apiAgent.getReasonCode();

			inProps.DivisionIndicator = apiAgent.getDivisionIndicator();
			inProps.ProdPercent = apiAgent.getProdPercent();
			inProps.NetComm = apiAgent.getNetComm();
			inProps.CommType = apiAgent.getCommType();
			inProps.BonusAllowed = apiAgent.getBonusAllowed();
			inProps.BonusLevel = apiAgent.getBonusLevel();
			inProps.BonusCode = apiAgent.getBonusCode();
			inProps.DbBalIntFlag = apiAgent.getDbBalIntFlag();
			inProps.DbBalIntPct = apiAgent.getDbBalIntPct();
			inProps.DfltCommOptn = apiAgent.getDfltCommOptn();
			inProps.AllocationOption = apiAgent.getAllocationOption();
            inProps.ReserveFlag = apiAgent.getReserveFlag();
            inProps.ReserveRateID = apiAgent.getReserveRateID();
            inProps.ReserveFlatAmount = apiAgent.getReserveFlatAmount();
            inProps.ReserveMinBalance = apiAgent.getReserveMinBalance();
            inProps.ReserveMaxBalance = apiAgent.getReserveMaxBalance();
			
			inProps.VestMarketCode = apiAgent.getVestMarketCode();
			inProps.VestAgentLevel = apiAgent.getVestAgentLevel();
			inProps.ClassCode = apiAgent.getClassCode();
			inProps.VestStartDate = apiAgent.getVestStartDate();
			inProps.VestDealType = apiAgent.getVestDealType();
			inProps.VestOrRevCode = apiAgent.getVestOrRevCode();
			inProps.VestDurationCode = apiAgent.getVestDurationCode();
			inProps.VestDuration = apiAgent.getVestDuration();
			inProps.VestStopDate = apiAgent.getVestStopDate();
			inProps.VestMaxAmount = apiAgent.getVestMaxAmount();
			inProps.VestMaxBalance = apiAgent.getVestMaxBalance();
			inProps.VestCode = apiAgent.getVestCode();
			inProps.VestPercent = apiAgent.getVestPercent();
			inProps.VestRevToAgent = apiAgent.getVestRevToAgent();
			inProps.VestRevToMarket = apiAgent.getVestRevToMarket();
			inProps.VestRevToLevel = apiAgent.getVestRevToLevel();
			inProps.VestCheckRevToAgent = apiAgent.getVestCheckRevToAgent();


			int count ; 
			//string state ; 

			// We cannot dynamically determine end of array, because user may wish to add rows,  
			// and we do not normally provide user a way to resize array when using the apir objects.  
			// We need to use max array size possible instead.  

			/* 
			for (count=1;count<=50;count++) {
				state = apiAgent.getStateLicensed(count); 
				if (String.Compare(state,"  " )<= 0) 
					break;
			}
			count-- ;  // The length is the last non-blank position
			*/  
			count = 50 ; 
			inProps.StateLicensed = new string[count];  
			inProps.LicenseStatusCode = new string[count];  
			inProps.LicenseReasonCode = new string[count];  
			inProps.LicenseGranted = new int[count];  
			inProps.LicenseExpires = new int[count];  
			inProps.ResidentCode = new string[count];  
			inProps.Nasd = new string[count];  
			inProps.Life = new string[count];  
			inProps.Health = new string[count];  
			inProps.Annuity = new string[count];  
			inProps.BasicLtc = new string[count];  
			inProps.BasicLastRenewal = new int[count];  
			inProps.BasicNextRenewal = new int[count];  
			inProps.LicenseNumber = new string[count];  
			inProps.LicenseType = new string[count];  

			for (int i=1;i<=count;i++) {
				inProps.StateLicensed[i-1] = apiAgent.getStateLicensed(i);  
				inProps.LicenseStatusCode[i-1] = apiAgent.getLicenseStatusCode(i);
				inProps.LicenseReasonCode[i-1] = apiAgent.getLicenseReasonCode(i);
				inProps.LicenseGranted[i-1] = apiAgent.getLicenseGranted(i);
				inProps.LicenseExpires[i-1] = apiAgent.getLicenseExpires(i);
				inProps.ResidentCode[i-1] = apiAgent.getResidentCode(i);
				inProps.Nasd[i-1] = apiAgent.getNasd(i);
				inProps.Life[i-1] = apiAgent.getLife(i);
				inProps.Health[i-1] = apiAgent.getHealth(i);
				inProps.Annuity[i-1] = apiAgent.getAnnuity(i);
				inProps.BasicLtc[i-1] = apiAgent.getBasicLtc(i);
				inProps.BasicLastRenewal[i-1] = apiAgent.getBasicLastRenewal(i);
				inProps.BasicNextRenewal[i-1] = apiAgent.getBasicNextRenewal(i);
				inProps.LicenseNumber[i-1] = apiAgent.getLicenseNumber(i);
				inProps.LicenseType[i-1] = apiAgent.getLicenseType(i);
			}


			/*
			for (count=1;count<=50;count++) {
				state = apiAgent.getContEdReqState(count); 
				if (String.Compare(state,"  " )<= 0) 
					break;
			}
			count-- ;  // The length is the last non-blank position
			*/
			count = 50 ; 
	
			inProps.ContEdReqState = new string[count];  
			inProps.ContEdReqFlag = new string[count];  
			inProps.ContEdReqStrtDate = new int[count];  
			inProps.ContEdReqStopDate = new int[count];  
			inProps.ContEdQualified = new string[count];  
			inProps.ContEdNonQual = new string[count];  
			inProps.ContEdPartnership = new string[count];  

			for (int i=1;i<=count;i++) {
				inProps.ContEdReqState[i-1] = apiAgent.getContEdReqState(i);  
				inProps.ContEdReqFlag[i-1] = apiAgent.getContEdReqFlag(i);
				inProps.ContEdReqStrtDate[i-1] = apiAgent.getContEdReqStrtDate(i);
				inProps.ContEdReqStopDate[i-1] = apiAgent.getContEdReqStopDate(i);
				inProps.ContEdQualified[i-1] = apiAgent.getContEdQualified(i);
				inProps.ContEdNonQual[i-1] = apiAgent.getContEdNonQual(i);
				inProps.ContEdPartnership[i-1] = apiAgent.getContEdPartnership(i);
			}


			/* 
			for (count=1;count<=50;count++) {
				state = apiAgent.getContEdH1ReqState(count); 
				if (String.Compare(state,"  " )<= 0) 
					break;
			}
			count-- ;  // The length is the last non-blank position
			*/ 
			count = 50 ; 

	
			inProps.ContEdH1ReqState = new string[count];  
			inProps.ContEdH1ReqFlag = new string[count];  
			inProps.ContEdH1ReqStrtDate = new int[count];  
			inProps.ContEdH1ReqStopDate = new int[count];  
			inProps.ContEdH1Qualified = new string[count];  
			inProps.ContEdH1NonQual = new string[count];  
			inProps.ContEdH1Partnership = new string[count];  

			for (int i=1;i<=count;i++) {
				inProps.ContEdH1ReqState[i-1] = apiAgent.getContEdH1ReqState(i);  
				inProps.ContEdH1ReqFlag[i-1] = apiAgent.getContEdH1ReqFlag(i);
				inProps.ContEdH1ReqStrtDate[i-1] = apiAgent.getContEdH1ReqStrtDate(i);
				inProps.ContEdH1ReqStopDate[i-1] = apiAgent.getContEdH1ReqStopDate(i);
				inProps.ContEdH1Qualified[i-1] = apiAgent.getContEdH1Qualified(i);
				inProps.ContEdH1NonQual[i-1] = apiAgent.getContEdH1NonQual(i);
				inProps.ContEdH1Partnership[i-1] = apiAgent.getContEdH1Partnership(i);
			}

			/*
			for (count=1;count<=50;count++) {
				state = apiAgent.getContEdH2ReqState(count); 
				if (String.Compare(state,"  " )<= 0) 
					break;
			}
			count-- ;  // The length is the last non-blank position
			*/
			count = 50 ; 

	
			inProps.ContEdH2ReqState = new string[count];  
			inProps.ContEdH2ReqFlag = new string[count];  
			inProps.ContEdH2ReqStrtDate = new int[count];  
			inProps.ContEdH2ReqStopDate = new int[count];  
			inProps.ContEdH2Qualified = new string[count];  
			inProps.ContEdH2NonQual = new string[count];  
			inProps.ContEdH2Partnership = new string[count];  

			for (int i=1;i<=count;i++) {
				inProps.ContEdH2ReqState[i-1] = apiAgent.getContEdH2ReqState(i);  
				inProps.ContEdH2ReqFlag[i-1] = apiAgent.getContEdH2ReqFlag(i);
				inProps.ContEdH2ReqStrtDate[i-1] = apiAgent.getContEdH2ReqStrtDate(i);
				inProps.ContEdH2ReqStopDate[i-1] = apiAgent.getContEdH2ReqStopDate(i);
				inProps.ContEdH2Qualified[i-1] = apiAgent.getContEdH2Qualified(i);
				inProps.ContEdH2NonQual[i-1] = apiAgent.getContEdH2NonQual(i);
				inProps.ContEdH2Partnership[i-1] = apiAgent.getContEdH2Partnership(i);
			}

            /*
			for (count=1;count<=50;count++) {
				state = apiAgent.getApptState(count); 
				if (String.Compare(state,"  " )<= 0) 
					break;
			}
			count-- ;  // The length is the last non-blank position
            */

            count = 50;

            inProps.ApptState = new string[count];  
			inProps.ApptStatusCode = new string[count];  
			inProps.ApptReasonCode = new string[count];  
			inProps.ApptGranted = new int[count];  
			inProps.ApptExpires = new int[count];  
			inProps.CourseActDate = new int[count];  
			inProps.CourseCeuDate = new int[count];  
			inProps.CourseNumber = new string[count];  
			inProps.PrincipleState = new string[count];  
			inProps.PrincipleAgent = new string[count];  
      inProps.Affiliate = new string[count];  
			inProps.NASDState = new string[count];  
			inProps.NASDStatus = new string[count];  
			inProps.NASDReason = new string[count];  
			inProps.NASDDateGranted = new int[count];  
			inProps.NASDDateExpired = new int[count];

			inProps.ParamResponse = new string[16];   // Don't try to determine this array size, just use the max possible


			for (int i=1;i<=count;i++) {
				inProps.ApptState[i-1] = apiAgent.getApptState(i);  
				inProps.ApptStatusCode[i-1] = apiAgent.getApptStatusCode(i);
				inProps.ApptReasonCode[i-1] = apiAgent.getApptReasonCode(i);
				inProps.ApptGranted[i-1] = apiAgent.getApptGranted(i);
				inProps.ApptExpires[i-1] = apiAgent.getApptExpires(i);
				inProps.CourseActDate[i-1] = apiAgent.getCourseActDate(i);
				inProps.CourseCeuDate[i-1] = apiAgent.getCourseCeuDate(i);
				inProps.CourseNumber[i-1] = apiAgent.getCourseNumber(i);
				inProps.PrincipleState[i-1] = apiAgent.getPrincipleState(i);
				inProps.PrincipleAgent[i-1] = apiAgent.getPrincipleAgent(i);
				inProps.Affiliate[i-1] = apiAgent.getAffiliate(i);  
				inProps.NASDState[i-1] = apiAgent.getNASDState(i);  
				inProps.NASDStatus[i-1] = apiAgent.getNASDStatus(i);
				inProps.NASDReason[i-1] = apiAgent.getNASDReason(i);
				inProps.NASDDateGranted[i-1] = apiAgent.getNASDDateGranted(i);
				inProps.NASDDateExpired[i-1] = apiAgent.getNASDDateExpired(i);
			}

			for (int i=1;i<=16;i++) 
				inProps.ParamResponse[i-1] = apiAgent.getParamResponse(i);


			BaseResponse outProps = new BaseResponse() ; 
			outProps.ErrorMessage = apiAgent.getErrorMessage() ; 
			outProps.ReturnCode = apiAgent.getReturnCode() ; 

			return outProps ; 
		}


	}
}
