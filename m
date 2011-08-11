From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 17:34:32 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/meta ...
Message-ID: <20110811173432.32560.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 17:34:31

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/metadata   : metadata.c 

Log message:
	Lock memory for shared VG
	
	Use debug pool locking functionality. So the command could check,
	whether the memory in the pool has not been modified.
	
	For lv_postoder() instead of unlocking and locking for every changed
	struct status member do it once when entering and leaving function.
	(mprotect would trap each such memory access).
	Currently lv_postoder() does not modify other part of vg structure
	then status flags of each LV with flags that are reverted back to
	its original state after function exit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2065&r2=1.2066
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.464&r2=1.465

--- LVM2/WHATS_NEW	2011/08/11 17:24:23	1.2065
+++ LVM2/WHATS_NEW	2011/08/11 17:34:30	1.2066
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Use memory pool locking to check for corruption of internal VG structs.
   Cache and share generated VG structs.
   Fix possible format instance memory leaks and premature releases in _vg_read.
   Suppress locking error messages in monitoring init scripts.
--- LVM2/lib/cache/lvmcache.c	2011/08/11 17:24:24	1.114
+++ LVM2/lib/cache/lvmcache.c	2011/08/11 17:34:30	1.115
@@ -689,6 +689,9 @@
 	vginfo->vg_use_count = 0;
 	vg->vginfo = vginfo;
 
+	if (!dm_pool_lock(vg->vgmem, 1))
+		goto_bad;
+
 out:
 	vginfo->holders++;
 	vginfo->vg_use_count++;
@@ -715,6 +718,11 @@
 		log_debug("VG %s reused %d times.",
 			  vginfo->cached_vg->name, vginfo->vg_use_count);
 
+	/* Debug perform crc check only when it's been used more then once */
+	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
+			    (vginfo->vg_use_count > 1)))
+		stack;
+
 	vginfo->cached_vg->vginfo = NULL;
 	vginfo->cached_vg = NULL;
 
--- LVM2/lib/metadata/metadata.c	2011/08/11 17:24:24	1.464
+++ LVM2/lib/metadata/metadata.c	2011/08/11 17:34:31	1.465
@@ -2107,8 +2107,17 @@
 			       void *data)
 {
 	int r;
+	int pool_locked = dm_pool_locked(lv->vg->vgmem);
+
+	if (pool_locked && !dm_pool_unlock(lv->vg->vgmem, 0))
+		return_0;
+
 	r = _lv_postorder_visit(lv, fn, data);
 	_lv_postorder_cleanup(lv, 0);
+
+	if (pool_locked && !dm_pool_lock(lv->vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
@@ -2122,6 +2131,10 @@
 {
 	struct lv_list *lvl;
 	int r = 1;
+	int pool_locked = dm_pool_locked(vg->vgmem);
+
+	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
@@ -2132,6 +2145,9 @@
 	dm_list_iterate_items(lvl, &vg->lvs)
 		_lv_postorder_cleanup(lvl->lv, 0);
 
+	if (pool_locked && !dm_pool_lock(vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 


