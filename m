From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:28 +0000 (UTC)
Subject: master - lvmetad: two phase vg_update
Message-ID: <20160628013328.91DDC60237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7c45ddc59449fa8b1823bcab31e3fbb64fed97c
Commit:        a7c45ddc59449fa8b1823bcab31e3fbb64fed97c
Parent:        cc3e7c7c31de8d69d9f1eb610181584482ee90a3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 8 14:42:03 2016 -0500
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:30:31 2016 +0100

lvmetad: two phase vg_update

Previously, a command sent lvmetad new VG metadata in vg_commit().
In vg_commit(), devices are suspended, so any memory allocation
done by the command while sending to lvmetad, or by lvmetad while
updating its cache could deadlock if memory reclaim was triggered.

Now lvmetad is updated in unlock_vg(), after devices are resumed.
The new method for updating VG metadata in lvmetad is in two phases:

1. In vg_write(), before devices are suspended, the command sends
   lvmetad a short message ("set_vg_info") telling it what the new
   VG seqno will be.  lvmetad sees that the seqno is newer than
   the seqno of its cached VG, so it sets the INVALID flag for the
   cached VG.  If sending the message to lvmetad fails, the command
   fails before the metadata is committed and the change is not made.
   If sending the message succeeds, vg_commit() is called.

2. In unlock_vg(), after devices are resumed, the command sends
   lvmetad the standard vg_update message with the new metadata.
   lvmetad sees that the seqno in the new metadata matches the
   seqno it saved from set_vg_info, and knows it has the latest
   copy, so it clears the INVALID flag for the cached VG.

If a command fails between 1 and 2 (after committing the VG on disk,
but before sending lvmetad the new metadata), the cached VG retains
the INVALID flag in lvmetad.  A subsequent command will read the
cached VG from lvmetad, see the INVALID flag, ignore the cached
copy, read the VG from disk instead, update the lvmetad copy
with the latest copy from disk, (this clears the INVALID flag
in lvmetad), and use the correct VG metadata for the command.

