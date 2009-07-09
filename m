From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 9 Jul 2009 22:50:45 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.c
Message-ID: <20090709225045.27291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-09 22:50:45

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.c 

Log message:
	Check MD devices for a partition table during device scan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1174&r2=1.1175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2009/07/09 22:34:02	1.1174
+++ LVM2/WHATS_NEW	2009/07/09 22:50:45	1.1175
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Check MD devices for a partition table during device scan.
   Add extended device (blkext) and MD partition (mdp) types to filters.
   Fix and precise metadata read errors for segment areas.
   Fix segment metadata read function errors to use proper segment name.
--- LVM2/lib/device/device.c	2008/01/30 13:59:58	1.26
+++ LVM2/lib/device/device.c	2009/07/09 22:50:45	1.27
@@ -43,6 +43,10 @@
 {
 	int parts = max_partitions(MAJOR(dev->dev));
 
+	/* All MD devices are partitionable via blkext (as of 2.6.28) */
+	if (MAJOR(dev->dev) == md_major())
+		return 1;
+
 	if ((parts <= 1) || (MINOR(dev->dev) % parts))
 		return 0;
 


