From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:38 +0000 (UTC)
Subject: master - metadata: _vg_read: check if PV_EXT_USED flag is set correctly for orphan PVs and do a repair if needed
Message-ID: <20160215120838.4055A60509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d97f1c89deb9a75452059cd62ebb20cf7d2d6bfa
Commit:        d97f1c89deb9a75452059cd62ebb20cf7d2d6bfa
Parent:        3436d5b79116d067e8f20d5365ae0dae6bd19dc8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 11 16:18:42 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: _vg_read: check if PV_EXT_USED flag is set correctly for orphan PVs and do a repair if needed

If we know that the PV is orphan, meaning there's at least one MDA on
that PV which does not reference any VG and at the same time there's
PV_EXT_USED flag set, we're certainly in an inconsistent state and we
need to fix this.

For example, such situation can happen during vgremove/vgreduce if we
removed/reduced the VG, but we haven't written PV headers yet because
vgremove stopped abruptly for whatever reason just before writing new
PV headers with updated state, including PV extension flags (and so the
PV_EXT_USED flag).

However, in case the PV has no MDAs at all, we can't double-check
whether the PV_EXT_USED is correct or not - if that PV is marked
as used, it's either:
  - really used (but other disks with MDAs are missing)
  - or the error state as described above is hit

User needs to overwrite the PV header directly if it's really clear
the PV having no MDAs does not belong to any VG and at the same time
it's still marked as being in use (pvcreate -ff <dev_name> will fix this).

For example - /dev/sda here has 1 MDA, orphan and is incorrectly marked
with PV_EXT_USED flag:

$ pvs --binary -o+pv_in_use
  WARNING: Found inconsistent standalone Physical Volumes.
  WARNING: Repairing flag incorrectly marking Physical Volume /dev/sda as used.
  PV         VG     Fmt  Attr PSize   PFree   InUse
  /dev/sda          lvm2 ---  128.00m 128.00m     0
---
 lib/metadata/metadata.c |   92 +++++++++++++++++++++++++++++++++++++++--------
 tools/toollib.c         |    5 ++-
 2 files changed, 81 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7af545a..61084bc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3328,11 +3328,64 @@ void vg_revert(struct volume_group *vg)
 		stack; // FIXME: What should we do?
 }
 
+static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
+{
+	int *in_use = _in_use;
+	if (!mda_is_ignored(mda))
+		*in_use = 1;
+	return 1;
+}
+
 struct _vg_read_orphan_baton {
+	struct cmd_context *cmd;
 	struct volume_group *vg;
 	uint32_t warn_flags;
+	int consistent;
+	int repair;
 };
 
+static int _check_or_repair_orphan_pv_ext(struct physical_volume *pv,
+					  struct lvmcache_info *info,
+					  struct _vg_read_orphan_baton *b)
+{
+	uint32_t ext_flags = lvmcache_ext_flags(info);
+	int at_least_one_mda_used;
+
+	if (ext_flags & PV_EXT_USED) {
+		if (lvmcache_mda_count(info)) {
+			at_least_one_mda_used = 0;
+			lvmcache_foreach_mda(info, _check_mda_in_use, &at_least_one_mda_used);
+
+			/*
+			 * We've found a PV that is marked as used with PV_EXT_USED flag
+			 * and it's orphan at the same time while it contains MDAs.
+			 * This is incorrect state and it needs to be fixed.
+			 * The PV_EXT_USED flag needs to be dropped!
+			 */
+			if (b->repair) {
+				if (at_least_one_mda_used) {
+					log_warn("WARNING: Repairing flag incorrectly marking "
+						 "Physical Volume %s as used.", pv_dev_name(pv));
+
+					/* pv_write will set correct ext_flags */
+					if (!pv_write(b->cmd, pv, 0)) {
+						b->consistent = 0;
+						log_error("Failed to repair physical volume \"%s\".",
+							  pv_dev_name(pv));
+						return 0;
+					}
+				}
+				b->consistent = 1;
+			} else if (at_least_one_mda_used) {
+				/* mark as inconsistent only if there's at least 1 MDA used */
+				b->consistent = 0;
+			}
+		}
+	}
+
+	return 1;
+}
+
 static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 {
 	struct _vg_read_orphan_baton *b = baton;
@@ -3352,13 +3405,20 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	}
 	pvl->pv = pv;
 	add_pvl_to_vgs(b->vg, pvl);
+
+	if (!_check_or_repair_orphan_pv_ext(pv, info, baton)) {
+		stack;
+		return 0;
+	}
+
 	return 1;
 }
 
 /* Make orphan PVs look like a VG. */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 					     uint32_t warn_flags,
-					     const char *orphan_vgname)
+					     const char *orphan_vgname,
+					     int *consistent)
 {
 	const struct format_type *fmt;
 	struct lvmcache_vginfo *vginfo;
@@ -3390,8 +3450,11 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	vg->extent_count = 0;
 	vg->free_count = 0;
 
+	baton.cmd = cmd;
 	baton.warn_flags = warn_flags;
 	baton.vg = vg;
+	baton.consistent = 1;
+	baton.repair = *consistent;
 
 	while ((pvl = (struct pv_list *) dm_list_first(&head.list))) {
 		dm_list_del(&pvl->list);
@@ -3403,6 +3466,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	if (!lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton))
 		return_NULL;
 
+	*consistent = baton.consistent;
 	return vg;
 }
 
@@ -3526,14 +3590,6 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 	return 1;
 }
 
-static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
-{
-	int *in_use = _in_use;
-	if (!mda_is_ignored(mda))
-		*in_use = 1;
-	return 1;
-}
-
 static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg, struct dm_list *to_check)
 {
 	struct pv_list *pvl, *pvl2;
@@ -3631,8 +3687,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				  "with pre-commit.");
 			return NULL;
 		}
-		*consistent = 1;
-		return _vg_read_orphans(cmd, warn_flags, vgname);
+		return _vg_read_orphans(cmd, warn_flags, vgname, consistent);
 	}
 
 	if (lvmetad_active() && !use_precommitted) {
@@ -4131,8 +4186,12 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	}
 
 out:
-	if (!*consistent && (warn_flags & WARN_INCONSISTENT))
-		log_warn("WARNING: Volume Group %s is not consistent.", vgname);
+	if (!*consistent && (warn_flags & WARN_INCONSISTENT)) {
+		if (is_orphan_vg(vgname))
+			log_warn("WARNING: Found inconsistent standalone Physical Volumes.");
+		else
+			log_warn("WARNING: Volume Group %s is not consistent.", vgname);
+	}
 
 	return vg;
 }
@@ -5126,8 +5185,11 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	if (!consistent && !failure) {
 		release_vg(vg);
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
-			log_error("Recovery of volume group \"%s\" failed.",
-				  vg_name);
+			if (is_orphan_vg(vg_name))
+				log_error("Recovery of standalone physical volumes failed.");
+			else
+				log_error("Recovery of volume group \"%s\" failed.",
+					  vg_name);
 			failure |= FAILED_RECOVERY;
 			goto bad_no_unlock;
 		}
diff --git a/tools/toollib.c b/tools/toollib.c
index f9ac259..7f8c2eb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -258,7 +258,10 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 
 	if (read_error != SUCCESS) {
 		*skip = 0;
-		log_error("Cannot process volume group %s", vg_name);
+		if (is_orphan_vg(vg_name))
+			log_error("Cannot process standalone physical volumes");
+		else
+			log_error("Cannot process volume group %s", vg_name);
 		return 1;
 	}
 


