From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Aug 2018 11:39:46 -0400
Subject: 2018-06-01-stable - vgcreate: close exclusive fd after pvcreate
Message-ID: <201808011539.w71Fdk9a012941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a75eb8d74c367b88d5b323d5dfb2e6556f2ad680
Commit:        a75eb8d74c367b88d5b323d5dfb2e6556f2ad680
Parent:        12dfd0ed02e003e21072798d17dcec4a80fc466d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 1 10:26:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 1 10:26:28 2018 -0500

vgcreate: close exclusive fd after pvcreate

When vgcreate does an automatic pvcreate, it opens the
dev with O_EXCL to ensure no other subsystem is using
the device.  This exclusive fd remained in bcache and
prevented activation parts of lvm from using the dev.

This appeared with vgcreate of a sanlock VG because of
the unique combination where the dev is not yet a PV,
so pvcreate is needed, and the vgcreate also creates
and activates an internal LV for sanlock.

Fix this by closing the exclusive fd after it's used
by pvcreate so that it won't interfere with other
bits of lvm that may try to use the device.
---
 lib/label/label.c |    6 +++---
 tools/toollib.c   |    7 +++++++
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ac37713..bafa543 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1190,7 +1190,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
@@ -1236,7 +1236,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
@@ -1282,7 +1282,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
diff --git a/tools/toollib.c b/tools/toollib.c
index 413937f..6ae78bd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5872,6 +5872,13 @@ do_command:
 					pd->name);
 	}
 
+	/*
+	 * Don't keep devs open excl in bcache because the excl will prevent
+	 * using that dev elsewhere.
+	 */
+	dm_list_iterate_items(devl, &rescan_devs)
+		label_scan_invalidate(devl->dev);
+
 	dm_list_iterate_items(pd, &pp->arg_fail)
 		log_debug("%s: command failed for %s.",
 			  cmd->command->name, pd->name);


