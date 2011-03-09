From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:33 +0100
Subject: [PATCH 1/7] Add memory pool and reference counting for format instances.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-2-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Format instances can be created anytime on demand and it contains
metadata area information mostly (at least for now, but in the future,
we may store more things here to update/edit in a PV/VG). In case we
have lots of metadata areas, memory consumption will rise. Using cmd
context mempool is not quite optimal here because it is destroyed too
late.
So let's use a separate mempool for format instances.

Also, we need to destroy the hash which does not use a mempool in
destroy_instance fn. This call was not used explicitly before, but now
it has to be (and I can't free any cmd mempool allocations for format
instance since there could be other non-format-instance allocations
throughout the code and I'm not able to track those at all, so I can't
simply call dm_pool_free for the various fid allocations).

This change will definitely make it much easier to maintain the memory
allocations within the fid....

Reference counting is used because fids could be shared, e.g. each PV
has either a PV-based fid or VG-based fid. If it's VG-based, each PV has
a shared fid with the VG - a reference to VG's fid.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format1/format1.c            |   12 ++++++++++--
 lib/format_pool/format_pool.c    |   10 ++++++++--
 lib/format_text/format-text.c    |   24 +++++++++++-------------
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/metadata.c          |   14 ++++++++++++--
 5 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 8550a1e..a024d99 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -535,8 +535,10 @@ static struct format_instance *_format1_create_instance(const struct format_type
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
+		log_error("Unable to allocate metadata area structure "
+			  "for lvm1 format");
 		dm_pool_free(fmt->cmd->mem, fid);
-		return_NULL;
+		goto bad;
 	}
 
 	mda->ops = &_metadata_format1_ops;
@@ -545,10 +547,16 @@ static struct format_instance *_format1_create_instance(const struct format_type
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
-static void _format1_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _format1_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1)
+		dm_pool_destroy(fid->mem);
 }
 
 static void _format1_destroy(struct format_type *fmt)
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 482d79a..24c21c2 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -264,7 +264,7 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 		log_error("Unable to allocate metadata area structure "
 			  "for pool format");
 		dm_pool_free(fmt->cmd->mem, fid);
-		return NULL;
+		goto bad;
 	}
 
 	mda->ops = &_metadata_format_pool_ops;
@@ -273,10 +273,16 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
-static void _pool_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _pool_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1)
+		dm_pool_destroy(fid->mem);
 }
 
 static void _pool_destroy(struct format_type *fmt)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e5156f8..2a2f0ed 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1571,8 +1571,13 @@ static int _text_pv_initialise(const struct format_type *fmt,
 	return 1;
 }
 
-static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
+static void _text_destroy_instance(struct format_instance *fid)
 {
+	if (--fid->ref_count <= 1) {
+		if (fid->type & FMT_INSTANCE_VG && fid->metadata_areas_index.hash)
+			dm_hash_destroy(fid->metadata_areas_index.hash);
+		dm_pool_destroy(fid->mem);
+	}
 }
 
 static void _free_dirs(struct dm_list *dir_list)
@@ -2188,28 +2193,21 @@ static int _text_pv_resize(const struct format_type *fmt,
 	return 1;
 }
 
-/* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							  const struct format_instance_ctx *fic)
 {
 	struct format_instance *fid;
-	int r;
 
 	if (!(fid = alloc_fid(fmt, fic)))
 		return_NULL;
 
-	if (fid->type & FMT_INSTANCE_VG)
-		r = _create_vg_text_instance(fid, fic);
-	else
-		r = _create_pv_text_instance(fid, fic);
-
-	if (r)
+	if (fid->type & FMT_INSTANCE_VG ? _create_vg_text_instance(fid, fic) :
+					  _create_pv_text_instance(fid, fic))
 		return fid;
-	else {
-		dm_pool_free(fmt->cmd->mem, fid);
-		return NULL;
-	}
 
+	dm_pool_free(fmt->cmd->mem, fid);
+	dm_pool_destroy(fid->mem);
+	return NULL;
 }
 
 void *create_text_context(struct cmd_context *cmd, const char *path,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d1794c2..4bdf40c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -196,6 +196,9 @@ struct pv_segment {
 #define FMT_INSTANCE_PRIVATE_MDAS 	0x00000008U
 
 struct format_instance {
+	unsigned ref_count;
+	struct dm_pool *mem;
+
 	uint32_t type;
 	const struct format_type *fmt;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5d84a35..5fba636 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3954,20 +3954,30 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic)
 {
+	struct dm_pool *mem;
 	struct format_instance *fid;
 
+	if (!(mem = dm_pool_create("format_instance", 1024)))
+		return_NULL;
+
 	if (!(fid = dm_pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
 		log_error("Couldn't allocate format_instance object.");
-		return NULL;
+		goto bad;
 	}
 
-	fid->fmt = fmt;
+	fid->ref_count = 1;
+	fid->mem = mem;
 	fid->type = fic->type;
+	fid->fmt = fmt;
 
 	dm_list_init(&fid->metadata_areas_in_use);
 	dm_list_init(&fid->metadata_areas_ignored);
 
 	return fid;
+
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 void vg_set_fid(struct volume_group *vg,
-- 
1.7.4


