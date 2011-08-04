From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 15:18:11 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20110804151811.479.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 15:18:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Remove unused inconsistent_seqno
	
	Last usage was removed in Petr's commit related to VG mda repair fix
	where relaxed check starts to ignore inconsistencies coming from
	PVs that are marked MISSING - thus removing unused variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2051&r2=1.2052
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.459&r2=1.460

--- LVM2/WHATS_NEW	2011/08/04 14:30:51	1.2051
+++ LVM2/WHATS_NEW	2011/08/04 15:18:10	1.2052
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Remove unused inconsistent_seqno variable in _vg_read().
   Remove meaningless const type qualifiers on cast type.
   Fix memory leak in dmsetup _message() memory allocation error path.
   Add test for fcntl error in singlenode client code.
--- LVM2/lib/metadata/metadata.c	2011/06/17 14:39:10	1.459
+++ LVM2/lib/metadata/metadata.c	2011/08/04 15:18:11	1.460
@@ -2835,7 +2835,6 @@
 	int inconsistent = 0;
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
-	int inconsistent_seqno = 0;
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
 	unsigned use_precommitted = precommitted;
@@ -2931,10 +2930,9 @@
 				log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
 						  "as global/metadata_read_only is set.",
 						  vgname, vg->seqno, correct_vg->seqno);
-			else {
+			else
 				inconsistent = 1;
-				inconsistent_seqno = 1;
-			}
+
 			if (vg->seqno > correct_vg->seqno) {
 				free_vg(correct_vg);
 				correct_vg = vg;
@@ -3100,10 +3098,9 @@
 					log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
 							  "as global/metadata_read_only is set.",
 							  vgname, vg->seqno, correct_vg->seqno);
-				else {
+				else
 					inconsistent = 1;
-					inconsistent_seqno = 1;
-				}
+
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					_free_pv_list(&all_pvs);
 					free_vg(vg);


