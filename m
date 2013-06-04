From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:56 +0000 (UTC)
Subject: dev-mornfall-activate - metadata: Fix a pool CRC failure due to "late" ondisk copy creation.
Message-ID: <20130604192856.5430360FD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3d4ed7708dd461482daa62c37e8a4c86f325286
Commit:        a3d4ed7708dd461482daa62c37e8a4c86f325286
Parent:        e190fe89fff90f260b85a4f8e8639239bd3ccd4a
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Mar 18 15:46:00 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jun 4 18:17:46 2013 +0200

metadata: Fix a pool CRC failure due to "late" ondisk copy creation.

---
 lib/metadata/metadata.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c2d7796..af7edab 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -837,12 +837,21 @@ static int _vg_metadata_snapshot(struct volume_group *vg)
 	if (vg->ondisk) /* we already have it */
 		return 1;
 
+	int pool_locked = dm_pool_locked(vg->vgmem);
+	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
+
 	cft = export_vg_to_config_tree(vg);
 	if (!cft)
 		return 0;
 
 	vg->ondisk = import_vg_from_config_tree(cft, vg->fid);
 	dm_config_destroy(cft);
+
+	/* recompute the pool crc */
+	if (pool_locked && !dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
+		return_0;
+
 	return 1;
 }
 


