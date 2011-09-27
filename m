From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 12:37:08 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20110927123708.15798.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 12:37:07

Modified files:
	tools          : lvcreate.c 

Log message:
	better -m0 error message, but there's an internal logic error to fix instead

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243

--- LVM2/tools/lvcreate.c	2011/09/22 15:36:21	1.242
+++ LVM2/tools/lvcreate.c	2011/09/27 12:37:07	1.243
@@ -575,11 +575,14 @@
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
+// FIXME -m0 implies *striped*
 	if (arg_count(cmd, thin_ARG) && arg_count(cmd,mirrors_ARG)) {
 		log_error("--thin and --mirrors are incompatible.");
 		return 0;
 	}
 
+// FIXME -m0 implies *striped*
+
 	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
 		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
@@ -620,7 +623,7 @@
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1) {
 			if (segtype_is_mirrored(lp->segtype)) {
-				log_error("Image count for segtype \"%s\" cannot be 0.", lp->segtype->name);
+				log_error("--mirrors must be at least 1 with segment type %s.", lp->segtype->name);
 				return 0;
 			}
 			log_print("Redundant mirrors argument: default is 0");


