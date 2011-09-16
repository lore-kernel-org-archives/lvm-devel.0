From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 16 Sep 2011 18:39:04 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110916183904.12434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-16 18:39:04

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Fix Bug 738832 - core to disk log conversion fails with internal error
	
	This bug showed up when trying to add a log to a mirror whose images are on
	multiple devices.  This is an intra-release regression and no WHATS_NEW
	entry will be added.  The error was introduce in the following commit:
	2d8a2f35c77fdeef1dbe0ef791db8530d07826eb
	
	The solution is to recognise in _alloc_init that if there are no mirrors
	or stripes specified, then 'new_extents' should be zero.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.288&r2=1.289

--- LVM2/lib/metadata/lv_manip.c	2011/09/16 12:12:51	1.288
+++ LVM2/lib/metadata/lv_manip.c	2011/09/16 18:39:03	1.289
@@ -767,7 +767,10 @@
 		return NULL;
 	}
 
-	ah->new_extents = new_extents;
+	if (mirrors || stripes)
+		ah->new_extents = new_extents;
+	else
+		ah->new_extents = 0;
 	ah->area_count = area_count;
 	ah->parity_count = segtype->parity_devs;
 	ah->region_size = region_size;
@@ -801,7 +804,7 @@
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
 			mirror_log_extents(ah->region_size, extent_size,
-					   ah->new_extents / ah->area_multiple);
+					   new_extents / ah->area_multiple);
 	}
 
 	for (s = 0; s < alloc_count; s++)


