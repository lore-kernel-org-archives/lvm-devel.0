From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2007 00:30:30 -0000
Subject: LVM2/lib/device dev-md.c
Message-ID: <20071024003030.20029.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-10-24 00:30:30

Modified files:
	lib/device     : dev-md.c 

Log message:
	refactor dev-md.c, separating out the magic number detection

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/device/dev-md.c	2007/08/20 20:55:25	1.5
+++ LVM2/lib/device/dev-md.c	2007/10/24 00:30:30	1.6
@@ -17,6 +17,8 @@
 #include "metadata.h"
 #include "xlate.h"
 
+#ifdef linux
+
 /* Lifted from <linux/raid/md_p.h> because of difficulty including it */
 
 #define MD_SB_MAGIC 0xa92b4efc
@@ -25,6 +27,19 @@
 #define MD_NEW_SIZE_SECTORS(x) ((x & ~(MD_RESERVED_SECTORS - 1)) \
 				- MD_RESERVED_SECTORS)
 
+static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
+{
+	uint32_t md_magic;
+
+	/* Version 1 is little endian; version 0.90.0 is machine endian */
+	if (dev_read(dev, sb_offset, sizeof(uint32_t), &md_magic) &&
+	    ((md_magic == xlate32(MD_SB_MAGIC)) ||
+	     (md_magic == MD_SB_MAGIC)))
+		return 1;
+
+	return 0;
+}
+
 /*
  * Returns -1 on error
  */
@@ -32,8 +47,6 @@
 {
 	int ret = 0;
 
-#ifdef linux
-
 	uint64_t size, sb_offset;
 	uint32_t md_magic;
 
@@ -53,10 +66,7 @@
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
 
 	/* Check if it is an md component device. */
-	/* Version 1 is little endian; version 0.90.0 is machine endian */
-	if (dev_read(dev, sb_offset, sizeof(uint32_t), &md_magic) &&
-	    ((md_magic == xlate32(MD_SB_MAGIC)) ||
-	     (md_magic == MD_SB_MAGIC))) {
+	if (_dev_has_md_magic(dev, sb_offset)) {
 		if (sb)
 			*sb = sb_offset;
 		ret = 1;
@@ -65,7 +75,14 @@
 	if (!dev_close(dev))
 		stack;
 
-#endif
 	return ret;
 }
 
+#else
+
+int dev_is_md(struct device *dev __attribute((unused)), uint64_t *sb __attribute((unused)))
+{
+	return 0;
+}
+
+#endif


