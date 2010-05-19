From: agk@sourceware.org <agk@sourceware.org>
Date: 19 May 2010 01:16:50 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/lock ...
Message-ID: <20100519011650.9241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-19 01:16:41

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/locking    : locking.c 
	lib/metadata   : metadata.c 
	tools          : pvresize.c 

Log message:
	Accept orphan VG names as parameters to lock_vol() and related functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1563&r2=1.1564
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.339&r2=1.340
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2010/05/19 00:52:55	1.1563
+++ LVM2/WHATS_NEW	2010/05/19 01:16:40	1.1564
@@ -1,5 +1,6 @@
 Version 2.02.66 - 
 ===============================
+  Accept orphan VG names as parameters to lock_vol() and related functions.
   Use is_orphan_vg in place of hard-coded prefix tests.
 
 Version 2.02.65 - 17th May 2010
--- LVM2/lib/cache/lvmcache.c	2010/05/19 00:52:55	1.87
+++ LVM2/lib/cache/lvmcache.c	2010/05/19 01:16:40	1.88
@@ -290,7 +290,7 @@
 	if (!_lock_hash)
 		return 0;
 
-	return dm_hash_lookup(_lock_hash, vgname) ? 1 : 0;
+	return dm_hash_lookup(_lock_hash, is_orphan_vg(vgname) ? VG_ORPHANS : vgname) ? 1 : 0;
 }
 
 void lvmcache_unlock_vgname(const char *vgname)
--- LVM2/lib/locking/locking.c	2010/05/19 00:52:55	1.81
+++ LVM2/lib/locking/locking.c	2010/05/19 01:16:41	1.82
@@ -417,16 +417,16 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		/*
-		 * VG locks alphabetical, ORPHAN lock last
-		 */
 		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
 
