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
/* 
 * Wrapper network functions to be called by COBOL. 
 *
 * Just server side functions for now.
 *
 * 12/22/96 initial version
 *
 * defaults:
 *   socket descriptor (sockd): 4bytes (COMP-5) BY REFERENCE
 *	Each function returns -1 in sockd upon failure, like the C routines
 *	would (unlike COBOL). When calling COB_INIT_SERVER(), set *sockd to
 *	to -1 before calling this initializing routine just in case
 *	the call fails (a COBOL runtime level call failure where the
 *	routine is never really called).
 *
 * NOTE: Make sure all arguments are 01 level and the integers are 4bytes 
 *	in size.
 */

#include "lpcopyrt.h"


#include <stdlib.h>			/* DA 12-23-96 */
#include <stdio.h>			/* DA 12-23-96 */

#include "net.h"

/* define MAKEDLL when using microsoft 6.0 for Realia4.227 (OS/2 16bit DLL) */
#ifdef MAKEDLL
#define FORDLL _loadds _export _far
#else
#define FORDLL
#endif

#define UNIX_BOX

#ifdef UNIX_BOX
#define COB_STOP_SERVER		cob_stop_server
#define COB_START_SERVER	cob_start_server
#define COB_SERVER_ACCEPT	cob_server_accept
#define COB_SEND_BUFF		cob_send_buff
#define COB_RECV_BUFF		cob_recv_buff
#endif


void FORDLL
COB_STOP_SERVER(int *sockd)
{	net_stop_server(sockd);
}

/* 
 * Set sockd to -1 before calling this initializing routine in case
 * the call fails (a COBOL runtime level call failure where this routine is
 * never really called).
 */
void FORDLL
COB_START_SERVER(int *sockd, char *port)
{	*sockd = net_start_server(port);
}

/* accept a new connection from a client */
void FORDLL
COB_SERVER_ACCEPT(int *serv_sockd, int *client_sockd)
{	*client_sockd = net_accept_conn(*serv_sockd, 0);
}

void FORDLL
COB_SEND_BUFF(int *sockd, char *buff, int *buflen, int *amt_sent)
{	*amt_sent = net_send_buff(*sockd, buff, (size_t)*buflen);
}

void FORDLL
COB_RECV_BUFF(int *sockd, char *buff, int *buflen, int *amt_recvd)
{	*amt_recvd = net_recv_buff(*sockd, buff, (size_t)*buflen);
}
