From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 12:42:08 -0400
Subject: master - Fix use of orphan lock in commands
Message-ID: <201806121642.w5CGg8Et007223@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a8c36b8917edf00ea875e727b0b775ca5a87a43
Commit:        9a8c36b8917edf00ea875e727b0b775ca5a87a43
Parent:        c4153a8dfca9defcea645818dcd547388858c51e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 11 15:08:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 09:46:11 2018 -0500

Fix use of orphan lock in commands

vgreduce, vgremove and vgcfgrestore were acquiring
the orphan lock in the midst of command processing
instead of at the start of the command.  (The orphan
lock moved to being acquired at the start of the
command back when pvcreate/vgcreate/vgextend were
reworked based on pvcreate_each_device.)

vgsplit also needed a small update to avoid reacquiring
a VG lock that it already held (for the new VG name).
---
 lib/metadata/metadata-exported.h |    4 ++++
 lib/metadata/metadata.c          |   10 ++--------
 lib/metadata/vg.c                |   14 ++++++--------
 tools/vgcfgrestore.c             |   12 ++++++------
 tools/vgreduce.c                 |   13 ++++++++++++-
 tools/vgremove.c                 |    7 +++++++
 tools/vgsplit.c                  |    2 ++
 7 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 641bf49..36a87b5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -693,6 +693,10 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t read_flags, uint32_t lockd_state);
+struct volume_group *vg_read_orphans(struct cmd_context *cmd,
+                                             uint32_t warn_flags,
+                                             const char *orphan_vgname,
+                                             int *consistent);
 
 /* 
  * Test validity of a VG handle.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 30b22c0..9dc5627 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -600,14 +600,8 @@ int vg_remove(struct volume_group *vg)
 {
 	int ret;
 
-	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
 	ret = vg_remove_direct(vg);
 
-	unlock_vg(vg->cmd, vg, VG_ORPHANS);
 	return ret;
 }
 
@@ -3280,7 +3274,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 }
 
 /* Make orphan PVs look like a VG. */
-static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
+struct volume_group *vg_read_orphans(struct cmd_context *cmd,
 					     uint32_t warn_flags,
 					     const char *orphan_vgname,
 					     int *consistent)
@@ -3664,7 +3658,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				  "with pre-commit.");
 			return NULL;
 		}
-		return _vg_read_orphans(cmd, warn_flags, vgname, consistent);
+		return vg_read_orphans(cmd, warn_flags, vgname, consistent);
 	}
 
 	uuid[0] = '\0';
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 400af8d..d837a55 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -671,6 +671,7 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
+	int consistent;
 	int r = 0;
 	const char *name = pv_dev_name(pv);
 
@@ -679,6 +680,8 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		return r;
 	}
 
+	log_debug("vgreduce_single VG %s PV %s", vg->name, pv_dev_name(pv));
+
 	if (pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
 		return r;
@@ -690,11 +693,6 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		return r;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return r;
-	}
-
 	pvl = find_pv_in_vg(vg, name);
 
 	if (!archive(vg))
@@ -716,8 +714,8 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
-				       NULL, 0, 0);
+	/* FIXME: we don't need to vg_read the orphan vg here */
+	orphan_vg = vg_read_orphans(cmd, 0, vg->fid->fmt->orphan_vg_name, &consistent);
 
 	if (vg_read_error(orphan_vg))
 		goto bad;
@@ -755,6 +753,6 @@ bad:
 	/* If we are committing here or we had an error then we will free fid */
 	if (pvl && (commit || r != 1))
 		free_pv_fid(pvl->pv);
-	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
+	release_vg(orphan_vg);
 	return r;
 }
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index ec2c240..0b03687 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -63,14 +63,14 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		lvmetad_rescan = 1;
 	}
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to lock volume group %s.", vg_name);
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Unable to lock orphans.");
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to lock orphans.");
-		unlock_vg(cmd, NULL, vg_name);
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
+		log_error("Unable to lock volume group %s.", vg_name);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -83,8 +83,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 				       arg_str_value(cmd, file_ARG, ""),
 				       arg_count(cmd, force_long_ARG)) :
 	      backup_restore(cmd, vg_name, arg_count(cmd, force_long_ARG)))) {
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 		unlock_vg(cmd, NULL, vg_name);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 		log_error("Restore failed.");
 		ret = ECMD_FAILED;
 		goto rescan;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index e8479a8..ce3d155 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -231,9 +231,20 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	handle->custom_handle = &vp;
 
 	if (!repairing) {
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+			log_error("Can't get lock for orphan PVs");
+			ret = ECMD_FAILED;
+			goto out;
+		}
+
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch afterwards? */
-		ret = process_each_pv(cmd, argc, argv, vg_name, 0, READ_FOR_UPDATE, handle, _vgreduce_single);
+
+		ret = process_each_pv(cmd, argc, argv, vg_name, 0,
+				      READ_FOR_UPDATE | PROCESS_SKIP_ORPHAN_LOCK,
+				      handle, _vgreduce_single);
+
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 		goto out;
 	}
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 8bf3841..5010e7d 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -108,10 +108,17 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	cmd->lockd_gl_disable = 1;
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
 			      READ_FOR_UPDATE, 0,
 			      NULL, &_vgremove_single);
 
+	unlock_vg(cmd, NULL, VG_ORPHANS);
+
 	return ret;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 1e46e7e..7ec00f8 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -748,8 +748,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	/*
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
+	 * We need to unlock vg_to because vg_read_for_update wants to lock it.
 	 */
 	if (!test_mode()) {
+		unlock_vg(cmd, NULL, vg_name_to);
 		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED, 0);