(This INVALID mechanism already existed for use by lvmlockd.)
---
 daemons/lvmetad/lvmetad-core.c  |    9 ++-
 lib/cache/lvmetad.c             |  113 ++++++++++++++++++++++++++++++++-------
 lib/cache/lvmetad.h             |    5 ++-
 lib/format_text/archiver.c      |    1 +
 lib/locking/locking.h           |    6 ++-
 lib/metadata/metadata.c         |   37 +++++++++----
 lib/metadata/pv_manip.c         |    2 +-
 lib/metadata/replicator_manip.c |    1 +
 lib/metadata/vg.c               |    1 +
 lib/metadata/vg.h               |    1 +
 liblvm/lvm_pv.c                 |    5 +-
 liblvm/lvm_vg.c                 |    7 ++-
 tools/pvchange.c                |    2 +-
 tools/pvcreate.c                |    2 +-
 tools/pvdisplay.c               |    2 +-
 tools/pvremove.c                |    2 +-
 tools/pvscan.c                  |    4 +-
 tools/reporter.c                |    2 +-
 tools/toollib.c                 |   10 ++--
 tools/vgcfgrestore.c            |   10 ++--
 tools/vgcreate.c                |   10 ++--
 tools/vgextend.c                |    2 +-
 tools/vgimportclone.c           |    4 +-
 tools/vgrename.c                |    6 +-
 tools/vgscan.c                  |    2 +-
 tools/vgsplit.c                 |    6 ++
 26 files changed, 181 insertions(+), 71 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index aab569f..1ec9e3b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2464,10 +2464,10 @@ static response set_vg_info(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *vg;
 	struct vg_info *info;
-	const char *name;
-	const char *uuid;
+	const char *name = NULL;
+	const char *uuid = NULL;
 	const int64_t new_version = daemon_request_int(r, "version", -1);
-	int64_t cache_version;
+	int64_t cache_version = -1;
 
 	if (new_version == -1)
 		goto out;
@@ -2500,6 +2500,9 @@ vers:
 	if (cache_version != -1 && new_version != -1 && cache_version >= new_version)
 		goto out;
 inval:
+	DEBUGLOG(s, "set info VG name %s uuid %s cache_version %d new_version %d",
+		 name ?: "none", uuid ?: "none", (int)cache_version, (int)new_version);
+
 	info = dm_hash_lookup(s->vgid_to_info, uuid);
 	if (!info) {
 		info = malloc(sizeof(struct vg_info));
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a0a17ac..784a529 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -644,10 +644,11 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 		action = "clear info about all PVs";
 	else if (!strcmp(id, "vg_clear_outdated_pvs"))
 		action = "clear the list of outdated PVs";
-	else if (!strcmp(id, "vg_update")) {
+	else if (!strcmp(id, "set_vg_info"))
+		action = "set VG info";
+	else if (!strcmp(id, "vg_update"))
 		action = "update VG";
-		action_modifies = 1;
-	} else if (!strcmp(id, "vg_remove")) {
+	else if (!strcmp(id, "vg_remove")) {
 		action = "remove VG";
 		action_modifies = 1;
 	} else if (!strcmp(id, "pv_found")) {
@@ -1073,7 +1074,13 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			log_debug_lvmetad("Rescan VG %s because no lvmlockd lock is held", vgname);
 			rescan = 1;
 		} else if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
-			log_debug_lvmetad("Rescan VG %s because lvmetad returned invalid", vgname);
+			if (!is_lockd_type(vg->lock_type)) {
+				/* Can happen if a previous command failed/crashed without updating lvmetad. */
+				log_warn("WARNING: Reading VG %s from disk because lvmetad metadata is invalid.", vgname);
+			} else {
+				/* This is normal when the VG was modified by another host. */
+				log_debug_lvmetad("Rescan VG %s because lvmetad returned invalid", vgname);
+			}
 			rescan = 1;
 		}
 
@@ -1137,32 +1144,98 @@ static int _fixup_ignored(struct metadata_area *mda, void *baton) {
 	return 1;
 }
 
-int lvmetad_vg_update(struct volume_group *vg)
+/*
+ * After the VG is written to disk, but before it's committed,
+ * lvmetad is told the new seqno.  lvmetad sets the INVALID
+ * flag on the cached VG and saves the new seqno.
+ *
+ * After the VG is committed on disk, the command sends the
+ * new VG metadata, containing the new seqno.  lvmetad sees
+ * that it has the updated metadata and clears the INVALID
+ * flag on the cached VG.
+ *
+ * If the command fails after committing the metadata on disk
+ * but before sending the new metadata to lvmetad, then the
+ * next command that asks lvmetad for the metadata will get
+ * back the INVALID flag.  That command will then read the
+ * VG metadata from disk to use, and will send the latest
+ * metadata from disk to lvmetad which will clear the
+ * INVALID flag.
+ */
+
+int lvmetad_vg_update_pending(struct volume_group *vg)
 {
+	char uuid[64] __attribute__((aligned(8)));
+	daemon_reply reply;
+
+	if (!lvmetad_used() || test_mode())
+		return 1; /* fake it */
+
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
+	log_debug_lvmetad("Sending lvmetad pending VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
+	reply = _lvmetad_send(vg->cmd, "set_vg_info",
+			      "name = %s", vg->name,
+			      "uuid = %s", uuid,
+			      "version = %"PRId64, (int64_t)vg->seqno,
+			      NULL);
+
+	if (!_lvmetad_handle_reply(reply, "set_vg_info", vg->name, NULL)) {
+		daemon_reply_destroy(reply);
+		return_0;
+	}
+
+	vg->lvmetad_update_pending = 1;
+
+	daemon_reply_destroy(reply);
+	return 1;
+}
+
+int lvmetad_vg_update_finish(struct volume_group *vg)
+{
+	char uuid[64] __attribute__((aligned(8)));
 	daemon_reply reply;
 	struct dm_hash_node *n;
 	struct metadata_area *mda;
 	char mda_id[128], *num;
+	struct dm_config_tree *vgmeta;
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
 	struct _fixup_baton baton;
 
-	if (!vg)
-		return 0;
+	if (!vg->lvmetad_update_pending)
+		return 1;
+
+	if (!(vg->fid->fmt->features & FMT_PRECOMMIT))
+		return 1;
 
 	if (!lvmetad_used() || test_mode())
 		return 1; /* fake it */
 
-	if (!vg->cft_precommitted) {
-		log_error(INTERNAL_ERROR "VG update without precommited");
+	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
+		return_0;
+
+	if (!(vgmeta = export_vg_to_config_tree(vg))) {
+		log_error("Failed to export VG to config tree.");
 		return 0;
 	}
 
-	log_debug_lvmetad("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
-	reply = _lvmetad_send(vg->cmd, "vg_update", "vgname = %s", vg->name,
-			      "metadata = %t", vg->cft_precommitted, NULL);
+	log_debug_lvmetad("Sending lvmetad updated VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
+	reply = _lvmetad_send(vg->cmd, "vg_update",
+			      "vgname = %s", vg->name,
+			      "metadata = %t", vgmeta,
+			      NULL);
+
+	dm_config_destroy(vgmeta);
 
 	if (!_lvmetad_handle_reply(reply, "vg_update", vg->name, NULL)) {
+		/*
+		 * In this failure case, the VG cached in lvmetad remains in
+		 * the INVALID state (from lvmetad_vg_update_pending).
+		 * A subsequent command will see INVALID, ignore the cached
+		 * copy, read the VG from disk, and update the cached copy.
+		 */
 		daemon_reply_destroy(reply);
 		return 0;
 	}
@@ -1195,6 +1268,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 			return 0;
 	}
 
+	vg->lvmetad_update_pending = 0;
 	return 1;
 }
 
@@ -1207,6 +1281,8 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	if (!lvmetad_used() || test_mode())
 		return 1; /* just fake it */
 
+	vg->lvmetad_update_pending = 0;
+
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
@@ -1887,10 +1963,6 @@ scan_more:
 
 		/*
 		 * Update lvmetad with the newly read version of the VG.
-		 * The "precommitted" name is a misnomer in this case,
-		 * but that is the field which lvmetad_vg_update() uses
-		 * to send the metadata cft to lvmetad.
-		 *
 		 * When the seqno is unchanged the cached VG can be left.
 		 */
 		if (save_seqno != vg->seqno) {
@@ -1905,10 +1977,13 @@ scan_more:
 			log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
 					  vg->name, vg->seqno, save_seqno);
 
-			vg_ret->cft_precommitted = vgmeta_ret;
-			if (!lvmetad_vg_update(vg_ret))
+			/*
+			 * If this vg_update fails the cached metadata in
+			 * lvmetad will remain invalid.
+			 */
+			vg_ret->lvmetad_update_pending = 1;
+			if (!lvmetad_vg_update_finish(vg_ret))
 				log_error("Failed to update lvmetad with new VG meta");
-			vg_ret->cft_precommitted = NULL;
 		}
 		dm_config_destroy(vgmeta_ret);
 	}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 3bb2b7c..9ee4e2d 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -78,7 +78,8 @@ void lvmetad_release_token(void);
  * lvmetad_vg_commit. The request is validated immediately and lvmetad_vg_commit
  * only constitutes a pointer update.
  */
-int lvmetad_vg_update(struct volume_group *vg);
+int lvmetad_vg_update_pending(struct volume_group *vg);
+int lvmetad_vg_update_finish(struct volume_group *vg);
 
 /*
  * Inform lvmetad that a VG has been removed. This is not entirely safe, but is
@@ -171,6 +172,8 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #    define lvmetad_set_token(a)	do { } while (0)
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
+#    define lvmetad_vg_update_pending(vg)	(1)
+#    define lvmetad_vg_update_finish(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
 #    define lvmetad_pv_found(cmd, pvid, dev, fmt, label_sector, vg, found_vgnames, changed_vgnames)	(1)
 #    define lvmetad_pv_gone(devno, pv_name)	(1)
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 92799e4..2acd8f5 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -22,6 +22,7 @@
 #include "memlock.h"
 #include "toolcontext.h"
 #include "locking.h"
+#include "lvmetad-client.h"
 
 #include <unistd.h>
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index ceeb73c..18bce2d 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -198,8 +198,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	rr; \
 })
 
-#define unlock_vg(cmd, vol)	\
+#define unlock_vg(cmd, vg, vol)	\
 	do { \
+		if (vg && !lvmetad_vg_update_finish(vg)) \
+			stack; \
 		if (is_real_vg(vol) && !sync_dev_names(cmd)) \
 			stack; \
 		if (!lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL)) \
@@ -207,7 +209,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	} while (0)
 #define unlock_and_release_vg(cmd, vg, vol) \
 	do { \
-		unlock_vg(cmd, vol); \
+		unlock_vg(cmd, vg, vol); \
 		release_vg(vg); \
 	} while (0)
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e55463b..e100bc6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -629,7 +629,7 @@ int vg_remove(struct volume_group *vg)
 
 	ret = vg_remove_direct(vg);
 
-	unlock_vg(vg->cmd, VG_ORPHANS);
+	unlock_vg(vg->cmd, vg, VG_ORPHANS);
 	return ret;
 }
 
@@ -3548,6 +3548,17 @@ int vg_write(struct volume_group *vg)
 
 	lockd_vg_update(vg);
 
+	/*
+	 * This tells lvmetad the new seqno it should expect to receive
+	 * the metadata for after the commit.  The cached VG will be
+	 * invalid in lvmetad until this command sends the new metadata
+	 * after it's committed.
+	 */
+	if (!lvmetad_vg_update_pending(vg)) {
+		log_error("Failed to prepare new VG metadata in lvmetad cache.");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -3598,10 +3609,6 @@ int vg_commit(struct volume_group *vg)
 		return cache_updated;
 	}
 
-	/* Skip if we already did this in vg_write */
-	if ((vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
-		return_0;
-
 	cache_updated = _vg_commit_mdas(vg);
 
 	set_vg_notify(vg->cmd);
@@ -3641,6 +3648,14 @@ void vg_revert(struct volume_group *vg)
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 
+	/*
+	 * This will leave the cached copy in lvmetad INVALID (from
+	 * lvmetad_vg_update_pending) and means the VG will be reread from disk
+	 * to update the lvmetad copy, which is what we want to ensure that the
+	 * cached copy is correct.
+	 */
+	vg->lvmetad_update_pending = 0;
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->new_lock_args) {
 			lockd_free_lv(vg->cmd, vg, lvl->lv->name, &lvl->lv->lvid.id[1], lvl->lv->lock_args);
@@ -5465,7 +5480,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	int consistent = 1;
 	struct volume_group *vg;
 
-	unlock_vg(cmd, vg_name);
+	unlock_vg(cmd, NULL, vg_name);
 
 	dev_close_all();
 
@@ -5473,13 +5488,13 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		return_NULL;
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, WARN_PV_READ, &consistent))) {
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
 	}
 
 	if (!consistent) {
 		release_vg(vg);
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
 	}
 
@@ -5825,7 +5840,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 bad:
 	if (!already_locked)
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, vg, vg_name);
 
 bad_no_unlock:
 	return _vg_make_handle(cmd, vg, failure);
@@ -5926,7 +5941,7 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 				 * FIXME: Disallow calling this function if
 				 * critical_section() is true.
 				 */
-				unlock_vg(cmd, vgname);
+				unlock_vg(cmd, NULL, vgname);
 				return FAILED_LOCKING;
 			}
 			lvmcache_force_next_label_scan();
