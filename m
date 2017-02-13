From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:58 +0000 (UTC)
Subject: master - lvconvert: remove code for changing region size
Message-ID: <20170213181058.686CF60CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1386dcca024b51019c1f3be6b153249df06dbac
Commit:        a1386dcca024b51019c1f3be6b153249df06dbac
Parent:        46abc28a480069b3e8b2c5c7c3448ffa25ec17ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 7 15:01:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:21:58 2017 -0600

lvconvert: remove code for changing region size

from the generic raid type conversion code.
---
 tools/lvconvert.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4e86698..4d6b1c9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1402,13 +1402,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!arg_is_set(cmd, regionsize_ARG) && (!*lp->type_str || seg->segtype == lp->segtype)) {
+	} else if (!*lp->type_str || seg->segtype == lp->segtype) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
-	    ((lp->type_str && lp->type_str[0]) || arg_is_set(cmd, regionsize_ARG))) {
+	    (lp->type_str && lp->type_str[0])) {
 		/* Activation is required later which precludes existing supported raid0 segment */
 		if ((seg_is_any_raid0(seg) || segtype_is_any_raid0(lp->segtype)) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
@@ -1430,12 +1430,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
 
-		/*
-		 * FIXME: arg_is_set() workaround for region size until the cli validation patches got merged;
-		 *	 i needs "--type raid*", because lp->region_size isn't set w/o it
-		 */
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     arg_is_set(cmd, regionsize_ARG) ? lp->region_size : 0, lp->pvh))
+				     lp->region_size, lp->pvh))
 			return_0;
 
 		log_print_unless_silent("Logical volume %s successfully converted.",
@@ -1456,12 +1452,8 @@ try_new_takeover_or_reshape:
 	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
 	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
 	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
-		/*
-		 * FIXME: arg_is_set() workaround for region size until the cli validation patches got merged;
-		 *	 i needs "--type raid*", because lp->region_size isn't set w/o it
-		 */
 		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     arg_is_set(cmd, regionsize_ARG) ? lp->region_size : 0, lp->pvh))
+				     lp->region_size, lp->pvh))
 			return_0;
 
 		log_print_unless_silent("Logical volume %s successfully converted.",


