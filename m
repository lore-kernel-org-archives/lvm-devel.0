From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 5 Dec 2017 12:48:41 -0500
Subject: master - deactivate_lvs: deactivate any missing RaidLV legs
Message-ID: <201712051748.vB5HmfOH019439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94632eb155a0a1814e69b1baa0516323cbbae648
Commit:        94632eb155a0a1814e69b1baa0516323cbbae648
Parent:        7195df5acace29e77add6aa2f3df9c684e44694a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Dec 5 18:48:06 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Dec 5 18:48:06 2017 +0100

deactivate_lvs: deactivate any missing RaidLV legs

In case of failed legs, raid replaces those with
e.g. "vg-lv_rimage_0-missing_0_0" mapped to an error target.

Those errouneously remain on deactivation.

Fix by removing them on deactivation/removal of the RaidLV.
---
 lib/activate/activate.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e7653a2..4c69af7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2506,6 +2506,16 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	critical_section_inc(cmd, "deactivating");
 	r = _lv_deactivate(lv);
+
+	/*
+	 * Remove any transiently activated error
+	 * devices which arean't used any more.
+	 */
+	if (r && lv_is_raid(lv) && !lv_deactivate_any_missing_subdevs(lv)) {
+		log_error("Failed to remove temporary SubLVs from %s",
+			  display_lvname(lv));
+		r = 0;
+	}
 	critical_section_dec(cmd, "deactivated");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists) {
@@ -2735,10 +2745,8 @@ static int _lv_remove_any_missing_subdevs(struct logical_volume *lv)
 		struct lv_segment *seg;
 
 		dm_list_iterate_items(seg, &lv->segments) {
-			if (seg->area_count != 1)
-				return_0;
 			if (dm_snprintf(name, sizeof(name), "%s-%s-missing_%u_0", seg->lv->vg->name, seg->lv->name, seg_no) < 0)
-				return 0;
+				return_0;
 			if (!_remove_dm_dev_by_name(name))
 				return 0;
 


