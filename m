From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 15:48:28 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20100316154828.28469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 15:48:28

Modified files:
	tools          : pvcreate.c 

Log message:
	replace existing_pv with existing_pvl

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/tools/pvcreate.c	2010/03/16 15:30:49	1.89
+++ LVM2/tools/pvcreate.c	2010/03/16 15:48:27	1.90
@@ -28,8 +28,8 @@
 					    struct pvcreate_params *pp)
 {
 	const char *uuid = NULL;
-	void *existing_pv;
 	struct volume_group *vg;
+	struct pv_list *existing_pvl;
 
 	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
 		log_error("--uuid is required with --restorefile");
@@ -56,14 +56,14 @@
 				  pp->restorefile);
 			return 0;
 		}
-		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp)->pv)) {
+		if (!(existing_pvl = find_pv_in_vg_by_uuid(vg, pp->idp))) {
 			log_error("Can't find uuid %s in backup file %s",
 				  uuid, pp->restorefile);
 			return 0;
 		}
-		pp->pe_start = pv_pe_start(existing_pv);
-		pp->extent_size = pv_pe_size(existing_pv);
-		pp->extent_count = pv_pe_count(existing_pv);
+		pp->pe_start = pv_pe_start(existing_pvl->pv);
+		pp->extent_size = pv_pe_size(existing_pvl->pv);
+		pp->extent_count = pv_pe_count(existing_pvl->pv);
 		vg_release(vg);
 	}
 


