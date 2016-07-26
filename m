From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Jul 2016 14:23:19 +0000 (UTC)
Subject: master - metadata: fix automatic updates of PV extension headers to newest version
Message-ID: <20160726142319.2CE00609D2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=070c0d31ab3847240081e7593f959b03e716923d
Commit:        070c0d31ab3847240081e7593f959b03e716923d
Parent:        f9697ea0067ef574aff09f1c8f25e1c7fab74c17
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 26 15:46:36 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 26 16:22:55 2016 +0200

metadata: fix automatic updates of PV extension headers to newest version

Before, the automatic update from older to newer version of PV extension
header happened within vg_write call. This may have caused problems under
some circumnstances where there's a code in between vg_write and vg_commit
which may have failed. In such situation, we reverted precommitted metadata
and put back the state to working version of VG metadata.

However, we don't have revert for PV write operation at the moment. So
if we updated PV headers already and we reverted vg_write due to failure
in subsequent code (before vg_commit), we ended up with lost VG metadata
(because old metadata pointers got reset by the PV write operation).

To minimize problematic situations here, we should put vg_write and
vg_commit that is done after PV header rewrites as close to each
other as possible.

This patch moves the automatic PV header rewrite for new extension
header part from vg_write to _vg_read where it's done the same way
as we do any other VG repairs if detected during VG read operation
(under VG write lock).
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   43 +++++++++++++++++++++++++++++++++----------
 2 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c96b5be..4f24476 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Fix automatic updates of PV extension headers to newest version.
   Improve lvconvert --trackchanges validation to require --splitmirrors 1.
   Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8a9a1b2..a32649f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3297,7 +3297,7 @@ static int _pv_in_pv_list(struct physical_volume *pv, struct dm_list *head)
  * Check if any of the PVs in VG still contain old PV headers
  * and if yes, schedule them for PV header update.
  */
-static int _check_old_pv_ext_for_vg(struct volume_group *vg)
+static int _vg_update_old_pv_ext_if_needed(struct volume_group *vg)
 {
 	struct pv_list *pvl, *new_pvl;
 	int pv_needs_rewrite;
@@ -3330,9 +3330,17 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 			}
 			new_pvl->pv = pvl->pv;
 			dm_list_add(&vg->pv_write_list, &new_pvl->list);
+			log_debug("PV %s has old extension header, updating to newest version.",
+				  pv_dev_name(pvl->pv));
 		}
 	}
 
+	if (!dm_list_empty(&vg->pv_write_list) &&
+	    (!vg_write(vg) || !vg_commit(vg))) {
+		log_error("Failed to update old PV extension headers in VG %s.", vg->name);
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -3463,11 +3471,6 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
-	if (!(_check_old_pv_ext_for_vg(vg))) {
-		log_error("Failed to schedule physical volume header update.");
-		return 0;
-	}
-
 	if (!drop_cached_metadata(vg)) {
 		log_error("Unable to drop cached metadata for VG %s.", vg->name);
 		return 0;
@@ -4139,6 +4142,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
 	int strip_historical_lvs = *consistent;
+	int update_old_pv_ext = *consistent;
 	unsigned use_precommitted = precommitted;
 	struct dm_list *pvids;
 	struct pv_list *pvl;
@@ -4175,8 +4179,18 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
                         }
 		}
 
-		if (correct_vg && strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg))
-			return_NULL;
+
+		if (correct_vg) {
+			if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
+				release_vg(correct_vg);
+				return_NULL;
+			}
+
+			if (strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg)) {
+				release_vg(correct_vg);
+				return_NULL;
+			}
+		}
 
 		return correct_vg;
 	}
@@ -4616,8 +4630,17 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	*consistent = !inconsistent_pvs;
 
-	if (*consistent && correct_vg && strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg))
-		return_NULL;
+	if (correct_vg && *consistent) {
+		if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
+			release_vg(correct_vg);
+			return_NULL;
+		}
+
+		if (strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg)) {
+			release_vg(correct_vg);
+			return_NULL;
+		}
+	}
 
 	return correct_vg;
 }


