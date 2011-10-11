From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:56:45 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20111011095645.14339.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:56:45

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Add some fixme locking
	
	Code here is using thread write protected variable without locking.
	So add locking, for proper synchronization and a FIXME, since the
	code needs closer look.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:54:39	1.114
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:56:44	1.115
@@ -747,12 +747,16 @@
 				send_local_reply(sock_client, status,
 						 sock_client->fd);
 			else {
+				/* FIXME: closer inspect this code since state is write thread protected */
+				pthread_mutex_lock(&sock_client->bits.localsock.mutex);
 				if (sock_client->bits.localsock.state ==
 				    POST_COMMAND) {
+					pthread_mutex_unlock(&sock_client->bits.localsock.mutex);
 					send_local_reply(sock_client, 0,
 							 sock_client->fd);
 				} else	// PRE_COMMAND finished.
 				{
+					pthread_mutex_unlock(&sock_client->bits.localsock.mutex);
 					if (
 					    (status =
 					     distribute_command(sock_client)) !=


