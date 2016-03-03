From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:10 +0000 (UTC)
Subject: master - cleanup: use _field_string
Message-ID: <20160303092010.A9007605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a975dc530e31fec883bbf6e2db7a6b48cb3b789d
Commit:        a975dc530e31fec883bbf6e2db7a6b48cb3b789d
Parent:        25bf0beedb8042ed77d97a79289168255b451475
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 11:50:12 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

cleanup: use _field_string

Make at least some 'advantage' in use local func and do dereference
internally from char pointer and use short list of params.
---
 lib/report/report.c |   61 +++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index ff54cc4..631a1bf 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1209,6 +1209,11 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
 
+static int _field_string(struct dm_report *rh, struct dm_report_field *field, const char *data)
+{
+	return dm_report_field_string(rh, field, &data);
+}
+
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
 	dm_report_field_set_value(field, data, sort);
@@ -1269,7 +1274,7 @@ static int _chars_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((
 		       struct dm_report_field *field,
 		       const void *data, void *private __attribute__((unused)))
 {
-	return dm_report_field_string(rh, field, (const char * const *) &data);
+	return _field_string(rh, field, data);
 }
 
 static int _uuid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1288,9 +1293,7 @@ static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private)
 {
-	const char *name = dev_name(*(const struct device * const *) data);
-
-	return _string_disp(rh, mem, field, &name, private);
+	return _field_string(rh, field, dev_name(*(const struct device * const *) data));
 }
 
 static int _devices_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1507,7 +1510,7 @@ static int _kernel_cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if ((lvdm->seg_status.type == SEG_STATUS_CACHE) &&
 	    lvdm->seg_status.cache->policy_name)
-		return _string_disp(rh, mem, field, &lvdm->seg_status.cache->policy_name, NULL);
+		return _field_string(rh, field, lvdm->seg_status.cache->policy_name);
 
 	return _field_set_value(field, GET_FIRST_RESERVED_NAME(cache_policy_undef),
 				GET_FIELD_RESERVED_VALUE(cache_policy_undef));
@@ -1530,7 +1533,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _string_disp(rh, mem, field, &seg->policy_name, private);
+	return _field_string(rh, field, seg->policy_name);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1558,7 +1561,7 @@ static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->profile)
-		return _string_disp(rh, mem, field, &lv->profile->name, private);
+		return _field_string(rh, field, lv->profile->name);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -1568,9 +1571,8 @@ static int _lvlockargs_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const char *repstr = lv->lock_args ? lv->lock_args : "";
 
-	return _string_disp(rh, mem, field, &repstr, private);
+	return _field_string(rh, field, lv->lock_args ? : "");
 }
 
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1580,7 +1582,7 @@ static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 
 	if (vg->fid && vg->fid->fmt)
-		return _string_disp(rh, mem, field, &vg->fid->fmt->name, private);
+		return _field_string(rh, field, vg->fid->fmt->name);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -1589,13 +1591,12 @@ static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
 {
-	const struct label *l =
-	    (const struct label *) data;
+	const struct label *l = (const struct label *) data;
 
-	if (!l->labeller || !l->labeller->fmt)
-		return _field_set_value(field, "", NULL);
+	if (l->labeller && l->labeller->fmt)
+		return _field_string(rh, field, l->labeller->fmt->name);
 
-	return _string_disp(rh, mem, field, &l->labeller->fmt->name, private);
+	return _field_set_value(field, "", NULL);
 }
 
 static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -1688,7 +1689,7 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	size_t len;
 
 	if (lv_is_visible(lv) || !cmd->report_mark_hidden_devices)
