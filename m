From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Feb 2016 09:32:47 +0000 (UTC)
Subject: master - metadata: do not repair missing PV_EXT_USED flag for PVs belonging to foreign VG
Message-ID: <20160217093247.1340360B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b077e7374f6bcb4ad5d8d9247553301ce75fa38e
Commit:        b077e7374f6bcb4ad5d8d9247553301ce75fa38e
Parent:        13f3e926326ae528d1a62d9786f462e7d7c73037
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 16 13:55:31 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 17 10:19:24 2016 +0100

metadata: do not repair missing PV_EXT_USED flag for PVs belonging to foreign VG

The host that owns foreign VGs is responsible for fixing up PV_EXT_USED
flag - the same already applies to repairing any inconsistent VG.

This patch also moves the iteration over vg->pvs inside
_check_or_repair_pv_ext fn - it's cleaner this way.
---
 lib/metadata/metadata.c |  109 +++++++++++++++++++++++++----------------------
 1 files changed, 58 insertions(+), 51 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4dbe38b..3b59e65 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3632,52 +3632,6 @@ static int _is_foreign_vg(struct volume_group *vg)
 	return vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id);
 }
 
-static int _check_or_repair_pv_ext(struct cmd_context *cmd,
-				   struct physical_volume *pv,
-				   int repair, int *inconsistent_pvs)
-{
-	struct lvmcache_info *info;
-	uint32_t ext_version, ext_flags;
-
-	/* Missing PV - nothing to do. */
-	if (!pv->dev)
-		return 1;
-
-	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
-		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
-		return 0;
-	}
-
-	ext_version = lvmcache_ext_version(info);
-	if (ext_version < 2) {
-		*inconsistent_pvs = 0;
-		return 1;
-	}
-
-	ext_flags = lvmcache_ext_flags(info);
-	if (!(ext_flags & PV_EXT_USED)) {
-		if (!repair) {
-			*inconsistent_pvs = 1;
-			return 1;
-		}
-
-		log_warn("WARNING: Repairing Physical Volume %s that is "
-			 "in Volume Group %s but not marked as used.",
-			  pv_dev_name(pv), pv->vg->name);
-
-		/* pv write will set correct ext_flags */
-		if (!pv_write(cmd, pv, 1)) {
-			*inconsistent_pvs = 1;
-			log_error("Failed to repair physical volume \"%s\".",
-				  pv_dev_name(pv));
-			return 0;
-		}
-	}
-
-	*inconsistent_pvs = 0;
-	return 1;
-}
-
 static int _repair_inconsistent_vg(struct volume_group *vg)
 {
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
@@ -3762,6 +3716,61 @@ next_pv:
 	return 1;
 }
 
+static int _check_or_repair_pv_ext(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   int repair, int *inconsistent_pvs)
+{
+	struct lvmcache_info *info;
+	uint32_t ext_version, ext_flags;
+	struct pv_list *pvl;
+
+	*inconsistent_pvs = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		/* Missing PV - nothing to do. */
+		if (is_missing_pv(pvl->pv))
+			continue;
+
+		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 0))) {
+			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
+			return 0;
+		}
+
+		ext_version = lvmcache_ext_version(info);
+		if (ext_version < 2)
+			continue;
+
+		ext_flags = lvmcache_ext_flags(info);
+		if (!(ext_flags & PV_EXT_USED)) {
+			if (!repair) {
+				*inconsistent_pvs = 1;
+				continue;
+			}
+
+			if (_is_foreign_vg(vg)) {
+				log_verbose("Skip repair of PV %s that is in foreign "
+					    "VG %s but not marked as used.",
+					    pv_dev_name(pvl->pv), vg->name);
+				*inconsistent_pvs = 1;
+			} else {
+				log_warn("WARNING: Repairing Physical Volume %s that is "
+					 "in Volume Group %s but not marked as used.",
+					  pv_dev_name(pvl->pv), vg->name);
+
+				/* pv write will set correct ext_flags */
+				if (!pv_write(cmd, pvl->pv, 1)) {
+					*inconsistent_pvs = 1;
+					log_error("Failed to repair physical volume \"%s\".",
+						  pv_dev_name(pvl->pv));
+					return 0;
+				}
+			}
+		}
+	}
+
+	return 1;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -4260,11 +4269,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	dm_list_iterate_items(pvl, &correct_vg->pvs) {
-		if (!_check_or_repair_pv_ext(cmd, pvl->pv, *consistent, &inconsistent_pvs)) {
-			release_vg(correct_vg);
-			return_NULL;
-		}
+	if (!_check_or_repair_pv_ext(cmd, correct_vg, *consistent, &inconsistent_pvs)) {
+		release_vg(correct_vg);
+		return_NULL;
 	}
 
 	*consistent = !inconsistent_pvs;


