From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 14:57:58 -0500
Subject: master - device: Mark read-only device buffers const.
Message-ID: <201801101957.w0AJvwrw018247@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6210c1ec28b9b6859d3e4c30a4dd1928f5c5badc
Commit:        6210c1ec28b9b6859d3e4c30a4dd1928f5c5badc
Parent:        c350f96c09f3fb591de1742829006769f53c29eb
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 19:50:53 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 19:57:10 2018 +0000

device: Mark read-only device buffers const.

---
 lib/cache/lvmcache.c          |    4 ++--
 lib/cache/lvmcache.h          |    2 +-
 lib/config/config.c           |    8 ++++----
 lib/device/dev-io.c           |    4 ++--
 lib/device/device.h           |   10 +++++-----
 lib/format_text/format-text.c |   30 +++++++++++++++---------------
 lib/format_text/import.c      |    4 ++--
 lib/format_text/layout.h      |    2 +-
 lib/format_text/text_label.c  |    8 ++++----
 lib/label/label.c             |   10 +++++-----
 lib/label/label.h             |    2 +-
 11 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 017a86b..a24fd0a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1102,7 +1102,7 @@ next:
 }
 
 /* Track the number of outstanding label reads */
-static void _process_label_data(int failed, void *context, void *data)
+static void _process_label_data(int failed, void *context, const void *data)
 {
 	int *nr_labels_outstanding = context;
 
@@ -1996,7 +1996,7 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
-int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
+int lvmcache_update_vgname_and_id(struct lvmcache_info *info, const struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
 	const char *vgid = (char *)&vgsummary->vgid;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 847c208..3c76b78 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -85,7 +85,7 @@ void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
-				  struct lvmcache_vgsummary *vgsummary);
+				  const struct lvmcache_vgsummary *vgsummary);
 int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
diff --git a/lib/config/config.c b/lib/config/config.c
index 9dd8a61..668df26 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -506,10 +506,10 @@ struct process_config_file_params {
 	int ret;
 };
 
-static void _process_config_file_buffer(int failed, void *context, void *data)
+static void _process_config_file_buffer(int failed, void *context, const void *data)
 {
 	struct process_config_file_params *pcfp = context;
-	char *fb = data, *fe;
+	const char *fb = data, *fe;
 
 	if (failed) {
 		pcfp->ret = 0;
@@ -552,7 +552,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 	char *fb;
 	int r = 0;
 	off_t mmap_offset = 0;
-	char *buf = NULL;
+	const char *buf = NULL;
 	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
 	struct config_source *cs = dm_config_get_custom(cft);
 	struct process_config_file_params *pcfp;
@@ -609,7 +609,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
 				goto_out;
 			_process_config_file_buffer(0, pcfp, buf);
-			dm_free(buf);
+			dm_free((void *)buf);
 		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, _process_config_file_buffer, pcfp))
 			goto_out;
 		r = pcfp->ret;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9920ee5..f916761 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -834,7 +834,7 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 }
 
 /* Returns pointer to read-only buffer. Caller does not free it.  */
-char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
+const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
 	if (!_dev_read(dev, offset, len, reason)) {
 		log_error("Read from %s failed", dev_name(dev));
@@ -881,7 +881,7 @@ int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_
  * Read from 'dev' in 2 distinct regions, denoted by (offset,len) and (offset2,len2).
  * Caller is responsible for dm_free().
  */
-char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 			uint64_t offset2, size_t len2, dev_io_reason_t reason)
 {
 	char *buf = NULL;
diff --git a/lib/device/device.h b/lib/device/device.h
index cf44362..926d24a 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -37,7 +37,7 @@
  * When provided, callback functions are called exactly once.
  * If failed is set, data cannot be accessed.
  */
-typedef void (*lvm_callback_fn_t)(int failed, void *context, void *data);
+typedef void (*lvm_callback_fn_t)(int failed, void *context, const void *data);
 
 /*
  * Support for external device info.
@@ -63,7 +63,7 @@ struct device_area {
 };
 
 struct device_buffer {
-	void *data;             /* Location of start of requested data (inside buf) */
+	const void *data;             /* Location of start of requested data (inside buf) */
 
 	/* Private */
 	void *malloc_address;   /* Start of allocated memory */
@@ -171,9 +171,9 @@ int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
 /* Returns a read-only buffer */
-char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason);
-char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-			uint64_t offset2, size_t len2, dev_io_reason_t reason);
+const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason);
+const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+			      uint64_t offset2, size_t len2, dev_io_reason_t reason);
 
 /* Passes the data to dev_read_callback_fn */
 int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d28449c..866f65f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -182,7 +182,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	uint64_t offset2;
 	size_t size;
 	size_t size2;
