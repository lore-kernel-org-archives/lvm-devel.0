From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Apr 2008 18:56:41 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/lock ...
Message-ID: <20080403185641.3595.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-03 18:56:40

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/locking    : file_locking.c 

Log message:
	Add some basic internal VG lock validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.821&r2=1.822
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/WHATS_NEW	2008/04/03 14:40:34	1.821
+++ LVM2/WHATS_NEW	2008/04/03 18:56:39	1.822
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add some basic internal VG lock validation.
   Add per-command flags to control which commands use the VG metadata cache.
   Fix vgsplit locking of new VG (2.02.30).
   Avoid erroneous vgsplit error message for new VG. (2.02.29)
--- LVM2/lib/cache/lvmcache.c	2008/04/02 21:23:39	1.41
+++ LVM2/lib/cache/lvmcache.c	2008/04/03 18:56:40	1.42
@@ -17,6 +17,7 @@
 #include "lvmcache.h"
 #include "toolcontext.h"
 #include "dev-cache.h"
+#include "locking.h"
 #include "metadata.h"
 #include "filter.h"
 #include "memlock.h"
@@ -29,6 +30,7 @@
 static struct list _vginfos;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
+static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 
 int lvmcache_init(void)
 {
@@ -46,6 +48,9 @@
 	if (!(_lock_hash = dm_hash_create(128)))
 		return 0;
 
+	if (_vg_global_lock_held)
+		lvmcache_lock_vgname(VG_GLOBAL, 0);
+
 	return 1;
 }
 
@@ -134,6 +139,10 @@
 		return;
 	}
 
+	if (dm_hash_lookup(_lock_hash, vgname))
+		log_error("Internal error: Nested locking attempted on VG %s.",
+			  vgname);
+		
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
@@ -152,6 +161,10 @@
 
 void lvmcache_unlock_vgname(const char *vgname)
 {
+	if (!dm_hash_lookup(_lock_hash, vgname))
+		log_error("Internal error: Attempt to unlock unlocked VG %s.",
+			  vgname);
+
 	_update_cache_lock_state(vgname, 0);
 
 	dm_hash_remove(_lock_hash, vgname);
@@ -1007,13 +1020,25 @@
 	} while ((vginfo = next));
 }
 
-static void _lvmcache_destroy_lockname(int present __attribute((unused)))
+static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 {
-	/* Nothing to do */
+	char *vgname;
+
+	if (!dm_hash_get_data(_lock_hash, n))
+		return;
+
+	vgname = dm_hash_get_key(_lock_hash, n);
+
+	if (!strcmp(vgname, VG_GLOBAL))
+		_vg_global_lock_held = 1;
+	else
+		log_error("Internal error: Volume Group %s was not unlocked",
+			  dm_hash_get_key(_lock_hash, n));
 }
 
 void lvmcache_destroy(void)
 {
+	struct dm_hash_node *n;
 	log_verbose("Wiping internal VG cache");
 
 	_has_scanned = 0;
@@ -1037,7 +1062,8 @@
 	}
 
 	if (_lock_hash) {
-		dm_hash_iter(_lock_hash, (dm_hash_iterate_fn) _lvmcache_destroy_lockname);
+		dm_hash_iterate(n, _lock_hash)
+			_lvmcache_destroy_lockname(n);
 		dm_hash_destroy(_lock_hash);
 		_lock_hash = NULL;
 	}
--- LVM2/lib/locking/file_locking.c	2008/01/30 13:59:59	1.34
+++ LVM2/lib/locking/file_locking.c	2008/04/03 18:56:40	1.35
@@ -221,7 +221,7 @@
 				     "%s/V_%s", _lock_dir, resource);
 
 		if (!_lock_file(lockfile, flags))
-			return 0;
+			return_0;
 
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:


