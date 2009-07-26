From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:31:42 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023142.15936.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:31:42

Modified files:
	tools          : lvcreate.c 

Log message:
	Move percent_t from struct lvcreate_params to struct lvcreate_cmdline_params.
	
	Create a new structure, lvcreate_cmdline_params, to store parameters only
	relevant for the cmdline, not the library call to lvcreate.
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202

--- LVM2/tools/lvcreate.c	2009/07/26 02:31:18	1.201
+++ LVM2/tools/lvcreate.c	2009/07/26 02:31:41	1.202
@@ -18,6 +18,10 @@
 
 #include <fcntl.h>
 
+struct lvcreate_cmdline_params {
+	percent_t percent;
+};
+
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
@@ -46,7 +50,6 @@
 	uint64_t size;
 	uint32_t voriginextents;
 	uint64_t voriginsize;
-	percent_t percent;
 	struct dm_list *pvh;
 
 	uint32_t permission;
@@ -163,7 +166,8 @@
  * need the vg.
  */
 static int _update_extents_params(struct volume_group *vg,
-			       struct lvcreate_params *lp)
+				  struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
 {
 	uint32_t pv_extent_count;
 
@@ -178,7 +182,7 @@
 		return_0;
 
 	/*
-	 * Create the pv list before we parse lp->percent - might be
+	 * Create the pv list before we parse lcp->percent - might be
 	 * PERCENT_PVSs
 	 */
 	if (lp->pv_count) {
@@ -188,7 +192,7 @@
 	} else
 		lp->pvh = &vg->pvs;
 
-	switch(lp->percent) {
+	switch(lcp->percent) {
 		case PERCENT_VG:
 			lp->extents = lp->extents * vg->extent_count / 100;
 			break;
@@ -215,6 +219,7 @@
 }
 
 static int _read_size_params(struct lvcreate_params *lp,
+			     struct lvcreate_cmdline_params *lcp,
 			     struct cmd_context *cmd)
 {
 	if (arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) != 1) {
@@ -228,7 +233,7 @@
 			return 0;
 		}
 		lp->extents = arg_uint_value(cmd, extents_ARG, 0);
-		lp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
+		lcp->percent = arg_percent_value(cmd, extents_ARG, PERCENT_NONE);
 	}
 
 	/* Size returned in kilobyte units; held in sectors */
@@ -238,7 +243,7 @@
 			return 0;
 		}
 		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
-		lp->percent = PERCENT_NONE;
+		lcp->percent = PERCENT_NONE;
 	}
 
 	/* Size returned in kilobyte units; held in sectors */
@@ -407,13 +412,16 @@
 	return 1;
 }
 
-static int _lvcreate_params(struct lvcreate_params *lp, struct cmd_context *cmd,
+static int _lvcreate_params(struct lvcreate_params *lp,
+			    struct lvcreate_cmdline_params *lcp,
+			    struct cmd_context *cmd,
 			    int argc, char **argv)
 {
 	int contiguous;
 	unsigned pagesize;
 
 	memset(lp, 0, sizeof(*lp));
+	memset(lcp, 0, sizeof(*lcp));
 
 	/*
 	 * Check selected options are compatible and determine segtype
@@ -508,7 +516,7 @@
 	}
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
-	    !_read_size_params(lp, cmd) ||
+	    !_read_size_params(lp, lcp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
 	    !_read_mirror_params(lp, cmd))
 		return_0;
@@ -1006,11 +1014,12 @@
 {
 	int r = ECMD_PROCESSED;
 	struct lvcreate_params lp;
+	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
 
 	memset(&lp, 0, sizeof(lp));
 
-	if (!_lvcreate_params(&lp, cmd, argc, argv))
+	if (!_lvcreate_params(&lp, &lcp, cmd, argc, argv))
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
@@ -1020,7 +1029,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!_update_extents_params(vg, &lp))
+	if (!_update_extents_params(vg, &lp, &lcp))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(vg, &lp))


