From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 17 Sep 2015 11:37:31 +0000 (UTC)
Subject: master - libdm: dev_node: use lstat instead of stat while removing and renaming nodes
Message-ID: <20150917113731.9D5FA609E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afdae26c71d2539a9f0dfb06b65541dedf28b5f5
Commit:        afdae26c71d2539a9f0dfb06b65541dedf28b5f5
Parent:        b5022102bbaf978cddd7ca9b27a1a12d5aeef44d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 17 13:31:34 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 17 13:37:15 2015 +0200

libdm: dev_node: use lstat instead of stat while removing and renaming nodes

When using udev, the /dev/mapper entries are symlinks - fix the code
to count with this.

This patch also fixes the dmsetup mknodes and vgmknodes to properly
repair /dev/mapper content if it sees dangling symlink in /dev/mapper.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   21 ++++++++++++++++-----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7f0e65e..b519fd5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Fix /dev/mapper handling to remove dangling entries if symlinks are found.
   Make it possible to use blank value as selection for string list report field.
 
 Version 1.02.108 - 15th September 2015
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index e1bd44e..e648dac 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1038,7 +1038,7 @@ static int _rm_dev_node(const char *dev_name, int warn_if_udev_failed)
 
 	if (!_build_dev_path(path, sizeof(path), dev_name))
 		return_0;
-	if (stat(path, &info) < 0)
+	if (lstat(path, &info) < 0)
 		return 1;
 	else if (_warn_if_op_needed(warn_if_udev_failed))
 		log_warn("Node %s was not removed by udev. "
@@ -1060,20 +1060,31 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 {
 	char oldpath[PATH_MAX];
 	char newpath[PATH_MAX];
-	struct stat info;
+	struct stat info, info2;
+	struct stat *info_block_dev;
 
 	if (!_build_dev_path(oldpath, sizeof(oldpath), old_name) ||
 	    !_build_dev_path(newpath, sizeof(newpath), new_name))
 		return_0;
 
-	if (stat(newpath, &info) == 0) {
-		if (!S_ISBLK(info.st_mode)) {
+	if (lstat(newpath, &info) == 0) {
+		if (S_ISLNK(info.st_mode)) {
+			if (stat(newpath, &info2) == 0)
+				info_block_dev = &info2;
+			else {
+				log_sys_error("stat", newpath);
+				return 0;
+			}
+		} else
+			info_block_dev = &info;
+
+		if (!S_ISBLK(info_block_dev->st_mode)) {
 			log_error("A non-block device file at '%s' "
 				  "is already present", newpath);
 			return 0;
 		}
 		else if (_warn_if_op_needed(warn_if_udev_failed)) {
-			if (stat(oldpath, &info) < 0 &&
+			if (lstat(oldpath, &info) < 0 &&
 				 errno == ENOENT)
 				/* assume udev already deleted this */
 				return 1;


