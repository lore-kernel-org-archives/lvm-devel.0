From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  7 Aug 2014 13:33:48 +0000 (UTC)
Subject: master - pvmove: remove spurious "Skipping mirror LV" message on pvmove of clustered mirror
Message-ID: <20140807133348.7BDBE6017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea662ca06065d1e3d44814b54cf8501c9bb9594f
Commit:        ea662ca06065d1e3d44814b54cf8501c9bb9594f
Parent:        26885ea119891294961939f8e3f73eee8163ad08
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 7 15:23:58 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 7 15:23:58 2014 +0200

pvmove: remove spurious "Skipping mirror LV" message on pvmove of clustered mirror

With cmirrord, we can do pvmove of clustered mirror. The code checking
suitability of LVs on the PV being moved issued a message if a mirror
LV was found and the VG was clustered. However, the actual pvmove did
work correctly.

The top-level mirror LV is actually skipped in the code since it's
always layered on top of internal LVs making up the mirror LV and for pvmove
we consider these internal devices only as they're actually layered on
top of concrete PVs then. But we don't need to issue any message here
about skipping the top-level mirror LV - it's misleading here.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   22 ++++++++++------------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index afefd6e..028758e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Remove spurious "Skipping mirror LV" message on pvmove of clustered mirror.
 
 Version 2.02.109 - 5th August 2014
 ==================================
diff --git a/tools/pvmove.c b/tools/pvmove.c
index c4c590b..3448af4 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -319,12 +319,15 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 
 		/*
-		 * RAID, thin, mirror, and snapshot-related LVs are not
-		 * processed in a cluster, so we don't have to worry about
-		 * avoiding certain PVs in that context.
+		 * RAID, thin and snapshot-related LVs are not
+		 * processed in a cluster, so we don't have to
+		 * worry about avoiding certain PVs in that context.
 		 */
-		if (vg_is_clustered(lv->vg))
-			continue;
+		if (vg_is_clustered(lv->vg)) {
+			/* Allow clustered mirror, but not raid mirror. */
+			if (!lv_is_mirror_type(lv) || lv_is_raid(lv))
+				continue;
+		}
 
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;
@@ -391,8 +394,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		 */
 		if (vg_is_clustered(vg) &&
 		    (lv_is_origin(lv) || lv_is_cow(lv) ||
-		     lv_is_thin_type(lv) || lv_is_raid_type(lv) ||
-		     lv_is_mirrored(lv))) {
+		     lv_is_thin_type(lv) || lv_is_raid_type(lv))) {
 			log_print_unless_silent("Skipping %s LV %s",
 						lv_is_origin(lv) ? "origin" :
 						lv_is_cow(lv) ?
@@ -405,11 +407,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						seg_is_raid(first_seg(lv)) ?
 						"RAID" :
 						lv_is_raid_type(lv) ?
-						"RAID-related" :
-						lv_is_mirrored(lv) ?
-						"mirror" :
-						lv_is_mirror_type(lv) ?
-						"mirror-related" : "",
+						"RAID-related" : "",
 						lv->name);
 			lv_skipped = 1;
 			continue;