@@ -5939,7 +5954,7 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 	}
 
 	/* Found vgname so cannot reserve. */
-	unlock_vg(cmd, vgname);
+	unlock_vg(cmd, NULL, vgname);
 	return FAILED_EXIST;
 }
 
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 567cede..5689a11 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -854,7 +854,7 @@ int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
 	}
 
 out:
-	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 
 	if (pvslist)
 		dm_list_iterate_items(pvl, pvslist)
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 5197b63..0501713 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -17,6 +17,7 @@
 #include "metadata.h"
 #include "segtype.h"
 #include "toolcontext.h"
+#include "lvmetad.h"
 
 /* Add lv as replicator_dev device */
 int replicator_dev_add_rimage(struct replicator_device *rdev,
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 7ac1a2c..01dcad9 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -20,6 +20,7 @@
 #include "toolcontext.h"
 #include "lvmcache.h"
 #include "archiver.h"
+#include "lvmetad.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 069cdc8..4ce7151 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -51,6 +51,7 @@ struct volume_group {
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
+	unsigned lvmetad_update_pending: 1;
 
 	/*
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 4c40b8b..3dd8433 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -22,6 +22,7 @@
 #include "locking.h"
 #include "toolcontext.h"
 #include "lvm_misc.h"
+#include "lvmetad.h"
 
 struct lvm_pv_create_params
 {
@@ -205,7 +206,7 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 		dm_list_iterate_items(pvl, &to_delete->pvslist)
 			free_pv_fid(pvl->pv);
 
-		unlock_vg(to_delete->cmd, VG_GLOBAL);
+		unlock_vg(to_delete->cmd, NULL, VG_GLOBAL);
 		to_delete->magic = 0xA5A5A5A5;
 
 		restore_user_env(&e);
@@ -437,7 +438,7 @@ static int _pv_create(pv_create_params_t params)
 	if (!(pvcreate_vol(cmd, params->pv_name, &params->pv_p, 1)))
 		rc = -1;
 
-	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 	return rc;
 }
 
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 8b3fc91..8f83230 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -22,6 +22,7 @@
 #include "lvm_misc.h"
 #include "lvm2app.h"
 #include "display.h"
+#include "lvmetad.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
@@ -84,14 +85,14 @@ static int _lvm_vg_extend(vg_t vg, const char *device)
 
 	pvcreate_params_set_defaults(&pp);
 	if (!vg_extend(vg, 1, &device, &pp)) {
-		unlock_vg(vg->cmd, VG_ORPHANS);
+		unlock_vg(vg->cmd, NULL, VG_ORPHANS);
 		return -1;
 	}
 	/*
 	 * FIXME: Either commit to disk, or keep holding VG_ORPHANS and
 	 * release in lvm_vg_close().
 	 */
-	unlock_vg(vg->cmd, VG_ORPHANS);
+	unlock_vg(vg->cmd, NULL, VG_ORPHANS);
 	return 0;
 }
 
