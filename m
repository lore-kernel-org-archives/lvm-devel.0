From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 22:30:26 -0000
Subject: LVM2/tools pvdisplay.c pvresize.c pvscan.c
Message-ID: <20070613223026.26468.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 22:30:26

Modified files:
	tools          : pvdisplay.c pvresize.c pvscan.c 

Log message:
	Convert pv->pe_size to get_pv_pe_size

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/tools/pvdisplay.c	2007/06/13 22:04:45	1.30
+++ LVM2/tools/pvdisplay.c	2007/06/13 22:30:26	1.31
@@ -59,7 +59,8 @@
 	if (!*pv->vg_name)
 		size = pv->size;
 	else
-		size = (pv->pe_count - get_pv_pe_alloc_count(pv)) * pv->pe_size;
+		size = (get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv)) * 
+			get_pv_pe_size(pv);
 
 	if (arg_count(cmd, short_ARG)) {
 		log_print("Device \"%s\" has a capacity of %s", pv_name,
--- LVM2/tools/pvresize.c	2007/06/13 22:16:27	1.5
+++ LVM2/tools/pvresize.c	2007/06/13 22:30:26	1.6
@@ -142,7 +142,7 @@
 			log_error("%s: Size must leave space for at "
 				  "least one physical extent of "
 				  "%" PRIu32 " sectors.", pv_name,
-				  pv->pe_size);
+				  get_pv_pe_size(pv));
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/pvscan.c	2007/06/13 22:11:29	1.32
+++ LVM2/tools/pvscan.c	2007/06/13 22:30:26	1.33
@@ -78,10 +78,10 @@
 			  pv_max_name_len, pv_tmp_name,
 			  vg_name_this,
 			  display_size(cmd, (uint64_t) get_pv_pe_count(pv) *
-				       pv->pe_size),
-			  display_size(cmd, (uint64_t) (pv->pe_count -
-							pv->pe_alloc_count)
-				       * pv->pe_size));
+				       get_pv_pe_size(pv)),
+			  display_size(cmd, (uint64_t) (get_pv_pe_count(pv) -
+						get_pv_pe_alloc_count(pv))
+				       * get_pv_pe_size(pv)));
 		return;
 	}
 
@@ -89,10 +89,11 @@
 	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
 		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
 		  pv->fmt ? pv->fmt->name : "    ",
-		  display_size(cmd, (uint64_t) get_pv_pe_count(pv) * pv->pe_size),
-		  display_size(cmd,
-			       (uint64_t) (pv->pe_count - get_pv_pe_alloc_count(pv)) *
-					   pv->pe_size));
+		  display_size(cmd, (uint64_t) get_pv_pe_count(pv) * 
+					       get_pv_pe_size(pv)),
+		  display_size(cmd, (uint64_t) (get_pv_pe_count(pv) - 
+						get_pv_pe_alloc_count(pv)) *
+					   get_pv_pe_size(pv)));
 	return;
 }
 
@@ -158,7 +159,7 @@
 			size_new += pv->size;
 			size_total += pv->size;
 		} else
-			size_total += get_pv_pe_count(pv) * pv->pe_size;
+			size_total += get_pv_pe_count(pv) * get_pv_pe_size(pv);
 	}
 
 	/* find maximum pv name length */


