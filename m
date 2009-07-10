From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jul 2009 20:05:30 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090710200530.24777.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-10 20:05:29

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgremove.c 

Log message:
	Remove unnecessary parameters from vg_remove_single().
	
	Use vg_t instead of struct volume_group.
	Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/metadata/metadata-exported.h	2009/07/09 10:09:33	1.87
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/10 20:05:29	1.88
@@ -425,9 +425,7 @@
 
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg,
-		     force_t force);
+int vg_remove_single(vg_t *vg, force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
--- LVM2/lib/metadata/metadata.c	2009/07/09 10:09:33	1.241
+++ LVM2/lib/metadata/metadata.c	2009/07/10 20:05:29	1.242
@@ -359,10 +359,7 @@
 	return 1;
 }
 
-/* FIXME: remove redundant vg_name */
-int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg,
-		     force_t force __attribute((unused)))
+int vg_remove_single(vg_t *vg, force_t force)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -371,7 +368,7 @@
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
-			  "or has PVs missing.", vg_name);
+			  "or has PVs missing.", vg ? vg->name : "");
 		log_error("Consider vgreduce --removemissing if metadata "
 			  "is inconsistent.");
 		return 0;
@@ -387,11 +384,11 @@
 		    (yes_no_prompt("Do you really want to remove volume "
 				   "group \"%s\" containing %u "
 				   "logical volumes? [y/n]: ",
-				   vg_name, lv_count) == 'n')) {
+				   vg->name, lv_count) == 'n')) {
 			log_print("Volume group \"%s\" not removed", vg_name);
 			return 0;
 		}
-		if (!remove_lvs_in_vg(cmd, vg, force))
+		if (!remove_lvs_in_vg(vg->cmd, vg, force))
 			return 0;
 	}
 
@@ -399,7 +396,7 @@
 
 	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
-			  "logical volume(s)", vg_name, lv_count);
+			  "logical volume(s)", vg->name, lv_count);
 		return 0;
 	}
 
@@ -407,7 +404,7 @@
 		return 0;
 
 	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg_name);
+		log_error("vg_remove %s failed", vg->name);
 		return 0;
 	}
 
@@ -415,7 +412,7 @@
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", pv_dev_name(pv), vg_name);
+			    "volume group \"%s\"", pv_dev_name(pv), vg->name);
 		pv->vg_name = vg->fid->fmt->orphan_vg_name;
 		pv->status = ALLOCATABLE_PV;
 
@@ -426,20 +423,20 @@
 		}
 
 		/* FIXME Write to same sector label was read from */
-		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+		if (!pv_write(vg->cmd, pv, NULL, INT64_C(-1))) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
-				  pv_dev_name(pv), vg_name);
+				  pv_dev_name(pv), vg->name);
 			ret = 0;
 		}
 	}
 
-	backup_remove(cmd, vg_name);
+	backup_remove(vg->cmd, vg->name);
 
 	if (ret)
-		log_print("Volume group \"%s\" successfully removed", vg_name);
+		log_print("Volume group \"%s\" successfully removed", vg->name);
 	else
-		log_error("Volume group \"%s\" not properly removed", vg_name);
+		log_error("Volume group \"%s\" not properly removed", vg->name);
 
 	return ret;
 }
--- LVM2/tools/vgremove.c	2009/07/08 14:33:17	1.50
+++ LVM2/tools/vgremove.c	2009/07/10 20:05:29	1.51
@@ -19,8 +19,7 @@
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(cmd, vg_name, vg,
-			      arg_count(cmd, force_ARG)))
+	if (!vg_remove_single(vg, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;


