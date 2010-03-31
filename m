From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: 31 Mar 2010 12:06:32 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c lib/meta ...
Message-ID: <20100331120632.12787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2010-03-31 12:06:31

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c metadata.c 

Log message:
	A missing space in the error message.
	Add missing parentheses to an error message
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1491&r2=1.1492
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.324&r2=1.325

--- LVM2/WHATS_NEW	2010/03/31 12:01:49	1.1491
+++ LVM2/WHATS_NEW	2010/03/31 12:06:30	1.1492
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix two messages, add a whitespace and parentheses
   When dmeventd is not forking because of -d flag, don't kill the parent process
   Fix 'make install' when $(builddir) is different from $(srcdir).
   Fix dso resource leak in error path of dmeventd.
--- LVM2/lib/metadata/merge.c	2008/11/03 22:14:29	1.36
+++ LVM2/lib/metadata/merge.c	2010/03/31 12:06:30	1.37
@@ -233,7 +233,7 @@
 			}
 		if (!seg_found) {
 			log_error("LV segment %s:%" PRIu32 "-%" PRIu32
-				  "is incorrectly listed as being used by LV %s",
+				  " is incorrectly listed as being used by LV %s",
 				  seg->lv->name, seg->le, seg->le + seg->len - 1,
 				  lv->name);
 			r = 0;
--- LVM2/lib/metadata/metadata.c	2010/03/18 17:29:12	1.324
+++ LVM2/lib/metadata/metadata.c	2010/03/31 12:06:30	1.325
@@ -2207,7 +2207,7 @@
 	if (((uint32_t) dm_list_size(&vg->lvs)) !=
 	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
 		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs %u in VG %s",
+			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs (%u) in VG %s",
 			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
 			  snapshot_count(vg), hidden_lv_count, vg->name);
 		r = 0;


