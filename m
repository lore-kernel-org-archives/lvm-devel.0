From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Nov 2011 13:54:56 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111107135456.20363.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-07 13:54:55

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Must not override alloc policy specified by user.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.325&r2=1.326

--- LVM2/lib/metadata/lv_manip.c	2011/11/07 11:03:47	1.325
+++ LVM2/lib/metadata/lv_manip.c	2011/11/07 13:54:54	1.326
@@ -2576,12 +2576,9 @@
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
 	if (!lv->le_count && segtype_is_thin_pool(segtype)) {
-		if (stripes == 1 && (dm_list_size(allocatable_pvs) == 1)) {
-			log_warn("WARNING: Only one PV available for thin pool data and metadata.");
-			alloc = ALLOC_ANYWHERE;
-		}
 		/* Thin pool allocation treats its metadata device like a mirror log. */
-		/* TODO: add support for stripped metadata pool */
+		/* FIXME Allow pool and data on same device with NORMAL */
+		/* FIXME Support striped metadata pool */
 		log_count = 1;
 	} else if (segtype_is_raid(segtype) && !lv->le_count)
 		log_count = mirrors * stripes;


