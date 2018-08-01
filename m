From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Aug 2018 12:28:50 -0400
Subject: master - vgcreate: close exclusive fd after pvcreate
Message-ID: <201808011628.w71GSoRT021639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=763219611c30d6870013b7cb84d66ec67a5dd7ec
Commit:        763219611c30d6870013b7cb84d66ec67a5dd7ec
Parent:        aa464aa2f6b438092a50ca20f149557550c7147b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 1 10:26:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 1 11:22:23 2018 -0500

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
index d2c8685..9fe11f6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1185,7 +1185,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
@@ -1231,7 +1231,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
@@ -1277,7 +1277,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		return false;
 	}
 
-	if (!(dev->flags & DEV_BCACHE_WRITE)) {
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
diff --git a/tools/toollib.c b/tools/toollib.c
index 36ae125..85d44b3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5782,6 +5782,13 @@ do_command:
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


