From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:55 -0400
Subject: master - lvmetad: more fixes related to bcache
Message-ID: <201804231355.w3NDtt8t001852@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9b0aa5c178a6d8bb708ed35f833c648f7437ae3
Commit:        a9b0aa5c178a6d8bb708ed35f833c648f7437ae3
Parent:        e351f8bc66d49fecaa0ab78f8413d50a4674604a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 9 11:39:12 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

lvmetad: more fixes related to bcache

Need to open devs prior to bcache io.
---
 lib/label/label.c       |   25 +++++++++++++++++--------
 lib/metadata/metadata.c |   12 ++++++++++++
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 9401067..14a7e90 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -515,7 +515,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 		bb = NULL;
 
 		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
-			log_error("Scan failed to read %s.", dev_name(devl->dev));
+			log_debug_devs("Scan failed to read %s.", dev_name(devl->dev));
 			scan_failed_count++;
 			scan_failed = 1;
 			lvmcache_del_dev(devl->dev);
@@ -525,7 +525,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 			ret = _process_block(devl->dev, bb, &is_lvm_device);
 
 			if (!ret && is_lvm_device) {
-				log_error("Scan failed to process %s", dev_name(devl->dev));
+				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
 				scan_failed_count++;
 				scan_failed = 1;
 				lvmcache_del_dev(devl->dev);
@@ -893,8 +893,11 @@ bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_read_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
-		return false;
+		/* This is not often needed, perhaps only with lvmetad. */
+		if (!label_scan_open(dev)) {
+			log_error("dev_read_bytes %s cannot open dev", dev_name(dev));
+			return false;
+		}
 	}
 
 	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
@@ -924,8 +927,11 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_write_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
-		return false;
+		/* This is not often needed, perhaps only with lvmetad. */
+		if (!label_scan_open(dev)) {
+			log_error("dev_write_bytes %s cannot open dev", dev_name(dev));
+			return false;
+		}
 	}
 
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
@@ -954,8 +960,11 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_write_zeros %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
-		return false;
+		/* This is not often needed, perhaps only with lvmetad. */
+		if (!label_scan_open(dev)) {
+			log_error("dev_write_zeros %s cannot open dev", dev_name(dev));
+			return false;
+		}
 	}
 
 	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len)) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 462c391..8cb06be 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3809,6 +3809,18 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				release_vg(correct_vg);
 				return_NULL;
 			}
+
+			/*
+		 	 * When a command reads the vg from lvmetad, and then
+			 * writes the vg, the write path does some disk reads
+		 	 * of the devs.
+		 	 * FIXME: when a command is going to write the vg,
+		 	 * we should just read the vg from disk entirely
+		 	 * and skip reading it from lvmetad.
+		 	 */
+			dm_list_iterate_items(pvl, &correct_vg->pvs)
+				label_scan_open(pvl->pv->dev);
+
 		}
 
 		return correct_vg;


