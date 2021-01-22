From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:04 +0000 (GMT)
Subject: main - filters: avoid duplicated //
Message-ID: <20210122151004.D327D398D000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce6e74f485cb1fb36a4c1c35d1bd3262b77954de
Commit:        ce6e74f485cb1fb36a4c1c35d1bd3262b77954de
Parent:        5485ec10e2b592f48f5208d8b5e3cf5e0f0eb70d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 20 00:41:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

filters: avoid duplicated //

sysfs_dir already goes with '/sys/'.
---
 lib/filters/filter-mpath.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 85d1625f6..889a2dd96 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -60,7 +60,7 @@ static const char *_get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
 	char path[PATH_MAX];
 	int size;
 
-	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d", sysfs_dir,
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d", sysfs_dir,
 			(int) MAJOR(devno), (int) MINOR(devno)) < 0) {
 		log_error("Sysfs path string is too long.");
 		return NULL;
@@ -106,7 +106,7 @@ static int _get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname,
 {
 	char path[PATH_MAX], buffer[64];
 
-	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0) {
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", sysfs_dir, kname) < 0) {
 		log_error("Sysfs path string is too long.");
 		return 0;
 	}
@@ -215,7 +215,7 @@ static int _native_dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 	}
 
-	if (dm_snprintf(path, sizeof(path), "%s/block/%s/holders", sysfs_dir, name) < 0) {
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/holders", sysfs_dir, name) < 0) {
 		log_warn("Sysfs path to check mpath is too long.");
 		return 0;
 	}


