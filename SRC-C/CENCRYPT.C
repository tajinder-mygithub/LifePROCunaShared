/*@**20100811********************************************/
/*@** */
/*@** Licensed Materials - Property o */
/*@** ExlService Holdings, Inc. */
/*@** */
/*@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved. */
/*@** */
/*@** Contains confidential and trade secret information. */
/*@** Copyright notice is precautionary only and does not */
/*@** imply publication. */
/*@**
/*@**20100811********************************************/

/**********************************************************************
**                                                                   **
**    Program Name......: CENCRYPT.C                              **
**    Author(s).........: David Ross                                 **
**    Description.......: Handles Sha Encryption as a callable module**
**    Creation Date.....: 09/27/2004                                 **
**                                                                   **
**    This module provides the same encryption services that LPDRVR  **
**    provides on login.  This module was created to support COBOL   **
**    programs that required this encryption outside of LPDRVR.      **

**    Standard includes <windows.h> and <stdlib.h> from Microsoft    **
**********************************************************************/
/*    Revision History                                               **
* 20090728-002-01  DAR  Modified for use in version 16 LPDRVR.       *
*                                                                    *
**********************************************************************/


// Encrypt
#define PASSWORD_DSP_LEN  8
#define PASSWORD_RET_LEN 64
#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
// encryption constants
#define HASH_ALGORITHM      CALG_SHA
#define BLOCK_PAD_TO        63                  // encrypted data size will be the next multiple of ENCRYPT_BLOCK_SIZE
                                                // that is larger than this value (64)
#define USE_BLOCK_CIPHER

//#define LP_CONTAINER  "Life Pro Container"      // use special LifePRO container
#define LP_CONTAINER  NULL                      // use default container

#ifdef USE_BLOCK_CIPHER
    // defines for RC2 block cipher
    #define ENCRYPT_ALGORITHM   CALG_RC2
    #define ENCRYPT_BLOCK_SIZE  8
#else
    // defines for RC4 stream cipher
    #define ENCRYPT_ALGORITHM   CALG_RC4
    #define ENCRYPT_BLOCK_SIZE  1
#endif

#include <windows.h>
#include <stdlib.h>
#include "wincrypt.h"


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{

	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
	}
	
	return TRUE;
}

/****************************************************************************
*
*  init_user - This routine inits the window's registry with a 
*              default encryption
*
*  SR#            INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
****************************************************************************/
int init_user()
{
  HCRYPTPROV hProv;
  HCRYPTKEY hKey;
  CHAR szUserName[100];
  DWORD dwUserNameLen = 100;

  // Attempt to acquire a handle to the default key container.
  if(!CryptAcquireContext(&hProv, LP_CONTAINER, MS_DEF_PROV, PROV_RSA_FULL, 0))
  {
    // Some sort of error occured. try it again

    // Create default key container.
    if(!CryptAcquireContext(&hProv, LP_CONTAINER, MS_DEF_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET))
    {
        // LocWinMessage(ghwnd, MSG_ENCRYPT7, GetLastError());
        return(-1);
    }

    // Get name of default key container.
    if(!CryptGetProvParam(hProv, PP_CONTAINER, szUserName, &dwUserNameLen, 0))
    {
      // Error getting key container name.
      szUserName[0] = 0;
    }

  }

  // Attempt to get handle to signature key.
  if(!CryptGetUserKey(hProv, AT_SIGNATURE, &hKey))
  {
     if(GetLastError() == NTE_NO_KEY)
     {
        // Create signature key pair.

        if(!CryptGenKey(hProv,AT_SIGNATURE,0,&hKey))
        {
           //LocWinMessage(ghwnd, MSG_ENCRYPT8, GetLastError());
           return(-1);
        }
        else
        {
           CryptDestroyKey(hKey);
        }
     }
     else
     {
        //LocWinMessage(ghwnd, MSG_ENCRYPT9, GetLastError());
        return(-1);
     }
  }

  // Attempt to get handle to exchange key.
  if(!CryptGetUserKey(hProv,AT_KEYEXCHANGE,&hKey))
  {
     if(GetLastError()==NTE_NO_KEY)
     {
        // Create key exchange key pair.

        if(!CryptGenKey(hProv,AT_KEYEXCHANGE,0,&hKey))
        {
           //LocWinMessage(ghwnd, MSG_ENCRYPT9, GetLastError());
           return(-1);
        }
        else
        {
           CryptDestroyKey(hKey);
        }
     }
     else
     {
        //LocWinMessage(ghwnd, MSG_ENCRYPT9, GetLastError());
        return(-1);
     }
  }

  CryptReleaseContext(hProv,0);

//  printf("Updated registry\n");
  return (0);

}


