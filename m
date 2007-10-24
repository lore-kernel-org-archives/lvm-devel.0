From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2007 11:24:24 -0000
Subject: LVM2/lib/device dev-md.c
Message-ID: <20071024112424.20365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-10-24 11:24:24

Modified files:
	lib/device     : dev-md.c 

Log message:
	explanation of md superblock location & avoid compilation warnings

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/device/dev-md.c	2007/10/24 00:51:05	1.7
+++ LVM2/lib/device/dev-md.c	2007/10/24 11:24:24	1.8
@@ -22,7 +22,7 @@
 /* Lifted from <linux/raid/md_p.h> because of difficulty including it */
 
 #define MD_SB_MAGIC 0xa92b4efc
-#define MD_RESERVED_BYTES (64 * 1024)
+#define MD_RESERVED_BYTES (64 * 1024ULL)
 #define MD_RESERVED_SECTORS (MD_RESERVED_BYTES / 512)
 #define MD_NEW_SIZE_SECTORS(x) ((x & ~(MD_RESERVED_SECTORS - 1)) \
 				- MD_RESERVED_SECTORS)
@@ -40,14 +40,21 @@
 	return 0;
 }
 
-/* FIXME Explain this algorithm */
-static uint64_t _v1_sb_offset(uint64_t size, int minor_version)
+/*
+ * Calculate the position of the superblock.
+ * It is always aligned to a 4K boundary and
+ * depending on minor_version, it can be:
+ * 0: At least 8K, but less than 12K, from end of device
+ * 1: At start of device
+ * 2: 4K from start of device.
+ */
+static uint64_t _v1_sb_offset(uint64_t size, unsigned minor_version)
 {
 	uint64_t sb_offset;
 
 	switch(minor_version) {
 	case 0:
-		sb_offset = (size - 8 * 2) & ~(4 * 2 - 1);
+		sb_offset = (size - 8 * 2) & ~(4 * 2 - 1ULL);
 		break;
 	case 1:
 		sb_offset = 0;


