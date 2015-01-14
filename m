From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:46 +0000 (UTC)
Subject: master - cleanup: update API for segment reporting
Message-ID: <20150114135446.5480C60C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d202f43fff6ff7d12540440ae6b16a0ec2c7de5e
Commit:        d202f43fff6ff7d12540440ae6b16a0ec2c7de5e
Parent:        cdd17eee377013a569e2aeed0cbe865749323def
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 10:31:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:50:08 2015 +0100

cleanup: update API for segment reporting

API for seg reporting is breaking internal lvm coding - it cannot
use vgmem mem pool for allocation of reported value.
So use separate pool instead of 'vgmem' for non vg related allocations

Add consts for many function params - but still many other are left
for now as non-const - needs deeper level of change even on libdm side.
---
 lib/activate/activate.c |   20 +++++----
 lib/activate/activate.h |   18 ++++----
 lib/report/report.c     |   66 +++++++++++++++-------------
 lib/report/report.h     |   10 ++--
 libdm/libdevmapper.h    |    1 +
 tools/reporter.c        |  110 +++++++++++++++++++++++++----------------------
 6 files changed, 121 insertions(+), 104 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c63cbde..d1d1104 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -619,7 +619,8 @@ int target_present(struct cmd_context *cmd, const char *target_name,
 
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		    int use_layer, struct lvinfo *info,
-		    struct lv_segment *seg, struct lv_seg_status *seg_status,
+		    const struct lv_segment *seg,
+		    struct lv_seg_status *seg_status,
 		    int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
@@ -698,7 +699,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
  * Returns 1 if lv_seg_status structure populated,
  * else 0 on failure or if device not active locally.
  */
-int lv_status(struct cmd_context *cmd, struct lv_segment *lv_seg,
+int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
 	      struct lv_seg_status *lv_seg_status)
 {
 	if (!activation())
@@ -712,18 +713,18 @@ int lv_status(struct cmd_context *cmd, struct lv_segment *lv_seg,
  * else 0 on failure or if device not active locally.
  *
  * This is the same as calling lv_info and lv_status,
- * but* it's done in one go with one ioctl if possible!
+ * but* it's done in one go with one ioctl if possible!                                                             ]
  */
 int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			   struct lv_segment *lv_seg, int use_layer,
-			   struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
-			   int with_open_count, int with_read_ahead)
+			    const struct lv_segment *lv_seg, int use_layer,
+			    struct lv_with_info_and_seg_status *status,
+			    int with_open_count, int with_read_ahead)
 {
 	if (!activation())
 		return 0;
 
 	if (lv == lv_seg->lv)
-		return _lv_info(cmd, lv, use_layer, lvinfo, lv_seg, lv_seg_status,
+		return _lv_info(cmd, lv, use_layer, &status->info, lv_seg, &status->seg_status,
 				with_open_count, with_read_ahead);
 
 	/*
@@ -731,8 +732,9 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 	 * status for segment that belong to another LV,
 	 * we need to acquire info and status separately!
 	 */
-	return _lv_info(cmd, lv, use_layer, lvinfo, NULL, NULL, with_open_count, with_read_ahead) &&
-	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg, lv_seg_status, 0, 0);
+	return _lv_info(cmd, lv, use_layer, &status->info, NULL, NULL, with_open_count, with_read_ahead) &&
+	       _lv_info(cmd, lv_seg->lv, use_layer, NULL, lv_seg,
+			&status->seg_status, 0, 0);
 }
 
 #define OPEN_COUNT_CHECK_RETRIES 25
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ef375bd..1376ce5 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -41,16 +41,16 @@ typedef enum {
 
 struct lv_seg_status {
 	struct dm_pool *mem;			/* input */
-	struct lv_segment *seg;			/* input */
+	const struct lv_segment *seg;		/* input */
 	lv_seg_status_type_t type;		/* output */
-	void *status; /* struct dm_status_* */	/* output */
+	const void *status; /* struct dm_status_* */	/* output */
 };
 
 struct lv_with_info_and_seg_status {
-	struct logical_volume *lv;		/* input */
-	struct lvinfo *info;			/* output */
+	const struct logical_volume *lv;	/* input */
+	struct lvinfo info;			/* output */
 	int seg_part_of_lv;			/* output */
-	struct lv_seg_status *seg_status;	/* input/output, see lv_seg_status */
+	struct lv_seg_status seg_status;	/* input/output, see lv_seg_status */
 };
 
 struct lv_activate_opts {
@@ -123,19 +123,19 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
  * Returns 1 if lv_seg_status structure has been populated,
  * else 0 on failure or if device not active locally.
  */
-int lv_status(struct cmd_context *cmd, struct lv_segment *lv_seg,
+int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
 	      struct lv_seg_status *lv_seg_status);
 
 /*
  * Returns 1 if lv_info_and_seg_status structure has been populated,
  * else 0 on failure or if device not active locally.
  *
- * lv_info_with_seg_status is the same as calling lv_info and then lv_seg_status,
+ * lv_info_with_seg_status is the same as calling lv_info and then lv_status,
  * but this fn tries to do that with one ioctl if possible.
  */
 int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
-			    struct lv_segment *lv_seg, int use_layer,
-			    struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
+			    const struct lv_segment *lv_seg, int use_layer,
+			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead);
 
 int lv_check_not_in_use(const struct logical_volume *lv);
diff --git a/lib/report/report.c b/lib/report/report.c
index d0351f7..be80e77 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -393,8 +393,8 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info && lvdm->info->exists && lvdm->info->major >= 0)
-		return dm_report_field_int(rh, field, &lvdm->info->major);
+	if (lvdm->info.exists && lvdm->info.major >= 0)
+		return dm_report_field_int(rh, field, &lvdm->info.major);
 
 	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 }
