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
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*/

using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro {
	/// <summary>
	/// The Database LifePRO API, which allows for direct access to tables in LifePRO for update, inserts, etc.  
	/// </summary>

	public class FileBtv :  IFileBtv {
		OFILEBTV apiFile ; 

		public static OAPPLICA apiApp ; 
		public string UserType ; 

		public BaseResponse Init (string userType) {
			UserType = userType ; 
			apiFile = new OFILEBTV(apiApp, UserType);  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiFile.getReturnCode() ; 
			outProps.ErrorMessage = apiFile.getErrorMessage() ;
            return outProps;   

		}
		public void Dispose() {
			apiFile.Dispose(); 
			apiFile = null ; 
		}


		public BaseResponse ExecFunction (ref DatabaseRequest inProps ) {
			
			apiFile.setFileName(inProps.FileName);
			apiFile.setFunction(inProps.Function);
			apiFile.setKeyNumber(inProps.KeyNumber);
			apiFile.setFileNumber(inProps.FileNumber);

            apiFile.setPassKeyValues(inProps.PassKeyValues);

            try
            {
                if (inProps.KeyBuffer != null) 
                    for (int i = 0; i < inProps.KeyBuffer.Length; i++)
                        apiFile.setKeyBuffer(i + 1, inProps.KeyBuffer[i]);
            }
            catch { } 

            try
            {
                if (inProps.DataBuffer != null)
                    apiFile.setDataBuffer(inProps.DataBuffer);
            }
            catch { }  

			apiFile.ExecFunction(); 

			inProps.FileLength = apiFile.getFileLength();  
			inProps.PassKeyValues = apiFile.getPassKeyValues(); 

			inProps.KeyBuffer = new string[7];  
			for (int i=1;i<=7;i++)  // Up to 7 key buffers are supported, just retrieve them all, 
								// it's OK if they're not in use.   
				inProps.KeyBuffer[i-1] = apiFile.getKeyBuffer(i);  

			inProps.DataBuffer = apiFile.getDataBuffer();  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiFile.getReturnCode() ; 
			outProps.ErrorMessage = apiFile.getErrorMessage();  
			return outProps ; 
		}

		public BaseResponse FindFileNumber (ref DatabaseRequest inProps ) {

			apiFile.setFileName(inProps.FileName);
			apiFile.setFunction(inProps.Function);

			apiFile.FindFileNumber(); 

			inProps.FileNumber = apiFile.getFileNumber();  
			inProps.FileLength = apiFile.getFileLength(); 

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiFile.getReturnCode() ; 
			outProps.ErrorMessage = apiFile.getErrorMessage();  
			return outProps ; 

		}

		public BaseResponse FindFileLength (ref DatabaseRequest inProps ) {

			apiFile.setFileName(inProps.FileName);
			apiFile.setFileNumber(inProps.FileNumber);  
			apiFile.setFunction(inProps.Function);

			apiFile.FindFileLength(); 

			inProps.FileLength = apiFile.getFileLength();  

			BaseResponse outProps = new BaseResponse() ; 
			outProps.ReturnCode = apiFile.getReturnCode() ; 
			outProps.ErrorMessage = apiFile.getErrorMessage();  
			return outProps ; 

		}

	}
}
