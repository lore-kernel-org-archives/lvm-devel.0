From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  6 Aug 2016 23:57:10 +0000 (UTC)
Subject: master - raid: Report supported lvconvert conversions if invalid.
Message-ID: <20160806235710.3570260DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de7f1deb80499087662e57c4aef9e9373f15ca63
Commit:        de7f1deb80499087662e57c4aef9e9373f15ca63
Parent:        6f236c3353cbcac799f755870251da7a5d576c41
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 7 00:30:26 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 7 00:30:26 2016 +0100

raid: Report supported lvconvert conversions if invalid.

---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |  206 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 204 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index df1a434..7282081 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Report supported conversions when asked for unsupported raid lvconvert.
   Add "--rebuild PV" option to lvchange to allow for PV selective rebuilds.
   Preserve existing mirror region size when using --repair.
   Forbid stripe parameters with lvconvert --repair.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 840c831..2e491eb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2061,6 +2061,7 @@ static uint32_t _min_sublv_area_at_le(struct lv_segment *seg, uint32_t area_le)
 
 	return area_len;
 }
+
 /*
  * All areas from lv image component LV's segments are
  * being split at "striped" compatible boundaries and
@@ -2200,7 +2201,6 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	if (!is_power_of_2(seg->stripe_size)) {
 		log_error("Cannot convert striped LV %s with non-power of 2 stripe size %u",
 			  display_lvname(lv), seg->stripe_size);
-		// log_error("Please use \"lvconvert --duplicate ...\"");
 		return NULL;
 	}
 
@@ -2260,6 +2260,195 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 
 /***********************************************/
 
+/*
+ * Takeover.
+ *
+ */
+#define	ALLOW_NONE		0x0
+#define	ALLOW_STRIPES		0x2
+#define	ALLOW_STRIPE_SIZE	0x4
+
+struct possible_takeover_reshape_type {
+	/* First 2 have to stay... */
+	const uint64_t possible_types;
+	const uint32_t options;
+	const uint64_t current_types;
+	const uint32_t current_areas;
+};
+
+struct possible_type {
+	/* ..to be handed back via this struct */
+	const uint64_t possible_types;
+	const uint32_t options;
+};
+
+static struct possible_takeover_reshape_type _possible_takeover_reshape_types[] = {
+	/* striped -> */
+	{ .current_types  = SEG_STRIPED_TARGET, /* striped, i.e. seg->area_count > 1 */
+	  .possible_types = SEG_RAID0|SEG_RAID0_META,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
+	/* raid0* -> */
+	{ .current_types  = SEG_RAID0|SEG_RAID0_META, /* raid0 striped, i.e. seg->area_count > 0 */
+	  .possible_types = SEG_STRIPED_TARGET|SEG_RAID0|SEG_RAID0_META,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
+	/* raid1 -> */
+	{ .current_types  = SEG_RAID1,
+	  .possible_types = SEG_RAID1,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
+	/* mirror -> raid1 with arbitrary number of legs */
+	{ .current_types  = SEG_MIRROR,
+	  .possible_types = SEG_MIRROR,
+	  .current_areas = ~0U,
+	  .options = ALLOW_NONE },
+
+	/* END */
+	{ .current_types  = 0 }
+};
+
+/*
+ * Return possible_type struct for current segment type.
+ */
+static struct possible_takeover_reshape_type *_get_possible_takeover_reshape_type(const struct lv_segment *seg_from,
+										   const struct segment_type *segtype_to,
+										   struct possible_type *last_pt)
+{
+	struct possible_takeover_reshape_type *lpt = (struct possible_takeover_reshape_type *) last_pt;
+	struct possible_takeover_reshape_type *pt = lpt ? lpt + 1 : _possible_takeover_reshape_types;
+
+	for ( ; pt->current_types; pt++)
+		if ((seg_from->segtype->flags & pt->current_types) &&
+		    (segtype_to ? (segtype_to->flags & pt->possible_types) : 1))
+			if (seg_from->area_count <= pt->current_areas)
+				return pt;
+
+	return NULL;
+}
+
+static struct possible_type *_get_possible_type(const struct lv_segment *seg_from,
+						const struct segment_type *segtype_to,
+						uint32_t new_image_count,
+						struct possible_type *last_pt)
+{
+	return (struct possible_type *) _get_possible_takeover_reshape_type(seg_from, segtype_to, last_pt);
+}
+
+/*
+ * Log any possible conversions for @lv
+ */
+typedef int (*type_flag_fn_t)(uint64_t *processed_segtypes, void *data);
+
+/* Loop through pt->flags calling tfn with argument @data */
+static int _process_type_flags(const struct logical_volume *lv, struct possible_type *pt, uint64_t *processed_segtypes, type_flag_fn_t tfn, void *data)
+{
+	unsigned i;
+	uint64_t t;
+	const struct lv_segment *seg = first_seg(lv);
+	const struct segment_type *segtype;
+
+	for (i = 0; i < 64; i++) {
+		t = 1ULL << i;
+		if ((t & pt->possible_types) &&
+		    !(t & seg->segtype->flags) &&
+		     ((segtype = get_segtype_from_flag(lv->vg->cmd, t))))
+			if (!tfn(processed_segtypes, data ? : (void *) segtype))
+				return 0;
+	}
+
+	return 1;
+}
+
+/* Callback to increment unsigned  possible conversion types in *data */
+static int _count_possible_conversions(uint64_t *processed_segtypes, void *data)
+{
+	unsigned *possible_conversions = data;
+
+	(*possible_conversions)++;
+
+	return 1;
+}
+
+/* Callback to log possible conversion to segment type in *data */
+static int _log_possible_conversion(uint64_t *processed_segtypes, void *data)
+{
+	struct segment_type *segtype = data;
+
+	/* Already processed? */
+	if (!(~*processed_segtypes & segtype->flags))
+		return 1;
+
+	log_error("  %s", segtype->name);
+
+	*processed_segtypes |= segtype->flags;
+
+	return 1;
+}
+
+static const char *_get_segtype_alias(const struct segment_type *segtype)
+{
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID5))
+		return SEG_TYPE_NAME_RAID5_LS;
+
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID6))
+		return SEG_TYPE_NAME_RAID6_ZR;
+
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID5_LS))
+		return SEG_TYPE_NAME_RAID5;
+
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID6_ZR))
+		return SEG_TYPE_NAME_RAID6;
+
+	return "";
+}
+
+/* Return "linear" for striped segtype with 1 area instead of "striped" */
+static const char *_get_segtype_name(const struct segment_type *segtype, unsigned new_image_count)
+{
+	if (!segtype || (segtype_is_striped(segtype) && new_image_count == 1))
+		return "linear";
+
+	return segtype->name;
+}
+
+static int _log_possible_conversion_types(const struct logical_volume *lv, const struct segment_type *new_segtype)
+{
+	unsigned possible_conversions = 0;
+	const struct lv_segment *seg = first_seg(lv);
+	struct possible_type *pt = NULL;
+	const char *alias;
+	uint64_t processed_segtypes = UINT64_C(0);
+
+	/* Count any possible segment types @seg an be directly converted to */
+	while ((pt = _get_possible_type(seg, NULL, 0, pt)))
+		if (!_process_type_flags(lv, pt, &processed_segtypes, _count_possible_conversions, &possible_conversions))
+			return_0;
+
+	if (!possible_conversions)
+		log_error("Direct conversion of %s LV %s is not possible.", lvseg_name(seg), display_lvname(lv));
+	else {
+			alias = _get_segtype_alias(seg->segtype);
+
+			log_error("Converting %s from %s%s%s%s is "
+				  "directly possible to the following layout%s:",
+				  display_lvname(lv), _get_segtype_name(seg->segtype, seg->area_count),
+				  *alias ? " (same as " : "", alias, *alias ? ")" : "",
+				  possible_conversions > 1 ? "s" : "");
+
+			pt = NULL;
+
+			/* Print any possible segment types @seg can be directly converted to */
+			while ((pt = _get_possible_type(seg, NULL, 0, pt)))
+				if (!_process_type_flags(lv, pt, &processed_segtypes, _log_possible_conversion, NULL))
+					return_0;
+	}
+
+	return 0;
+}
+
+/***********************************************/
+
 #define TAKEOVER_FN_ARGS			\
 	struct logical_volume *lv,		\
 	const struct segment_type *new_segtype,	\
