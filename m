From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Dec 2008 15:26:02 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20081219152602.17341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-12-19 15:26:02

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Do not issue write behind lv size.
	
	pvcreate $DEV
	vgcreate -s 1k vg_test $DEV
	lvcreate -l 1 -n lv1 vg_test
	..
	/dev/vg_test/lv1: write failed after 1024 of 4096 at 0: No space left on device
	
	Just check for maximum write size in set_lv.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1013&r2=1.1014
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/WHATS_NEW	2008/12/19 15:24:52	1.1013
+++ LVM2/WHATS_NEW	2008/12/19 15:26:01	1.1014
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Check for maximal LV size when wiping device.
   Calculate mirror log size instead of using 1 extent.
   Check if requested major/minor pair is already used.
   Fix incorrect return value in help function.
--- LVM2/lib/metadata/lv_manip.c	2008/12/19 15:24:53	1.161
+++ LVM2/lib/metadata/lv_manip.c	2008/12/19 15:26:02	1.162
@@ -2698,9 +2698,13 @@
 	if (!dev_open_quiet(dev))
 		return_0;
 
-	dev_set(dev, UINT64_C(0),
-		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
-		value);
+	if (!sectors)
+		sectors = UINT64_C(4096) >> SECTOR_SHIFT;
+
+	if (sectors > lv->size)
+		sectors = lv->size;
+
+	dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value);
 	dev_flush(dev);
 	dev_close_immediate(dev);
 


