From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:45 +0000 (UTC)
Subject: master - segtype: check for seg type instead of status
Message-ID: <20161213210945.8D0B060973@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1e398c474032716679f704008026b5d17e9469a
Commit:        d1e398c474032716679f704008026b5d17e9469a
Parent:        069039204002e5c8514050fe541bbd378c383a02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 14:50:48 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

segtype: check for seg type instead of status

RAID is LV property - which has single segment of raid type.
---
 WHATS_NEW                |    1 +
 lib/format_text/export.c |    2 +-
 lib/metadata/merge.c     |    8 ++++----
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a75183e..0561074 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Check segtype directly instead of checking RAID in segment status. 
   Reusing exiting code for raid image removal.
   Fix pvmove leaving -pvmove0 error device in clustered VG.
   Avoid adding extra '_' at end of raid extracted images or metadata.
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 1ecc362..199c185 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -623,7 +623,7 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 			break;
 		case AREA_LV:
 			/* FIXME This helper code should be target-independent! Check for metadata LV property. */
-			if (!(seg->status & RAID)) {
+			if (!seg_is_raid(seg)) {
 				outf(f, "\"%s\", %u%s",
 				     seg_lv(seg, s)->name,
 				     seg_le(seg, s),
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index bf0d2c0..6d52bc4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -431,7 +431,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		}
 
 		if (complete_vg && seg->log_lv &&
-		    !seg_is_mirrored(seg) && !(seg->status & RAID_IMAGE)) {
+		    !seg_is_mirrored(seg) && lv_is_raid_image(lv)) {
 			log_error("LV %s: segment %u log LV %s is not a "
 				  "mirror log or a RAID image",
 				  lv->name, seg_count, seg->log_lv->name);
@@ -458,9 +458,9 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			}
 		}
 
-		if (complete_vg && seg->status & MIRROR_IMAGE) {
-			if (!find_mirror_seg(seg) ||
-			    !seg_is_mirrored(find_mirror_seg(seg))) {
+		if (complete_vg && lv_is_mirror_image(lv)) {
+			if (!(seg2 = find_mirror_seg(seg)) ||
+			    !seg_is_mirrored(seg2)) {
 				log_error("LV %s: segment %u mirror image "
 					  "is not mirrored",
 					  lv->name, seg_count);


