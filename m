From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:34:57 +0000 (UTC)
Subject: master - thin: rename extend_pool to create_pool
Message-ID: <20130723123457.36E0161200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84801d7c34430052e298bc54826e18eb68212ec6
Commit:        84801d7c34430052e298bc54826e18eb68212ec6
Parent:        3670fe92ba05c9555159ee887bc96e1da41e6682
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 23 13:33:14 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 23 13:33:14 2013 +0100

thin: rename extend_pool to create_pool

---
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/metadata.h   |    2 +-
 lib/metadata/thin_manip.c |   10 +++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 16ad7e7..8882a0a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2868,7 +2868,7 @@ int lv_extend(struct logical_volume *lv,
 
 	if (segtype_is_thin_pool(segtype)) {
 		if (!lv->le_count) {
-			if (!(r = extend_pool(lv, segtype, ah, stripes, stripe_size)))
+			if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 				stack;
 		} else if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
 						       stripes, stripe_size)))
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c2a20cb..2408c23 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -470,7 +470,7 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
 int pool_below_threshold(const struct lv_segment *pool_seg);
-int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
+int create_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
 /*
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 38073ee..35e1ec7 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -425,8 +425,7 @@ uint32_t get_free_pool_device_id(struct lv_segment *thin_pool_seg)
 	return max_id;
 }
 
-// FIXME Rename this fn: it doesn't extend an already-existing pool AFAICT
-int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
+int create_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size)
 {
 	const struct segment_type *striped;
@@ -455,7 +454,9 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 	if (!lv_add_segment(ah, stripes, 1, pool_lv, striped, 1, 0, 0))
 		return_0;
 
-	if (activation()) {
+	if (!activation())
+		log_warn("WARNING: Pool %s is created without initialization.", pool_lv->name);
+	else {
 		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 			return_0;
 
@@ -474,8 +475,6 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 				  pool_lv->name);
 			goto bad;
 		}
-	} else {
-		log_warn("WARNING: Pool %s is created without initialization.", pool_lv->name);
 	}
 
 	if (dm_snprintf(name, sizeof(name), "%s_tmeta", pool_lv->name) < 0) {
@@ -512,6 +511,7 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		goto_bad;
 
 	return 1;
+
 bad:
 	if (activation()) {
 		if (deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {


