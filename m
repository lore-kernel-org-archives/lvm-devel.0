From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Jun 2016 16:20:23 +0000 (UTC)
Subject: master - vgcfgrestore: use lvmetad disabled state
Message-ID: <20160620162023.72FD86055B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ae22125c62ddea4340916a5e255d55844bfd087
Commit:        6ae22125c62ddea4340916a5e255d55844bfd087
Parent:        cae6591b9ddc5e94b64c542503d34448babf720f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 17 16:37:30 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 20 11:19:49 2016 -0500

vgcfgrestore: use lvmetad disabled state

Previously, vgcfgrestore would attempt to vg_remove the
existing VG from lvmetad and then vg_update to add the
restored VG.  But, if there was a failure in the command
or with vg_update, the lvmetad cache would be left incorrect.
Now, disable lvmetad before the restore begins, and then
rescan to populate lvmetad from disk after restore has
written the new VG to disk.
---
 daemons/lvmetad/lvmetad-client.h |    1 +
 daemons/lvmetad/lvmetad-core.c   |   10 +++++++---
 lib/cache/lvmetad.c              |    3 +++
 lib/format_text/archiver.c       |   16 ++--------------
 lib/format_text/archiver.h       |    4 +---
 tools/vgcfgrestore.c             |   32 +++++++++++++++++++++++++++++++-
 tools/vgconvert.c                |    2 +-
 7 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index b352c04..dd6a379 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -24,6 +24,7 @@
 #define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
 #define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
+#define LVMETAD_DISABLE_REASON_VGRESTORE	"VGRESTORE"
 
 struct volume_group;
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ca1e4ed..aab569f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -202,8 +202,9 @@ struct vg_info {
 #define GLFL_DISABLE_REASON_DIRECT     0x00000004
 #define GLFL_DISABLE_REASON_LVM1       0x00000008
 #define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
+#define GLFL_DISABLE_REASON_VGRESTORE  0x00000020
 
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES)
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
 
 #define VGFL_INVALID 0x00000001
 
@@ -2347,6 +2348,8 @@ static response set_global_info(lvmetad_state *s, request r)
 			reason_flags |= GLFL_DISABLE_REASON_LVM1;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
 			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
+		if (strstr(reason, LVMETAD_DISABLE_REASON_VGRESTORE))
+			reason_flags |= GLFL_DISABLE_REASON_VGRESTORE;
 	}
 
 	if (global_invalid != -1) {
@@ -2404,10 +2407,11 @@ static response get_global_info(lvmetad_state *s, request r)
 	pid = (int)daemon_request_int(r, "pid", 0);
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "");
+			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
+			 (s->flags & GLFL_DISABLE_REASON_VGRESTORE)  ? LVMETAD_DISABLE_REASON_VGRESTORE "," : "");
 	}
 
 	if (!reason[0])
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0508291..ee44202 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2726,6 +2726,9 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
 			*reason = "duplicate PVs were found";
 
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_VGRESTORE)) {
+			*reason = "vgcfgrestore is restoring VG metadata";
+
 		} else {
 			*reason = "<unknown>";
 		}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 4e85e0e..e6d4b59 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -359,9 +359,7 @@ static int _restore_vg_should_write_pv(struct physical_volume *pv, int do_pvcrea
 
 /* ORPHAN and VG locks held before calling this */
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
-		      int drop_lvmetad,
-		      int do_pvcreate,
-		      struct pv_create_args *pva)
+		      int do_pvcreate, struct pv_create_args *pva)
 {
 	struct dm_list new_pvs;
 	struct pv_list *pvl, *new_pvl;
@@ -502,16 +500,6 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 	if (!vg_write(vg))
 		return_0;
 
-	if (drop_lvmetad && lvmetad_used()) {
-		struct volume_group *vg_lvmetad = lvmetad_vg_lookup(cmd, vg->name, NULL);
-		if (vg_lvmetad) {
-			/* FIXME Cope with failure to update lvmetad */
-			if (!lvmetad_vg_remove(vg_lvmetad))
-				stack;
-			release_vg(vg_lvmetad);
-		}
-	}
-
 	if (!vg_commit(vg))
 		return_0;
 
@@ -550,7 +538,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg, 1, 0, NULL);
+		r = backup_restore_vg(cmd, vg, 0, NULL);
 	else
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index 82f7620..e949751 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -53,9 +53,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
 
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
-                      int drop_lvmetad,
-                      int do_pvcreate,
-		      struct pv_create_args *pva);
+                      int do_pvcreate, struct pv_create_args *pva);
 
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file, int force);
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 8e51ed6..54e382c 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -14,10 +14,12 @@
  */
 
 #include "tools.h"
+#include "lvmetad-client.h"
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *vg_name = NULL;
+	int lvmetad_rescan = 0;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -44,7 +46,21 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	lvmcache_seed_infos_from_lvmetad(cmd);
+	/*
+	 * lvmetad does not handle a VG being restored, which would require
+	 * vg_remove of the existing VG, then vg_update of the restored VG.  A
+	 * command failure after removing the existing VG from lvmetad would
+	 * not be easily recovered from.  So, disable the lvmetad cache before
+	 * doing the restore.  After the VG is restored on disk, rescan
+	 * metadata from disk to populate lvmetad from scratch which will pick
+	 * up the VG that was restored on disk.
+	 */
+
+	if (lvmetad_used()) {
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_VGRESTORE);
+		lvmetad_disconnect();
+		lvmetad_rescan = 1;
+	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock volume group %s", vg_name);
@@ -74,5 +90,19 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vg_name);
+
+	if (lvmetad_rescan) {
+		if (!lvmetad_connect(cmd)) {
+			log_warn("WARNING: Failed to connect to lvmetad.");
+			log_warn("WARNING: Update lvmetad with pvscan --cache.");
+			goto out;
+		}
+		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
+			log_warn("WARNING: Failed to scan devices.");
+			log_warn("WARNING: Update lvmetad with pvscan --cache.");
+			goto out;
+		}
+	}
+out:
 	return ECMD_PROCESSED;
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 846db05..4c3d560 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -126,7 +126,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
 
-	if (!backup_restore_vg(cmd, vg, 0, 1, &pva)) {
+	if (!backup_restore_vg(cmd, vg, 1, &pva)) {
 		log_error("Conversion failed for volume group %s.", vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");


