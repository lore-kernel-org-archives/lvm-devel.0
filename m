From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sun,  1 Feb 2015 20:03:47 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - fix stripesize reshape regression
Message-ID: <20150201200347.EC8D760093@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b004136890a0fd4ed9031dc81c3b73e24d2b289
Commit:        4b004136890a0fd4ed9031dc81c3b73e24d2b289
Parent:        0dbd1141e34a89b107158e29387ba826b1606541
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sun Feb 1 21:03:05 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sun Feb 1 21:03:05 2015 +0100

fix stripesize reshape regression

---
 lib/metadata/raid_manip.c |   41 ++++++++++++++++++++++++++---------------
 tools/lvconvert.c         |    3 ++-
 2 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 79997d9..d3cc3fa 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2363,6 +2363,8 @@ static int _convert_reshape(struct logical_volume *lv,
 		return 0;
 	}
 
+	seg->stripe_size = new_stripe_size;
+
 	if (!archive(lv->vg))
 		return_0;
 
@@ -2588,28 +2590,37 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 	unsigned stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
 	unsigned stripe_size = new_stripe_size ?: seg->stripe_size;
 
+	if (new_segtype == seg->segtype &&
+	    stripes == _data_rimages_count(seg, seg->area_count) &&
+	    stripe_size == seg->stripe_size) {
+printf("%s %d stripes=%u stripe_size=%u seg->stripe_size=%u\n", __func__, __LINE__, stripes, stripe_size, seg->stripe_size);
+		log_error("Nothing to do");
+		return 0;
+	}
+
+printf("%s %d stripes=%u stripe_size=%u seg->stripe_size=%u\n", __func__, __LINE__, stripes, stripe_size, seg->stripe_size);
 	/* Check + apply stripe size change */
-	if (stripe_size && !(stripe_size & (stripe_size - 1)) &&
-	    seg->stripe_size != stripe_size) {
+	if (stripe_size / stripes < 8 ||
+	    (stripe_size / stripes) % 8) {
+		log_error("Invalid stripe size on %s", lv->name);
+		return_0;
+	}
+
+	if (seg->stripe_size != stripe_size) {
 		if (seg_is_striped(seg) || seg_is_raid0(seg)) {
 			log_error("Cannot change stripe size on \"%s\"", lv->name);
 			return_0;
 		}
 
-		if (new_stripe_size > seg->region_size) {
-			log_error("New stripe size for %s larger than region size", lv->name);
+		if (stripe_size / stripes > lv->vg->extent_size) {
+			log_error("Stripe size for %s too large for volume group extent size", lv->name);
 			return_0;
 		}
 
-		seg->stripe_size = new_stripe_size;
-		log_debug_metadata("Setting new stripe size for %s", lv->name);
-	}
-
-	if (new_segtype == seg->segtype &&
-	    stripes == _data_rimages_count(seg, seg->area_count) &&
-	    stripe_size == seg->stripe_size) {
-		log_error("Nothing to do");
-		return 0;
+		if (stripe_size > seg->region_size) {
+			log_error("New stripe size for %s larger than region size", lv->name);
+			return_0;
+		}
 	}
 
 #if 1
@@ -2622,6 +2633,7 @@ static int _convert_raid_to_raid(struct logical_volume *lv,
 #endif
 	/* Staying on the same level -> reshape required to change stripes, stripe size or algorithm */
 	if (is_same_level(seg->segtype, new_segtype)) {
+printf("%s %d stripes=%u stripe_size=%u seg->stripe_size=%u\n", __func__, __LINE__, stripes, stripe_size, seg->stripe_size);
 		if (!_convert_reshape(lv, new_segtype, stripes, stripe_size, allocate_pvs))
 			return 0;
 
@@ -2730,8 +2742,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 		return _convert_raid0_to_striped(lv, new_segtype);
 
 	/* All the rest of the raid conversions... */
-	if (_convert_raid_to_raid(lv, new_segtype, new_stripes, new_stripe_size, allocate_pvs))
-		return 1;
+	return _convert_raid_to_raid(lv, new_segtype, new_stripes, new_stripe_size, allocate_pvs);
 
 err:
 	/* FIXME: enhance message */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c969341..beffc22 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1970,8 +1970,9 @@ printf("image_count=%u", image_count);
 	     arg_count(cmd, stripes_ARG) ||
 	     arg_count(cmd, stripes_long_ARG) ||
 	     arg_count(cmd, stripesize_ARG))) {
-		unsigned stripes = (arg_count(cmd, stripes_ARG )|| arg_count(cmd, stripes_long_ARG)) ? lp->stripes  : 0;
+		unsigned stripes = (arg_count(cmd, stripes_ARG) || arg_count(cmd, stripes_long_ARG)) ? lp->stripes  : 0;
 		unsigned stripe_size = arg_count(cmd, stripesize_ARG) ? lp->stripe_size  : 0;
+printf("stripes=%u stripe_size=%u\n", stripes, stripe_size);
 
 		if (seg_is_striped(seg))
 			seg->region_size = lp->region_size;


