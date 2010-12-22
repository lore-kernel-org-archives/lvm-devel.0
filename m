From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 12:10:57 -0000
Subject: LVM2 daemons/clvmd/clvmd.c ./WHATS_NEW
Message-ID: <20101222121057.19575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 12:10:57

Modified files:
	daemons/clvmd  : clvmd.c 
	.              : WHATS_NEW 

Log message:
	Log error state from pthread_join operation
	
	Value jstat is unused - so replace it with logging via log_sys_error().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1850&r2=1.1851

--- LVM2/daemons/clvmd/clvmd.c	2010/12/20 13:48:28	1.89
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/22 12:10:56	1.90
@@ -666,7 +666,6 @@
 
 	/* EOF on pipe or an error, close it */
 	if (len <= 0) {
-		int jstat;
 		void *ret = &status;
 		close(thisfd->fd);
 
@@ -677,7 +676,9 @@
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
-			jstat = pthread_join(thisfd->bits.pipe.threadid, &ret);
+			if (pthread_join(thisfd->bits.pipe.threadid, &ret))
+				log_sys_error("pthread_join", "");
+
 			thisfd->bits.pipe.threadid = 0;
 			if (thisfd->bits.pipe.client != NULL)
 				thisfd->bits.pipe.client->bits.localsock.
@@ -1041,7 +1042,6 @@
 	/* EOF or error on socket */
 	if (len <= 0) {
 		int *status;
-		int jstat;
 
 		DEBUGLOG("EOF on local socket: inprogress=%d\n",
 			 thisfd->bits.localsock.in_progress);
@@ -1068,9 +1068,10 @@
 			pthread_cond_signal(&thisfd->bits.localsock.cond);
 			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
 
-			jstat =
-			    pthread_join(thisfd->bits.localsock.threadid,
-					 (void **) &status);
+			if (pthread_join(thisfd->bits.localsock.threadid,
+					 (void **) &status))
+				log_sys_error("pthread_join", "");
+
 			DEBUGLOG("Joined child thread\n");
 
 			thisfd->bits.localsock.threadid = 0;
--- LVM2/WHATS_NEW	2010/12/21 21:08:51	1.1850
+++ LVM2/WHATS_NEW	2010/12/22 12:10:56	1.1851
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Log error message for pthread_join() failure in clvmd.
 
 Version 2.02.79 - 20th December 2010
 ====================================


