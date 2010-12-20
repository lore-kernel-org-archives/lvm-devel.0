From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:38:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20101220143822.28132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:38:22

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Add missing test for reallocation error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1847&r2=1.1848
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241

--- LVM2/WHATS_NEW	2010/12/20 14:08:46	1.1847
+++ LVM2/WHATS_NEW	2010/12/20 14:38:22	1.1848
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Add missing test for reallocation error in _find_parallel_space().
   Add check for unlink error result in remove_lockfile() (dmeventd).
   Use dm_free for dm_malloc-ed areas in _clog_ctr/_clog_dtr (cmirrord).
   Add checks for allocation errors in config node clonning.
--- LVM2/lib/metadata/lv_manip.c	2010/12/20 13:12:56	1.240
+++ LVM2/lib/metadata/lv_manip.c	2010/12/20 14:38:22	1.241
@@ -1302,7 +1302,12 @@
 					/* Expand areas array if needed after an area was split. */
 					if (ix + ix_offset > *areas_size_ptr) {
 						*areas_size_ptr *= 2;
-						*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
+						if (!(*areas_ptr = dm_realloc(*areas_ptr,
+									     sizeof(**areas_ptr) *
+									     (*areas_size_ptr)))) {
+							log_error("Memory reallocation for parallel areas failed.");
+							return 0;
+						}
 					}
 					(*areas_ptr)[ix + ix_offset - 1].pva = pva;
 						(*areas_ptr)[ix + ix_offset - 1].used = required;


