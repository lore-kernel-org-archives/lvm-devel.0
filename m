From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:05 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: missing error message
Message-ID: <20140922153805.BD52960D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68981310916114e8659bb7754c5847a178aaea5d
Commit:        68981310916114e8659bb7754c5847a178aaea5d
Parent:        3e57143abd49682a90a96a95514b781289bf43f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 23:32:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:31 2014 +0200

cleanup: missing error message

---
 lib/metadata/raid_manip.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 92ea177..0c96fd0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1290,8 +1290,12 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		if (seg_lv(seg, s) == image_lv)
 			meta_lv = seg_metalv(seg, s);
 
-	if (!meta_lv)
-		return_0;
+	if (!meta_lv) {
+		log_error("Failed to find meta for %s in RAID array %s.",
+			  display_lvname(image_lv),
+			  display_lvname(lv));
+		return 0;
+	}
 
 	if (!deactivate_lv(vg->cmd, meta_lv)) {
 		log_error("Failed to deactivate %s before merging.",
@@ -1632,8 +1636,10 @@ int lv_raid_replace(struct logical_volume *lv,
 try_again:
 	if (!_alloc_image_components(lv, allocate_pvs, match_count,
 				     &new_meta_lvs, &new_data_lvs)) {
-		if (!(lv->status & PARTIAL_LV))
+		if (!(lv->status & PARTIAL_LV)) {
+			log_error("LV %s in not partial.", display_lvname(lv));
 			return 0;
+		}
 
 		/* This is a repair, so try to do better than all-or-nothing */
 		match_count--;