-		if (!is_orphan_vg(vol) && 
-		    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
-		    (!(flags & LCK_CACHE)) &&
-		    !lvmcache_verify_lock_order(vol))
+		/* Global VG_ORPHANS lock covers all orphan formats. */
+		if (is_orphan_vg(vol))
+			vol = VG_ORPHANS;
+		/* VG locks alphabetical, ORPHAN lock last */
+		else if (((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
+			 !(flags & LCK_CACHE) &&
+			 !lvmcache_verify_lock_order(vol))
 			return 0;
 
 		/* Lock VG to change on-disk metadata. */
--- LVM2/lib/metadata/metadata.c	2010/05/14 15:19:43	1.339
+++ LVM2/lib/metadata/metadata.c	2010/05/19 01:16:41	1.340
@@ -3459,7 +3459,7 @@
 	return !_vg_bad_status_bits(vg, status);
 }
 
-static struct volume_group *_recover_vg(struct cmd_context *cmd, const char *lock_name,
+static struct volume_group *_recover_vg(struct cmd_context *cmd,
 			 const char *vg_name, const char *vgid,
 			 uint32_t lock_flags)
 {
@@ -3469,11 +3469,11 @@
 	lock_flags &= ~LCK_TYPE_MASK;
 	lock_flags |= LCK_WRITE;
 
-	unlock_vg(cmd, lock_name);
+	unlock_vg(cmd, vg_name);
 
 	dev_close_all();
 
-	if (!lock_vol(cmd, lock_name, lock_flags))
+	if (!lock_vol(cmd, vg_name, lock_flags))
 		return_NULL;
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
@@ -3503,7 +3503,6 @@
 			       uint64_t status_flags, uint32_t misc_flags)
 {
 	struct volume_group *vg = NULL;
-	const char *lock_name;
  	int consistent = 1;
 	int consistent_in;
 	uint32_t failure = 0;
@@ -3518,11 +3517,10 @@
 		return NULL;
 	}
 
-	lock_name = is_orphan_vg(vg_name) ? VG_ORPHANS : vg_name;
-	already_locked = vgname_is_locked(lock_name);
+	already_locked = vgname_is_locked(vg_name);
 
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
-	    !lock_vol(cmd, lock_name, lock_flags)) {
+	    !lock_vol(cmd, vg_name, lock_flags)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
@@ -3555,7 +3553,7 @@
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
 		vg_release(vg);
-		if (!(vg = _recover_vg(cmd, lock_name, vg_name, vgid, lock_flags))) {
+		if (!(vg = _recover_vg(cmd, vg_name, vgid, lock_flags))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
@@ -3592,7 +3590,7 @@
 
 bad:
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK))
-		unlock_vg(cmd, lock_name);
+		unlock_vg(cmd, vg_name);
 
 	return _vg_make_handle(cmd, vg, failure);
 }
--- LVM2/tools/pvresize.c	2009/12/11 13:11:56	1.34
+++ LVM2/tools/pvresize.c	2010/05/19 01:16:41	1.35
@@ -34,15 +34,14 @@
 	int r = 0;
 	struct dm_list mdas;
 	const char *pv_name = pv_dev_name(pv);
-	const char *vg_name;
+	const char *vg_name = pv_vg_name(pv);
 	struct lvmcache_info *info;
 	int mda_count = 0;
 	struct volume_group *old_vg = vg;
 
 	dm_list_init(&mdas);
 
-	if (is_orphan_vg(pv_vg_name(pv))) {
-		vg_name = VG_ORPHANS;
+	if (is_orphan_vg(vg_name)) {
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphans");
 			return 0;
@@ -56,8 +55,6 @@
 
 		mda_count = dm_list_size(&mdas);
 	} else {
-		vg_name = pv_vg_name(pv);
-
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
 		if (vg_read_error(vg)) {
@@ -70,7 +67,7 @@
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
-			goto bad;
+			goto out;
 		}
 
 		pv = pvl->pv;
@@ -78,31 +75,31 @@
 		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("Can't get info for PV %s in volume group %s",
 				  pv_name, vg->name);
-			goto bad;
+			goto out;
 		}
 
 		mda_count = dm_list_size(&info->mdas);
 
 		if (!archive(vg))
-			goto bad;
+			goto out;
 	}
 
 	/* FIXME Create function to test compatibility properly */
 	if (mda_count > 1) {
 		log_error("%s: too many metadata areas for pvresize", pv_name);
-		goto bad;
+		goto out;
 	}
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
 		log_error("Physical volume %s format does not support resizing.",
 			  pv_name);
-		goto bad;
+		goto out;
 	}
 
 	/* Get new size */
 	if (!dev_get_size(pv_dev(pv), &size)) {
 		log_error("%s: Couldn't get size.", pv_name);
-		goto bad;
+		goto out;
 	}
 
 	if (new_size) {
@@ -117,13 +114,13 @@
 	if (size < PV_MIN_SIZE) {
 		log_error("%s: Size must exceed minimum of %ld sectors.",
 			  pv_name, PV_MIN_SIZE);
-		goto bad;
+		goto out;
 	}
 
 	if (size < pv_pe_start(pv)) {
 		log_error("%s: Size must exceed physical extent start of "
 			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
-		goto bad;
+		goto out;
 	}
 
 	pv->size = size;
@@ -137,34 +134,34 @@
 				  "least one physical extent of "
 				  "%" PRIu32 " sectors.", pv_name,
 				  pv_pe_size(pv));
-			goto bad;
+			goto out;
 		}
 
 		if (!pv_resize(pv, vg, new_pe_count))
-			goto_bad;
+			goto_out;
 	}
 
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
 		    pv_name, pv_size(pv));
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (!is_orphan_vg(pv_vg_name(pv))) {
+	if (!is_orphan_vg(vg_name)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			goto bad;
+			goto out;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		goto bad;;
+		goto out;
 	}
 
 	log_print("Physical volume \"%s\" changed", pv_name);
 	r = 1;
 
-bad:
+out:
 	unlock_vg(cmd, vg_name);
 	if (!old_vg)
 		vg_release(vg);


