From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Dec 2011 21:56:05 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-common.c ...
Message-ID: <20111218215605.12707.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-18 21:56:04

Modified files:
	libdm          : libdevmapper.h libdm-common.c libdm-config.c 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c config.h 
	lib/filters    : filter-persistent.c 
	lib/format_text: import.c 

Log message:
	Make a cleaner split between config tree and config file functionality. Move
	the latter out of libdm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/libdm/libdevmapper.h	2011/12/11 23:18:20	1.170
+++ LVM2/libdm/libdevmapper.h	2011/12/18 21:56:03	1.171
@@ -1321,16 +1321,15 @@
 struct dm_config_tree {
 	struct dm_config_node *root;
 	struct dm_config_tree *cascade;
+	struct dm_pool *mem;
+	void *custom;
 };
 
-struct dm_config_tree *dm_config_create(const char *filename, int keep_open);
+struct dm_config_tree *dm_config_create(void);
 struct dm_config_tree *dm_config_from_string(const char *config_settings);
 int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end);
 
 void *dm_config_get_custom(struct dm_config_tree *cft);
-int dm_config_check_file(struct dm_config_tree *cft, const char **filename, struct stat *info);
-int dm_config_keep_open(struct dm_config_tree *ctf);
-
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom);
 
 /*
@@ -1349,9 +1348,6 @@
 typedef int (*dm_putline_fn)(const char *line, void *baton);
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
 
-time_t dm_config_timestamp(struct dm_config_tree *cft);
-int dm_config_changed(struct dm_config_tree *cft);
-
 struct dm_config_node *dm_config_find_node(struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
--- LVM2/libdm/libdm-common.c	2011/11/18 19:34:03	1.128
+++ LVM2/libdm/libdm-common.c	2011/12/18 21:56:03	1.129
@@ -900,7 +900,7 @@
 				break; /* no other DEL ops */
 			}
 		}
-	else if ((type == NODE_RENAME))
+	else if (type == NODE_RENAME)
 		/*
 		 * Ignore any outstanding operations if renaming it.
 		 *
--- LVM2/libdm/libdm-config.c	2011/12/11 23:18:20	1.17
+++ LVM2/libdm/libdm-config.c	2011/12/18 21:56:03	1.18
@@ -50,17 +50,6 @@
 	struct dm_pool *mem;
 };
 
-struct cs {
-	struct dm_config_tree cft;
-	struct dm_pool *mem;
-	time_t timestamp;
-	off_t st_size;
-	char *filename;
-	int exists;
-	int keep_open; // FIXME AGK Remove this before release
-	void *custom; /* LVM uses this for a device pointer */
-};
-
 struct output_line {
 	struct dm_pool *mem;
 	dm_putline_fn putline;
@@ -100,12 +89,9 @@
 	return !(*str || (b != e));
 }
 
-/*
- * public interface
- */
-struct dm_config_tree *dm_config_create(const char *filename, int keep_open)
+struct dm_config_tree *dm_config_create()
 {
-	struct cs *c;
+	struct dm_config_tree *cft;
 	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);
 
 	if (!mem) {
@@ -113,54 +99,31 @@
 		return 0;
 	}
 
-	if (!(c = dm_pool_zalloc(mem, sizeof(*c)))) {
+	if (!(cft = dm_pool_zalloc(mem, sizeof(*cft)))) {
 		log_error("Failed to allocate config tree.");
 		dm_pool_destroy(mem);
 		return 0;
 	}
-
-	c->mem = mem;
-	c->cft.root = (struct dm_config_node *) NULL;
-	c->cft.cascade = NULL;
-	c->timestamp = 0;
-	c->exists = 0;
-	c->keep_open = keep_open;
-	c->custom = NULL;
-	if (filename &&
-	    !(c->filename = dm_pool_strdup(c->mem, filename))) {
-		log_error("Failed to duplicate filename.");
-		dm_pool_destroy(mem);
-		return 0;
-	}
-
-	return &c->cft;
+	cft->root = NULL;
+	cft->cascade = NULL;
+	cft->custom = NULL;
+	cft->mem = mem;
+	return cft;
 }
 
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom)
 {
-	struct cs *c = (struct cs *) cft;
-
-	c->custom = custom;
+	cft->custom = custom;
 }
 
 void *dm_config_get_custom(struct dm_config_tree *cft)
 {
-	struct cs *c = (struct cs *) cft;
-
-	return c->custom;
-}
-
-int dm_config_keep_open(struct dm_config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-
-	return c->keep_open;
+	return cft->custom;
 }
 
 void dm_config_destroy(struct dm_config_tree *cft)
 {
-	struct cs *c = (struct cs *) cft;
-	dm_pool_destroy(c->mem);
+	dm_pool_destroy(cft->mem);
 }
 
 /*
@@ -194,12 +157,11 @@
 {
 	/* TODO? if (start == end) return 1; */
 
