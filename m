From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:32:00 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023200.16081.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:32:00

Modified files:
	tools          : lvcreate.c 

Log message:
	Move 'size' from lvcreate_params into lvcreate_cmdline_params.
	
	The main _lvcreate function should deal with extents - the 'size' parameter
	is just an intermediate step.
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203

--- LVM2/tools/lvcreate.c	2009/07/26 02:31:41	1.202
+++ LVM2/tools/lvcreate.c	2009/07/26 02:32:00	1.203
@@ -20,6 +20,7 @@
 
 struct lvcreate_cmdline_params {
 	percent_t percent;
+	uint64_t size;
 };
 
 /* FIXME: refactor and reduce the size of this struct! */
@@ -47,7 +48,6 @@
 
 	/* size */
 	uint32_t extents;
-	uint64_t size;
 	uint32_t voriginextents;
 	uint64_t voriginsize;
 	struct dm_list *pvh;
@@ -171,8 +171,8 @@
 {
 	uint32_t pv_extent_count;
 
-	if (lp->size &&
-	    !(lp->extents = _extents_from_size(vg->cmd, lp->size,
+	if (lcp->size &&
+	    !(lp->extents = _extents_from_size(vg->cmd, lcp->size,
 					       vg->extent_size)))
 		return_0;
 
@@ -242,7 +242,7 @@
 			log_error("Negative size is invalid");
 			return 0;
 		}
-		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
+		lcp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lcp->percent = PERCENT_NONE;
 	}
 


