From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 5 Apr 2017 18:03:36 -0400
Subject: master - lvconvert: allow --type with --regionsize
Message-ID: <201704052203.v35M3aOx032639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ef1bdab27b2e2d3fb2491b42e3f7afa3b93140e
Commit:        1ef1bdab27b2e2d3fb2491b42e3f7afa3b93140e
Parent:        7ccb4825c7c5f40e93afea065100105f3d5f3551
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 00:01:29 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 00:03:16 2017 +0200

lvconvert: allow --type with --regionsize

Allow the combination of both arguments keeping
the raid level but changing the regionssize
(e.g. "lvconvert --type raid1 --regionsize 1M RaidLV"
 on an existing raid1 LV).

Resolves: rhbz1438396
---
 lib/metadata/raid_manip.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 63a2a6c..c7d1d76 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5355,7 +5355,7 @@ static int _takeover_from_raid1_to_raid0_meta(TAKEOVER_FN_ARGS)
 
 static int _takeover_from_raid1_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _takeover_unsupported(lv, new_segtype, 0, 0, 0, 0, new_stripes, 0, 0, NULL);
 }
 
 static int _takeover_from_raid1_to_raid10(TAKEOVER_FN_ARGS)
@@ -5975,7 +5975,29 @@ int lv_raid_convert(struct logical_volume *lv,
 	/* Exit without doing activation checks if the combination isn't possible */
 	if (_takeover_not_possible(takeover_fn))
 		return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
-				   region_size, allocate_pvs);
+			   region_size, allocate_pvs);
+
+	/*
+	 * User requested "--type raid*" without neither
+	 * requesting a reshape nor a takeover.
+	 *
+	 * I.e. the raid level is the same but no layout,
+	 * stripesize or number of stripes change is required.
+	 *
+	 * Check if a regionsize change is required.
+	 */
+	if (seg->segtype == new_segtype && new_region_size) {
+		if (seg->region_size != new_region_size) {
+			log_verbose("Converting %s LV %s to regionsize %s.",
+				    lvseg_name(first_seg(lv)), display_lvname(lv),
+				    display_size(lv->vg->cmd, new_region_size));
+			return _region_size_change_requested(lv, yes, new_region_size);
+		} else {
+			log_error("Can't convert %s LV %s without a region size change.",
+				  lvseg_name(seg), display_lvname(lv));
+			return 0;
+		}
+	}
 
 	log_verbose("Converting %s from %s to %s.",
 		    display_lvname(lv), lvseg_name(first_seg(lv)),