@@ -405,8 +405,8 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info && lvdm->info->exists && lvdm->info->minor >= 0)
-		return dm_report_field_int(rh, field, &lvdm->info->minor);
+	if (lvdm->info.exists && lvdm->info.minor >= 0)
+		return dm_report_field_int(rh, field, &lvdm->info.minor);
 
 	return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 }
@@ -746,10 +746,10 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (!lvdm->info || !lvdm->info->exists)
+	if (!lvdm->info.exists)
 		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 
-	return _size32_disp(rh, mem, field, &lvdm->info->read_ahead, private);
+	return _size32_disp(rh, mem, field, &lvdm->info.read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1533,9 +1533,9 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (!lv_is_pvmove(lvdm->lv)) {
 		if (lvdm->lv->status & LVM_WRITE) {
-			if (!lvdm->info->exists)
+			if (!lvdm->info.exists)
 				perms = _str_unknown;
-			else if (lvdm->info->read_only)
+			else if (lvdm->info.read_only)
 				perms = GET_FIRST_RESERVED_NAME(lv_permissions_r_override);
 			else
 				perms = GET_FIRST_RESERVED_NAME(lv_permissions_rw);
@@ -1702,8 +1702,8 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->suspended, GET_FIRST_RESERVED_NAME(lv_suspended_y), private);
+	if (lvdm->info.exists)
+		return _binary_disp(rh, mem, field, lvdm->info.suspended, GET_FIRST_RESERVED_NAME(lv_suspended_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1714,8 +1714,8 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->live_table, GET_FIRST_RESERVED_NAME(lv_live_table_y), private);
+	if (lvdm->info.exists)
+		return _binary_disp(rh, mem, field, lvdm->info.live_table, GET_FIRST_RESERVED_NAME(lv_live_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1726,8 +1726,8 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->inactive_table, GET_FIRST_RESERVED_NAME(lv_inactive_table_y), private);
+	if (lvdm->info.exists)
+		return _binary_disp(rh, mem, field, lvdm->info.inactive_table, GET_FIRST_RESERVED_NAME(lv_inactive_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1738,8 +1738,8 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvdm->info->exists)
-		return _binary_disp(rh, mem, field, lvdm->info->open_count, GET_FIRST_RESERVED_NAME(lv_device_open_y), private);
+	if (lvdm->info.exists)
+		return _binary_disp(rh, mem, field, lvdm->info.open_count, GET_FIRST_RESERVED_NAME(lv_device_open_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1801,9 +1801,9 @@ static int _cache_ ## cache_status_field_name ## _disp (struct dm_report *rh, \
 							void *private) \
 { \
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
-	if (lvdm->seg_status->type != SEG_STATUS_CACHE) \
+	if (lvdm->seg_status.type != SEG_STATUS_CACHE) \
 		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
-	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status->status + offsetof(struct dm_status_cache, cache_status_field_name))); \
+	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status.status + offsetof(struct dm_status_cache, cache_status_field_name))); \
 }
 
 GENERATE_CACHE_STATUS_DISP_FN(total_blocks)
@@ -1840,7 +1840,7 @@ static void *_obj_get_vg(void *obj)
 
 static void *_obj_get_lv(void *obj)
 {
-	return ((struct lvm_report_object *)obj)->lvdm->lv;
+	return (struct logical_volume *)((struct lvm_report_object *)obj)->lvdm->lv;
 }
 
 static void *_obj_get_lv_with_info_and_seg_status(void *obj)
@@ -1973,24 +1973,30 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 /*
  * Create a row of data for an object
  */
-int report_object(void *handle, struct volume_group *vg,
-		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct lvinfo *lvinfo,  struct lv_seg_status *lv_seg_status,
-		  struct label *label)
+int report_object(void *handle, const struct volume_group *vg,
+		  const struct logical_volume *lv, const struct physical_volume *pv,
+		  const struct lv_segment *seg, const struct pv_segment *pvseg,
+		  const struct lvinfo *lvinfo,  const struct lv_seg_status *lv_seg_status,
+		  const struct label *label)
 {
 	struct device dummy_device = { .dev = 0 };
 	struct label dummy_label = { .dev = &dummy_device };
-	struct lv_with_info_and_seg_status lvdm = { .lv = lv, .info = lvinfo, .seg_status = lv_seg_status};
+	struct lv_with_info_and_seg_status lvdm = { .lv = lv };
 	struct lvm_report_object obj = {
-		.vg = vg,
+		.vg = (struct volume_group *) vg,
 		.lvdm = &lvdm,
-		.pv = pv,
-		.seg = seg,
-		.pvseg = pvseg,
-		.label = label ? : (pv ? pv_label(pv) : NULL)
+		.pv = (struct physical_volume *) pv,
+		.seg = (struct lv_segment *) seg,
+		.pvseg = (struct pv_segment *) pvseg,
+		.label = (struct label *) (label ? : (pv ? pv_label(pv) : NULL))
 	};
 
+	if (lvinfo)
+		lvdm.info = *lvinfo;
+
+	if (lv_seg_status)
+		lvdm.seg_status = *lv_seg_status;
+
 	/* FIXME workaround for pv_label going through cache; remove once struct
 	 * physical_volume gains a proper "label" pointer */
 	if (!obj.label) {
diff --git a/lib/report/report.h b/lib/report/report.h
index 20fb6bd..a8e7405 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -44,11 +44,11 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int aligned, int buffered, int headings, int field_prefixes,
 		  int quoted, int columns_as_rows, const char *selection);
 void report_free(void *handle);
-int report_object(void *handle, struct volume_group *vg,
-		  struct logical_volume *lv, struct physical_volume *pv,
-		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
-		  struct label *label);
+int report_object(void *handle, const struct volume_group *vg,
+		  const struct logical_volume *lv, const struct physical_volume *pv,
+		  const struct lv_segment *seg, const struct pv_segment *pvseg,
+		  const struct lvinfo *lvinfo, const struct lv_seg_status *lv_seg_status,
+		  const struct label *label);
 int report_devtypes(void *handle);
 int report_output(void *handle);
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index f18fba9..48adf22 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1647,6 +1647,7 @@ struct dm_report_object_type {
 	uint32_t id;			/* Powers of 2 */
 	const char *desc;
 	const char *prefix;		/* field id string prefix (optional) */
+	/* FIXME: convert to proper usage of const pointers here */
 	void *(*data_fn)(void *object);	/* callback from report_object() */
 };
 
diff --git a/tools/reporter.c b/tools/reporter.c
index b312568..133ef39 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -39,7 +39,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_PROCESSED;
 }
 
-static void _choose_lv_segment_for_status_report(struct logical_volume *lv, struct lv_segment **lv_seg)
+static void _choose_lv_segment_for_status_report(const struct logical_volume *lv, const struct lv_segment **lv_seg)
 {
 	/*
 	 * By default, take the first LV segment to report status for.
@@ -51,58 +51,61 @@ static void _choose_lv_segment_for_status_report(struct logical_volume *lv, stru
 	*lv_seg = first_seg(lv);
 }
 
-static void _do_info_and_status(struct cmd_context *cmd,
-			       struct logical_volume *lv,
-			       struct lvinfo *lvinfo,
-			       struct lv_segment *lv_seg,
-			       struct lv_seg_status *lv_seg_status,
-			       int do_info, int do_status)
+static int _do_info_and_status(struct cmd_context *cmd,
+				const struct logical_volume *lv,
+				const struct lv_segment *lv_seg,
+				struct lv_with_info_and_seg_status *status,
+				int do_info, int do_status)
 {
-	if (lv_seg_status) {
-		lv_seg_status->mem = lv->vg->vgmem;
-		lv_seg_status->type = SEG_STATUS_NONE;
-		lv_seg_status->status = NULL;
-	}
+	status->seg_status.mem = NULL;
 
-	if (do_info && !do_status) {
-		/* info only */
-		if (!lv_info(cmd, lv, 0, lvinfo, 1, 1))
-			lvinfo->exists = 0;
-	} else if (!do_info && do_status) {
-		/* status only */
+	if (do_status) {
+		if (!(status->seg_status.mem = dm_pool_create("reporter_pool", 1024)))
+			return_0;
 		if (!lv_seg)
 			_choose_lv_segment_for_status_report(lv, &lv_seg);
-		if (!lv_status(cmd, lv_seg, lv_seg_status))
-			lvinfo->exists = 0;
-	} else if (do_info && do_status) {
-		/* both info and status */
-		if (!lv_seg)
-			_choose_lv_segment_for_status_report(lv, &lv_seg);
-		if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, lvinfo, lv_seg_status, 1, 1))
-			lvinfo->exists = 0;
+		if (do_info) {
+			/* both info and status */
+			if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 1, 1))
+				status->info.exists = 0;
+		} else {
+			/* status only */
+			if (!lv_status(cmd, lv_seg, &status->seg_status))
+				status->info.exists = 0;
+		}
+	} else if (do_info) {
+		/* info only */
+		if (!lv_info(cmd, lv, 0, &status->info, 1, 1))
+			status->info.exists = 0;
 	}
