From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 23:02:52 -0000
Subject: LVM2/tools pvdisplay.c pvresize.c pvscan.c vgc ...
Message-ID: <20070613230252.7789.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 23:02:51

Modified files:
	tools          : pvdisplay.c pvresize.c pvscan.c vgconvert.c 
	                 vgreduce.c 

Log message:
	Convert pv->size to get_pv_size

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/tools/pvdisplay.c	2007/06/13 22:30:26	1.31
+++ LVM2/tools/pvdisplay.c	2007/06/13 23:02:51	1.32
@@ -57,7 +57,7 @@
 	}
 
 	if (!*pv->vg_name)
-		size = pv->size;
+		size = get_pv_size(pv);
 	else
 		size = (get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv)) * 
 			get_pv_pe_size(pv);
--- LVM2/tools/pvresize.c	2007/06/13 22:30:26	1.6
+++ LVM2/tools/pvresize.c	2007/06/13 23:02:51	1.7
@@ -114,7 +114,7 @@
 			log_print("WARNING: %s: Overriding real size. "
 				  "You could lose data.", pv_name);
 		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, params->new_size, pv->size);
+			    " sectors.", pv_name, params->new_size, get_pv_size(pv));
 		size = params->new_size;
 	}
 
@@ -136,7 +136,7 @@
 
 	if (vg) {
 		pv->size -= get_pv_pe_start(pv);
-		new_pe_count = pv->size / vg->extent_size;
+		new_pe_count = get_pv_size(pv) / vg->extent_size;
 		
  		if (!new_pe_count) {
 			log_error("%s: Size must leave space for at "
@@ -155,7 +155,7 @@
 	}
 
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, pv->size);
+		    pv_name, get_pv_size(pv));
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (*pv->vg_name) {
--- LVM2/tools/pvscan.c	2007/06/13 22:30:26	1.33
+++ LVM2/tools/pvscan.c	2007/06/13 23:02:51	1.34
@@ -67,7 +67,7 @@
 			  pv_max_name_len, pv_tmp_name,
 			  vg_max_name_len, " ",
 			  pv->fmt ? pv->fmt->name : "    ",
-			  display_size(cmd, pv->size));
+			  display_size(cmd, get_pv_size(pv)));
 		return;
 	}
 
@@ -156,8 +156,8 @@
 
 		if (!*pv->vg_name) {
 			new_pvs_found++;
-			size_new += pv->size;
-			size_total += pv->size;
+			size_new += get_pv_size(pv);
+			size_total += get_pv_size(pv);
 		} else
 			size_total += get_pv_pe_count(pv) * get_pv_pe_size(pv);
 	}
--- LVM2/tools/vgconvert.c	2007/06/13 22:58:32	1.19
+++ LVM2/tools/vgconvert.c	2007/06/13 23:02:51	1.20
@@ -136,7 +136,7 @@
 		change_made = 1;
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", dev_name(pv->dev), pv->size);
+			    " available sectors", dev_name(pv->dev), get_pv_size(pv));
 
 		/* Wipe existing label first */
 		if (!label_remove(pv->dev)) {
--- LVM2/tools/vgreduce.c	2007/06/13 22:11:29	1.61
+++ LVM2/tools/vgreduce.c	2007/06/13 23:02:51	1.62
@@ -367,7 +367,7 @@
 	struct pv_list *pvl;
 	const char *name = dev_name(pv->dev);
 
-	if (pv->pe_alloc_count) {
+	if (get_pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
 		return ECMD_FAILED;
 	}


