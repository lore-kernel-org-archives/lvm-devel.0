From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 25 Sep 2014 13:52:40 -0500
Subject: LVM cache: Add function to retrieve cachemode
Message-ID: <1411671160.4303.1.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

cache: Add function to retrieve the cachemode of a cache[-pool] LV

This patch adds a function that allows the retrieval of the cachemode
of a cache[-pool] LV.  The caller can choose whether they want the
return to be string or uint format (or both).  Allowing the user to
be able to select which arguments they would like returned is inline
with the way the other lv_cache_*_info functions work.  This new
function is called lv_cache_cachemode_info (I can see arguments for
s/cachemode/mode/).

This patch is a necessary component of adding the ability to display
cachemode via 'lvs' or being able to check it in other places in the
code base.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -294,6 +294,11 @@ int lv_cache_policy_info(struct logical_
 {
 	return 0;
 }
+int lv_cache_cachemode_info(struct logical_volume *lv,
+			    char **cachemode_str, uint32_t *cachemode_flags);
+{
+	return 0;
+}
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent)
 {
@@ -1136,6 +1141,100 @@ int lv_cache_policy_info(struct logical_
 	}
 
 	dev_manager_destroy(dm);
+
+	return 1;
+}
+
+/*
+ * lv_cache_cachemode_info
+ * @lv
+ * @cachemode_str
+ * @cachemode_flags
+ *
+ * This function returns the cache mode for the given cache[-pool] LV.
+ * The user is free to select either or both 'cachemode_str' or
+ * 'cachemode_flags'.  If 'cachemode_str' is selected, the string representing
+ * the cachemode with be allocated and returned.  If cachemode_flags is
+ * passed in, then it will be populated with the correct DM_CACHE_FEATURE_*
+ * flag.  The two options are provided because sometimes it is easier to deal
+ * with the flags and other times a string is desired.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+int lv_cache_cachemode_info(struct logical_volume *lv,
+			    char **cachemode_str, uint32_t *cachemode_flags)
+{
+	int i;
+	struct lv_segment *cache_seg;
+	struct logical_volume *cache_lv;
+	struct dev_manager *dm;
+	struct dm_status_cache *status;
+	struct dm_pool *mem = lv->vg->cmd->mem;
+
+	/* The user is free to choose which args they are interested in */
+	if (cachemode_str)
+		*cachemode_str = NULL;
+	if (cachemode_flags)
+		*cachemode_flags = 0;
+
+	if (lv_is_cache(lv))
+		cache_lv = lv;
+	else if (lv_is_cache_pool(lv)) {
+		if (dm_list_empty(&lv->segs_using_this_lv)) {
+			//FIXME: Ok to return value not sourced from kernel?
+			log_error(INTERNAL_ERROR "Unable to get cachemode"
+				  " of unlinked cache_pool, %s", lv->name);
+			//FIXME: ... because we could do this:
+			if (cachemode_str) {
+				if (first_seg(lv)->feature_flags &
+				    DM_CACHE_FEATURE_WRITEBACK)
+					*cachemode_str = dm_pool_strdup(mem, "writeback");
+				else if (first_seg(lv)->feature_flags &
+					 DM_CACHE_FEATURE_WRITETHROUGH)
+					*cachemode_str = dm_pool_strdup(mem, "writethrough");
+				else
+					*cachemode_str = NULL;
+			}
+			if (cachemode_flags)
+				*cachemode_flags = first_seg(lv)->feature_flags;
+			return 1;
+		}
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+		cache_lv = cache_seg->lv;
+	} else {
+		log_error(INTERNAL_ERROR
+			  "Unable to get policy info of non-cache LV, %s",
+			  lv->name);
+		return 0;
+	}
+
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
+		return_0;
+
+	log_debug_activation("Checking cachemode for LV %s/%s",
+			     cache_lv->vg->name, cache_lv->name);
+
+	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_cache_status(dm, cache_lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+
+	if (cachemode_flags)
+		*cachemode_flags = status->feature_flags;
+	if (cachemode_str) {
+		if (status->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+			*cachemode_str = dm_pool_strdup(mem, "writeback");
+		else if (status->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
+			*cachemode_str = dm_pool_strdup(mem, "writethrough");
+		else
+			*cachemode_str = NULL;
+	}
+
+	dev_manager_destroy(dm);
 
 	return 1;
 }
Index: lvm2/lib/activate/activate.h
===================================================================
--- lvm2.orig/lib/activate/activate.h
+++ lvm2/lib/activate/activate.h
@@ -126,6 +126,8 @@ int lv_cache_block_info(struct logical_v
 int lv_cache_policy_info(struct logical_volume *lv,
 			 const char **policy_name, int *policy_argc,
 			 const char ***policy_argv);
+int lv_cache_cachemode_info(struct logical_volume *lv,
+			    char **cachemode_str, uint32_t *cachemode_flags);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,



