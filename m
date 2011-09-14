From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Sep 2011 09:57:36 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110914095736.2732.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-14 09:57:36

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h raid_manip.c 

Log message:
	LVM_WRITE and LVM_READ are 64bit constants
	
	Revert John patch, which fixed only 1 place where ~LVM_WRITE was in use and
	convert ommited LVM_READ/WRITE flags to 64bit constants as well.
	(Since both 'status' flags for LV and VG are 64bit.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2107&r2=1.2108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.210&r2=1.211
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/09/14 02:45:36	1.2107
+++ LVM2/WHATS_NEW	2011/09/14 09:57:35	1.2108
@@ -3,7 +3,6 @@
   Fix lv_mirror_count to handle mirrored stripes properly.
   Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
   Fix mirrored log creation when PE size is small - force log_size >= region_size
-  Fix improper RAID 64-bit status flag reset when and'ing against 32-bit flag.
   Fix log size calculation when only a log is being added to a mirror.
   Work around resume_lv causing error LV scanning during splitmirror operation.
   Add 7th lv_attr char to show the related kernel target.
--- LVM2/lib/metadata/metadata-exported.h	2011/09/08 20:55:39	1.210
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/14 09:57:35	1.211
@@ -88,8 +88,8 @@
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
 
-#define LVM_READ		0x00000100U	/* LV VG 32-bit */
-#define LVM_WRITE		0x00000200U	/* LV VG 32-bit */
+#define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
+#define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
 
 #define CLUSTERED		UINT64_C(0x00000400)	/* VG */
 //#define SHARED		UINT64_C(0x00000800)	/* VG */
--- LVM2/lib/metadata/raid_manip.c	2011/09/13 16:33:21	1.13
+++ LVM2/lib/metadata/raid_manip.c	2011/09/14 09:57:35	1.14
@@ -971,11 +971,7 @@
 		if (!_lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
 		lv_set_visible(seg_lv(seg, s));
-		/*
-		 * LVM_WRITE is 32-bit, if we don't '|' it with
-		 * UINT64_C(0) it will remove all higher order flags
-		 */
-		seg_lv(seg, s)->status &= ~(UINT64_C(0) | LVM_WRITE);
+		seg_lv(seg, s)->status &= ~LVM_WRITE;
 		break;
 	}
 


