From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 16:50:51 +0000 (UTC)
Subject: master - stripes: Introduce _round_to_stripe_boundary.
Message-ID: <20150924165051.CFB5060ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e773e719109ad54c289f86a54b316e787f0110c8
Commit:        e773e719109ad54c289f86a54b316e787f0110c8
Parent:        39a97d86f09df0d89664c7ddae28ca1d1bb3a741
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 24 17:50:53 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 17:50:53 2015 +0100

stripes: Introduce _round_to_stripe_boundary.

---
 lib/metadata/lv_manip.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ac3d25f..429a487 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -941,6 +941,26 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 	return denominator ? dm_make_percent(numerator, denominator) : 100.0;
 }
 
+/* Round up extents to next stripe boundary for number of stripes */
+static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t extents,
+					  uint32_t stripes, int extend)
+{
+	uint32_t size_rest, new_extents = extents;
+
+	if (!stripes)
+		return extents;
+
+	/* Round up extents to stripe divisible amount */
+	if ((size_rest = extents % stripes)) {
+		new_extents += extend ? stripes - size_rest : -size_rest;
+		log_print_unless_silent("Rounding size %s (%d extents) up to stripe boundary size %s (%d extents).",
+					display_size(vg->cmd, extents * vg->extent_size), extents,
+					display_size(vg->cmd, new_extents * vg->extent_size), new_extents);
+	}
+
+	return new_extents;
+}
+
 /*
  * All lv_segments get created here.
  */
@@ -6933,7 +6953,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					       const char *new_lv_name)
 {
 	struct cmd_context *cmd = vg->cmd;
-	uint32_t size_rest, size;
+	uint32_t size;
 	uint64_t status = lp->permission | VISIBLE_LV;
 	const struct segment_type *create_segtype = lp->segtype;
 	struct logical_volume *lv, *origin_lv = NULL;
@@ -6998,12 +7018,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->stripe_size = vg->extent_size;
 	}
 
-	if ((size_rest = lp->extents % lp->stripes)) {
-		log_print_unless_silent("Rounding size (%d extents) up to stripe boundary "
-					"size (%d extents).", lp->extents,
-					lp->extents - size_rest + lp->stripes);
-		lp->extents = lp->extents - size_rest + lp->stripes;
-	}
+	lp->extents = _round_to_stripe_boundary(vg, lp->extents, lp->stripes, 1);
 
 	if (!lp->extents && !seg_is_thin_volume(lp)) {
 		log_error(INTERNAL_ERROR "Unable to create new logical volume with no extents.");


