From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Feb 2012 17:59:23 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20120213175923.11219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-13 17:59:22

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Fix bug that caused RAID devices to be unable to activate if sub-LV was missing.
	
	Commit 02f6f4902fd90709f55e2e97e969ee28c2945c81 introduced a bug that caused
	RAID devices to fail to activate if the device for a single sub-LV failed.
	The special case of LVM mirror was handled, but not LVM RAID.
	EXAMPLE:
	[root at bp-01 ~]# devices vg
	LV            Copy%  Devices
	lv            100.00 lv_rimage_0(0),lv_rimage_1(0)
	[lv_rimage_0]        /dev/sde1(1)
	[lv_rimage_1]        /dev/sdh1(1)
	[lv_rmeta_0]         /dev/sde1(0)
	[lv_rmeta_1]         /dev/sdh1(0)
	[root at bp-01 ~]# vgchange -an vg
	0 logical volume(s) in volume group "vg" now active
	[root at bp-01 ~]# off.sh sdh
	Turning off sdh
	[root at bp-01 ~]# vgchange -ay vg --partial
	Partial mode. Incomplete logical volumes will be processed.
	Couldn't find device with uuid fbI0YO-GX7x-firU-Vy5o-vzwx-vAKZ-feRxfF.
	Cannot activate vg/lv_rimage_1: all segments missing.
	0 logical volume(s) in volume group "vg" now active
	
	AFTER this patch:
	[root at bp-01 ~]# vgchange -ay vg --partial
	Partial mode. Incomplete logical volumes will be processed.
	Couldn't find device with uuid fbI0YO-GX7x-firU-Vy5o-vzwx-vAKZ-feRxfF.
	1 logical volume(s) in volume group "vg" now active
	[root at bp-01 ~]# devices vg
	Couldn't find device with uuid fbI0YO-GX7x-firU-Vy5o-vzwx-vAKZ-feRxfF.
	LV            Copy%  Devices
	lv            100.00 lv_rimage_0(0),lv_rimage_1(0)
	[lv_rimage_0]        /dev/sde1(1)
	[lv_rimage_1]        unknown device(1)
	[lv_rmeta_0]         /dev/sde1(0)
	[lv_rmeta_1]         unknown device(0)
	[root at bp-01 ~]# dmsetup table vg-lv; dmsetup status vg-lv
	0 1024000 raid raid1 3 0 region_size 1024 2 253:2 253:3 - -
	0 1024000 raid raid1 2 AD 1024000/1024000
	
	No WHATSNEW update necessary because this is an intrarelease fix.
	
	brassow

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.270&r2=1.271

--- LVM2/lib/activate/dev_manager.c	2012/02/01 13:47:27	1.270
+++ LVM2/lib/activate/dev_manager.c	2012/02/13 17:59:21	1.271
@@ -1449,11 +1449,14 @@
 		}
 
 		/*
-		 * Mirrors activate LVs replaced with error targets
+		 * Mirrors activate LVs replaced with error targets and
+		 * RAID can handle non-accessible sub-LVs.
 		 *
 		 * TODO: Can we eventually skip to activate such LVs ?
 		 */
 		if (!num_existing_areas &&
+		    !strstr(seg->lv->name, "_rmeta_") &&
+		    !strstr(seg->lv->name, "_rimage_") &&
 		    !strstr(seg->lv->name, "_mimage_") &&
 		    !((name = strstr(seg->lv->name, "_mlog")) && !name[5])) {
 			log_error("Cannot activate %s/%s: all segments missing.",


