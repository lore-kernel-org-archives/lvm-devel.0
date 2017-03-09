From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 17:18:52 -0500
Subject: master - lvconvert: add raid1 <-> raid4 conversion
Message-ID: <201703092218.v29MIqOi006955@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2d7a48418df7ce6071e4276a4a2cf0dd47570d4
Commit:        f2d7a48418df7ce6071e4276a4a2cf0dd47570d4
Parent:        d2aae8cff476034539c3cfe577204b53187fb166
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 23:17:13 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 23:18:13 2017 +0100

lvconvert: add raid1 <-> raid4 conversion

In addition to the already supported conversion between 2-legged
raid1 and raid5, raid1 and raid4 can be also converted into each
other with 2 legs (raid4/5 are limited to map a 2-legged raid1).

This patch supports the missing raid4 conversion in the sequence
linear -> 2-legged raid1 -> raid4/5, then restripe to more than one
data stripes for performance and resilience reasons and optionally
convert to striped/raid0.

The other conversion sequence is also possible by converting N-way
striped/raid0 to raid4/5, then restripe to 2 legs followed by a
conversion to raid1 and optionally to linear (loosing all resilience).
---
 lib/metadata/raid_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0906916..a8c2e19 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4344,12 +4344,12 @@ static struct possible_takeover_reshape_type _possible_takeover_reshape_types[]
 
 	/* raid1 -> raid5* with 2 legs */
 	{ .current_types  = SEG_RAID1,
-	  .possible_types = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	  .possible_types = SEG_RAID4|SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
 	  .current_areas = 2U,
 	  .options = ALLOW_REGION_SIZE|ALLOW_STRIPE_SIZE },
 
 	/* raid5* -> raid1 with 2 legs */
-	{ .current_types  = SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
+	{ .current_types  = SEG_RAID4|SEG_RAID5_LS|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_LA|SEG_RAID5_N,
 	  .possible_types = SEG_RAID1,
 	  .current_areas = 2U,
 	  .options = ALLOW_REGION_SIZE },
@@ -5099,7 +5099,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
 			return 0;
 		}
-		if (!segtype_is_any_raid5(new_segtype)) {
+		if (!segtype_is_raid4(new_segtype) && !segtype_is_any_raid5(new_segtype)) {
 			log_error("Can't convert %s LV %s to %s.",
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name);
 			return 0;
@@ -5176,6 +5176,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	seg->data_copies = new_data_copies;
 
 	if (segtype_is_raid4(new_segtype) &&
+	    seg->area_count != 2 &&
 	    (!_shift_parity_dev(seg) ||
 	     !_rename_area_lvs(lv, "_"))) {
 		log_error("Can't convert %s to %s.", display_lvname(lv), new_segtype->name);


