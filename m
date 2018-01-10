From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:54:06 -0500
Subject: master - device: Free cached device bufs when metadata invalid or dev closed.
Message-ID: <201801101554.w0AFs6Fd004794@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d568b709cec5f84c8a8a278747b997a75b4c463
Commit:        4d568b709cec5f84c8a8a278747b997a75b4c463
Parent:        bd0967a4b1ac3dc6402b0e9ad8bc2f85f4f7af1c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 12:03:31 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

device: Free cached device bufs when metadata invalid or dev closed.

---
 lib/cache/lvmcache.c |    6 ++++++
 lib/device/dev-io.c  |    4 ++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 53f1c95..017a86b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -141,6 +141,8 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 /* Volume Group metadata cache functions */
 static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 {
+	struct lvmcache_info *info;
+
 	if (!vginfo || !vginfo->vgmetadata)
 		return;
 
@@ -154,6 +156,10 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
+	/* Invalidate any cached device buffers */
+	dm_list_iterate_items(info, &vginfo->infos)
+		devbufs_release(info->dev);
+
 	log_debug_cache("lvmcache: VG %s wiped.", vginfo->vgname);
 
 	release_vg(vginfo->cached_vg);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 47d3ad9..18a09d1 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -85,6 +85,9 @@ static void _release_devbuf(struct device_buffer *devbuf)
 
 void devbufs_release(struct device *dev)
 {
+	if ((dev->flags & DEV_REGULAR))
+		return;
+
 	_release_devbuf(&dev->last_devbuf);
 	_release_devbuf(&dev->last_extra_devbuf);
 }
@@ -706,6 +709,7 @@ static void _close(struct device *dev)
 	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dm_list_del(&dev->open_list);
+	devbufs_release(dev);
 
 	log_debug_devs("Closed %s", dev_name(dev));
 