@@ -165,7 +166,7 @@ static int _lvm_vg_write(vg_t vg)
 			/* FIXME: do pvremove / label_remove()? */
 		}
 		dm_list_init(&vg->removed_pvs);
-		unlock_vg(vg->cmd, VG_ORPHANS);
+		unlock_vg(vg->cmd, NULL, VG_ORPHANS);
 	}
 
 	return 0;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index e68e181..8c19268 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -255,7 +255,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvchange_single);
 
 	if (!argc)
-		unlock_vg(cmd, VG_GLOBAL);
+		unlock_vg(cmd, NULL, VG_GLOBAL);
 
 	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s not changed",
 				params.done, params.done == 1 ? "" : "s",
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index fe6611f..e69eed4 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -156,7 +156,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		ret = ECMD_FAILED;
 	else {
 		/* pvcreate_each_device returns with orphans locked */
-		unlock_vg(cmd, VG_ORPHANS);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 		ret = ECMD_PROCESSED;
 	}
 
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 404e02b..5f033f3 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -112,7 +112,7 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 			      NULL, _pvdisplay_single);
 
 	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
+		unlock_vg(cmd, NULL, VG_GLOBAL);
 
 	return ret;
 }
diff --git a/tools/pvremove.c b/tools/pvremove.c
index e262eb0..28c7b83 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -58,7 +58,7 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 		ret = ECMD_FAILED;
 	else {
 		/* pvcreate_each_device returns with orphans locked */
-		unlock_vg(cmd, VG_ORPHANS);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 		ret = ECMD_PROCESSED;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index c29401c..f5367e4 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -536,7 +536,7 @@ out:
 
 	if (!sync_local_dev_names(cmd))
 		stack;
-	unlock_vg(cmd, VG_GLOBAL);
+	unlock_vg(cmd, NULL, VG_GLOBAL);
 	return ret;
 }
 
