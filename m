From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:20 -0400
Subject: [PATCH 08/20] Add tags_format_and_copy() common function and call from _tags_disp.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a common function to allocate memory and format a string of
tags.
Call tags_format_and_copy() from _tags_disp().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   24 ++++++++++++++++++++++++
 lib/metadata/metadata.h |    1 +
 lib/report/report.c     |   21 +++------------------
 3 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 07f6a90..58b5b6e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3936,6 +3936,30 @@ char alloc_policy_char(alloc_policy_t alloc)
 	}
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
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 70efe9e..3ebe736 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -413,5 +413,6 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char alloc_policy_char(alloc_policy_t alloc);
+char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index b8c5d1a..cac4f8b 100644
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
1.7.2.2


