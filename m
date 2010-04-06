From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Apr 2010 14:04:03 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20100406140403.21163.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-06 14:04:03

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Refactor _read_pv() code that updates vg->extent_count and vg->free_count.
	
	Simple refactor to mov code that updates the vg extent counts from a
	single pv's counts close to the code that adds a pv to vg->pvs and
	updates vg->pv_count.  No functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/lib/format_text/import_vsn1.c	2010/04/01 10:34:10	1.71
+++ LVM2/lib/format_text/import_vsn1.c	2010/04/06 14:04:03	1.72
@@ -241,10 +241,6 @@
 		return 0;
 	}
 
-	/* adjust the volume group. */
-	vg->extent_count += pv->pe_count;
-	vg->free_count += pv->pe_count;
-
 	pv->pe_size = vg->extent_size;
 
 	pv->pe_alloc_count = 0;
@@ -273,6 +269,8 @@
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
+	vg->extent_count += pv->pe_count;
+	vg->free_count += pv->pe_count;
 	vg->pv_count++;
 	dm_list_add(&vg->pvs, &pvl->list);
 


