From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 20:51:08 +0000 (UTC)
Subject: master - metadata: Fix a pool CRC failure due to "late" ondisk copy creation.
Message-ID: <20130610205108.EB27160F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cce2f67abf488eaed94902d415dd6f106c84229
Commit:        2cce2f67abf488eaed94902d415dd6f106c84229
Parent:        df4c0bedfbe59d780b14346ce190673148c0cd98
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Mar 18 15:46:00 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 17:26:38 2013 +0200

metadata: Fix a pool CRC failure due to "late" ondisk copy creation.

---
 lib/metadata/metadata.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 922e82e..d25fe01 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -837,12 +837,21 @@ static int _vg_update_vg_ondisk(struct volume_group *vg)
 	if (vg->vg_ondisk) /* we already have it */
 		return 1;
 
+	int pool_locked = dm_pool_locked(vg->vgmem);
+	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
+
 	cft = export_vg_to_config_tree(vg);
 	if (!cft)
 		return 0;
 
 	vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
 	dm_config_destroy(cft);
+
+	/* recompute the pool crc */
+	if (pool_locked && !dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
+		return_0;
+
 	return 1;
 }
 


