From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Apr 2008 02:22:07 -0000
Subject: LVM2 lib/cache/lvmcache.c ./WHATS_NEW
Message-ID: <20080424022207.13013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-24 02:22:07

Modified files:
	lib/cache      : lvmcache.c 
	.              : WHATS_NEW 

Log message:
	Exclude VG_GLOBAL from internal concurrent VG lock counter.
	(Avoids 'device left open' warning messages from vgscan etc.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.860&r2=1.861

--- LVM2/lib/cache/lvmcache.c	2008/04/15 14:54:00	1.46
+++ LVM2/lib/cache/lvmcache.c	2008/04/24 02:22:06	1.47
@@ -156,7 +156,8 @@
 
 	_update_cache_lock_state(vgname, 1);
 
-	_vgs_locked++;
+	if (strcmp(vgname, VG_GLOBAL))
+		_vgs_locked++;
 }
 
 int vgname_is_locked(const char *vgname)
@@ -178,7 +179,7 @@
 	dm_hash_remove(_lock_hash, vgname);
 
 	/* FIXME Do this per-VG */
-	if (!--_vgs_locked)
+	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked)
 		dev_close_all();
 }
 
--- LVM2/WHATS_NEW	2008/04/23 14:33:05	1.860
+++ LVM2/WHATS_NEW	2008/04/24 02:22:07	1.861
@@ -1,8 +1,9 @@
 Version 2.02.36 - 
 =================================
+  Exclude VG_GLOBAL from internal concurrent VG lock counter.
   Fix vgsplit internal counting of snapshot LVs.
-  Fix internal snapshot_count when vgmerge with snapshots in source VG.
-  Simply clvmd-openais by using non-async saLckResourceLock.
+  Fix vgmerge snapshot_count when source VG contains snapshots.
+  Simplify clvmd-openais by using non-async saLckResourceLock.
   Check lv_count in vg_validate.
   Fix internal LV counter when a snapshot is removed.
   Fix metadata corruption writing lvm1-formatted metadata with snapshots.


