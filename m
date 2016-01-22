From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Jan 2016 13:20:42 +0000 (UTC)
Subject: master - device: also cache device size
Message-ID: <20160122132042.ACD2260C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d090d6574e455625ad4e2a1a6f3d93f5c663b097
Commit:        d090d6574e455625ad4e2a1a6f3d93f5c663b097
Parent:        dc388e0c7af967568527dd1bccb0361ca668f09b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 15 16:41:27 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 22 14:13:34 2016 +0100

device: also cache device size

Add "size" and "size_seqno" to struct device to cache device's size
and also to control its lifetime - the cached value is valid as long
as the global _dev_size_seqno is equal to the device's size_seqno,
otherwise we need to get the size again and cache the new value.

This patch also adds new dev_size_seqno_inc() fn for the appropriate
parts of the code to increment current global value of _dev_size_seqno
and hence to cause all currently cached values for device sizes to
be invalidated.

The device size is now cached because we're planning to reuse this
information for further checks and we want to avoid checking it more
than necessary to save resources.
---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   26 +++++++++++++++++++++++++-
 lib/device/device.h |    9 +++++++++
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6342041..f6fd967 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Cache device sizes internally.
   Restore support for command breaking in process_each_lv_in_vg() (2.02.118).
   Use correct mempool when process_each_lv_in_vg() (2.02.118).
   Fix lvm.8 man to show again prohibited suffixes.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 8c58786..f8b24bf 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -54,6 +54,7 @@
 #endif
 
 static DM_LIST_INIT(_open_devices);
+static unsigned _dev_size_seqno = 1;
 
 /*-----------------------------------------------------------------
  * The standard io loop that keeps submitting an io until it's
@@ -271,11 +272,18 @@ out:
 	return r;
 }
 
-static int _dev_get_size_file(const struct device *dev, uint64_t *size)
+static int _dev_get_size_file(struct device *dev, uint64_t *size)
 {
 	const char *name = dev_name(dev);
 	struct stat info;
 
+	if (dev->size_seqno == _dev_size_seqno) {
+		log_very_verbose("%s: using cached size %" PRIu64 " sectors",
+				 name, dev->size);
+		*size = dev->size;
+		return 1;
+	}
+
 	if (stat(name, &info)) {
 		log_sys_error("stat", name);
 		return 0;
@@ -283,6 +291,8 @@ static int _dev_get_size_file(const struct device *dev, uint64_t *size)
 
 	*size = info.st_size;
 	*size >>= SECTOR_SHIFT;	/* Convert to sectors */
+	dev->size = *size;
+	dev->size_seqno = _dev_size_seqno;
 
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
 
@@ -293,6 +303,13 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 {
 	const char *name = dev_name(dev);
 
+	if (dev->size_seqno == _dev_size_seqno) {
+		log_very_verbose("%s: using cached size %" PRIu64 " sectors",
+				 name, dev->size);
+		*size = dev->size;
+		return 1;
+	}
+
 	if (!dev_open_readonly(dev))
 		return_0;
 
@@ -304,6 +321,9 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	}
 
 	*size >>= BLKSIZE_SHIFT;	/* Convert to sectors */
+	dev->size = *size;
+	dev->size_seqno = _dev_size_seqno;
+
 	if (!dev_close(dev))
 		log_sys_error("close", name);
 
@@ -373,6 +393,10 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
 /*-----------------------------------------------------------------
  * Public functions
  *---------------------------------------------------------------*/
+void dev_size_seqno_inc(void)
+{
+	_dev_size_seqno++;
+}
 
 int dev_get_size(struct device *dev, uint64_t *size)
 {
diff --git a/lib/device/device.h b/lib/device/device.h
index a1ba80c..6b01fb6 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -62,6 +62,8 @@ struct device {
 	int block_size;
 	int read_ahead;
 	uint32_t flags;
+	unsigned size_seqno;
+	uint64_t size;
 	uint64_t end;
 	struct dm_list open_list;
 	struct dev_ext ext;
@@ -91,6 +93,13 @@ struct dev_ext *dev_ext_get(struct device *dev);
 int dev_ext_release(struct device *dev);
 
 /*
+ * Increment current dev_size_seqno.
+ * This is used to control lifetime
+ * of cached device size.
+ */
+void dev_size_seqno_inc(void);
+
+/*
  * All io should use these routines.
  */
 int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);