extern  __declspec(dllexport) short __stdcall 
CENCRYPT (char **out, char *in) 
{

HCRYPTPROV hProv = 0;
HCRYPTKEY hKey;
long cc;

HCRYPTHASH hHash = 0;
LPTSTR szDescription = TEXT("");
PBYTE pbBuffer = NULL;
DWORD dwBlockLen;
DWORD dwBufferLen;
DWORD dwCount;

DWORD dwFlags; 

   cc = 0; 

   // Per Microsoft, using the MS_DEF_PROV parameter forces encryption to use the
   // base encryption provider, which uses 40 bit encryption.  Without this,
   // and with a NULL in the 3rd parameter, Windows XP was using 128 bit encryption
   // by default, and Win 2000 was using 40 bit.  MS_DEF_PROV forces consistency.


   dwFlags = CRYPT_VERIFYCONTEXT;	// This forces the key container to be created in memory only.
   if (!CryptAcquireContext(&hProv, LP_CONTAINER, MS_DEF_PROV, PROV_RSA_FULL, dwFlags))
   {
     if (init_user() < 0)
        return (-1);
     cc=CryptAcquireContext(&hProv, LP_CONTAINER, MS_DEF_PROV, PROV_RSA_FULL, dwFlags);
   }

   //if (cc == 0)
   //{
   //  //LocWinMessage(ghwnd, MSG_ENCRYPT1, GetLastError());
   //  return(-1);
   //}

//   pad(in, 8);  ??

   if (!CryptCreateHash(hProv, HASH_ALGORITHM, 0, 0, &hHash))
   {
     //LocWinMessage(ghwnd, MSG_ENCRYPT2, GetLastError());
     return(-1);
   }
   if (!CryptHashData(hHash, in, strlen(in), 0))
   {
     //LocWinMessage(ghwnd, MSG_ENCRYPT3, GetLastError());
     return(-1);
   }

    // Derive a session key from the hash object.
    if(!CryptDeriveKey(hProv, ENCRYPT_ALGORITHM, hHash, 0, &hKey)) {
        //LocWinMessage(ghwnd, MSG_ENCRYPT10, GetLastError());
        return(-1);
    }

    // Determine number of bytes to encrypt at a time. This must be a multiple
    // of ENCRYPT_BLOCK_SIZE.
    dwBlockLen = max(300, BLOCK_PAD_TO);
    dwBlockLen -= dwBlockLen % ENCRYPT_BLOCK_SIZE;

    // Determine the block size. If a block cipher is used this must have
    // room for an extra block.
    if(ENCRYPT_BLOCK_SIZE > 1) {
        dwBufferLen = dwBlockLen + ENCRYPT_BLOCK_SIZE;
    } else {
        dwBufferLen = dwBlockLen;
    }

    // Allocate memory.
    if((pbBuffer = malloc(dwBufferLen)) == NULL) {
        //LocWinMessage(ghwnd, MSG_ENCRYPT5);
        return(-1);
    }

    // Encrypt source file and write to Source file.
    memset(pbBuffer, ' ', dwBufferLen);
    memcpy(pbBuffer, in, strlen(in));

    dwCount=strlen(in);
    if (dwCount < BLOCK_PAD_TO)
        dwCount = BLOCK_PAD_TO;
    pbBuffer[BLOCK_PAD_TO+1]='\0';

        // Encrypt data
    if(!CryptEncrypt(hKey, 0, TRUE, 0, pbBuffer, &dwCount, dwBufferLen)) {
            //LocWinMessage(ghwnd, MSG_ENCRYPT11, GetLastError(), dwCount);
            return(-1);
        }

   memcpy (*out, pbBuffer, PASSWORD_RET_LEN);    // if, for some reason, the encrypted data is longer than 64, truncate

   // Free memory.
    if(pbBuffer) free(pbBuffer);

    // Destroy session key.
    if(hKey) CryptDestroyKey(hKey);

  // Destroy hash object.
  if(hHash != 0)
     CryptDestroyHash(hHash);

  // Release provider handle.
  if(hProv != 0)
     CryptReleaseContext(hProv, 0);

   return(0);
}

