From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Feb 2017 15:52:24 +0000 (UTC)
Subject: master - lvconvert: add segtype raid5_n and conversions to/from it (cleanup)
Message-ID: <20170207155224.4427560C49@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91c4bd14d0a6d07366375e86e6cdff0da2e2bdc4
Commit:        91c4bd14d0a6d07366375e86e6cdff0da2e2bdc4
Parent:        cfb6ef654d3d1f1dd02569a1d5bd2fc252ae2494
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 7 12:25:26 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 7 12:25:26 2017 +0100

lvconvert: add segtype raid5_n and conversions to/from it (cleanup)

Cleanups as of Jons review:
- enhance comment about mandatory raid4 <-> raid5_n activation w/o metadata SubLVs
- remove bogus segment flag setting
- fix to sync related comments on conversions to raid0/striped and amongst raid4/5
- add missing error message for non-synced conversion to raid0/striped

Related: rhbz1366296
---
 lib/metadata/merge.c      |    9 ++++++++-
 lib/metadata/raid_manip.c |   11 +++++++----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index dbd91db..6311818 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -148,7 +148,14 @@ static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
 static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
 {
 	/* Checks applying to any raid4/5/6/10 */
-	/* Allow raid4 + raid5_n to get activated w/o metadata (mandatory during conversion between them) */
+	/*
+	 * Allow raid4 + raid5_n to get activated w/o metadata.
+	 *
+	 * This is mandatory during conversion between them,
+	 * because switching the dedicated parity SubLVs
+	 * beginning <-> end changes the roles of all SubLVs
+	 * which the kernel would reject.
+	 */
 	if (!(seg_is_raid4(seg) || seg_is_raid5_n(seg)) && !seg->meta_areas)
 		raid_seg_error("no meta areas");
 	if (!seg->stripe_size)
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9b9f5f3..0c541fb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2196,7 +2196,7 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
-	seg->status |= RAID;
+	seg->status |= SEG_RAID;
 
 	if (!lv_update_and_reload(lv))
 		return_0;
@@ -3114,9 +3114,12 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 
 	dm_list_init(&removal_lvs);
 
-	/* Necessary when convering to raid0/striped w/o redundancy? */
-	if (!_raid_in_sync(lv))
+	/* Necessary when converting to raid0/striped w/o redundancy. */
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync.",
+			  display_lvname(lv));
 		return 0;
+	}
 
 	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
 				  "type losing %s resilience? [y/n]: ",
@@ -3224,7 +3227,7 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 
-	/* Necessary when convering to raid0/striped w/o redundancy? */
+	/* Necessary when convering to raid0/striped w/o redundancy. */
 	if (!_raid_in_sync(lv)) {
 		log_error("Unable to convert %s while it is not in-sync.",
 			  display_lvname(lv));


