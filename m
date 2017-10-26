From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 26 Oct 2017 11:16:53 -0400
Subject: master - raid: ignore --stripes/--stripesize on takeover
Message-ID: <201710261516.v9QFGrec006413@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a3884245d02bcdad41e4dd99f9201721c60158f
Commit:        4a3884245d02bcdad41e4dd99f9201721c60158f
Parent:        b765288bf242bbbdc93ef2f76ae4d3f7bdeb5868
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 26 17:16:23 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 26 17:16:23 2017 +0200

raid: ignore --stripes/--stripesize on takeover

Converting from one raid level to another, no changes
of stripes or stripesize can be requested because those
are subject to reshaping.  I.e. the process requires to
takeover first and secondly request raid algorithm,
stripe or stripesize changes.

Ignore any related changes display warninngs
and proceed with the takeover.

Without this patch, a takeover requesting
stripesize change causes data corruption!
---
 lib/metadata/raid_manip.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f065a4c..f48169e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -502,7 +502,6 @@ static int _reset_flags_passed_to_kernel(struct logical_volume *lv, int *flags_r
 			return 0;
 
 		if (slv->status & LV_RESHAPE_DELTA_DISKS_MINUS) {
-			*flags_reset = 1;
 			slv->status |= LV_REMOVE_AFTER_RESHAPE;
 			seg_metalv(seg, s)->status |= LV_REMOVE_AFTER_RESHAPE;
 		}
@@ -6293,6 +6292,17 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 		r = 0;
 	}
 
+	/* Can't reshape stripes or stripe size when performing a takeover! */
+	if (!_is_same_level(seg_from->segtype, *segtype_to)) {
+		if (stripes && stripes != _data_rimages_count(seg_from, seg_from->area_count))
+			log_warn("WARNING: ignoring --stripes option on takeover of %s (reshape afterwards).",
+				 display_lvname(seg_from->lv));
+
+		if (!seg_is_raid1(seg_from) && new_stripe_size_supplied)
+			log_warn("WARNING: ignoring --stripesize option on takeover of %s (reshape afterwards).",
+				 display_lvname(seg_from->lv));
+	}
+
 	if (r &&
 	    !yes &&
 	    strcmp((*segtype_to)->name, SEG_TYPE_NAME_MIRROR) && /* "mirror" is prompted for later */
@@ -6465,11 +6475,20 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * stripes and stripe_size can only be changed via reshape, not in a takeover!
+	 *
+	 * Ignore any of them here unless a takeover from raid1 to
+	 * raid4/5 is requested when stripe size may be defined.
+	 */
+	stripes = _data_rimages_count(seg, seg->area_count);
+	stripe_size = seg_is_raid1(seg) ? stripe_size : seg->stripe_size;
+
 	takeover_fn = _get_takeover_fn(first_seg(lv), new_segtype, new_image_count);
 
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
-		return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
+		return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, stripes, stripe_size,
 			   region_size, allocate_pvs);
 
 	/*
@@ -6498,7 +6517,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	lv->status &= ~LV_RESHAPE;
 
-	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
+	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, stripes, stripe_size,
 			   region_size, allocate_pvs);
 }
 


