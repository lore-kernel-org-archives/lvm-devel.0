From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 09:01:23 -0500
Subject: master - raid: ignore --stripesize on raid4/5 conversion to 1 stripe
Message-ID: <201712011401.vB1E1ND0023152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3d18e637cbd4bfb1ef088a404fdc12dd319309e
Commit:        d3d18e637cbd4bfb1ef088a404fdc12dd319309e
Parent:        a42c3a0e90d712652890696fefca51380969d595
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 15:00:09 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 15:00:09 2017 +0100

raid: ignore --stripesize on raid4/5 conversion to 1 stripe

In case caller passes in changed stripe size when reshaping raid4/5
to 1 stripe aiming to convert to raid1 and optionally to linear,
ignore it to prevent data corruption.
---
 lib/metadata/raid_manip.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2d8aaed..0f56120 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1989,12 +1989,16 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 				       const unsigned new_stripes, const unsigned new_stripe_size,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs)
 {
-	uint32_t available_slvs, current_le_count, reduced_le_count, removed_slvs, s;
+	int stripe_size_changed;
+	uint32_t available_slvs, current_le_count, reduced_le_count, removed_slvs, s, stripe_size;
 	uint64_t extend_le_count;
 	unsigned devs_health, devs_in_sync;
 	struct lv_segment *seg = first_seg(lv);
 	struct lvinfo info = { 0 };
 
+	stripe_size = seg->stripe_size;
+	stripe_size_changed = new_stripe_size && (stripe_size != new_stripe_size);
+
 	if (seg_is_any_raid6(seg) && new_stripes < 3) {
 		log_error("Minimum 3 stripes required for %s LV %s.",
 			  lvseg_name(seg), display_lvname(lv));
@@ -2119,7 +2123,15 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		return 0;
 	}
 
-	seg->stripe_size = new_stripe_size;
+	/* May allow stripe size changes > 2 legs */
+	if (new_image_count > 2)
+		seg->stripe_size = new_stripe_size;
+	else {
+		seg->stripe_size = stripe_size;
+		if (stripe_size_changed)
+			log_warn("WARNING: ignoring --stripesize on conversion of %s to 1 stripe.",
+				 display_lvname(lv));
+	}
 
 	return 1;
 }


