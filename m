From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:03:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c
Message-ID: <20111221130308.22274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:03:07

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 

Log message:
	Fix missing thread list manipulation
	
	For manipulation with thread list to avoid race with timeout thread,
	take also _timeout_mutex.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2208&r2=1.2209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/WHATS_NEW	2011/12/21 12:59:22	1.2208
+++ LVM2/WHATS_NEW	2011/12/21 13:03:06	1.2209
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix missing thread list manipulation protection in dmeventd.
   Do not derefence lv pointer in _percent_run() function before NULL check.
   Allow empty strings for description and creation_host config fields.
   Issue deprecation warning when removing last lvm1-format snapshot.
--- LVM2/daemons/dmeventd/dmeventd.c	2011/09/14 09:53:32	1.84
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/12/21 13:03:07	1.85
@@ -739,8 +739,10 @@
 			return;
 		}
 	thread->status = DM_THREAD_DONE;
+	pthread_mutex_lock(&_timeout_mutex);
 	UNLINK_THREAD(thread);
 	LINK(thread, &_thread_registry_unused);
+	pthread_mutex_unlock(&_timeout_mutex);
 	_unlock_mutex();
 }
 
@@ -1078,8 +1080,10 @@
 	 * unlink and terminate its monitoring thread.
 	 */
 	if (!thread->events) {
+		pthread_mutex_lock(&_timeout_mutex);
 		UNLINK_THREAD(thread);
 		LINK(thread, &_thread_registry_unused);
+		pthread_mutex_unlock(&_timeout_mutex);
 	}
 	_unlock_mutex();
 


