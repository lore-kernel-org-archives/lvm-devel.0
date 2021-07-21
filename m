From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Jul 2021 19:26:37 +0000 (GMT)
Subject: main - writecache: fix missing sync_dev_names when attaching cache
Message-ID: <20210721192637.42057385C017@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d91c018732c07c5d8c6bfc05570dbc82644a957c
Commit:        d91c018732c07c5d8c6bfc05570dbc82644a957c
Parent:        640fe5cf42fd136e60778513c5fc28499e78f9c2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 21 13:16:21 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 21 13:16:21 2021 -0500

writecache: fix missing sync_dev_names when attaching cache

When activating an LV to check the fs block size, wait for
the LV dev to be accessible before running blkid on it.
---
 tools/lvconvert.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7fbe84952..f699443fd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6124,6 +6124,12 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 			log_error("Failed to activate LV to check block size %s", display_lvname(lv));
 			goto bad;
 		}
+		if (!sync_local_dev_names(cmd)) {
+			log_error("Failed to sync local dev names.");
+			if (!deactivate_lv(cmd, lv))
+				stack;
+			goto bad;
+		}
 	}
 
 	if (!_set_writecache_block_size(cmd, lv, &block_size_sectors)) {