@@ -2293,6 +2482,9 @@ static int _takeover_unsupported(TAKEOVER_FN_ARGS)
 		  (segtype_is_striped_target(new_segtype) &&
 		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
+	if (!_log_possible_conversion_types(lv, new_segtype))
+		stack;
+
 	return 0;
 }
 
@@ -2303,6 +2495,9 @@ static int _takeover_unsupported_yet(const struct logical_volume *lv, const unsi
 		  (segtype_is_striped_target(new_segtype) &&
 		   (new_stripes == 1)) ? SEG_TYPE_NAME_LINEAR : new_segtype->name);
 
+	if (!_log_possible_conversion_types(lv, new_segtype))
+		stack;
+
 	return 0;
 }
 
@@ -2453,6 +2648,7 @@ static int _takeover_from_raid0_to_mirrored(TAKEOVER_FN_ARGS)
 {
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
+
 static int _takeover_from_raid0_to_raid0_meta(TAKEOVER_FN_ARGS)
 {
 	if (!_raid0_meta_change_wrapper(lv, new_segtype, new_stripes, yes, force, 1, allocate_pvs))
@@ -2766,9 +2962,13 @@ static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t
 /*
  * lv_raid_convert
  *
- * Convert an LV from one RAID type (or 'mirror' segtype) to another.
+ * Convert lv from one RAID type (or striped/mirror segtype) to new_segtype,
+ * or add/remove LVs to/from a RAID LV.
  *
- * Returns: 1 on success, 0 on failure
+ * Non dm-raid changes e.g. mirror/striped functions are also called from here.
+ *
+ * Takeover is defined as a switch from one raid level to another, potentially
+ * involving the addition of one or more image component pairs and rebuild.
  */
 int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,


