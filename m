From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:37:28 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20100330143728.17451.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:37:28

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Fix resouce leak in error path
	
	If the error path of _register_for_event() calls _free_thread_status()
	_lib_put() call is missing.
	To make thing simpler move this _lib_put() into common error path code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:35:40	1.55
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:37:28	1.56
@@ -243,8 +243,10 @@
 	return ret;
 }
 
+static void _lib_put(struct dso_data *data);
 static void _free_thread_status(struct thread_status *thread)
 {
+	_lib_put(thread->dso_data);
 	if (thread->current_task)
 		dm_task_destroy(thread->current_task);
 	dm_free(thread->device.uuid);
@@ -1481,7 +1483,6 @@
 		if (thread->status == DM_THREAD_DONE) {
 			dm_list_del(l);
 			pthread_join(thread->thread, NULL);
-			_lib_put(thread->dso_data);
 			_free_thread_status(thread);
 		}
 	}


