From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:57 +0000 (UTC)
Subject: master - report: display lv_name, lv_uuid, vg_name, lv_time and new lv_time_removed for historical LVs
Message-ID: <20160303131957.1C7F260232@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28f96d5ab617cc41b8aab66c7cb19d750d68d2fd
Commit:        28f96d5ab617cc41b8aab66c7cb19d750d68d2fd
Parent:        2e7a1210622e25a5a3d813b9a069767eaad3b4ac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:23:23 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:14 2016 +0100

report: display lv_name,lv_uuid,vg_name,lv_time and new lv_time_removed for historical LVs

---
 lib/display/display.c   |    2 +-
 lib/metadata/lv.c       |   23 ++++++++++++++++++++---
 lib/metadata/lv.h       |    4 +++-
 lib/report/columns.h    |    5 +++--
 lib/report/properties.c |    4 +++-
 lib/report/report.c     |   43 +++++++++++++++++++++++++++++++++++++++++--
 lib/report/values.h     |    1 +
 7 files changed, 72 insertions(+), 10 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 0948dda..2b7ea52 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -383,7 +383,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	log_print("LV UUID                %s", uuid);
 	log_print("LV Write Access        %s", access_str);
 	log_print("LV Creation host, time %s, %s",
-		  lv_host_dup(cmd->mem, lv), lv_time_dup(cmd->mem, lv, 1));
+		  lv_host_dup(cmd->mem, lv), lv_creation_time_dup(cmd->mem, lv, 1));
 
 	if (lv_is_origin(lv)) {
 		log_print("LV snapshot status     source of");
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index a5144e9..ab937c4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1274,12 +1274,13 @@ int lv_set_creation(struct logical_volume *lv,
 	return 1;
 }
 
-char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode)
+static char *_time_dup(struct cmd_context *cmd, struct dm_pool *mem,
+		       time_t ts, int iso_mode)
 {
 	char buffer[4096];
 	struct tm *local_tm;
-	time_t ts = (time_t)lv->timestamp;
-	const char *format = iso_mode ? DEFAULT_TIME_FORMAT : lv->vg->cmd->time_format;
+	const char *format = iso_mode ? DEFAULT_TIME_FORMAT
+				      : cmd->time_format;
 
 	if (!ts ||
 	    !(local_tm = localtime(&ts)) ||
@@ -1289,6 +1290,22 @@ char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_
 	return dm_pool_strdup(mem, buffer);
 }
 
+char *lv_creation_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode)
+{
+	time_t ts = lv_is_historical(lv) ? (time_t) lv->this_glv->historical->timestamp
+					 : (time_t) lv->timestamp;
+
+	return _time_dup(lv->vg->cmd, mem, ts, iso_mode);
+}
+
+char *lv_removal_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode)
+{
+	time_t ts = lv_is_historical(lv) ? (time_t)lv->this_glv->historical->timestamp_removed
+					 : (time_t)0;
+
+	return _time_dup(lv->vg->cmd, mem, ts, iso_mode);
+}
+
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return dm_pool_strdup(mem, lv->hostname ? : "");
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index f554bce..f9f5b4e 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -187,10 +187,12 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
-char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
+char *lv_creation_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
+char *lv_removal_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
+char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
 #endif /* _LVM_LV_H */
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 56a8628..35c2b2f 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -32,7 +32,7 @@
  */
 
 /* *INDENT-OFF* */
-FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier.", 0)
+FIELD(LVS, lv, STR, "LV UUID", lvid, 38, lvuuid, lv_uuid, "Unique identifier.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV including its VG, namely VG/LV.", 0)
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
@@ -92,7 +92,8 @@ FIELD(LVS, lv, STR, "Pool UUID", lvid, 38, poollvuuid, pool_lv_uuid, "For thin v
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "Lock Args", lvid, 9, lvlockargs, lv_lockargs, "Lock args of the LV used by lvmlockd.", 0)
-FIELD(LVS, lv, TIM, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, TIM, "CTime", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, TIM, "RTime", lvid, 26, lvtimeremoved, lv_time_removed, "Removal time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 76a72be..030936b 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -362,8 +362,10 @@ GET_LV_NUM_PROPERTY_FN(metadata_percent, _metadata_percent(lv))
 #define _metadata_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_metadata_size, lv_metadata_size(lv) * SECTOR_SIZE)
 #define _lv_metadata_size_set prop_not_implemented_set
-GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv, 0))
+GET_LV_STR_PROPERTY_FN(lv_time, lv_creation_time_dup(lv->vg->vgmem, lv, 0))
 #define _lv_time_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_time_removed, lv_removal_time_dup(lv->vg->vgmem, lv, 0))
+#define _lv_time_removed_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
 #define _lv_host_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 056afd2..47a911e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1688,6 +1688,9 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr, *lvname;
 	size_t len;
 
+	if (lv_is_historical(lv))
+		return _string_disp(rh, mem, field, &lv->this_glv->historical->name, private);
+
 	if (lv_is_visible(lv) || !cmd->report_mark_hidden_devices)
 		return _field_string(rh, field, lv->name);
 
@@ -2463,6 +2466,25 @@ static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_string(rh, field, vg->lock_args ? : "");
 }
 
+static int _lvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const union lvid *lvid;
+	char *repstr;
+
+	if (lv_is_historical(lv))
+		lvid = &lv->this_glv->historical->lvid;
+	else
+		lvid = &lv->lvid;
+
+	if (!(repstr = id_format_and_copy(mem, &lvid->id[1])))
+		return_0;
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 		        struct dm_report_field *field,
 		        const void *data, void *private __attribute__((unused)))
@@ -2851,14 +2873,31 @@ static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr;
 	uint64_t *sortval;
 
-	if (!(repstr = lv_time_dup(mem, lv, 0)) ||
+	if (!(repstr = lv_creation_time_dup(mem, lv, 0)) ||
 	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("Failed to allocate buffer for time.");
 		return 0;
 	}
 
-	*sortval = lv->timestamp;
+	*sortval = lv_is_historical(lv) ? lv->this_glv->historical->timestamp : lv->timestamp;
+	return _field_set_value(field, repstr, sortval);
+}
+
+static int _lvtimeremoved_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+	uint64_t *sortval;
+
+	if (!(repstr = lv_removal_time_dup(mem, lv, 0)) ||
+	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
+		log_error("Failed to allocate buffer for time.");
+		return 0;
+	}
 
+	*sortval = lv_is_historical(lv) ? lv->this_glv->historical->timestamp_removed : 0;
 	return _field_set_value(field, repstr, sortval);
 }
 
diff --git a/lib/report/values.h b/lib/report/values.h
index 43c5abe..4a6c235 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -90,6 +90,7 @@ FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_error, "", "error", "erro
 FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
 FIELD_RESERVED_VALUE(NOFLAG, lv_when_full, lv_when_full_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time, lv_time_fuzzy, "", lv_time_handler, NULL)
+FIELD_RESERVED_VALUE(NAMED | RANGE | FUZZY | DYNAMIC, lv_time_removed, lv_time_removed_fuzzy, "", lv_time_handler, NULL)
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "undefined")


