From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:41 +0000 (GMT)
Subject: master - writecache: attach while active using fs block size
Message-ID: <20200610173141.95186388F070@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d15c466f9557004fa003b8986b82deca25cc5aaf
Commit:        d15c466f9557004fa003b8986b82deca25cc5aaf
Parent:        1ee42f13915d852008b1e7b777edee766413ef89
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 30 16:25:15 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:15:34 2020 -0500

writecache: attach while active using fs block size

Use libblkid to detect sector/block size of the fs on the LV.
Use this to choose a compatible writecache block size.
Enable attaching writecache to an active LV.
---
 tools/lvconvert.c | 177 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 164 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 757e708ff..b25fa1704 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5433,7 +5433,166 @@ static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
 	return lv_wcorig;
 }
 
-#define DEFAULT_WRITECACHE_BLOCK_SIZE_SECTORS 8 /* 4K */
+/*
+ * Currently only supports writecache block sizes 512 and 4096.
+ * This could be expanded later.
+ */
+static int _set_writecache_block_size(struct cmd_context *cmd,
+				      struct logical_volume *lv,
+				      uint32_t *block_size_sectors)
+{
+	char pathname[PATH_MAX];
+	struct device *fs_dev;
+	struct dm_list pvs;
+	struct pv_list *pvl;
+	uint32_t fs_block_size = 0;
+	uint32_t block_size_setting = 0;
+	uint32_t block_size = 0;
+	int lbs_unknown = 0, lbs_4k = 0, lbs_512 = 0;
+	int pbs_unknown = 0, pbs_4k = 0, pbs_512 = 0;
+	int rv;
+
+	/* This is set if the user specified a writecache block size on the command line. */
+	if (*block_size_sectors)
+		block_size_setting = *block_size_sectors * 512;
+
+	dm_list_init(&pvs);
+
+	if (!get_pv_list_for_lv(cmd->mem, lv, &pvs)) {
+		log_error("Failed to build list of PVs for %s.", display_lvname(lv));
+		goto_bad;
+	}
+
+	dm_list_iterate_items(pvl, &pvs) {
+		unsigned int pbs = 0;
+		unsigned int lbs = 0;
+
+		if (!dev_get_direct_block_sizes(pvl->pv->dev, &pbs, &lbs)) {
+			lbs_unknown++;
+			pbs_unknown++;
+			continue;
+		}
+
+		if (lbs == 4096)
+			lbs_4k++;
+		else if (lbs == 512)
+			lbs_512++;
+		else
+			lbs_unknown++;
+
+		if (pbs == 4096)
+			pbs_4k++;
+		else if (pbs == 512)
+			pbs_512++;
+		else
+			pbs_unknown++;
+	}
+
+	if (lbs_4k && lbs_512) {
+		log_error("Writecache requires consistent logical block size for LV devices.");
+		goto_bad;
+	}
+
+	if (lbs_4k && block_size_setting && (block_size_setting < 4096)) {
+		log_error("Writecache block size %u not allowed with device logical block size 4096.",
+			  block_size_setting);
+		goto_bad;
+	}
+
+	if (dm_snprintf(pathname, sizeof(pathname), "%s%s/%s", cmd->dev_dir,
+			lv->vg->name, lv->name) < 0) {
+		log_error("Path name too long to get LV block size %s", display_lvname(lv));
+		goto_bad;
+	}
+
+	if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
+		log_error("Device for LV not found to check block size %s", display_lvname(lv));
+		goto_bad;
+	}
+
+	/*
+	 * get_fs_block_size() returns the libblkid BLOCK_SIZE value,
+	 * where libblkid has fs-specific code to set BLOCK_SIZE to the
+	 * value we need here.
+	 *
+	 * The term "block size" here may not equate directly to what the fs
+	 * calls the block size, e.g. xfs calls this the sector size (and
+	 * something different the block size); while ext4 does call this
+	 * value the block size, but it's possible values are not the same
+	 * as xfs's, and do not seem to relate directly to the device LBS.
+	 *
+	 * With 512 LBS and 4K PBS, mkfs.xfs will use xfs sector size 4K.
+	 */
+	rv = get_fs_block_size(fs_dev, &fs_block_size);
+	if (!rv || !fs_block_size) {
+		if (lbs_4k && pbs_4k && !pbs_512) {
+			block_size = 4096;
+		} else if (lbs_512 && pbs_512 && !pbs_4k) {
+			block_size = 512;
+		} else if (lbs_512 && pbs_4k) {
+			if (block_size_setting == 4096)
+				block_size = 4096;
+			else
+				block_size = 512;
+		} else {
+			block_size = 512;
+		}
+
+		if (block_size_setting && (block_size_setting != block_size)) {
+			log_error("Cannot use writecache block size %u with unknown file system block size, logical block size %u, physical block size %u.",
+				  block_size_setting, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+			goto bad;
+		}
+
+		if (block_size != 512) {
+			log_warn("WARNING: unable to detect a file system block size on %s", display_lvname(lv));
+			log_warn("WARNING: using a writecache block size larger than the file system block size may corrupt the file system.");
+			if (!arg_is_set(cmd, yes_ARG) &&
+			    yes_no_prompt("Use writecache block size %u? [y/n]: ", block_size) == 'n')  {
+				log_error("Conversion aborted.");
+				goto bad;
+			}
+		}
+
+		log_print("Using writecache block size %u for unknown file system block size, logical block size %u, physical block size %u.",
+			 block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+		goto out;
+	}
+
+	if (!block_size_setting) {
+		/* User did not specify a block size, so choose according to fs block size. */
+		if (fs_block_size == 4096)
+			block_size = 4096;
+		else if (fs_block_size == 512)
+			block_size = 512;
+		else if (fs_block_size > 4096)
+			block_size = 4096;
+		else if (fs_block_size < 4096)
+			block_size = 512;
+		else
+			goto_bad;
+	} else {
+		if (block_size_setting <= fs_block_size)
+			block_size = block_size_setting;
+		else {
+			log_error("Writecache block size %u cannot be larger than file system block size %u.",
+				  block_size_setting, fs_block_size);
+			goto_bad;
+		}
+	}
+
+out:
+	if (block_size == 512)
+		*block_size_sectors = 1;
+	else if (block_size == 4096)
+		*block_size_sectors = 8;
+	else
+		goto_bad;
+
+	return 1;
+bad:
+	return 0;
+}
 
 static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 					struct logical_volume *lv,
@@ -5444,7 +5603,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	struct logical_volume *lv_fast;
 	struct writecache_settings settings;
 	const char *fast_name;
-	uint32_t block_size_sectors;
+	uint32_t block_size_sectors = 0;
 	char *lockd_fast_args = NULL;
 	char *lockd_fast_name = NULL;
 	struct id lockd_fast_id;
@@ -5472,16 +5631,6 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
-	/*
-	 * To permit this we need to check the block size of the fs using lv
-	 * (recently in libblkid) so that we can use a matching writecache
-	 * block size.  We also want to do that if the lv is inactive.
-	 */
-	if (lv_is_active(lv)) {
-		log_error("LV %s must be inactive to attach writecache.", display_lvname(lv));
-		goto bad;
-	}
-
 	/* fast LV shouldn't generally be active by itself, but just in case. */
 	if (lv_info(cmd, lv_fast, 1, NULL, 0, 0)) {
 		log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
@@ -5489,13 +5638,15 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	}
 
 	memset(&settings, 0, sizeof(settings));
-	block_size_sectors = DEFAULT_WRITECACHE_BLOCK_SIZE_SECTORS;
 
 	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {
 		log_error("Invalid writecache settings.");
 		goto bad;
 	}
 
+	if (!_set_writecache_block_size(cmd, lv, &block_size_sectors))
+		goto_bad;
+
 	if (!arg_is_set(cmd, yes_ARG) &&
 	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
 		log_error("Conversion aborted.");


