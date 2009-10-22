From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Oct 2009 17:33:10 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20091022173310.9275.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-22 17:33:09

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Remember to clear 'global lock held during cache refresh' state after use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1299&r2=1.1300
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2009/10/22 13:00:07	1.1299
+++ LVM2/WHATS_NEW	2009/10/22 17:33:09	1.1300
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Remember to clear 'global lock held during cache refresh' state after use.
   Use udev flags support in LVM.
   Delay announcing mirror monitoring to syslog until initialisation succeeded.
   Handle metadata with unknown segment types more gracefully.
--- LVM2/lib/cache/lvmcache.c	2009/09/15 13:49:11	1.69
+++ LVM2/lib/cache/lvmcache.c	2009/10/22 17:33:09	1.70
@@ -52,8 +52,15 @@
 	if (!(_lock_hash = dm_hash_create(128)))
 		return 0;
 
-	if (_vg_global_lock_held)
+	/*
+	 * Reinitialising the cache clears the internal record of
+	 * which locks are held.  The global lock can be held during
+	 * this operation so its state must be restored afterwards.
+	 */
+	if (_vg_global_lock_held) {
 		lvmcache_lock_vgname(VG_GLOBAL, 0);
+		_vg_global_lock_held = 0;
+	}
 
 	return 1;
 }


