From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 14:37:49 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20110913143749.9114.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 14:37:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bug 737125 - unable to create mirror on 1K extent size VG
	
	_alloc_init calculates the number of necessary log extents via
	'mirror_log_extents'.  'mirror_log_extents' takes 3 arguments: region_size,
	pe_size, and size of the mirror LV.  Unfortunately, _alloc_init is guessing at
	the mirror size by using 'ah->new_extents / ah->area_multiple' - the number of
	extents that the mirror images have.  However, this is /always/ wrong when
	allocating the log separately.  Further, the log is always allocated separately
	unless we are up-converting the mirror at the same time.  It was by luck alone
	that a default value of '1' reflects what we want in most cases.
	
	In order to get a decent value computed, we need to pass in the 'lv' argument
	to allocate_extents.  This would normally imply a desire for cling/contiguous
	allocation to the given LV, but since we are not allocating any parallel
	extents and only log extents, it works fine.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2102&r2=1.2103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/WHATS_NEW	2011/09/13 13:59:19	1.2102
+++ LVM2/WHATS_NEW	2011/09/13 14:37:48	1.2103
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix log size calculation when only a log is being added to a mirror.
   Work around resume_lv causing error LV scanning during splitmirror operation.
   Add 7th lv_attr char to show the related kernel target.
   Terminate pv_attr field correctly. (2.02.86)
--- LVM2/lib/metadata/mirror.c	2011/09/13 13:59:19	1.163
+++ LVM2/lib/metadata/mirror.c	2011/09/13 14:37:49	1.164
@@ -1966,7 +1966,7 @@
 	}
 
 	/* allocate destination extents */
-	ah = allocate_extents(lv->vg, NULL, segtype,
+	ah = allocate_extents(lv->vg, lv, segtype,
 			      0, 0, log_count - old_log_count, region_size, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {


