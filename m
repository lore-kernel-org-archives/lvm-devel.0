From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 14:36:44 +0000 (UTC)
Subject: master - lvmlockd: skip unnecessary lvmetad cache update
Message-ID: <20160419143644.C9A0461BBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a400eba1740c335ed715c67b978dd0ed8228d73a
Commit:        a400eba1740c335ed715c67b978dd0ed8228d73a
Parent:        50633039bfb5ef9a89e419ca7ad7ad49304d1c0d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 14 13:45:10 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:19:32 2016 -0500

lvmlockd: skip unnecessary lvmetad cache update

In cases where a VG is reread from disk, but the
seqno matches what is currently in lvmetad, the
metadata in lvmetad doesn't need to be updated.
---
 lib/cache/lvmetad.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7ca5d4a..a680441 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -872,7 +872,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	} else {
 		log_error(INTERNAL_ERROR "VG name required (VGID not available)");
-		goto out;
+		return NULL;
 	}
 
 	if (_lvmetad_handle_reply(reply, "vg_lookup", diag_name, &found) && found) {
@@ -958,16 +958,14 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		 * invalidated the cached vg.
 		 */
 		if (rescan) {
-			log_debug_lvmetad("Update invalid lvmetad cache for VG %s", vgname);
-			vg2 = lvmetad_pvscan_vg(cmd, vg);
-			release_vg(vg);
-			vg = vg2;
-			if (!vg) {
+			if (!(vg2 = lvmetad_pvscan_vg(cmd, vg))) {
 				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
 				fid = NULL;
 				goto out;
-			} else
-				fid = vg->fid;
+			}
+			release_vg(vg);
+			vg = vg2;
+			fid = vg2->fid;
 		}
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
@@ -1575,6 +1573,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 	struct format_instance_ctx fic = { .type = 0 };
 	struct _lvmetad_pvscan_baton baton;
 	struct device *save_dev = NULL;
+	uint32_t save_seqno = 0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		/* missing pv */
@@ -1622,6 +1621,9 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			continue;
 		}
 
+		if (!save_seqno)
+			save_seqno = baton.vg->seqno;
+
 		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {
 			log_error("VG export to config tree failed");
 			release_vg(baton.vg);
@@ -1661,10 +1663,14 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		 * but that is the field which lvmetad_vg_update() uses
 		 * to send the metadata cft to lvmetad.
 		 */
-		vg_ret->cft_precommitted = vgmeta_ret;
-		if (!lvmetad_vg_update(vg_ret))
-			log_error("Failed to update lvmetad with new VG meta");
-		vg_ret->cft_precommitted = NULL;
+		if (save_seqno != vg->seqno) {
+			log_debug_lvmetad("Update lvmetad from seqno %u to seqno %u for VG %s",
+					  vg->seqno, save_seqno, vg->name);
+			vg_ret->cft_precommitted = vgmeta_ret;
+			if (!lvmetad_vg_update(vg_ret))
+				log_error("Failed to update lvmetad with new VG meta");
+			vg_ret->cft_precommitted = NULL;
+		}
 		dm_config_destroy(vgmeta_ret);
 	}
 out:


