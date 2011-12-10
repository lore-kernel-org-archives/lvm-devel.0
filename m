From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Dec 2011 00:47:24 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111210004724.2181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-10 00:47:23

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	update FIXMEs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/lib/metadata/thin_manip.c	2011/11/10 12:43:05	1.26
+++ LVM2/lib/metadata/thin_manip.c	2011/12/10 00:47:23	1.27
@@ -244,6 +244,7 @@
 	return max_id;
 }
 
+// FIXME Rename this fn: it doesn't extend an already-existing pool AFAICT
 int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size)
 {
@@ -285,10 +286,8 @@
 		 * FIXME: implement lazy clearing when activation is disabled
 		 */
 
-		// FIXME: activate_lv_local_excl is actually wanted here
+		/* pool_lv is a new LV so the VG lock protects us */
 		if (!activate_lv_local(pool_lv->vg->cmd, pool_lv) ||
-		    // FIXME: maybe -zero n  should  allow to recreate same thin pool
-		    // and different option should be used for zero_new_blocks
 		    /* Clear 4KB of metadata device for new thin-pool. */
 		    !set_lv(pool_lv->vg->cmd, pool_lv, UINT64_C(0), 0)) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",


