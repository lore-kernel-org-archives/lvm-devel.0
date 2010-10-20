From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2010 15:07:32 -0000
Subject: LVM2 lib/device/device.c ./WHATS_NEW
Message-ID: <20101020150732.5923.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-20 15:07:31

Modified files:
	lib/device     : device.c 
	.              : WHATS_NEW 

Log message:
	Fix strict-aliasing compile warning in partition table scanning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1764&r2=1.1765

--- LVM2/lib/device/device.c	2010/08/11 12:14:24	1.34
+++ LVM2/lib/device/device.c	2010/10/20 15:07:30	1.35
@@ -58,9 +58,11 @@
 {
 	int ret = 0;
 	unsigned p;
-	uint16_t buf[SECTOR_SIZE/sizeof(uint16_t)];
-	uint16_t *part_magic;
-	struct partition *part;
+	struct {
+		uint8_t skip[PART_OFFSET];
+		struct partition part[4];
+		uint16_t magic;
+	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
 	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
 		return_0;
@@ -68,17 +70,15 @@
 	/* FIXME Check for other types of partition table too */
 
 	/* Check for msdos partition table */
-	part_magic = buf + PART_MAGIC_OFFSET/sizeof(buf[0]);
-	if ((*part_magic == xlate16(PART_MAGIC))) {
-		part = (struct partition *) (buf + PART_OFFSET/sizeof(buf[0]));
-		for (p = 0; p < 4; p++, part++) {
+	if (buf.magic == xlate16(PART_MAGIC)) {
+		for (p = 0; p < 4; ++p) {
 			/* Table is invalid if boot indicator not 0 or 0x80 */
-			if ((part->boot_ind & 0x7f)) {
+			if (buf.part[p].boot_ind & 0x7f) {
 				ret = 0;
 				break;
 			}
 			/* Must have at least one non-empty partition */
-			if (part->nr_sects)
+			if (buf.part[p].nr_sects)
 				ret = 1;
 		}
 	}
--- LVM2/WHATS_NEW	2010/10/15 17:04:02	1.1764
+++ LVM2/WHATS_NEW	2010/10/20 15:07:30	1.1765
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix strict-aliasing compile warning in partition table scanning.
   Add an option to automatically extend snapshots through dmeventd.
   Remove dependency on libm, floor() is replaced with integer algorithm.
   Fix hang when repairing a mirrored-log that had both devs fail.


