From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jan 2009 14:44:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20090115144450.27778.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-15 14:44:49

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Fix fsadm lvresize for filesystem block sizes != 1024.
	
	Fixes rhbz 480022.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1020&r2=1.1021
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2009/01/10 17:09:40	1.1020
+++ LVM2/WHATS_NEW	2009/01/15 14:44:48	1.1021
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix fsadm failure with block size != 1K.
   Fix pvs segfault when run with orphan PV and some VG fields.
   Display a 'dev_size' of zero for missing devices in reports.
   Add pv_mda_size to pvs and vg_mda_size to vgs.
--- LVM2/tools/lvresize.c	2008/11/03 22:14:30	1.99
+++ LVM2/tools/lvresize.c	2009/01/15 14:44:49	1.100
@@ -144,7 +144,7 @@
 		return 0;
 	}
 
-	if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64,
+	if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
 			(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
 		log_error("Couldn't generate new LV size string");
 		return 0;
@@ -635,7 +635,7 @@
 				  lp->lv_name);
 			return ECMD_FAILED;
 		}
-		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64,
+		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
 				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
 		    log_error("Couldn't generate new LV size string");
 		    return ECMD_FAILED;


