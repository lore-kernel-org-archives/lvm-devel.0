From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 9 Jan 2018 09:32:37 -0500
Subject: master - format_text: Use vgsummary callbacks
Message-ID: <201801091432.w09EWbNX031907@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4675af4cfbc0139ba94ec3f18b15c09bf106a61
Commit:        f4675af4cfbc0139ba94ec3f18b15c09bf106a61
Parent:        4b02d4e22eeb0dbf61e2c93f3803fbbaeffb0291
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 9 01:50:23 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 9 03:14:30 2018 +0000

format_text: Use vgsummary callbacks

---
 lib/device/dev-cache.h          |    2 +-
 lib/format1/lvm1-label.c        |    4 ++--
 lib/format_text/format-text.c   |   38 +++++++++++++++++++++++++-------------
 lib/format_text/import-export.h |    4 +++-
 lib/format_text/import.c        |   11 ++++++++++-
 lib/format_text/layout.h        |    3 ++-
 lib/format_text/text_label.c    |   23 +++++++++++------------
 lib/label/label.c               |    2 +-
 8 files changed, 55 insertions(+), 32 deletions(-)

diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 0143dfa..5603553 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -23,7 +23,7 @@
  * predicate for devices.
  */
 struct dev_filter {
-	int (*passes_filter) (struct dev_filter *f, struct device * dev);
+	int (*passes_filter) (struct dev_filter *f, struct device *dev);
 	void (*destroy) (struct dev_filter *f);
 	void (*wipe) (struct dev_filter *f);
 	int (*dump) (struct dev_filter *f, struct dm_pool *mem, int merge_existing);
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 6a2ec49..84d6f4e 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -91,8 +91,8 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, struct
 	r = 1;
 
 out:
-        if (read_label_callback_fn)
-                read_label_callback_fn(!r, read_label_callback_context, NULL);
+	if (read_label_callback_fn)
+		read_label_callback_fn(!r, read_label_callback_context, NULL);
 
 	return r;
 }
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c2d6294..7e80a11 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1360,6 +1360,8 @@ struct vgname_from_mda_params{
 	int primary_mda;
 	struct lvmcache_vgsummary *vgsummary;
 	uint64_t *mda_free_sectors;
+	lvm_callback_fn_t update_vgsummary_fn;
+	void *update_vgsummary_context;
 	uint32_t wrap;
 	unsigned used_cached_metadata;
 	int ret;
@@ -1375,6 +1377,11 @@ static void _vgname_from_mda_process(int failed, void *context, void *data)
 	struct raw_locn *rlocn = mdah->raw_locns;
 	uint64_t buffer_size, current_usage;
 
+	if (failed) {
+		vfmp->ret = 0;
+		goto_out;
+	}
+
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(vgsummary->vgname)) {
 		vfmp->ret = 0;
@@ -1402,7 +1409,8 @@ static void _vgname_from_mda_process(int failed, void *context, void *data)
 	}
 
 out:
-	;
+	if (vfmp->ret)
+		vfmp->update_vgsummary_fn(0, vfmp->update_vgsummary_context, vfmp->vgsummary);
 }
 
 static void _vgname_from_mda_validate(int failed, void *context, void *data)
@@ -1417,7 +1425,12 @@ static void _vgname_from_mda_validate(int failed, void *context, void *data)
 	unsigned len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 
-	memcpy(buf, buffer, NAME_LEN + 1);
+	if (failed) {
+		vfmp->ret = 0;
+		goto_out;
+	}
+
+	memcpy(buf, buffer, NAME_LEN);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1455,23 +1468,22 @@ static void _vgname_from_mda_validate(int failed, void *context, void *data)
 				(uint32_t) (rlocn->size - vfmp->wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
 				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0,
-				vgsummary)) {
+				vgsummary, _vgname_from_mda_process, vfmp)) {
 		vfmp->ret = 0;
 		goto_out;
 	}
 
-	_vgname_from_mda_process(0, vfmp, NULL);
-
 out:
