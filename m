From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 13 Aug 2009 17:26:55 -0400
Subject: [PATCH 1/9] Enforce an alphabetical lock ordering for vgname locks.
In-Reply-To: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1250198823-11591-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

You can test this with a simple vgsplit - e.g.:
vgsplit vg2 vg1 - should fail now
vgsplit vg1 vg2 - should pass

TODO
- fix vgsplit and vgmerge to obey the ordering rules
- cleanup patch if possible

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c  |   38 +++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h  |    1 +
 lib/locking/locking.c |    6 ++++++
 3 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a7889d8..3db9bb9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -186,6 +186,42 @@ void lvmcache_drop_metadata(const char *vgname)
 		_drop_metadata(vgname);
 }
 
+static const char * _compare_lock_name(struct dm_hash_node *n,
+				       const char *vgname)
+{
+	char *vgname2;
+
+	if (!_lock_hash || !dm_hash_get_data(_lock_hash, n))
+		return NULL;
+
+	vgname2 = dm_hash_get_key(_lock_hash, n);
+	/* We don't care about special locks */
+	if (*vgname2 == '#')
+		return NULL;
+
+	if (strcmp(vgname, vgname2) < 0)
+		return vgname2;
+	return NULL;
+}
+
+/*
+ * Enforce alphabetical order of vgname locks
+ */
+int lvmcache_verify_lock_order(const char *vgname)
+{
+	struct dm_hash_node *n;
+	const char *vgname2;
+
+	dm_hash_iterate(n, _lock_hash)
+		if ((vgname2 = _compare_lock_name(n, vgname))) {
+			log_errno(EDEADLK, "Invalid vgname lock order "
+				  "attempted with %s - %s already locked",
+				  vgname, vgname2);
+			return 0;
+		}
+	return 1;
+}
+
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
@@ -196,7 +232,7 @@ void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)
 	if (dm_hash_lookup(_lock_hash, vgname))
 		log_error("Internal error: Nested locking attempted on VG %s.",
 			  vgname);
-		
+
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 09edb3c..f1f1065 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -84,6 +84,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
+int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
 const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 40e8601..1217974 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -387,6 +387,12 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
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
-- 
1.6.0.6


