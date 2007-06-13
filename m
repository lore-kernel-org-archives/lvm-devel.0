From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 23:33:45 -0000
Subject: LVM2/tools pvchange.c pvdisplay.c pvscan.c
Message-ID: <20070613233345.22903.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 23:33:45

Modified files:
	tools          : pvchange.c pvdisplay.c pvscan.c 

Log message:
	Convert pv->status to get_pv_status

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/tools/pvchange.c	2007/06/13 23:29:33	1.47
+++ LVM2/tools/pvchange.c	2007/06/13 23:33:45	1.48
@@ -124,7 +124,7 @@
 		}
 
 		/* change allocatability for a PV */
-		if (allocatable && (pv->status & ALLOCATABLE_PV)) {
+		if (allocatable && (get_pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
 			if (*pv->vg_name)
@@ -134,7 +134,7 @@
 			return 1;
 		}
 
-		if (!allocatable && !(pv->status & ALLOCATABLE_PV)) {
+		if (!allocatable && !(get_pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
 			if (*pv->vg_name)
--- LVM2/tools/pvdisplay.c	2007/06/13 23:29:33	1.33
+++ LVM2/tools/pvdisplay.c	2007/06/13 23:33:45	1.34
@@ -68,7 +68,7 @@
 		goto out;
 	}
 
-	if (pv->status & EXPORTED_VG)
+	if (get_pv_status(pv) & EXPORTED_VG)
 		log_print("Physical volume \"%s\" of volume group \"%s\" "
 			  "is exported", pv_name, pv->vg_name);
 
--- LVM2/tools/pvscan.c	2007/06/13 23:29:33	1.35
+++ LVM2/tools/pvscan.c	2007/06/13 23:33:45	1.36
@@ -71,7 +71,7 @@
 		return;
 	}
 
-	if (pv->status & EXPORTED_VG) {
+	if (get_pv_status(pv) & EXPORTED_VG) {
 		strncpy(vg_name_this, pv->vg_name, vg_name_len);
 		log_print("PV %-*s  is in exported VG %s "
 			  "[%s / %s free]",
@@ -136,7 +136,7 @@
 		pv = pvl->pv;
 
 		if ((arg_count(cmd, exported_ARG)
-		     && !(pv->status & EXPORTED_VG))
+		     && !(get_pv_status(pv) & EXPORTED_VG))
 		    || (arg_count(cmd, novolumegroup_ARG) && (*pv->vg_name))) {
 			list_del(&pvl->list);
 			continue;


