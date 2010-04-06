From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Apr 2010 14:03:44 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100406140344.19111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-06 14:03:44

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add pv to vg->pvs after check for maximum value of vg->extent_count.
	
	In add_pv_to_vg(), we should only add the pv to vg->pvs after all
	internal checks have passed.  The check for vg->extent_count exeeding
	maximum was after we added the pv to the list, so this function could
	return a state of vg->pvs that did not reflect other parameters such
	as vg->pv_count.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.329&r2=1.330

--- LVM2/lib/metadata/metadata.c	2010/04/01 13:08:06	1.329
+++ LVM2/lib/metadata/metadata.c	2010/04/06 14:03:43	1.330
@@ -220,9 +220,6 @@
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
-	pvl->pv = pv;
-	dm_list_add(&vg->pvs, &pvl->list);
-
 	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
 		log_error("Unable to add %s to %s: new extent count (%"
 			  PRIu64 ") exceeds limit (%" PRIu32 ").",
@@ -232,6 +229,9 @@
 		return 0;
 	}
 
+	pvl->pv = pv;
+	dm_list_add(&vg->pvs, &pvl->list);
+
 	vg->pv_count++;
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;


