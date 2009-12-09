From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:29:04 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20091209192904.24058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:29:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Allow manipulation with precommited metadata even when a PV is missing.
	
	The new recovery code first tries to repair LV and then removes failed PV
	from VG. It means that during operation there can be VG with PV missing,
	and vg_read code handles it like not consistent VG.
	
	We already allows returning "inconsistent" commited metadata,
	for mirror repair we need this for precommited too.
	(The suspend call prepares precommited metadata to inactive table on
	other cluster nodes.)
	
	"Inconsistent" here means - correct metadata, just with some metadata areas
	not found (obviously on missing or failed PVs).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1348&r2=1.1349
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.300&r2=1.301

--- LVM2/WHATS_NEW	2009/12/09 19:01:27	1.1348
+++ LVM2/WHATS_NEW	2009/12/09 19:29:04	1.1349
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Allow use precommited metadata when a PV is missing.
   Add memlock information to do_lock_lv debug output.
   Never use distributed lock for LV in non-clustered VG.
   Allow implicit lock conversion in pre/post callbacks on local node.
--- LVM2/lib/metadata/metadata.c	2009/12/03 19:18:34	1.300
+++ LVM2/lib/metadata/metadata.c	2009/12/09 19:29:04	1.301
@@ -2481,6 +2481,7 @@
 	int inconsistent = 0;
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
+	int inconsistent_seqno = 0;
 	unsigned use_precommitted = precommitted;
 	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
@@ -2556,6 +2557,7 @@
 		/* FIXME Also ensure contents same - checksum compare? */
 		if (correct_vg->seqno != vg->seqno) {
 			inconsistent = 1;
+			inconsistent_seqno = 1;
 			if (vg->seqno > correct_vg->seqno) {
 				vg_release(correct_vg);
 				correct_vg = vg;
@@ -2679,6 +2681,7 @@
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
+				inconsistent_seqno = 1;
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					vg_release(vg);
 					vg_release(correct_vg);
@@ -2706,6 +2709,16 @@
 		if (use_precommitted) {
 			log_error("Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
+			/* FIXME: during repair, there is inconsistent flag set because some metadata areas
+			 * are missing (on missing PVs). Code should create list of missing PVs, compare it
+			 * with PV marked missing in metadata and if equals, use it as consistent vg.
+			 * For now, return precommited metadata if remainng seq match here to allow
+			 * preloading table in suspend call.
+			 */
+			if (!inconsistent_seqno) {
+				*consistent = 0;
+				return correct_vg;
+			}
 			vg_release(correct_vg);
 			return NULL;
 		}


