From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 18 Aug 2014 14:03:44 +0000 (UTC)
Subject: master - report: fix thin external snapshot identification for lv_layout and lv_type fields
Message-ID: <20140818140344.D7B3C610E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90c47a49686431a097809d1d133a071a95a14e68
Commit:        90c47a49686431a097809d1d133a071a95a14e68
Parent:        4d45302e25f5fe1251bdd8f2c49c4a75a4a31d2e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 18 15:58:48 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 18 15:58:48 2014 +0200

report: fix thin external snapshot identification for lv_layout and lv_type fields

Thin snapshots having external origins missed the "snapshot" keyword for
lv_type field. Also, thin external origins which are thin devices (from
another pool) were not recognized properly.

For example, external origin itself can be either non-thin volume (lvol0
below) or it can be a thin volume from another pool (lvol3 below):

Before this patch:

$ lvs -o name,vg_name,attr,pool_lv,origin,layout,type
  Internal error: Failed to properly detect layout and type for for LV vg/lvol3
  Internal error: Failed to properly detect layout and type for for LV vg/lvol3
  LV    VG     Attr       Pool  Origin Layout     Type
  lvol0 vg     ori-------              linear     external,origin,thin
  lvol2 vg     Vwi-a-tz-- pool  lvol0  thin       thin
  lvol3 vg     ori---tz-- pool         unknown    external,origin,thin,thin
  lvol4 vg     Vwi-a-tz-- pool1 lvol3  thin       thin
  pool  vg     twi-a-tz--              pool,thin  pool,thin
  pool1 vg     twi-a-tz--              pool,thin  pool,thin

- lvol2 as well as lvol4 have missing "snapshot" in type field
- lvol3 has unrecognized layout (should be "thin"), but has double
  "thin" in lv_type which is incorrect
- (also there's double "for" in the internal error message)

With this patch applied:

$ lvs -o name,vg_name,attr,pool_lv,origin,layout,type
  LV    VG     Attr       Pool  Origin Layout     Type
  lvol0 vg     ori-------              linear     external,origin,thin
  lvol2 vg     Vwi-a-tz-- pool  lvol0  thin       snapshot,thin
  lvol3 vg     ori---tz-- pool         thin       external,origin,thin
  lvol4 vg     Vwi-a-tz-- pool1 lvol3  thin       snapshot,thin
  pool  vg     twi-a-tz--              pool,thin  pool,thin
  pool1 vg     twi-a-tz--              pool,thin  pool,thin
---
 lib/metadata/lv_manip.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b2e927d..81001fd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -267,6 +267,7 @@ static int _lv_type_list_thin(struct dm_pool *mem,
 {
 	int top_level = 1;
 	unsigned snap_count;
+	struct lv_segment *seg;
 
 	if (lv_is_thin_pool(lv)) {
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]) ||
@@ -292,18 +293,11 @@ static int _lv_type_list_thin(struct dm_pool *mem,
 		if (snap_count > 1 &&
 		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MULTIPLE]))
 			goto_bad;
-		if (first_seg(lv)->origin)
+		if ((seg = first_seg(lv)) && (seg->origin || seg->external_lv))
 			if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_SNAPSHOT]))
 				goto_bad;
 	}
 
-	if (lv_is_external_origin(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_ORIGIN]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_EXTERNAL]))
-			goto_bad;
-		top_level = 0;
-	}
-
 	if (top_level) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
@@ -382,10 +376,19 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 		goto_bad;
 
 	/* Thins and related */
-	if ((lv_is_thin_type(lv) || lv_is_external_origin(lv)) &&
+	if (lv_is_thin_type(lv) &&
 	    !_lv_type_list_thin(mem, lv, *layout, *type))
 		goto_bad;
 
+	if (lv_is_external_origin(lv)) {
+		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_EXTERNAL]))
+			goto_bad;
+		if (!lv_is_thin_volume(lv) &&
+		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_THIN]))
+			goto_bad;
+	}
+
 	/* Caches and related */
 	if (lv_is_cache_type(lv) &&
 	    !_lv_type_list_cache(mem, lv, *layout, *type))
@@ -439,7 +442,7 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 				 */
 				unknown = 1;
 				log_error(INTERNAL_ERROR "Failed to properly detect "
-					  "layout and type for for LV %s/%s",
+					  "layout and type for LV %s/%s",
 					  lv->vg->name, lv->name);
 			}
 		}