-		return _string_disp(rh, mem, field, &lv->name, private);
+		return _field_string(rh, field, lv->name);
 
 	len = strlen(lv->name) + 3;
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
@@ -2030,7 +2031,7 @@ static int _do_movepv_disp(struct dm_report *rh, struct dm_pool *mem,
 		repstr = lv_move_pv_dup(mem, lv);
 
 	if (repstr)
-		return _string_disp(rh, mem, field, &repstr, private);
+		return _field_string(rh, field, repstr);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -2316,7 +2317,7 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (seg_is_thin_pool(seg)) {
 		discards_str = get_pool_discards_name(seg->discards);
-		return _string_disp(rh, mem, field, &discards_str, private);
+		return _field_string(rh, field, discards_str);
 	}
 
 	return _field_set_value(field, "", NULL);
@@ -2353,7 +2354,7 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (!(cachemode_str = get_cache_mode_name(seg)))
 			return_0;
 
-		return _string_disp(rh, mem, field, &cachemode_str, private);
+		return _field_string(rh, field, cachemode_str);
 	}
 
 	return _field_set_value(field, "", NULL);
@@ -2441,7 +2442,7 @@ static int _vgsystemid_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	const char *repstr = (vg->system_id && *vg->system_id) ? vg->system_id : vg->lvm1_system_id ? : "";
 
-	return _string_disp(rh, mem, field, &repstr, private);
+	return _field_string(rh, field, repstr);
 }
 
 static int _vglocktype_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2449,9 +2450,8 @@ static int _vglocktype_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	const char *repstr = vg->lock_type ? vg->lock_type : "";
 
-	return _string_disp(rh, mem, field, &repstr, private);
+	return _field_string(rh, field, vg->lock_type ? : "");
 }
 
 static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2459,9 +2459,8 @@ static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	const char *repstr = vg->lock_args ? vg->lock_args : "";
 
-	return _string_disp(rh, mem, field, &repstr, private);
+	return _field_string(rh, field, vg->lock_args ? : "");
 }
 
 static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -2539,7 +2538,7 @@ static int _vgprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 
 	if (vg->profile)
-		return _string_disp(rh, mem, field, &vg->profile->name, private);
+		return _field_string(rh, field, vg->profile->name);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -2703,7 +2702,7 @@ static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
 	char *sync_action;
 
 	if (lv_is_raid(lv) && lv_raid_sync_action(lv, &sync_action))
-		return _string_disp(rh, mem, field, &sync_action, private);
+		return _field_string(rh, field, sync_action);
 
 	return _field_set_value(field, "", NULL);
 }
@@ -2923,7 +2922,7 @@ static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? GET_FIRST_RESERVED_NAME(vg_permissions_rw)
 										     : GET_FIRST_RESERVED_NAME(vg_permissions_r);
-	return _string_disp(rh, mem, field, &perms, private);
+	return _field_string(rh, field, perms);
 }
 
 static int _vgextendable_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -2955,7 +2954,7 @@ static int _vgallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
 				    const void *data, void *private)
 {
 	const char *alloc_policy = get_alloc_string(((const struct volume_group *) data)->alloc) ? : _str_unknown;
-	return _string_disp(rh, mem, field, &alloc_policy, private);
+	return _field_string(rh, field, alloc_policy);
 }
 
 static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -3079,7 +3078,7 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			perms = _str_unknown;
 	}
 
-	return _string_disp(rh, mem, field, &perms, private);
+	return _field_string(rh, field, perms);
 }
 
 static int _lvallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -3087,7 +3086,7 @@ static int _lvallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
 				    const void *data, void *private)
 {
 	const char *alloc_policy = get_alloc_string(((const struct logical_volume *) data)->alloc) ? : _str_unknown;
-	return _string_disp(rh, mem, field, &alloc_policy, private);
+	return _field_string(rh, field, alloc_policy);
 }
 
 static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -3323,7 +3322,7 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 			health = "metadata_read_only";
 	}
 
-	return _string_disp(rh, mem, field, &health, private);
+	return _field_string(rh, field, health);
 }
 
 static int _lvcheckneeded_disp(struct dm_report *rh, struct dm_pool *mem,


