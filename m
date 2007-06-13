From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 22:11:29 -0000
Subject: LVM2/tools pvscan.c vgreduce.c vgsplit.c
Message-ID: <20070613221129.19827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 22:11:29

Modified files:
	tools          : pvscan.c vgreduce.c vgsplit.c 

Log message:
	Convert pv->pe_count to get_pv_pe_count

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/tools/pvscan.c	2007/06/13 22:04:45	1.31
+++ LVM2/tools/pvscan.c	2007/06/13 22:11:29	1.32
@@ -77,7 +77,7 @@
 			  "[%s / %s free]",
 			  pv_max_name_len, pv_tmp_name,
 			  vg_name_this,
-			  display_size(cmd, (uint64_t) pv->pe_count *
+			  display_size(cmd, (uint64_t) get_pv_pe_count(pv) *
 				       pv->pe_size),
 			  display_size(cmd, (uint64_t) (pv->pe_count -
 							pv->pe_alloc_count)
@@ -89,7 +89,7 @@
 	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
 		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
 		  pv->fmt ? pv->fmt->name : "    ",
-		  display_size(cmd, (uint64_t) pv->pe_count * pv->pe_size),
+		  display_size(cmd, (uint64_t) get_pv_pe_count(pv) * pv->pe_size),
 		  display_size(cmd,
 			       (uint64_t) (pv->pe_count - get_pv_pe_alloc_count(pv)) *
 					   pv->pe_size));
@@ -158,7 +158,7 @@
 			size_new += pv->size;
 			size_total += pv->size;
 		} else
-			size_total += pv->pe_count * pv->pe_size;
+			size_total += get_pv_pe_count(pv) * pv->pe_size;
 	}
 
 	/* find maximum pv name length */
--- LVM2/tools/vgreduce.c	2007/06/13 22:04:45	1.60
+++ LVM2/tools/vgreduce.c	2007/06/13 22:11:29	1.61
@@ -397,8 +397,8 @@
 	}
 
 	vg->pv_count--;
-	vg->free_count -= pv->pe_count - get_pv_pe_alloc_count(pv);
-	vg->extent_count -= pv->pe_count;
+	vg->free_count -= get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
+	vg->extent_count -= get_pv_pe_count(pv);
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		log_error("Removal of physical volume \"%s\" from "
--- LVM2/tools/vgsplit.c	2007/06/13 22:04:45	1.27
+++ LVM2/tools/vgsplit.c	2007/06/13 22:11:29	1.28
@@ -35,11 +35,11 @@
 
 	pv = list_item(pvl, struct pv_list)->pv;
 
-	vg_from->extent_count -= pv->pe_count;
-	vg_to->extent_count += pv->pe_count;
+	vg_from->extent_count -= get_pv_pe_count(pv);
+	vg_to->extent_count += get_pv_pe_count(pv);
 
-	vg_from->free_count -= pv->pe_count - get_pv_pe_alloc_count(pv);
-	vg_to->free_count += pv->pe_count - get_pv_pe_alloc_count(pv);
+	vg_from->free_count -= get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
+	vg_to->free_count += get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
 
 	return 1;
 }


