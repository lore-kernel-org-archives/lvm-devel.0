From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 09:58:21 +0000 (UTC)
Subject: master - libdm: fix races with udev
Message-ID: <20131017095821.69B8E61313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed30145f4ad030b751b529590ab0f6f41afa17bc
Commit:        ed30145f4ad030b751b529590ab0f6f41afa17bc
Parent:        3ac7f927e1e587089bbbbae04ecad1906af55485
Author:        Mikulas Patocka <mpatocka@redhat.com>
AuthorDate:    Mon Sep 16 15:23:54 2013 -0400
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 11:57:33 2013 +0200

libdm: fix races with udev

On modern systems udev manages nodes in /dev/mapper directory.
It creates, deletes and renames the nodes according to the
state of the kernel driver.

When the dmsetup is compiled without udev support (--enable-udev_sync)
and runs on the system with running udevd it tries to manage nodes in
/dev/mapper too, so it can race with udev.
dmsetup checks if the node was created/deleted/renamed with the stat
syscall, and skips the operation if it was. However, if udev
creates/deletes/renames the node after the stat syscall and before the
mknod/unlink/rename syscall, dmsetup reports an error.

Since in the system everything happened as expected, skip reporting
error for such case.

These races can be easily provoked by inserting sleep at appropriate
places.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b59a39e..6742ad4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.83
 ==================================
+  Skip race errors when non-udev dmsetup build runs on udev-enabled system.
   Skip error message when holders are not present in sysfs.
   Use __linux__ instead of linux define to make libdevmapper.h C compliant.
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 52be405..9a52f2e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -966,7 +966,9 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 
 	(void) dm_prepare_selinux_context(path, S_IFBLK);
 	old_mask = umask(0);
-	if (mknod(path, S_IFBLK | mode, dev) < 0) {
+
+	/* The node may already have been created by udev. So ignore EEXIST. */
+	if (mknod(path, S_IFBLK | mode, dev) < 0 && errno != EEXIST) {
 		log_error("%s: mknod for %s failed: %s", path, dev_name, strerror(errno));
 		umask(old_mask);
 		(void) dm_prepare_selinux_context(NULL, 0);
@@ -998,7 +1000,8 @@ static int _rm_dev_node(const char *dev_name, int warn_if_udev_failed)
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
-	if (unlink(path) < 0) {
+	/* udev may already have deleted the node. Ignore ENOENT. */
+	if (unlink(path) < 0 && errno != ENOENT) {
 		log_error("Unable to unlink device node for '%s'", dev_name);
 		return 0;
 	}
@@ -1054,7 +1057,8 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 			 "Falling back to direct node rename.",
 			 oldpath, newpath);
 
-	if (rename(oldpath, newpath) < 0) {
+	/* udev may already have renamed the node. Ignore ENOENT. */
+	if (rename(oldpath, newpath) < 0 && errno != ENOENT) {
 		log_error("Unable to rename device node from '%s' to '%s'",
 			  old_name, new_name);
 		return 0;


