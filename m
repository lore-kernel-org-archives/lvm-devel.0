From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 16:23:21 -0500
Subject: master - config: Split config buffer processing into new fn.
Message-ID: <201801022123.w02LNLaG013571@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22b6c482ecb4673c30aa1e9ae1946f9fc5497510
Commit:        22b6c482ecb4673c30aa1e9ae1946f9fc5497510
Parent:        96801ac0859798c4e478d05e91aaa68b4ce10c91
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 20:40:18 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 21:10:46 2018 +0000

config: Split config buffer processing into new fn.

Wrap its parameters into struct process_config_file_params allocated
from a mempool now passed into the config_file_read* fns.
---
 lib/cache/lvmcache.c            |    2 +-
 lib/commands/toolcontext.c      |    4 +-
 lib/config/config.c             |   90 ++++++++++++++++++++++++++++----------
 lib/config/config.h             |    4 +-
 lib/device/dev-cache.h          |    8 ++--
 lib/filters/filter-composite.c  |    4 +-
 lib/filters/filter-persistent.c |    8 ++--
 lib/filters/filter.h            |    2 +-
 lib/format_text/import.c        |    9 ++--
 9 files changed, 87 insertions(+), 44 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 5d4732c..25bf7ee 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1204,7 +1204,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 */
 	if (_force_label_scan && cmd->is_long_lived &&
 	    cmd->dump_filter && cmd->full_filter && cmd->full_filter->dump &&
-	    !cmd->full_filter->dump(cmd->full_filter, 0))
+	    !cmd->full_filter->dump(cmd->full_filter, cmd->mem, 0))
 		stack;
 
 	r = 1;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1d21443..eda412e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1287,7 +1287,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 		lvm_stat_ctim(&ts, &st);
 		cts = config_file_timestamp(cmd->cft);
 		if (timespeccmp(&ts, &cts, >) &&
-		    !persistent_filter_load(cmd->filter, NULL))
+		    !persistent_filter_load(cmd->mem, cmd->filter, NULL))
 			log_verbose("Failed to load existing device cache from %s",
 				    dev_cache);
 	}
@@ -2225,7 +2225,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	int flags;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
-	    !cmd->filter->dump(cmd->filter, 1))
+	    !cmd->filter->dump(cmd->filter, cmd->mem, 1))
 		stack;
 
 	archive_exit(cmd);
diff --git a/lib/config/config.c b/lib/config/config.c
index bbbcc3d..bb1d80e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -279,7 +279,7 @@ struct dm_config_tree *config_file_open_and_read(const char *config_file,
 	}
 
 	log_very_verbose("Loading config file: %s", config_file);
-	if (!config_file_read(cft)) {
+	if (!config_file_read(cmd->mem, cft)) {
 		log_error("Failed to load config file %s", config_file);
 		goto bad;
 	}
@@ -489,23 +489,67 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 	return 0;
 }
 
+struct process_config_file_params {
+	struct dm_config_tree *cft;
+	struct device *dev;
+	off_t offset;
+	size_t size;
+	off_t offset2;
+	size_t size2;
+	checksum_fn_t checksum_fn;
+	uint32_t checksum;
+	int checksum_only;
+	int no_dup_node_check;
+};
+
+static int _process_config_file_buffer(struct process_config_file_params *pcfp, char *buffer)
+{
+	char *fb, *fe;
+	int r = 0;
+
+	fb = buffer;
+
+	if (pcfp->checksum_fn && pcfp->checksum !=
+	    (pcfp->checksum_fn(pcfp->checksum_fn(INITIAL_CRC, (const uint8_t *)fb, pcfp->size),
+			 (const uint8_t *)(fb + pcfp->size), pcfp->size2))) {
+		log_error("%s: Checksum error at offset %" PRIu64, dev_name(pcfp->dev), (uint64_t) pcfp->offset);
+		goto out;
+	}
+
+	if (!pcfp->checksum_only) {
+		fe = fb + pcfp->size + pcfp->size2;
+		if (pcfp->no_dup_node_check) {
+			if (!dm_config_parse_without_dup_node_check(pcfp->cft, fb, fe))
+				goto_out;
+		} else {
+			if (!dm_config_parse(pcfp->cft, fb, fe))
+				goto_out;
+		}
+	}
+
+	r = 1;
+out:
+	return r;
+}
+
 /*
  * When checksum_only is set, the checksum of buffer is only matched
  * and function avoids parsing of mda into config tree which
  * remains unmodified and should not be used.
  */
-int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
+int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
 			int checksum_only, int no_dup_node_check)
 {
-	char *fb, *fe;
+	char *fb;
 	int r = 0;
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
 	char *buf = NULL;
 	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
 	struct config_source *cs = dm_config_get_custom(cft);
+	struct process_config_file_params *pcfp;
 
 	if (!_is_file_based_config_source(cs->type)) {
 		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
@@ -514,6 +558,22 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		return 0;
 	}
 
+	if (!(pcfp = dm_pool_zalloc(mem, sizeof(*pcfp)))) {
+		log_debug("config_file_read_fd: process_config_file_params struct allocation failed");
+		return 0;
+	}
+
+	pcfp->cft = cft;
+	pcfp->dev = dev;
+	pcfp->offset = offset;
+	pcfp->size = size;
+	pcfp->offset2 = offset2;
+	pcfp->size2 = size2;
+	pcfp->checksum_fn = checksum_fn;
+	pcfp->checksum = checksum;
+	pcfp->checksum_only = checksum_only;
+	pcfp->no_dup_node_check = no_dup_node_check;
+
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || circular)
 		use_mmap = 0;
@@ -539,25 +599,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		fb = buf;
 	}
 
-	if (checksum_fn && checksum !=
-	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
-			 (const uint8_t *)(fb + size), size2))) {
-		log_error("%s: Checksum error at offset %" PRIu64, dev_name(dev), (uint64_t) offset);
-		goto out;
-	}
-
-	if (!checksum_only) {
-		fe = fb + size + size2;
-		if (no_dup_node_check) {
-			if (!dm_config_parse_without_dup_node_check(cft, fb, fe))
-				goto_out;
-		} else {
-			if (!dm_config_parse(cft, fb, fe))
-				goto_out;
-		}
-	}
-
-	r = 1;
+	r = _process_config_file_buffer(pcfp, fb);
 
       out:
 	if (!use_mmap)
@@ -573,7 +615,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	return r;
 }
 
-int config_file_read(struct dm_config_tree *cft)
+int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
 {
 	const char *filename = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
@@ -601,7 +643,7 @@ int config_file_read(struct dm_config_tree *cft)
 		}
 	}
 
-	r = config_file_read_fd(cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
+	r = config_file_read_fd(mem, cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
 				(checksum_fn_t) NULL, 0, 0, 0);
 
 	if (!cf->keep_open) {
diff --git a/lib/config/config.h b/lib/config/config.h
index d01306b..5c8844a 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -239,11 +239,11 @@ config_source_t config_get_source_type(struct dm_config_tree *cft);
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
 struct dm_config_tree *config_open(config_source_t source, const char *filename, int keep_open);
-int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
+int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
 			int skip_parse, int no_dup_node_check);
-int config_file_read(struct dm_config_tree *cft);
+int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
 						 struct cmd_context *cmd);
 int config_write(struct dm_config_tree *cft, struct config_def_tree_spec *tree_spec,
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 546b1fe..0143dfa 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -23,10 +23,10 @@
  * predicate for devices.
  */
 struct dev_filter {
-	int (*passes_filter) (struct dev_filter * f, struct device * dev);
-	void (*destroy) (struct dev_filter * f);
-	void (*wipe) (struct dev_filter * f);
-	int (*dump) (struct dev_filter * f, int merge_existing);
+	int (*passes_filter) (struct dev_filter *f, struct device * dev);
+	void (*destroy) (struct dev_filter *f);
+	void (*wipe) (struct dev_filter *f);
+	int (*dump) (struct dev_filter *f, struct dm_pool *mem, int merge_existing);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index c635896..83a0f02 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -52,13 +52,13 @@ static void _composite_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-static int _dump(struct dev_filter *f, int merge_existing)
+static int _dump(struct dev_filter *f, struct dm_pool *mem, int merge_existing)
 {
 	struct dev_filter **filters;
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		if ((*filters)->dump &&
-		    !(*filters)->dump(*filters, merge_existing))
+		    !(*filters)->dump(*filters, mem, merge_existing))
 			return_0;
 
 	return 1;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 5bc0861..7542e02 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -87,7 +87,7 @@ static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
 	return 1;
 }
 
-int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out)
+int persistent_filter_load(struct dm_pool *mem, struct dev_filter *f, struct dm_config_tree **cft_out)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	struct dm_config_tree *cft;
@@ -116,7 +116,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, pf->file, 1)))
 		return_0;
 
-	if (!config_file_read(cft))
+	if (!config_file_read(mem, cft))
 		goto_out;
 
 	log_debug_devs("Loading persistent filter cache from %s", pf->file);
@@ -175,7 +175,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 		fprintf(fp, "\n\t]\n");
 }
 
-static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
+static int _persistent_filter_dump(struct dev_filter *f, struct dm_pool *mem, int merge_existing)
 {
 	struct pfilter *pf;
 	char *tmp_file;
@@ -234,7 +234,7 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 	lvm_stat_ctim(&ts, &info);
 	if (merge_existing && timespeccmp(&ts, &pf->ctime, !=))
 		/* Keep cft open to avoid losing lock */
-		persistent_filter_load(f, &cft);
+		persistent_filter_load(mem, f, &cft);
 
 	tmp_file = alloca(strlen(pf->file) + 5);
 	sprintf(tmp_file, "%s.tmp", pf->file);
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index d75f6e1..5dbf0b4 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -53,6 +53,6 @@ typedef enum {
 } filter_mode_t;
 struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
 
-int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
+int persistent_filter_load(struct dm_pool *mem, struct dev_filter *f, struct dm_config_tree **cft_out);
 
 #endif 	/* _LVM_FILTER_H */
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index da4cefd..039722a 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "metadata.h"
 #include "import-export.h"
+#include "toolcontext.h"
 
 /* FIXME Use tidier inclusion method */
 static struct text_vg_version_ops *(_text_vsn_list[2]);
@@ -52,8 +53,8 @@ int text_vgsummary_import(const struct format_type *fmt,
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
 		return_0;
 
-	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, reason, offset, size,
+	if ((!dev && !config_file_read(fmt->cmd->mem, cft)) ||
+	    (dev && !config_file_read_fd(fmt->cmd->mem, cft, dev, reason, offset, size,
 					 offset2, size2, checksum_fn,
 					 vgsummary->mda_checksum,
 					 checksum_only, 1))) {
@@ -127,8 +128,8 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		     ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
 		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
 
-	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
+	if ((!dev && !config_file_read(fid->mem, cft)) ||
+	    (dev && !config_file_read_fd(fid->mem, cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					 offset2, size2, checksum_fn, checksum,
 					 skip_parse, 1)))
 		goto_out;


