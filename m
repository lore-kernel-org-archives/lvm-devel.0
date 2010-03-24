From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Mar 2010 15:28:21 +0100
Subject: [PATCH] Do not open PVs with no metadata areas if memory is locked.
Message-ID: <1269440901-22549-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If there is LV across a PV without mda, this warning appears:
 # lvchange -p rw vg_test/lv1 -v
   ...
   Suspending vg_test-lv1 (254:0) with device flush
   WARNING: dev_open(/dev/sdc) called while suspended

Because PVs without mdas are attached to proper vginfo
late in vg_read, it can happen that code closes file descriptor
for these PVs and later rescan issues this warning.

Fix (wonderful hack!) it by not only keeping PVs of locked
VGs open, but also keep open PVs without mdas if some VG is locked.

It will be closed when Vg lock count drops to zero (dev_close_all())

Also fix minor things
 - remove old unused prototype
 - do not query hash table if key is empty string
---
 lib/cache/lvmcache.c |    2 +-
 lib/cache/lvmcache.h |    1 -
 lib/device/dev-io.c  |    3 ++-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0ce034a..4b310b7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -484,7 +484,7 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 	struct lvmcache_info *info;
 	char id[ID_LEN + 1] __attribute((aligned(8)));
 
-	if (!_pvid_hash || !pvid)
+	if (!_pvid_hash || !pvid || !*pvid)
 		return NULL;
 
 	strncpy(&id[0], pvid, ID_LEN);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 8eeb495..1504e21 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -74,7 +74,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				   const char *vgname, const char *vgid,
 				   uint32_t vgstatus);
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
-void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 06675e2..63c57c8 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -566,7 +566,8 @@ static int _dev_close(struct device *dev, int immediate)
 	    (dev->open_count < 1 &&
 	     (!(info = info_from_pvid(dev->pvid, 0)) ||
 	      !info->vginfo ||
-	      !vgname_is_locked(info->vginfo->vgname))))
+	      (!is_orphan_vg(info->vginfo->vgname) && !vgname_is_locked(info->vginfo->vgname)) ||
+	      (is_orphan_vg(info->vginfo->vgname) && !vgs_locked()))))
 		_close(dev);
 
 	return 1;
-- 
1.7.0.2


