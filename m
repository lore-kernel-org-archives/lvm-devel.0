From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:32:50 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023250.16555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:32:50

Modified files:
	tools          : lvcreate.c 

Log message:
	Move pvs and pv_count fields from lvcreate_params to lvcreate_cmdline_params.
	
	No functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205

--- LVM2/tools/lvcreate.c	2009/07/26 02:32:26	1.204
+++ LVM2/tools/lvcreate.c	2009/07/26 02:32:50	1.205
@@ -21,6 +21,8 @@
 struct lvcreate_cmdline_params {
 	percent_t percent;
 	uint64_t size;
+	char **pvs;
+	int pv_count;
 };
 
 /* FIXME: refactor and reduce the size of this struct! */
@@ -56,8 +58,6 @@
 	uint32_t read_ahead; /* all */
 	alloc_policy_t alloc; /* all */
 
-	int pv_count; /* all; redundant? */
-	char **pvs; /* all; redundant? */
 	const char *tag; /* all */
 };
 
@@ -185,9 +185,9 @@
 	 * Create the pv list before we parse lcp->percent - might be
 	 * PERCENT_PVSs
 	 */
-	if (lp->pv_count) {
+	if (lcp->pv_count) {
 		if (!(lp->pvh = create_pv_list(vg->cmd->mem, vg,
-					   lp->pv_count, lp->pvs, 1)))
+					   lcp->pv_count, lcp->pvs, 1)))
 			return_0;
 	} else
 		lp->pvh = &vg->pvs;
@@ -200,7 +200,7 @@
 			lp->extents = lp->extents * vg->free_count / 100;
 			break;
 		case PERCENT_PVS:
-			if (!lp->pv_count) {
+			if (!lcp->pv_count) {
 				log_error("Please specify physical volume(s) "
 					  "with %%PVS");
 				return 0;
@@ -603,8 +603,8 @@
 		return 0;
 	}
 
-	lp->pv_count = argc;
-	lp->pvs = argv;
+	lcp->pv_count = argc;
+	lcp->pvs = argv;
 
 	return 1;
 }


