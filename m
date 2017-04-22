From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Sat, 22 Apr 2017 01:32:08 -0400
Subject: master - lvconvert: preserve region size on raid1 image count changes
Message-ID: <201704220532.v3M5W85V013718@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8333d5a969042a321f00656271bd55a37c1ea179
Commit:        8333d5a969042a321f00656271bd55a37c1ea179
Parent:        8f305f025ed862689a8b4e34557e6a469201cba0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 22 02:04:49 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 22 02:04:49 2017 +0200

lvconvert: preserve region size on raid1 image count changes

Unless a change of the regionsize is requested via "lvconvert -R N ...",
keep the region size when the number of images changes in a raid1 LV.

Resolves: rhbz1443705
---
 WHATS_NEW         |    2 ++
 tools/lvconvert.c |   11 ++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a13744..efcddd5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.171 - 
 ==================================
+  lvconvert - preserve region size on raid1 image count changes
+  raid - sanely handle insufficient space on takeover
   Fix configure --enable-notify-dbus status message.
   Change configure option name prefix from --enable-lockd to --enable-lvmlockd.
   lvcreate - raise mirror/raid default regionsize to 2MiB
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5b9510b..d5ca6d7 100644
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
@@ -1359,7 +1363,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, lp->yes, image_count, lp->region_size, lp->pvh))
+			if (!lv_raid_change_image_count(lv, lp->yes, image_count,
+							lp->region_size_supplied ? lp->region_size : seg->region_size , lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",


