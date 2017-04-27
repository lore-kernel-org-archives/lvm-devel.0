From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 27 Apr 2017 09:29:29 -0400
Subject: master - Revert "lvconvert: preserve region size on raid1 image count changes"
Message-ID: <201704271329.v3RDTT0d030346@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af47ec9f515402e69328fb73a73172845ff05b2f
Commit:        af47ec9f515402e69328fb73a73172845ff05b2f
Parent:        813bcb24f0cfd664e539d4508ab3586c9b927ab3
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 27 15:29:03 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 27 15:29:03 2017 +0200

Revert "lvconvert: preserve region size on raid1 image count changes"

This reverts commit 8333d5a969042a321f00656271bd55a37c1ea179.
---
 WHATS_NEW         |    3 +--
 tools/lvconvert.c |   11 +++--------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f8efd87..199b1dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,7 @@
 Version 2.02.171 - 
 ==================================
   Adjust pvresize messages and add prompt if underlying dev size differs.
-  lvconvert - preserve region size on raid1 image count changes
-  raid - sanely handle insufficient space on takeover
+  raid - sanely handle insufficient space on takeover.
   Fix configure --enable-notify-dbus status message.
   Change configure option name prefix from --enable-lockd to --enable-lvmlockd.
   lvcreate - raise mirror/raid default regionsize to 2MiB
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 22555f3..04201d0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -60,7 +60,6 @@ struct lvconvert_params {
 	int need_polling;
 
 	uint32_t region_size;
-	unsigned region_size_supplied;
 
 	uint32_t mirrors;
 	sign_t mirrors_sign;
@@ -248,13 +247,10 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 				return 0;
 			}
 
-			if (arg_is_set(cmd, regionsize_ARG)) {
+			if (arg_is_set(cmd, regionsize_ARG))
 				lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
-				lp->region_size_supplied = 1;
-			} else {
+			else
 				lp->region_size = get_default_region_size(cmd);
-				lp->region_size_supplied = 0;
-			}
 
 			/* FIXME man page says in one place that --type and --mirrors can't be mixed */
 			if (lp->mirrors_supplied && !lp->mirrors)
@@ -1364,8 +1360,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, lp->yes, image_count,
-							lp->region_size_supplied ? lp->region_size : seg->region_size , lp->pvh))
+			if (!lv_raid_change_image_count(lv, lp->yes, image_count, lp->region_size, lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",


