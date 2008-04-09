From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Apr 2008 12:45:33 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.h tools/pvmove.c
Message-ID: <20080409124533.23529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-09 12:45:33

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.h pvmove.c 

Log message:
	Fix some pvmove error status codes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.835&r2=1.836
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2008/04/08 22:02:16	1.835
+++ LVM2/WHATS_NEW	2008/04/09 12:45:32	1.836
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix some pvmove error status codes.
   Fix vgsplit error paths to release vg_to lock.
   Indicate whether or not VG is clustered in vgcreate log message.
   Mention default --clustered setting in vgcreate man page.
--- LVM2/tools/polldaemon.h	2007/12/22 12:13:29	1.4
+++ LVM2/tools/polldaemon.h	2008/04/09 12:45:32	1.5
@@ -19,21 +19,21 @@
 #include "metadata-exported.h"
 
 struct poll_functions {
-	const char *(*get_copy_name_from_lv) (struct logical_volume * lv_mirr);
-	struct volume_group *(*get_copy_vg) (struct cmd_context * cmd,
+	const char *(*get_copy_name_from_lv) (struct logical_volume *lv_mirr);
+	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
 					     const char *name);
-	struct logical_volume *(*get_copy_lv) (struct cmd_context * cmd,
-					       struct volume_group * vg,
+	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
+					       struct volume_group *vg,
 					       const char *name,
 					       uint32_t lv_type);
-	int (*update_metadata) (struct cmd_context * cmd,
-				struct volume_group * vg,
-				struct logical_volume * lv_mirr,
-				struct list * lvs_changed, int first_time);
-	int (*finish_copy) (struct cmd_context * cmd,
-			    struct volume_group * vg,
-			    struct logical_volume * lv_mirr,
-			    struct list * lvs_changed);
+	int (*update_metadata) (struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct logical_volume *lv_mirr,
+				struct list *lvs_changed, int first_time);
+	int (*finish_copy) (struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct logical_volume *lv_mirr,
+			    struct list *lvs_changed);
 };
 
 struct daemon_parms {
--- LVM2/tools/pvmove.c	2008/04/07 10:23:47	1.50
+++ LVM2/tools/pvmove.c	2008/04/09 12:45:32	1.51
@@ -565,8 +565,10 @@
 	char *colon;
 	int ret;
 
-	if (!pvmove_target_present(cmd, 0))
-		return 0;
+	if (!pvmove_target_present(cmd, 0)) {
+		stack;
+		return ECMD_FAILED;
+	}
 
 	if (argc) {
 		pv_name = argv[0];
@@ -577,7 +579,7 @@
 						     (unsigned) (colon -
 								 pv_name)))) {
 				log_error("Failed to clone PV name");
-				return 0;
+				return ECMD_FAILED;
 			}
 		}
 
@@ -587,7 +589,6 @@
 			stack;
 			return ret;
 		}
-
 	}
 
 	return pvmove_poll(cmd, pv_name,


