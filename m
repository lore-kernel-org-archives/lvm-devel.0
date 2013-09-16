From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 16 Sep 2013 15:23:54 -0400 (EDT)
Subject: [PATCH] libdm: fix races with udev
Message-ID: <alpine.LRH.2.02.1309161523010.9077@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

libdm: fix races with udev

On newer systems (Debian 6 and newer), udev manages nodes in /dev/mapper
directory. It creates, deletes and renames the nodes according to the
state of the kernel driver.

dmsetup tries to manage nodes in /dev/mapper too, so it can race with
udev. dmsetup checks if the node was created/deleted/renamed with the stat
syscall, and skips the operation if it was. However, if udev
creates/deletes/renames the node after the stat syscall and before the
mknod/unlink/rename syscall, dmsetup reports an error.

These races can be easily provoked by inserting sleep at appropriate
places.

This patch avoids the error messages by ignoring errors that could happen
as a result of the race.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/libdm-common.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: lvm2-copy/libdm/libdm-common.c
===================================================================
--- lvm2-copy.orig/libdm/libdm-common.c	2013-09-16 18:24:07.000000000 +0200
+++ lvm2-copy/libdm/libdm-common.c	2013-09-16 19:15:12.000000000 +0200
@@ -966,7 +966,9 @@ static int _add_dev_node(const char *dev
 
 	(void) dm_prepare_selinux_context(path, S_IFBLK);
 	old_mask = umask(0);
-	if (mknod(path, S_IFBLK | mode, dev) < 0) {
+
+	/* The node may already have been created by udev. So ignore EEXIST. */
+	if (mknod(path, S_IFBLK | mode, dev) < 0 && errno != EEXIST) {
 		log_error("%s: mknod for %s failed: %s", path, dev_name, strerror(errno));
 		umask(old_mask);
 		(void) dm_prepare_selinux_context(NULL, 0);
@@ -998,7 +1000,8 @@ static int _rm_dev_node(const char *dev_
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
-	if (unlink(path) < 0) {
+	/* udev may already have deleted the node. Ignore ENOENT. */
+	if (unlink(path) < 0 && errno != ENOENT) {
 		log_error("Unable to unlink device node for '%s'", dev_name);
 		return 0;
 	}
@@ -1054,7 +1057,8 @@ static int _rename_dev_node(const char *
 			 "Falling back to direct node rename.",
 			 oldpath, newpath);
 
-	if (rename(oldpath, newpath) < 0) {
+	/* udev may already have renamed the node. Ignore ENOENT. */
+	if (rename(oldpath, newpath) < 0 && errno != ENOENT) {
 		log_error("Unable to rename device node from '%s' to '%s'",
 			  old_name, new_name);
 		return 0;


