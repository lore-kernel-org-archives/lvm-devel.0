From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 9 Jul 2009 22:34:03 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20090709223403.16597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-09 22:34:02

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Add extended device (blkext) and MD partition (mdp) types to filters.
	
	Both types were added with a 'max_partitions' of 1 because these devices
	are _not_ partitionable (they are the partitions).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1173&r2=1.1174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2009/07/09 11:29:41	1.1173
+++ LVM2/WHATS_NEW	2009/07/09 22:34:02	1.1174
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Add extended device (blkext) and MD partition (mdp) types to filters.
   Fix and precise metadata read errors for segment areas.
   Fix segment metadata read function errors to use proper segment name.
   Add parent node to config_node structure.
--- LVM2/lib/filters/filter.c	2009/04/16 10:16:14	1.47
+++ LVM2/lib/filters/filter.c	2009/07/09 22:34:02	1.48
@@ -57,6 +57,7 @@
 	{"ide", 64},		/* IDE disk */
 	{"sd", 16},		/* SCSI disk */
 	{"md", 1},		/* Multiple Disk driver (SoftRAID) */
+	{"mdp", 1},		/* Partitionable MD */
 	{"loop", 1},		/* Loop device */
 	{"dasd", 4},		/* DASD disk (IBM S/390, zSeries) */
 	{"dac960", 8},		/* DAC960 */
@@ -79,6 +80,7 @@
 	{"ps3disk", 16},	/* PlayStation 3 internal disk */
 	{"virtblk", 8},		/* VirtIO disk */
 	{"mmc", 16},		/* MMC block device */
+	{"blkext", 1},		/* Extended device partitions */
 	{NULL, 0}
 };
 


