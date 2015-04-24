From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Apr 2015 11:59:51 +0000 (UTC)
Subject: master - report: add lv_ancestors and lv_descendants reporting fields
Message-ID: <20150424115951.96CE76075B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e4aee0492a6c3abbe6ecf24037d57bdd43c41fd
Commit:        6e4aee0492a6c3abbe6ecf24037d57bdd43c41fd
Parent:        82f6dbfaf7b62c044cd765c207bd8eb1db0edc5a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 24 11:51:52 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 24 11:51:52 2015 +0200

report: add lv_ancestors and lv_descendants reporting fields

Show full chain of ancestors and descendants for snapshots
(both thick and thin - in case of thick, the "ancestor" field
is actually equal to "origin" field as snapshots can't be
chained for thick snapshots).

These fields display current state as it is, they do not
display any history! If the snapshot chain is broken in
the middle, we don't report the historical origin (this
is going to be a part of another patch and a different
set of fields or just a switch for existing fields to
show ancestors and descendants with history included).

For example:

(origin --> snapshot)

lvol1 --> lvol2 --> lvol3 --> lvol4
              \
                --> lvol5 --> lvol6 --> lvol7 --> lvol8

$ lvs -o name,pool_lv,origin,ancestors,descendants vg
  LV    Pool Origin Ancestors                     Descendants
  lvol1 pool                                      lvol2,lvol3,lvol4,lvol5,lvol6,lvol7,lvol8
  lvol2 pool lvol1  lvol1                         lvol3,lvol4,lvol5,lvol6,lvol7,lvol8
  lvol3 pool lvol2  lvol2,lvol1                   lvol4
  lvol4 pool lvol3  lvol3,lvol2,lvol1
  lvol5 pool lvol2  lvol2,lvol1                   lvol6,lvol7,lvol8
  lvol6 pool lvol5  lvol5,lvol2,lvol1             lvol7,lvol8
  lvol7 pool lvol6  lvol6,lvol5,lvol2,lvol1       lvol8
  lvol8 pool lvol7  lvol7,lvol6,lvol5,lvol2,lvol1
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    2 +
 lib/report/properties.c |    4 ++
 lib/report/report.c     |  100 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 23c70eb..ca5ee0f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Add lv_ancestors and lv_descendants reporting fields.
   Add --ignorelocal option to dumpconfig to ignore the local section.
   Close connection to lvmetad after fork.
   Make lvchange able to resume background pvmove polling again.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6fde503..8da8db1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -64,6 +64,8 @@ FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thi
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, ancestors, ancestors, "Ancestors of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, descendants, descendants, "Descendants of this LV.", 0)
 FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 4c1f6f5..45ca0c7 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -300,6 +300,10 @@ GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _origin_size_set prop_not_implemented_set
+#define _ancestors_set prop_not_implemented_set
+#define _ancestors_get prop_not_implemented_get
+#define _descendants_set prop_not_implemented_set
+#define _descendants_get prop_not_implemented_get
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index c29acdb..73beda3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -633,6 +633,106 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", NULL);
 }
 
+static int _find_ancestors(struct _str_list_append_baton *ancestors,
+			   struct logical_volume *lv)
+{
+	struct logical_volume *ancestor_lv = NULL;
+	struct lv_segment *seg;
+
+	if (lv_is_cow(lv)) {
+		ancestor_lv = origin_from_cow(lv);
+	} else 	if (lv_is_thin_volume(lv)) {
+		seg = first_seg(lv);
+		if (seg->origin)
+			ancestor_lv = seg->origin;
+		else if (seg->external_lv)
+			ancestor_lv = seg->external_lv;
+	}
+
+	if (ancestor_lv) {
+		if (!_str_list_append(ancestor_lv->name, ancestors))
+			return_0;
+		if (!_find_ancestors(ancestors, ancestor_lv))
+			return_0;
+	}
+
+	return 1;
+}
+
+static int _ancestors_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct _str_list_append_baton ancestors;
+
+	ancestors.mem = mem;
+	if (!(ancestors.result = str_list_create(mem)))
+		return_0;
+
+	if (!_find_ancestors(&ancestors, lv)) {
+		dm_pool_free(ancestors.mem, ancestors.result);
+		return_0;
+	}
+
+	return _field_set_string_list(rh, field, ancestors.result, private, 0);
+}
+
+static int _find_descendants(struct _str_list_append_baton *descendants,
+			     struct logical_volume *lv)
+{
+	struct logical_volume *descendant_lv = NULL;
+	const struct seg_list *sl;
+	struct lv_segment *seg;
+
+	if (lv_is_origin(lv)) {
+		dm_list_iterate_items_gen(seg, &lv->snapshot_segs, origin_list) {
+			if ((descendant_lv = seg->cow)) {
+				if (!_str_list_append(descendant_lv->name, descendants))
+					return_0;
+				if (!_find_descendants(descendants, descendant_lv))
+					return_0;
+			}
+		}
+	} else {
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+			if (lv_is_thin_volume(sl->seg->lv)) {
+				seg = first_seg(sl->seg->lv);
+				if ((seg->origin == lv) || (seg->external_lv == lv))
+					descendant_lv = sl->seg->lv;
+			}
+
+			if (descendant_lv) {
+				if (!_str_list_append(descendant_lv->name, descendants))
+					return_0;
+				if (!_find_descendants(descendants, descendant_lv))
+					return_0;
+			}
+		}
+	}
+
+	return 1;
+}
+
+static int _descendants_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct _str_list_append_baton descendants;
+
+	descendants.mem = mem;
+	if (!(descendants.result = str_list_create(mem)))
+		return_0;
+
+	if (!_find_descendants(&descendants, lv)) {
+		dm_pool_free(descendants.mem, descendants.result);
+		return_0;
+	}
+
+	return _field_set_string_list(rh, field, descendants.result, private, 0);
+}
+
 static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))


