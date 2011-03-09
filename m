From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 09 Mar 2011 13:40:34 +0100
Subject: [PATCH 0/7] Add memory pool for format instance and fix memory leaks
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <4D777542.8070705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/09/2011 01:22 PM +0100, Peter Rajnoha wrote:
>   Add memory pool and reference counting for format instances.
>   Move text_context allocation inside create_instance fn.
>   Use vg_set_fid and new pv_set_fid throughout.
>   Add new free_pv_fid fn and use it throughout.
>   Call destroy_instance for all PVs in a VG while calling free_vg.
>   Various cleanups for fid mem and ref_count changes.
>   Switch over to format instance mempool use where possible.

+ one more that has to come as the very first one!

Use new alloc_fid fn for common format instance initialisation.

Just a little cleanup for each format's create_instance fn. There's
common code that doesn't need to be repeated. Factor it out into
a separate "alloc_fid" fn. This makes the code easier to maintain.
---
 lib/format1/format1.c         |    8 +-------
 lib/format_pool/format_pool.c |   13 ++-----------
 lib/format_text/format-text.c |   14 +++-----------
 lib/metadata/metadata.c       |   19 +++++++++++++++++++
 lib/metadata/metadata.h       |   27 +++++++++++++++------------
 5 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 9011982..8550a1e 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -530,15 +530,9 @@ static struct format_instance *_format1_create_instance(const struct format_type
 	struct format_instance *fid;
 	struct metadata_area *mda;
 
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid))))
+	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
-
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
 		dm_pool_free(fmt->cmd->mem, fid);
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 4252dad..482d79a 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -256,17 +256,8 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 	struct format_instance *fid;
 	struct metadata_area *mda;
 
-	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Unable to allocate format instance structure for "
-			  "pool format");
-		return NULL;
-	}
-
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
+	if (!(fid = alloc_fid(fmt, fic)))
+		return_NULL;
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c5db278..e5156f8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2190,21 +2190,13 @@ static int _text_pv_resize(const struct format_type *fmt,
 
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
-							   const struct format_instance_ctx *fic)
+							  const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
 	int r;
 
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
-		log_error("Couldn't allocate format instance object.");
-		return NULL;
-	}
-
-	fid->fmt = fmt;
-	fid->type = fic->type;
-
-	dm_list_init(&fid->metadata_areas_in_use);
-	dm_list_init(&fid->metadata_areas_ignored);
+	if (!(fid = alloc_fid(fmt, fic)))
+		return_NULL;
 
 	if (fid->type & FMT_INSTANCE_VG)
 		r = _create_vg_text_instance(fid, fic);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff61cbb..3cfbce6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3951,6 +3951,25 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 	return FAILED_EXIST;
 }
 
+struct format_instance *alloc_fid(const struct format_type *fmt,
+				  const struct format_instance_ctx *fic)
+{
+	struct format_instance *fid;
+
+	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
+		log_error("Couldn't allocate format_instance object.");
+		return NULL;
+	}
+
+	fid->fmt = fmt;
+	fid->type = fic->type;
+
+	dm_list_init(&fid->metadata_areas_in_use);
+	dm_list_init(&fid->metadata_areas_ignored);
+
+	return fid;
+}
+
 void vg_set_fid(struct volume_group *vg,
 		 struct format_instance *fid)
 {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1982711..8f0a6b1 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -191,6 +191,21 @@ struct metadata_area *mda_copy(struct dm_pool *mem,
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
+
+struct format_instance_ctx {
+	uint32_t type;
+	union {
+		const char *pv_id;
+		struct {
+			const char *vg_name;
+			const char *vg_id;
+		} vg_ref;
+		void *private;
+	} context;
+};
+
+struct format_instance *alloc_fid(const struct format_type *fmt,
+				  const struct format_instance_ctx *fic);
 void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
 /* FIXME: Add generic interface for mda counts based on given key. */
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
@@ -229,18 +244,6 @@ struct seg_list {
 	struct lv_segment *seg;
 };
 
-struct format_instance_ctx {
-	uint32_t type;
-	union {
-		const char *pv_id;
-		struct {
-			const char *vg_name;
-			const char *vg_id;
-		} vg_ref;
-		void *private;
-	} context;
-};
-
 /*
  * Ownership of objects passes to caller.
  */
-- 
1.7.4


