From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:22:00 +0100
Subject: [PATCH 6/6] lv_postorder unlock and lock
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <17be845bfe91973b1437feccea1b0f083c69e577.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of unlocking and locking for every changed struct member
do it once when entering and leaving function.

Currently lv_postoder() does not modify other part of vg structure
then status flags of each LV with flags that are also removed.
However using standard dm_pool_set_uint64 would require to implement
more efective data structure for exception stor - as it is not
needed for now - avoid complexity and use this very simple workaround.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cec9c3c..85bcb2d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2083,8 +2083,17 @@ static int _lv_postorder(struct logical_volume *lv,
 			       void *data)
 {
 	int r;
+	int lck = dm_pool_locked(lv->vg->vgmem);
+
+	if (lck && !dm_pool_unlock(lv->vg->vgmem))
+		return_0;
+
 	r = _lv_postorder_visit(lv, fn, data);
 	_lv_postorder_cleanup(lv, 0);
+
+	if (lck && !dm_pool_lock(lv->vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
@@ -2098,6 +2107,10 @@ static int _lv_postorder_vg(struct volume_group *vg,
 {
 	struct lv_list *lvl;
 	int r = 1;
+	int lck = dm_pool_locked(vg->vgmem);
+
+	if (lck && !dm_pool_unlock(vg->vgmem))
+		return_0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
@@ -2108,6 +2121,9 @@ static int _lv_postorder_vg(struct volume_group *vg,
 	dm_list_iterate_items(lvl, &vg->lvs)
 		_lv_postorder_cleanup(lvl->lv, 0);
 
+	if (lck && !dm_pool_lock(vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
-- 
1.7.4.1


