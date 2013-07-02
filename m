From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:13 +0000 (UTC)
Subject: master - report: add vg_profile and lv_profile to report the profile attached to VG/LV
Message-ID: <20130702133313.0FF9E603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f6cfc9de497944b60a0b52e77ff532c489bce63
Commit:        9f6cfc9de497944b60a0b52e77ff532c489bce63
Parent:        21554ab5fe958b09eed853f3bfefa61c4c130604
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 2 14:34:52 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:12 2013 +0200

report: add vg_profile and lv_profile to report the profile attached to VG/LV

vgs -o vg_profile ...
lvs -o lv_profile ...
---
 lib/config/defaults.h   |    4 ++--
 lib/metadata/lv.c       |    6 ++++++
 lib/metadata/lv.h       |    1 +
 lib/metadata/vg.c       |    6 ++++++
 lib/metadata/vg.h       |    1 +
 lib/report/columns.h    |    2 ++
 lib/report/properties.c |    4 ++++
 lib/report/report.c     |   26 ++++++++++++++++++++++++++
 8 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index b8d46f1..7ee89ec 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -163,8 +163,8 @@
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
-#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
-#define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
+#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
+#define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
 #define DEFAULT_PVSEGS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 93ae92d..475a514 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -785,6 +785,12 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, s);
 }
 
+char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	const char *profile_name = lv->profile ? lv->profile->name : "";
+	return dm_pool_strdup(mem, profile_name);
+}
+
 /* For given LV find recursively the LV which holds lock for it */
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 6831f67..06f8c60 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -93,4 +93,5 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 struct logical_volume *lv_ondisk(struct logical_volume *lv);
 struct profile *lv_config_profile(const struct logical_volume *lv);
+char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 #endif /* _LVM_LV_H */
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 50e8328..22099e2 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -267,6 +267,12 @@ int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
 	return 1;
 }
 
+char *vg_profile_dup(const struct volume_group *vg)
+{
+	const char *profile_name = vg->profile ? vg->profile->name : "";
+	return dm_pool_strdup(vg->vgmem, profile_name);
+}
+
 static int _recalc_extents(uint32_t *extents, const char *desc1,
 			   const char *desc2, uint32_t old_size,
 			   uint32_t new_size)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index f33fe11..8db04d3 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -155,6 +155,7 @@ uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
+char *vg_profile_dup(const struct volume_group *vg);
 
 /*
  * Returns visible LV count - number of LVs from user perspective
diff --git a/lib/report/columns.h b/lib/report/columns.h
index c55a685..d13d19a 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -96,6 +96,7 @@ FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
+FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV", 0)
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
@@ -139,6 +140,7 @@ FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number o
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
+FIELD(VGS, vg, STR, "VProfile", cmd, 8, vgprofile, vg_profile, "Configuration profile attached to this VG", 0)
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 884df2a..ad23e7c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -261,6 +261,8 @@ GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
 #define _lv_host_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
 #define _lv_active_set _not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_profile, lv_profile_dup(lv->vg->vgmem, lv))
+#define _lv_profile_set _not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
@@ -307,6 +309,8 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
 #define _vg_mda_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
+GET_VG_STR_PROPERTY_FN(vg_profile, vg_profile_dup(vg))
+#define _vg_profile_set _not_implemented_set
 
 /* LVSEG */
 GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg))
diff --git a/lib/report/report.c b/lib/report/report.c
index 8ff4f28..8b5455b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -111,6 +111,19 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 	return 1;
 }
 
+static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv->profile)
+		return dm_report_field_string(rh, field, &lv->profile->name);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
@@ -760,6 +773,19 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
+static int _vgprofile_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+
+	if (vg->profile)
+		return dm_report_field_string(rh, field, &vg->profile->name);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
 static int _pvmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)


