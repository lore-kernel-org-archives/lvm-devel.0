From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 13:03:40 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20120208130340.755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 13:03:40

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	A bit more readable code
	
	Just a minor readability conversion.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/daemons/clvmd/clvmd.c	2012/01/26 17:55:55	1.119
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/08 13:03:40	1.120
@@ -741,8 +741,7 @@
 			 status, sock_client);
 		/* But has the client gone away ?? */
 		if (sock_client == NULL) {
-			DEBUGLOG
-			    ("Got PIPE response for dead client, ignoring it\n");
+			DEBUGLOG("Got PIPE response for dead client, ignoring it\n");
 		} else {
 			/* If error then just return that code */
 			if (status)
@@ -751,21 +750,16 @@
 			else {
 				/* FIXME: closer inspect this code since state is write thread protected */
 				pthread_mutex_lock(&sock_client->bits.localsock.mutex);
-				if (sock_client->bits.localsock.state ==
-				    POST_COMMAND) {
+				if (sock_client->bits.localsock.state == POST_COMMAND) {
 					pthread_mutex_unlock(&sock_client->bits.localsock.mutex);
 					send_local_reply(sock_client, 0,
 							 sock_client->fd);
-				} else	// PRE_COMMAND finished.
-				{
+				} else {
+					/* PRE_COMMAND finished. */
 					pthread_mutex_unlock(&sock_client->bits.localsock.mutex);
-					if (
-					    (status =
-					     distribute_command(sock_client)) !=
-					    0) send_local_reply(sock_client,
-								EFBIG,
-								sock_client->
-								fd);
+					if ((status = distribute_command(sock_client)))
+						send_local_reply(sock_client, EFBIG,
+								 sock_client->fd);
 				}
 			}
 		}
@@ -1247,9 +1241,8 @@
 			    inheader->node + strlen(inheader->node) + 1;
 
 			while (missing_len > 0) {
-				DEBUGLOG
-				    ("got %d bytes, need another %d (total %d)\n",
-				     argslen, missing_len, inheader->arglen);
+				DEBUGLOG("got %d bytes, need another %d (total %d)\n",
+					 argslen, missing_len, inheader->arglen);
 				len = read(thisfd->fd, argptr + argslen,
 					   missing_len);
 				if (len == -1 && errno == EINTR)


