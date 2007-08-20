From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2007 17:04:56 -0000
Subject: LVM2 lib/display/display.c lib/display/display ...
Message-ID: <20070820170456.16121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-20 17:04:53

Modified files:
	lib/display    : display.c display.h 
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : lvmcmdline.c lvremove.c tools.h 

Log message:
	Move lv_remove_single() into library (lv_manip.c, metadata-exported.h).
	Move yes_no_prompt() into library (display.c, display.h).
	Fixup includes as a result of movement of prior two functions.
	Fixup force_t enum to be more descriptive.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/display/display.c	2007/08/07 09:06:05	1.76
+++ LVM2/lib/display/display.c	2007/08/20 17:04:52	1.77
@@ -726,3 +726,34 @@
 	}
 }
 
+char yes_no_prompt(const char *prompt, ...)
+{
+	int c = 0, ret = 0;
+	va_list ap;
+
+	sigint_allow();
+	do {
+		if (c == '\n' || !c) {
+			va_start(ap, prompt);
+			vprintf(prompt, ap);
+			va_end(ap);
+		}
+
+		if ((c = getchar()) == EOF) {
+			ret = 'n';
+			break;
+		}
+
+		c = tolower(c);
+		if ((c == 'y') || (c == 'n'))
+			ret = c;
+	} while (!ret || c != '\n');
+
+	sigint_restore();
+
+	if (c != '\n')
+		printf("\n");
+
+	return ret;
+}
+
--- LVM2/lib/display/display.h	2007/08/07 09:06:05	1.19
+++ LVM2/lib/display/display.h	2007/08/20 17:04:52	1.20
@@ -17,6 +17,7 @@
 #define _LVM_DISPLAY_H
 
 #include "metadata-exported.h"
+#include "locking.h"
 
 #include <stdint.h>
 
@@ -58,4 +59,6 @@
 const char *get_alloc_string(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
+char yes_no_prompt(const char *prompt, ...);
+
 #endif
--- LVM2/lib/metadata/lv_manip.c	2007/08/08 18:00:36	1.122
+++ LVM2/lib/metadata/lv_manip.c	2007/08/20 17:04:52	1.123
@@ -24,6 +24,7 @@
 #include "display.h"
 #include "segtype.h"
 #include "archiver.h"
+#include "activate.h"
 
 struct lv_names {
 	const char *old;
@@ -1804,3 +1805,114 @@
 
 	return parallel_areas;
 }
+
+int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
+		     force_t force)
+{
+	struct volume_group *vg;
+	struct lvinfo info;
+	struct logical_volume *origin = NULL;
+
+	vg = lv->vg;
+
+	if (!vg_check_status(vg, LVM_WRITE))
+		return 0;
+
+	if (lv_is_origin(lv)) {
+		log_error("Can't remove logical volume \"%s\" under snapshot",
+			  lv->name);
+		return 0;
+	}
+
+	if (lv->status & MIRROR_IMAGE) {
+		log_error("Can't remove logical volume %s used by a mirror",
+			  lv->name);
+		return 0;
+	}
+
+	if (lv->status & MIRROR_LOG) {
+		log_error("Can't remove logical volume %s used as mirror log",
+			  lv->name);
+		return 0;
+	}
+
+	if (lv->status & LOCKED) {
+		log_error("Can't remove locked LV %s", lv->name);
+		return 0;
+	}
+
+	/* FIXME Ensure not referred to by another existing LVs */
+
+	if (lv_info(cmd, lv, &info, 1)) {
+		if (info.open_count) {
+			log_error("Can't remove open logical volume \"%s\"",
+				  lv->name);
+			return 0;
+		}
+
+		if (info.exists && (force == DONT_FORCE)) {
+			if (yes_no_prompt("Do you really want to remove active "
+					  "logical volume \"%s\"? [y/n]: ",
+					  lv->name) == 'n') {
+				log_print("Logical volume \"%s\" not removed",
+					  lv->name);
+				return 0;
+			}
+		}
+	}
+
+	if (!archive(vg))
+		return 0;
+
+	/* If the VG is clustered then make sure no-one else is using the LV
+	   we are about to remove */
+	if (vg_status(vg) & CLUSTERED) {
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Can't get exclusive access to volume \"%s\"",
+				  lv->name);
+			return 0;
+		}
+	}
+
+	/* FIXME Snapshot commit out of sequence if it fails after here? */
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate logical volume \"%s\"",
+			  lv->name);
+		return 0;
+	}
+
+	if (lv_is_cow(lv)) {
+		origin = origin_from_cow(lv);
+		log_verbose("Removing snapshot %s", lv->name);
+		if (!vg_remove_snapshot(lv)) {
+			stack;
+			return 0;
+		}
+	}
+
+	log_verbose("Releasing logical volume \"%s\"", lv->name);
+	if (!lv_remove(lv)) {
+		log_error("Error releasing logical volume \"%s\"", lv->name);
+		return 0;
+	}
+
+	/* store it on disks */
+	if (!vg_write(vg))
+		return 0;
+
+	backup(vg);
+
+	if (!vg_commit(vg))
+		return 0;
+
+	/* If no snapshots left, reload without -real. */
+	if (origin && !lv_is_origin(origin)) {
+		if (!suspend_lv(cmd, origin))
+			log_error("Failed to refresh %s without snapshot.", origin->name);
+		else if (!resume_lv(cmd, origin))
+			log_error("Failed to resume %s.", origin->name);
+	}
+
+	log_print("Logical volume \"%s\" successfully removed", lv->name);
+	return 1;
+}
--- LVM2/lib/metadata/metadata-exported.h	2007/08/20 16:16:54	1.8
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/20 17:04:52	1.9
@@ -108,8 +108,8 @@
  */
 typedef enum {
 	DONT_FORCE = 0,
-	FORCE = 1,
-	FORCE_2 = 2
+	FORCE_NO_CONFIRM = 1, /* skip yes/no confirmation of operation */
+	FORCE_OVERRIDE = 2 /* skip confirmation and bypass a second condition */
 } force_t;
 
 struct cmd_context;
