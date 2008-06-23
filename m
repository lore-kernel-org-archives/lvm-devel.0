From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jun 2008 14:54:50 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-md.c
Message-ID: <20080623145450.27447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-23 14:54:50

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-md.c 

Log message:
	Suppress 'sb_offset' compiler warning by using enum for md superblock versions.
	
	The warning is bogus and is only seen on certain versions of gcc.
	However using the enum does seem to clarify the intent of the code - only
	3 possible md minor superblock versions.
	
	Related compiler warning:
	device/dev-md.c:53: warning: 'sb_offset' may be used uninitialized in this function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.911&r2=1.912
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2008/06/23 09:27:45	1.911
+++ LVM2/WHATS_NEW	2008/06/23 14:54:49	1.912
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Suppress 'sb_offset' compiler warning by using enum for md minor sb version. 
   lvm2_run: Don't return uninitialized "ret" for _memlock_inc or _memlock_dec.
   Avoid link failure when configuring without --enable-cmdlib.
   Avoid link failure when configuring without --enable-readline.
--- LVM2/lib/device/dev-md.c	2007/10/24 11:24:24	1.8
+++ LVM2/lib/device/dev-md.c	2008/06/23 14:54:50	1.9
@@ -48,18 +48,26 @@
  * 1: At start of device
  * 2: 4K from start of device.
  */
-static uint64_t _v1_sb_offset(uint64_t size, unsigned minor_version)
+typedef enum {
+	MD_MINOR_VERSION_MIN,
+	MD_MINOR_V0 = MD_MINOR_VERSION_MIN,
+	MD_MINOR_V1,
+	MD_MINOR_V2,
+	MD_MINOR_VERSION_MAX = MD_MINOR_V2
+} md_minor_version_t;
+
+static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 {
 	uint64_t sb_offset;
 
 	switch(minor_version) {
-	case 0:
+	case MD_MINOR_V0:
 		sb_offset = (size - 8 * 2) & ~(4 * 2 - 1ULL);
 		break;
-	case 1:
+	case MD_MINOR_V1:
 		sb_offset = 0;
 		break;
-	case 2:
+	case MD_MINOR_V2:
 		sb_offset = 4 * 2;
 		break;
 	}
@@ -74,7 +82,7 @@
 int dev_is_md(struct device *dev, uint64_t *sb)
 {
 	int ret = 1;
-	unsigned minor = 0;
+	md_minor_version_t minor;
 	uint64_t size, sb_offset;
 
 	if (!dev_get_size(dev, &size)) {
@@ -96,12 +104,13 @@
 	if (_dev_has_md_magic(dev, sb_offset))
 		goto out;
 
+	minor = MD_MINOR_VERSION_MIN;
 	/* Version 1, try v1.0 -> v1.2 */
 	do {
 		sb_offset = _v1_sb_offset(size, minor);
 		if (_dev_has_md_magic(dev, sb_offset))
 			goto out;
-	} while (++minor <= 2);
+	} while (++minor <= MD_MINOR_VERSION_MAX);
 
 	ret = 0;
 


