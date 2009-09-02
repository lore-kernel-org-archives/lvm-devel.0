From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:34:12 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20090902213412.16031.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:34:11

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/locking    : locking.c locking.h 

Log message:
	Enforce an alphabetical lock ordering for vgname locks.
	
	Add a new constraint that vgname locks must be obtained in
	alphabetical order.  At this point, we have test coverage for
	the 3 commands affected - vgsplit, vgmerge, and vgrename.
	Tests have been updated to cover these commands.
	Going forward any command or library call that must obtain
	more than one vgname lock must do so in alphabetical order.
	Future patches will update lvm2app to enforce this ordering.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1252&r2=1.1253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2009/09/02 14:47:39	1.1252
+++ LVM2/WHATS_NEW	2009/09/02 21:34:11	1.1253
@@ -1,5 +1,7 @@
 Version 2.02.52 -
 =================================
+  Enforce an alphabetical lock ordering for vgname locks.
+  Refactor vgsplit, vgmerge, and vgrename to obey vgname ordering rules.
   Implement write lock prioritisation for file locking and make it default.
   Fix clogd build direcory.
   Drop unrequired clogd Makefile.
--- LVM2/lib/cache/lvmcache.c	2009/07/27 11:00:17	1.66
+++ LVM2/lib/cache/lvmcache.c	2009/09/02 21:34:11	1.67
@@ -186,6 +186,45 @@
 		_drop_metadata(vgname);
 }
 
+/*
+ * Ensure vgname2 comes after vgname1 alphabetically.
+ * Special VG names beginning with '#' don't count.
+ */
+static int _vgname_order_correct(const char *vgname1, const char *vgname2)
+{
+	if ((*vgname1 == '#')|(*vgname2 == '#'))
+		return 1;
+
+	if (strcmp(vgname1, vgname2) < 0)
+		return 1;
+	return 0;
+}
+
+/*
+ * Ensure VG locks are acquired in alphabetical order.
+ */
+int lvmcache_verify_lock_order(const char *vgname)
+{
+	struct dm_hash_node *n;
+	const char *vgname2;
+
+	if (!_lock_hash)
+		return_0;
+
+	dm_hash_iterate(n, _lock_hash) {
+		if (!dm_hash_get_data(_lock_hash, n))
+			return_0;
+		vgname2 = dm_hash_get_key(_lock_hash, n);
+		if (!_vgname_order_correct(vgname2, vgname)) {
+			log_errno(EDEADLK, "Internal error: VG lock %s must "
+				  "be requested before %s, not after.",
+				  vgname, vgname2);
+			return_0;
+		}
+	}
+	return 1;
+}
+
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
@@ -196,7 +235,7 @@
 	if (dm_hash_lookup(_lock_hash, vgname))
 		log_error("Internal error: Nested locking attempted on VG %s.",
 			  vgname);
-		
+
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
--- LVM2/lib/cache/lvmcache.h	2008/11/03 22:14:27	1.24
+++ LVM2/lib/cache/lvmcache.h	2009/09/02 21:34:11	1.25
@@ -84,6 +84,7 @@
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
+int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
 const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid);
--- LVM2/lib/locking/locking.c	2009/07/24 23:29:03	1.64
+++ LVM2/lib/locking/locking.c	2009/09/02 21:34:11	1.65
@@ -387,6 +387,12 @@
 		if (!_blocking_supported || vgs_locked())
 			flags |= LCK_NONBLOCK;
 
+		if (vol[0] != '#' &&
+		    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
+		    (!(flags & LCK_CACHE)) &&
+		    !lvmcache_verify_lock_order(vol))
+			return 0;
+
 		/* Lock VG to change on-disk metadata. */
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
--- LVM2/lib/locking/locking.h	2009/07/24 18:26:42	1.50
+++ LVM2/lib/locking/locking.h	2009/09/02 21:34:11	1.51
@@ -34,6 +34,8 @@
  *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
  *   char *vol holds volume group name.
  *   Set the LCK_CACHE flag to invalidate 'vol' in the internal cache.
+ *   If more than one lock needs to be held simultaneously, they must be
+ *   acquired in alphabetical order of 'vol' (to avoid deadlocks).
  *
  * LCK_LV:
  *   Lock/unlock an individual logical volume


