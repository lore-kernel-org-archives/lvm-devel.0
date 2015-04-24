From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Apr 2015 12:19:58 +0000 (UTC)
Subject: master - cleanup: ancestors -> lv_ancestors, descendants -> lv_descendants
Message-ID: <20150424121958.C683160559@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=066d0a4e1949afac055a7dc92bedd0f45f519124
Commit:        066d0a4e1949afac055a7dc92bedd0f45f519124
Parent:        6e4aee0492a6c3abbe6ecf24037d57bdd43c41fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 24 14:19:23 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 24 14:19:28 2015 +0200

cleanup: ancestors -> lv_ancestors, descendants -> lv_descendants

Use "lv_" prefix as they're LV fields.
---
 lib/report/columns.h    |    4 ++--
 lib/report/properties.c |    8 ++++----
 lib/report/report.c     |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 8da8db1..cf84295 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -64,8 +64,8 @@ FIELD(LVS, lv, SIZ, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thi
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
-FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, ancestors, ancestors, "Ancestors of this LV.", 0)
-FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, descendants, descendants, "Descendants of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 12, lvancestors, lv_ancestors, "Ancestors of this LV.", 0)
+FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 12, lvdescendants, lv_descendants, "Descendants of this LV.", 0)
 FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 45ca0c7..ea70690 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -300,10 +300,10 @@ GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _origin_size_set prop_not_implemented_set
-#define _ancestors_set prop_not_implemented_set
-#define _ancestors_get prop_not_implemented_get
-#define _descendants_set prop_not_implemented_set
-#define _descendants_get prop_not_implemented_get
+#define _lv_ancestors_set prop_not_implemented_set
+#define _lv_ancestors_get prop_not_implemented_get
+#define _lv_descendants_set prop_not_implemented_set
+#define _lv_descendants_get prop_not_implemented_get
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 73beda3..500bf2b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -659,7 +659,7 @@ static int _find_ancestors(struct _str_list_append_baton *ancestors,
 	return 1;
 }
 
-static int _ancestors_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvancestors_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
@@ -714,7 +714,7 @@ static int _find_descendants(struct _str_list_append_baton *descendants,
 	return 1;
 }
 
-static int _descendants_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvdescendants_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {


