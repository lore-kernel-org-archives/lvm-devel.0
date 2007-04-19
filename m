From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 Apr 2007 02:10:42 -0000
Subject: LVM2 lib/device/dev-io.c lib/device/device.h l ...
Message-ID: <20070419021042.2013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-19 03:10:42

Modified files:
	lib/device     : dev-io.c device.h 
	lib/config     : config.c 
	.              : WHATS_NEW 

Log message:
	Add dev_read_circular, read 2 regions on same device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.595&r2=1.596

--- LVM2/lib/device/dev-io.c	2007/01/25 14:37:47	1.56
+++ LVM2/lib/device/dev-io.c	2007/04/19 02:10:41	1.57
@@ -564,6 +564,35 @@
 	return _aligned_io(&where, buffer, 0);
 }
 
+/*
+ * Read from 'dev' into 'buf', possibly in 2 distinct regions, denoted
+ * by (offset,len) and (offset2,len2).  Thus, the total size of
+ * 'buf' should be len+len2.
+ */
+int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+		      uint64_t offset2, size_t len2, void *buf)
+{
+	if (!dev_read(dev, offset, len, buf)) {
+		log_error("Read from %s failed", dev_name(dev));
+		return 0;
+	}
+
+	/*
+	 * The second region is optional, and allows for
+	 * a circular buffer on the device.
+	 */
+	if (!len2)
+		return 1;
+
+	if (!dev_read(dev, offset2, len2, buf + len)) {
+		log_error("Circular read from %s failed",
+			  dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
+
 /* FIXME If O_DIRECT can't extend file, dev_extend first; dev_truncate after.
  *       But fails if concurrent processes writing
  */
--- LVM2/lib/device/device.h	2006/05/11 18:39:24	1.32
+++ LVM2/lib/device/device.h	2007/04/19 02:10:41	1.33
@@ -78,6 +78,8 @@
 const char *dev_name(const struct device *dev);
 
 int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer);
+int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+		      uint64_t offset2, size_t len2, void *buf);
 int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer);
 int dev_append(struct device *dev, size_t len, void *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value);
--- LVM2/lib/config/config.c	2007/03/08 19:22:52	1.54
+++ LVM2/lib/config/config.c	2007/04/19 02:10:42	1.55
@@ -210,18 +210,10 @@
 			stack;
 			return 0;
 		}
-		if (!dev_read(dev, (uint64_t) offset, size, buf)) {
-			log_error("Read from %s failed", dev_name(dev));
+		if (!dev_read_circular(dev, (uint64_t) offset, size,
+				       (uint64_t) offset2, size2, buf)) {
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
 
--- LVM2/WHATS_NEW	2007/03/30 21:00:26	1.595
+++ LVM2/WHATS_NEW	2007/04/19 02:10:42	1.596
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add dev_read_circular.
   Add pvck command stub.
   Update lists of attribute characters in man pages.
   Change cling alloc policy attribute character from 'C' to l'.


