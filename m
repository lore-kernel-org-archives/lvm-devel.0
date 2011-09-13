From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 18:11:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110913181139.8073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 18:11:38

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Better fix for bug 737125 - unable to create mirror on 1K extent size VG
	
	WHATS_NEW entry:
	Fix log size calculation when only a log is being added to a mirror.
	
	The original fix pass the mirror LV to allocate_extents (rather than
	passing NULL) so that _alloc_init could correctly determine the necessary
	size of the mirror log.  In the previous check-in, I noted:
	In order to get a decent value computed, we need to pass in the 'lv' argument
	to allocate_extents.  This would normally imply a desire for cling/contiguous
	allocation to the given LV, but since we are not allocating any parallel
	extents and only log extents, it works fine.
	However, passing in the LV did have unintended consequences on the placement of
	the log.  The better solution is to pass in the number of extext that are in
	the mirror LV instead of the LV itself.  This will not cause the allocator to
	reserve that number of extents, because 'stripes' and 'mirrors' are specified
	as 0.  Thus, 'extents' is used to calculate the size of the log, but won't
	affect how much is allocated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/lib/metadata/mirror.c	2011/09/13 14:37:49	1.164
+++ LVM2/lib/metadata/mirror.c	2011/09/13 18:11:38	1.165
@@ -1966,9 +1966,10 @@
 	}
 
 	/* allocate destination extents */
-	ah = allocate_extents(lv->vg, lv, segtype,
-			      0, 0, log_count - old_log_count, region_size, 0,
-			      allocatable_pvs, alloc, parallel_areas);
+	ah = allocate_extents(lv->vg, NULL, segtype,
+			      0, 0, log_count - old_log_count, region_size,
+			      lv->le_count, allocatable_pvs,
+			      alloc, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;


