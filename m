From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 Jan 2019 11:49:32 -0500
Subject: master - writecache: use wipe_lv to warn about specific signatures
Message-ID: <201901031649.x03GnW4C029370@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc40391b7de93334c815565240848d5297f7a6c8
Commit:        bc40391b7de93334c815565240848d5297f7a6c8
Parent:        938b6b8253c7aadb8947c574cc5f480ed2c1b696
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 3 10:37:26 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 3 10:47:35 2019 -0600

writecache: use wipe_lv to warn about specific signatures

When initializing an LV to hold the writecache, use wipe_lv()
which looks for specific signatures on the LV.

Wiping signatures is not necessary, but printing a warning
that names a specific signature (in addition to the existing
generic warning/confirmation) may help if a user accidentally
specifies the wrong LV which contains something important.
---
 tools/lvconvert.c |   39 +++++++++------------------------------
 1 files changed, 9 insertions(+), 30 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2c6384e..8ea7b65 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5230,44 +5230,23 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 
 static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	struct device *dev;
-	char name[PATH_MAX];
-	int ret = 0;
+	struct wipe_params wp;
+	int ret;
 
 	if (!activate_lv(cmd, lv)) {
-		log_error("Failed to activate LV %s for zeroing.", lv->name);
+		log_error("Failed to activate LV %s for zeroing.", display_lvname(lv));
 		return 0;
 	}
 
-	sync_local_dev_names(cmd);
-
-	if (dm_snprintf(name, sizeof(name), "%s%s/%s",
-			cmd->dev_dir, lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
-		goto out;
-	}
+	wp.do_wipe_signatures = 1; /* optional, to print warning if clobbering something */
+	wp.do_zero = 1;            /* required for dm-writecache to work */
+	wp.zero_sectors = 1;
+	wp.zero_value = 0;
 
-	if (!(dev = dev_cache_get(cmd, name, NULL))) {
-		log_error("%s: not found: device not zeroed", name);
-		goto out;
-	}
+	ret = wipe_lv(lv, wp);
 
-	if (!label_scan_open(dev)) {
-		log_error("Failed to open %s/%s for zeroing.", lv->vg->name, lv->name);
-		goto out;
-	}
-
-	if (!dev_write_zeros(dev, UINT64_C(0), (size_t) 1 << SECTOR_SHIFT))
-		goto_out;
-
-	log_debug("Zeroed the first sector of %s", lv->name);
-
-	label_scan_invalidate(dev);
-
-	ret = 1;
-out:
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Failed to deactivate LV %s for zeroing.", lv->name);
+		log_error("Failed to deactivate LV %s for zeroing.", display_lvname(lv));
 		ret = 0;
 	}
 


