From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:21 -0500
Subject: master - cache: factor report functions
Message-ID: <201811062143.wA6LhLxW004805@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e548e7c29d18034d153dc2ebe4ff0cc6bb99dc81
Commit:        e548e7c29d18034d153dc2ebe4ff0cc6bb99dc81
Parent:        a686391eca557fc35eb90c1ef4cdc57418b6ee19
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 16:33:34 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:29 2018 -0600

cache: factor report functions

to prepare for future addition
---
 lib/report/report.c |   65 ++++++++++++++++++++++++++------------------------
 1 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 369f47c..52baa6c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1424,24 +1424,19 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 				const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const struct lv_segment *setting_seg = NULL;
 	const struct dm_config_node *settings;
 	struct dm_list *result;
 	struct _str_list_append_baton baton;
 	struct dm_list dummy_list; /* dummy list to display "nothing" */
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
-	else if (!seg_is_cache_pool(seg)) {
-		dm_list_init(&dummy_list);
-		return _field_set_string_list(rh, field, &dummy_list, private, 0, NULL);
-		/* TODO: once we have support for STR_LIST reserved values, replace with:
-		 * return _field_set_value(field,  GET_FIRST_RESERVED_NAME(cache_settings_undef), GET_FIELD_RESERVED_VALUE(cache_settings_undef));
-		 */
-	}
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
 
-	if (seg->policy_settings)
-		settings = seg->policy_settings->child;
-	else {
+	if (!setting_seg || !setting_seg->policy_settings) {
 		dm_list_init(&dummy_list);
 		return _field_set_string_list(rh, field, &dummy_list, private, 0, NULL);
 		/* TODO: once we have support for STR_LIST reserved values, replace with:
@@ -1449,6 +1444,8 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 		 */
 	}
 
+	settings = setting_seg->policy_settings->child;
+
 	if (!(result = str_list_create(mem)))
 		return_0;
 
@@ -1566,19 +1563,19 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
-	else if (!seg_is_cache_pool(seg) || !seg->policy_name)
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+
+	if (!setting_seg || !setting_seg->policy_name)
 		return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
 					GET_FIELD_RESERVED_VALUE(cache_policy_undef));
 
-	if (!seg->policy_name) {
-		log_error(INTERNAL_ERROR "Unexpected NULL policy name.");
-		return 0;
-	}
-
-	return _field_string(rh, field, seg->policy_name);
+	return _field_string(rh, field, setting_seg->policy_name);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2747,21 +2744,27 @@ static int _cachemetadataformat_disp(struct dm_report *rh, struct dm_pool *mem,
 				     const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const struct lv_segment *setting_seg = NULL;
 	const uint64_t *fmt;
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
 
-	if (seg_is_cache_pool(seg)) {
-		switch (seg->cache_metadata_format) {
-		case CACHE_METADATA_FORMAT_1:
-		case CACHE_METADATA_FORMAT_2:
-			fmt = (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2) ? &_two64 : &_one64;
-			return dm_report_field_uint64(rh, field, fmt);
-		default: /* unselected/undefined for all other cases */;
-		}
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+
+	else
+		goto undef;
+
+	switch (setting_seg->cache_metadata_format) {
+	case CACHE_METADATA_FORMAT_1:
+	case CACHE_METADATA_FORMAT_2:
+		fmt = (setting_seg->cache_metadata_format == CACHE_METADATA_FORMAT_2) ? &_two64 : &_one64;
+		return dm_report_field_uint64(rh, field, fmt);
+	default: /* unselected/undefined for all other cases */;
 	}
 
+ undef:
 	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 


