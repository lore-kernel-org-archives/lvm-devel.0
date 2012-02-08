From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:36:19 -0000
Subject: LVM2 daemons/cmirrord/functions.c daemons/dmev ...
Message-ID: <20120208113619.21109.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:36:19

Modified files:
	daemons/cmirrord: functions.c 
	daemons/dmeventd: dmeventd.c 
	libdm          : libdm-deptree.c 
	tools          : lvm.c 

Log message:
	Remove unneeded assignments
	
	Variables have (or will have) those values set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/daemons/cmirrord/functions.c	2012/02/08 11:34:46	1.31
+++ LVM2/daemons/cmirrord/functions.c	2012/02/08 11:36:18	1.32
@@ -372,7 +372,7 @@
 	enum sync log_sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
 
-	int disk_log = 0;
+	int disk_log;
 	char disk_path[128];
 	int unlink_path = 0;
 	long page_size;
--- LVM2/daemons/dmeventd/dmeventd.c	2011/12/22 15:50:39	1.86
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/02/08 11:36:18	1.87
@@ -448,7 +448,7 @@
 {
 	struct dm_event_daemon_message *msg = message_data->msg;
 	struct thread_status *thread;
-	int i = 0, j = 0;
+	int i, j;
 	int ret = -1;
 	int count = dm_list_size(&_thread_registry);
 	int size = 0, current = 0;
@@ -1170,8 +1170,6 @@
 	if (!hit)
 		goto out;
 
-	thread = hit;
-
 	while (1) {
 		if (dm_list_end(&_thread_registry, &thread->list))
 			goto out;
--- LVM2/libdm/libdm-deptree.c	2012/01/25 21:50:51	1.153
+++ LVM2/libdm/libdm-deptree.c	2012/02/08 11:36:18	1.154
@@ -739,10 +739,6 @@
 		*deps = NULL;
 		info->major = major;
 		info->minor = minor;
-		info->exists = 0;
-		info->live_table = 0;
-		info->inactive_table = 0;
-		info->read_only = 0;
 		return 1;
 	}
 
--- LVM2/tools/lvm.c	2011/11/12 22:44:11	1.116
+++ LVM2/tools/lvm.c	2012/02/08 11:36:19	1.117
@@ -60,7 +60,7 @@
 	/* Initialise if this is a new completion attempt */
 	if (!state) {
 		char *s = rl_line_buffer;
-		int j = 0;
+		int j;
 
 		match_no = 0;
 		com = NULL;