+
+	return 1;
 }
 
 static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
-					       struct logical_volume *lv,
+					       const struct logical_volume *lv,
 					       int do_info, int do_status,
 					       void *handle)
 {
-	struct lvinfo lvinfo;
-	struct lv_seg_status lv_seg_status;
+	struct lv_with_info_and_seg_status status;
 	int r = ECMD_FAILED;
 
-	_do_info_and_status(cmd, lv, &lvinfo, NULL, &lv_seg_status, do_info, do_status);
+	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status)) {
+		stack;
+		return r;
+	}
+
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL,
-			   do_info ? &lvinfo : NULL,
-			   do_status ? &lv_seg_status : NULL,
+			   do_info ? &status.info : NULL,
+			   do_status ? &status.seg_status : NULL,
 			   NULL))
-		goto out;
+		goto_out;
 
 	r = ECMD_PROCESSED;
 out:
-	if (lv_seg_status.status)
-		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
+	if (status.seg_status.mem)
+		dm_pool_destroy(status.seg_status.mem);
+
 	return r;
 }
 
@@ -131,25 +134,29 @@ static int _lvs_with_info_and_status_single(struct cmd_context *cmd, struct logi
 }
 
 static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
-						struct lv_segment *seg,
+						const struct lv_segment *seg,
 						int do_info, int do_status,
 						void *handle)
 {
-	struct lvinfo lvinfo;
-	struct lv_seg_status lv_seg_status;
+	struct lv_with_info_and_seg_status status;
 	int r = ECMD_FAILED;
 
-	_do_info_and_status(cmd, seg->lv, &lvinfo, seg, &lv_seg_status, do_info, do_status);
+	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status)) {
+		stack;
+		return r;
+	}
+
 	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
