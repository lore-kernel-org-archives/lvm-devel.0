From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  5 Aug 2016 13:29:09 +0000 (UTC)
Subject: master - raid: Tell lib whether stripesize was specified
Message-ID: <20160805132909.2C67060EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91f866f7866eed6eb8ead5a876efcac5a58511da
Commit:        91f866f7866eed6eb8ead5a876efcac5a58511da
Parent:        7482ff93b8316767ad128b43fcf5fae8725f8057
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 5 14:28:14 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 5 14:28:14 2016 +0100

raid: Tell lib whether stripesize was specified

---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   11 ++++++-----
 tools/lvconvert.c                |    5 ++++-
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e61802d..e1a3538 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1200,6 +1200,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,
 		    int yes, int force,
 		    const unsigned stripes,
+		    const unsigned new_stripe_size_supplied,
 		    const unsigned new_stripe_size,
 		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2cc48e1..a2bf832 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2744,6 +2744,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,
 		    int yes, int force,
 		    const unsigned new_stripes,
+		    const unsigned new_stripe_size_supplied,
 		    const unsigned new_stripe_size,
 		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs)
@@ -2758,7 +2759,11 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
+	stripes = new_stripes ? : _data_rimages_count(seg, seg->area_count);
+
+	/* FIXME Ensure caller does *not* set wrong default value! */
+	/* Define new stripe size if not passed in */
+	stripe_size = new_stripe_size ? : seg->stripe_size;
 
 	if (segtype_is_striped(new_segtype))
 		new_image_count = stripes;
@@ -2766,10 +2771,6 @@ int lv_raid_convert(struct logical_volume *lv,
 	if (segtype_is_raid(new_segtype) && !_check_max_raid_devices(new_image_count))
 		return_0;
 
-	/* FIXME Ensure caller does *not* set wrong default value! */
-	/* Define new stripe size if not passed in */
-	stripe_size = new_stripe_size ?: seg->stripe_size;
-
 	takeover_fn = _get_takeover_fn(first_seg(lv), new_segtype, new_image_count);
 
 	/* Exit without doing activation checks if the combination isn't possible */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5731558..8c3bf05 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -86,6 +86,7 @@ struct lvconvert_params {
 	sign_t mirrors_sign;
 	uint32_t stripes;
 	uint32_t stripe_size;
+	uint32_t stripe_size_supplied;
 	uint32_t read_ahead;
 	cache_mode_t cache_mode; /* cache */
 	const char *policy_name; /* cache */
@@ -1905,7 +1906,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			log_error("RAID module does not support RAID0.");
 			return 0;
 		}
-		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size,
+		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
 				     lp->region_size, lp->pvh))
 			return_0;
 		log_print_unless_silent("Logical volume %s successfully converted.",
@@ -4405,6 +4406,8 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
 		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
 			return_0;
+		/* FIXME Move this into the get function */
+		lp->stripe_size_supplied = arg_is_set(cmd, stripesize_ARG);
 
 		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
 			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */


