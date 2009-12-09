From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:53:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20091209195340.30677.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:53:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Call explicitly suspend for temporary mirror layer.
	
	The memlock_inc() fix is wrong, memlock count is not
	propagated to long living process (clvmd) and just
	it underflow there.
	Also suspend is needed to pre-load precommited metadata
	on other nodes (remapping to error taget in this case).
	
	With explicit suspend we generate lock request and code
	can update memlock count.
	
	(Infinitely "locked" memory caused that fs_unlock() was not
	called properly and on cluster nodes remains
	old links in /dev/mapper for not active devices.)
	
	(N.B. failing of suspend call here is not handled as fatal
	error - the LV is going to be removed later anyway.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1349&r2=1.1350
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2009/12/09 19:29:04	1.1349
+++ LVM2/WHATS_NEW	2009/12/09 19:53:39	1.1350
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Explicitly call suspend for temporary mirror layer.
   Allow use precommited metadata when a PV is missing.
   Add memlock information to do_lock_lv debug output.
   Never use distributed lock for LV in non-clustered VG.
--- LVM2/lib/metadata/mirror.c	2009/12/09 19:43:39	1.98
+++ LVM2/lib/metadata/mirror.c	2009/12/09 19:53:39	1.99
@@ -603,6 +603,16 @@
 		return 0;
 	}
 
+	/* FIXME: second suspend should not be needed
+	 * Explicitly suspend temporary LV
+	 * This balance memlock_inc() calls with memlock_dec() in resume
+	 * (both localy and in cluster) and also properly propagates precommited
+	 * metadata into dm table on other nodes.
+	 * (visible flag set causes the suspend is not properly propagated?)
+	 */
+	if (temp_layer_lv && !suspend_lv(temp_layer_lv->vg->cmd, temp_layer_lv))
+		log_error("Problem suspending temporary LV %s", temp_layer_lv->name);
+
 	if (!vg_commit(mirrored_seg->lv->vg)) {
 		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
 		return 0;
@@ -616,23 +626,9 @@
 	 * As it's now detached from mirrored_seg->lv we must resume it
 	 * explicitly.
 	 */
-	if (temp_layer_lv) {
-		if (!resume_lv(temp_layer_lv->vg->cmd, temp_layer_lv)) {
-			log_error("Problem resuming temporary LV, %s", temp_layer_lv->name);
-			return 0;
-		}
-
-		/*
-		 * The code above calls a suspend_lv once, however we now need
-		 * to resume 2 LVs, due to image removal: the mirror image
-		 * itself here, and now the remaining mirror LV. Since
-		 * suspend_lv/resume_lv call memlock_inc/memlock_dec and these
-		 * need to be balanced, we need to call an extra memlock_inc()
-		 * here to balance for the this extra resume -- the following
-		 * one could otherwise either deadlock due to suspended
-		 * devices, or alternatively drop memlock_count below 0.
-		 */
-		memlock_inc();
+	if (temp_layer_lv && !resume_lv(temp_layer_lv->vg->cmd, temp_layer_lv)) {
+		log_error("Problem resuming temporary LV, %s", temp_layer_lv->name);
+		return 0;
 	}
 
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {


