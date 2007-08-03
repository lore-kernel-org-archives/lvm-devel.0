From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Aug 2007 21:22:10 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20070803212210.772.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-03 21:22:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : lvrename.c 

Log message:
	Factor out core of lvrename to lv_rename library function.
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.676&r2=1.677
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2007/08/01 21:01:06	1.676
+++ LVM2/WHATS_NEW	2007/08/03 21:22:09	1.677
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Factor out core of lvrename() to lv_rename lvm library function.
   Add --log argument to specify log type for mirrors.
   Don't try to monitor devices which we failed to create.
   Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
--- LVM2/lib/metadata/lv_manip.c	2007/01/05 15:53:40	1.115
+++ LVM2/lib/metadata/lv_manip.c	2007/08/03 21:22:09	1.116
@@ -23,6 +23,7 @@
 #include "pv_alloc.h"
 #include "display.h"
 #include "segtype.h"
+#include "archiver.h"
 
 /*
  * PVs used by a segment of an LV
@@ -1459,6 +1460,66 @@
 	return r;
 }
 
+/*
+ * Core of LV renaming routine.
+ * VG must be locked by caller.
+ * Returns 0 on failure, 1 on success.
+ */
+int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
+	      char *newname)
+{
+	struct volume_group *vg = lv->vg;
+
+	if (find_lv_in_vg(vg, newname)) {
+		log_error("Logical volume \"%s\" already exists in "
+			  "volume group \"%s\"", newname, vg->name);
+		return 0;
+	}
+
+	if (lv->status & LOCKED) {
+		log_error("Cannot rename locked LV %s", lv->name);
+		return 0;
+	}
+
+	if ((lv->status & MIRRORED) ||
+	    (lv->status & MIRROR_LOG) ||
+	    (lv->status & MIRROR_IMAGE)) {
+		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
+			  lv->name, strerror(ENOSYS));
+		return 0;
+	}
+
+	if (!archive(vg))
+		return_0;
+
+	if (!(lv->name = dm_pool_strdup(cmd->mem, newname))) {
+		log_error("Failed to allocate space for new name");
+		return 0;
+	}
+
+	log_verbose("Writing out updated volume group");
+	if (!vg_write(vg))
+		return_0;
+
+	backup(vg);
+
+	if (!suspend_lv(cmd, lv)) {
+		stack;
+		vg_revert(vg);
+		return 0;
+	}
+
+	if (!vg_commit(vg)) {
+		stack;
+		resume_lv(cmd, lv);
+		return 0;
+	}
+
+	resume_lv(cmd, lv);
+
+	return 1;
+}
+
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len)
 {
--- LVM2/lib/metadata/metadata-exported.h	2007/07/23 21:03:42	1.3
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/03 21:22:09	1.4
@@ -356,6 +356,9 @@
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
 
+int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
+	      char *newname);
+
 /* Find a PV within a given VG */
 struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
 pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
--- LVM2/tools/lvrename.c	2007/07/23 22:20:42	1.44
+++ LVM2/tools/lvrename.c	2007/08/03 21:22:10	1.45
@@ -16,6 +16,11 @@
 #include "tools.h"
 #include "lvm-types.h"
 
+
+/*
+ * lvrename command implementation.
+ * Check arguments and call lv_rename() to execute the request.
+ */
 int lvrename(struct cmd_context *cmd, int argc, char **argv)
 {
 	size_t maxlen;
@@ -24,7 +29,6 @@
 	char *st;
 
 	struct volume_group *vg;
-	struct logical_volume *lv;
 	struct lv_list *lvl;
 
 	if (argc == 3) {
@@ -103,72 +107,14 @@
 				    CORRECT_INCONSISTENT)))
 		return ECMD_FAILED;
 
-	if (find_lv_in_vg(vg, lv_name_new)) {
-		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", lv_name_new, vg_name);
-		goto error;
-	}
-
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
 		log_error("Existing logical volume \"%s\" not found in "
 			  "volume group \"%s\"", lv_name_old, vg_name);
 		goto error;
 	}
 
-	lv = lvl->lv;
-
-	if (lv->status & LOCKED) {
-		log_error("Cannot rename locked LV %s", lv->name);
+	if (!lv_rename(cmd, lvl->lv, lv_name_new))
 		goto error;
-	}
-
-	if ((lv->status & MIRRORED) ||
-	    (lv->status & MIRROR_LOG) ||
-	    (lv->status & MIRROR_IMAGE)) {
-		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
-			  lv->name, strerror(ENOSYS));
-		goto error;
-	}
-
-	if ((lv->status & MIRRORED) ||
-	    (lv->status & MIRROR_LOG) ||
-	    (lv->status & MIRROR_IMAGE)) {
-		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
-			  lv->name, strerror(ENOSYS));
-		goto error;
-	}
-
-	if (!archive(lv->vg)) {
-		stack;
-		goto error;
-	}
-
-	if (!(lv->name = dm_pool_strdup(cmd->mem, lv_name_new))) {
-		log_error("Failed to allocate space for new name");
-		goto error;
-	}
-
-	log_verbose("Writing out updated volume group");
-	if (!vg_write(vg)) {
-		stack;
-		goto error;
-	}
-
-	backup(lv->vg);
-
-	if (!suspend_lv(cmd, lv)) {
-		stack;
-		vg_revert(vg);
-		goto error;
-	}
-
-	if (!vg_commit(vg)) {
-		stack;
-		resume_lv(cmd, lv);
-		goto error;
-	}
-
-	resume_lv(cmd, lv);
 
 	unlock_vg(cmd, vg_name);
 


