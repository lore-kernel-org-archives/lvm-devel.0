From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 1 Mar 2017 12:59:24 -0500
Subject: master - lvconvert: add new reporting fields for reshaping
Message-ID: <201703011759.v21HxOFO000770@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48778bc5038f0384bf0e6ad43bac048f6700637b
Commit:        48778bc5038f0384bf0e6ad43bac048f6700637b
Parent:        62abae1525cec51279c39c5127afaced8f0463e2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 1 18:50:35 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 1 18:50:35 2017 +0100

lvconvert: add new reporting fields for reshaping

During an ongoing reshape, the MD kernel runtime reads stripes relative
to data_offset and starts storing the reshaped stripes (with new raid
layout and/or new stripesize  and/or new number of stripes) relative
to new_data_offset.  This is to avoid writing over any data in place
which is non-atomic by nature and thus be recoverable without data loss
in the transition.  MD uses the term out-of-place reshaping for it.

There's 2 other areas we don't have report capability for:
- number of data stripes vs. total stripes
  (e.g. raid6 with 7 stripes toal has 5 data stripes)
- number of (rotating) parity/syndrome chunks
  (e.g. raid6 with 7 stripes toal has 2 parity chunks; one
   per stripe for P-Syndrome and another one for Q-Syndrome)

Thus, add the following reportable keys:

