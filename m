From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 22 Jul 2013 09:52:40 +0000 (UTC)
Subject: master - metadata: Do not try to maintain an ondisk copy of orphan VGs.
Message-ID: <20130722095240.B887A60CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f897fcbd957517b484956062055599b226090f05
Commit:        f897fcbd957517b484956062055599b226090f05
Parent:        6aeb54c77cf333952d6459823709cd9cd6df681d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 11:51:35 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jul 22 11:51:35 2013 +0200

metadata: Do not try to maintain an ondisk copy of orphan VGs.

---
 lib/metadata/metadata.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ddcf0a5..d0745e0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -842,12 +842,14 @@ static int _vg_update_vg_ondisk(struct volume_group *vg)
 	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
 		return_0;
 
-	cft = export_vg_to_config_tree(vg);
-	if (!cft)
-		return 0;
+	if (!is_orphan_vg(vg->name)) {
+		cft = export_vg_to_config_tree(vg);
+		if (!cft)
+			return 0;
 
-	vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
-	dm_config_destroy(cft);
+		vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
+		dm_config_destroy(cft);
+	}
 
 	/* recompute the pool crc */
 	if (pool_locked && !dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))


