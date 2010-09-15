From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:35:58 -0400
Subject: [PATCH 06/19] Add tags_format_and_copy() common function to format tags strings.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   24 ++++++++++++++++++++++++
 lib/metadata/metadata.h |    1 +
 lib/report/report.c     |   21 +++------------------
 3 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cb49d0f..7e8d8f1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4751,6 +4751,30 @@ out:
 	return repstr;
 }
 
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
+{
+	struct str_list *sl;
+
+	if (!dm_pool_begin_object(mem, 256)) {
+		log_error("dm_pool_begin_object failed");
+		return NULL;
+	}
+
+	dm_list_iterate_items(sl, tags) {
+		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
+		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
+			log_error("dm_pool_grow_object failed");
+			return NULL;
+		}
+	}
+
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
+		log_error("dm_pool_grow_object failed");
+		return NULL;
+	}
+	return dm_pool_end_object(mem);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6e6d4c5..64da490 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -425,5 +425,6 @@ char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid(const struct logical_volume *lv);
 char *vg_uuid(const struct volume_group *vg);
 char *pv_uuid(const struct physical_volume *pv);
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 940ee25..ed53fac 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -150,27 +150,12 @@ static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 		      const void *data, void *private __attribute__((unused)))
 {
 	const struct dm_list *tags = (const struct dm_list *) data;
-	struct str_list *sl;
+	char *tags_str;
 
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return 0;
-	}
-
-	dm_list_iterate_items(sl, tags) {
-		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
-		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
-			log_error("dm_pool_grow_object failed");
-			return 0;
-		}
-	}
-
-	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+	if (!(tags_str = tags_format_and_copy(mem, tags)))
 		return 0;
-	}
 
-	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
+	dm_report_field_set_value(field, tags_str, NULL);
 
 	return 1;
 }
-- 
1.7.2.1


