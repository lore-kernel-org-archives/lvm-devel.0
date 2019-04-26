From: David Teigland <teigland@sourceware.org>
Date: Fri, 26 Apr 2019 15:51:56 -0400
Subject: master - wipe_lv: initially open LV in writable mode
Message-ID: <201904261951.x3QJpuux013744@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccd13860708a1538b46c1b82b45d0ab44a26d89e
Commit:        ccd13860708a1538b46c1b82b45d0ab44a26d89e
Parent:        8fbaa6d9a5dd738a566906a23f5bbe901d80a9d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 26 14:49:27 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 26 14:49:27 2019 -0500

wipe_lv: initially open LV in writable mode

wipe_lv knows it's going to write the device, so it
can open rw from the start.  It was opening readonly,
and then dev_write needed to reopen it readwrite.
---
 lib/label/label.c       |   12 ++++++++++++
 lib/label/label.h       |    1 +
 lib/metadata/lv_manip.c |    2 +-
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index fc74272..3b9d9fd 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1272,6 +1272,18 @@ int label_scan_open_excl(struct device *dev)
 	return label_scan_open(dev);
 }
 
+int label_scan_open_rw(struct device *dev)
+{
+	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
+		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
+		log_debug("Close and reopen rw %s", dev_name(dev));
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+	}
+	dev->flags |= DEV_BCACHE_WRITE;
+	return label_scan_open(dev);
+}
+
 bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	if (!scan_bcache) {
diff --git a/lib/label/label.h b/lib/label/label.h
index 5939655..8f1f0e2 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -115,6 +115,7 @@ void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
+int label_scan_open_rw(struct device *dev);
 
 /*
  * Wrappers around bcache equivalents.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 76d18b0..6aee947 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7365,7 +7365,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	if (!label_scan_open(dev)) {
+	if (!label_scan_open_rw(dev)) {
 		log_error("Failed to open %s/%s for wiping and zeroing.", lv->vg->name, lv->name);
 		goto out;
 	}


