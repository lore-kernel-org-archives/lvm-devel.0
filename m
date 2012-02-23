From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Feb 2012 17:36:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20120223173638.2000.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-23 17:36:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c raid_manip.c 
	tools          : lvcreate.c 

Log message:
	Require number of stripes to be greater than parity devices in higher RAID.
	
	Also, add some comments to code that I recently added that may be unclear
	otherwise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2303&r2=1.2304
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.364&r2=1.365
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.254&r2=1.255

--- LVM2/WHATS_NEW	2012/02/23 11:24:07	1.2303
+++ LVM2/WHATS_NEW	2012/02/23 17:36:35	1.2304
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Require number of stripes to be greater than parity devices in higher RAID.
   Add LVMetaD systemd units.
   Fix allocation code to allow replacement of single RAID 4/5/6 device.
   Check all tags and LV names are in a valid form in vg_validate.
--- LVM2/lib/metadata/lv_manip.c	2012/02/23 03:57:23	1.364
+++ LVM2/lib/metadata/lv_manip.c	2012/02/23 17:36:36	1.365
@@ -752,6 +752,22 @@
 		area_count = stripes;
 
 	size = sizeof(*ah);
+
+	/*
+	 * It is a requirement that RAID 4/5/6 are created with a number of
+	 * stripes that is greater than the number of parity devices.  (e.g
+	 * RAID4/5 must have at least 2 stripes and RAID6 must have at least
+	 * 3.)  It is also a constraint that, when replacing individual devices
+	 * in a RAID 4/5/6 array, no more devices can be replaced than
+	 * there are parity devices.  (Otherwise, there would not be enough
+	 * redundancy to maintain the array.)  Understanding these two
+	 * constraints allows us to infer whether the caller of this function
+	 * is intending to allocate an entire array or just replacement
+	 * component devices.  In the former case, we must account for the
+	 * necessary parity_count.  In the later case, we do not need to
+	 * account for the extra parity devices because the array already
+	 * exists and they only want replacement drives.
+	 */
 	parity_count = (area_count <= segtype->parity_devs) ? 0 :
 		segtype->parity_devs;
 	alloc_count = area_count + parity_count;
--- LVM2/lib/metadata/raid_manip.c	2012/02/23 03:57:23	1.23
+++ LVM2/lib/metadata/raid_manip.c	2012/02/23 17:36:36	1.24
@@ -519,9 +519,18 @@
 	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
 		return_0;
 
+	/*
+	 * The number of extents is based on the RAID type.  For RAID1,
+	 * each of the rimages is the same size - 'le_count'.  However
+	 * for RAID 4/5/6, the stripes add together (NOT including the parity
+	 * devices) to equal 'le_count'.  Thus, when we are allocating
+	 * individual devies, we must specify how large the individual device
+	 * is along with the number we want ('count').
+	 */
 	extents = (segtype->parity_devs) ?
 		(lv->le_count / (seg->area_count - segtype->parity_devs)) :
 		lv->le_count;
+
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
 				    region_size, extents, pvs,
 				    lv->alloc, parallel_areas)))
--- LVM2/tools/lvcreate.c	2012/02/15 15:18:44	1.254
+++ LVM2/tools/lvcreate.c	2012/02/23 17:36:36	1.255
@@ -485,9 +485,10 @@
 	 *
 	 * For RAID 4/5/6, these values must be set.
 	 */
-	if (!segtype_is_mirrored(lp->segtype) && (lp->stripes < 2)) {
-		log_error("Number of stripes to %s not specified",
-			  lp->segtype->name);
+	if (!segtype_is_mirrored(lp->segtype) &&
+	    (lp->stripes <= lp->segtype->parity_devs)) {
+		log_error("Number of stripes must be at least %d for %s",
+			  lp->segtype->parity_devs + 1, lp->segtype->name);
 		return 0;
 	}
 


