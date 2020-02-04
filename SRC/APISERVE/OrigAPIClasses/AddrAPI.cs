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
*  20050504-004-01   DAR   02/16/06    Initial implementation  
*  20091112-002-01   JWS   01/06/10    Address API modifications  
*  10110311-001-01   JWS   03/25/11    Add updatable Address Type setup 
*  20111018-004-02   JVR   02/23/12    Add cell phone number to Name / Address record 
*  20121126-001-01   DAR   11/26/12    Add Address "Add" function, along with additional properties. 
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20150601-002-01   AKR   01/14/16    New Co/Pol Methods Added 
*/


using System;
using LPNETAPI;
using System.ServiceModel;
using System.ServiceModel.Description;


namespace PDMA.LifePro
{
    /// <summary>
    /// The LifePRO Address API object, used to retrievea and update address information. 
    /// </summary>
    public class AddrAPI : IAddrAPI
    {
        OADDRAPI apiAddr;
        public static OAPPLICA apiApp;

        public string UserType;

        public BaseResponse Init(string userType)
        {
            UserType = userType;
            apiAddr = new OADDRAPI(apiApp, UserType);

            BaseResponse outProps = new BaseResponse();
            outProps.ReturnCode = apiAddr.getReturnCode();
            outProps.ErrorMessage = apiAddr.getErrorMessage();
            return outProps;

        }
        public void Dispose()
        {
            apiAddr.Dispose();
            apiAddr = null;
        }

