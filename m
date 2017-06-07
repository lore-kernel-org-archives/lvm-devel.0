From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 7 Jun 2017 12:38:05 -0400
Subject: master - lvconvert: reject RAID conversions on inactive LVs
Message-ID: <201706071638.v57Gc5Jx005982@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39703cb48514415633bc027e49e99e1ee7c4bbb4
Commit:        39703cb48514415633bc027e49e99e1ee7c4bbb4
Parent:        61420309ee34bb77318bf3913eb539b8f85adbda
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 7 18:37:04 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 7 18:37:04 2017 +0200

lvconvert: reject RAID conversions on inactive LVs

Only support RAID conversions on active LVs.

If we'd accept e.g. upconverting linear -> raid1 on inactive
linear LVs, any LV flags passed to the kernel aren't properly
cleared thus errouneously passing them on every activation.

Add respective check to lv_raid_change_image_count() and
move existing one in lv_raid_convert() for better messages.
---
 lib/metadata/raid_manip.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8c9069c..5db4a8e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3058,6 +3058,13 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 	const char *level = seg->area_count == 1 ? "raid1 with " : "";
 	const char *resil = new_count < seg->area_count ? "reducing" : "enhancing";
 
+	/* LV must be active to perform raid conversion operations */
+	if (!lv_is_active(lv)) {
+		log_error("%s must be active to perform this operation.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (new_count != 1 && /* Already prompted for in _raid_remove_images() */
 	    !yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s%u images %s resilience? [y/n]: ",
 				  lvseg_name(first_seg(lv)), display_lvname(lv), level, new_count, resil) == 'n') {
@@ -6158,6 +6165,15 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t available_slvs, removed_slvs;
 	takeover_fn_t takeover_fn;
 
+	/* FIXME If not active, prompt and activate */
+	/* FIXME Some operations do not require the LV to be active */
+	/* LV must be active to perform raid conversion operations */
+	if (!lv_is_active(lv)) {
+		log_error("%s must be active to perform this operation.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	new_segtype = new_segtype ? : seg->segtype;
 	if (!new_segtype) {
 		log_error(INTERNAL_ERROR "New segtype not specified.");
@@ -6261,15 +6277,6 @@ int lv_raid_convert(struct logical_volume *lv,
 		    (segtype_is_striped_target(new_segtype) &&
 		    (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
-	/* FIXME If not active, prompt and activate */
-	/* FIXME Some operations do not require the LV to be active */
-	/* LV must be active to perform raid conversion operations */
-	if (!lv_is_active(lv)) {
-		log_error("%s must be active to perform this operation.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	/* In clustered VGs, the LV must be active on this node exclusively. */
 	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
 		log_error("%s must be active exclusive locally to "