-	char *buf = NULL;
+	const char *buf = NULL;
 	struct device_area *area;
 	struct mda_context *mdac;
 	unsigned circular = 0;
@@ -273,14 +273,14 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 			}
 		}
 		if (circular)
-			dm_free(buf);
+			dm_free((void *)buf);
 		buf = NULL;
 	}
 
 	r = 1;
  out:
 	if (circular)
-		dm_free(buf);
+		dm_free((void *)buf);
 	if (!dev_close(area->dev))
 		stack;
 	return r;
@@ -334,7 +334,7 @@ struct process_raw_mda_header_params {
 	int ret;
 };
 
-static void _process_raw_mda_header(int failed, void *context, void *data)
+static void _process_raw_mda_header(int failed, void *context, const void *data)
 {
 	struct process_raw_mda_header_params *prmp = context;
 	struct mda_header *mdah = prmp->mdah;
@@ -472,7 +472,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
 	};
 	int rlocn_was_ignored;
-	char *buf;
+	const char *buf;
 
 	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
@@ -1348,7 +1348,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 
 struct vgname_from_mda_params{
 	const struct format_type *fmt;
-	struct mda_header *mdah;
+	const struct mda_header *mdah;
 	struct device_area *dev_area;
 	int primary_mda;
 	struct lvmcache_vgsummary *vgsummary;
@@ -1360,14 +1360,14 @@ struct vgname_from_mda_params{
 	int ret;
 };
 
-static void _vgname_from_mda_process(int failed, void *context, void *data)
+static void _vgname_from_mda_process(int failed, void *context, const void *data)
 {
 	struct vgname_from_mda_params *vfmp = context;
-	struct mda_header *mdah = vfmp->mdah;
+	const struct mda_header *mdah = vfmp->mdah;
 	struct device_area *dev_area = vfmp->dev_area;
 	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
 	uint64_t *mda_free_sectors = vfmp->mda_free_sectors;
-	struct raw_locn *rlocn = mdah->raw_locns;
+	const struct raw_locn *rlocn = mdah->raw_locns;
 	uint64_t buffer_size, current_usage;
 
 	if (failed) {
@@ -1406,15 +1406,15 @@ out:
 		vfmp->update_vgsummary_fn(0, vfmp->update_vgsummary_context, vfmp->vgsummary);
 }
 
-static void _vgname_from_mda_validate(int failed, void *context, void *data)
+static void _vgname_from_mda_validate(int failed, void *context, const void *data)
 {
 	struct vgname_from_mda_params *vfmp = context;
-	char *buffer = data;
+	const char *buffer = data;
 	const struct format_type *fmt = vfmp->fmt;
-	struct mda_header *mdah = vfmp->mdah;
+	const struct mda_header *mdah = vfmp->mdah;
 	struct device_area *dev_area = vfmp->dev_area;
 	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
-	struct raw_locn *rlocn = mdah->raw_locns;
+	const struct raw_locn *rlocn = mdah->raw_locns;
 	unsigned len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 
@@ -1471,11 +1471,11 @@ out:
 }
 
 int vgname_from_mda(const struct format_type *fmt,
-		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
+		    const struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors,
 		    lvm_callback_fn_t update_vgsummary_fn, void *update_vgsummary_context)
 {
-	struct raw_locn *rlocn;
+	const struct raw_locn *rlocn;
 	struct vgname_from_mda_params *vfmp;
 
 	if (mda_free_sectors)
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index d6b72d4..a6310c9 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -43,7 +43,7 @@ struct import_vgsummary_params {
 	int ret;
 };
 
-static void _import_vgsummary(int failed, void *context, void *data)
+static void _import_vgsummary(int failed, void *context, const void *data)
 {
 	struct import_vgsummary_params *ivsp = context;
 	struct text_vg_version_ops **vsn;
@@ -150,7 +150,7 @@ struct import_vg_params {
 	char **desc;
 };
 
-static void _import_vg(int failed, void *context, void *data)
+static void _import_vg(int failed, void *context, const void *data)
 {
 	struct import_vg_params *ivp = context;
 	struct text_vg_version_ops **vsn;
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 986f779..f99a6f8 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -107,7 +107,7 @@ struct mda_context {
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
 #define MDA_ALIGNMENT 4096	/* Default alignment in bytes since 2.02.177 for start of VG metadata content. */
 
-int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
+int vgname_from_mda(const struct format_type *fmt, const struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
 		    uint64_t *mda_free_sectors,
 		    lvm_callback_fn_t update_vgsummary_callback_fn, void *update_vgsummary_callback_context);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index d0782a9..7f3b2d3 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -336,10 +336,10 @@ struct process_mda_header_params {
 	int ret;
 };
 
-static void _process_vgsummary(int failed, void *context, void *data)
+static void _process_vgsummary(int failed, void *context, const void *data)
 {
 	struct process_mda_header_params *pmp = context;
-	struct lvmcache_vgsummary *vgsummary = data;
+	const struct lvmcache_vgsummary *vgsummary = data;
 
 	--pmp->umb->nr_outstanding_mdas;
 
@@ -357,10 +357,10 @@ out:
 		stack;
 }
 
-static void _process_mda_header(int failed, void *context, void *data)
+static void _process_mda_header(int failed, void *context, const void *data)
 {
 	struct process_mda_header_params *pmp = context;
-	struct mda_header *mdah = data;
+	const struct mda_header *mdah = data;
 	struct update_mda_baton *umb = pmp->umb;
 	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct metadata_area *mda = pmp->mda;
diff --git a/lib/label/label.c b/lib/label/label.c
index afb3b19..27b72d3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -131,7 +131,7 @@ struct find_labeller_params {
 	int ret;
 };
 
-static void _set_label_read_result(int failed, void *context, void *data)
+static void _set_label_read_result(int failed, void *context, const void *data)
 {
 	struct find_labeller_params *flp = context;
 	struct label **result = flp->result;
@@ -154,17 +154,17 @@ out:
 		flp->process_label_data_fn(0, flp->process_label_data_context, NULL);
 }
 
-static void _find_labeller(int failed, void *context, void *data)
+static void _find_labeller(int failed, void *context, const void *data)
 {
 	struct find_labeller_params *flp = context;
-	char *readbuf = data;
+	const char *readbuf = data;
 	struct device *dev = flp->dev;
 	uint64_t scan_sector = flp->scan_sector;
 	struct label **result = flp->result;
 	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct labeller_i *li;
 	struct labeller *l = NULL;	/* Set when a labeller claims the label */
-	struct label_header *lh;
+	const struct label_header *lh;
 	struct lvmcache_info *info;
 	uint64_t sector;
 
@@ -246,7 +246,7 @@ int label_remove(struct device *dev)
 	struct labeller_i *li;
 	struct label_header *lh;
 	struct lvmcache_info *info;
-	char *readbuf = NULL;
+	const char *readbuf = NULL;
 
 	memset(labelbuf, 0, LABEL_SIZE);
 
diff --git a/lib/label/label.h b/lib/label/label.h
index 1f12294..7f365f2 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -97,7 +97,7 @@ int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
 int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_sector,
-	lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
+			lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);


