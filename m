From: David Teigland <teigland@sourceware.org>
Date: Wed, 2 Jan 2019 12:57:11 -0500
Subject: master - Revert "lvconvert: use standard wiping code"
Message-ID: <201901021757.x02HvBlt007821@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89c61f2018c843a7dabc617ba152b99656ee9849
Commit:        89c61f2018c843a7dabc617ba152b99656ee9849
Parent:        ee9d623d387c8789fc40e957af7b47d287a57368
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 2 11:21:45 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 2 11:21:45 2019 -0600

Revert "lvconvert: use standard wiping code"

This reverts commit fb85d5d02478a34ab6648bdbdf09a931176dee71.

Adding a confirmation prompt in the following commit so the
wiping confirmation won't be needed.
---
 tools/lvconvert.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7139be3..3ba7f5b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5228,6 +5228,52 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct device *dev;
+	char name[PATH_MAX];
+	int ret = 0;
+
+	if (!activate_lv(cmd, lv)) {
+		log_error("Failed to activate LV %s for zeroing.", lv->name);
+		return 0;
+	}
+
+	sync_local_dev_names(cmd);
+
+	if (dm_snprintf(name, sizeof(name), "%s%s/%s",
+			cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", lv->name);
+		goto out;
+	}
+
+	if (!(dev = dev_cache_get(cmd, name, NULL))) {
+		log_error("%s: not found: device not zeroed", name);
+		goto out;
+	}
+
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open %s/%s for zeroing.", lv->vg->name, lv->name);
+		goto out;
+	}
+
+	if (!dev_write_zeros(dev, UINT64_C(0), (size_t) 1 << SECTOR_SHIFT))
+		goto_out;
+
+	log_debug("Zeroed the first sector of %s", lv->name);
+
+	label_scan_invalidate(dev);
+
+	ret = 1;
+out:
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Failed to deactivate LV %s for zeroing.", lv->name);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
 				       char *key, char *val, uint32_t *block_size_sectors)
 {
@@ -5470,7 +5516,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 * writecache block_size value matching the sector size of lv.
 	 */
 
-	if (!activate_and_wipe_lv(lv_fast, 0)) {
+	if (!_writecache_zero(cmd, lv_fast)) {
 		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
 		return 0;
 	}


