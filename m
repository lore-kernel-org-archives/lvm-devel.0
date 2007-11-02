From: bmr@sourceware.org <bmr@sourceware.org>
Date: 2 Nov 2007 14:54:41 -0000
Subject: LVM2 ./WHATS_NEW tools/pvchange.c tools/pvdisp ...
Message-ID: <20071102145441.16874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-11-02 14:54:41

Modified files:
	.              : WHATS_NEW 
	tools          : pvchange.c pvdisplay.c pvscan.c 

Log message:
	Convert pvchange, pvdisplay, pvscan to use is_orphan()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.723&r2=1.724
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2007/11/02 13:06:41	1.723
+++ LVM2/WHATS_NEW	2007/11/02 14:54:40	1.724
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Convert pvchange, pvdisplay, pvscan to use is_orphan()
   Add is_orphan_vg() and change all hardcoded checks to use it.
   Detect md superblocks version 1.0, 1.1 and 1.2.
   Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
--- LVM2/tools/pvchange.c	2007/10/12 14:29:32	1.53
+++ LVM2/tools/pvchange.c	2007/11/02 14:54:40	1.54
@@ -51,7 +51,8 @@
 	}
 
 	/* If in a VG, must change using volume group. */
-	if (*pv_vg_name(pv)) {
+	/* FIXME: handle PVs with no MDAs */
+	if (!is_orphan(pv)) {
 		log_verbose("Finding volume group of physical volume \"%s\"",
 			    pv_name);
 
@@ -115,7 +116,7 @@
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
-		if (!*pv_vg_name(pv) &&
+		if (is_orphan(pv) &&
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
@@ -127,7 +128,7 @@
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			if (*pv_vg_name(pv))
+			if (!is_orphan(pv))
 				unlock_vg(cmd, pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
@@ -137,7 +138,7 @@
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			if (*pv_vg_name(pv))
+			if (!is_orphan(pv))
 				unlock_vg(cmd, pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
@@ -180,7 +181,7 @@
 			return 0;
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
-		if (*pv_vg_name(pv)) {
+		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
 			orig_pe_alloc_count = pv_pe_alloc_count(pv);
 			pv->vg_name = ORPHAN;
@@ -196,7 +197,7 @@
 	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*pv_vg_name(pv)) {
+	if (!is_orphan(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
--- LVM2/tools/pvdisplay.c	2007/10/12 14:29:32	1.39
+++ LVM2/tools/pvdisplay.c	2007/11/02 14:54:40	1.40
@@ -56,7 +56,7 @@
 		 pv = pvl->pv;
 	}
 
-	if (!*pv_vg_name(pv))
+	if (is_orphan(pv))
 		size = pv_size(pv);
 	else
 		size = (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * 
@@ -72,7 +72,7 @@
 		log_print("Physical volume \"%s\" of volume group \"%s\" "
 			  "is exported", pv_name, pv_vg_name(pv));
 
-	if (!pv_vg_name(pv))
+	if (is_orphan(pv))
 		log_print("\"%s\" is a new physical volume of \"%s\"",
 			  pv_name, display_size(cmd, size));
 
--- LVM2/tools/pvscan.c	2007/10/12 14:29:32	1.43
+++ LVM2/tools/pvscan.c	2007/11/02 14:54:40	1.44
@@ -62,7 +62,7 @@
 		sprintf(pv_tmp_name, "%s", pv_dev_name(pv));
 	}
 
-	if (!*pv_vg_name(pv)) {
+	if (is_orphan(pv)) {
 		log_print("PV %-*s    %-*s %s [%s]",
 			  pv_max_name_len, pv_tmp_name,
 			  vg_max_name_len, " ",
@@ -144,7 +144,7 @@
 
 		if ((arg_count(cmd, exported_ARG)
 		     && !(pv_status(pv) & EXPORTED_VG))
-		    || (arg_count(cmd, novolumegroup_ARG) && (*pv_vg_name(pv)))) {
+		    || (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
 			list_del(&pvl->list);
 			continue;
 		}
@@ -161,7 +161,7 @@
 ********/
 		pvs_found++;
 
-		if (!*pv_vg_name(pv)) {
+		if (is_orphan(pv)) {
 			new_pvs_found++;
 			size_new += pv_size(pv);
 			size_total += pv_size(pv);


