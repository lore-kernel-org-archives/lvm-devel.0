From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 02 Dec 2010 15:30:01 +0100
Subject: [PATCH] Generate an archive (if possible) and a backup for metadata while running vgcfgrestore
Message-ID: <4CF7AD69.7010103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should archive existing backup (if possible) and make
a new backup even for vgcfgrestore (rhbz #640589).

I've changed backup_restore_from_file and backup_restore fn
to return the VG that has just been restored, so I can call
backup for it in the layer above.

Peter
---
 lib/format_text/archiver.c |   35 ++++++++++++++++++++++++++---------
 lib/format_text/archiver.h |    6 +++---
 tools/vgcfgrestore.c       |   34 ++++++++++++++++++++++++++++++----
 3 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 3ace628..7d025b3 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -272,6 +272,17 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	struct format_instance *tf;
 	struct metadata_area *mda;
 	void *context;
+	char path[PATH_MAX];
+
+	/* Use default backup directory if not defined directly. */
+	if (!file) {
+		if (dm_snprintf(path, sizeof(path), "%s/%s",
+			cmd->backup_params->dir, vg_name) < 0) {
+			log_debug("Failed to generate backup filename (for read).");
+			return NULL;
+		}
+		file = path;
+	}
 
 	if (!(context = create_text_context(cmd, file,
 					    cmd->cmd_line)) ||
@@ -346,11 +357,12 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 }
 
 /* ORPHAN and VG locks held before calling this */
-int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
-			     const char *file)
+struct volume_group *backup_restore_from_file(struct cmd_context *cmd,
+					      const char *vg_name,
+					      const char *file)
 {
 	struct volume_group *vg;
-	int missing_pvs, r = 0;
+	int missing_pvs;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -358,18 +370,23 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 	if (!(vg = backup_read_vg(cmd, vg_name, file)))
 		return_0;
 
-	missing_pvs = vg_missing_pv_count(vg);
-	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg);
-	else
+	if ((missing_pvs = vg_missing_pv_count(vg))) {
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
+		goto bad;
+	}
 
+	if (!backup_restore_vg(cmd, vg))
+		goto_bad;
+
+	return vg;
+
+bad:
 	vg_release(vg);
-	return r;
+	return NULL;
 }
 
-int backup_restore(struct cmd_context *cmd, const char *vg_name)
+struct volume_group *backup_restore(struct cmd_context *cmd, const char *vg_name)
 {
 	char path[PATH_MAX];
 
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index 7346f93..1a60d06 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -52,9 +52,9 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name);
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg);
-int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
-			     const char *file);
-int backup_restore(struct cmd_context *cmd, const char *vg_name);
+struct volume_group *backup_restore_from_file(struct cmd_context *cmd,
+				const char *vg_name, const char *file);
+struct volume_group *backup_restore(struct cmd_context *cmd, const char *vg_name);
 
 int backup_to_file(const char *file, const char *desc, struct volume_group *vg);
 
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index dc0158f..a6e81df 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -18,6 +18,8 @@
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
 	char *vg_name = NULL;
+	struct volume_group *old_vg_backup, *restored_vg;
+	int old_suppress;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -45,6 +47,15 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
+	/*
+	 * Try to read any existing backup to archive it later on.
+	 * Don't care if it does not exist (..we can restore a VG
+	 * that does not currently exist in the system).
+	*/
+        old_suppress = log_suppress(1);
+        old_vg_backup = backup_read_vg(cmd, vg_name, NULL);
+        log_suppress(old_suppress);
+
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		return ECMD_FAILED;
@@ -56,20 +67,35 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (old_vg_backup) {
+		if (!archive(old_vg_backup))
+			stack;
+		vg_release(old_vg_backup);
+	}
+	else
+		log_verbose("No existing backup for VG %s found, "
+			    "skipping archive creation.", vg_name);
+
 	cmd->handles_unknown_segments = 1;
 
-	if (!(arg_count(cmd, file_ARG) ?
-	      backup_restore_from_file(cmd, vg_name,
-				       arg_str_value(cmd, file_ARG, "")) :
-	      backup_restore(cmd, vg_name))) {
+	if (arg_count(cmd, file_ARG))
+		restored_vg = backup_restore_from_file(cmd, vg_name,
+				arg_str_value(cmd, file_ARG, ""));
+	else
+		restored_vg = backup_restore(cmd, vg_name);
+
+	if (!restored_vg) {
 		unlock_vg(cmd, VG_ORPHANS);
 		unlock_vg(cmd, vg_name);
 		log_error("Restore failed.");
 		return ECMD_FAILED;
 	}
 
+	backup(restored_vg);
+
 	log_print("Restored volume group %s", vg_name);
 
+	vg_release(restored_vg);
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vg_name);
 	return ECMD_PROCESSED;


