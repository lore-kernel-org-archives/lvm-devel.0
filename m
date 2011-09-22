From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Sep 2011 15:33:22 -0000
Subject: LVM2/lib/metadata raid_manip.c
Message-ID: <20110922153322.597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-22 15:33:21

Modified files:
	lib/metadata   : raid_manip.c 

Log message:
	When up-converting a RAID1 array, we need to allocate new larger arrays for
	seg->areas and seg->meta_areas.  We also need to copy the memory from the
	old arrays to the newly allocated arrays.  The amount of memory to copy was
	determined by seg->area_count.  However, seg->area_count was being set to the
	higher value after copying the 'seg->areas' information, but before copying
	the 'seg->meta_areas' information.  This means we were copying more memory
	than necessary for 'seg->meta_areas' - something that could lead to a segfault.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/lib/metadata/raid_manip.c	2011/09/14 09:57:35	1.14
+++ LVM2/lib/metadata/raid_manip.c	2011/09/22 15:33:21	1.15
@@ -499,7 +499,6 @@
 		goto fail;
 	memcpy(new_areas, seg->areas, seg->area_count * sizeof(*seg->areas));
 	seg->areas = new_areas;
-	seg->area_count = new_count;
 
 	/* Expand meta_areas array */
 	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
@@ -508,6 +507,7 @@
 	memcpy(new_areas, seg->meta_areas,
 	       seg->area_count * sizeof(*seg->meta_areas));
 	seg->meta_areas = new_areas;
+	seg->area_count = new_count;
 
 	/* Set segment areas for metadata sub_lvs */
 	s = old_count;


