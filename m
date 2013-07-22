From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:02:04 +0000 (UTC)
Subject: master - metadata: Do not ignore errors in _vg_update_vg_ondisk.
Message-ID: <20130722100204.16EB061297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ed7f78ff4d79831700806407c3728ea7d728488
Commit:        3ed7f78ff4d79831700806407c3728ea7d728488
Parent:        bd60232d7428a8b51c8794b30503761f4032f7a1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 12:00:48 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jul 22 12:00:48 2013 +0200

metadata: Do not ignore errors in _vg_update_vg_ondisk.

---
 lib/metadata/metadata.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d0745e0..5624a5e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -835,27 +835,25 @@ static int _vg_update_vg_ondisk(struct volume_group *vg)
 	struct dm_config_tree *cft;
 	int pool_locked;
 
-	if (vg->vg_ondisk) /* we already have it */
+	if (vg->vg_ondisk || is_orphan_vg(vg->name)) /* we already have it */
 		return 1;
 
 	pool_locked = dm_pool_locked(vg->vgmem);
 	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
 		return_0;
 
-	if (!is_orphan_vg(vg->name)) {
-		cft = export_vg_to_config_tree(vg);
-		if (!cft)
-			return 0;
+	cft = export_vg_to_config_tree(vg);
+	if (!cft)
+		return 0;
 
-		vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
-		dm_config_destroy(cft);
-	}
+	vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
+	dm_config_destroy(cft);
 
 	/* recompute the pool crc */
 	if (pool_locked && !dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
 		return_0;
 
-	return 1;
+	return vg->vg_ondisk ? 1 : 0;
 }
 
 /*