- reshape_len      (in current units)
- reshape_len_le   (in logical extents)
- data_offset      (in sectors)
- new_data_offset  (     "    )
- data_stripes
- parity_chunks

Enhance lvchange-raid.sh, lvconvert-raid-reshape-linear_to_striped.sh,
lvconvert-raid-reshape-striped_to_linear.sh, lvconvert-raid-reshape.sh
and lvconvert-raid-takeover.sh to make use of new keys.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/report/columns.h                               |    9 +-
 lib/report/properties.c                            |   17 ++-
 lib/report/report.c                                |  173 ++++++++++++++++++++
 test/shell/lvchange-raid.sh                        |    2 +-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    4 +
 .../lvconvert-raid-reshape-striped_to_linear.sh    |   24 +++-
 test/shell/lvconvert-raid-reshape.sh               |   90 ++++++-----
 test/shell/lvconvert-raid-takeover.sh              |  167 ++++++++++---------
 8 files changed, 359 insertions(+), 127 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6d9b851..0452641 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -241,7 +241,14 @@ FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 0, vgmdacopies, vg_mda_copies, "Target numb
  * SEGS type fields
  */
 FIELD(SEGS, seg, STR, "Type", list, 0, segtype, segtype, "Type of LV segment.", 0)
-FIELD(SEGS, seg, NUM, "#Str", area_count, 0, uint32, stripes, "Number of stripes or mirror legs.", 0)
+FIELD(SEGS, seg, NUM, "#Str", list, 0, seg_stripes, stripes, "Number of data stripes or mirror/raid1 legs.", 0)
+FIELD(SEGS, seg, NUM, "#DStr", list, 0, seg_data_stripes, data_stripes, "Number of data stripes or mirror/raid1 legs.", 0)
+FIELD(SEGS, seg, NUM, "RSize", list, 0, seg_reshape_len, reshape_len, "Size of out-of-place reshape space in current units.", 0)
+FIELD(SEGS, seg, SIZ, "RSize", list, 0, seg_reshape_len_le, reshape_len_le, "Size of out-of-place reshape space in physical extents.", 0)
+FIELD(SEGS, seg, NUM, "#Cpy", list, 0, seg_data_copies, data_copies, "Number of data copies.", 0)
+FIELD(SEGS, seg, NUM, "DOff", list, 0, seg_data_offset, data_offset, "Data offset on each image device.", 0)
+FIELD(SEGS, seg, NUM, "NOff", list, 0, seg_new_data_offset, new_data_offset, "New data offset after any reshape on each image device.", 0)
+FIELD(SEGS, seg, NUM, "#Par", list, 0, seg_parity_chunks, parity_chunks, "Number of (rotating) parity chunks.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 0, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
 FIELD(SEGS, seg, SIZ, "Region", region_size, 0, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
 FIELD(SEGS, seg, SIZ, "Chunk", list, 0, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 3b27bdc..5264eb1 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,6 +16,7 @@
 #include "properties.h"
 #include "activate.h"
 #include "metadata.h"
+#include "segtype.h"
 
 
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
@@ -446,8 +447,22 @@ GET_VG_NUM_PROPERTY_FN(vg_missing_pv_count, vg_missing_pv_count(vg))
 /* LVSEG */
 GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _segtype_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(data_copies, lvseg->data_copies)
+#define _data_copies_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(reshape_len, lvseg->reshape_len)
+#define _reshape_len_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(reshape_len_le, lvseg->reshape_len)
+#define _reshape_len_le_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(data_offset, lvseg->data_offset)
+#define _data_offset_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(new_data_offset, lvseg->data_offset)
+#define _new_data_offset_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(parity_chunks, lvseg->data_offset)
+#define _parity_chunks_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
 #define _stripes_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(data_stripes, lvseg->area_count - lvseg->segtype->parity_devs)
+#define _data_stripes_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripe_size, (SECTOR_SIZE * lvseg->stripe_size))
 #define _stripe_size_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(region_size, (SECTOR_SIZE * lvseg->region_size))
diff --git a/lib/report/report.c b/lib/report/report.c
index 702befb..5142f72 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2412,6 +2412,179 @@ static int _segstartpe_disp(struct dm_report *rh,
 	return dm_report_field_uint32(rh, field, &seg->le);
 }
 
+static int _get_seg_used_stripes(const struct lv_segment *seg)
+{
+	uint32_t s;
+	uint32_t stripes = seg->area_count;
+
+	for (s = seg->area_count - 1; stripes && s; s--) {
+		if (seg_type(seg, s) == AREA_LV &&
+		    seg_lv(seg, s)->status & LV_REMOVE_AFTER_RESHAPE)
+			stripes--;
+		else
+			break;
+	}
+
+	return stripes;
+}
+
+static int _seg_stripes_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	const struct lv_segment *seg = ((const struct lv_segment *) data);
+
+	return dm_report_field_uint32(rh, field, &seg->area_count);
+}
+
+static int _seg_data_stripes_disp(struct dm_report *rh, struct dm_pool *mem,
+				  struct dm_report_field *field,
+				  const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t stripes = _get_seg_used_stripes(seg) - seg->segtype->parity_devs;
+
+	/* FIXME: in case of odd numbers of raid10 stripes */
+	if (seg_is_raid10(seg))
+		stripes /= seg->data_copies;
+
+	return dm_report_field_uint32(rh, field, &stripes);
+}
+
+static int _seg_reshape_len_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t reshape_len = seg->reshape_len;
+
+	if (reshape_len && seg->lv) {
+		reshape_len *= seg->area_count * seg->lv->vg->extent_size;
+
+		return _size32_disp(rh, mem, field, &reshape_len, private);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+}
+
+static int _seg_reshape_len_le_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t reshape_len = seg->reshape_len;
+
+	if (reshape_len) {
+		reshape_len *= seg->area_count;
+
+		return dm_report_field_uint32(rh, field, &reshape_len);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+}
+
+static int _seg_data_copies_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg->data_copies > 1)
+		return dm_report_field_uint32(rh, field, &seg->data_copies);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+}
+
+static int _segdata_offset(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private, int new_data_offset)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const char *what = "";
+
+	if (lv_is_raid_image(seg->lv) &&
+	    !seg->le &&
+	    (seg->reshape_len || !new_data_offset)) {
+		struct lv_list *lvl;
+		char *lv_name;
+
+		if ((lv_name = strdup(seg->lv->name))) {
+			char *p = strchr(lv_name, '_');
+
+			if (p) {
+				/* Handle duplicated sub LVs */
+				if (strstr(p, "_dup_"))
+					p = strchr(p + 5, '_');
+
+				if (p) {
+					*p = '\0';
+					if ((lvl = find_lv_in_vg(seg->lv->vg, lv_name))) {
+						if (seg_is_reshapable_raid(first_seg(lvl->lv))) {
+							uint64_t data_offset;
+
+							if (lv_raid_data_offset(lvl->lv, &data_offset)) {
+								if (new_data_offset && !lv_raid_image_in_sync(seg->lv))
+									data_offset = data_offset ? 0 :
+										      seg->reshape_len * seg->lv->vg->extent_size;
+
+								return dm_report_field_uint64(rh, field, &data_offset);
+							}
+
+							what = _str_unknown;
+						}
+					}
+				}
+			}
+		}
+
+	}
+
+	return _field_set_value(field, what, &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _seg_data_offset_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	return _segdata_offset(rh, mem, field, data, private, 0);
+}
+
+static int _seg_new_data_offset_disp(struct dm_report *rh, struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data, void *private)
+{
+	return _segdata_offset(rh, mem, field, data, private, 1);
+}
+
+static int _seg_parity_chunks_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	uint32_t parity_chunks = seg->segtype->parity_devs ?: seg->data_copies - 1;
+
+	if (parity_chunks) {
+		uint32_t s, resilient_sub_lvs = 0;
+
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) == AREA_LV) {
+				struct lv_segment *seg1 = first_seg(seg_lv(seg, s));
+
+				if (seg1->segtype->parity_devs ||
+				    seg1->data_copies > 1)
+					resilient_sub_lvs++;
+			}
+		}
+
+		if (resilient_sub_lvs && resilient_sub_lvs == seg->area_count)
+			parity_chunks++;
+
+		return dm_report_field_uint32(rh, field, &parity_chunks);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_32));
+}
+
 static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 4bc8855..f81cc53 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -188,7 +188,7 @@ run_syncaction_check() {
 	# 'lvs' should show results
 	lvchange --syncaction check $vg/$lv
 	aux wait_for_sync $vg $lv
-	check lv_attr_bit health $vg/$lv "-"
+	check lv_attr_bit health $vg/$lv "-" || check lv_attr_bit health $vg/$lv "m"
 	check lv_field $vg/$lv raid_mismatch_count "0"
 }
 
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 3b6120c..5a266ee 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -27,6 +27,7 @@ aux prepare_vg 5
 lvcreate -aey -L 16M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "linear"
 check lv_field $vg/$lv1 stripes 1
