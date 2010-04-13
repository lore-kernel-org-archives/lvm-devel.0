From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:25:26 -0000
Subject: LVM2/lib/format_pool import_export.c
Message-ID: <20100413172526.10599.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:25:26

Modified files:
	lib/format_pool: import_export.c 

Log message:
	Move increment of vg->pv_count from import_pool_vg() to import_pool_pvs().
	
	Move the increment of vg->pv_count next to the place where we add to
	vg->pvs.  It looks safe to do this since the only caller of import_pool_vg()
	calls import_pool_pvs() immediately afterward, and there is no way
	import_pool_vg() can fail (always returns 1).  However, if there's a
	memory allocation failure inside import_pool_pvs(), we will end up with
	a different count in vg->pv_count that with the original code.  In any
	case, vg->pv_count should be as close to dm_list_size(&vg->pvs) as
	possible, as is the case everywhere else in the code.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/lib/format_pool/import_export.c	2010/04/13 17:25:13	1.30
+++ LVM2/lib/format_pool/import_export.c	2010/04/13 17:25:26	1.31
@@ -37,7 +37,6 @@
 		    ((pl->pd.pl_blocks) / POOL_PE_SIZE);
 
 		vg->free_count = vg->extent_count;
-		vg->pv_count++;
 
 		if (vg->name)
 			continue;
@@ -120,6 +119,7 @@
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
+		vg->pv_count++;
 		dm_list_add(&vg->pvs, &pvl->list);
 	}
 