@@ -654,7 +654,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 					params.new_pvs_found, display_size(cmd, params.size_new));
 
 out:
-	unlock_vg(cmd, VG_GLOBAL);
+	unlock_vg(cmd, NULL, VG_GLOBAL);
 	destroy_processing_handle(cmd, handle);
 
 	return ret;
diff --git a/tools/reporter.c b/tools/reporter.c
index 6f8ed8f..ad0a356 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1171,7 +1171,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 		dm_report_output(report_handle);
 
 	if (lock_global)
-		unlock_vg(cmd, VG_GLOBAL);
+		unlock_vg(cmd, NULL, VG_GLOBAL);
 out:
 	if (report_handle) {
 		if (report_in_group && !dm_report_group_pop(handle->report_group))
diff --git a/tools/toollib.c b/tools/toollib.c
index 4c24b16..35b687b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1962,7 +1962,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		}
 
 		if (!vg_read_error(vg) && !already_locked)
-			unlock_vg(cmd, vg_name);
+			unlock_vg(cmd, vg, vg_name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -2826,7 +2826,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			ret_max = ret;
 
 		if (!already_locked)
-			unlock_vg(cmd, vg_name);
+			unlock_vg(cmd, vg, vg_name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -3501,7 +3501,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			ret_max = ret;
 
 		if (!skip && !already_locked)
-			unlock_vg(cmd, vg->name);
+			unlock_vg(cmd, vg, vg->name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -4654,7 +4654,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * the questions, reacquire the orphans lock, verify that the PVs were
 	 * not used during the questions, then do the create steps.
 	 */
-	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 
 	/*
 	 * Process prompts that require asking the user.  The orphans lock is
@@ -4941,7 +4941,7 @@ do_command:
 	return 1;
 
 bad:
-	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 out:
 	return 0;
 }
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 8a60ab3..b5a2add 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -70,7 +70,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock orphans");
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, NULL, vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -81,8 +81,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 				       arg_str_value(cmd, file_ARG, ""),
 				       arg_count(cmd, force_long_ARG)) :
 	      backup_restore(cmd, vg_name, arg_count(cmd, force_long_ARG)))) {
-		unlock_vg(cmd, VG_ORPHANS);
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
+		unlock_vg(cmd, NULL, vg_name);
 		log_error("Restore failed.");
 		ret = ECMD_FAILED;
 		goto rescan;
@@ -91,8 +91,8 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	ret = ECMD_PROCESSED;
 	log_print_unless_silent("Restored volume group %s", vg_name);
 
-	unlock_vg(cmd, VG_ORPHANS);
-	unlock_vg(cmd, vg_name);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
+	unlock_vg(cmd, NULL, vg_name);
 rescan:
 	if (lvmetad_rescan) {
 		if (!lvmetad_connect(cmd)) {
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 14e0d53..1a6a240 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -90,7 +90,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * VG lock to be released, so the lvmcache destroy rule about locks
 	 * seems to be unwarranted here.
 	 */
-	unlock_vg(cmd, vp_new.vg_name);
+	unlock_vg(cmd, NULL, vp_new.vg_name);
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
@@ -181,8 +181,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 	}
 
-	unlock_vg(cmd, VG_ORPHANS);
-	unlock_vg(cmd, vp_new.vg_name);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
+	unlock_vg(cmd, vg, vp_new.vg_name);
 
 	backup(vg);
 
@@ -222,8 +222,8 @@ out:
 	return ECMD_PROCESSED;
 
 bad:
-	unlock_vg(cmd, vp_new.vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, vg, vp_new.vg_name);
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 	release_vg(vg);
 	destroy_processing_handle(cmd, handle);
 	return ECMD_FAILED;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 4b2a13e..344dff0 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -204,6 +204,6 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	destroy_processing_handle(cmd, handle);
 
 	if (!restoremissing)
-		unlock_vg(cmd, VG_ORPHANS);
+		unlock_vg(cmd, NULL, VG_ORPHANS);
 	return ret;
 }
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 7028fbb..09b3a7c 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -333,9 +333,9 @@ retry_name:
 
 	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, 0, handle, _vgimportclone_vg_single);
 
