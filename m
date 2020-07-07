From: David Teigland <teigland@sourceware.org>
Date: Tue,  7 Jul 2020 18:21:48 +0000 (GMT)
Subject: master - writecache: skip fs block size check in test mode
Message-ID: <20200707182148.23926385ED4B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40266faaab07f5578d137f9e400fbc9190edabcd
Commit:        40266faaab07f5578d137f9e400fbc9190edabcd
Parent:        ad773511c59aea239592c014a2dab4161ed92214
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 7 13:20:18 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 7 13:20:18 2020 -0500

writecache: skip fs block size check in test mode

if doing so requires activating the LV
---
 tools/lvconvert.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0155fdbf9..61256c698 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5649,6 +5649,11 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		stack;
 
 	if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
+		if (test_mode()) {
+			log_print("Test mode skips checking fs block size.");
+			fs_block_size = 0;
+			goto skip_fs;
+		}
 		log_error("Device for LV not found to check block size %s", pathname);
 		goto_bad;
 	}
@@ -5667,6 +5672,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	 * With 512 LBS and 4K PBS, mkfs.xfs will use xfs sector size 4K.
 	 */
 	rv = get_fs_block_size(fs_dev, &fs_block_size);
+skip_fs:
 	if (!rv || !fs_block_size) {
 		if (lbs_4k && pbs_4k && !pbs_512) {
 			block_size = 4096;


