From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 May 2019 14:33:46 -0400
Subject: master - scan: remove comments about lvmetad
Message-ID: <201905021833.x42IXkaL008686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99de816a1bb6414e4611030c8d83766b1ff3cd65
Commit:        99de816a1bb6414e4611030c8d83766b1ff3cd65
Parent:        81735b46d9c7ab8f2dd27835d2a43cc5ad705c86
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 2 13:32:30 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 2 13:32:30 2019 -0500

scan: remove comments about lvmetad

---
 lib/label/label.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 31b290b..b999f87 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1024,8 +1024,6 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 {
 	struct device_list *devl;
 
-	/* FIXME: get rid of this, it's only needed for lvmetad in which
-	   case we should be setting up bcache in one place. */
 	if (!scan_bcache) {
 		if (!_setup_bcache(0))
 			return 0;
@@ -1227,14 +1225,6 @@ out:
 	return ret;
 }
 
-/*
- * This is only needed when commands are using lvmetad, in which case they
- * don't do an initial label_scan, but may later need to rescan certain devs
- * from disk and call this function.  FIXME: is there some better number to
- * choose here?  How should we predict the number of devices that might need
- * scanning when using lvmetad?
- */
-
 int label_scan_setup_bcache(void)
 {
 	if (!scan_bcache) {
@@ -1293,7 +1283,7 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		/* This is not often needed, perhaps only with lvmetad. */
+		/* This is not often needed. */
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for reading@%llu length %u.",
 				  dev_name(dev), (unsigned long long)start, (uint32_t)len);
@@ -1333,7 +1323,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		/* This is not often needed, perhaps only with lvmetad. */
+		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",
@@ -1379,7 +1369,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		/* This is not often needed, perhaps only with lvmetad. */
+		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",
@@ -1428,7 +1418,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		/* This is not often needed, perhaps only with lvmetad. */
+		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for writing at %llu length %u.",


