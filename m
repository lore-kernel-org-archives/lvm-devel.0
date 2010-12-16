From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:13 +0100
Subject: [PATCH 05/20] Remove const from destroy callback
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <2c8db0418db9ba1284e760ffda4baf8c0321d8d3.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We have 2 choices here:
 - add dm_free_c(const void*) to accept const pointers for free
   and make just one const void* -> void* cast there.

 - stick with 'standard' way of freeing non-const pointers - i.e
   when freeing point we usually have the writable structure.

So this patch removes 'const' from destroy() function callbacks.
Note: i.e. in _text_destroy() we even operate on passed const pointer.

2nd note we still have functions which need to free static pointers,
so this patch doesn't fix all places - but it's get down to very few
occurences.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/error/errseg.c            |    4 ++--
 lib/format1/format1.c         |    4 ++--
 lib/format_pool/format_pool.c |    4 ++--
 lib/format_text/format-text.c |    4 ++--
 lib/freeseg/freeseg.c         |    4 ++--
 lib/metadata/metadata.h       |    2 +-
 lib/metadata/segtype.h        |    2 +-
 lib/mirror/mirrored.c         |    4 ++--
 lib/replicator/replicator.c   |    4 ++--
 lib/snapshot/snapshot.c       |    4 ++--
 lib/striped/striped.c         |    4 ++--
 lib/unknown/unknown.c         |    4 ++--
 lib/zero/zero.c               |    4 ++--
 13 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 6cfcd79..add1df8 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -81,9 +81,9 @@ static int _errseg_modules_needed(struct dm_pool *mem,
 	return 1;
 }
 
-static void _errseg_destroy(const struct segment_type *segtype)
+static void _errseg_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _error_ops = {
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 0dcec05..b35bd98 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -555,9 +555,9 @@ static void _format1_destroy_instance(struct format_instance *fid __attribute__(
 {
 }
 
-static void _format1_destroy(const struct format_type *fmt)
+static void _format1_destroy(struct format_type *fmt)
 {
-	dm_free((void *) fmt);
+	dm_free(fmt);
 }
 
 static struct format_handler _format1_ops = {
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 545195b..730da87 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -286,9 +286,9 @@ static void _pool_destroy_instance(struct format_instance *fid __attribute__((un
 {
 }
 
-static void _pool_destroy(const struct format_type *fmt)
+static void _pool_destroy(struct format_type *fmt)
 {
-	dm_free((void *) fmt);
+	dm_free(fmt);
 }
 
 /* *INDENT-OFF* */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index caab923..c186757 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1719,7 +1719,7 @@ static void _free_raws(struct dm_list *raw_list)
 	}
 }
 
-static void _text_destroy(const struct format_type *fmt)
+static void _text_destroy(struct format_type *fmt)
 {
 	if (fmt->private) {
 		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
@@ -1727,7 +1727,7 @@ static void _text_destroy(const struct format_type *fmt)
 		dm_free(fmt->private);
 	}
 
-	dm_free((void *)fmt);
+	dm_free(fmt);
 }
 
 static struct metadata_area_ops _metadata_text_file_ops = {
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 08f3100..8e73be0 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -31,9 +31,9 @@ static const char *_freeseg_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
-static void _freeseg_destroy(const struct segment_type *segtype)
+static void _freeseg_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _freeseg_ops = {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 815e460..08bff4a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -291,7 +291,7 @@ struct format_handler {
 	/*
 	 * Destructor for format type
 	 */
-	void (*destroy) (const struct format_type * fmt);
+	void (*destroy) (struct format_type * fmt);
 };
 
 /*
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 8bf16d7..6d50746 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -97,7 +97,7 @@ struct segtype_handler {
 	int (*modules_needed) (struct dm_pool *mem,
 			       const struct lv_segment *seg,
 			       struct dm_list *modules);
-	void (*destroy) (const struct segment_type * segtype);
+	void (*destroy) (struct segment_type * segtype);
 	int (*target_monitored) (struct lv_segment *seg, int *pending);
 	int (*target_monitor_events) (struct lv_segment *seg, int events);
 	int (*target_unmonitor_events) (struct lv_segment *seg, int events);
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index a02ccb5..3d25d70 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -600,9 +600,9 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 	return 1;
 }
 
-static void _mirrored_destroy(const struct segment_type *segtype)
+static void _mirrored_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _mirrored_ops = {
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 1753bca..26a5cf1 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -406,9 +406,9 @@ static int _replicator_modules_needed(struct dm_pool *mem,
 	return 1;
 }
 
-static void _replicator_destroy(const struct segment_type *segtype)
+static void _replicator_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _replicator_ops = {
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index e1612f9..1a98d7e 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -218,9 +218,9 @@ static int _snap_modules_needed(struct dm_pool *mem,
 	return 1;
 }
 
-static void _snap_destroy(const struct segment_type *segtype)
+static void _snap_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _snapshot_ops = {
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 7ba963b..51bf24a 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -199,9 +199,9 @@ static int _striped_target_present(struct cmd_context *cmd,
 }
 #endif
 
-static void _striped_destroy(const struct segment_type *segtype)
+static void _striped_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _striped_ops = {
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 6dc00f6..332ae99 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -74,9 +74,9 @@ static int _unknown_add_target_line(struct dev_manager *dm __attribute__((unused
 }
 #endif
 
-static void _unknown_destroy(const struct segment_type *segtype)
+static void _unknown_destroy(struct segment_type *segtype)
 {
-	dm_free((void *)segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _unknown_ops = {
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 7e5ffa6..16ce66c 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -78,9 +78,9 @@ static int _zero_modules_needed(struct dm_pool *mem,
 	return 1;
 }
 
-static void _zero_destroy(const struct segment_type *segtype)
+static void _zero_destroy(struct segment_type *segtype)
 {
-	dm_free((void *) segtype);
+	dm_free(segtype);
 }
 
 static struct segtype_handler _zero_ops = {
-- 
1.7.3.3


