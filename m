From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 14:00:31 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101222140031.22568.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 14:00:30

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Fix last pthread_join fix commit
	
	Call for pthread_join() does not set errno value even though return values
	looks like that. For now assign errno from return value and still use
	strerror() to print some error message as this seems to be commonly used.
	
	Add also log_sys_error() message for error close of local pipe.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/daemons/clvmd/clvmd.c	2010/12/22 12:10:56	1.90
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/22 14:00:28	1.91
@@ -667,7 +667,8 @@
 	/* EOF on pipe or an error, close it */
 	if (len <= 0) {
 		void *ret = &status;
-		close(thisfd->fd);
+		if (close(thisfd->fd))
+			log_sys_error("close", "local_pipe");
 
 		/* Clear out the cross-link */
 		if (thisfd->bits.pipe.client != NULL)
@@ -676,7 +677,8 @@
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
-			if (pthread_join(thisfd->bits.pipe.threadid, &ret))
+			if ((errno = pthread_join(thisfd->bits.pipe.threadid,
+						  &ret)))
 				log_sys_error("pthread_join", "");
 
 			thisfd->bits.pipe.threadid = 0;
@@ -1068,8 +1070,8 @@
 			pthread_cond_signal(&thisfd->bits.localsock.cond);
 			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
 
-			if (pthread_join(thisfd->bits.localsock.threadid,
-					 (void **) &status))
+			if ((errno = pthread_join(thisfd->bits.localsock.threadid,
+						  (void **) &status)))
 				log_sys_error("pthread_join", "");
 
 			DEBUGLOG("Joined child thread\n");


