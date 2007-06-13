From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 22:16:27 -0000
Subject: LVM2/tools pvresize.c
Message-ID: <20070613221627.20634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 22:16:27

Modified files:
	tools          : pvresize.c 

Log message:
	Convert pv->pe_start to get_pv_pe_start

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/tools/pvresize.c	2007/06/06 19:40:28	1.4
+++ LVM2/tools/pvresize.c	2007/06/13 22:16:27	1.5
@@ -125,9 +125,9 @@
 		return ECMD_FAILED;
 	}
 
-	if (size < pv->pe_start) {
+	if (size < get_pv_pe_start(pv)) {
 		log_error("%s: Size must exceed physical extent start of "
-			  "%" PRIu64 " sectors.", pv_name, pv->pe_start);
+			  "%" PRIu64 " sectors.", pv_name, get_pv_pe_start(pv));
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
@@ -135,7 +135,7 @@
 	pv->size = size;
 
 	if (vg) {
-		pv->size -= pv->pe_start;
+		pv->size -= get_pv_pe_start(pv);
 		new_pe_count = pv->size / vg->extent_size;
 		
  		if (!new_pe_count) {


