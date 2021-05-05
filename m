From: David Teigland <teigland@sourceware.org>
Date: Wed,  5 May 2021 21:20:22 +0000 (GMT)
Subject: main - blkid: simplify fs block size check
Message-ID: <20210505212022.CF831385742C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=318bb3a06b420e2ff9344138f20b879e82878866
Commit:        318bb3a06b420e2ff9344138f20b879e82878866
Parent:        71933d3496dfb21e1e39744d69f0372e202c1a1c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 5 16:15:10 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 5 16:15:10 2021 -0500

blkid: simplify fs block size check

Only the LV path name is needed for blkid query,
the step of getting a dev struct is not needed.
---
 lib/device/dev-type.c          | 10 +++++-----
 lib/device/dev-type.h          |  2 +-
 lib/metadata/integrity_manip.c |  7 +------
 tools/lvconvert.c              | 18 +++++-------------
 4 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 1b335722d..706061814 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -701,23 +701,23 @@ out:
 }
 
 #ifdef BLKID_WIPING_SUPPORT
-int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
+int get_fs_block_size(const char *pathname, uint32_t *fs_block_size)
 {
 	char *block_size_str = NULL;
 
-	if ((block_size_str = blkid_get_tag_value(NULL, "BLOCK_SIZE", dev_name(dev)))) {
+	if ((block_size_str = blkid_get_tag_value(NULL, "BLOCK_SIZE", pathname))) {
 		*fs_block_size = (uint32_t)atoi(block_size_str);
 		free(block_size_str);
-		log_debug("Found blkid BLOCK_SIZE %u for fs on %s", *fs_block_size, dev_name(dev));
+		log_debug("Found blkid BLOCK_SIZE %u for fs on %s", *fs_block_size, pathname);
 		return 1;
 	} else {
-		log_debug("No blkid BLOCK_SIZE for fs on %s", dev_name(dev));
+		log_debug("No blkid BLOCK_SIZE for fs on %s", pathname);
 		*fs_block_size = 0;
 		return 0;
 	}
 }
 #else
-int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
+int get_fs_block_size(const char *pathname, uint32_t *fs_block_size)
 {
 	log_debug("Disabled blkid BLOCK_SIZE for fs.");
 	*fs_block_size = 0;
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 45377c144..d358520df 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -100,6 +100,6 @@ int dev_is_nvme(struct dev_types *dt, struct device *dev);
 
 int dev_is_lv(struct device *dev);
 
-int get_fs_block_size(struct device *dev, uint32_t *fs_block_size);
+int get_fs_block_size(const char *pathname, uint32_t *fs_block_size);
 
 #endif
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 4fbccfb3c..c2fd7504c 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -326,7 +326,6 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 				     int lbs_4k, int lbs_512, int pbs_4k, int pbs_512)
 {
 	char pathname[PATH_MAX];
-	struct device *fs_dev;
 	uint32_t fs_block_size = 0;
 	int rv;
 
@@ -371,10 +370,6 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 			log_error("Path name too long to get LV block size %s", display_lvname(lv));
 			goto bad;
 		}
-		if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
-			log_error("Device for LV not found to check block size %s", display_lvname(lv));
-			goto bad;
-		}
 
 		/*
 		 * get_fs_block_size() returns the libblkid BLOCK_SIZE value,
@@ -387,7 +382,7 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		 * value the block size, but it's possible values are not the same
 		 * as xfs's, and do not seem to relate directly to the device LBS.
 		 */
-		rv = get_fs_block_size(fs_dev, &fs_block_size);
+		rv = get_fs_block_size(pathname, &fs_block_size);
 		if (!rv || !fs_block_size) {
 			int use_bs;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ab6892105..990a723b6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5948,7 +5948,6 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 				      uint32_t *block_size_sectors)
 {
 	char pathname[PATH_MAX];
-	struct device *fs_dev;
 	struct dm_list pvs_list;
 	struct pv_list *pvl;
 	uint32_t fs_block_size = 0;
@@ -6011,17 +6010,10 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		goto bad;
 	}
 
-	if (!sync_local_dev_names(cmd))
-		stack;
-
-	if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
-		if (test_mode()) {
-			log_print("Test mode skips checking fs block size.");
-			fs_block_size = 0;
-			goto skip_fs;
-		}
-		log_error("Device for LV not found to check block size %s", pathname);
-		goto bad;
+	if (test_mode()) {
+		log_print("Test mode skips checking fs block size.");
+		fs_block_size = 0;
+		goto skip_fs;
 	}
 
 	/*
@@ -6037,7 +6029,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	 *
 	 * With 512 LBS and 4K PBS, mkfs.xfs will use xfs sector size 4K.
 	 */
-	rv = get_fs_block_size(fs_dev, &fs_block_size);
+	rv = get_fs_block_size(pathname, &fs_block_size);
 skip_fs:
 	if (!rv || !fs_block_size) {
 		if (lbs_4k && pbs_4k && !pbs_512) {


