From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 19:55:44 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100630195544.29141.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 19:55:44

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Check for missing_pv in vg_remove loop.
	
	If a pv is missing, we should just skip it rather than checking the
	device size and failing the vgremove.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.376&r2=1.377

--- LVM2/lib/metadata/metadata.c	2010/06/30 19:28:35	1.376
+++ LVM2/lib/metadata/metadata.c	2010/06/30 19:55:43	1.377
@@ -566,6 +566,9 @@
 	/* init physical volumes */
 	dm_list_iterate_items(pvl, &vg->removed_pvs) {
 		pv = pvl->pv;
+		if (is_missing_pv(pv))
+			continue;
+
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg->name);
 		pv->vg_name = vg->fid->fmt->orphan_vg_name;


