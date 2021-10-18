From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 17:19:28 +0000 (GMT)
Subject: main - dev-cache: skip different filesystems on dir scan
Message-ID: <20211018171928.336193858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cf4eac250ef7abd5e0961da2371294da07ab4de
Commit:        9cf4eac250ef7abd5e0961da2371294da07ab4de
Parent:        bae1083472d9c589d59f93a4e0a137cb94ba5ed0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 18 19:04:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 19:17:26 2021 +0200

dev-cache: skip different filesystems on dir scan

When scanning configured  /dev dir, avoid entring
directories with different filesystem.

This minimizes risk we will block on i.e. entring
directory with mount point.
---
 WHATS_NEW              | 1 +
 lib/device/dev-cache.c | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index d87cb7e37..0199c174e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Device scanning is skipping different filesystems.
   Print info message with too many or too large archived files.
   Reduce metadata readings during scanning phase.
   Optimize computation of crc32 check sum with multiple PVs.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d454b5b30..6d706eb1e 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1101,6 +1101,7 @@ static void _insert_dirs(struct dm_list *dirs)
 static int _insert(const char *path, const struct stat *info,
 		   int rec, int check_with_udev_db)
 {
+	static long _st_dev = -1;
 	struct stat tinfo;
 
 	if (!info) {
@@ -1111,12 +1112,20 @@ static int _insert(const char *path, const struct stat *info,
 		info = &tinfo;
 	}
 
+	if (_st_dev == -1)
+		_st_dev = info->st_dev; /* first dir device */
+
 	if (check_with_udev_db && !_device_in_udev_db(info->st_rdev)) {
 		log_very_verbose("%s: Not in udev db", path);
 		return 0;
 	}
 
 	if (S_ISDIR(info->st_mode)) {	/* add a directory */
+		if (info->st_dev != _st_dev) {
+			log_debug_devs("%s: Different filesystem in directory", path);
+			return 1;
+		}
+
 		/* check it's not a symbolic link */
 		if (lstat(path, &tinfo) < 0) {
 			log_sys_very_verbose("lstat", path);


