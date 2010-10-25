From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:09 +0200
Subject: [PATCH 02/30] Use dm_pool_grow_object embeded strlen for 0 delta
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <c8607124ac3c8c7f5d92aafc1e266732df8f2abc.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use internal strlen for 0

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c       |    2 +-
 lib/format_text/archive.c |    4 ++--
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/metadata.c   |    4 ++--
 lib/report/report.c       |    6 +++---
 tools/lvmcmdline.c        |    2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2b38663..e64ec86 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -387,7 +387,7 @@ static int _line_append(struct output_line *outline, const char *fmt, ...)
 	}
 	va_end(ap);
 
-	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
+	if (!dm_pool_grow_object(outline->mem, buf, 0)) {
 		log_error("dm_pool_grow_object failed for config line");
 		return 0;
 	}
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index bf16da5..246350b 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -110,9 +110,9 @@ static void _insert_archive_file(struct dm_list *head, struct archive_file *b)
 static char *_join_file_to_dir(struct dm_pool *mem, const char *dir, const char *name)
 {
 	if (!dm_pool_begin_object(mem, 32) ||
-	    !dm_pool_grow_object(mem, dir, strlen(dir)) ||
+	    !dm_pool_grow_object(mem, dir, 0) ||
 	    !dm_pool_grow_object(mem, "/", 1) ||
-	    !dm_pool_grow_object(mem, name, strlen(name)) ||
+	    !dm_pool_grow_object(mem, name, 0) ||
 	    !dm_pool_grow_object(mem, "\0", 1))
 		return_NULL;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e4349cc..0ea7dcf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -665,7 +665,7 @@ static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_are
 		}
 
 		dm_list_iterate_items(pvl, &spvs->pvs) {
-			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
+			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), 0)) {
 				log_error("dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4d11ac4..2da4085 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1078,7 +1078,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
 			dm_pool_free(mem, bs);
                 	return NULL;
 		}
-		if (!dm_pool_grow_object(mem, buf, strlen(buf))) {
+		if (!dm_pool_grow_object(mem, buf, 0)) {
 			log_error("Failed to generate list of random bits.");
 			dm_pool_free(mem, bs);
                 	return NULL;
@@ -3970,7 +3970,7 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 	}
 
 	dm_list_iterate_items(sl, tags) {
-		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
+		if (!dm_pool_grow_object(mem, sl->str, 0) ||
 		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
 			log_error("dm_pool_grow_object failed");
 			return NULL;
diff --git a/lib/report/report.c b/lib/report/report.c
index 7a90b4d..b26a1e3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -85,7 +85,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 			extent = 0;
 		}
 
-		if (!dm_pool_grow_object(mem, name, strlen(name))) {
+		if (!dm_pool_grow_object(mem, name, 0)) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
@@ -97,7 +97,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 			log_error("Extent number dm_snprintf failed");
 			return 0;
 		}
-		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
+		if (!dm_pool_grow_object(mem, extent_str, 0)) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
@@ -108,7 +108,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 				log_error("Extent number dm_snprintf failed");
 				return 0;
 			}
-			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
+			if (!dm_pool_grow_object(mem, extent_str, 0)) {
 				log_error("dm_pool_grow_object failed");
 				return 0;
 			}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b29acfb..06873a0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -986,7 +986,7 @@ static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **
 		if (space && !dm_pool_grow_object(cmd->mem, "'", 1))
 			goto_bad;
 
-		if (!dm_pool_grow_object(cmd->mem, argv[i], strlen(argv[i])))
+		if (!dm_pool_grow_object(cmd->mem, argv[i], 0))
 			goto_bad;
 
 		if (space && !dm_pool_grow_object(cmd->mem, "'", 1))
-- 
1.7.3.1


