From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 08:40:57 -0500
Subject: master - raid: fix compile time warning
Message-ID: <201703101340.v2ADevn6005154@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b9b76d029143b4589e41a6c4b8daa0eec163909
Commit:        8b9b76d029143b4589e41a6c4b8daa0eec163909
Parent:        59e57be54f9b4c9e83ec1ede480285965a7411eb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 14:40:39 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 14:40:39 2017 +0100

raid: fix compile time warning

---
 lib/metadata/raid_manip.c |   44 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a8c2e19..5278001 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1491,7 +1491,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		uint32_t data_rimages = _data_rimages_count(seg, seg->area_count);
 		uint32_t reshape_len = out_of_place_les_per_disk * data_rimages;
 		uint32_t prev_rimage_len = _lv_total_rimage_len(lv);
-		uint64_t lv_size = lv->size;
+		uint64_t lv_size_cur = lv->size;
 
 		if (!lv_extend(lv, seg->segtype, data_rimages,
 			       seg->stripe_size, 1, /* seg_is_any_raid10(seg) ? seg->data_copies : 1, */ seg->region_size,
@@ -1502,7 +1502,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 			return 0;
 		}
 
-		lv->size = lv_size;
+		lv->size = lv_size_cur;
 		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
 		if (!_lv_set_reshape_len(lv, _lv_total_rimage_len(lv) - prev_rimage_len))
 			return 0;
@@ -4405,10 +4405,10 @@ static int _get_allowed_conversion_options(const struct lv_segment *seg_from,
 /*
  * Log any possible conversions for @lv
  */
-typedef int (*type_flag_fn_t)(uint64_t *processed_segtypes, void *data);
+typedef int (*type_flag_fn_t)(const struct logical_volume *lv, void *ref, void *data);
 
 /* Loop through pt->flags calling tfn with argument @data */
-static int _process_type_flags(const struct logical_volume *lv, struct possible_type *pt, uint64_t *processed_segtypes, type_flag_fn_t tfn, void *data)
+static int _process_type_flags(const struct logical_volume *lv, struct possible_type *pt, void *ref, type_flag_fn_t tfn, void *data)
 {
 	unsigned i;
 	uint64_t t;
@@ -4420,7 +4420,7 @@ static int _process_type_flags(const struct logical_volume *lv, struct possible_
 		if ((t & pt->possible_types) &&
 		    !(t & seg->segtype->flags) &&
 		     ((segtype = get_segtype_from_flag(lv->vg->cmd, t))))
-			if (!tfn(processed_segtypes, data ? : (void *) segtype))
+			if (!tfn(lv, ref, data ? : (void *) segtype))
 				return 0;
 	}
 
@@ -4428,7 +4428,7 @@ static int _process_type_flags(const struct logical_volume *lv, struct possible_
 }
 
 /* Callback to increment unsigned  possible conversion types in *data */
-static int _count_possible_conversions(uint64_t *processed_segtypes, void *data)
+static int _count_possible_conversions(const struct logical_volume *lv, void *ref, void *data)
 {
 	unsigned *possible_conversions = data;
 
@@ -4438,15 +4438,43 @@ static int _count_possible_conversions(uint64_t *processed_segtypes, void *data)
 }
 
 /* Callback to log possible conversion to segment type in *data */
-static int _log_possible_conversion(uint64_t *processed_segtypes, void *data)
+static int _log_possible_transitions(const struct logical_volume *lv, void *ref, void *data)
 {
 	struct segment_type *segtype = data;
+	char *segtype_name = dm_pool_strdup(lv->vg->vgmem, first_seg(lv)->segtype->name);
+	char *p = strchr(segtype_name, '_');
+	const char *from_name = ((struct segment_type *) ref)->name;
+	size_t len;
+
+	if (p)
+		*p = '\0';
+
+	len = strlen(segtype_name);
+	if (strcmp(from_name, segtype->name) &&
+	    strncmp(segtype_name, segtype->name, len))
+		log_error("   -> %s", segtype->name);
+
+	return 1;
+}
+
+/* Callback to log possible conversion to segment type in *data */
+static int _log_possible_conversion(const struct logical_volume *lv, void *processed_segtypes_ptr, void *data)
+{
+	struct segment_type *segtype = data;
+	struct possible_takeover_reshape_type *pt = NULL;
+	struct lv_segment seg;
+	uint64_t *processed_segtypes = processed_segtypes_ptr;
 
 	/* Already processed? */
 	if (!(~*processed_segtypes & segtype->flags))
 		return 1;
 
 	log_error("  %s", segtype->name);
+	seg.segtype = segtype;
+	seg.area_count = first_seg(lv)->area_count;
+	if ((pt = _get_possible_takeover_reshape_type(&seg, NULL, (struct possible_type *) pt)))
+		if (!_process_type_flags(lv, (struct possible_type *) pt, segtype, _log_possible_transitions, NULL))
+			return_0;
 
 	*processed_segtypes |= segtype->flags;
 
@@ -4478,7 +4506,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 	const char *alias;
 	uint64_t processed_segtypes = UINT64_C(0);
 
-	/* Count any possible segment types @seg an be directly converted to */
+	/* Count any possible segment types @seg can be directly converted to */
 	while ((pt = _get_possible_type(seg, NULL, 0, pt)))
 		if (!_process_type_flags(lv, pt, &processed_segtypes, _count_possible_conversions, &possible_conversions))
 			return_0;