@@ -365,6 +365,9 @@
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
 
+int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
+		     force_t force);
+
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 
--- LVM2/tools/lvmcmdline.c	2007/07/20 15:48:39	1.45
+++ LVM2/tools/lvmcmdline.c	2007/08/20 17:04:53	1.46
@@ -368,37 +368,6 @@
 	return 1;
 }
 
-char yes_no_prompt(const char *prompt, ...)
-{
-	int c = 0, ret = 0;
-	va_list ap;
-
-	sigint_allow();
-	do {
-		if (c == '\n' || !c) {
-			va_start(ap, prompt);
-			vprintf(prompt, ap);
-			va_end(ap);
-		}
-
-		if ((c = getchar()) == EOF) {
-			ret = 'n';
-			break;
-		}
-
-		c = tolower(c);
-		if ((c == 'y') || (c == 'n'))
-			ret = c;
-	} while (!ret || c != '\n');
-
-	sigint_restore();
-
-	if (c != '\n')
-		printf("\n");
-
-	return ret;
-}
-
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
--- LVM2/tools/lvremove.c	2007/08/20 16:16:54	1.51
+++ LVM2/tools/lvremove.c	2007/08/20 17:04:53	1.52
@@ -15,125 +15,13 @@
 
 #include "tools.h"
 
-/* TODO: Next checkin, move to lvm library (lv_manip.c, metadata-exported.h) */
-static int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-			    force_t force)
-{
-	struct volume_group *vg;
-	struct lvinfo info;
-	struct logical_volume *origin = NULL;
-
-	vg = lv->vg;
-
-	if (!vg_check_status(vg, LVM_WRITE))
-		return 0;
-
-	if (lv_is_origin(lv)) {
-		log_error("Can't remove logical volume \"%s\" under snapshot",
-			  lv->name);
-		return 0;
-	}
-
-	if (lv->status & MIRROR_IMAGE) {
-		log_error("Can't remove logical volume %s used by a mirror",
-			  lv->name);
-		return 0;
-	}
-
-	if (lv->status & MIRROR_LOG) {
-		log_error("Can't remove logical volume %s used as mirror log",
-			  lv->name);
-		return 0;
-	}
-
-	if (lv->status & LOCKED) {
-		log_error("Can't remove locked LV %s", lv->name);
-		return 0;
-	}
-
-	/* FIXME Ensure not referred to by another existing LVs */
-
-	if (lv_info(cmd, lv, &info, 1)) {
-		if (info.open_count) {
-			log_error("Can't remove open logical volume \"%s\"",
-				  lv->name);
-			return 0;
-		}
-
-		if (info.exists && (force == DONT_FORCE)) {
-			if (yes_no_prompt("Do you really want to remove active "
-					  "logical volume \"%s\"? [y/n]: ",
-					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			}
-		}
-	}
-
-	if (!archive(vg))
-		return 0;
-
-	/* If the VG is clustered then make sure no-one else is using the LV
-	   we are about to remove */
-	if (vg_status(vg) & CLUSTERED) {
-		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Can't get exclusive access to volume \"%s\"",
-				  lv->name);
-			return 0;
-		}
-	}
-
-	/* FIXME Snapshot commit out of sequence if it fails after here? */
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate logical volume \"%s\"",
-			  lv->name);
-		return 0;
-	}
-
-	if (lv_is_cow(lv)) {
-		origin = origin_from_cow(lv);
-		log_verbose("Removing snapshot %s", lv->name);
-		if (!vg_remove_snapshot(lv)) {
-			stack;
-			return 0;
-		}
-	}
-
-	log_verbose("Releasing logical volume \"%s\"", lv->name);
-	if (!lv_remove(lv)) {
-		log_error("Error releasing logical volume \"%s\"", lv->name);
-		return 0;
-	}
-
-	/* store it on disks */
-	if (!vg_write(vg))
-		return 0;
-
-	backup(vg);
-
-	if (!vg_commit(vg))
-		return 0;
-
-	/* If no snapshots left, reload without -real. */
-	if (origin && !lv_is_origin(origin)) {
-		if (!suspend_lv(cmd, origin))
-			log_error("Failed to refresh %s without snapshot.", origin->name);
-		else if (!resume_lv(cmd, origin))
-			log_error("Failed to resume %s.", origin->name);
-	}
-
-	log_print("Logical volume \"%s\" successfully removed", lv->name);
-	return 1;
-}
-
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
 	if (!lv_remove_single(cmd, lv, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
-	else
-		return ECMD_PROCESSED;
+
+	return ECMD_PROCESSED;
 }
 
 int lvremove(struct cmd_context *cmd, int argc, char **argv)
--- LVM2/tools/tools.h	2007/08/07 09:06:05	1.54
+++ LVM2/tools/tools.h	2007/08/20 17:04:53	1.55
@@ -144,7 +144,6 @@
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 
-char yes_no_prompt(const char *prompt, ...);
 
 /* we use the enums to access the switches */
 unsigned int arg_count(const struct cmd_context *cmd, int a);


