From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:12:33 +0000 (UTC)
Subject: master - refactor: rename struct lv_with_info used in reporting code to lv_with_info_and_seg_status
Message-ID: <20141111121233.7F8C061276@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7e5f038887be820874522674a51071705439c8e
Commit:        d7e5f038887be820874522674a51071705439c8e
Parent:        20b22cd023bdfd30301305ba5b78655619d965f1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 20 13:46:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 08:53:28 2014 +0100

refactor: rename struct lv_with_info used in reporting code to lv_with_info_and_seg_status

The former struct lv_with_info is renamed to lv_with_info_and_seg_status as it can
hold more than just "info", there's lv's segment status now in addition:

	struct lv_with_info_and_seg_status {
		struct logical_volume *lv;
		struct lvinfo *info;
		struct lv_seg_status *seg_status;
	}

Where struct lv_seg_status is:

	struct lv_seg_status {
		struct dm_pool *mem;
		struct lv_segment lv_seg;
		lv_seg_status_type_t type;
		void *status; /* struct dm_status_* */
	}

Where lv_seg points to lv's segment that is being reported or
processed in general.

New struct lv_seg_status keeps the information about segment status -
the status retrieved via DM_DEVICE_STATUS ioctl. This information will
be used for reporting dm device target status for the LV segment
specified.

So this patch introduces third level of LV information that is
kept for reuse while reporting fields within one reporting line,
causing only one DM_DEVICE_STATUS ioctl call per LV segment line
reported (otherwise we'd need to call the DM_DEVICE_STATUS for each
segment status field in one LV segment/reporting line which is not
efficient).

This is following exactly the same principle as already introduced
by commit ecb2be5d1642aa0142d216f9e52f64fd3e8c3fc8.

So currently we have three levels of information that can be used
to report an LV/LV segment:

    - LV metadata itself (struct logical_volume *lv)

    - LV's DM_DEVICE_INFO ioctl result (struct lvinfo *info)

    - LV's segment DM_DEVICE_STATUS ioctl result (this status must be
      bound to a segment, not the whole LV as the whole LV may be
      composed of several segments of course)
      (this is the new struct lv_seg_status *seg_status)
---
 lib/activate/activate.h |   23 ++++++++++++++
 lib/report/report.c     |   76 ++++++++++++++++++++++------------------------
 lib/report/report.h     |    3 +-
 tools/reporter.c        |   23 ++++++++------
 4 files changed, 74 insertions(+), 51 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 9dfbcfa..ab5e69d 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -30,6 +30,29 @@ struct lvinfo {
 	uint32_t read_ahead;
 };
 
+typedef enum {
+	SEG_STATUS_NONE,
+	SEG_STATUS_CACHE,
+	SEG_STATUS_RAID,
+	SEG_STATUS_SNAPSHOT,
+	SEG_STATUS_THIN,
+	SEG_STATUS_THIN_POOL
+} lv_seg_status_type_t;
+
+struct lv_seg_status {
+	struct dm_pool *mem;			/* input */
+	struct lv_segment *seg;			/* input */
+	lv_seg_status_type_t type;		/* output */
+	void *status; /* struct dm_status_* */	/* output */
+};
+
+struct lv_with_info_and_seg_status {
+	struct logical_volume *lv;		/* input */
+	struct lvinfo *info;			/* output */
+	int seg_part_of_lv;			/* output */
+	struct lv_seg_status *seg_status;	/* input/output, see lv_seg_status */
+};
+
 struct lv_activate_opts {
 	int exclusive;
 	int origin_only;
diff --git a/lib/report/report.c b/lib/report/report.c
index e6df787..511d6cb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -27,14 +27,9 @@
 
 #include <stddef.h> /* offsetof() */
 
-struct lv_with_info {
-	struct logical_volume *lv;
-	struct lvinfo *info;
-};
-
 struct lvm_report_object {
 	struct volume_group *vg;
-	struct lv_with_info *lvi;
+	struct lv_with_info_and_seg_status *lvdm;
 	struct physical_volume *pv;
 	struct lv_segment *seg;
 	struct pv_segment *pvseg;
@@ -297,10 +292,10 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info && lvi->info->exists && lvi->info->major >= 0)
-		return dm_report_field_int(rh, field, &lvi->info->major);
+	if (lvdm->info && lvdm->info->exists && lvdm->info->major >= 0)
+		return dm_report_field_int(rh, field, &lvdm->info->major);
 
 	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 }
@@ -309,10 +304,10 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info && lvi->info->exists && lvi->info->minor >= 0)
-		return dm_report_field_int(rh, field, &lvi->info->minor);
+	if (lvdm->info && lvdm->info->exists && lvdm->info->minor >= 0)
+		return dm_report_field_int(rh, field, &lvdm->info->minor);
 
 	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 }
@@ -649,12 +644,12 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data,
 			      void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (!lvi->info || !lvi->info->exists)
+	if (!lvdm->info || !lvdm->info->exists)
 		return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 
