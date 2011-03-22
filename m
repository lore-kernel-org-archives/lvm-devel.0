From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:59 +0100
Subject: [PATCH 5/6] lv_postorder using dm_pool_set_uint64
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <3ecd5edb5fbb88a05a76b1dc2af52aa07fdc8141.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We may use either this code to safe&restore lv_postorder and keep
the structure locked.

Next patch is optimization for this one - it unlocks VG during
postorder processing (thus it equals to the original setting).

When memory pool is unlocked - this patch presents just very small
overhead and potentially helps to better debugging if there ever would
done something more complex then current lv_postoder code which could
be easily checked there are no other side-effects.

More comments in following patch...

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e466821..cec9c3c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2023,7 +2023,10 @@ static int _lv_postorder_cleanup(struct logical_volume *lv, void *data)
 {
 	if (!(lv->status & POSTORDER_FLAG))
 		return 1;
-	lv->status &= ~POSTORDER_FLAG;
+	/* lv->status &= ~POSTORDER_FLAG */
+	if (!dm_pool_set_uint64(lv->vg->vgmem, &lv->status,
+				lv->status & ~POSTORDER_FLAG))
+                return_0;
 
 	if (!_lv_each_dependency(lv, _lv_postorder_cleanup, data))
 		return_0;
@@ -2047,7 +2050,10 @@ static int _lv_postorder_visit(struct logical_volume *lv,
 		return 1;
 	if (lv->status & POSTORDER_OPEN_FLAG)
 		return 1; // a data structure loop has closed...
-	lv->status |= POSTORDER_OPEN_FLAG;
+	/* lv->status |= POSTORDER_OPEN_FLAG */
+	if (!dm_pool_set_uint64(lv->vg->vgmem, &lv->status,
+				lv->status | POSTORDER_OPEN_FLAG))
+                return_0;
 
 	baton.fn = fn;
 	baton.data = data;
@@ -2056,8 +2062,11 @@ static int _lv_postorder_visit(struct logical_volume *lv,
 	if (r)
 		r = fn(lv, data);
 
-	lv->status &= ~POSTORDER_OPEN_FLAG;
-	lv->status |= POSTORDER_FLAG;
+	/* lv->status &= ~POSTORDER_OPEN_FLAG */
+	/* lv->status |= POSTORDER_FLAG */
+	if (!dm_pool_set_uint64(lv->vg->vgmem, &lv->status,
+				(lv->status & ~POSTORDER_OPEN_FLAG) | POSTORDER_FLAG))
+		return_0;
 
 	return r;
 }
-- 
1.7.4.1


