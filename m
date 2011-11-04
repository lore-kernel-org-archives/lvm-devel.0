From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 22:45:53 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111104224553.2315.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 22:45:52

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin pool allocation simplified
	
	Support allocation of metadata from the same PV, if the VG
	is build only from one PV.
	
	As thinp is not mirror - we do not require 2 PVs
	for basic thin usage as user is losing only perfomance.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.322&r2=1.323

--- LVM2/lib/metadata/lv_manip.c	2011/11/04 22:44:22	1.322
+++ LVM2/lib/metadata/lv_manip.c	2011/11/04 22:45:52	1.323
@@ -2568,10 +2568,15 @@
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
-	if (!lv->le_count && segtype_is_thin_pool(segtype))
+	if (!lv->le_count && segtype_is_thin_pool(segtype)) {
+		if (stripes == 1 && (dm_list_size(allocatable_pvs) == 1)) {
+			log_warn("WARNING: Only one PV available for thin pool data and metadata.");
+			alloc = ALLOC_ANYWHERE;
+		}
 		/* Thin pool allocation treats its metadata device like a mirror log. */
+		/* TODO: add support for stripped metadata pool */
 		log_count = 1;
-	else if (segtype_is_raid(segtype) && !lv->le_count)
+	} else if (segtype_is_raid(segtype) && !lv->le_count)
 		log_count = mirrors * stripes;
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,


