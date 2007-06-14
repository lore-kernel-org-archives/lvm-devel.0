From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jun 2007 15:25:36 -0000
Subject: LVM2/tools pvchange.c pvdisplay.c pvmove.c pvr ...
Message-ID: <20070614152536.21400.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-14 15:25:36

Modified files:
	tools          : pvchange.c pvdisplay.c pvmove.c pvremove.c 
	                 pvresize.c pvscan.c reporter.c 

Log message:
	Convert pv->vg_name to get_pv_vg_name

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/tools/pvchange.c	2007/06/13 23:53:38	1.49
+++ LVM2/tools/pvchange.c	2007/06/14 15:25:35	1.50
@@ -55,12 +55,12 @@
 		log_verbose("Finding volume group of physical volume \"%s\"",
 			    pv_name);
 
-		if (!lock_vol(cmd, pv->vg_name, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_WRITE)) {
 			log_error("Can't get lock for %s", get_pv_vg_name(pv));
 			return 0;
 		}
 
-		if (!(vg = vg_read(cmd, pv->vg_name, NULL, &consistent))) {
+		if (!(vg = vg_read(cmd, get_pv_vg_name(pv), NULL, &consistent))) {
 			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
@@ -115,7 +115,7 @@
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
-		if (!*pv->vg_name &&
+		if (!*get_pv_vg_name(pv) &&
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
@@ -181,7 +181,7 @@
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (*get_pv_vg_name(pv)) {
-			orig_vg_name = pv->vg_name;
+			orig_vg_name = get_pv_vg_name(pv);
 			orig_pe_alloc_count = get_pv_pe_alloc_count(pv);
 			pv->vg_name = ORPHAN;
 			pv->pe_alloc_count = 0;
--- LVM2/tools/pvdisplay.c	2007/06/13 23:53:38	1.35
+++ LVM2/tools/pvdisplay.c	2007/06/14 15:25:36	1.36
@@ -27,12 +27,12 @@
 	const char *pv_name = dev_name(get_pv_dev(pv));
 
 	 if (get_pv_vg_name(pv)) {
-	         if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
+	         if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
 	                 log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 	                 return ECMD_FAILED;
 	         }
 
-	         if (!(vg = vg_read(cmd, pv->vg_name, (char *)&pv->vgid, &consistent))) {
+	         if (!(vg = vg_read(cmd, get_pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
 	                 log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 	                 goto out;
 	         }
--- LVM2/tools/pvmove.c	2007/06/13 23:53:38	1.36
+++ LVM2/tools/pvmove.c	2007/06/14 15:25:36	1.37
@@ -281,7 +281,7 @@
 	}
 
 	if (arg_count(cmd, name_ARG)) {
-		if (!(lv_name = _extract_lvname(cmd, pv->vg_name,
+		if (!(lv_name = _extract_lvname(cmd, get_pv_vg_name(pv),
 						arg_value(cmd, name_ARG)))) {
 			stack;
 			return EINVALID_CMD_LINE;
--- LVM2/tools/pvremove.c	2007/06/13 23:53:38	1.13
+++ LVM2/tools/pvremove.c	2007/06/14 15:25:36	1.14
@@ -65,7 +65,7 @@
 		log_print("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
 			  pv->vg_name[0] ? " of volume group \"" : "",
-			  pv->vg_name[0] ? pv->vg_name : "",
+			  pv->vg_name[0] ? get_pv_vg_name(pv) : "",
 			  pv->vg_name[0] ? "\"" : "");
 	}
 
--- LVM2/tools/pvresize.c	2007/06/13 23:53:38	1.9
+++ LVM2/tools/pvresize.c	2007/06/14 15:25:36	1.10
@@ -63,7 +63,7 @@
 			return ECMD_FAILED;
 		}
 	} else {
-		vg_name = pv->vg_name;
+		vg_name = get_pv_vg_name(pv);
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for %s", get_pv_vg_name(pv));
--- LVM2/tools/pvscan.c	2007/06/13 23:53:38	1.37
+++ LVM2/tools/pvscan.c	2007/06/14 15:25:36	1.38
@@ -72,7 +72,7 @@
 	}
 
 	if (get_pv_status(pv) & EXPORTED_VG) {
-		strncpy(vg_name_this, pv->vg_name, vg_name_len);
+		strncpy(vg_name_this, get_pv_vg_name(pv), vg_name_len);
 		log_print("PV %-*s  is in exported VG %s "
 			  "[%s / %s free]",
 			  pv_max_name_len, pv_tmp_name,
--- LVM2/tools/reporter.c	2007/06/13 23:53:38	1.23
+++ LVM2/tools/reporter.c	2007/06/14 15:25:36	1.24
@@ -61,12 +61,12 @@
 	struct physical_volume *pv = pvseg->pv;
 	int ret = ECMD_PROCESSED;
 
-	if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
+	if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
 		log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 		return ECMD_FAILED;
 	}
 
-	if (!(vg = vg_read(cmd, pv->vg_name, NULL, &consistent))) {
+	if (!(vg = vg_read(cmd, get_pv_vg_name(pv), NULL, &consistent))) {
 		log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 		goto out;
 	}
@@ -107,12 +107,12 @@
 	int ret = ECMD_PROCESSED;
 
 	if (get_pv_vg_name(pv)) {
-		if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
+		if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
 			log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
-		if (!(vg = vg_read(cmd, pv->vg_name, (char *)&pv->vgid, &consistent))) {
+		if (!(vg = vg_read(cmd, get_pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
 			log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 			goto out;
 		}


