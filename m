From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 22:04:46 -0000
Subject: LVM2/tools pvchange.c pvdisplay.c pvscan.c vgr ...
Message-ID: <20070613220446.10289.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 22:04:45

Modified files:
	tools          : pvchange.c pvdisplay.c pvscan.c vgreduce.c 
	                 vgsplit.c 

Log message:
	Convert pv->pe_alloc_count to get_pv_pe_alloc_count

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/tools/pvchange.c	2007/06/06 19:40:28	1.45
+++ LVM2/tools/pvchange.c	2007/06/13 22:04:45	1.46
@@ -182,7 +182,7 @@
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (*pv->vg_name) {
 			orig_vg_name = pv->vg_name;
-			orig_pe_alloc_count = pv->pe_alloc_count;
+			orig_pe_alloc_count = get_pv_pe_alloc_count(pv);
 			pv->vg_name = ORPHAN;
 			pv->pe_alloc_count = 0;
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
--- LVM2/tools/pvdisplay.c	2007/06/06 19:40:28	1.29
+++ LVM2/tools/pvdisplay.c	2007/06/13 22:04:45	1.30
@@ -59,7 +59,7 @@
 	if (!*pv->vg_name)
 		size = pv->size;
 	else
-		size = (pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+		size = (pv->pe_count - get_pv_pe_alloc_count(pv)) * pv->pe_size;
 
 	if (arg_count(cmd, short_ARG)) {
 		log_print("Device \"%s\" has a capacity of %s", pv_name,
--- LVM2/tools/pvscan.c	2006/11/30 23:11:42	1.30
+++ LVM2/tools/pvscan.c	2007/06/13 22:04:45	1.31
@@ -91,7 +91,7 @@
 		  pv->fmt ? pv->fmt->name : "    ",
 		  display_size(cmd, (uint64_t) pv->pe_count * pv->pe_size),
 		  display_size(cmd,
-			       (uint64_t) (pv->pe_count - pv->pe_alloc_count) *
+			       (uint64_t) (pv->pe_count - get_pv_pe_alloc_count(pv)) *
 					   pv->pe_size));
 	return;
 }
--- LVM2/tools/vgreduce.c	2007/06/06 19:40:28	1.59
+++ LVM2/tools/vgreduce.c	2007/06/13 22:04:45	1.60
@@ -397,7 +397,7 @@
 	}
 
 	vg->pv_count--;
-	vg->free_count -= pv->pe_count - pv->pe_alloc_count;
+	vg->free_count -= pv->pe_count - get_pv_pe_alloc_count(pv);
 	vg->extent_count -= pv->pe_count;
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
--- LVM2/tools/vgsplit.c	2007/06/06 19:40:28	1.26
+++ LVM2/tools/vgsplit.c	2007/06/13 22:04:45	1.27
@@ -38,8 +38,8 @@
 	vg_from->extent_count -= pv->pe_count;
 	vg_to->extent_count += pv->pe_count;
 
-	vg_from->free_count -= pv->pe_count - pv->pe_alloc_count;
-	vg_to->free_count += pv->pe_count - pv->pe_alloc_count;
+	vg_from->free_count -= pv->pe_count - get_pv_pe_alloc_count(pv);
+	vg_to->free_count += pv->pe_count - get_pv_pe_alloc_count(pv);
 
 	return 1;
 }


