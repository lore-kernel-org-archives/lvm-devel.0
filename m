From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 15:14:57 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090728151457.9129.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 15:14:57

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_lv.c lvm_vg.c 

Log message:
	Add an open_mode to the vg struct for liblvm - enforce read / write semantics.
	
	For now, a simple way to enforce the read/write semantics is to just save the
	open mode of the VG.  If the caller uses lvm_vg_create, the mode is write.
	The caller using lvm_vg_open can use either read or write to open the VG.
	Once we have this, we enforce the permissions on each API call and don't allow
	a caller to modify a VG that has not been opened properly.
	
	This may be better combined with the locking mode, but I view that as future
	cleanup, past this initial release.  The intial release should enforce the
	basic object semantics though, as described in the lvm.h file.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.271&r2=1.272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/metadata/metadata-exported.h	2009/07/28 13:17:04	1.104
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/28 15:14:56	1.105
@@ -247,6 +247,7 @@
 	 * They have to get cleared on vg_commit.
 	 */
 	struct dm_list removed_pvs;
+	uint32_t open_mode; /* FIXME: read or write - check lock type? */
 
 	/*
 	 * Store result of the last vg_read().
@@ -713,6 +714,7 @@
 uint64_t vg_extent_count(const vg_t *vg);
 uint64_t vg_free_count(const vg_t *vg);
 uint64_t vg_pv_count(const vg_t *vg);
+int vg_check_write_mode(vg_t *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
 struct vgcreate_params {
--- LVM2/lib/metadata/metadata.c	2009/07/28 13:17:04	1.271
+++ LVM2/lib/metadata/metadata.c	2009/07/28 15:14:56	1.272
@@ -3042,6 +3042,16 @@
 	return 1;
 }
 
+/* FIXME: remove / combine this with locking? */
+int vg_check_write_mode(vg_t *vg)
+{
+	if (vg->open_mode != 'w') {
+		log_errno(EPERM, "Attempt to modify a read-only VG\n");
+		return 0;
+	}
+	return 1;
+}
+
 /*
  * Performs a set of checks against a VG according to bits set in status
  * and returns FAILED_* bits for those that aren't acceptable.
--- LVM2/liblvm/lvm_lv.c	2009/07/28 13:16:40	1.11
+++ LVM2/liblvm/lvm_lv.c	2009/07/28 15:14:56	1.12
@@ -107,9 +107,10 @@
 	uint64_t extents;
 	struct lv_list *lvl;
 
-	/* FIXME: check for proper VG access */
 	if (vg_read_error(vg))
 		return NULL;
+	if (!vg_check_write_mode(vg))
+		return NULL;
 	memset(&lp, 0, sizeof(lp));
 	extents = extents_from_size(vg->cmd, size, vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
@@ -130,6 +131,8 @@
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
 		return -1;
+	if (!vg_check_write_mode(lv->vg))
+		return -1;
 	if (!lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT))
 		return -1;
 	return 0;
--- LVM2/liblvm/lvm_vg.c	2009/07/28 13:17:04	1.22
+++ LVM2/liblvm/lvm_vg.c	2009/07/28 15:14:56	1.23
@@ -35,6 +35,7 @@
 		vg_release(vg);
 		return NULL;
 	}
+	vg->open_mode = 'w';
 	return vg;
 }
 
@@ -43,6 +44,9 @@
 	if (vg_read_error(vg))
 		return -1;
 
+	if (!vg_check_write_mode(vg))
+		return -1;
+
 	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return -1;
@@ -72,6 +76,8 @@
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_reduce(vg, (char *)device))
 		return -1;
@@ -82,6 +88,8 @@
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_set_extent_size(vg, new_size))
 		return -1;
@@ -94,6 +102,8 @@
 
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (dm_list_empty(&vg->pvs)) {
 		log_error("Volume group %s does not contain any "
@@ -140,6 +150,8 @@
 {
 	if (vg_read_error(vg))
 		return -1;
+	if (!vg_check_write_mode(vg))
+		return -1;
 
 	if (!vg_remove_single(vg))
 		return -1;
@@ -165,6 +177,8 @@
 		vg_release(vg);
 		return NULL;
 	}
+	/* FIXME: combine this with locking ? */
+	vg->open_mode = mode[0];
 
 	return vg;
 }


