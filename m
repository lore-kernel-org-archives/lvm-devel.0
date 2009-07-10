From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 11:38:51 -0400
Subject: [PATCH 1/5] Remove unnecessary parameters from vg_remove_single().
In-Reply-To: <1247240335-18769-1-git-send-email-dwysocha@redhat.com>
References: <1247240335-18769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1247240335-18769-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use vg_t instead of struct volume_group.
Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 +---
 lib/metadata/metadata.c          |   27 ++++++++++++---------------
 tools/vgremove.c                 |    3 +--
 3 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5aa0d56..6e085d8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -425,9 +425,7 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg,
-		     force_t force);
+int vg_remove_single(vg_t *vg, force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0c155fd..ea198b0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -359,10 +359,7 @@ static int remove_lvs_in_vg(struct cmd_context *cmd,
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
@@ -371,7 +368,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
-			  "or has PVs missing.", vg_name);
+			  "or has PVs missing.", vg ? vg->name : "");
 		log_error("Consider vgreduce --removemissing if metadata "
 			  "is inconsistent.");
 		return 0;
@@ -387,11 +384,11 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
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
 
@@ -399,7 +396,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
-			  "logical volume(s)", vg_name, lv_count);
+			  "logical volume(s)", vg->name, lv_count);
 		return 0;
 	}
 
@@ -407,7 +404,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		return 0;
 
 	if (!vg_remove(vg)) {
-		log_error("vg_remove %s failed", vg_name);
+		log_error("vg_remove %s failed", vg->name);
 		return 0;
 	}
 
@@ -415,7 +412,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", pv_dev_name(pv), vg_name);
+			    "volume group \"%s\"", pv_dev_name(pv), vg->name);
 		pv->vg_name = vg->fid->fmt->orphan_vg_name;
 		pv->status = ALLOCATABLE_PV;
 
@@ -426,20 +423,20 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
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
diff --git a/tools/vgremove.c b/tools/vgremove.c
index ff35720..8977ea5 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -19,8 +19,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(cmd, vg_name, vg,
-			      arg_count(cmd, force_ARG)))
+	if (!vg_remove_single(vg, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
-- 
1.6.0.6


