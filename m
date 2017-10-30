From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 06:55:26 -0400
Subject: master - thin: fix merging messages
Message-ID: <201710301055.v9UAtQ8D020855@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af21263cb39bb850d5bf437fe0371e173b8c0246
Commit:        af21263cb39bb850d5bf437fe0371e173b8c0246
Parent:        90ee7783b4c2b1b13122e6107cebeb28ca30326d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 11:00:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 11:53:39 2017 +0100

thin: fix merging messages

Correct reported message when thin snapshot has been already merged.
So lvm2 is no longer reporting "Mergins of snapshot X will occur..."
(even with swapped names).
---
 WHATS_NEW                |    1 +
 test/shell/thin-merge.sh |    6 ++++--
 tools/lvconvert.c        |   24 +++++++++++-------------
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 961c7e5..e8e6bb0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Fix printed message when thin snapshot was already merged.
   Remove created spare LV when creation of thin-pool failed.
   Avoid reading ignored metadata when mda gets used again.
   Fix detection of moved PVs in vgsplit. (2.02.175)
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 7baaa55..1841bf7 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -45,7 +45,8 @@ touch mntsnap/test_snap
 
 lvs -o+tags,thin_id $vg
 
-lvconvert --merge $vg/snap
+lvconvert --merge $vg/snap &>out
+grep "Merging of thin snapshot $vg/snap will occur on next activation of $vg/${lv1}." out
 
 umount mnt
 
@@ -115,7 +116,8 @@ check lv_field  $vg/$lv1 thin_id "3"
 # Check --mergethin
 lvcreate -s -n snap $vg/$lv1
 check lv_field  $vg/snap thin_id "4"
-lvconvert --mergethin $vg/snap
+lvconvert --mergethin $vg/snap  &>out
+grep "Volume $vg/snap replaced origin $vg/${lv1}." out
 check lv_field  $vg/$lv1 thin_id "4"
 
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76be5cb..3a025c7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2098,7 +2098,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 					  struct logical_volume *lv)
 {
-	int origin_is_active = 0, r = 0;
+	int origin_is_active = 0;
 	struct lv_segment *snap_seg = first_seg(lv);
 	struct logical_volume *origin = snap_seg->origin;
 
@@ -2151,16 +2151,18 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 		 * replace the origin LV with its snapshot LV.
 		 */
 		if (!thin_merge_finish(cmd, origin, lv))
-			goto_out;
+			return_0;
+
+		log_print_unless_silent("Volume %s replaced origin %s.",
+					display_lvname(origin), display_lvname(lv));
 
 		if (origin_is_active && !activate_lv(cmd, lv)) {
 			log_error("Failed to reactivate origin %s.",
 				  display_lvname(lv));
-			goto out;
+			return 0;
 		}
 
-		r = 1;
-		goto out;
+		return 1;
 	}
 
 	init_snapshot_merge(snap_seg, origin);
@@ -2169,16 +2171,12 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
-	r = 1;
-out:
+	log_print_unless_silent("Merging of thin snapshot %s will occur on "
+				"next activation of %s.",
+				display_lvname(lv), display_lvname(origin));
 	backup(lv->vg);
 
-	if (r)
-		log_print_unless_silent("Merging of thin snapshot %s will occur on "
-					"next activation of %s.",
-					display_lvname(lv), display_lvname(origin));
-
-	return r;
+	return 1;
 }
 
 static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,


