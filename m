From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 11 Jan 2016 14:03:39 +0000 (UTC)
Subject: master - cleanup: use _field_set_value and _string_disp consistently in report.c
Message-ID: <20160111140339.C6A996030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f03a21f5b81dae3a1280fdd3704950e90eff13b2
Commit:        f03a21f5b81dae3a1280fdd3704950e90eff13b2
Parent:        a83d611a86e6da31f255d5d87adf14cb3d62a05a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 11 15:01:35 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 11 15:01:42 2016 +0100

cleanup: use _field_set_value and _string_disp consistently in report.c

Do not mix dm_report_field_set_value and _field_set_value and
use single function call throughout for clarity. The same applies
for dm_report_field_string and _string_disp.
---
 lib/report/report.c |   50 +++++++++++++++++++++-----------------------------
 1 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2fdf509..bb2736f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1283,13 +1283,13 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 	return _field_set_value(field, repstr, NULL);
 }
 
-static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute__((unused)))
+			  const void *data, void *private)
 {
 	const char *name = dev_name(*(const struct device * const *) data);
 
-	return dm_report_field_string(rh, field, &name);
+	return _string_disp(rh, mem, field, &name, private);
 }
 
 static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -1417,7 +1417,6 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	const char *cache_policy_name;
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
@@ -1430,12 +1429,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
-		log_error("dm_pool_strdup failed");
-		return 0;
-	}
-
-	return _field_set_value(field, cache_policy_name, NULL);
+	return _string_disp(rh, mem, field, seg->policy_name, private);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1463,7 +1457,7 @@ static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->profile)
-		return dm_report_field_string(rh, field, &lv->profile->name);
+		return _string_disp(rh, mem, field, &lv->profile->name, private);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -1497,10 +1491,8 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct label *l =
 	    (const struct label *) data;
 
-	if (!l->labeller || !l->labeller->fmt) {
-		dm_report_field_set_value(field, "", NULL);
-		return 1;
-	}
+	if (!l->labeller || !l->labeller->fmt)
+		return _field_set_value(field, "", NULL);
 
 	return _string_disp(rh, mem, field, &l->labeller->fmt->name, private);
 }
@@ -1585,9 +1577,9 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 	return _field_set_value(field, name, NULL);
 }
 
-static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute__((unused)),
+			  const void *data, void *private,
 			  int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
@@ -1599,7 +1591,7 @@ static int _do_loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute_
 		repstr = lv_mirror_log_dup(mem, lv);
 
 	if (repstr)
-		return dm_report_field_string(rh, field, &repstr);
+		return _string_disp(rh, mem, field, &repstr, private);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -1620,14 +1612,14 @@ static int _loglvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
-			const void *data, void *private __attribute__((unused)))
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr, *lvname;
 	size_t len;
 
 	if (lv_is_visible(lv))
-		return dm_report_field_string(rh, field, &lv->name);
+		return _string_disp(rh, mem, field, &lv->name, private);
 
 	len = strlen(lv->name) + 3;
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
@@ -1937,9 +1929,9 @@ static int _lvdescendants_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, descendants.result, private, 0);
 }
 
-static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
-			   const void *data, void *private __attribute__((unused)),
+			   const void *data, void *private,
 			   int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
@@ -1951,7 +1943,7 @@ static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 		repstr = lv_move_pv_dup(mem, lv);
 
 	if (repstr)
-		return dm_report_field_string(rh, field, &repstr);
+		return _string_disp(rh, mem, field, &repstr, private);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -1970,9 +1962,9 @@ static int _movepvuuid_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 	return _do_movepv_disp(rh, mem, field, data, private, 1);
 }
 
-static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
-			      const void *data, void *private __attribute__((unused)),
+			      const void *data, void *private,
 			      int uuid)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
@@ -1984,7 +1976,7 @@ static int _do_convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 		repstr = lv_convert_lv_dup(mem, lv);
 
 	if (repstr)
-		return dm_report_field_string(rh, field, &repstr);
+		return _string_disp(rh, mem, field, &repstr, private);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -2239,7 +2231,7 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (seg_is_thin_pool(seg)) {
 		discards_str = get_pool_discards_name(seg->discards);
-		return dm_report_field_string(rh, field, &discards_str);
+		return _string_disp(rh, mem, field, &discards_str, private);
 	}
 
 	return _field_set_value(field, "", NULL);
@@ -2259,7 +2251,7 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (!(cachemode_str = get_cache_mode_name(seg)))
 			return_0;
 
-		return dm_report_field_string(rh, field, &cachemode_str);
+		return _string_disp(rh, mem, field, &cachemode_str, private);
 	}
 
 	return _field_set_value(field, "", NULL);
@@ -2439,7 +2431,7 @@ static int _vgprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 
 	if (vg->profile)
-		return dm_report_field_string(rh, field, &vg->profile->name);
+		return _string_disp(rh, mem, field, &vg->profile->name, private);
 
 	return _field_set_value(field, "", NULL);
 }


