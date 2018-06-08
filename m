From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 16:39:14 -0400
Subject: master - Remove lvmcache CACHE_LOCKED flag
Message-ID: <201806082039.w58KdEDG016157@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b48e10d9e6fd33ea26ce5296be44a986f49352a2
Commit:        b48e10d9e6fd33ea26ce5296be44a986f49352a2
Parent:        ebd147ff244abd7d308ffb3ea8a2121b5f4bc7a3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 15:11:47 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 15:11:47 2018 -0500

Remove lvmcache CACHE_LOCKED flag

and the functions that set it.  It's no longer used.
---
 lib/cache/lvmcache.c |   38 +-------------------------------------
 1 files changed, 1 insertions(+), 37 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3cbe1df..923fb2e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -28,8 +28,6 @@
 #include "lib/cache/lvmetad.h"
 #include "daemons/lvmetad/lvmetad-client.h"
 
-#define CACHE_LOCKED	0x00000002
-
 /* One per device */
 struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
@@ -131,33 +129,6 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 	_has_scanned = 1;
 }
 
-static void _update_cache_info_lock_state(struct lvmcache_info *info, int locked)
-{
-	if (locked)
-		info->status |= CACHE_LOCKED;
-	else
-		info->status &= ~CACHE_LOCKED;
-}
-
-static void _update_cache_vginfo_lock_state(struct lvmcache_vginfo *vginfo,
-					    int locked)
-{
-	struct lvmcache_info *info;
-
-	dm_list_iterate_items(info, &vginfo->infos)
-		_update_cache_info_lock_state(info, locked);
-}
-
-static void _update_cache_lock_state(const char *vgname, int locked)
-{
-	struct lvmcache_vginfo *vginfo;
-
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
-		return;
-
-	_update_cache_vginfo_lock_state(vginfo, locked);
-}
-
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
 	if (dm_hash_lookup(_lock_hash, vgname))
@@ -167,10 +138,8 @@ void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unuse
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
-	if (strcmp(vgname, VG_GLOBAL)) {
-		_update_cache_lock_state(vgname, 1);
+	if (strcmp(vgname, VG_GLOBAL))
 		_vgs_locked++;
-	}
 }
 
 int lvmcache_vgname_is_locked(const char *vgname)
@@ -187,9 +156,6 @@ void lvmcache_unlock_vgname(const char *vgname)
 		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
 			  vgname);
 
-	if (strcmp(vgname, VG_GLOBAL))
-		_update_cache_lock_state(vgname, 0);
-
 	dm_hash_remove(_lock_hash, vgname);
 
 	/* FIXME Do this per-VG */
@@ -1513,8 +1479,6 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 	else if (!_lvmcache_update_vgid(NULL, vginfo, vgid)) /* Orphans */
 		return_0;
 
-	_update_cache_vginfo_lock_state(vginfo, lvmcache_vgname_is_locked(vgname));
-
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = fmt;
 


