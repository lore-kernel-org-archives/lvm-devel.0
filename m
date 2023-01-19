From: David Teigland <teigland@sourceware.org>
Date: Thu, 19 Jan 2023 17:57:05 +0000 (GMT)
Subject: main - lvresize: only resize crypt when fs resize is enabled
Message-ID: <20230119175705.E9A9A3858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bb55765286dc8e4f0000957d85a6b8ee2752852
Commit:        3bb55765286dc8e4f0000957d85a6b8ee2752852
Parent:        92199ad0b98586182a52e2f8cd82c06336e306f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 19 11:36:51 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 19 11:52:14 2023 -0600

lvresize: only resize crypt when fs resize is enabled

There were a couple of cases where lvresize, without --fs resize,
was resizing the crypt layer above the LV.  Resizing the crypt
layer should only be done when fs resizing is enabled (even if the
fs is already small enough due to being independently reduced.)

Also, check the size of the crypt device to see if it's already
been reduced independently, and skip the cryptsetup resize if
it's not needed.
---
 lib/device/filesystem.c         | 13 +++++++++++++
 lib/device/filesystem.h         |  1 +
 lib/metadata/lv_manip.c         | 18 +++++++++++++++++-
 test/shell/lvresize-fs-crypt.sh |  7 ++++++-
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 61e4d805e..b4c43a626 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -22,6 +22,7 @@
 
 #include <dirent.h>
 #include <mntent.h>
+#include <sys/ioctl.h>
 
 static const char *_lvresize_fs_helper_path;
 
@@ -105,6 +106,7 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 	struct fs_info info;
 	FILE *fme = NULL;
 	struct mntent *me;
+	int fd;
 	int ret;
 
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir,
@@ -150,6 +152,17 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 		log_print("File system found on crypt device %s on LV %s.",
 			  crypt_path, display_lvname(lv));
 
+		if ((fd = open(crypt_path, O_RDONLY)) < 0) {
+			log_error("Failed to open crypt path %s", crypt_path);
+			return 0;
+		}
+		if (ioctl(fd, BLKGETSIZE64, &info.crypt_dev_size_bytes) < 0) {
+			log_error("Failed to get crypt device size %s", crypt_path);
+			close(fd);
+			return 0;
+		}
+		close(fd);
+
 		if (!fs_get_blkid(crypt_path, &info)) {
 			log_error("No file system info from blkid for dm-crypt device %s on LV %s.",
 				  crypt_path, display_lvname(lv));
diff --git a/lib/device/filesystem.h b/lib/device/filesystem.h
index 7a34d2ae0..fd1af0416 100644
--- a/lib/device/filesystem.h
+++ b/lib/device/filesystem.h
@@ -25,6 +25,7 @@ struct fs_info {
 	uint64_t fs_last_byte; /* last byte on the device used by the fs */
 	uint32_t crypt_offset_bytes; /* offset in bytes of crypt data on LV */
 	dev_t crypt_devt; /* dm-crypt device between the LV and FS */
+	uint64_t crypt_dev_size_bytes;
 
 	unsigned nofs:1;
 	unsigned unmounted:1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cb7f26069..cfb118f11 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6408,7 +6408,23 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 	 * but the crypt dev over the LV should be shrunk to correspond with
 	 * the LV size, so that the FS does not see an incorrect device size.
 	 */
-	if (!fsinfo.needs_reduce && fsinfo.needs_crypt && !test_mode()) {
+	if (!fsinfo.needs_reduce && fsinfo.needs_crypt) {
+		/* Check if the crypt device is already sufficiently reduced. */
+		if (fsinfo.crypt_dev_size_bytes <= newsize_bytes_fs) {
+			log_print("crypt device is already reduced to %llu bytes.",
+				  (unsigned long long)fsinfo.crypt_dev_size_bytes);
+			ret = 1;
+			goto out;
+		}
+		if (!strcmp(lp->fsopt, "checksize")) {
+			log_error("crypt reduce is required (see --resizefs or cryptsetup resize.)");
+			ret = 0;
+			goto out;
+		}
+		if (test_mode()) {
+			ret = 1;
+			goto_out;
+		}
 		ret = crypt_resize_script(cmd, lv, &fsinfo, newsize_bytes_fs);
 		goto out;
 	}
diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
index 61a6de022..4bef771dc 100644
--- a/test/shell/lvresize-fs-crypt.sh
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -151,7 +151,12 @@ mount /dev/mapper/$cr "$mount_dir"
 # this lvresize will not resize the fs (which is already reduced
 # to smaller than the requested LV size), but lvresize will use
 # the helper to resize the crypt dev before resizing the LV.
-lvresize -L-100M $vg/$lv
+# Using --fs resize is required to allow lvresize to look above
+# the lv at crypt&fs layers for potential resizing.  Without
+# --fs resize, lvresize fails because it sees that crypt resize
+# is needed and --fs resize is needed to enable that.
+not lvresize -L-100 $vg/$lv
+lvresize -L-100M --fs resize $vg/$lv
 check lv_field $vg/$lv lv_size "356.00m"
 df --output=size "$mount_dir" |tee df2
 not diff df1 df2

