From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 13:05:09 -0000
Subject: LVM2 ./WHATS_NEW lib/format_pool/import_export.c
Message-ID: <20101201130509.15012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 13:05:08

Modified files:
	.              : WHATS_NEW 
	lib/format_pool: import_export.c 

Log message:
	Check str_list_add() success
	
	Report error if str_list_add fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1825&r2=1.1826
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2010/12/01 13:01:36	1.1825
+++ LVM2/WHATS_NEW	2010/12/01 13:05:06	1.1826
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Check str_list_add() success in _add_stripe_seg().
   Check lv_info() success in _mirrored_transient_status().
   Add backtraces for dev_set() and dev_close_immediate() errors in set_lv().
   Add logging for unlink() error in clvmd remove_lockfile().
--- LVM2/lib/format_pool/import_export.c	2010/04/13 17:26:03	1.32
+++ LVM2/lib/format_pool/import_export.c	2010/12/01 13:05:07	1.33
@@ -206,7 +206,10 @@
 			return_0;
 
 	/* add the subpool type to the segment tag list */
-	str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
+	if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
+		log_error("Allocation failed for str_list.");
+		return 0;
+	}
 
 	dm_list_add(&lv->segments, &seg->list);
 
@@ -240,7 +243,10 @@
 		}
 
 		/* add the subpool type to the segment tag list */
-		str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
+		if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
+			log_error("Allocation failed for str_list.");
+			return 0;
+		}
 
 		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0))
 			return_0;


