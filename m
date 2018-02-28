From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:21 -0500
Subject: master - lv_manip: enhance for_each_sub_lv
Message-ID: <201802282022.w1SKMLS7009766@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc1adc32cbd593dd1839526da82521b429b13141
Commit:        bc1adc32cbd593dd1839526da82521b429b13141
Parent:        6b48868cf0754b13e4efaaaec33cf8c9deba2d40
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:00:33 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:08:38 2018 +0100

lv_manip: enhance for_each_sub_lv

Fix missing 'externalLV' traversing for thins with external origins.

Replace extra for_each_sub_lv_except_pools() with better
internal logic allowing selectively to cut of processed subLV tree.

Extend error code for function 'fn()' when it returns -1 it will
stop futher tree scan for given LV.

Also a bit simplify code to have only one place that
is calling 'fn()' and use level counter to know
depth of traversing.

Update renaming travering to skip trees for pools
and external origins.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   72 +++++++++++++++++++++++-----------------------
 lib/metadata/metadata.h |    3 --
 3 files changed, 37 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5791930..6a0a0dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add external_origin visiting in for_each_sub_lv().
   Ensure cluster commands drop their device cache before locking VG.
   Do not report LV as remotely active when it's locally exclusive in cluster.
   Add deprecate messages for usage of mirrors with mirrorlog.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ac30dad..35c805c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4341,53 +4341,62 @@ static int _rename_cb(struct logical_volume *lv, void *data)
 	return _rename_sub_lv(lv, lv_names->old, lv_names->new);
 }
 
+static int _rename_skip_pools_externals_cb(struct logical_volume *lv, void *data)
+{
+	if (lv_is_pool(lv) || lv_is_external_origin(lv))
+		return -1; /* and skip subLVs */
+
+	return _rename_cb(lv, data);
+}
+
 /*
  * Loop down sub LVs and call fn for each.
  * fn is responsible to log necessary information on failure.
+ * Return value '0' stops whole traversal.
+ * Return value '-1' stops subtree traversal.
  */
-static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
+static int _for_each_sub_lv(struct logical_volume *lv, int level,
 			    int (*fn)(struct logical_volume *lv, void *data),
 			    void *data)
 {
 	struct logical_volume *org;
 	struct lv_segment *seg;
 	uint32_t s;
+	int r;
 
-	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {
-		if (!fn(org, data))
+	if (!lv)
+		return 1;
+
+	if (level++) {
+		if (!(r = fn(lv, data)))
 			return_0;
-		if (!_for_each_sub_lv(org, skip_pools, fn, data))
+		/* Only r == 1 lets you run for_each... */
+		if (r == -1)
+			return 1;
+	}
+
+	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {
+		if (!_for_each_sub_lv(org, level, fn, data))
 			return_0;
 	}
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->log_lv) {
-			if (!fn(seg->log_lv, data))
-				return_0;
-			if (!_for_each_sub_lv(seg->log_lv, skip_pools, fn, data))
-				return_0;
-		}
+		if (!_for_each_sub_lv(seg->external_lv, level, fn, data))
+			return_0;
 
-		if (seg->metadata_lv) {
-			if (!fn(seg->metadata_lv, data))
-				return_0;
-			if (!_for_each_sub_lv(seg->metadata_lv, skip_pools, fn, data))
-				return_0;
-		}
+		if (!_for_each_sub_lv(seg->log_lv, level, fn, data))
+			return_0;
 
-		if (seg->pool_lv && !skip_pools) {
-			if (!fn(seg->pool_lv, data))
-				return_0;
-			if (!_for_each_sub_lv(seg->pool_lv, skip_pools, fn, data))
-				return_0;
-		}
+		if (!_for_each_sub_lv(seg->metadata_lv, level, fn, data))
+			return_0;
+
+		if (!_for_each_sub_lv(seg->pool_lv, level, fn, data))
+			return_0;
 
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!fn(seg_lv(seg, s), data))
-				return_0;
-			if (!_for_each_sub_lv(seg_lv(seg, s), skip_pools, fn, data))
+			if (!_for_each_sub_lv(seg_lv(seg, s), level, fn, data))
 				return_0;
 		}
 
@@ -4398,9 +4407,7 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 		for (s = 0; s < seg->area_count; s++) {
 			if ((seg_metatype(seg, s) != AREA_LV) || !seg_metalv(seg, s))
 				continue;
-			if (!fn(seg_metalv(seg, s), data))
-				return_0;
-			if (!_for_each_sub_lv(seg_metalv(seg, s), skip_pools, fn, data))
+			if (!_for_each_sub_lv(seg_metalv(seg, s), level, fn, data))
 				return_0;
 		}
 	}
@@ -4415,13 +4422,6 @@ int for_each_sub_lv(struct logical_volume *lv,
 	return _for_each_sub_lv(lv, 0, fn, data);
 }
 
-int for_each_sub_lv_except_pools(struct logical_volume *lv,
-				 int (*fn)(struct logical_volume *lv, void *data),
-				 void *data)
-{
-	return _for_each_sub_lv(lv, 1, fn, data);
-}
-
 /*
  * Core of LV renaming routine.
  * VG must be locked by caller.
@@ -4475,7 +4475,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 
 		/* rename sub LVs */
-		if (!for_each_sub_lv_except_pools(lv, _rename_cb, (void *) &lv_names))
+		if (!for_each_sub_lv(lv, _rename_skip_pools_externals_cb, (void *) &lv_names))
 			return_0;
 
 		/* rename main LV */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index df660a7..f6b19f4 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -444,9 +444,6 @@ int add_glv_to_indirect_glvs(struct dm_pool *mem,
 int remove_glv_from_indirect_glvs(struct generic_logical_volume *origin_glv,
 				  struct generic_logical_volume *glv);
 
-int for_each_sub_lv_except_pools(struct logical_volume *lv,
-				 int (*fn)(struct logical_volume *lv, void *data),
-				 void *data);
 int for_each_sub_lv(struct logical_volume *lv,
 		    int (*fn)(struct logical_volume *lv, void *data),
 		    void *data);


