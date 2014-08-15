From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 11:28:58 +0000 (UTC)
Subject: master - cache+thin: add lv_is_{cache, thin}_origin fn to identify origin LVs
Message-ID: <20140815112858.0A73B60E81@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8eba33510f95572316a743d6b68d5c7c31743672
Commit:        8eba33510f95572316a743d6b68d5c7c31743672
Parent:        ec0d2f7aa4da4e433e26bc252626eae6febbe4d6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 13:08:30 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 13:28:43 2014 +0200

cache+thin: add lv_is_{cache,thin}_origin fn to identify origin LVs

---
 lib/metadata/cache_manip.c       |   13 +++++++++++++
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/thin_manip.c        |   16 ++++++++++++++++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 184df79..f617f4e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -314,3 +314,16 @@ int get_cache_mode(const char *str, uint32_t *flags)
 
 	return 1;
 }
+
+int lv_is_cache_origin(const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	/* Make sure there's exactly one segment in segs_using_this_lv! */
+	if (dm_list_empty(&lv->segs_using_this_lv) ||
+	    (dm_list_size(&lv->segs_using_this_lv) > 1))
+		return 0;
+
+	seg = get_only_segment_using_this_lv(lv);
+	return seg && lv_is_cache(seg->lv) && (seg_lv(seg, 0) == lv);
+}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fa96a1a..497e59c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -921,6 +921,8 @@ int lv_is_striped(const struct logical_volume *lv);
 */
 int lv_is_origin(const struct logical_volume *lv);
 int lv_is_virtual_origin(const struct logical_volume *lv);
+int lv_is_thin_origin(const struct logical_volume *lv);
+int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 07246f7..7d86187 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -499,3 +499,19 @@ const char *get_pool_discards_name(thin_discards_t discards)
 
 	return "unknown";
 }
+
+int lv_is_thin_origin(const struct logical_volume *lv)
+{
+	struct seg_list *segl;
+
+	if (!lv_is_thin_volume(lv) ||
+	    dm_list_empty(&lv->segs_using_this_lv))
+		return 0;
+
+	dm_list_iterate_items(segl, &lv->segs_using_this_lv) {
+		if (segl->seg->origin == lv)
+			return 1;
+	}
+
+	return 0;
+}