+check lv_field $vg/$lv1 data_stripes 1
 echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -35,6 +36,7 @@ lvconvert -y -m 1 $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 2
+check lv_field $vg/$lv1 data_stripes 2
 check lv_field $vg/$lv1 regionsize "512.00k"
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
@@ -44,6 +46,7 @@ lvconvert -y --ty raid5_n $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 stripes 2
+check lv_field $vg/$lv1 data_stripes 1
 check lv_field $vg/$lv1 stripesize "64.00k"
 check lv_field $vg/$lv1 regionsize "512.00k"
 
@@ -51,6 +54,7 @@ check lv_field $vg/$lv1 regionsize "512.00k"
 lvconvert -y --stripes 4 $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 data_stripes 4
 check lv_first_seg_field $vg/$lv1 stripes 5
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "512.00k"
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index fc87caf..dd857c1 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -26,8 +26,10 @@ aux prepare_vg 5
 # Create 4-way striped  LV
 lvcreate -aey -i 4 -I 32k -L 16M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "striped"
+check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 stripesize "32.00k"
+check lv_field $vg/$lv1 reshape_len "" 
 echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -35,14 +37,22 @@ fsck -fn $DM_DEV_DIR/$vg/$lv1
 lvconvert -y --ty raid5 -R 128k $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 5
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
+check lv_field $vg/$lv1 reshape_len ""
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Extend raid5_n LV by factor 4 to keep size once linear
 lvresize -y -L 64 $vg/$lv1
+check lv_field $vg/$lv1 segtype "raid5_n"
+check lv_field $vg/$lv1 data_stripes 4
+check lv_field $vg/$lv1 stripes 5
+check lv_field $vg/$lv1 stripesize "32.00k"
+check lv_field $vg/$lv1 regionsize "128.00k"
+check lv_field $vg/$lv1 reshape_len ""
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -52,33 +62,45 @@ fsck -fn $DM_DEV_DIR/$vg/$lv1
 lvconvert -y -f --ty raid5_n --stripes 1 -I 64k -R 1024k $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 5
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+check lv_first_seg_field $vg/$lv1 reshape_len 10
+# for slv in {0..4}
+# do
+#	check lv_first_seg_field $vg/${lv1}_rimage_${slv} reshape_len 2
+# done
 aux wait_for_sync $vg $lv1 1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Remove the now freed legs
 lvconvert --stripes 1 $vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
