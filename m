From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Aug 2007 17:38:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20070821173823.16150.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-21 17:38:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgremove.c 

Log message:
	Move guts of vgremove into lvm library.
	Include archiver.h in metadata.c as a result of prior move.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.686&r2=1.687
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2007/08/20 20:55:24	1.686
+++ LVM2/WHATS_NEW	2007/08/21 17:37:34	1.687
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Move guts of vgremove into library.
   Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.
   Move guts of lvremove into library.
   Allow clvmd debug to be turned on in a running daemon using clvmd -d
--- LVM2/lib/metadata/metadata-exported.h	2007/08/21 16:40:33	1.11
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/21 17:37:53	1.12
@@ -330,6 +330,9 @@
 			       uint32_t max_lv, alloc_policy_t alloc,
 			       int pv_count, char **pv_names);
 int vg_remove(struct volume_group *vg);
+int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
+		     struct volume_group *vg, int consistent,
+		     force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
--- LVM2/lib/metadata/metadata.c	2007/08/20 20:55:26	1.132
+++ LVM2/lib/metadata/metadata.c	2007/08/21 17:38:08	1.133
@@ -25,6 +25,7 @@
 #include "activate.h"
 #include "display.h"
 #include "locking.h"
+#include "archiver.h"
 
 #include <sys/param.h>
 
@@ -248,6 +249,72 @@
 	return 1;
 }
 
+int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
+		     struct volume_group *vg, int consistent,
+		     force_t force)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	int ret = 1;
+
+	if (!vg || !consistent || (vg_status(vg) & PARTIAL_VG)) {
+		log_error("Volume group \"%s\" not found or inconsistent.",
+			  vg_name);
+		log_error("Consider vgreduce --removemissing if metadata "
+			  "is inconsistent.");
+		return 0;
+	}
+
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return 0;
+
+	if (vg->lv_count) {
+		log_error("Volume group \"%s\" still contains %d "
+			  "logical volume(s)", vg_name, vg->lv_count);
+		return 0;
+	}
+
+	if (!archive(vg))
+		return 0;
+
+	if (!vg_remove(vg)) {
+		log_error("vg_remove %s failed", vg_name);
+		return 0;
+	}
+
+	/* init physical volumes */
+	list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		log_verbose("Removing physical volume \"%s\" from "
+			    "volume group \"%s\"", dev_name(pv_dev(pv)), vg_name);
+		pv->vg_name = ORPHAN;
+		pv->status = ALLOCATABLE_PV;
+
+		if (!dev_get_size(pv_dev(pv), &pv->size)) {
+			log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
+			ret = 0;
+			continue;
+		}
+
+		/* FIXME Write to same sector label was read from */
+		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+			log_error("Failed to remove physical volume \"%s\""
+				  " from volume group \"%s\"",
+				  dev_name(pv_dev(pv)), vg_name);
+			ret = 0;
+		}
+	}
+
+	backup_remove(cmd, vg_name);
+
+	if (ret)
+		log_print("Volume group \"%s\" successfully removed", vg_name);
+	else
+		log_error("Volume group \"%s\" not properly removed", vg_name);
+
+	return ret;
+}
+
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
 {
 	int i;
--- LVM2/tools/vgremove.c	2007/08/21 16:40:33	1.43
+++ LVM2/tools/vgremove.c	2007/08/21 17:38:20	1.44
@@ -15,71 +15,6 @@
 
 #include "tools.h"
 
-static int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
-			    force_t force)
-{
-	struct physical_volume *pv;
-	struct pv_list *pvl;
-	int ret = 1;
-
-	if (!vg || !consistent || (vg_status(vg) & PARTIAL_VG)) {
-		log_error("Volume group \"%s\" not found or inconsistent.",
-			  vg_name);
-		log_error("Consider vgreduce --removemissing if metadata "
-			  "is inconsistent.");
-		return 0;
-	}
-
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return 0;
-
-	if (vg->lv_count) {
-		log_error("Volume group \"%s\" still contains %d "
-			  "logical volume(s)", vg_name, vg->lv_count);
-		return 0;
-	}
-
-	if (!archive(vg))
-		return 0;
-
-	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg_name);
-		return 0;
-	}
-
-	/* init physical volumes */
-	list_iterate_items(pvl, &vg->pvs) {
-		pv = pvl->pv;
-		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", dev_name(pv_dev(pv)), vg_name);
-		pv->vg_name = ORPHAN;
-		pv->status = ALLOCATABLE_PV;
-
-		if (!dev_get_size(pv_dev(pv), &pv->size)) {
-			log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
-			ret = 0;
-			continue;
-		}
-
-		/* FIXME Write to same sector label was read from */
-		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
-			log_error("Failed to remove physical volume \"%s\""
-				  " from volume group \"%s\"",
-				  dev_name(pv_dev(pv)), vg_name);
-			ret = 0;
-		}
-	}
-
-	backup_remove(cmd, vg_name);
-
-	if (ret)
-		log_print("Volume group \"%s\" successfully removed", vg_name);
-	else
-		log_error("Volume group \"%s\" not properly removed", vg_name);
-
-	return ret;
-}
 static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg, int consistent,
 			   void *handle __attribute((unused)))


