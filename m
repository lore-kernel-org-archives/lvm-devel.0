From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:25:57 -0000
Subject: LVM2 lib/metadata/lv.c lib/metadata/lv_manip.c ...
Message-ID: <20120213112557.30367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:25:56

Modified files:
	lib/metadata   : lv.c lv_manip.c 
	liblvm         : lvm_lv.c 
	tools          : reporter.c 

Log message:
	Add internal error for unsupported code paths
	
	Patch mainly helps static analyzers to better work with code paths
	lvm code should never trigger.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.360&r2=1.361
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/lib/metadata/lv.c	2012/01/24 00:55:03	1.36
+++ LVM2/lib/metadata/lv.c	2012/02/13 11:25:56	1.37
@@ -53,6 +53,9 @@
 		case AREA_UNASSIGNED:
 			name = "unassigned";
 			extent = 0;
+		default:
+			log_error(INTERNAL_ERROR "Unknown area segtype.");
+			return NULL;
 		}
 
 		if (!dm_pool_grow_object(mem, name, strlen(name))) {
--- LVM2/lib/metadata/lv_manip.c	2012/02/12 21:37:03	1.360
+++ LVM2/lib/metadata/lv_manip.c	2012/02/13 11:25:56	1.361
@@ -2116,6 +2116,11 @@
 		return NULL;
 	}
 
+	if (!allocatable_pvs) {
+		log_error(INTERNAL_ERROR "Missing allocatable pvs.");
+		return NULL;
+	}
+
 	if (vg->fid->fmt->ops->segtype_supported &&
 	    !vg->fid->fmt->ops->segtype_supported(vg->fid, segtype)) {
 		log_error("Metadata format (%s) does not support required "
--- LVM2/liblvm/lvm_lv.c	2012/02/08 11:41:18	1.37
+++ LVM2/liblvm/lvm_lv.c	2012/02/13 11:25:56	1.38
@@ -124,12 +124,18 @@
 }
 
 /* Set default for linear segment specific LV parameters */
-static void _lv_set_default_linear_params(struct cmd_context *cmd,
+static int _lv_set_default_linear_params(struct cmd_context *cmd,
 					  struct lvcreate_params *lp)
 {
-	lp->segtype = get_segtype_from_string(cmd, "striped");
+	if (!(lp->segtype = get_segtype_from_string(cmd, "striped"))) {
+		log_error(INTERNAL_ERROR "Segtype striped not found.");
+		return 0;
+	}
+
 	lp->stripes = 1;
 	lp->stripe_size = DEFAULT_STRIPESIZE * 2;
+
+	return 1;
 }
 
 /*
@@ -151,7 +157,8 @@
 	extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
 				    vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
-	_lv_set_default_linear_params(vg->cmd, &lp);
+	if (!_lv_set_default_linear_params(vg->cmd, &lp))
+		return_NULL;
 	if (!lv_create_single(vg, &lp))
 		return NULL;
 	lvl = find_lv_in_vg(vg, name);
--- LVM2/tools/reporter.c	2011/08/10 20:25:31	1.67
+++ LVM2/tools/reporter.c	2012/02/13 11:25:56	1.68
@@ -315,6 +315,9 @@
 						  "report/pvsegs_cols_verbose",
 						  DEFAULT_PVSEGS_COLS_VERB);
 		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown report type.");
+		return ECMD_FAILED;
 	}
 
 	/* If -o supplied use it, else use default for report_type */


