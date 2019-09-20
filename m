From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 15:55:33 -0400
Subject: master - writecache: display layout and role fields
Message-ID: <201909201955.x8KJtX55004138@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27c3c1d7c8dcb160f29d1610f3993f41afc72a6d
Commit:        27c3c1d7c8dcb160f29d1610f3993f41afc72a6d
Parent:        6f7d7089b4527cd1e198bac9da0341d8f65d4717
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 20 14:54:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 14:55:11 2019 -0500

writecache: display layout and role fields

---
 lib/metadata/lv_manip.c          |   33 ++++++++++++++++++++++++++++++---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   13 +++++++++++++
 3 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 107074a..79e3d15 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -131,7 +131,10 @@ enum {
 	LV_TYPE_RAID6_NR,
 	LV_TYPE_RAID6_NC,
 	LV_TYPE_LOCKD,
-	LV_TYPE_SANLOCK
+	LV_TYPE_SANLOCK,
+	LV_TYPE_CACHEVOL,
+	LV_TYPE_WRITECACHE,
+	LV_TYPE_WRITECACHEORIGIN
 };
 
 static const char *_lv_type_names[] = {
@@ -184,6 +187,9 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_RAID6_NC] =				SEG_TYPE_NAME_RAID6_NC,
 	[LV_TYPE_LOCKD] =				"lockd",
 	[LV_TYPE_SANLOCK] =				"sanlock",
+	[LV_TYPE_CACHEVOL] =				"cachevol",
+	[LV_TYPE_WRITECACHE] =				"writecache",
+	[LV_TYPE_WRITECACHEORIGIN] =			"writecacheorigin",
 };
 
 static int _lv_layout_and_role_mirror(struct dm_pool *mem,
@@ -410,6 +416,14 @@ static int _lv_layout_and_role_cache(struct dm_pool *mem,
 		if (lv_is_cache(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 			goto_bad;
+	} else if (lv_is_writecache_origin(lv)) {
+		if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_WRITECACHE]) ||
+		    !str_list_add(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_WRITECACHEORIGIN]))
+			goto_bad;
+		if (lv_is_writecache(lv) &&
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_WRITECACHE]))
+			goto_bad;
 	} else
 		top_level = 1;
 
@@ -422,7 +436,20 @@ static int _lv_layout_and_role_cache(struct dm_pool *mem,
 	if (lv_is_cache(lv) &&
 	    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 		goto_bad;
-	else if (lv_is_cache_pool(lv) || lv_is_cache_vol(lv)) {
+	else if (lv_is_writecache(lv) &&
+	         !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_WRITECACHE]))
+		goto_bad;
+	else if (lv_is_writecache_cachevol(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_WRITECACHE]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHEVOL]))
+			goto_bad;
+		*public_lv = 0;
+	} else if (lv_is_cache_vol(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHEVOL]))
+			goto_bad;
+		*public_lv = 0;
+	} else if (lv_is_cache_pool(lv)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
@@ -546,7 +573,7 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		goto_bad;
 
 	/* Caches and related */
-	if ((lv_is_cache_type(lv) || lv_is_cache_origin(lv)) &&
+	if ((lv_is_cache_type(lv) || lv_is_cache_origin(lv) || lv_is_writecache(lv) || lv_is_writecache_origin(lv)) &&
 	    !_lv_layout_and_role_cache(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 63d3fad..7c9aebb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1081,6 +1081,7 @@ int lv_is_cow(const struct logical_volume *lv);
 
 int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_writecache_origin(const struct logical_volume *lv);
+int lv_is_writecache_cachevol(const struct logical_volume *lv);
 
 int lv_is_merging_cow(const struct logical_volume *cow);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dc88d87..644cd59 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5180,3 +5180,16 @@ int lv_is_writecache_origin(const struct logical_volume *lv)
 	return 0;
 }
 
+int lv_is_writecache_cachevol(const struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (!sl->seg || !sl->seg->lv || !sl->seg->writecache)
+			continue;
+		if (lv_is_writecache(sl->seg->lv) && (sl->seg->writecache == lv))
+			return 1;
+	}
+	return 0;
+}
+