-	;
+	if (!failed)
+		dm_free(data);
 }
 
 int vgname_from_mda(const struct format_type *fmt,
 		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
-		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
+		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors,
+		    lvm_callback_fn_t update_vgsummary_fn, void *update_vgsummary_context)
 {
 	struct raw_locn *rlocn;
-	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 	struct vgname_from_mda_params *vfmp;
 
 	if (mda_free_sectors)
@@ -1505,16 +1517,16 @@ int vgname_from_mda(const struct format_type *fmt,
 	vfmp->vgsummary = vgsummary;
 	vfmp->primary_mda = primary_mda;
 	vfmp->mda_free_sectors = mda_free_sectors;
+	vfmp->update_vgsummary_fn = update_vgsummary_fn;
+	vfmp->update_vgsummary_context = update_vgsummary_context;
 	vfmp->ret = 1;
 
 	/* Do quick check for a vgname */
 	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
-	if (!dev_read_buf(dev_area->dev, dev_area->start + rlocn->offset,
-			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
+	if (!dev_read_callback(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, MDA_CONTENT_REASON(primary_mda),
+			       _vgname_from_mda_validate, vfmp))
 		return_0;
 
-	_vgname_from_mda_validate(0, vfmp, buf);
-
 	return vfmp->ret;
 }
 
@@ -1546,7 +1558,7 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 		}
 
 		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
+		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL, NULL, NULL)) {
 			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 894d881..da6d2ab 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -89,6 +89,8 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
 		       int checksum_only,
-		       struct lvmcache_vgsummary *vgsummary);
+		       struct lvmcache_vgsummary *vgsummary,
+		       lvm_callback_fn_t process_vgsummary_fn,
+		       void *process_vgsummary_context);
 
 #endif
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index a295b78..d6b72d4 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -38,6 +38,8 @@ struct import_vgsummary_params {
 	struct dm_config_tree *cft;
 	int checksum_only;
 	struct lvmcache_vgsummary *vgsummary;
+	lvm_callback_fn_t process_vgsummary_fn;
+	void *process_vgsummary_context;
 	int ret;
 };
 
@@ -75,6 +77,9 @@ static void _import_vgsummary(int failed, void *context, void *data)
 
 out:
 	config_destroy(ivsp->cft);
+
+	if (ivsp->ret && ivsp->process_vgsummary_fn)
+		ivsp->process_vgsummary_fn(0, ivsp->process_vgsummary_context, NULL);
 }
 
 /*
@@ -86,7 +91,9 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
 		       int checksum_only,
-		       struct lvmcache_vgsummary *vgsummary)
+		       struct lvmcache_vgsummary *vgsummary,
+		       lvm_callback_fn_t process_vgsummary_fn,
+		       void *process_vgsummary_context)
 {
 	struct import_vgsummary_params *ivsp;
 
@@ -103,6 +110,8 @@ int text_vgsummary_import(const struct format_type *fmt,
 	ivsp->fmt = fmt;
 	ivsp->checksum_only = checksum_only;
 	ivsp->vgsummary = vgsummary;
+	ivsp->process_vgsummary_fn = process_vgsummary_fn;
+	ivsp->process_vgsummary_context = process_vgsummary_context;
 	ivsp->ret = 1;
 
 	if (!dev) {
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 3320b0c..986f779 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -109,6 +109,7 @@ struct mda_context {
 
 int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
-		    uint64_t *mda_free_sectors);
+		    uint64_t *mda_free_sectors,
+		    lvm_callback_fn_t update_vgsummary_callback_fn, void *update_vgsummary_callback_context);
 
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 60ce5db..d0782a9 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -343,6 +343,9 @@ static void _process_vgsummary(int failed, void *context, void *data)
 
 	--pmp->umb->nr_outstanding_mdas;
 
+	if (failed)
+		goto_out;
+
 	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
 		pmp->umb->ret = 0;
 		pmp->ret = 0;
@@ -372,23 +375,19 @@ static void _process_mda_header(int failed, void *context, void *data)
 		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
 				   dev_name(mdac->area.dev),
 				   mdac->area.start);
-		--pmp->umb->nr_outstanding_mdas;
-		if (!dev_close(pmp->dev))
-			stack;
-		return;
+		goto bad;
 	}
 
-	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary,
-			     &mdac->free_sectors)) {
+	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary, &mdac->free_sectors, _process_vgsummary, pmp)) {
 		/* FIXME Separate fatal and non-fatal error cases? */
-		stack;
-		--pmp->umb->nr_outstanding_mdas;
-		if (!dev_close(pmp->dev))
-			stack;
-		return;
+		goto_bad;
 	}
 
-	_process_vgsummary(0, pmp, &pmp->vgsummary);
+	return;
+
+bad:
+	_process_vgsummary(1, pmp, NULL);
+	return;
 }
 
 static int _update_mda(struct metadata_area *mda, void *baton)
diff --git a/lib/label/label.c b/lib/label/label.c
index b116ea6..3a5c9fc 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -374,7 +374,7 @@ int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_s
 {
 	struct label **result;	/* FIXME Eliminate this */
 
-	if (!(result = dm_zalloc(sizeof(*result)))) {
+	if (!(result = dm_pool_zalloc(mem, sizeof(*result)))) {
 		log_error("Couldn't allocate memory for internal result pointer.");
 		return 0;
 	}


