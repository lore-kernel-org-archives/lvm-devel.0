From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:39:09 -0000
Subject: LVM2/tools vgmerge.c
Message-ID: <20100628203909.20214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:39:08

Modified files:
	tools          : vgmerge.c 

Log message:
	Update _vgmerge_single() to move fid->metadata_areas_ignored.
	
	When vgmerge is called we move the mdas from the source to the
	destination.  With metadata balancing we now have another mda
	list, fid->metadata_areas_ignored, so move the mdas on this list
	as well.
	
	This patch should not matter as the code is written today.  However
	we include it for completeness in the case that _vgmerge_single()
	is refactored and/or moved into a library function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/tools/vgmerge.c	2010/06/28 20:32:47	1.67
+++ LVM2/tools/vgmerge.c	2010/06/28 20:39:08	1.68
@@ -126,6 +126,12 @@
 		dm_list_move(&vg_to->fid->metadata_areas_in_use, mdah);
 	}
 
+	while (!dm_list_empty(&vg_from->fid->metadata_areas_ignored)) {
+		struct dm_list *mdah = vg_from->fid->metadata_areas_ignored.n;
+
+		dm_list_move(&vg_to->fid->metadata_areas_ignored, mdah);
+	}
+
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 


