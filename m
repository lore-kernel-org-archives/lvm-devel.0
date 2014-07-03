From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  3 Jul 2014 22:51:25 +0000 (UTC)
Subject: master - report: Add lv_parent field.
Message-ID: <20140703225126.00D0C60FF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=137ed3081adca8ecec933bd5f5e34c1fa3e2ffef
Commit:        137ed3081adca8ecec933bd5f5e34c1fa3e2ffef
Parent:        1e1c2769a7092959e5c0076767b4973d4e4dc37c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 3 23:49:34 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 3 23:49:34 2014 +0100

report: Add lv_parent field.

Only defined for thin/cache/raid/mirror at this stage as it
relies on get_only_segment_using_this_lv().
---
 WHATS_NEW               |    2 +-
 lib/metadata/lv.c       |   18 ++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/metadata/lv_manip.c |    2 +-
 lib/metadata/metadata.h |    2 +-
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   13 +++++++++++++
 8 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 96c4c65..5a1e214 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
 Version 2.02.108 -
 =================================
   Fix VG component of lvid in vgsplit/vgmerge and check in vg_validate.
-  Add lv_full_name and lv_dm_path fields to reports.
+  Add lv_full_name, lv_parent and lv_dm_path fields to reports.
   Change lv_path field to suppress devices that never appear in /dev/vg.
   Postpone thin pool lvconvert prompts (2.02.107).
   Require --yes option to skip prompt to lvconvert thin pool chunksize.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c38cbe3..18066f0 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -231,6 +231,24 @@ char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv)
         return dm_pool_strdup(mem, lvfullname);
 }
 
+char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	const char *parent = "";
+
+	if (lv_is_visible(lv))
+		;
+	else if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
+		parent = get_only_segment_using_this_lv(lv)->lv->name;
+	else if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
+		parent = get_only_segment_using_this_lv(lv)->lv->name;
+	else if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv))
+		parent = get_only_segment_using_this_lv(lv)->lv->name;
+	else if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))
+		parent = get_only_segment_using_this_lv(lv)->lv->name;
+
+	return dm_pool_strdup(mem, parent);
+}
+
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct dm_list *modules;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 86db501..47ade92 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -73,6 +73,7 @@ char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 uint64_t lvseg_start(const struct lv_segment *seg);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 537ec30..306a34b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -342,7 +342,7 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv,
  *
  * In general, walk through lv->segs_using_this_lv.
  */
-struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv)
+struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *lv)
 {
 	struct seg_list *sl;
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 4c5ad33..518dd21 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -428,7 +428,7 @@ int lv_split_segment(struct logical_volume *lv, uint32_t le);
  */
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
-struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
+struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *lv);
 
 int for_each_sub_lv(struct logical_volume *lv,
                     int (*fn)(struct logical_volume *lv, void *data),
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 418e67a..8d42387 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -33,6 +33,7 @@ FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for inte
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV including its VG, namely VG/LV.", 0)
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
+FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 9692de8..d6f14f1 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -170,6 +170,8 @@ GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_dm_path, lv_dmpath_dup(lv->vg->vgmem, lv))
 #define _lv_dm_path_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_parent, lv_parent_dup(lv->vg->vgmem, lv))
+#define _lv_parent_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 #define _lv_attr_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
diff --git a/lib/report/report.c b/lib/report/report.c
index fca1133..3b71989 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -324,6 +324,19 @@ static int _lvfullname_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
+static int _lvparent_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+
+	if (!(repstr = lv_parent_dup(mem, lv)))
+		return_0;
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))


