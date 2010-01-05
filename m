From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:06:44 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20100105160644.24304.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:06:43

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/locking    : file_locking.c 

Log message:
	Add possibility to handle precommitted metadata in lvmcache.
	
	- Add drop_precommitted flag to force drop precommitted metadata
	- add lvmcache_commit_metadata() which upgrades precommitted metadata in cache
	
	No functional change in this patch - just preparation for following change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1358&r2=1.1359
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2010/01/05 16:05:12	1.1358
+++ LVM2/WHATS_NEW	2010/01/05 16:06:42	1.1359
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add possibility to drop precommitted metadata in lvmcache.
   Move processing of VG locks to separate function in clvmd.
   Properly decode flags even for VG locks.
   Properly handle precommitted flag in cache when commited data only present.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:05:12	1.80
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/01/05 16:06:42	1.81
@@ -693,7 +693,7 @@
 
 	pthread_mutex_lock(&lvm_lock);
 	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
-	lvmcache_drop_metadata(vgname);
+	lvmcache_drop_metadata(vgname, 0);
 	pthread_mutex_unlock(&lvm_lock);
 }
 
--- LVM2/lib/cache/lvmcache.c	2009/12/16 19:22:12	1.74
+++ LVM2/lib/cache/lvmcache.c	2010/01/05 16:06:43	1.75
@@ -158,7 +158,7 @@
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-static void _drop_metadata(const char *vgname)
+static void _drop_metadata(const char *vgname, int drop_precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -172,26 +172,48 @@
 	 * already invalidated the PV labels (before caching it)
 	 * and we must not do it again.
 	 */
+	if (!drop_precommitted && vginfo->precommitted && !vginfo->vgmetadata)
+		log_error(INTERNAL_ERROR "metadata commit (or revert) missing before "
+			  "dropping metadata from cache.");
 
-	if (!vginfo->precommitted)
+	if (drop_precommitted || !vginfo->precommitted)
 		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
 	_free_cached_vgmetadata(vginfo);
 }
 
-void lvmcache_drop_metadata(const char *vgname)
+/*
+ * Remote node uses this to upgrade precommited metadata to commited state
+ * when receives vg_commit notification.
+ * (Note that devices can be suspended here, if so, precommited metadata are already read.)
+ */
+void lvmcache_commit_metadata(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+		return;
+
+	if (vginfo->precommitted) {
+		log_debug("Precommitted metadata cache: VG %s upgraded to committed.",
+			  vginfo->vgname);
+		vginfo->precommitted = 0;
+	}
+}
+
+void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 {
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */
 	if (!strcmp(vgname, VG_ORPHANS)) {
-		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME);
-		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME);
-		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME);
+		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME, 0);
+		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME, 0);
+		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME, 0);
 
 		/* Indicate that PVs could now be missing from the cache */
 		init_full_scan_done(0);
 	} else if (!vgname_is_locked(VG_GLOBAL))
-		_drop_metadata(vgname);
+		_drop_metadata(vgname, drop_precommitted);
 }
 
 /*
--- LVM2/lib/cache/lvmcache.h	2009/09/02 21:34:11	1.25
+++ LVM2/lib/cache/lvmcache.h	2010/01/05 16:06:43	1.26
@@ -111,6 +111,7 @@
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
-void lvmcache_drop_metadata(const char *vgname);
+void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
+void lvmcache_commit_metadata(const char *vgname);
 
 #endif
--- LVM2/lib/locking/file_locking.c	2009/09/02 14:47:40	1.43
+++ LVM2/lib/locking/file_locking.c	2010/01/05 16:06:43	1.44
@@ -259,7 +259,7 @@
 	case LCK_VG:
 		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
 		if (strcmp(resource, VG_GLOBAL))
-			lvmcache_drop_metadata(resource);
+			lvmcache_drop_metadata(resource, 0);
 
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)


