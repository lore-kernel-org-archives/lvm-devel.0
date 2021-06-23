From: David Teigland <teigland@sourceware.org>
Date: Wed, 23 Jun 2021 17:41:35 +0000 (GMT)
Subject: main - writecache: use block size 4096 when no fs is found
Message-ID: <20210623174135.659AA38515D5@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84bd394cf9aaa581b4bf980f764544dda26a0305
Commit:        84bd394cf9aaa581b4bf980f764544dda26a0305
Parent:        1139a05939f85bd86a756b451a8f194bc7a72a2c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 23 12:38:57 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 23 12:38:57 2021 -0500

writecache: use block size 4096 when no fs is found

When there is no block size constraint from a file system
or from a user setting, use 4096 rather than 512 because of
better performance.
---
 tools/lvconvert.c | 23 +++++------------------
 1 file changed, 5 insertions(+), 18 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cbe4fa93a..ab8b42b7e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5992,24 +5992,13 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	rv = get_fs_block_size(pathname, &fs_block_size);
 skip_fs:
 	if (!rv || !fs_block_size) {
-		if (lbs_4k && pbs_4k && !pbs_512) {
+		if (block_size_setting)
+			block_size = block_size_setting;
+		else
 			block_size = 4096;
-		} else if (lbs_512 && pbs_512 && !pbs_4k) {
-			block_size = 512;
-		} else if (lbs_512 && pbs_4k) {
-			if (block_size_setting == 4096)
-				block_size = 4096;
-			else
-				block_size = 512;
-		} else {
-			block_size = 512;
-		}
 
-		if (block_size_setting && (block_size_setting != block_size)) {
-			log_warn("WARNING: writecache block size %u does not match device block sizes, logical %u physical %u",
-				 block_size_setting, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
-			block_size = block_size_setting;
-		}
+		log_print("Using writecache block size %u for unknown file system block size, logical block size %u, physical block size %u.",
+			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
 
 		if (block_size != 512) {
 			log_warn("WARNING: unable to detect a file system block size on %s", display_lvname(lv));
@@ -6021,8 +6010,6 @@ skip_fs:
 			}
 		}
 
-		log_print("Using writecache block size %u for unknown file system block size, logical block size %u, physical block size %u.",
-			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
 		goto out;
 	}
 


