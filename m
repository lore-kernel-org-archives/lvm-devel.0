From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 22:58:33 -0000
Subject: LVM2/tools vgconvert.c
Message-ID: <20070613225833.6638.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 22:58:32

Modified files:
	tools          : vgconvert.c 

Log message:
	Convert existing_pv dereferences to get_pv_*

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/tools/vgconvert.c	2006/05/16 16:48:31	1.18
+++ LVM2/tools/vgconvert.c	2007/06/13 22:58:32	1.19
@@ -114,18 +114,18 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
 
-		pe_start = existing_pv->pe_start;
-		pe_end = existing_pv->pe_count * existing_pv->pe_size
+		pe_start = get_pv_pe_start(existing_pv);
+		pe_end = get_pv_pe_count(existing_pv) * get_pv_pe_size(existing_pv)
 		    + pe_start - 1;
 
 		list_init(&mdas);
-		if (!(pv = pv_create(cmd->fmt, existing_pv->dev,
+		if (!(pv = pv_create(cmd->fmt, get_pv_dev(existing_pv),
 				     &existing_pv->id, size,
-				     pe_start, existing_pv->pe_count,
-				     existing_pv->pe_size, pvmetadatacopies,
+				     pe_start, get_pv_pe_count(existing_pv),
+				     get_pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
 			log_error("Failed to setup physical volume \"%s\"",
-				  dev_name(existing_pv->dev));
+				  dev_name(get_pv_dev(existing_pv)));
 			if (change_made)
 				log_error("Use pvcreate and vgcfgrestore to "
 					  "repair from archived metadata.");