+check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+check lv_first_seg_field $vg/$lv1 reshape_len 4
 
 # Convert raid5_n to raid1
 lvconvert -y --type raid1 $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid1"
+check lv_first_seg_field $vg/$lv1 data_stripes 2
 check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
+check lv_first_seg_field $vg/$lv1 reshape_len ""
 
-# Convert raid5_n -> striped
+# Convert raid5_n -> linear
 lvconvert -y --type linear $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "linear"
+check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 1
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "0"
+check lv_first_seg_field $vg/$lv1 reshape_len ""
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 2c302dd..6764d30 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -17,7 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 which mkfs.ext4 || skip
 aux have_raid 1 10 2 || skip
 
-aux prepare_vg 64
+aux prepare_pvs 65 64
+
+vgcreate -s 1M $vg $(cat DEVICES)
 
 function _lvcreate
 {
@@ -30,6 +32,7 @@ function _lvcreate
 
 	lvcreate -y -aey --type $level -i $req_stripes -L $size -n $lv $vg
 	check lv_first_seg_field $vg/$lv segtype "$level"
+	check lv_first_seg_field $vg/$lv datastripes $req_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes
 	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
@@ -39,10 +42,11 @@ function _lvconvert
 {
 	local req_level=$1
 	local level=$2
-	local stripes=$3
-	local vg=$4
-	local lv=$5
-	local region_size=$6
+	local data_stripes=$3
+	local stripes=$4
+	local vg=$5
+	local lv=$6
+	local region_size=$7
 	local wait_and_check=1
 	local R=""
 
@@ -53,6 +57,7 @@ function _lvconvert
 	lvconvert -y --ty $req_level $R $vg/$lv
 	[ $? -ne 0 ] && return $?
 	check lv_first_seg_field $vg/$lv segtype "$level"
+	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes
 	[ -n "$region_size" ] && check lv_field $vg/$lv regionsize $region_size
 	if [ "$wait_and_check" -eq 1 ]
@@ -67,6 +72,8 @@ function _reshape_layout
 {
 	local type=$1
 	shift
+	local data_stripes=$1
+	shift
 	local stripes=$1
 	shift
 	local vg=$1
@@ -80,6 +87,7 @@ function _reshape_layout
 
 	lvconvert -vvvv -y --ty $type $opts $vg/$lv
 	check lv_first_seg_field $vg/$lv segtype "$type"
+	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes
 	aux wait_for_sync $vg $lv $ignore_a_chars
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
@@ -99,101 +107,101 @@ check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 aux wait_for_sync $vg $lv1
 
 # Reshape it to 256K stripe size
-_reshape_layout raid5_ls 4 $vg $lv1 --stripesize 256K
+_reshape_layout raid5_ls 3 4 $vg $lv1 --stripesize 256K
 check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
 
 # Convert raid5(_n) -> striped
-not _lvconvert striped striped 3 $vg $lv1 512k
-_reshape_layout raid5_n 4 $vg $lv1
-_lvconvert striped striped 3 $vg $lv1
+not _lvconvert striped striped 3 3 $vg $lv1 512k
+_reshape_layout raid5_n 3 4 $vg $lv1
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid5_n
-_lvconvert raid5_n raid5_n 4 $vg $lv1 "" 1
+_lvconvert raid5_n raid5_n 3 4 $vg $lv1 "" 1
 
 # Convert raid5_n -> raid5_ls
-_reshape_layout raid5_ls 4 $vg $lv1
+_reshape_layout raid5_ls 3 4 $vg $lv1
 
 # Convert raid5_ls to 5 stripes
-_reshape_layout raid5_ls 6 $vg $lv1 --stripes 5
+_reshape_layout raid5_ls 5 6 $vg $lv1 --stripes 5
 
 # Convert raid5_ls back to 3 stripes
-_reshape_layout raid5_ls 6 $vg $lv1 --stripes 3 --force
-_reshape_layout raid5_ls 4 $vg $lv1 --stripes 3
+_reshape_layout raid5_ls 3 6 $vg $lv1 --stripes 3 --force
+_reshape_layout raid5_ls 3 4 $vg $lv1 --stripes 3
 
 # Convert raid5_ls to 7 stripes
-_reshape_layout raid5_ls 8 $vg $lv1 --stripes 7
+_reshape_layout raid5_ls 7 8 $vg $lv1 --stripes 7
 
 # Convert raid5_ls to 9 stripes
-_reshape_layout raid5_ls 10 $vg $lv1 --stripes 9
+_reshape_layout raid5_ls 9 10 $vg $lv1 --stripes 9
 
 # Convert raid5_ls to 14 stripes
-_reshape_layout raid5_ls 15 $vg $lv1 --stripes 14
+_reshape_layout raid5_ls 14 15 $vg $lv1 --stripes 14
 
 # Convert raid5_ls to 63 stripes
-_reshape_layout raid5_ls 64 $vg $lv1 --stripes 63
+_reshape_layout raid5_ls 63 64 $vg $lv1 --stripes 63
 
 # Convert raid5_ls back to 27 stripes
-_reshape_layout raid5_ls 64 $vg $lv1 --stripes 27 --force
-_reshape_layout raid5_ls 28 $vg $lv1 --stripes 27
+_reshape_layout raid5_ls 27 64 $vg $lv1 --stripes 27 --force
+_reshape_layout raid5_ls 27 28 $vg $lv1 --stripes 27
 
 # Convert raid5_ls back to 4 stripes
-_reshape_layout raid5_ls 28 $vg $lv1 --stripes 4 --force
-_reshape_layout raid5_ls 5 $vg $lv1 --stripes 4
+_reshape_layout raid5_ls 4 28 $vg $lv1 --stripes 4 --force
+_reshape_layout raid5_ls 4 5 $vg $lv1 --stripes 4
 
 # Convert raid5_ls back to 3 stripes
-_reshape_layout raid5_ls 5 $vg $lv1 --stripes 3 --force
-_reshape_layout raid5_ls 4 $vg $lv1 --stripes 3
+_reshape_layout raid5_ls 3 5 $vg $lv1 --stripes 3 --force
+_reshape_layout raid5_ls 3 4 $vg $lv1 --stripes 3
 
 # Convert raid5_ls -> raid5_rs
-_reshape_layout raid5_rs 4 $vg $lv1
+_reshape_layout raid5_rs 3 4 $vg $lv1
 
 # Convert raid5_rs -> raid5_la
-_reshape_layout raid5_la 4 $vg $lv1
+_reshape_layout raid5_la 3 4 $vg $lv1
 
 # Convert raid5_la -> raid5_ra
-_reshape_layout raid5_ra 4 $vg $lv1
+_reshape_layout raid5_ra 3 4 $vg $lv1
 
 # Convert raid5_ra -> raid6_ra_6
-_lvconvert raid6_ra_6 raid6_ra_6 5 $vg $lv1 "4.00m" 1
+_lvconvert raid6_ra_6 raid6_ra_6 3 5 $vg $lv1 "4.00m" 1
 
 # Convert raid5_la -> raid6(_zr)
-_reshape_layout raid6 5 $vg $lv1
+_reshape_layout raid6 3 5 $vg $lv1
 
 # Convert raid6(_zr) -> raid6_nc
-_reshape_layout raid6_nc 5 $vg $lv1
+_reshape_layout raid6_nc 3 5 $vg $lv1
 
 # Convert raid6(_nc) -> raid6_nr
-_reshape_layout raid6_nr 5 $vg $lv1
+_reshape_layout raid6_nr 3 5 $vg $lv1
 
 # Convert raid6_nr) -> raid6_rs_6
-_reshape_layout raid6_rs_6 5 $vg $lv1
+_reshape_layout raid6_rs_6 3 5 $vg $lv1
 
 # Convert raid6_rs_6 to 5 stripes
-_reshape_layout raid6_rs_6 7 $vg $lv1 --stripes 5
+_reshape_layout raid6_rs_6 5 7 $vg $lv1 --stripes 5
 
 # Convert raid6_rs_6 to 4 stripes
-_reshape_layout raid6_rs_6 7 $vg $lv1 --stripes 4 --force
-_reshape_layout raid6_rs_6 6 $vg $lv1 --stripes 4
+_reshape_layout raid6_rs_6 4 7 $vg $lv1 --stripes 4 --force
+_reshape_layout raid6_rs_6 4 6 $vg $lv1 --stripes 4
 check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
 
 # Convert raid6_rs_6 to raid6_n_6
-_reshape_layout raid6_n_6 6 $vg $lv1
+_reshape_layout raid6_n_6 4 6 $vg $lv1
 
 # Convert raid6_n_6 -> striped
-_lvconvert striped striped 4 $vg $lv1
+_lvconvert striped striped 4 4 $vg $lv1
 check lv_first_seg_field $vg/$lv1 stripesize "256.00k"
 
 # Convert striped -> raid10(_near)
-_lvconvert raid10 raid10 8 $vg $lv1
+_lvconvert raid10 raid10 4 8 $vg $lv1
 
 # Convert raid10 to 10 stripes and 64K stripesize
 # FIXME: change once we support odd numbers of raid10 stripes
-not _reshape_layout raid10 9 $vg $lv1 --stripes 9 --stripesize 64K
-_reshape_layout raid10 10 $vg $lv1 --stripes 10 --stripesize 64K
+not _reshape_layout raid10 4 9 $vg $lv1 --stripes 9 --stripesize 64K
+_reshape_layout raid10 5 10 $vg $lv1 --stripes 10 --stripesize 64K
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 
 # Convert raid6_n_6 -> striped
-_lvconvert striped striped 5 $vg $lv1
+_lvconvert striped striped 5 5 $vg $lv1
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 5d8f858..2ce6367 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -33,6 +33,7 @@ function _lvcreate
 
 	lvcreate -y -aey --type $level -i $req_stripes -L $size -n $lv $vg
 	check lv_field $vg/$lv segtype "$level"
+	check lv_field $vg/$lv data_stripes $req_stripes
 	check lv_field $vg/$lv stripes $stripes
 	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
@@ -42,10 +43,11 @@ function _lvconvert
 {
 	local req_level=$1
 	local level=$2
-	local stripes=$3
-	local vg=$4
-	local lv=$5
-	local region_size=$6
+	local data_stripes=$3
+	local stripes=$4
+	local vg=$5
+	local lv=$6
+	local region_size=$7
 	local wait_and_check=1
 	local R=""
 
@@ -56,6 +58,7 @@ function _lvconvert
 	lvconvert -y --ty $req_level $R $vg/$lv
 	[ $? -ne 0 ] && return $?
 	check lv_field $vg/$lv segtype "$level"
+	check lv_field $vg/$lv data_stripes $data_stripes
 	check lv_field $vg/$lv stripes $stripes
 	if [ "$wait_and_check" -eq 1 ]
 	then
@@ -70,19 +73,19 @@ function _invalid_raid5_conversions
 	local vg=$1
 	local lv=$2
 
-	not _lvconvert striped 4 $vg $lv1
-	not _lvconvert raid0 raid0 4 $vg $lv1
-	not _lvconvert raid0_meta raid0_meta 4 $vg $lv1
-	not _lvconvert raid4 raid4 5 $vg $lv1
-	not _lvconvert raid5_ls raid5_ls 5 $vg $lv1
-	not _lvconvert raid5_rs raid5_rs 5 $vg $lv1
-	not _lvconvert raid5_la raid5_la 5 $vg $lv1
-	not _lvconvert raid5_ra raid5_ra 5 $vg $lv1
-	not _lvconvert raid6_zr raid6_zr 6 $vg $lv1
-	not _lvconvert raid6_nr raid6_nr 6 $vg $lv1
-	not _lvconvert raid6_nc raid6_nc 6 $vg $lv1
-	not _lvconvert raid6_n_6 raid6_n_6 6 $vg $lv1
-	not _lvconvert raid6 raid6_n_6 6 $vg $lv1
+	not _lvconvert striped 4 4 $vg $lv1
+	not _lvconvert raid0 raid0 4 4 $vg $lv1
+	not _lvconvert raid0_meta raid0_meta 4 4 $vg $lv1
+	not _lvconvert raid4 raid4 4 5 $vg $lv1
+	not _lvconvert raid5_ls raid5_ls 4 5 $vg $lv1
+	not _lvconvert raid5_rs raid5_rs 4 5 $vg $lv1
+	not _lvconvert raid5_la raid5_la 4 5 $vg $lv1
+	not _lvconvert raid5_ra raid5_ra 4 5 $vg $lv1
+	not _lvconvert raid6_zr raid6_zr 4 6 $vg $lv1
+	not _lvconvert raid6_nr raid6_nr 4 6 $vg $lv1
+	not _lvconvert raid6_nc raid6_nc 4 6 $vg $lv1
+	not _lvconvert raid6_n_6 raid6_n_6 4 6 $vg $lv1
+	not _lvconvert raid6 raid6_n_6 4 6 $vg $lv1
 }
 
 # Delayst leg so that rebuilding status characters
@@ -162,116 +165,116 @@ _lvcreate raid4 3 4 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 
 # Convert raid4 -> striped
-not _lvconvert striped striped 3 $vg $lv1 512k
-_lvconvert striped striped 3 $vg $lv1
+not _lvconvert striped striped 3 3 $vg $lv1 512k
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1 64k
+_lvconvert raid4 raid4 3 4 $vg $lv1 64k
 check lv_field $vg/$lv1 regionsize "64.00k"
 
 # Convert raid4 -> raid5_n
-_lvconvert raid5 raid5_n 4 $vg $lv1 128k
+_lvconvert raid5 raid5_n 3 4 $vg $lv1 128k
 check lv_field $vg/$lv1 regionsize "128.00k"
 
 # Convert raid5_n -> striped
-_lvconvert striped striped 3 $vg $lv1
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid5_n
-_lvconvert raid5_n raid5_n 4 $vg $lv1
+_lvconvert raid5_n raid5_n 3 4 $vg $lv1
 
 # Convert raid5_n -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1
+_lvconvert raid4 raid4 3 4 $vg $lv1
 
 # Convert raid4 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1
+_lvconvert raid0 raid0 3 3 $vg $lv1
 
 # Convert raid0 -> raid5_n
-_lvconvert raid5_n raid5_n 4 $vg $lv1
+_lvconvert raid5_n raid5_n 3 4 $vg $lv1
 
 # Convert raid5_n -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+_lvconvert raid0_meta raid0_meta 3 3 $vg $lv1
 
 # Convert raid0_meta -> raid5_n
-_lvconvert raid5 raid5_n 4 $vg $lv1
+_lvconvert raid5 raid5_n 3 4 $vg $lv1
 
 # Convert raid4 -> raid0_meta
-not _lvconvert raid0_meta raid0_meta 3 $vg $lv1 256k
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+not _lvconvert raid0_meta raid0_meta 3 3 $vg $lv1 256k
+_lvconvert raid0_meta raid0_meta 3 3 $vg $lv1
 
 # Convert raid0_meta -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1
+_lvconvert raid4 raid4 3 4 $vg $lv1
 
 # Convert raid4 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1
+_lvconvert raid0 raid0 3 3 $vg $lv1
 
 # Convert raid0 -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1
+_lvconvert raid4 raid4 3 4 $vg $lv1
 
 # Convert raid4 -> striped
-_lvconvert striped striped 3 $vg $lv1
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid6_n_6
-_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6_n_6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> striped
-_lvconvert striped striped 3 $vg $lv1
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid6_n_6
-_lvconvert raid6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid5_n
-_lvconvert raid5_n raid5_n 4 $vg $lv1
+_lvconvert raid5_n raid5_n 3 4 $vg $lv1
 
 # Convert raid5_n -> raid6_n_6
-_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6_n_6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid4
-_lvconvert raid4 raid4 4 $vg $lv1
+_lvconvert raid4 raid4 3 4 $vg $lv1
 
 # Convert raid4 -> raid6_n_6
-_lvconvert raid6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0
-_lvconvert raid0 raid0 3 $vg $lv1
+_lvconvert raid0 raid0 3 3 $vg $lv1
 
 # Convert raid0 -> raid6_n_6
-_lvconvert raid6_n_6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6_n_6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+_lvconvert raid0_meta raid0_meta 3 3 $vg $lv1
 
 # Convert raid0_meta -> raid6_n_6
-_lvconvert raid6 raid6_n_6 5 $vg $lv1
+_lvconvert raid6 raid6_n_6 3 5 $vg $lv1
 
 # Convert raid6_n_6 -> striped
-not _lvconvert striped striped 3 $vg $lv1 128k
-_lvconvert striped striped 3 $vg $lv1
+not _lvconvert striped striped 3 3 $vg $lv1 128k
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Convert striped -> raid10
-_lvconvert raid10 raid10 6 $vg $lv1
+_lvconvert raid10 raid10 3 6 $vg $lv1
 
 # Convert raid10 -> raid0
-not _lvconvert raid0 raid0 3 $vg $lv1 64k
-_lvconvert raid0 raid0 3 $vg $lv1
+not _lvconvert raid0 raid0 3 3 $vg $lv1 64k
+_lvconvert raid0 raid0 3 3 $vg $lv1
 
 # Convert raid0 -> raid10
-_lvconvert raid10 raid10 6 $vg $lv1
+_lvconvert raid10 raid10 3 6 $vg $lv1
 
 # Convert raid10 -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+_lvconvert raid0_meta raid0_meta 3 3 $vg $lv1
 
 # Convert raid0_meta -> raid5
-_lvconvert raid5_n raid5_n 4 $vg $lv1
+_lvconvert raid5_n raid5_n 3 4 $vg $lv1
 
 # Convert raid5_n -> raid0_meta
-_lvconvert raid0_meta raid0_meta 3 $vg $lv1
+_lvconvert raid0_meta raid0_meta 3 3 $vg $lv1
 
 # Convert raid0_meta -> raid10
-_lvconvert raid10 raid10 6 $vg $lv1
+_lvconvert raid10 raid10 3 6 $vg $lv1
 
 # Convert raid10 -> striped
-not _lvconvert striped striped 3 $vg $lv1 256k
-_lvconvert striped striped 3 $vg $lv1
+not _lvconvert striped striped 3 3 $vg $lv1 256k
+_lvconvert striped striped 3 3 $vg $lv1
 
 # Clean up
 lvremove -y $vg
@@ -280,51 +283,51 @@ lvremove -y $vg
 _lvcreate raid5 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
-not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-_lvconvert raid5_ls raid5_ls 5 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 4 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 4 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+_lvconvert raid6_ls_6 raid6_ls_6 4 6 $vg $lv1
+_lvconvert raid5_ls raid5_ls 4 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_ls 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
-not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-_lvconvert raid5_ls raid5_ls 5 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 4 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 4 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+_lvconvert raid6_ls_6 raid6_ls_6 4 6 $vg $lv1
+_lvconvert raid5_ls raid5_ls 4 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_rs 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
-not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-_lvconvert raid5_rs raid5_rs 5 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 4 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+_lvconvert raid6_rs_6 raid6_rs_6 4 6 $vg $lv1
+_lvconvert raid5_rs raid5_rs 4 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_la 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
-not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-_lvconvert raid5_la raid5_la 5 $vg $lv1
+not _lvconvert raid6_ls_6 raid6_ls_6 4 6 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 4 6 $vg $lv1
+not _lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+_lvconvert raid6_la_6 raid6_la_6 4 6 $vg $lv1
+_lvconvert raid5_la raid5_la 4 5 $vg $lv1
 lvremove -y $vg
 
 _lvcreate raid5_ra 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
-not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
-not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
-not _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
-_lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
-_lvconvert raid5_ra raid5_ra 5 $vg $lv1
+not _lvconvert raid6_ls_6 raid6_ls_6 4 6 $vg $lv1
+not _lvconvert raid6_rs_6 raid6_rs_6 4 6 $vg $lv1
+not _lvconvert raid6_la_6 raid6_la_6 4 6 $vg $lv1
+_lvconvert raid6_ra_6 raid6_ra_6 4 6 $vg $lv1
+_lvconvert raid5_ra raid5_ra 4 5 $vg $lv1
 lvremove -y $vg
 
 else


