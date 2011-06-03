From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:29 +0200
Subject: [PATCH 11/11] lv_postorder unlock and lock
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <cf76a9f5354f1a4d4dcc0dc2a665e9acf72ff121.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of unlocking and locking for every changed struct member
do it once when entering and leaving function.

Currently lv_postoder() does not modify other part of vg structure
then status flags of each LV with flags that are also removed.

After the function execution the structure should remain unmodified.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1cd1e6c..f4cee5a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2107,8 +2107,17 @@ static int _lv_postorder(struct logical_volume *lv,
 			       void *data)
 {
 	int r;
+	int lck = dm_pool_locked(lv->vg->vgmem);
+
+	if (lck && !dm_pool_unlock(lv->vg->vgmem, 0))
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
 
@@ -2122,6 +2131,10 @@ static int _lv_postorder_vg(struct volume_group *vg,
 {
 	struct lv_list *lvl;
 	int r = 1;
+	int lck = dm_pool_locked(vg->vgmem);
+
+	if (lck && !dm_pool_unlock(vg->vgmem, 0))
+		return_0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!_lv_postorder_visit(lvl->lv, fn, data)) {
@@ -2132,6 +2145,9 @@ static int _lv_postorder_vg(struct volume_group *vg,
 	dm_list_iterate_items(lvl, &vg->lvs)
 		_lv_postorder_cleanup(lvl->lv, 0);
 
+	if (lck && !dm_pool_lock(vg->vgmem, 0))
+		return_0;
+
 	return r;
 }
 
-- 
1.7.5.2