-	unlock_vg(cmd, vp.new_vgname);
+	unlock_vg(cmd, NULL, vp.new_vgname);
 out:
-	unlock_vg(cmd, VG_GLOBAL);
+	unlock_vg(cmd, NULL, VG_GLOBAL);
 	internal_filter_clear();
 	init_internal_filtering(0);
 	lvmcache_lock_ordering(1);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 2006193..293f63c 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -161,7 +161,7 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	if (!backup_remove(cmd, vg_name))
 		stack;
 
-	unlock_vg(cmd, vp->vg_name_new);
+	unlock_vg(cmd, vg, vp->vg_name_new);
 	vp->unlock_new_name = 0;
 
 	log_print_unless_silent("Volume group \"%s\" successfully renamed to \"%s\"",
@@ -169,7 +169,7 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	return 1;
 
  error:
-	unlock_vg(cmd, vp->vg_name_new);
+	unlock_vg(cmd, vg, vp->vg_name_new);
 	vp->unlock_new_name = 0;
 
 	lockd_rename_vg_final(cmd, vg, 0);
@@ -250,7 +250,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Needed if process_each_vg returns error before calling _single. */
 	if (vp.unlock_new_name)
-		unlock_vg(cmd, vg_name_new);
+		unlock_vg(cmd, NULL, vg_name_new);
 
 	destroy_processing_handle(cmd, handle);
 	return ret;
diff --git a/tools/vgscan.c b/tools/vgscan.c
index e09724a..4deab73 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -125,6 +125,6 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 			maxret = ret;
 	}
 
-	unlock_vg(cmd, VG_GLOBAL);
+	unlock_vg(cmd, NULL, VG_GLOBAL);
 	return maxret;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index cb6b0ef..6114a72 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -653,6 +653,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
 		goto_bad;
 
+	lvmetad_vg_update_finish(vg_to);
+
 	backup(vg_to);
 
 	/*
@@ -664,6 +666,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		if (!vg_write(vg_from) || !vg_commit(vg_from))
 			goto_bad;
 
+		lvmetad_vg_update_finish(vg_from);
+
 		backup(vg_from);
 	}
 
@@ -686,6 +690,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
 		goto_bad;
 
+	lvmetad_vg_update_finish(vg_to);
+
 	backup(vg_to);
 
 	log_print_unless_silent("%s volume group \"%s\" successfully split from \"%s\"",


