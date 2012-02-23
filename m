From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Feb 2012 03:57:24 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20120223035724.3768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-23 03:57:23

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c raid_manip.c 

Log message:
	Fix allocation code to allow replacement of single RAID 4/5/6 device.
	
	The code fail to account for the case where we just need a single device
	in a RAID 4/5/6 array.  There is no good way to tell the allocation functions
	that we don't need parity devices when we are allocating just a single device.
	So, I've used a bit of a hack.  If we are allocating an area_count that is <=
	the parity count, then we can assume we are simply allocating a replacement
	device (i.e. no need to include parity devices in the calculations).  This
	should make sense in most cases.  If we need to allocate replacement devices
	due to failure (or moving), we will never allocate more than the parity count;
	or we would cause the array to become unusable.  If we are creating a new device,
	we should always create more stripes than parity devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2301&r2=1.2302
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.363&r2=1.364
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2012/02/23 00:11:01	1.2301
+++ LVM2/WHATS_NEW	2012/02/23 03:57:23	1.2302
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Fix allocation code to allow replacement of single RAID 4/5/6 device.
   Check all tags and LV names are in a valid form in vg_validate.
   Add tmpfiles.d style configuration for lvm2 lock and run directory.
   Add configure --with-tmpfilesdir for dir holding volatile-file configuration.
--- LVM2/lib/metadata/lv_manip.c	2012/02/22 17:14:39	1.363
+++ LVM2/lib/metadata/lv_manip.c	2012/02/23 03:57:23	1.364
@@ -737,7 +737,7 @@
 					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
-	uint32_t s, area_count, alloc_count;
+	uint32_t s, area_count, alloc_count, parity_count;
 	size_t size = 0;
 
 	/* FIXME Caller should ensure this */
@@ -752,7 +752,9 @@
 		area_count = stripes;
 
 	size = sizeof(*ah);
-	alloc_count = area_count + segtype->parity_devs;
+	parity_count = (area_count <= segtype->parity_devs) ? 0 :
+		segtype->parity_devs;
+	alloc_count = area_count + parity_count;
 	if (segtype_is_raid(segtype) && metadata_area_count)
 		/* RAID has a meta area for each device */
 		alloc_count *= 2;
@@ -787,7 +789,7 @@
 	else
 		ah->new_extents = 0;
 	ah->area_count = area_count;
-	ah->parity_count = segtype->parity_devs;
+	ah->parity_count = parity_count;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
 	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
--- LVM2/lib/metadata/raid_manip.c	2012/02/13 11:10:37	1.22
+++ LVM2/lib/metadata/raid_manip.c	2012/02/23 03:57:23	1.23
@@ -493,6 +493,7 @@
 {
 	uint32_t s;
 	uint32_t region_size;
+	uint32_t extents;
 	struct lv_segment *seg = first_seg(lv);
 	const struct segment_type *segtype;
 	struct alloc_handle *ah;
@@ -518,8 +519,11 @@
 	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
 		return_0;
 
+	extents = (segtype->parity_devs) ?
+		(lv->le_count / (seg->area_count - segtype->parity_devs)) :
+		lv->le_count;
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
-				    region_size, lv->le_count, pvs,
+				    region_size, extents, pvs,
 				    lv->alloc, parallel_areas)))
 		return_0;
 


