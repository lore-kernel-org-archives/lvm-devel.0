From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 27 Apr 2017 09:58:19 -0400
Subject: master - lvconvert: preserve region size on raid1 image count changes (v2)
Message-ID: <201704271358.v3RDwJJf001739@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05164479781486dbe2486c0439d42ed03e4483e8
Commit:        05164479781486dbe2486c0439d42ed03e4483e8
Parent:        14c84c79db91d16f7beed203aa8c03127426d1d9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 27 15:52:25 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 27 15:52:25 2017 +0200

lvconvert: preserve region size on raid1 image count changes (v2)

Unless a change of the regionsize is requested via "lvconvert -R N ...",
keep the region size when the number of images changes in a raid1 LV.

Related: rhbz1443705
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   15 +++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 199b1dc..c746bac 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  lvconvert - preserve region size on raid1 image count changes
   Adjust pvresize messages and add prompt if underlying dev size differs.
   raid - sanely handle insufficient space on takeover.
   Fix configure --enable-notify-dbus status message.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 04201d0..821146f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -60,6 +60,7 @@ struct lvconvert_params {
 	int need_polling;
 
 	uint32_t region_size;
+	unsigned region_size_supplied;
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
@@ -247,10 +248,13 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 				return 0;
 			}
 
-			if (arg_is_set(cmd, regionsize_ARG))
+			if (arg_is_set(cmd, regionsize_ARG)) {
 				lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-			else
+				lp->region_size_supplied = 1;
+			} else {
 				lp->region_size = get_default_region_size(cmd);
+				lp->region_size_supplied = 0;
+			}
 
 			/* FIXME man page says in one place that --type and --mirrors can't be mixed */
 			if (lp->mirrors_supplied && !lp->mirrors)
@@ -1360,7 +1364,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, lp->yes, image_count, lp->region_size, lp->pvh))
+			if (!lv_raid_change_image_count(lv, lp->yes, image_count,
+							(lp->region_size_supplied || !seg->region_size) ?
+							lp->region_size : seg->region_size , lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",
@@ -1427,7 +1433,8 @@ try_new_takeover_or_reshape:
 	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp))))) {
 		if (!lv_raid_convert(lv, lp->segtype,
 				     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-				     lp->region_size, lp->pvh))
+				     (lp->region_size_supplied || !seg->region_size) ?
+				     lp->region_size : seg->region_size , lp->pvh))
 			return_0;
 
 		log_print_unless_silent("Logical volume %s successfully converted.",


