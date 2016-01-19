From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:30:39 +0000 (UTC)
Subject: master - refactor: add 'delimiter' variable for non-default delimiter when reporting string list
Message-ID: <20160119133039.286F8602DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ed324648e4dad4bd504f0bea9d94efa2a99fe4c
Commit:        2ed324648e4dad4bd504f0bea9d94efa2a99fe4c
Parent:        48f270970fc526f9f0ac7d074639e8ed90346586
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 11:50:41 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 11:50:52 2016 +0100

refactor: add 'delimiter' variable for non-default delimiter when reporting string list

---
 lib/report/report.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index c03469a..4b00a76 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1217,11 +1217,12 @@ static int _field_set_value(struct dm_report_field *field, const void *data, con
 }
 
 static int _field_set_string_list(struct dm_report *rh, struct dm_report_field *field,
-				  const struct dm_list *list, void *private, int sorted)
+				  const struct dm_list *list, void *private, int sorted,
+				  const char *delimiter)
 {
 	struct cmd_context *cmd = (struct cmd_context *) private;
-	return sorted ? dm_report_field_string_list(rh, field, list, cmd->report_list_item_separator)
-		      : dm_report_field_string_list_unsorted(rh, field, list, cmd->report_list_item_separator);
+	return sorted ? dm_report_field_string_list(rh, field, list, delimiter ? : cmd->report_list_item_separator)
+		      : dm_report_field_string_list_unsorted(rh, field, list, delimiter ? : cmd->report_list_item_separator);
 }
 
 /*
@@ -1346,7 +1347,7 @@ static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct dm_list *tagsl = (const struct dm_list *) data;
 
-	return _field_set_string_list(rh, field, tagsl, private, 1);
+	return _field_set_string_list(rh, field, tagsl, private, 1, NULL);
 }
 
 struct _str_list_append_baton {
@@ -1382,7 +1383,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 		seg = first_seg(seg->pool_lv);
 	else if (!seg_is_cache_pool(seg)) {
 		dm_list_init(&dummy_list);
-		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0, NULL);
 		/* TODO: once we have support for STR_LIST reserved values, replace with:
 		 * return _field_set_value(field,  GET_FIRST_RESERVED_NAME(cache_settings_undef), GET_FIELD_RESERVED_VALUE(cache_settings_undef));
 		 */
@@ -1392,7 +1393,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 		settings = seg->policy_settings->child;
 	else {
 		dm_list_init(&dummy_list);
-		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0, NULL);
 		/* TODO: once we have support for STR_LIST reserved values, replace with:
 		 * return _field_set_value(field,  GET_FIRST_RESERVED_NAME(cache_settings_undef), GET_FIELD_RESERVED_VALUE(cache_settings_undef));
 		 */
@@ -1409,7 +1410,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 		settings = settings->sib;
 	};
 
-	return _field_set_string_list(rh, field, result, private, 0);
+	return _field_set_string_list(rh, field, result, private, 0, NULL);
 }
 
 static int _do_get_kernel_cache_settings_list(struct dm_pool *mem,
@@ -1465,7 +1466,7 @@ static int _kernel_cache_settings_disp(struct dm_report *rh, struct dm_pool *mem
 
 	if (lvdm->seg_status.type != SEG_STATUS_CACHE) {
 		dm_list_init(&dummy_list);
-		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0, NULL);
 	}
 
 	if (!(mem = dm_pool_create("reporter_pool", 1024)))
@@ -1474,7 +1475,7 @@ static int _kernel_cache_settings_disp(struct dm_report *rh, struct dm_pool *mem
 	if (!_get_kernel_cache_settings_list(mem, lvdm->seg_status.cache, &result))
 		goto_out;
 
-	r = _field_set_string_list(rh, field, result, private, 0);
+	r = _field_set_string_list(rh, field, result, private, 0, NULL);
 out:
 	dm_pool_destroy(mem);
 	return r;
@@ -1515,7 +1516,7 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!(list_lv_modules(mem, lv, modules)))
 		return_0;
 
-	return _field_set_string_list(rh, field, modules, private, 1);
+	return _field_set_string_list(rh, field, modules, private, 1, NULL);
 }
 
 static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1925,7 +1926,7 @@ static int _lvancestors_disp(struct dm_report *rh, struct dm_pool *mem,
 		return_0;
 	}
 
-	return _field_set_string_list(rh, field, ancestors.result, private, 0);
+	return _field_set_string_list(rh, field, ancestors.result, private, 0, NULL);
 }
 
 static int _find_descendants(struct _str_list_append_baton *descendants,
@@ -1980,7 +1981,7 @@ static int _lvdescendants_disp(struct dm_report *rh, struct dm_pool *mem,
 		return_0;
 	}
 
-	return _field_set_string_list(rh, field, descendants.result, private, 0);
+	return _field_set_string_list(rh, field, descendants.result, private, 0, NULL);
 }
 
 static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2910,7 +2911,7 @@ static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _field_set_string_list(rh, field, lv_layout, private, 0);
+	return _field_set_string_list(rh, field, lv_layout, private, 0, NULL);
 }
 
 static int _lvrole_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2926,7 +2927,7 @@ static int _lvrole_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _field_set_string_list(rh, field, lv_role, private, 0);
+	return _field_set_string_list(rh, field, lv_role, private, 0, NULL);
 }
 
 static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,


