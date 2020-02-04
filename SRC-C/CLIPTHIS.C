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

#include "lpcopyrt.h"

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <direct.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>
#define BUFSIZE  1024

#define   FF   12

void encapsulate(HWND hwnd, char *file);

LRESULT CALLBACK WndProc (HWND, UINT, WPARAM, LPARAM);
int CopyToClipBoard(HWND hwnd, PSTR szCmdLine);
int ConvertFile(HWND hwnd, PSTR szCmdLine);

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
  static char szAppName[] = "ClipThis" ;
  HWND        hwnd ;
  WNDCLASSEX  wndclass ;
  char buf[_MAX_PATH+1];

  wndclass.cbSize        = sizeof (wndclass) ;
  wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
  wndclass.lpfnWndProc   = WndProc ;
  wndclass.cbClsExtra    = 0 ;
  wndclass.cbWndExtra    = 0 ;
  wndclass.hInstance     = hInstance ;
  wndclass.hIcon         = LoadIcon (NULL, IDI_APPLICATION) ;
  wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
  wndclass.hbrBackground = (HBRUSH) GetStockObject (WHITE_BRUSH) ;
  wndclass.lpszMenuName  = NULL ;
  wndclass.lpszClassName = szAppName ;
  wndclass.hIconSm       = LoadIcon (NULL, IDI_APPLICATION) ;

  RegisterClassEx (&wndclass) ;

  wsprintf(buf, "Adding %s to the Clipboard", szCmdLine);
  hwnd = CreateWindow (szAppName,         // window class name
                 buf,
                 WS_OVERLAPPEDWINDOW,     // window style
                 CW_USEDEFAULT,           // initial x position
                 CW_USEDEFAULT,           // initial y position
                 CW_USEDEFAULT,           // initial x size
                 CW_USEDEFAULT,           // initial y size
                 NULL,                    // parent window handle
                 NULL,                    // window menu handle
                 hInstance,               // program instance handle
	            NULL) ;		             // creation parameters

  ShowWindow (hwnd, SW_HIDE) ;
  UpdateWindow (hwnd) ;

  CopyToClipBoard(hwnd, szCmdLine);
  encapsulate(hwnd, szCmdLine);

  return 0;
}


LRESULT CALLBACK WndProc (HWND hwnd, UINT iMsg, WPARAM wParam, LPARAM lParam)
{
HDC         hdc ;
PAINTSTRUCT ps ;
RECT        rect ;

  switch (iMsg)
  {
       case WM_CREATE :
            return 0 ;

       case WM_PAINT :
	        hdc = BeginPaint (hwnd, &ps) ;

            GetClientRect (hwnd, &rect) ;

            DrawText (hdc, "Copying, Please Wait...", -1, &rect,
		             DT_SINGLELINE | DT_CENTER | DT_VCENTER) ;

	        EndPaint (hwnd, &ps) ;
            return 0 ;

       case WM_DESTROY :
            PostQuitMessage (0) ;
            return 0 ;
  }

  return DefWindowProc (hwnd, iMsg, wParam, lParam) ;
}

int CopyToClipBoard(HWND hwnd, PSTR szCmdLine)
{
PSTR p;
HGLOBAL hglb;


  hglb = GlobalAlloc(GHND, _MAX_PATH);

  if ((p= (PSTR)GlobalLock (hglb)) == NULL)
  {
     MessageBox(hwnd, "Could not Allocate enough memory",
                "Error",MB_APPLMODAL|MB_ICONSTOP);
     return(-1);
  }


  _fullpath(p, szCmdLine, _MAX_PATH);
  //strcpy (p, szCmdLine);

  GlobalUnlock(hglb);
  OpenClipboard(hwnd);
  EmptyClipboard();
  SetClipboardData(CF_TEXT, hglb);
  CloseClipboard();
  return (0);
}



void encapsulate(HWND hwnd, char *file)
{
  char fileNameIn[_MAX_PATH];
  char fileNameOut[_MAX_PATH];
  char buf[BUFSIZE+1], bufOut[(BUFSIZE*2) +1];
  int fIn, fOut;
  char *p, *pOut;
  short cc, newDelimiter;
  char lastCharLine, crlf;

//  file = "c:\\tmp\\lemg_fr1";
  wsprintf(fileNameIn, "%s.2nd", file);
  wsprintf(fileNameOut, "%s.mrg", file);

  if ((fIn=open(fileNameIn, O_RDONLY)) < 0)
  {
     char buf[100];
     wsprintf(buf, "Could not open %s", fileNameOut);
     MessageBox(hwnd, buf,
                "Error",MB_APPLMODAL|MB_ICONSTOP);
     return;
  }

  if ((fOut=open(fileNameOut, O_TRUNC | O_CREAT | O_WRONLY, S_IREAD | S_IWRITE)) < 0)
  {
     char buf[100];
     wsprintf(buf, "Could not open %s", fileNameOut);
     MessageBox(hwnd, buf,
                "Error",MB_APPLMODAL|MB_ICONSTOP);
     return;
  }

  memset(buf, 0x00, sizeof(buf));
  memset(bufOut, 0x00, sizeof(bufOut));

  cc=read(fIn, buf, BUFSIZE);

  newDelimiter=TRUE;
  crlf=TRUE;
  lastCharLine = '\0';
  while (cc > 0)
  {

     for (p=buf,pOut=bufOut;cc > 0;cc--, p++)
     {
        lastCharLine=*p;
        if (*p == '~')
        {
           if (newDelimiter)
           {
              if (!crlf)
                 *pOut++ = ',';

              *pOut++ = '"';
              crlf=FALSE;
           }

           *pOut++ = '"';

           newDelimiter=TRUE;
        }
        else if (*p == '\n')
        {
           if (newDelimiter)
           {
               if(!crlf)
                   *pOut++ = ',';
               *pOut++ = '"';
           }

           crlf=TRUE;
           *pOut++ = '"';
           *pOut++ = '\n';
           newDelimiter=TRUE;
        }
        else if (*p >= ' ')
        {
           if (newDelimiter)
           {
              if (!crlf)
                 *pOut++ = ',';

              *pOut++ = '"';
              newDelimiter=FALSE;
              crlf=FALSE;
           }
           *pOut++ = *p;
        }
     }
     write(fOut, bufOut, strlen(bufOut));
     memset(buf, 0x00, sizeof(buf));
     memset(bufOut, 0x00, sizeof(bufOut));
     cc=read(fIn, buf, BUFSIZE);
  }

  if (lastCharLine >= ' ')
     write(fOut, "\"\n", 2);

  close(fOut);
  close(fIn);

}

