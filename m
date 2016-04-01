From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 15:10:59 +0000 (UTC)
Subject: master - dev-cache: skip VGID/LVID indexing if /sys/dev/block is not present
Message-ID: <20160401151059.A3C7261006@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42f04a0f77ee94b01d652d6c11d10e85aa46a897
Commit:        42f04a0f77ee94b01d652d6c11d10e85aa46a897
Parent:        9f28eb4c20ecb772f1b8a912c43f243d63a7e5f3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 1 17:04:11 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 17:09:15 2016 +0200

dev-cache: skip VGID/LVID indexing if /sys/dev/block is not present

/sys/dev/block is available since kernel version 2.2.26 (~ 2008):
https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-dev

The VGID/LVID indexing code relies on this feature so skip indexing
if it's not available to avoid error messages about inability to open
/sys/dev/block directory.

We're not going to provide fallback code to read the /sys/block/
instead in this case as that's not that efficient - it needs extra
reads for getting major:minor and reading partitions would also
pose further reads and that's not worth it.
---
 lib/device/dev-cache.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 84bd85b..8461f40 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -818,9 +818,8 @@ static int _dev_cache_iterate_devs_for_index(void)
 	return r;
 }
 
-static int _dev_cache_iterate_sysfs_for_index(void)
+static int _dev_cache_iterate_sysfs_for_index(const char *path)
 {
-	char path[PATH_MAX];
 	char devname[PATH_MAX];
 	DIR *d;
 	struct dirent *dirent;
@@ -830,11 +829,6 @@ static int _dev_cache_iterate_sysfs_for_index(void)
 	int partial_failure = 0;
 	int r = 0;
 
-	if (dm_snprintf(path, sizeof(path), "%sdev/block", dm_sysfs_dir()) < 0) {
-		log_error("_dev_cache_iterate_sysfs_for_index: dm_snprintf failed.");
-		return 0;
-	}
-
 	if (!(d = opendir(path))) {
 		log_sys_error("opendir", path);
 		return 0;
@@ -876,11 +870,36 @@ static int _dev_cache_iterate_sysfs_for_index(void)
 
 int dev_cache_index_devs(void)
 {
+	static int sysfs_has_dev_block = -1;
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block", dm_sysfs_dir()) < 0) {
+		log_error("dev_cache_index_devs: dm_snprintf failed.");
+		return 0;
+	}
+
+	/* Skip indexing if /sys/dev/block is not available.*/
+	if (sysfs_has_dev_block == -1) {
+		struct stat info;
+		if (stat(path, &info) == 0)
+			sysfs_has_dev_block = 1;
+		else {
+			if (errno == ENOENT) {
+				sysfs_has_dev_block = 0;
+				return 1;
+			} else {
+				log_sys_error("stat", path);
+				return 0;
+			}
+		}
+	} else if (!sysfs_has_dev_block)
+		return 1;
+
 	int with_udev = obtain_device_list_from_udev() &&
 			udev_get_library_context();
 
 	return with_udev ? _dev_cache_iterate_devs_for_index()
-			 : _dev_cache_iterate_sysfs_for_index();
+			 : _dev_cache_iterate_sysfs_for_index(path);
 }
 
 #ifdef UDEV_SYNC_SUPPORT


