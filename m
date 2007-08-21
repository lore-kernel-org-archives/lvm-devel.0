From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Aug 2007 16:40:34 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20070821164034.3724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-21 16:40:33

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : vgremove.c 

Log message:
	Prepare to move guts of vgremove into lvm library.
	Fixup force_t.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/metadata/lv_manip.c	2007/08/20 20:55:26	1.124
+++ LVM2/lib/metadata/lv_manip.c	2007/08/21 16:40:33	1.125
@@ -1850,7 +1850,7 @@
 			return 0;
 		}
 
-		if (info.exists && (force == DONT_FORCE)) {
+		if (info.exists && (force == PROMPT)) {
 			if (yes_no_prompt("Do you really want to remove active "
 					  "logical volume \"%s\"? [y/n]: ",
 					  lv->name) == 'n') {
--- LVM2/lib/metadata/metadata-exported.h	2007/08/20 20:55:26	1.10
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/21 16:40:33	1.11
@@ -107,9 +107,9 @@
  * Whether or not to force an operation.
  */
 typedef enum {
-	DONT_FORCE = 0,
-	FORCE_NO_CONFIRM = 1, /* skip yes/no confirmation of operation */
-	FORCE_OVERRIDE = 2 /* skip confirmation and bypass a second condition */
+	PROMPT = 0, /* Issue yes/no prompt to confirm operation */
+	DONT_PROMPT = 1, /* Skip yes/no prompt */
+	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
 struct cmd_context;
--- LVM2/tools/vgremove.c	2007/08/20 20:55:30	1.42
+++ LVM2/tools/vgremove.c	2007/08/21 16:40:33	1.43
@@ -15,37 +15,37 @@
 
 #include "tools.h"
 
-static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg, int consistent,
-			   void *handle __attribute((unused)))
+static int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, int consistent,
+			    force_t force)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	int ret = ECMD_PROCESSED;
+	int ret = 1;
 
 	if (!vg || !consistent || (vg_status(vg) & PARTIAL_VG)) {
 		log_error("Volume group \"%s\" not found or inconsistent.",
 			  vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
 			  "is inconsistent.");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!vg_check_status(vg, EXPORTED_VG))
-		return ECMD_FAILED;
+		return 0;
 
 	if (vg->lv_count) {
 		log_error("Volume group \"%s\" still contains %d "
 			  "logical volume(s)", vg_name, vg->lv_count);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!archive(vg))
-		return ECMD_FAILED;
+		return 0;
 
 	if (!vg_remove(vg)) {
 		log_error("vg_remove %s failed", vg_name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* init physical volumes */
@@ -58,7 +58,7 @@
 
 		if (!dev_get_size(pv_dev(pv), &pv->size)) {
 			log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
-			ret = ECMD_FAILED;
+			ret = 0;
 			continue;
 		}
 
@@ -67,19 +67,29 @@
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
 				  dev_name(pv_dev(pv)), vg_name);
-			ret = ECMD_FAILED;
+			ret = 0;
 		}
 	}
 
 	backup_remove(cmd, vg_name);
 
-	if (ret == ECMD_PROCESSED)
+	if (ret)
 		log_print("Volume group \"%s\" successfully removed", vg_name);
 	else
 		log_error("Volume group \"%s\" not properly removed", vg_name);
 
 	return ret;
 }
+static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
+			   struct volume_group *vg, int consistent,
+			   void *handle __attribute((unused)))
+{
+	if (!vg_remove_single(cmd, vg_name, vg, consistent,
+			      arg_count(cmd, force_ARG)))
+		return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
 
 int vgremove(struct cmd_context *cmd, int argc, char **argv)
 {


