From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2007 00:51:05 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c
Message-ID: <20071024005105.25327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-10-24 00:51:05

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 

Log message:
	Detect md superblocks version 1.0, 1.1 and 1.2.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.721&r2=1.722
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2007/10/12 18:37:19	1.721
+++ LVM2/WHATS_NEW	2007/10/24 00:51:05	1.722
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Detect md superblocks version 1.0, 1.1 and 1.2.
   Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
   Add pv_dev_name() to access PV device name.
   Add const attributes to pv accessor functions.
--- LVM2/lib/device/dev-md.c	2007/10/24 00:30:30	1.6
+++ LVM2/lib/device/dev-md.c	2007/10/24 00:51:05	1.7
@@ -40,15 +40,35 @@
 	return 0;
 }
 
+/* FIXME Explain this algorithm */
+static uint64_t _v1_sb_offset(uint64_t size, int minor_version)
+{
+	uint64_t sb_offset;
+
+	switch(minor_version) {
+	case 0:
+		sb_offset = (size - 8 * 2) & ~(4 * 2 - 1);
+		break;
+	case 1:
+		sb_offset = 0;
+		break;
+	case 2:
+		sb_offset = 4 * 2;
+		break;
+	}
+	sb_offset <<= SECTOR_SHIFT;
+
+	return sb_offset;
+}
+
 /*
  * Returns -1 on error
  */
 int dev_is_md(struct device *dev, uint64_t *sb)
 {
-	int ret = 0;
-
+	int ret = 1;
+	unsigned minor = 0;
 	uint64_t size, sb_offset;
-	uint32_t md_magic;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
@@ -63,24 +83,35 @@
 		return -1;
 	}
 
+	/* Check if it is an md component device. */
+	/* Version 0.90.0 */
 	sb_offset = MD_NEW_SIZE_SECTORS(size) << SECTOR_SHIFT;
+	if (_dev_has_md_magic(dev, sb_offset))
+		goto out;
 
-	/* Check if it is an md component device. */
-	if (_dev_has_md_magic(dev, sb_offset)) {
-		if (sb)
-			*sb = sb_offset;
-		ret = 1;
-	}
+	/* Version 1, try v1.0 -> v1.2 */
+	do {
+		sb_offset = _v1_sb_offset(size, minor);
+		if (_dev_has_md_magic(dev, sb_offset))
+			goto out;
+	} while (++minor <= 2);
+
+	ret = 0;
 
+out:
 	if (!dev_close(dev))
 		stack;
 
+	if (ret && sb)
+		*sb = sb_offset;
+
 	return ret;
 }
 
 #else
 
-int dev_is_md(struct device *dev __attribute((unused)), uint64_t *sb __attribute((unused)))
+int dev_is_md(struct device *dev __attribute((unused)),
+	      uint64_t *sb __attribute((unused)))
 {
 	return 0;
 }


