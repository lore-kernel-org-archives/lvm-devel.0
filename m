From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 21:21:08 +0100
Subject: [PATCH 3/4] Add possibility to handle precommitted metadata in lvmcache.
In-Reply-To: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
References: <1262031669-26458-1-git-send-email-mbroz@redhat.com>
Message-ID: <1262031669-26458-3-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - Add drop_precommitted flag to force drop precommited metadata
 - add lvmcache_commit_metadata() which upgrades precommitted metadata in cache

No functional change in this patch - just preparation for following change.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/cache/lvmcache.c          |   27 ++++++++++++++++++++-------
 lib/cache/lvmcache.h          |    3 ++-
 lib/locking/file_locking.c    |    2 +-
 4 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 983f90f..ad6b924 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -693,7 +693,7 @@ void do_lock_vg(unsigned char command, unsigned char lock_flags, char *resource)
 
 	pthread_mutex_lock(&lvm_lock);
 	DEBUGLOG("Dropping metadata for VG %s\n", vgname);
-	lvmcache_drop_metadata(vgname);
+	lvmcache_drop_metadata(vgname, 0);
 	pthread_mutex_unlock(&lvm_lock);
 }
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 358cd80..33e54ab 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -158,7 +158,7 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-static void _drop_metadata(const char *vgname)
+static void _drop_metadata(const char *vgname, int drop_precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -173,25 +173,38 @@ static void _drop_metadata(const char *vgname)
 	 * and we must not do it again.
 	 */
 
-	if (!vginfo->precommitted)
+	if (drop_precommitted || !vginfo->precommitted)
 		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
 	_free_cached_vgmetadata(vginfo);
 }
 
-void lvmcache_drop_metadata(const char *vgname)
+/*
+ * Remote node uses this camm to upgrade precommited metadata to commited state
+ */
+void lvmcache_commit_metadata(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+		return;
+
+	vginfo->precommitted = 0;
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
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index f1f1065..e2d749e 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -111,6 +111,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
-void lvmcache_drop_metadata(const char *vgname);
+void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
+void lvmcache_commit_metadata(const char *vgname);
 
 #endif
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 0ee8bbf..f47961d 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -259,7 +259,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 	case LCK_VG:
 		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
 		if (strcmp(resource, VG_GLOBAL))
-			lvmcache_drop_metadata(resource);
+			lvmcache_drop_metadata(resource, 0);
 
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)
-- 
1.6.5.7