        public AddressResponse RunAddressFunction(ref AddressRequest inProps)
        {
            apiAddr.setNameID(inProps.NameID);
            // 20150601-002-01
            apiAddr.setCompanyCode(inProps.CompanyCode);
            apiAddr.setPolicyNumber(inProps.PolicyNumber);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setInAddressType(inProps.InAddressType);
            apiAddr.setInAddressCode(inProps.InAddressCode);
            apiAddr.setUpdateIndicator(inProps.UpdateIndicator);
            // 20150601-002-01
            apiAddr.setUpdateQueryFlag(inProps.UpdateQueryFlag);

            // These next inputs only used for web service calls currently.  Not exposed through LPREMAPI. 
            apiAddr.setAddressID(inProps.AddressID);
            apiAddr.setEffectiveDate(inProps.EffectiveDate);
            apiAddr.setAddressCode(inProps.AddressCode);
            apiAddr.setIdentifyingNumber(inProps.IdentifyingNumber);
            // End web service only inputs.  


            apiAddr.setUpdatePhoneNumber(inProps.UpdatePhoneNumber);
            apiAddr.setUpdateFaxNumber(inProps.UpdateFaxNumber);
            apiAddr.setUpdateCellPhoneNumber(inProps.UpdateCellPhoneNumber);
            apiAddr.setUpdateAddressType(inProps.UpdateAddressType);
            apiAddr.setUpdateAddressCode(inProps.UpdateAddressCode);
            apiAddr.setUpdateAddressLine1(inProps.UpdateAddressLine1);
            apiAddr.setUpdateAddressLine2(inProps.UpdateAddressLine2);
            apiAddr.setUpdateAddressLine3(inProps.UpdateAddressLine3);
            apiAddr.setUpdateAddressCity(inProps.UpdateAddressCity);
            apiAddr.setUpdateAddressState(inProps.UpdateAddressState);
            apiAddr.setUpdateAddressZipCode(inProps.UpdateAddressZipCode);
            apiAddr.setUpdateAddressBoxNumber(inProps.UpdateAddressBoxNumber);
            apiAddr.setUpdateAddressZipExtension(inProps.UpdateAddressZipExtension);
            apiAddr.setUpdateAddressCountry(inProps.UpdateAddressCountry);
            apiAddr.setUpdateAddressCounty(inProps.UpdateAddressCounty);
            apiAddr.setUpdateAddressCountyCode(inProps.UpdateAddressCountyCode);
            apiAddr.setUpdateAddressCityCode(inProps.UpdateAddressCityCode);

            apiAddr.setUpdateCancelDate(inProps.UpdateCancelDate);
            apiAddr.setUpdateEffectiveDate(inProps.UpdateEffectiveDate);
            apiAddr.setUpdateRecurringStartMonth(inProps.UpdateRecurringStartMonth);
            apiAddr.setUpdateRecurringStartDay(inProps.UpdateRecurringStartDay);
            apiAddr.setUpdateRecurringStopMonth(inProps.UpdateRecurringStopMonth);
            apiAddr.setUpdateRecurringStopDay(inProps.UpdateRecurringStopDay);
            apiAddr.setAlternateNameID(inProps.UpdateAlternateNameID);
            apiAddr.setUpdateBadAddressInd(inProps.UpdateBadAddressIndicator);

            apiAddr.RunAddressFunction();


            AddressResponse outProps = new AddressResponse();
            outProps.ReturnCode = apiAddr.getReturnCode();
            outProps.ErrorMessage = apiAddr.getErrorMessage().Trim();

            outProps.EffectiveDate = apiAddr.getEffectiveDate();
            outProps.AddressID = apiAddr.getAddressID();
            outProps.CancelDate = apiAddr.getCancelDate();
            outProps.RecurringStartMonth = apiAddr.getRecurringStartMonth();
            outProps.RecurringStartDay = apiAddr.getRecurringStartDay();
            outProps.RecurringStopMonth = apiAddr.getRecurringStopMonth();
            outProps.RecurringStopDay = apiAddr.getRecurringStopDay();
            outProps.AlternateNameID = apiAddr.getAlternateNameID();
            outProps.PhoneNumber = apiAddr.getPhoneNumber();
            outProps.FaxNumber = apiAddr.getFaxNumber();
            outProps.CellPhoneNumber = apiAddr.getCellPhoneNumber();
            outProps.AddressType = apiAddr.getAddressType().Trim();
            outProps.AddressCode = apiAddr.getAddressCode().Trim();
            outProps.AddressLine1 = apiAddr.getAddressLine1().Trim();
            outProps.AddressLine2 = apiAddr.getAddressLine2().Trim();
            outProps.AddressLine3 = apiAddr.getAddressLine3().Trim();
            outProps.AddressCity = apiAddr.getAddressCity().Trim();
            outProps.AddressState = apiAddr.getAddressState().Trim();
            outProps.AddressZipCode = apiAddr.getAddressZipCode().Trim();
            outProps.AddressBoxNumber = apiAddr.getAddressBoxNumber().Trim();
            outProps.AddressZipExtension = apiAddr.getAddressZipExtension().Trim();
            outProps.AddressCountry = apiAddr.getAddressCountry().Trim();
            outProps.AddressCounty = apiAddr.getAddressCounty().Trim();
            outProps.AddressCountyCode = apiAddr.getAddressCountyCode().Trim();
            outProps.AddressCityCode = apiAddr.getAddressCityCode().Trim();
            outProps.FormatAddressLine1 = apiAddr.getFormatAddressLine1().Trim();
            outProps.FormatAddressLine2 = apiAddr.getFormatAddressLine2().Trim();
            outProps.FormatAddressLine3 = apiAddr.getFormatAddressLine3().Trim();
            outProps.FormatAddressLine4 = apiAddr.getFormatAddressLine4().Trim();
            outProps.IdentifyingNumber = apiAddr.getIdentifyingNumber().Trim();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd().Trim();
            //20150601-002
            outProps.UpdateNameId = apiAddr.getUpdateNameId();

            // Assign certain values to input properties used as input in WS calls.  
            inProps.AddressID = outProps.AddressID;
            inProps.EffectiveDate = outProps.EffectiveDate;
            inProps.AddressCode = outProps.AddressCode;
            inProps.IdentifyingNumber = outProps.IdentifyingNumber;
            //20150601-002
            inProps.NameID = outProps.UpdateNameId;


            return outProps;

        }
        //20150601-002
        public AddressResponse GetAddress(ref AddressRequest inProps)
        {
            // 20150601-002-01
            apiAddr.setNameID(inProps.NameID);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setCompanyCode(inProps.CompanyCode);
            apiAddr.setPolicyNumber(inProps.PolicyNumber);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setInAddressType(inProps.InAddressType);
            apiAddr.setInAddressCode(inProps.InAddressCode);
            apiAddr.setUpdateIndicator(inProps.UpdateIndicator);
            apiAddr.setUpdateQueryFlag(inProps.UpdateQueryFlag);
            // 20150601-002-01 End

            // These next inputs only used for web service calls currently.  Not exposed through LPREMAPI. 
            apiAddr.setAddressID(inProps.AddressID);
            apiAddr.setEffectiveDate(inProps.EffectiveDate);
            apiAddr.setAddressCode(inProps.AddressCode);
            apiAddr.setIdentifyingNumber(inProps.IdentifyingNumber);
            // End web service only inputs.  


            apiAddr.setUpdatePhoneNumber(inProps.UpdatePhoneNumber);
            apiAddr.setUpdateFaxNumber(inProps.UpdateFaxNumber);
            apiAddr.setUpdateCellPhoneNumber(inProps.UpdateCellPhoneNumber);
            apiAddr.setUpdateAddressType(inProps.UpdateAddressType);
            apiAddr.setUpdateAddressCode(inProps.UpdateAddressCode);
            apiAddr.setUpdateAddressLine1(inProps.UpdateAddressLine1);
            apiAddr.setUpdateAddressLine2(inProps.UpdateAddressLine2);
            apiAddr.setUpdateAddressLine3(inProps.UpdateAddressLine3);
            apiAddr.setUpdateAddressCity(inProps.UpdateAddressCity);
            apiAddr.setUpdateAddressState(inProps.UpdateAddressState);
            apiAddr.setUpdateAddressZipCode(inProps.UpdateAddressZipCode);
            apiAddr.setUpdateAddressBoxNumber(inProps.UpdateAddressBoxNumber);
            apiAddr.setUpdateAddressZipExtension(inProps.UpdateAddressZipExtension);
            apiAddr.setUpdateAddressCountry(inProps.UpdateAddressCountry);
            apiAddr.setUpdateAddressCounty(inProps.UpdateAddressCounty);
            apiAddr.setUpdateAddressCountyCode(inProps.UpdateAddressCountyCode);
            apiAddr.setUpdateAddressCityCode(inProps.UpdateAddressCityCode);

            apiAddr.setUpdateCancelDate(inProps.UpdateCancelDate);
            apiAddr.setUpdateEffectiveDate(inProps.UpdateEffectiveDate);
            apiAddr.setUpdateRecurringStartMonth(inProps.UpdateRecurringStartMonth);
            apiAddr.setUpdateRecurringStartDay(inProps.UpdateRecurringStartDay);
            apiAddr.setUpdateRecurringStopMonth(inProps.UpdateRecurringStopMonth);
            apiAddr.setUpdateRecurringStopDay(inProps.UpdateRecurringStopDay);
            apiAddr.setAlternateNameID(inProps.UpdateAlternateNameID);
            apiAddr.setUpdateBadAddressInd(inProps.UpdateBadAddressIndicator);

            //20150601-002
            apiAddr.GetAddress();
            //apiAddr.RunAddressFunction();


            AddressResponse outProps = new AddressResponse();
            outProps.ReturnCode = apiAddr.getReturnCode();
            outProps.ErrorMessage = apiAddr.getErrorMessage().Trim();

            outProps.EffectiveDate = apiAddr.getEffectiveDate();
            outProps.AddressID = apiAddr.getAddressID();
            outProps.CancelDate = apiAddr.getCancelDate();
            outProps.RecurringStartMonth = apiAddr.getRecurringStartMonth();
            outProps.RecurringStartDay = apiAddr.getRecurringStartDay();
            outProps.RecurringStopMonth = apiAddr.getRecurringStopMonth();
            outProps.RecurringStopDay = apiAddr.getRecurringStopDay();
            outProps.AlternateNameID = apiAddr.getAlternateNameID();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd();
            outProps.PhoneNumber = apiAddr.getPhoneNumber();
            outProps.FaxNumber = apiAddr.getFaxNumber();
            outProps.CellPhoneNumber = apiAddr.getCellPhoneNumber();
            outProps.AddressType = apiAddr.getAddressType().Trim();
            outProps.AddressCode = apiAddr.getAddressCode().Trim();
            outProps.AddressLine1 = apiAddr.getAddressLine1().Trim();
            outProps.AddressLine2 = apiAddr.getAddressLine2().Trim();
            outProps.AddressLine3 = apiAddr.getAddressLine3().Trim();
            outProps.AddressCity = apiAddr.getAddressCity().Trim();
            outProps.AddressState = apiAddr.getAddressState().Trim();
            outProps.AddressZipCode = apiAddr.getAddressZipCode().Trim();
            outProps.AddressBoxNumber = apiAddr.getAddressBoxNumber().Trim();
            outProps.AddressZipExtension = apiAddr.getAddressZipExtension().Trim();
            outProps.AddressCountry = apiAddr.getAddressCountry().Trim();
            outProps.AddressCounty = apiAddr.getAddressCounty().Trim();
            outProps.AddressCountyCode = apiAddr.getAddressCountyCode().Trim();
            outProps.AddressCityCode = apiAddr.getAddressCityCode().Trim();
            outProps.FormatAddressLine1 = apiAddr.getFormatAddressLine1().Trim();
            outProps.FormatAddressLine2 = apiAddr.getFormatAddressLine2().Trim();
            outProps.FormatAddressLine3 = apiAddr.getFormatAddressLine3().Trim();
            outProps.FormatAddressLine4 = apiAddr.getFormatAddressLine4().Trim();
            outProps.IdentifyingNumber = apiAddr.getIdentifyingNumber().Trim();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd().Trim();
            //20150601-002
            outProps.UpdateNameId = apiAddr.getUpdateNameId();

            // Assign certain values to input properties used as input in WS calls.  
            inProps.AddressID = outProps.AddressID;
            inProps.EffectiveDate = outProps.EffectiveDate;
            inProps.AddressCode = outProps.AddressCode;
            inProps.IdentifyingNumber = outProps.IdentifyingNumber;
            //20150601-002
            inProps.NameID = outProps.UpdateNameId;


            return outProps;

        }
        //20150601-002 20160114 Begin
        public AddressResponse UpdateAddressForPolicy(ref AddressRequest inProps)
        {
            apiAddr.setNameID(inProps.NameID);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setCompanyCode(inProps.CompanyCode);
            apiAddr.setPolicyNumber(inProps.PolicyNumber);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setInAddressType(inProps.InAddressType);
            apiAddr.setInAddressCode(inProps.InAddressCode);
            apiAddr.setUpdateIndicator(inProps.UpdateIndicator);
            apiAddr.setUpdateQueryFlag(inProps.UpdateQueryFlag);

            // These next inputs only used for web service calls currently.  Not exposed through LPREMAPI. 
            apiAddr.setAddressID(inProps.AddressID);
            apiAddr.setEffectiveDate(inProps.EffectiveDate);
            apiAddr.setAddressCode(inProps.AddressCode);
            apiAddr.setIdentifyingNumber(inProps.IdentifyingNumber);
            // End web service only inputs.  


            apiAddr.setUpdatePhoneNumber(inProps.UpdatePhoneNumber);
            apiAddr.setUpdateFaxNumber(inProps.UpdateFaxNumber);
            apiAddr.setUpdateCellPhoneNumber(inProps.UpdateCellPhoneNumber);
            apiAddr.setUpdateAddressType(inProps.UpdateAddressType);
            apiAddr.setUpdateAddressCode(inProps.UpdateAddressCode);
            apiAddr.setUpdateAddressLine1(inProps.UpdateAddressLine1);
            apiAddr.setUpdateAddressLine2(inProps.UpdateAddressLine2);
            apiAddr.setUpdateAddressLine3(inProps.UpdateAddressLine3);
            apiAddr.setUpdateAddressCity(inProps.UpdateAddressCity);
            apiAddr.setUpdateAddressState(inProps.UpdateAddressState);
            apiAddr.setUpdateAddressZipCode(inProps.UpdateAddressZipCode);
            apiAddr.setUpdateAddressBoxNumber(inProps.UpdateAddressBoxNumber);
            apiAddr.setUpdateAddressZipExtension(inProps.UpdateAddressZipExtension);
            apiAddr.setUpdateAddressCountry(inProps.UpdateAddressCountry);
            apiAddr.setUpdateAddressCounty(inProps.UpdateAddressCounty);
            apiAddr.setUpdateAddressCountyCode(inProps.UpdateAddressCountyCode);
            apiAddr.setUpdateAddressCityCode(inProps.UpdateAddressCityCode);

            apiAddr.setUpdateCancelDate(inProps.UpdateCancelDate);
            apiAddr.setUpdateEffectiveDate(inProps.UpdateEffectiveDate);
            apiAddr.setUpdateRecurringStartMonth(inProps.UpdateRecurringStartMonth);
            apiAddr.setUpdateRecurringStartDay(inProps.UpdateRecurringStartDay);
            apiAddr.setUpdateRecurringStopMonth(inProps.UpdateRecurringStopMonth);
            apiAddr.setUpdateRecurringStopDay(inProps.UpdateRecurringStopDay);
            apiAddr.setAlternateNameID(inProps.UpdateAlternateNameID);
            apiAddr.setUpdateBadAddressInd(inProps.UpdateBadAddressIndicator);

            apiAddr.UpdateAddressForPolicy();

            AddressResponse outProps = new AddressResponse();
            outProps.ReturnCode = apiAddr.getReturnCode();
            outProps.ErrorMessage = apiAddr.getErrorMessage().Trim();

            outProps.EffectiveDate = apiAddr.getEffectiveDate();
            outProps.AddressID = apiAddr.getAddressID();
            outProps.CancelDate = apiAddr.getCancelDate();
            outProps.RecurringStartMonth = apiAddr.getRecurringStartMonth();
            outProps.RecurringStartDay = apiAddr.getRecurringStartDay();
            outProps.RecurringStopMonth = apiAddr.getRecurringStopMonth();
            outProps.RecurringStopDay = apiAddr.getRecurringStopDay();
            outProps.AlternateNameID = apiAddr.getAlternateNameID();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd();
            outProps.PhoneNumber = apiAddr.getPhoneNumber();
            outProps.FaxNumber = apiAddr.getFaxNumber();
            outProps.CellPhoneNumber = apiAddr.getCellPhoneNumber();
            outProps.AddressType = apiAddr.getAddressType().Trim();
            outProps.AddressCode = apiAddr.getAddressCode().Trim();
            outProps.AddressLine1 = apiAddr.getAddressLine1().Trim();
            outProps.AddressLine2 = apiAddr.getAddressLine2().Trim();
            outProps.AddressLine3 = apiAddr.getAddressLine3().Trim();
            outProps.AddressCity = apiAddr.getAddressCity().Trim();
            outProps.AddressState = apiAddr.getAddressState().Trim();
            outProps.AddressZipCode = apiAddr.getAddressZipCode().Trim();
            outProps.AddressBoxNumber = apiAddr.getAddressBoxNumber().Trim();
            outProps.AddressZipExtension = apiAddr.getAddressZipExtension().Trim();
            outProps.AddressCountry = apiAddr.getAddressCountry().Trim();
            outProps.AddressCounty = apiAddr.getAddressCounty().Trim();
            outProps.AddressCountyCode = apiAddr.getAddressCountyCode().Trim();
            outProps.AddressCityCode = apiAddr.getAddressCityCode().Trim();
            outProps.FormatAddressLine1 = apiAddr.getFormatAddressLine1().Trim();
            outProps.FormatAddressLine2 = apiAddr.getFormatAddressLine2().Trim();
            outProps.FormatAddressLine3 = apiAddr.getFormatAddressLine3().Trim();
            outProps.FormatAddressLine4 = apiAddr.getFormatAddressLine4().Trim();
            outProps.IdentifyingNumber = apiAddr.getIdentifyingNumber().Trim();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd().Trim();
            outProps.UpdateNameId = apiAddr.getUpdateNameId();

            // Assign certain values to input properties used as input in WS calls.  
            inProps.AddressID = outProps.AddressID;
            inProps.EffectiveDate = outProps.EffectiveDate;
            inProps.AddressCode = outProps.AddressCode;
            inProps.IdentifyingNumber = outProps.IdentifyingNumber;
            inProps.NameID = outProps.UpdateNameId;


            return outProps;

        }
        public AddressResponse AddAddressForPolicy(ref AddressRequest inProps)
        {
            apiAddr.setNameID(inProps.NameID);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setCompanyCode(inProps.CompanyCode);
            apiAddr.setPolicyNumber(inProps.PolicyNumber);
            apiAddr.setRelateCode(inProps.RelateCode);
            apiAddr.setInAddressType(inProps.InAddressType);
            apiAddr.setInAddressCode(inProps.InAddressCode);
            apiAddr.setUpdateIndicator(inProps.UpdateIndicator);
            apiAddr.setUpdateQueryFlag(inProps.UpdateQueryFlag);

            // These next inputs only used for web service calls currently.  Not exposed through LPREMAPI. 
            apiAddr.setAddressID(inProps.AddressID);
            apiAddr.setEffectiveDate(inProps.EffectiveDate);
            apiAddr.setAddressCode(inProps.AddressCode);
            apiAddr.setIdentifyingNumber(inProps.IdentifyingNumber);
            // End web service only inputs.  


            apiAddr.setUpdatePhoneNumber(inProps.UpdatePhoneNumber);
            apiAddr.setUpdateFaxNumber(inProps.UpdateFaxNumber);
            apiAddr.setUpdateCellPhoneNumber(inProps.UpdateCellPhoneNumber);
            apiAddr.setUpdateAddressType(inProps.UpdateAddressType);
            apiAddr.setUpdateAddressCode(inProps.UpdateAddressCode);
            apiAddr.setUpdateAddressLine1(inProps.UpdateAddressLine1);
            apiAddr.setUpdateAddressLine2(inProps.UpdateAddressLine2);
            apiAddr.setUpdateAddressLine3(inProps.UpdateAddressLine3);
            apiAddr.setUpdateAddressCity(inProps.UpdateAddressCity);
            apiAddr.setUpdateAddressState(inProps.UpdateAddressState);
            apiAddr.setUpdateAddressZipCode(inProps.UpdateAddressZipCode);
            apiAddr.setUpdateAddressBoxNumber(inProps.UpdateAddressBoxNumber);
            apiAddr.setUpdateAddressZipExtension(inProps.UpdateAddressZipExtension);
            apiAddr.setUpdateAddressCountry(inProps.UpdateAddressCountry);
            apiAddr.setUpdateAddressCounty(inProps.UpdateAddressCounty);
            apiAddr.setUpdateAddressCountyCode(inProps.UpdateAddressCountyCode);
            apiAddr.setUpdateAddressCityCode(inProps.UpdateAddressCityCode);

            apiAddr.setUpdateCancelDate(inProps.UpdateCancelDate);
            apiAddr.setUpdateEffectiveDate(inProps.UpdateEffectiveDate);
            apiAddr.setUpdateRecurringStartMonth(inProps.UpdateRecurringStartMonth);
            apiAddr.setUpdateRecurringStartDay(inProps.UpdateRecurringStartDay);
            apiAddr.setUpdateRecurringStopMonth(inProps.UpdateRecurringStopMonth);
            apiAddr.setUpdateRecurringStopDay(inProps.UpdateRecurringStopDay);
            apiAddr.setAlternateNameID(inProps.UpdateAlternateNameID);
            apiAddr.setUpdateBadAddressInd(inProps.UpdateBadAddressIndicator);

            apiAddr.AddAddressForPolicy();


            AddressResponse outProps = new AddressResponse();
            outProps.ReturnCode = apiAddr.getReturnCode();
            outProps.ErrorMessage = apiAddr.getErrorMessage().Trim();

            outProps.EffectiveDate = apiAddr.getEffectiveDate();
            outProps.AddressID = apiAddr.getAddressID();
            outProps.CancelDate = apiAddr.getCancelDate();
            outProps.RecurringStartMonth = apiAddr.getRecurringStartMonth();
            outProps.RecurringStartDay = apiAddr.getRecurringStartDay();
            outProps.RecurringStopMonth = apiAddr.getRecurringStopMonth();
            outProps.RecurringStopDay = apiAddr.getRecurringStopDay();
            outProps.AlternateNameID = apiAddr.getAlternateNameID();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd();
            outProps.PhoneNumber = apiAddr.getPhoneNumber();
            outProps.FaxNumber = apiAddr.getFaxNumber();
            outProps.CellPhoneNumber = apiAddr.getCellPhoneNumber();
            outProps.AddressType = apiAddr.getAddressType().Trim();
            outProps.AddressCode = apiAddr.getAddressCode().Trim();
            outProps.AddressLine1 = apiAddr.getAddressLine1().Trim();
            outProps.AddressLine2 = apiAddr.getAddressLine2().Trim();
            outProps.AddressLine3 = apiAddr.getAddressLine3().Trim();
            outProps.AddressCity = apiAddr.getAddressCity().Trim();
            outProps.AddressState = apiAddr.getAddressState().Trim();
            outProps.AddressZipCode = apiAddr.getAddressZipCode().Trim();
            outProps.AddressBoxNumber = apiAddr.getAddressBoxNumber().Trim();
            outProps.AddressZipExtension = apiAddr.getAddressZipExtension().Trim();
            outProps.AddressCountry = apiAddr.getAddressCountry().Trim();
            outProps.AddressCounty = apiAddr.getAddressCounty().Trim();
            outProps.AddressCountyCode = apiAddr.getAddressCountyCode().Trim();
            outProps.AddressCityCode = apiAddr.getAddressCityCode().Trim();
            outProps.FormatAddressLine1 = apiAddr.getFormatAddressLine1().Trim();
            outProps.FormatAddressLine2 = apiAddr.getFormatAddressLine2().Trim();
            outProps.FormatAddressLine3 = apiAddr.getFormatAddressLine3().Trim();
            outProps.FormatAddressLine4 = apiAddr.getFormatAddressLine4().Trim();
            outProps.IdentifyingNumber = apiAddr.getIdentifyingNumber().Trim();
            outProps.BadAddressIndicator = apiAddr.getBadAddressInd().Trim();
            outProps.UpdateNameId = apiAddr.getUpdateNameId();

            // Assign certain values to input properties used as input in WS calls.  
            inProps.AddressID = outProps.AddressID;
            inProps.EffectiveDate = outProps.EffectiveDate;
            inProps.AddressCode = outProps.AddressCode;
            inProps.IdentifyingNumber = outProps.IdentifyingNumber;
            inProps.NameID = outProps.UpdateNameId;


            return outProps;

        }
        //20150601-002 20160114 End

    }
}
