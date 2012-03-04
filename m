From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 15:58:32 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20120304155832.16300.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 15:58:32

Modified files:
	tools          : toollib.c 

Log message:
	Add FIXMEs
	
	Processing loop needs some thinking

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.245&r2=1.246

--- LVM2/tools/toollib.c	2012/03/01 21:14:43	1.245
+++ LVM2/tools/toollib.c	2012/03/04 15:58:31	1.246
@@ -119,6 +119,10 @@
 		process_all = 1;
 	}
 
+	/*
+	 * FIXME: In case of remove it goes through deleted entries,
+	 * but it works since entries are allocated from vg mem pool.
+	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
@@ -182,6 +186,10 @@
 	}
 
 	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
+		/*
+		 * FIXME: lvm supports removal of LV with all its dependencies
+		 * this leads to miscalculation that depends on the order of args.
+		 */
 		log_error("One or more specified logical volume(s) not found.");
 		if (ret_max < ECMD_FAILED)
 			ret_max = ECMD_FAILED;