-	struct cs *c = (struct cs *) cft;
 	struct parser *p;
-	if (!(p = dm_pool_alloc(c->mem, sizeof(*p))))
+	if (!(p = dm_pool_alloc(cft->mem, sizeof(*p))))
 		return_0;
 
-	p->mem = c->mem;
+	p->mem = cft->mem;
 	p->fb = start;
 	p->fe = end;
 	p->tb = p->te = p->fb;
@@ -216,7 +178,7 @@
 {
 	struct dm_config_tree *cft;
 
-	if (!(cft = dm_config_create(NULL, 0)))
+	if (!(cft = dm_config_create()))
 		return_NULL;
 
 	if (!dm_config_parse(cft, config_settings, config_settings + strlen(config_settings))) {
@@ -227,88 +189,6 @@
 	return cft;
 }
 
-/*
- * Doesn't populate filename if the file is empty.
- */
-int dm_config_check_file(struct dm_config_tree *cft, const char **filename, struct stat *info)
-{
-	struct cs *c = (struct cs *) cft;
-	struct stat _info;
-
-	if (!info)
-		info = &_info;
-
-	if (stat(c->filename, info)) {
-		log_sys_error("stat", c->filename);
-		c->exists = 0;
-		return 0;
-	}
-
-	if (!S_ISREG(info->st_mode)) {
-		log_error("%s is not a regular file", c->filename);
-		c->exists = 0;
-		return 0;
-	}
-
-	c->exists = 1;
-	c->timestamp = info->st_ctime;
-	c->st_size = info->st_size;
-
-	if (info->st_size == 0)
-		log_verbose("%s is empty", c->filename);
-	else if (filename)
-		*filename = c->filename;
-
-	return 1;
-}
-
-time_t dm_config_timestamp(struct dm_config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-
-	return c->timestamp;
-}
-
-/*
- * Return 1 if config files ought to be reloaded
- */
-int dm_config_changed(struct dm_config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-	struct stat info;
-
-	if (!c->filename)
-		return 0;
-
-	if (stat(c->filename, &info) == -1) {
-		/* Ignore a deleted config file: still use original data */
-		if (errno == ENOENT) {
-			if (!c->exists)
-				return 0;
-			log_very_verbose("Config file %s has disappeared!",
-					 c->filename);
-			goto reload;
-		}
-		log_sys_error("stat", c->filename);
-		log_error("Failed to reload configuration files");
-		return 0;
-	}
-
-	if (!S_ISREG(info.st_mode)) {
-		log_error("Configuration file %s is not a regular file",
-			  c->filename);
-		goto reload;
-	}
-
-	/* Unchanged? */
-	if (c->timestamp == info.st_ctime && c->st_size == info.st_size)
-		return 0;
-
-      reload:
-	log_verbose("Detected config file change to %s", c->filename);
-	return 1;
-}
-
 static int _line_start(struct output_line *outline)
 {
 	if (!dm_pool_begin_object(outline->mem, 128)) {
@@ -1242,24 +1122,22 @@
 
 struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft, const struct dm_config_node *node, int sib)
 {
-	struct cs *c = (struct cs *) cft;
-	return dm_config_clone_node_with_mem(c->mem, node, sib);
+	return dm_config_clone_node_with_mem(cft->mem, node, sib);
 }
 
 struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const char *key)
 {
-	struct cs *c = (struct cs *) cft;
 	struct dm_config_node *cn;
 
-	if (!(cn = _create_node(c->mem))) {
+	if (!(cn = _create_node(cft->mem))) {
 		log_error("Failed to create config node.");
 		return NULL;
 	}
-	if (!(cn->key = dm_pool_strdup(c->mem, key))) {
+	if (!(cn->key = dm_pool_strdup(cft->mem, key))) {
 		log_error("Failed to create config node's key.");
 		return NULL;
 	}
-	if (!(cn->v = _create_value(c->mem))) {
+	if (!(cn->v = _create_value(cft->mem))) {
 		log_error("Failed to create config node's value.");
 		return NULL;
 	}
@@ -1272,12 +1150,10 @@
 
 struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft)
 {
-	struct cs *c = (struct cs *) cft;
-	return _create_value(c->mem);
+	return _create_value(cft->mem);
 }
 
 struct dm_pool *dm_config_memory(struct dm_config_tree *cft)
 {
-	struct cs *c = (struct cs *) cft;
-	return c->mem;
+	return cft->mem;
 }
--- LVM2/lib/cache/lvmcache.c	2011/12/08 23:18:00	1.120
+++ LVM2/lib/cache/lvmcache.c	2011/12/18 21:56:03	1.121
@@ -85,7 +85,7 @@
 
 	/* Release also cached config tree */
 	if (vginfo->cft) {
-		destroy_config_tree(vginfo->cft);
+		dm_config_destroy(vginfo->cft);
 		vginfo->cft = NULL;
 	}
 
--- LVM2/lib/commands/toolcontext.c	2011/12/08 21:24:09	1.143
+++ LVM2/lib/commands/toolcontext.c	2011/12/18 21:56:03	1.144
@@ -500,7 +500,7 @@
 		return 0;
 	}
 
-	if (!(cfl->cft = dm_config_create(config_file, 0))) {
+	if (!(cfl->cft = config_file_open(config_file, 0))) {
 		log_error("config_tree allocation failed");
 		return 0;
 	}
@@ -512,14 +512,14 @@
 			goto out;
 		}
 		log_sys_error("stat", config_file);
-		destroy_config_tree(cfl->cft);
+		config_file_destroy(cfl->cft);
 		return 0;
 	}
 
 	log_very_verbose("Loading config file: %s", config_file);
-	if (!read_config_file(cfl->cft)) {
+	if (!config_file_read(cfl->cft)) {
 		log_error("Failed to load config file %s", config_file);
-		destroy_config_tree(cfl->cft);
+		config_file_destroy(cfl->cft);
 		return 0;
 	}
 
@@ -540,7 +540,7 @@
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
 	if (!*cmd->system_dir) {
-		if (!(cmd->cft = dm_config_create(NULL, 0))) {
+		if (!(cmd->cft = config_file_open(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -573,7 +573,7 @@
 
 	/* Replace temporary duplicate copy of lvm.conf */
 	if (cft->root) {
-		if (!(cft = dm_config_create(NULL, 0))) {
+		if (!(cft = config_file_open(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -602,7 +602,7 @@
 	struct config_tree_list *cfl;
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
-		if (dm_config_changed(cfl->cft))
+		if (config_file_changed(cfl->cft))
 			return 1;
 	}
 
@@ -627,11 +627,11 @@
 	dm_list_iterate_items(cfl, &cmd->config_files) {
 		if (cfl->cft == cmd->cft)
 			cmd->cft = NULL;
-		destroy_config_tree(cfl->cft);
+		config_file_destroy(cfl->cft);
 	}
 
 	if (cmd->cft) {
-		destroy_config_tree(cmd->cft);
+		config_file_destroy(cmd->cft);
 		cmd->cft = NULL;
 	}
 
@@ -852,7 +852,7 @@
 	 */
 	if (load_persistent_cache && !cmd->is_long_lived &&
 	    !stat(dev_cache, &st) &&
-	    (st.st_ctime > dm_config_timestamp(cmd->cft)) &&
+	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
 	    !persistent_filter_load(f4, NULL))
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
--- LVM2/lib/config/config.c	2011/12/12 00:08:23	1.110
+++ LVM2/lib/config/config.c	2011/12/18 21:56:03	1.111
@@ -29,13 +29,128 @@
 #include <unistd.h>
 #include <fcntl.h>
 #include <ctype.h>
+#include <assert.h>
 
-void destroy_config_tree(struct dm_config_tree *cft)
+struct config_file {
+	time_t timestamp;
+	off_t st_size;
+	char *filename;
+	int exists;
+	int keep_open;
+	struct device *dev;
+};
+
+/*
+ * public interface
+ */
+struct dm_config_tree *config_file_open(const char *filename, int keep_open)
 {
-	struct device *dev = dm_config_get_custom(cft);
+	struct dm_config_tree *cft = dm_config_create();
+	struct config_file *cf;
+	if (!cft)
+		return NULL;
 
-	if (dev)
-		dev_close(dev);
+	cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file));
+	if (!cf) goto fail;
+
+	cf->timestamp = 0;
+	cf->exists = 0;
+	cf->keep_open = keep_open;
+	dm_config_set_custom(cft, cf);
+
+	if (filename &&
+	    !(cf->filename = dm_pool_strdup(cft->mem, filename))) {
+		log_error("Failed to duplicate filename.");
+		goto fail;
+	}
+
+	return cft;
+fail:
+	dm_config_destroy(cft);
+	return NULL;
+}
+
+/*
+ * Doesn't populate filename if the file is empty.
+ */
+int config_file_check(struct dm_config_tree *cft, const char **filename, struct stat *info)
+{
+	struct config_file *cf = dm_config_get_custom(cft);
+	struct stat _info;
+
+	if (!info)
+		info = &_info;
+
+	if (stat(cf->filename, info)) {
+		log_sys_error("stat", cf->filename);
+		cf->exists = 0;
+		return 0;
+	}
+
+	if (!S_ISREG(info->st_mode)) {
+		log_error("%s is not a regular file", cf->filename);
+		cf->exists = 0;
+		return 0;
+	}
+
+	cf->exists = 1;
+	cf->timestamp = info->st_ctime;
+	cf->st_size = info->st_size;
+
+	if (info->st_size == 0)
+		log_verbose("%s is empty", cf->filename);
+	else if (filename)
+		*filename = cf->filename;
+
+	return 1;
+}
+
+/*
+ * Return 1 if config files ought to be reloaded
+ */
+int config_file_changed(struct dm_config_tree *cft)
+{
+	struct config_file *cf = dm_config_get_custom(cft);
+	struct stat info;
+
+	if (!cf->filename)
+		return 0;
+
+	if (stat(cf->filename, &info) == -1) {
+		/* Ignore a deleted config file: still use original data */
+		if (errno == ENOENT) {
+			if (!cf->exists)
+				return 0;
+			log_very_verbose("Config file %s has disappeared!",
+					 cf->filename);
+			goto reload;
+		}
+		log_sys_error("stat", cf->filename);
+		log_error("Failed to reload configuration files");
+		return 0;
+	}
+
+	if (!S_ISREG(info.st_mode)) {
+		log_error("Configuration file %s is not a regular file",
+			  cf->filename);
+		goto reload;
+	}
+
+	/* Unchanged? */
+	if (cf->timestamp == info.st_ctime && cf->st_size == info.st_size)
+		return 0;
+
+      reload:
+	log_verbose("Detected config file change to %s", cf->filename);
+	return 1;
+}
+
+void config_file_destroy(struct dm_config_tree *cft)
+{
+	struct config_file *cf = dm_config_get_custom(cft);
+
+	if (cf && cf->dev)
+		dev_close(cf->dev);
 
 	dm_config_destroy(cft);
 }
@@ -74,9 +189,9 @@
 	return 0;
 }
 
-int read_config_fd(struct dm_config_tree *cft, struct device *dev,
-		   off_t offset, size_t size, off_t offset2, size_t size2,
-		   checksum_fn_t checksum_fn, uint32_t checksum)
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
+			off_t offset, size_t size, off_t offset2, size_t size2,
+			checksum_fn_t checksum_fn, uint32_t checksum)
 {
 	const char *fb, *fe;
 	int r = 0;
@@ -137,40 +252,46 @@
 	return r;
 }
 
-int read_config_file(struct dm_config_tree *cft)
+int config_file_read(struct dm_config_tree *cft)
 {
 	const char *filename = NULL;
-	struct device *dev = dm_config_get_custom(cft);
+	struct config_file *cf = dm_config_get_custom(cft);
 	struct stat info;
 	int r;
 
-	if (!dm_config_check_file(cft, &filename, &info))
+	if (!config_file_check(cft, &filename, &info))
 		return_0;
 
 	/* Nothing to do.  E.g. empty file. */
 	if (!filename)
 		return 1;
 
-	if (!dev) {
-		if (!(dev = dev_create_file(filename, NULL, NULL, 1)))
+	if (!cf->dev) {
+		if (!(cf->dev = dev_create_file(filename, NULL, NULL, 1)))
 			return_0;
 
-		if (!dev_open_readonly_buffered(dev))
+		if (!dev_open_readonly_buffered(cf->dev))
 			return_0;
 	}
 
-	dm_config_set_custom(cft, dev);
-	r = read_config_fd(cft, dev, 0, (size_t) info.st_size, 0, 0,
-			   (checksum_fn_t) NULL, 0);
-
-	if (!dm_config_keep_open(cft)) {
-		dev_close(dev);
-		dm_config_set_custom(cft, NULL);
+	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
+				(checksum_fn_t) NULL, 0);
+
+	if (!cf->keep_open) {
+		dev_close(cf->dev);
+		cf->dev = NULL;
 	}
 
 	return r;
 }
 
+time_t config_file_timestamp(struct dm_config_tree *cft)
+{
+	struct config_file *cf = dm_config_get_custom(cft);
+	assert(cf);
+	return cf->timestamp;
+}
+
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
 						   const char *path)
 {
--- LVM2/lib/config/config.h	2011/12/11 23:18:20	1.39
+++ LVM2/lib/config/config.h	2011/12/18 21:56:03	1.40
@@ -23,19 +23,23 @@
 
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);
-void destroy_config_tree(struct dm_config_tree *cft);
 struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
-int read_config_fd(struct dm_config_tree *cft, struct device *dev,
-		   off_t offset, size_t size, off_t offset2, size_t size2,
-		   checksum_fn_t checksum_fn, uint32_t checksum);
-
+struct dm_config_tree *config_file_open(const char *filename, int keep_open);
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
+			off_t offset, size_t size, off_t offset2, size_t size2,
+			checksum_fn_t checksum_fn, uint32_t checksum);
+	int config_file_read(struct dm_config_tree *cft);
 int config_write(struct dm_config_tree *cft, const char *file,
 		 int argc, char **argv);
+void config_file_destroy(struct dm_config_tree *cft);
+
+time_t config_file_timestamp(struct dm_config_tree *cft);
+int config_file_changed(struct dm_config_tree *cft);
+int config_file_check(struct dm_config_tree *cft, const char **filename, struct stat *info);
 
-int read_config_file(struct dm_config_tree *cft);
 
 int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 		      struct dm_config_tree *newdata);
--- LVM2/lib/filters/filter-persistent.c	2011/08/30 14:55:16	1.51
+++ LVM2/lib/filters/filter-persistent.c	2011/12/18 21:56:04	1.52
@@ -122,10 +122,10 @@
 		return_0;
 	}
 
-	if (!(cft = dm_config_create(pf->file, 1)))
+	if (!(cft = config_file_open(pf->file, 1)))
 		return_0;
 
-	if (!read_config_file(cft))
+	if (!config_file_read(cft))
 		goto_out;
 
 	_read_array(pf, cft, "persistent_filter_cache/valid_devices",
@@ -147,7 +147,7 @@
 	if (r && cft_out)
 		*cft_out = cft;
 	else
-		destroy_config_tree(cft);
+		config_file_destroy(cft);
 	return r;
 }
 
@@ -271,7 +271,7 @@
 	fcntl_unlock_file(lockfd);
 
 	if (cft)
-		destroy_config_tree(cft);
+		config_file_destroy(cft);
 
 	return r;
 }
--- LVM2/lib/format_text/import.c	2011/08/30 14:55:17	1.55
+++ LVM2/lib/format_text/import.c	2011/12/18 21:56:04	1.56
@@ -49,12 +49,12 @@
 
 	_init_text_import();
 
-	if (!(cft = dm_config_create(NULL, 0)))
+	if (!(cft = config_file_open(NULL, 0)))
 		return_NULL;
 
-	if ((!dev && !read_config_file(cft)) ||
-	    (dev && !read_config_fd(cft, dev, offset, size,
-				    offset2, size2, checksum_fn, checksum)))
+	if ((!dev && !config_file_read(cft)) ||
+	    (dev && !config_file_read_fd(cft, dev, offset, size,
+					 offset2, size2, checksum_fn, checksum)))
 		goto_out;
 
 	/*
@@ -72,7 +72,7 @@
 	}
 
       out:
-	destroy_config_tree(cft);
+	config_file_destroy(cft);
 	return vgname;
 }
 
@@ -94,12 +94,12 @@
 	*desc = NULL;
 	*when = 0;
 
-	if (!(cft = dm_config_create(file, 0)))
+	if (!(cft = config_file_open(file, 0)))
 		return_NULL;
 
-	if ((!dev && !read_config_file(cft)) ||
-	    (dev && !read_config_fd(cft, dev, offset, size,
-				    offset2, size2, checksum_fn, checksum))) {
+	if ((!dev && !config_file_read(cft)) ||
+	    (dev && !config_file_read_fd(cft, dev, offset, size,
+					 offset2, size2, checksum_fn, checksum))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
@@ -119,7 +119,7 @@
 	}
 
       out:
-	destroy_config_tree(cft);
+	config_file_destroy(cft);
 	return vg;
 }
 


