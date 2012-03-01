From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 09:50:05 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20120301095005.30565.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 09:50:04

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Log fail of pthread_join
	
	Syslog error outside of mutex section.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.576&r2=1.577
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW_DM	2012/02/28 17:47:24	1.576
+++ LVM2/WHATS_NEW_DM	2012/03/01 09:50:04	1.577
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Log failure of pthread_join when cleaning unused threads in dmeventd.
   Fix empty string warning logic in _find_config_str. (1.02.68)
   Fix dm_task_set_name to properly resolve path to dm name (1.02.71).
   Add dm_strncpy() function as a faster strncpy() replacement.
--- LVM2/daemons/dmeventd/dmeventd.c	2012/02/27 11:13:51	1.90
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 09:50:04	1.91
@@ -1517,6 +1517,7 @@
 	int ret;
 	struct dm_list *l;
 	struct thread_status *thread;
+	int join_ret = 0;
 
 	_lock_mutex();
 	while ((l = dm_list_first(&_thread_registry_unused))) {
@@ -1556,12 +1557,15 @@
 
 		if (thread->status == DM_THREAD_DONE) {
 			dm_list_del(l);
-			pthread_join(thread->thread, NULL);
+			join_ret = pthread_join(thread->thread, NULL);
 			_free_thread_status(thread);
 		}
 	}
 
 	_unlock_mutex();
+
+	if (join_ret)
+		syslog(LOG_ERR, "Failed pthread_join: %s\n", strerror(join_ret));
 }
 
 static void _sig_alarm(int signum __attribute__((unused)))


