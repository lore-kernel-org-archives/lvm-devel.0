From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 7 Apr 2011 21:49:31 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110407214931.10279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-04-07 21:49:30

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Thanks to Zdenek Kabelac (kabi) for pointing out that I was using
	dm_pool_free incorrectly.  This check-in fixes that incorrect usage.
	
	I've also added a WHATS_NEW line to reflect the changes I made to allow
	lv_extend to operate on 0 length intrinsically layered LVs (i.e mirrors
	and RAID).  I forgot that in the last commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1967&r2=1.1968
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.255&r2=1.256

--- LVM2/WHATS_NEW	2011/03/30 13:14:34	1.1967
+++ LVM2/WHATS_NEW	2011/04/07 21:49:29	1.1968
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Allow lv_extend() to work on zero length intrinsically layered LVs.
   Keep the cache content when the exported vg buffer is matching.
   Extend the set of memory regions, that are not locked to memory.
   Enhance usability with the valgrind memcheck tool.
--- LVM2/lib/metadata/lv_manip.c	2011/04/06 21:32:20	1.255
+++ LVM2/lib/metadata/lv_manip.c	2011/04/07 21:49:29	1.256
@@ -2114,8 +2114,8 @@
 	struct logical_volume *sub_lv;
 	uint32_t i;
 	uint64_t status = 0;
-	char *img_name;
-	size_t len;
+	size_t len = strlen(lv->name) + 32;
+	char img_name[len];
 	struct lv_segment *mapseg;
 
 	if (lv->le_count || first_seg(lv)) {
@@ -2141,9 +2141,6 @@
 	/*
 	 * Next, create all of our sub_lv's and link them in.
 	 */
-	len = strlen(lv->name) + 32;
-	if (!(img_name = dm_pool_alloc(lv->vg->cmd->mem, len)))
-		return_0;
 	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
 		return_0;
 
@@ -2157,7 +2154,6 @@
 	}
 	dm_list_add(&lv->segments, &mapseg->list);
 
-	dm_pool_free(lv->vg->cmd->mem, img_name);
 	return 1;
 }
 


