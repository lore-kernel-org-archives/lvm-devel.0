From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:41 +0000 (UTC)
Subject: master - thin: fix error paths for metadata creation
Message-ID: <20130718162641.A389560DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d72f34af418b90c71e8e96f408d4953e679e0895
Commit:        d72f34af418b90c71e8e96f408d4953e679e0895
Parent:        7afa9cebcbce0232c0c889cb3f112f66d10a79b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:01:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

thin: fix error paths for metadata creation

Since we vg_write&commit metadata LV inside  lv_extend() call,
proper restore is needed in case something fails.

So add bad: section which deactivates activated LV
and removes it from VG.

Also check early for metadata LV name lengh fail.
---
 lib/metadata/thin_manip.c |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 4f6e2ec..8724845 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -433,8 +433,7 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 	const struct segment_type *striped;
 	struct logical_volume *meta_lv, *data_lv;
 	struct lv_segment *seg;
-	const size_t len = strlen(pool_lv->name) + 16;
-	char name[len];
+	char name[NAME_LEN];
 
 	if (pool_lv->le_count) {
 		/* FIXME move code for manipulation from lv_manip.c */
@@ -486,38 +485,53 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		log_warn("WARNING: Pool %s is created without initialization.", pool_lv->name);
 	}
 
-	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
-		return_0;
+	if (dm_snprintf(name, sizeof(name), "%s_tmeta", pool_lv->name) < 0) {
+		log_error("Name is too long to be a pool name.");
+		goto bad;
+	}
 
 	if (!(meta_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
 					ALLOC_INHERIT, pool_lv->vg)))
-		return_0;
+		goto_bad;
 
 	if (!move_lv_segments(meta_lv, pool_lv, 0, 0))
-		return_0;
+		goto_bad;
 
 	/* Pool data segment */
 	if (!lv_add_segment(ah, 0, stripes, pool_lv, striped, stripe_size, 0, 0))
-		return_0;
+		goto_bad;
 
 	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
 					    pool_lv->status, "_tdata")))
-		return_0;
+		goto_bad;
 
 	seg = first_seg(pool_lv);
 	seg->segtype = segtype; /* Set as thin_pool segment */
 	seg->lv->status |= THIN_POOL;
 
 	if (!attach_pool_metadata_lv(seg, meta_lv))
-		return_0;
+		goto_bad;
 
 	/* Drop reference as attach_pool_data_lv() takes it again */
 	if (!remove_seg_from_segs_using_this_lv(data_lv, seg))
-		return_0;
+		goto_bad;
 	if (!attach_pool_data_lv(seg, data_lv))
-		return_0;
+		goto_bad;
 
 	return 1;
+bad:
+	if (activation()) {
+		if (deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+			log_error("Aborting. Could not deactivate pool %s.",
+				  pool_lv->name);
+			return 0;
+		}
+		if (!lv_remove(pool_lv) || !vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned LV(s) before retrying.");
+	}
+
+	return 0;
 }
 
 int update_pool_lv(struct logical_volume *lv, int activate)


