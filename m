From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:28 +0000 (UTC)
Subject: master - thin: move setting of THIN_POOL
Message-ID: <20130731133628.D0F7460319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b58f104427911c4ef9a82a7726ccc62978e1cf5
Commit:        7b58f104427911c4ef9a82a7726ccc62978e1cf5
Parent:        5d9628475e81b15f3196a69ab4b3288466cd168f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 31 15:13:54 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:27:38 2013 +0200

thin: move setting of THIN_POOL

Set flag when attaching data LV which make segment THIN_POOL.
---
 lib/metadata/thin_manip.c |   13 +++++++------
 lib/thin/thin.c           |    5 ++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 35e1ec7..6851b3f 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -53,6 +53,7 @@ int attach_pool_data_lv(struct lv_segment *pool_seg, struct logical_volume *pool
 	if (!set_lv_segment_area_lv(pool_seg, 0, pool_data_lv, 0, THIN_POOL_DATA))
 		return_0;
 
+	pool_seg->lv->status |= THIN_POOL;
 	lv_set_hidden(pool_data_lv);
 
 	return 1;
@@ -498,18 +499,18 @@ int create_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		goto_bad;
 
 	seg = first_seg(pool_lv);
-	seg->segtype = segtype; /* Set as thin_pool segment */
-	seg->lv->status |= THIN_POOL;
-
-	if (!attach_pool_metadata_lv(seg, meta_lv))
-		goto_bad;
-
 	/* Drop reference as attach_pool_data_lv() takes it again */
 	if (!remove_seg_from_segs_using_this_lv(data_lv, seg))
 		goto_bad;
+
 	if (!attach_pool_data_lv(seg, data_lv))
 		goto_bad;
 
+	if (!attach_pool_metadata_lv(seg, meta_lv))
+		goto_bad;
+
+	seg->segtype = segtype; /* Set as thin_pool segment */
+
 	return 1;
 
 bad:
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index bdb9c88..863f051 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -103,11 +103,10 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	if (!(pool_data_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown pool %s in", lv_name);
 
-	seg->lv->status |= THIN_POOL;
-	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
+	if (!attach_pool_data_lv(seg, pool_data_lv))
 		return_0;
 
-	if (!attach_pool_data_lv(seg, pool_data_lv))
+	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
 		return_0;
 
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))


