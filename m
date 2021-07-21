From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Jul 2021 19:26:38 +0000 (GMT)
Subject: main - writecache: use block size 512 for thin pool data
Message-ID: <20210721192638.6758A38708E9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06602942a31d82cb69e9d1874f3b63825c0f93ac
Commit:        06602942a31d82cb69e9d1874f3b63825c0f93ac
Parent:        d91c018732c07c5d8c6bfc05570dbc82644a957c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 21 14:10:38 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 21 14:24:27 2021 -0500

writecache: use block size 512 for thin pool data

Recent commit 84bd394cf9aaa581b4bf980f764544dda26a0305
  "writecache: use block size 4096 when no fs is found"

failed to account for the case where writecache is attached
to thin pool data.  Checking fs block size on the thin pool
data LV is wrong, and checking the fs block on each thin LV
would be impractical, so default to 512 which cannot break
any existing file systems, and require the user to specify
4k when appropriate.
---
 tools/lvconvert.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f699443fd..83dfe5c71 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5966,6 +5966,23 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		goto bad;
 	}
 
+	/*
+	 * When attaching writecache to thin pool data, the fs block sizes
+	 * would need to be checked on each thin LV which isn't practical, so
+	 * default to 512, and require the user to specify 4k when appropriate.
+	 */
+	if (lv_is_thin_pool(lv) || lv_is_thin_pool_data(lv)) {
+		if (block_size_setting)
+			block_size = block_size_setting;
+		else
+			block_size = 512;
+
+		log_print("Using writecache block size %u for thin pool data, logical block size %u, physical block size %u.",
+			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+
+		goto out;
+	}
+
 	if (dm_snprintf(pathname, sizeof(pathname), "%s/%s/%s", cmd->dev_dir,
 			lv->vg->name, lv->name) < 0) {
 		log_error("Path name too long to get LV block size %s", display_lvname(lv));


