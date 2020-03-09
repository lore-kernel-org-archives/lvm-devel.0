From: David Teigland <teigland@sourceware.org>
Date: Mon,  9 Mar 2020 16:21:08 +0000 (GMT)
Subject: master - writecache: require inactive LV to attach
Message-ID: <20200309162108.52A99394D81C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5b1b52903fe3c71e8515f5592ab10d69896b5e7
Commit:        a5b1b52903fe3c71e8515f5592ab10d69896b5e7
Parent:        c9526e859eba5a406e49853d59041a3497154fa8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 9 11:18:10 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 9 11:18:10 2020 -0500

writecache: require inactive LV to attach

Prevent attaching writecache to an active LV until
we can determine the block size of the fs on the LV,
and use that to enforce an appropriate writecache
block size.  Changing the block size under a mounted
fs can cause panic/corruption.
---
 tools/lvconvert.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 68bd75cb5..f6d9a29f6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5603,6 +5603,16 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
+	/*
+	 * To permit this we need to check the block size of the fs using lv
+	 * (recently in libblkid) so that we can use a matching writecache
+	 * block size.  We also want to do that if the lv is inactive.
+	 */
+	if (lv_is_active(lv)) {
+		log_error("LV %s must be inactive to attach writecache.", display_lvname(lv));
+		goto bad;
+	}
+
 	/* fast LV shouldn't generally be active by itself, but just in case. */
 	if (lv_info(cmd, lv_fast, 1, NULL, 0, 0)) {
 		log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
@@ -5643,15 +5653,6 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
 	}
 
-	/*
-	 * TODO: use libblkid to get the sector size of lv.  If it doesn't
-	 * match the block_size we are using for the writecache, then warn that
-	 * an existing file system on lv may become unmountable with the
-	 * writecache attached because of the changing sector size.  If this
-	 * happens, then use --splitcache, and reattach the writecache using a
-	 * writecache block_size value matching the sector size of lv.
-	 */
-
 	if (!_writecache_zero(cmd, lv_fast)) {
 		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
 		return ECMD_FAILED;



