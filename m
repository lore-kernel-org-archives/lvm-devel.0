From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:35:54 -0400
Subject: [PATCH 02/19] Refactor pvstatus_disp to take pv argument and call common pv_attr function.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   21 +++++++++++++++++++++
 lib/metadata/metadata.h |    1 +
 lib/report/columns.h    |    2 +-
 lib/report/report.c     |   17 +++--------------
 4 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 094ffc1..86f07e7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4598,6 +4598,27 @@ char *vg_attr(struct dm_pool *mem, const struct volume_group *vg)
 	return repstr;
 }
 
+char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 3))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (pv->status & ALLOCATABLE_PV)
+		repstr[0] = 'a';
+	else
+		repstr[0] = '-';
+
+	if (pv->status & EXPORTED_VG)
+		repstr[1] = 'x';
+	else
+		repstr[1] = '-';
+	return repstr;
+}
+
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	float percent;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f3e268c..1749f85 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -419,6 +419,7 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
+char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv);
 char *vg_attr(struct dm_pool *mem, const struct volume_group *vg);
 char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 95ad578..689f6a5 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -93,7 +93,7 @@ FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the star
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
-FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
+FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 2de78a1..b7612a1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -266,23 +266,12 @@ static int _pvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	const uint32_t status = *(const uint32_t *) data;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 3))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = pv_attr(mem, pv)))
 		return 0;
-	}
-
-	if (status & ALLOCATABLE_PV)
-		repstr[0] = 'a';
-	else
-		repstr[0] = '-';
-
-	if (status & EXPORTED_VG)
-		repstr[1] = 'x';
-	else
-		repstr[1] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
-- 
1.7.2.1


