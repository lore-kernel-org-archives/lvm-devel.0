From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:32 -0500
Subject: master - debug: enhance messages
Message-ID: <66734.119121009463000523@us-mta-354.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5555765cfc71a87eadcb1f6ac9bdd41f2e3c9052
Commit:        5555765cfc71a87eadcb1f6ac9bdd41f2e3c9052
Parent:        cff16b062badbc65661940b021c06d3b1c423562
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 13:19:44 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

debug: enhance messages

Drop 'extra' stack trace where errors are already logged from function.
Add some missing dots in messages.
---
 lib/metadata/metadata.c |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1371b97..5856a92 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4905,7 +4905,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	if (found_old_metadata)
-		log_warn("WARNING: Inconsistent metadata found for VG %s", vgname);
+		log_warn("WARNING: Inconsistent metadata found for VG %s.", vgname);
 
 	vg = NULL;
 
@@ -4936,13 +4936,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (!(dev->flags & DEV_IS_MD_COMPONENT))
 				continue;
 
-			log_debug_metadata("Drop dev for MD component from cache %s", dev_name(dev));
+			log_debug_metadata("Drop dev for MD component from cache %s.", dev_name(dev));
 			lvmcache_del_dev(dev);
 
 			dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 				if (mda_get_device(mda) != dev)
 					continue;
-				log_debug_metadata("Drop mda from MD component from mda list %s", dev_name(dev));
+				log_debug_metadata("Drop mda from MD component from mda list %s.", dev_name(dev));
 				dm_list_del(&mda->list);
 				break;
 			}
@@ -5010,7 +5010,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	int activating = (vg_read_flags & READ_FOR_ACTIVATE);
 
 	if (is_orphan_vg(vg_name)) {
-		log_very_verbose("Reading orphan VG %s", vg_name);
+		log_very_verbose("Reading orphan VG %s.", vg_name);
 		vg = vg_read_orphans(cmd, vg_name);
 		*error_flags = 0;
 		*error_vg = NULL;
@@ -5020,7 +5020,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	if (!validate_name(vg_name)) {
 		log_error("Volume group name \"%s\" has invalid characters.", vg_name);
 		failure |= FAILED_NOTFOUND;
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -5035,15 +5035,15 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 
 	if (!(vg_read_flags & READ_WITHOUT_LOCK) &&
 	    !lock_vol(cmd, vg_name, (writing || activating) ? LCK_VG_WRITE : LCK_VG_READ, NULL)) {
-		log_error("Can't get lock for %s", vg_name);
+		log_error("Can't get lock for %s.", vg_name);
 		failure |= FAILED_LOCKING;
-		goto_bad;
+		goto bad;
 	}
 
 	if (!(vg = _vg_read(cmd, vg_name, vgid, 0, writing))) {
 		/* Some callers don't care if the VG doesn't exist and don't want an error message. */
 		if (!(vg_read_flags & READ_OK_NOTFOUND))
-			log_error("Volume group \"%s\" not found", vg_name);
+			log_error("Volume group \"%s\" not found.", vg_name);
 		failure |= FAILED_NOTFOUND;
 		goto_bad;
 	}
@@ -5114,14 +5114,14 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.", vg->name);
 		failure |= FAILED_INTERNAL_ERROR;
-		goto_bad;
+		goto bad;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!check_lv_segments(lvl->lv, 0)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.", lvl->lv->name);
 			failure |= FAILED_INTERNAL_ERROR;
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -5130,7 +5130,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.", lvl->lv->name);
 			failure |= FAILED_INTERNAL_ERROR;
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -5166,23 +5166,23 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	 */
 	if (writing || activating) {
 		if (!(vg->status & LVM_WRITE)) {
-			log_error("Volume group %s is read-only", vg->name);
+			log_error("Volume group %s is read-only.", vg->name);
 			failure |= FAILED_READ_ONLY;
-			goto_bad;
+			goto bad;
 		}
 
 		if (!cmd->handles_missing_pvs && (missing_pv_dev || missing_pv_flag)) {
 			log_error("Cannot change VG %s while PVs are missing.", vg->name);
 			log_error("See vgreduce --removemissing and vgextend --restoremissing.");
 			failure |= FAILED_NOT_ENABLED;
-			goto_bad;
+			goto bad;
 		}
 	}
 
 	if (writing && !cmd->handles_unknown_segments && vg_has_unknown_segments(vg)) {
 		log_error("Cannot change VG %s with unknown segments in it!", vg->name);
 		failure |= FAILED_NOT_ENABLED; /* FIXME new failure code here? */
-		goto_bad;
+		goto bad;
 	}
 
 	/*
@@ -5197,31 +5197,31 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 
 		if (dm_pool_locked(vg->vgmem)) {
 			/* FIXME: can this happen? */
-			log_warn("WARNING: vg_read no vg copy: pool locked");
+			log_warn("WARNING: vg_read no vg copy: pool locked.");
 			goto out;
 		}
 
 		if (vg->vg_committed) {
 			/* FIXME: can this happen? */
-			log_warn("WARNING: vg_read no vg copy: copy exists");
+			log_warn("WARNING: vg_read no vg copy: copy exists.");
 			release_vg(vg->vg_committed);
 			vg->vg_committed = NULL;
 		}
 
 		if (vg->vg_precommitted) {
 			/* FIXME: can this happen? */
-			log_warn("WARNING: vg_read no vg copy: pre copy exists");
+			log_warn("WARNING: vg_read no vg copy: pre copy exists.");
 			release_vg(vg->vg_precommitted);
 			vg->vg_precommitted = NULL;
 		}
 
 		if (!(cft = export_vg_to_config_tree(vg))) {
-			log_warn("WARNING: vg_read no vg copy: copy export failed");
+			log_warn("WARNING: vg_read no vg copy: copy export failed.");
 			goto out;
 		}
 
 		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, cft)))
-			log_warn("WARNING: vg_read no vg copy: copy import failed");
+			log_warn("WARNING: vg_read no vg copy: copy import failed.");
 
 		dm_config_destroy(cft);
 	} else {



