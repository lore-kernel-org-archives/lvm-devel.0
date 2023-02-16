From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:45 +0000 (GMT)
Subject: main - lvconvert: use log_print_unless_silent
Message-ID: <20230216231045.5776B3858C31@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb930c2165c2b62daf2adc9d97d59f129132e5c3
Commit:        fb930c2165c2b62daf2adc9d97d59f129132e5c3
Parent:        501cc19034d114683458fadeacb1bb1b47ab0195
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 12:18:02 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 16 13:15:03 2023 +0100

lvconvert: use log_print_unless_silent

For better -qq.
---
 tools/lvconvert.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 34ef5ac1e..7331f243f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4357,7 +4357,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 			if (!arg_is_set(cmd, yes_ARG) &&
 			    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",
 					  display_size(cmd, pv_size_sectors), device_name) == 'n') {
-				log_print("Use --cachesize SizeMB to use a part of the cachedevice.");
+				log_print_unless_silent("Use --cachesize SizeMB to use a part of the cachedevice.");
 				log_error("Conversion aborted.");
 				return 0;
 			}
@@ -4407,8 +4407,8 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 	lp.pvh = use_pvh;
 	lp.extents = cache_size_sectors / vg->extent_size;
 
-	log_print("Creating cachevol LV %s with size %s.",
-		  cvname, display_size(cmd, cache_size_sectors));
+	log_print_unless_silent("Creating cachevol LV %s with size %s.",
+				cvname, display_size(cmd, cache_size_sectors));
 
 	dm_list_init(&lp.tags);
 
@@ -5783,7 +5783,7 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 			stack;
 	}
 
-	log_print("Detaching writecache completed cleaning.");
+	log_print_unless_silent("Detaching writecache completed cleaning.");
 
 	lv_fast = first_seg(lv)->writecache;
 
@@ -5977,8 +5977,8 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		else
 			block_size = 512;
 
-		log_print("Using writecache block size %u for thin pool data, logical block size %u, physical block size %u.",
-			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+		log_print_unless_silent("Using writecache block size %u for thin pool data, logical block size %u, physical block size %u.",
+					block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
 
 		goto out;
 	}
@@ -5990,7 +5990,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	}
 
 	if (test_mode()) {
-		log_print("Test mode skips checking fs block size.");
+		log_print_unless_silent("Test mode skips checking fs block size.");
 		fs_block_size = 0;
 		goto skip_fs;
 	}
@@ -6016,8 +6016,8 @@ skip_fs:
 		else
 			block_size = 4096;
 
-		log_print("Using writecache block size %u for unknown file system block size, logical block size %u, physical block size %u.",
-			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+		log_print_unless_silent("Using writecache block size %u for unknown file system block size, logical block size %u, physical block size %u.",
+					block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
 
 		if (block_size != 512) {
 			log_warn("WARNING: unable to detect a file system block size on %s", display_lvname(lv));