-			   do_info ? &lvinfo : NULL,
-			   do_status ? &lv_seg_status : NULL,
+			   do_info ? &status.info : NULL,
+			   do_status ? &status.seg_status : NULL,
 			   NULL))
-		goto out;
+		goto_out;
 
 	r = ECMD_PROCESSED;
 out:
-	if (lv_seg_status.status)
-		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
+	if (status.seg_status.mem)
+		dm_pool_destroy(status.seg_status.mem);
+
 	return r;
 }
 
@@ -222,9 +229,9 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
-	struct lvinfo lvinfo = { .exists = 0 };
-	struct lv_seg_status lv_seg_status = { .type = SEG_STATUS_NONE,
-					       .status = NULL };
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE
+	};
 
 	struct segment_type _freeseg_type = {
 		.name = "free",
@@ -260,18 +267,19 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	};
 
 	if (seg)
-		_do_info_and_status(cmd, seg->lv, &lvinfo, seg, &lv_seg_status, do_info, do_status);
+		_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, &lvinfo, &lv_seg_status,
+			   seg ? : &_free_lv_segment, pvseg, &status.info, &status.seg_status,
 			   pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
 
  out:
-	if (seg && lv_seg_status.status)
-		dm_pool_free(lv_seg_status.mem, lv_seg_status.status);
+	if (status.seg_status.mem)
+		dm_pool_destroy(status.seg_status.mem);
+
 	return ret;
 }
 


