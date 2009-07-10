From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:07:03 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090710200703.25140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:07:03

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgremove.c 

Log message:
	Remove force parameter from vg_remove_single, now the liblvm function.
	
	Move check for active LVs outside of library function.  The vgremove
	liblvm function function will fail if there are active LVs.  It will
	be the application's responsibility to check this condition and remove
	the LVs individually before calling vgremove.  Note also that we've
	duplicated the EXPORTED_VG check in vgremove_single (tools) and
	vg_remove_single (library).  Duplication seemed the only option here
	since we don't want to do the automatic removal of LVs (in the tools)
	if the vg is exported, and we still need to protect the library call
	from removal if the vg is exported.
	
	We still need to deal with the ORPHAN lock but vg_remove_single is now
	very close to our liblvm function.
	
	TODO: Refactor lvremove in a similar way.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/metadata/metadata-exported.h	2009/07/10 20:05:29	1.88
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/10 20:07:02	1.89
@@ -425,7 +425,7 @@
 
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(vg_t *vg, force_t force);
+int vg_remove_single(vg_t *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
@@ -436,6 +436,10 @@
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
+/* FIXME: refactor / unexport when lvremove liblvm refactoring dones */
+int remove_lvs_in_vg(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     force_t force);
 /*
  * vg_release() must be called on every struct volume_group allocated
  * by vg_create() or vg_read_internal() to free it when no longer required.
--- LVM2/lib/metadata/metadata.c	2009/07/10 20:05:29	1.242
+++ LVM2/lib/metadata/metadata.c	2009/07/10 20:07:02	1.243
@@ -343,9 +343,9 @@
 	return 1;
 }
 
-static int remove_lvs_in_vg(struct cmd_context *cmd,
-			    struct volume_group *vg,
-			    force_t force)
+int remove_lvs_in_vg(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     force_t force)
 {
 	struct dm_list *lst;
 	struct lv_list *lvl;
@@ -359,7 +359,7 @@
 	return 1;
 }
 
-int vg_remove_single(vg_t *vg, force_t force)
+int vg_remove_single(vg_t *vg)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -380,21 +380,6 @@
 	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
-		if ((force == PROMPT) &&
-		    (yes_no_prompt("Do you really want to remove volume "
-				   "group \"%s\" containing %u "
-				   "logical volumes? [y/n]: ",
-				   vg->name, lv_count) == 'n')) {
-			log_print("Volume group \"%s\" not removed", vg_name);
-			return 0;
-		}
-		if (!remove_lvs_in_vg(vg->cmd, vg, force))
-			return 0;
-	}
-
-	lv_count = vg_visible_lvs(vg);
-
-	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
 			  "logical volume(s)", vg->name, lv_count);
 		return 0;
--- LVM2/tools/vgremove.c	2009/07/10 20:05:29	1.51
+++ LVM2/tools/vgremove.c	2009/07/10 20:07:03	1.52
@@ -19,7 +19,29 @@
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(vg, arg_count(cmd, force_ARG)))
+	unsigned lv_count;
+	force_t force;
+
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return ECMD_FAILED;
+
+	lv_count = vg_visible_lvs(vg);
+
+	force = arg_count(cmd, force_ARG);
+	if (lv_count) {
+		if ((force == PROMPT) &&
+		    (yes_no_prompt("Do you really want to remove volume "
+				   "group \"%s\" containing %u "
+				   "logical volumes? [y/n]: ",
+				   vg_name, lv_count) == 'n')) {
+			log_print("Volume group \"%s\" not removed", vg_name);
+			return ECMD_FAILED;
+		}
+		if (!remove_lvs_in_vg(cmd, vg, force))
+			return ECMD_FAILED;
+	}
+
+	if (!vg_remove_single(vg))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;


