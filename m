From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Sep 2009 18:15:08 -0000
Subject: LVM2/tools lvconvert.c polldaemon.c polldaemon ...
Message-ID: <20090930181508.21647.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-30 18:15:07

Modified files:
	tools          : lvconvert.c polldaemon.c polldaemon.h pvmove.c 

Log message:
	Make poll_mirror_progress a function that can be replaced.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/tools/lvconvert.c	2009/09/14 22:47:49	1.92
+++ LVM2/tools/lvconvert.c	2009/09/30 18:15:06	1.93
@@ -315,6 +315,7 @@
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
+	.poll_progress = poll_mirror_progress,
 	.update_metadata = _update_lvconvert_mirror,
 	.finish_copy = _finish_lvconvert_mirror,
 };
--- LVM2/tools/polldaemon.c	2009/09/30 17:43:51	1.25
+++ LVM2/tools/polldaemon.c	2009/09/30 18:15:06	1.26
@@ -63,13 +63,6 @@
 	return 1;
 }
 
-typedef enum {
-	PROGRESS_CHECK_FAILED = 0,
-	PROGRESS_UNFINISHED = 1,
-	PROGRESS_FINISHED_SEGMENT = 2,
-	PROGRESS_FINISHED_ALL = 3
-} progress_t;
-
 progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms)
@@ -122,7 +115,7 @@
 		return 0;
 	}
 
-	progress = poll_mirror_progress(cmd, lv, name, parms);
+	progress = parms->poll_fns->poll_progress(cmd, lv, name, parms);
 	if (progress == PROGRESS_CHECK_FAILED)
 		return_0;
 
--- LVM2/tools/polldaemon.h	2009/09/29 19:35:26	1.9
+++ LVM2/tools/polldaemon.h	2009/09/30 18:15:06	1.10
@@ -18,6 +18,15 @@
 
 #include "metadata-exported.h"
 
+typedef enum {
+	PROGRESS_CHECK_FAILED = 0,
+	PROGRESS_UNFINISHED = 1,
+	PROGRESS_FINISHED_SEGMENT = 2,
+	PROGRESS_FINISHED_ALL = 3
+} progress_t;
+
+struct daemon_parms;
+
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (struct logical_volume *lv);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
@@ -28,6 +37,10 @@
 					       const char *name,
 					       const char *uuid,
 					       uint32_t lv_type);
+	progress_t (*poll_progress)(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    const char *name,
+				    struct daemon_parms *parms);
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
 				struct logical_volume *lv,
@@ -54,4 +67,8 @@
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title);
 
+progress_t poll_mirror_progress(struct cmd_context *cmd,
+				struct logical_volume *lv, const char *name,
+				struct daemon_parms *parms);
+
 #endif
--- LVM2/tools/pvmove.c	2009/07/08 18:15:51	1.66
+++ LVM2/tools/pvmove.c	2009/09/30 18:15:07	1.67
@@ -562,6 +562,7 @@
 	.get_copy_name_from_lv = get_pvmove_pvname_from_lv_mirr,
 	.get_copy_vg = _get_move_vg,
 	.get_copy_lv = find_pvmove_lv_from_pvname,
+	.poll_progress = poll_mirror_progress,
 	.update_metadata = _update_metadata,
 	.finish_copy = _finish_pvmove,
 };


