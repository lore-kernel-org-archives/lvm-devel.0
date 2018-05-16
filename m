From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 May 2018 15:50:47 -0400
Subject: master - scan: fix missing close in lib
Message-ID: <201805161950.w4GJol54027053@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28d35e5c590a01a196ce5a9a1239921921519809
Commit:        28d35e5c590a01a196ce5a9a1239921921519809
Parent:        64dd656ef7943f9991c83802dfa5f762c902e1fb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 16 13:24:00 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 16 14:48:30 2018 -0500

scan: fix missing close in lib

lib was using dev_test_excl which wasn't closing the device.
Switch code to new io layer with excl open.
Also use exclusive open in some other places.
---
 lib/label/label.c              |    8 +++++++-
 lib/label/label.h              |    1 +
 lib/metadata/metadata-liblvm.c |   13 +------------
 lib/metadata/metadata.c        |    2 +-
 tools/toollib.c                |    2 +-
 5 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 40537d1..b9227f5 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -114,7 +114,7 @@ int label_remove(struct device *dev)
 
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
-	if (!label_scan_open(dev)) {
+	if (!label_scan_open_excl(dev)) {
 		log_error("Failed to open device %s", dev_name(dev));
 		return 0;
 	}
@@ -977,6 +977,12 @@ int label_scan_open(struct device *dev)
 	return 1;
 }
 
+int label_scan_open_excl(struct device *dev)
+{
+	dev->flags |= DEV_BCACHE_EXCL;
+	return label_scan_open(dev);
+}
+
 bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	if (!scan_bcache) {
diff --git a/lib/label/label.h b/lib/label/label.h
index 0ef1d83..3d8882f 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -114,6 +114,7 @@ int label_read_sector(struct device *dev, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
+int label_scan_open_excl(struct device *dev);
 
 /*
  * Wrappers around bcache equivalents.
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index df4fdd9..ffd07a5 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -227,13 +227,12 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	/*
 	 * This test will fail if the device belongs to an MD array.
 	 */
-	if (!dev_test_excl(dev)) {
+	if (!label_scan_open_excl(dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",
 			  name);
 		goto out;
 	}
-	dev_close(dev);
 
 	if (!wipe_known_signatures(cmd, dev, name,
 				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
@@ -578,16 +577,6 @@ static int _pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	// FIXME: why is this called if info is not used?
-	//info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
-
-	if (!dev_test_excl(dev)) {
-		/* FIXME Detect whether device-mapper is still using the device */
-		log_error("Can't open %s exclusively - not removing. "
-			  "Mounted filesystem?", dev_name(dev));
-		goto out;
-	}
-
 	/* Wipe existing label(s) */
 	if (!label_remove(dev)) {
 		log_error("Failed to wipe existing label(s) on %s", pv_name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1636026..1cbaf95 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1413,7 +1413,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 	struct device *dev = pv->dev;
 	const char *pv_name = dev_name(dev);
 
-	if (!label_scan_open(dev)) {
+	if (!label_scan_open_excl(dev)) {
 		log_error("%s not opened: device not written", pv_name);
 		return 0;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index afd8060..0fc86cf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5785,7 +5785,7 @@ do_command:
 
 		pv_name = pd->name;
 
-		label_scan_open(pd->dev);
+		label_scan_open_excl(pd->dev);
 
 		log_debug("Creating a new PV on %s.", pv_name);
 