-	return _size32_disp(rh, mem, field, &lvi->info->read_ahead, private);
+	return _size32_disp(rh, mem, field, &lvdm->info->read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1430,18 +1425,18 @@ static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 	const char *perms = "";
 
-	if (!lv_is_pvmove(lvi->lv)) {
-		if (lvi->lv->status & LVM_WRITE) {
-			if (!lvi->info->exists)
+	if (!lv_is_pvmove(lvdm->lv)) {
+		if (lvdm->lv->status & LVM_WRITE) {
+			if (!lvdm->info->exists)
 				perms = _str_unknown;
-			else if (lvi->info->read_only)
+			else if (lvdm->info->read_only)
 				perms = FIRST_NAME(lv_permissions_r_override);
 			else
 				perms = FIRST_NAME(lv_permissions_rw);
-		} else if (lvi->lv->status & LVM_READ)
+		} else if (lvdm->lv->status & LVM_READ)
 			perms = FIRST_NAME(lv_permissions_r);
 		else
 			perms = _str_unknown;
@@ -1602,10 +1597,10 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->suspended, FIRST_NAME(lv_suspended_y), private);
+	if (lvdm->info->exists)
+		return _binary_disp(rh, mem, field, lvdm->info->suspended, FIRST_NAME(lv_suspended_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1614,10 +1609,10 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->live_table, FIRST_NAME(lv_live_table_y), private);
+	if (lvdm->info->exists)
+		return _binary_disp(rh, mem, field, lvdm->info->live_table, FIRST_NAME(lv_live_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1626,10 +1621,10 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 				 struct dm_report_field *field,
 				 const void *data, void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->inactive_table, FIRST_NAME(lv_inactive_table_y), private);
+	if (lvdm->info->exists)
+		return _binary_disp(rh, mem, field, lvdm->info->inactive_table, FIRST_NAME(lv_inactive_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1638,10 +1633,10 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
 {
-	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->open_count, FIRST_NAME(lv_device_open_y), private);
+	if (lvdm->info->exists)
+		return _binary_disp(rh, mem, field, lvdm->info->open_count, FIRST_NAME(lv_device_open_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1717,12 +1712,12 @@ static void *_obj_get_vg(void *obj)
 
 static void *_obj_get_lv(void *obj)
 {
-	return ((struct lvm_report_object *)obj)->lvi->lv;
+	return ((struct lvm_report_object *)obj)->lvdm->lv;
 }
 
-static void *_obj_get_lv_with_info(void *obj)
+static void *_obj_get_lv_with_info_and_seg_status(void *obj)
 {
-	return ((struct lvm_report_object *)obj)->lvi;
+	return ((struct lvm_report_object *)obj)->lvdm;
 }
 
 static void *_obj_get_pv(void *obj)
@@ -1753,7 +1748,7 @@ static void *_obj_get_devtypes(void *obj)
 static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
-	{ LVSINFO, "Logical Volume Device", "lv_", _obj_get_lv_with_info },
+	{ LVSINFO, "Logical Volume Device Info", "lv_", _obj_get_lv_with_info_and_seg_status },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
 	{ LABEL, "Physical Volume Label", "pv_", _obj_get_label },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
@@ -1851,14 +1846,15 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct lvinfo *lvinfo, struct label *label)
+		  struct lvinfo *lvinfo,  struct lv_seg_status *lv_seg_status,
+		  struct label *label)
 {
 	struct device dummy_device = { .dev = 0 };
 	struct label dummy_label = { .dev = &dummy_device };
-	struct lv_with_info lvi = { .lv = lv, .info = lvinfo };
+	struct lv_with_info_and_seg_status lvdm = { .lv = lv, .info = lvinfo, .seg_status = lv_seg_status};
 	struct lvm_report_object obj = {
 		.vg = vg,
-		.lvi = &lvi,
+		.lvdm = &lvdm,
 		.pv = pv,
 		.seg = seg,
 		.pvseg = pvseg,
diff --git a/lib/report/report.h b/lib/report/report.h
index 089fc15..e4b302e 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -45,7 +45,8 @@ void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg,
-		  struct lvinfo *lvinfo, struct label *label);
+		  struct lvinfo *lvinfo, struct lv_seg_status *lv_seg_status,
+		  struct label *label);
 int report_devtypes(void *handle);
 int report_output(void *handle);
 
diff --git a/tools/reporter.c b/tools/reporter.c
index b49f37d..959e884 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -31,7 +31,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -42,7 +42,7 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -62,7 +62,7 @@ static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume
 	struct lvinfo lvinfo;
 
 	_get_lv_info_for_report(cmd, lv, &lvinfo);
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL, &lvinfo, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -71,7 +71,7 @@ static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume
 static int _segs_single(struct cmd_context *cmd __attribute__((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -83,7 +83,7 @@ static int _segs_with_lv_info_single(struct cmd_context *cmd __attribute__((unus
 	struct lvinfo lvinfo;
 
 	_get_lv_info_for_report(cmd, seg->lv, &lvinfo);
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL, &lvinfo, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -93,11 +93,13 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 				 struct volume_group *vg,
 				 struct pv_segment *pvseg,
 				 int lv_info_needed,
+				 int lv_seg_status_needed,
 				 void *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 	struct lvinfo lvinfo = { .exists = 0 };
+	struct lv_seg_status lv_seg_status;
 
 	struct segment_type _freeseg_type = {
 		.name = "free",
@@ -136,7 +138,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	    _get_lv_info_for_report(cmd, seg->lv, &lvinfo);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, &lvinfo, pv_label(pvseg->pv))) {
+			   seg ? : &_free_lv_segment, pvseg, &lvinfo, &lv_seg_status,
+			   pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -149,7 +152,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct pv_segment *pvseg, void *handle)
 {
-	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, handle);
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, 0, handle);
 }
 
 static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
@@ -157,7 +160,7 @@ static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
 					   struct pv_segment *pvseg,
 					   void *handle)
 {
-	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, handle);
+	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, 0, handle);
 }
 
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -198,7 +201,7 @@ static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -207,7 +210,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 static int _label_single(struct cmd_context *cmd, struct label *label,
 		         void *handle)
 {
-	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
+	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


