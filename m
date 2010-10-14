From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Oct 2010 20:03:14 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20101014200314.26604.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-10-14 20:03:13

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 

Log message:
	Fix for bug 637936: killing both redundant logs causes deadlock
	
	Problem:
	When both legs of a mirrored log fail, neither the log nor the parent
	mirror can proceed.  The repair code must be careful to replace the
	log with an error target before operating on the parent - otherwise,
	the parent can get stuck trying to suspend because it can't push through
	any writes.  The steps to replace the log device with an error target
	were incomplete and resulted in the replacement not happening at all!
	
	The code originally had all the necessary logic to complete the
	replacement task, but was pulled out in a effort to clean-up that
	section of code, while fixing another bug:
	<offending commit msg>
	In addition, I added following three changes.
	
	- Removed tmp_orphan_lvs handling procedure
	It seems that _delete_lv() can handle detached_log_lv properly
	without adding mirror legs in mirrored log to tmp_orphan_lvs.
	Therefore, I removed the procedure.
	
	- Removed vg_write()/vg_commit()
	Metadata is saved by vg_write()/vg_commit() just after detached_log_lv
	is handled. Therefore, I removed vg_write()/vg_commit().
	</offending commit msg>
	
	http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c?cvsroot=lvm2&f=h#rev1.130
	
	I've reverted the "clean-up" changes associated with that fix, but not what
	that commit was actually fixing.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1761&r2=1.1762
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/WHATS_NEW	2010/10/13 21:26:37	1.1761
+++ LVM2/WHATS_NEW	2010/10/14 20:03:12	1.1762
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix hang when repairing a mirrored-log that had both devs fail.
   Convey need for snapshot-merge target in lvconvert error message and man page.
   Add "devices/disable_after_error_count" to lvm.conf.
   Give correct error message when creating a too-small snapshot.
--- LVM2/lib/metadata/lv_manip.c	2010/10/13 13:52:53	1.233
+++ LVM2/lib/metadata/lv_manip.c	2010/10/14 20:03:12	1.234
@@ -462,6 +462,15 @@
 	if (!lv_empty(lv))
 		return_0;
 
+	/*
+	 * Since we are replacing the whatever-was-there with
+	 * an error segment, we should also clear any flags
+	 * that suggest it is anything other than "error".
+	 */
+	lv->status &= ~MIRRORED;
+
+	/* FIXME: Should we bug if we find a log_lv attached? */
+
 	if (!lv_add_virtual_segment(lv, 0, len,
 				    get_segtype_from_string(lv->vg->cmd,
 							    "error")))
--- LVM2/lib/metadata/mirror.c	2010/10/12 16:41:17	1.135
+++ LVM2/lib/metadata/mirror.c	2010/10/14 20:03:13	1.136
@@ -896,18 +896,40 @@
 	 */
 	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
 	    (detached_log_lv->status & PARTIAL_LV)) {
+		struct lv_segment *seg = first_seg(detached_log_lv);
+
 		log_very_verbose("%s being removed due to failures",
 				 detached_log_lv->name);
 
+		/*
+		 * We are going to replace the mirror with an
+		 * error segment, but before we do, we must remember
+		 * all of the LVs that must be deleted later (i.e.
+		 * the sub-lv's)
+		 */
+		for (m = 0; m < seg->area_count; m++) {
+			seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
+			lv_set_visible(seg_lv(seg, m));
+			if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
+						  sizeof(*lvl)))) {
+				log_error("dm_pool_alloc failed");
+				return 0;
+			}
+			lvl->lv = seg_lv(seg, m);
+			dm_list_add(&tmp_orphan_lvs, &lvl->list);
+		}
+
 		if (!replace_lv_with_error_segment(detached_log_lv)) {
 			log_error("Failed error target substitution for %s",
 				  detached_log_lv->name);
 			return 0;
 		}
 
-		/*
-		 * Flush all I/Os held by mirrored log.
-		 */
+		if (!vg_write(detached_log_lv->vg)) {
+			log_error("intermediate VG write failed.");
+			return 0;
+		}
+
 		if (!suspend_lv(detached_log_lv->vg->cmd,
 				detached_log_lv)) {
 			log_error("Failed to suspend %s",
@@ -915,8 +937,14 @@
 			return 0;
  		}
 
-		if (!resume_lv(detached_log_lv->vg->cmd,
-			       detached_log_lv)) {
+		if (!vg_commit(detached_log_lv->vg)) {
+			if (!resume_lv(detached_log_lv->vg->cmd,
+				       detached_log_lv))
+				stack;
+			return_0;
+		}
+
+		if (!resume_lv(detached_log_lv->vg->cmd, detached_log_lv)) {
 			log_error("Failed to resume %s",
 				  detached_log_lv->name);
 			return_0;


