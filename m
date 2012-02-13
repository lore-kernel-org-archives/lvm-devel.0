From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Feb 2012 18:36:57 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120213183657.28415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-13 18:36:56

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix possible NULL pointer dereferences when updating mirror log.
	
	'_lv_update_log_type' takes a lvconvert_params argument so that it can pass
	down the user's preference of 'region_size' and allocation_policy.  When
	'mirror_remove_missing' was introduced (commit ID
	95986e42a18ca98c9b1d777346978b7297c85558) it didn't make sense to pass down
	user preferences - so NULL was given instead.  While it may never happen in
	practice, static analysis reveals that this argument could be dereferenced.
	So, if the user preferences were not passed in, glean the necessary fields
	from what is already set in the LV.
	
	Reported-by: Zdenek Kabelac <zkabelac@redhat.com>
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	
	(Not updating WHATSNEW for this simple clean-up.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/tools/lvconvert.c	2012/01/25 22:38:40	1.180
+++ LVM2/tools/lvconvert.c	2012/02/13 18:36:55	1.181
@@ -770,8 +770,10 @@
 			       struct dm_list *operable_pvs,
 			       int log_count)
 {
-	uint32_t region_size;
 	int old_log_count;
+	uint32_t region_size = (lp) ? lp->region_size :
+		first_seg(lv)->region_size;
+	alloc_policy_t alloc = (lp) ? lp->alloc : lv->alloc;
 	struct logical_volume *original_lv;
 	struct logical_volume *log_lv;
 
@@ -793,13 +795,12 @@
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
-
 		region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							  lv->le_count,
-							  lp->region_size);
+							  region_size);
 
 		if (!add_mirror_log(cmd, original_lv, log_count,
-				    region_size, operable_pvs, lp->alloc))
+				    region_size, operable_pvs, alloc))
 			return_0;
 		/*
 		 * FIXME: This simple approach won't work in cluster mirrors,
@@ -812,7 +813,8 @@
 	}
 
 	/* Reducing redundancy of the log */
-	return remove_mirror_images(log_lv, log_count, is_mirror_image_removable, operable_pvs, 1U);
+	return remove_mirror_images(log_lv, log_count,
+				    is_mirror_image_removable, operable_pvs, 1U);
 }
 
 /*


