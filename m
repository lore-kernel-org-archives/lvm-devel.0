From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:48 -0500
Subject: master - lvconvert: use standard wiping code
Message-ID: <201812212046.wBLKkmcc021401@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb85d5d02478a34ab6648bdbdf09a931176dee71
Commit:        fb85d5d02478a34ab6648bdbdf09a931176dee71
Parent:        9830aa207c192d6d25d6a7ab2d7186eb91b043b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:39:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

lvconvert: use standard wiping code

---
 tools/lvconvert.c |   48 +-----------------------------------------------
 1 files changed, 1 insertions(+), 47 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c260ee0..f6f94c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5225,52 +5225,6 @@ bad:
 
 }
 
-static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	struct device *dev;
-	char name[PATH_MAX];
-	int ret = 0;
-
-	if (!activate_lv(cmd, lv)) {
-		log_error("Failed to activate LV %s for zeroing.", lv->name);
-		return 0;
-	}
-
-	sync_local_dev_names(cmd);
-
-	if (dm_snprintf(name, sizeof(name), "%s%s/%s",
-			cmd->dev_dir, lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
-		goto out;
-	}
-
-	if (!(dev = dev_cache_get(cmd, name, NULL))) {
-		log_error("%s: not found: device not zeroed", name);
-		goto out;
-	}
-
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
-	if (!deactivate_lv(cmd, lv)) {
-		log_error("Failed to deactivate LV %s for zeroing.", lv->name);
-		ret = 0;
-	}
-
-	return ret;
-}
-
 static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
 				       char *key, char *val, uint32_t *block_size_sectors)
 {
@@ -5513,7 +5467,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	 * writecache block_size value matching the sector size of lv.
 	 */
 
-	if (!_writecache_zero(cmd, lv_fast)) {
+	if (!activate_and_wipe_lv(lv_fast, 0)) {
 		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
 		return 0;
 	}


