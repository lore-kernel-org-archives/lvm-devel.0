From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 16:33:23 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20110913163323.16570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 16:33:22

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Changing RAID status flags to 64-bit broke some binary flag operations.
	
	LVM_WRITE is a 32-bit flag.  Now that RAID[_IMAGE|_META] are 64-bit,
	and'ing a RAID LV's status against LVM_WRITE can reset the higher order
	flags.
	
	A similar thing will affect thinp flags if not careful.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2103&r2=1.2104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2011/09/13 14:37:48	1.2103
+++ LVM2/WHATS_NEW	2011/09/13 16:33:21	1.2104
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix improper RAID 64-bit status flag reset when and'ing against 32-bit flag.
   Fix log size calculation when only a log is being added to a mirror.
   Work around resume_lv causing error LV scanning during splitmirror operation.
   Add 7th lv_attr char to show the related kernel target.
--- LVM2/lib/metadata/raid_manip.c	2011/09/06 18:49:32	1.12
+++ LVM2/lib/metadata/raid_manip.c	2011/09/13 16:33:21	1.13
@@ -971,7 +971,11 @@
 		if (!_lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
 		lv_set_visible(seg_lv(seg, s));
-		seg_lv(seg, s)->status &= ~LVM_WRITE;
+		/*
+		 * LVM_WRITE is 32-bit, if we don't '|' it with
+		 * UINT64_C(0) it will remove all higher order flags
+		 */
+		seg_lv(seg, s)->status &= ~(UINT64_C(0) | LVM_WRITE);
 		break;
 	}
 


