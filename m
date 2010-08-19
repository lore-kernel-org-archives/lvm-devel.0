From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Aug 2010 23:26:33 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenod ...
Message-ID: <20100819232633.4547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-19 23:26:32

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c 
	lib/metadata   : metadata.c 

Log message:
	Fix wrong use of LCK_WRITE
	
	In all top vg read functions only LCK_VG_READ/WRITE can be used.
	All other vg lock definitions are low-level backend machinery.
	
	Moreover, LCK_WRITE cannot be tested through bitmask.
	This patch fixes these mistakes.
	
	For _recover_vg() we do not need lock_flags, it can be only
	two of above and we always upgrading to LCK_VG_WRITE lock there.
	(N.B. that code is racy)
	
	There is no functional change in code (despite wrong masking
	it produces correct bits:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1716&r2=1.1717
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.393&r2=1.394

--- LVM2/WHATS_NEW	2010/08/19 23:08:18	1.1716
+++ LVM2/WHATS_NEW	2010/08/19 23:26:31	1.1717
@@ -4,6 +4,7 @@
   Remove assumption that --yes must be used only in --force mode.
   Fix file descriptor leak in swap signature detection error path.
   Detect and allow abort in pvcreate if LUKS signature is detected.
+  Use proper locks mask when checking for LCK_WRITE.
 
 Version 2.02.73 - 18th August 2010
 ==================================
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/17 19:25:05	1.7
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/19 23:26:31	1.8
@@ -155,11 +155,13 @@
 		if (!_resources[i])
 			break;
 		if (!strcmp(_resources[i], resource)) {
-			if ((_locks[i] & LCK_WRITE) || (_locks[i] & LCK_EXCL)) {
+			if ((_locks[i] & LCK_TYPE_MASK) == LCK_WRITE ||
+			    (_locks[i] & LCK_TYPE_MASK) == LCK_EXCL) {
 				DEBUGLOG("%s already write/exclusively locked...\n", resource);
 				goto maybe_retry;
 			}
-			if ((mode & LCK_WRITE) || (mode & LCK_EXCL)) {
+			if ((mode & LCK_TYPE_MASK) == LCK_WRITE ||
+			    (mode & LCK_TYPE_MASK) == LCK_EXCL) {
 				DEBUGLOG("%s already locked and WRITE/EXCL lock requested...\n",
 					 resource);
 				goto maybe_retry;
--- LVM2/lib/metadata/metadata.c	2010/08/19 23:08:18	1.393
+++ LVM2/lib/metadata/metadata.c	2010/08/19 23:26:32	1.394
@@ -3834,20 +3834,16 @@
 }
 
 static struct volume_group *_recover_vg(struct cmd_context *cmd,
-			 const char *vg_name, const char *vgid,
-			 uint32_t lock_flags)
+			 const char *vg_name, const char *vgid)
 {
 	int consistent = 1;
 	struct volume_group *vg;
 
-	lock_flags &= ~LCK_TYPE_MASK;
-	lock_flags |= LCK_WRITE;
-
 	unlock_vg(cmd, vg_name);
 
 	dev_close_all();
 
-	if (!lock_vol(cmd, vg_name, lock_flags))
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE))
 		return_NULL;
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
@@ -3882,7 +3878,7 @@
 	uint32_t failure = 0;
 	int already_locked;
 
-	if (misc_flags & READ_ALLOW_INCONSISTENT || !(lock_flags & LCK_WRITE))
+	if (misc_flags & READ_ALLOW_INCONSISTENT || lock_flags != LCK_VG_WRITE)
 		consistent = 0;
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
@@ -3927,7 +3923,7 @@
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
 		vg_release(vg);
-		if (!(vg = _recover_vg(cmd, vg_name, vgid, lock_flags))) {
+		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
@@ -3941,7 +3937,7 @@
 	 */
 
 	if (!cmd->handles_missing_pvs && vg_missing_pv_count(vg) &&
-	    (lock_flags & LCK_WRITE)) {
+	    lock_flags == LCK_VG_WRITE) {
 		log_error("Cannot change VG %s while PVs are missing.", vg->name);
 		log_error("Consider vgreduce --removemissing.");
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
@@ -3949,7 +3945,7 @@
 	}
 
 	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) &&
-	    (lock_flags & LCK_WRITE)) {
+	    lock_flags == LCK_VG_WRITE) {
 		log_error("Cannot change VG %s with unknown segments in it!",
 			  vg->name);
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */


