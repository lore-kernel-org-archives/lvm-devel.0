From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 12:42:13 -0400
Subject: master - Remove the unused lock_hash in lvmcache
Message-ID: <201806121642.w5CGgDpc007233@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be3af7f93ef0ca7d65b07863c876a7cbb1e7a239
Commit:        be3af7f93ef0ca7d65b07863c876a7cbb1e7a239
Parent:        981a3ba98ed6815a8b761261ed5652ec81294938
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 11:29:56 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 11:29:56 2018 -0500

Remove the unused lock_hash in lvmcache

It kept track of which VGs were locked, but is
no longer used, so remove it.
---
 lib/cache/lvmcache.c |   56 --------------------------------------------------
 1 files changed, 0 insertions(+), 56 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 757ed88..8db964c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -67,14 +67,12 @@ struct lvmcache_vginfo {
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
-static struct dm_hash_table *_lock_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
-static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 
 int lvmcache_init(struct cmd_context *cmd)
@@ -98,19 +96,6 @@ int lvmcache_init(struct cmd_context *cmd)
 	if (!(_pvid_hash = dm_hash_create(128)))
 		return 0;
 
-	if (!(_lock_hash = dm_hash_create(128)))
-		return 0;
-
-	/*
-	 * Reinitialising the cache clears the internal record of
-	 * which locks are held.  The global lock can be held during
-	 * this operation so its state must be restored afterwards.
-	 */
-	if (_vg_global_lock_held) {
-		lvmcache_lock_vgname(VG_GLOBAL, 0);
-		_vg_global_lock_held = 0;
-	}
-
 	return 1;
 }
 
@@ -131,25 +116,12 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
-	if (dm_hash_lookup(_lock_hash, vgname))
-		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
-			  vgname);
-
-	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
-		log_error("Cache locking failure for %s", vgname);
-
 	if (strcmp(vgname, VG_GLOBAL))
 		_vgs_locked++;
 }
 
 void lvmcache_unlock_vgname(const char *vgname)
 {
-	if (!dm_hash_lookup(_lock_hash, vgname))
-		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
-			  vgname);
-
-	dm_hash_remove(_lock_hash, vgname);
-
 	/* FIXME Do this per-VG */
 	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked) {
 		dev_size_seqno_inc(); /* invalidate all cached dev sizes */
@@ -1912,26 +1884,8 @@ static void _lvmcache_destroy_vgnamelist(struct lvmcache_vginfo *vginfo)
 	} while ((vginfo = next));
 }
 
-static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
-{
-	char *vgname;
-
-	if (!dm_hash_get_data(_lock_hash, n))
-		return;
-
-	vgname = dm_hash_get_key(_lock_hash, n);
-
-	if (!strcmp(vgname, VG_GLOBAL))
-		_vg_global_lock_held = 1;
-	else
-		log_error(INTERNAL_ERROR "Volume Group %s was not unlocked",
-			  dm_hash_get_key(_lock_hash, n));
-}
-
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
-	struct dm_hash_node *n;
-
 	log_debug_cache("Dropping VG info");
 
 	_has_scanned = 0;
@@ -1954,16 +1908,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 		_vgname_hash = NULL;
 	}
 
-	if (_lock_hash) {
-		if (reset)
-			_vg_global_lock_held = 0;
-		else
-			dm_hash_iterate(n, _lock_hash)
-				_lvmcache_destroy_lockname(n);
-		dm_hash_destroy(_lock_hash);
-		_lock_hash = NULL;
-	}
-
 	if (!dm_list_empty(&_vginfos))
 		log_error(INTERNAL_ERROR "_vginfos list should be empty");
 	dm_list_init(&_vginfos);


