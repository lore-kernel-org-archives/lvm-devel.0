From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 17 Apr 2007 13:23:51 -0400
Subject: [PATCH 1/2] add dev_read2 support function
Message-ID: <1176830631.4070.19.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add dev_read2 - read from 2 regions on the same device.
Should not change functional behavior.


Index: LVM2/lib/device/dev-io.c
===================================================================
--- LVM2.orig/lib/device/dev-io.c	2007-01-25 09:37:47.000000000 -0500
+++ LVM2/lib/device/dev-io.c	2007-04-17 12:34:49.000000000 -0400
@@ -564,6 +564,36 @@ int dev_read(struct device *dev, uint64_
 	return _aligned_io(&where, buffer, 0);
 }
 
+/*
+ * Read from 'dev' into 'buf', possibly in 2 distinct regions, denoted
+ * by (offset,len) and (offset2,len2).  Thus, the total size of
+ * 'buf' should be len+len2.
+ */
+int dev_read2(struct device *dev, uint64_t offset, size_t len,
+	      uint64_t offset2, size_t len2, void *buf)
+{
+	if (!dev_read(dev, (uint64_t) offset, len, buf)) {
+		log_error("Read from %s failed", dev_name(dev));
+		stack;
+		return 0;
+	}
+
+	/*
+	 * The second region is optional, and allows for
+	 * a circular buffer on the device.
+	 */
+	if (len2) {
+		if (!dev_read(dev, (uint64_t) offset2, len2,
+			      buf + len)) {
+			log_error("Circular read from %s failed",
+				  dev_name(dev));
+			stack;
+			return 0;
+		}
+	}
+	return 1;
+}
+
 /* FIXME If O_DIRECT can't extend file, dev_extend first; dev_truncate after.
  *       But fails if concurrent processes writing
  */
Index: LVM2/lib/device/device.h
===================================================================
--- LVM2.orig/lib/device/device.h	2006-05-11 14:39:24.000000000 -0400
+++ LVM2/lib/device/device.h	2007-04-17 12:33:38.000000000 -0400
@@ -78,6 +78,8 @@ int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
 int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer);
+int dev_read2(struct device *dev, uint64_t offset, size_t len,
+	      uint64_t offset2, size_t len2, void *buf);
 int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer);
 int dev_append(struct device *dev, size_t len, void *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value);
Index: LVM2/lib/config/config.c
===================================================================
--- LVM2.orig/lib/config/config.c	2007-03-08 14:22:52.000000000 -0500
+++ LVM2/lib/config/config.c	2007-04-17 12:40:30.000000000 -0400
@@ -210,18 +210,10 @@ int read_config_fd(struct config_tree *c
 			stack;
 			return 0;
 		}
-		if (!dev_read(dev, (uint64_t) offset, size, buf)) {
-			log_error("Read from %s failed", dev_name(dev));
+		if (!dev_read2(dev, (uint64_t) offset, size,
+			       (uint64_t) offset2, size2, buf)) {
 			goto out;
 		}
-		if (size2) {
-			if (!dev_read(dev, (uint64_t) offset2, size2,
-				      buf + size)) {
-				log_error("Circular read from %s failed",
-					  dev_name(dev));
-				goto out;
-			}
-		}
 		p->fb = buf;
 	}
 
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-04-17 12:45:02.000000000 -0400
+++ LVM2/WHATS_NEW	2007-04-17 12:45:18.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add dev_read2.
   Add pvck command stub.
   Update lists of attribute characters in man pages.
   Change cling alloc policy attribute character from 'C' to l'.



