From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Apr 2007 16:45:02 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/activate ...
Message-ID: <20070426164502.20827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-26 17:45:00

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/activate   : dev_manager.c 
	lib/commands   : toolcontext.c 
	lib/device     : dev-cache.c dev-cache.h 
	lib/filters    : filter-persistent.c filter-regex.c 
	                 filter-sysfs.c 
	lib/format1    : disk-rep.c format1.c import-extents.c 
	lib/format_text: import_vsn1.c 
	lib/log        : log.h 
	lib/metadata   : metadata.c 
	lib/misc       : lvm-file.c 
	lib/regex      : matcher.c 
	tools          : lvmcmdline.c 

Log message:
	Add devices/preferred_names config regex list for displayed device names.
	Free a temporary dir string in fcntl_lock_file() after use.
	Fix a dm_pool_destroy() in matcher_create().
	Introduce goto_bad macro.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.606&r2=1.607
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/matcher.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2007/04/26 16:40:45	1.606
+++ LVM2/WHATS_NEW	2007/04/26 16:44:57	1.607
@@ -1,15 +1,20 @@
 Version 2.02.25 -
 =================================
-  Fix warnings on x86_64 involving ptrdiff_t in log_error messages
-  Update pvck to include text metadata area and record detection
-  Add support functions for analysis of config sections
-  Update pvck to read labels on disk, with --labelsector parameter
-  Add count_chars and count_chars_len functions
-  Add /sys/block listings to lvm_dump.sh
-  Make lvm_dump.sh list /dev recursively
+  Add devices/preferred_names config regex list for displayed device names.
+  Free a temporary dir string in fcntl_lock_file() after use.
+  Fix a dm_pool_destroy() in matcher_create().
+  Introduce goto_bad macro.
+  Fix warnings on x86_64 involving ptrdiff_t in log_error messages.
+  Update pvck to include text metadata area and record detection.
+  Add support functions for token counting in config file extracts.
+  Update pvck to read labels on disk, with --labelsector parameter.
+  Add count_chars and count_chars_len functions.
+  Add /sys/block listings to lvm_dump.sh.
+  Make lvm_dump.sh list /dev recursively.
   Fix thread race in clvmd.
   Add scan_sector param to label_read and _find_labeller.
-  Make clvmd cope with quorum devices on RHEL5
+  Make clvmd cope with quorum devices.
+  Add extra internal error checking to clvmd.
   Add dev_read_circular.
   Add pvck command stub.
   Update lists of attribute characters in man pages.
@@ -17,7 +22,6 @@
   Fix creation and conversion of mirrors with tags.
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
-  Add extra internal error checking to clvmd
 
 Version 2.02.24 - 19th March 2007
 =================================
--- LVM2/doc/example.conf	2007/02/28 18:27:12	1.30
+++ LVM2/doc/example.conf	2007/04/26 16:44:57	1.31
@@ -19,6 +19,14 @@
     # to use with LVM2.
     scan = [ "/dev" ]
 
+    # If several entries in the scanned directories correspond to the
+    # same block device and the tools need to display a name for device,
+    # all the pathnames are matched against each item in the following
+    # list of regular expressions in turn and the first match is used.
+    preferred_names = [ ]
+
+    # preferred_names = [ "^/dev/mpath/", "^/dev/[hs]d" ]
+
     # A filter that tells LVM2 to only use a restricted set of devices.
     # The filter consists of an array of regular expressions.  These
     # expressions can be delimited by a character of your choice, and
--- LVM2/lib/activate/dev_manager.c	2007/03/08 19:58:04	1.121
+++ LVM2/lib/activate/dev_manager.c	2007/04/26 16:44:58	1.122
@@ -435,10 +435,8 @@
 		return NULL;
 	}
 
-	if (!(dm = dm_pool_alloc(mem, sizeof(*dm)))) {
-		stack;
-		goto bad;
-	}
+	if (!(dm = dm_pool_alloc(mem, sizeof(*dm))))
+		goto_bad;
 
 	dm->cmd = cmd;
 	dm->mem = mem;
@@ -450,10 +448,8 @@
 	}
 	dm->stripe_filler = stripe_filler;
 
-	if (!(dm->vg_name = dm_pool_strdup(dm->mem, vg_name))) {
-		stack;
-		goto bad;
-	}
+	if (!(dm->vg_name = dm_pool_strdup(dm->mem, vg_name)))
+		goto_bad;
 
 	dm->target_state = NULL;
 
--- LVM2/lib/commands/toolcontext.c	2007/02/28 18:27:12	1.49
+++ LVM2/lib/commands/toolcontext.c	2007/04/26 16:44:58	1.50
@@ -465,10 +465,8 @@
 	const struct config_node *cn;
 	struct config_value *cv;
 
-	if (!dev_cache_init()) {
-		stack;
-		return 0;
-	}
+	if (!dev_cache_init(cmd))
+		return_0;
 
 	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
 		if (!dev_cache_add_dir("/dev")) {
--- LVM2/lib/device/dev-cache.c	2006/08/01 14:56:32	1.45
+++ LVM2/lib/device/dev-cache.c	2007/04/26 16:44:58	1.46
@@ -19,6 +19,8 @@
 #include "btree.h"
 #include "filter.h"
 #include "filter-persistent.h"
+#include "matcher.h"
+#include "toolcontext.h"
 
 #include <unistd.h>
 #include <sys/param.h>
@@ -38,6 +40,7 @@
 	struct dm_pool *mem;
 	struct dm_hash_table *names;
 	struct btree *devices;
+	struct matcher *preferred_names_matcher;
 
 	int has_scanned;
 	struct list dirs;
@@ -129,15 +132,49 @@
 	return dev;
 }
 
+void dev_set_preferred_name(struct str_list *sl, struct device *dev)
+{
+	/*
+	 * Don't interfere with ordering specified in config file.
+	 */
+	if (_cache.preferred_names_matcher)
+		return;
+
+	log_debug("%s: New preferred name", sl->str);
+	list_del(&sl->list);
+	list_add_h(&dev->aliases, &sl->list);
+}
+
 /* Return 1 if we prefer path1 else return 0 */
 static int _compare_paths(const char *path0, const char *path1)
 {
 	int slash0 = 0, slash1 = 0;
+	int m0, m1;
 	const char *p;
 	char p0[PATH_MAX], p1[PATH_MAX];
 	char *s0, *s1;
 	struct stat stat0, stat1;
 
+	if (_cache.preferred_names_matcher) {
+		m0 = matcher_run(_cache.preferred_names_matcher, path0);
+		m1 = matcher_run(_cache.preferred_names_matcher, path1);
+
+		if (m0 != m1) {
+			if (m0 < 0)
+				return 1;
+			if (m1 < 0)
+				return 0;
+			if (m0 < m1)
+				return 1;
+			if (m1 < m0)
+				return 0;
+		}
+	}
+
+	/*
+	 * Built-in rules.
+	 */
+
 	/* Return the path with fewer slashes */
 	for (p = path0; p++; p = (const char *) strchr(p, '/'))
 		slash0++;
@@ -441,7 +478,65 @@
 		_full_scan(1);
 }
 
-int dev_cache_init(void)
+static int _init_preferred_names(struct cmd_context *cmd)
+{
+	const struct config_node *cn;
+	struct config_value *v;
+	struct dm_pool *scratch = NULL;
+	char **regex;
+	unsigned count = 0;
+	int i, r = 0;
+
+	_cache.preferred_names_matcher = NULL;
+
+	if (!(cn = find_config_tree_node(cmd, "devices/preferred_names")) ||
+	    cn->v->type == CFG_EMPTY_ARRAY) {
+		log_very_verbose("devices/preferred_names not found in config file: "
+				 "using built-in preferences");
+		return 1;
+	}
+
+	for (v = cn->v; v; v = v->next) {
+		if (v->type != CFG_STRING) {
+			log_error("preferred_names patterns must be enclosed in quotes");
+			return 0;
+		}       
+
+		count++;
+	}
+
+	if (!(scratch = dm_pool_create("preferred device name matcher", 1024)))
+		return_0;
+
+	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count))) {
+		log_error("Failed to allocate preferred device name "
+			  "pattern list.");
+		goto out;
+	}
+
+	for (v = cn->v, i = count - 1; v; v = v->next, i--) {
+		if (!(regex[i] = dm_pool_strdup(scratch, v->v.str))) {
+			log_error("Failed to allocate a preferred device name "
+				  "pattern.");
+			goto out;
+		}
+	}
+
+	if (!(_cache.preferred_names_matcher =
+		matcher_create(_cache.mem,(const char **) regex, count))) {
+		log_error("Preferred device name pattern matcher creation failed.");
+		goto out;
+	}
+
+	r = 1;
+
+out:
+	dm_pool_destroy(scratch);
+
+	return r;
+}
+
+int dev_cache_init(struct cmd_context *cmd)
 {
 	_cache.names = NULL;
 	_cache.has_scanned = 0;
@@ -466,6 +561,9 @@
 	list_init(&_cache.dirs);
 	list_init(&_cache.files);
 
+	if (!_init_preferred_names(cmd))
+		goto_bad;
+
 	return 1;
 
       bad:
@@ -489,6 +587,9 @@
 	if (_cache.names)
 		_check_for_open_devices();
 
+	if (_cache.preferred_names_matcher)
+		_cache.preferred_names_matcher = NULL;
+
 	if (_cache.mem) {
 		dm_pool_destroy(_cache.mem);
 		_cache.mem = NULL;
--- LVM2/lib/device/dev-cache.h	2005/10/16 23:03:57	1.9
+++ LVM2/lib/device/dev-cache.h	2007/04/26 16:44:58	1.10
@@ -30,7 +30,8 @@
 /*
  * The global device cache.
  */
-int dev_cache_init(void);
+struct cmd_context;
+int dev_cache_init(struct cmd_context *cmd);
 void dev_cache_exit(void);
 
 /* Trigger(1) or avoid(0) a scan */
@@ -41,6 +42,8 @@
 int dev_cache_add_loopfile(const char *path);
 struct device *dev_cache_get(const char *name, struct dev_filter *f);
 
+void dev_set_preferred_name(struct str_list *sl, struct device *dev);
+
 /*
  * Object for iterating through the cache.
  */
--- LVM2/lib/filters/filter-persistent.c	2007/01/25 14:37:47	1.29
+++ LVM2/lib/filters/filter-persistent.c	2007/04/26 16:44:58	1.30
@@ -301,10 +301,9 @@
 	}
 	memset(pf, 0, sizeof(*pf));
 
-	if (!(pf->file = dm_malloc(strlen(file) + 1))) {
-		stack;
-		goto bad;
-	}
+	if (!(pf->file = dm_malloc(strlen(file) + 1)))
+		goto_bad;
+
 	strcpy(pf->file, file);
 	pf->real = real;
 
@@ -313,10 +312,8 @@
 		goto bad;
 	}
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
-		stack;
-		goto bad;
-	}
+	if (!(f = dm_malloc(sizeof(*f))))
+		goto_bad;
 
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;
--- LVM2/lib/filters/filter-regex.c	2006/04/19 15:33:06	1.20
+++ LVM2/lib/filters/filter-regex.c	2007/04/26 16:44:58	1.21
@@ -98,18 +98,15 @@
 	unsigned count = 0;
 	int i, r = 0;
 
-	if (!(scratch = dm_pool_create("filter matcher", 1024))) {
-		stack;
-		return 0;
-	}
+	if (!(scratch = dm_pool_create("filter matcher", 1024)))
+		return_0;
 
 	/*
 	 * count how many patterns we have.
 	 */
 	for (v = val; v; v = v->next) {
-
 		if (v->type != CFG_STRING) {
-			log_info("filter patterns must be enclosed in quotes");
+			log_error("filter patterns must be enclosed in quotes");
 			goto out;
 		}
 
@@ -119,10 +116,8 @@
 	/*
 	 * allocate space for them
 	 */
-	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count))) {
-		stack;
-		goto out;
-	}
+	if (!(regex = dm_pool_alloc(scratch, sizeof(*regex) * count)))
+		goto_out;
 
 	/*
 	 * create the accept/reject bitset
@@ -136,7 +131,7 @@
 	 */
 	for (v = val, i = count - 1; v; v = v->next, i--)
 		if (!_extract_pattern(scratch, v->v.str, regex, rf->accept, i)) {
-			log_info("invalid filter pattern");
+			log_error("invalid filter pattern");
 			goto out;
 		}
 
@@ -164,13 +159,8 @@
 
 		if (m >= 0) {
 			if (dm_bit(rf->accept, m)) {
-
-				if (!first) {
-					log_debug("%s: New preferred name",
-						  sl->str);
-					list_del(&sl->list);
-					list_add_h(&dev->aliases, &sl->list);
-				}
+				if (!first)
+					dev_set_preferred_name(sl, dev);
 
 				return 1;
 			}
@@ -208,22 +198,16 @@
 		return NULL;
 	}
 
-	if (!(rf = dm_pool_alloc(mem, sizeof(*rf)))) {
-		stack;
-		goto bad;
-	}
+	if (!(rf = dm_pool_alloc(mem, sizeof(*rf))))
+		goto_bad;
 
 	rf->mem = mem;
 
-	if (!_build_matcher(rf, patterns)) {
-		stack;
-		goto bad;
-	}
+	if (!_build_matcher(rf, patterns))
+		goto_bad;
 
-	if (!(f = dm_pool_zalloc(mem, sizeof(*f)))) {
-		stack;
-		goto bad;
-	}
+	if (!(f = dm_pool_zalloc(mem, sizeof(*f))))
+		goto_bad;
 
 	f->passes_filter = _accept_p;
 	f->destroy = _regex_destroy;
--- LVM2/lib/filters/filter-sysfs.c	2007/01/25 14:37:47	1.14
+++ LVM2/lib/filters/filter-sysfs.c	2007/04/26 16:44:58	1.15
@@ -284,10 +284,8 @@
 		goto bad;
 	}
 
-	if (!(f = dm_pool_zalloc(mem, sizeof(*f)))) {
-		stack;
-		goto bad;
-	}
+	if (!(f = dm_pool_zalloc(mem, sizeof(*f))))
+		goto_bad;
 
 	f->passes_filter = _accept_p;
 	f->destroy = _destroy;
--- LVM2/lib/format1/disk-rep.c	2006/11/30 23:11:40	1.65
+++ LVM2/lib/format1/disk-rep.c	2007/04/26 16:44:58	1.66
@@ -357,10 +357,8 @@
 	list_init(&dl->uuids);
 	list_init(&dl->lvds);
 
-	if (!_read_pvd(dev, &dl->pvd)) {
-		stack;
-		goto bad;
-	}
+	if (!_read_pvd(dev, &dl->pvd))
+		goto_bad;
 
 	/*
 	 * is it an orphan ?
--- LVM2/lib/format1/format1.c	2006/10/19 12:53:46	1.99
+++ LVM2/lib/format1/format1.c	2007/04/26 16:44:58	1.100
@@ -131,10 +131,10 @@
 	int partial;
 
 	if (!vg)
-		goto bad;
+		goto_bad;
 
 	if (list_empty(pvs))
-		goto bad;
+		goto_bad;
 
 	memset(vg, 0, sizeof(*vg));
 
@@ -146,24 +146,24 @@
 	list_init(&vg->tags);
 
 	if (!_check_vgs(pvs, &partial))
-		goto bad;
+		goto_bad;
 
 	dl = list_item(pvs->n, struct disk_list);
 
 	if (!import_vg(mem, vg, dl, partial))
-		goto bad;
+		goto_bad;
 
 	if (!import_pvs(fid->fmt, mem, vg, pvs, &vg->pvs, &vg->pv_count))
-		goto bad;
+		goto_bad;
 
 	if (!import_lvs(mem, vg, pvs))
-		goto bad;
+		goto_bad;
 
 	if (!import_extents(fid->fmt->cmd, vg, pvs))
-		goto bad;
+		goto_bad;
 
 	if (!import_snapshots(mem, vg, pvs))
-		goto bad;
+		goto_bad;
 
 	return vg;
 
@@ -191,15 +191,11 @@
 	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
 
 	if (!read_pvs_in_vg
-	    (fid->fmt, vg_name, fid->fmt->cmd->filter, mem, &pvs)) {
-		stack;
-		goto bad;
-	}
+	    (fid->fmt, vg_name, fid->fmt->cmd->filter, mem, &pvs))
+		goto_bad;
 
-	if (!(vg = _build_vg(fid, &pvs))) {
-		stack;
-		goto bad;
-	}
+	if (!(vg = _build_vg(fid, &pvs)))
+		goto_bad;
 
       bad:
 	dm_pool_destroy(mem);
@@ -415,17 +411,14 @@
 		return 0;
 	}
 
-	if (!(dl = dm_pool_alloc(mem, sizeof(*dl)))) {
-		stack;
-		goto bad;
-	}
+	if (!(dl = dm_pool_alloc(mem, sizeof(*dl))))
+		goto_bad;
+
 	dl->mem = mem;
 	dl->dev = pv->dev;
 
-	if (!export_pv(fmt->cmd, mem, NULL, &dl->pvd, pv)) {
-		stack;
-		goto bad;
-	}
+	if (!export_pv(fmt->cmd, mem, NULL, &dl->pvd, pv))
+		goto_bad;
 
 	/* must be set to be able to zero gap after PV structure in
 	   dev_write in order to make other disk tools happy */
@@ -434,10 +427,8 @@
 	dl->pvd.pe_on_disk.base = LVM1_PE_ALIGN << SECTOR_SHIFT;
 
 	list_add(&pvs, &dl->list);
-	if (!write_disks(fmt, &pvs)) {
-		stack;
-		goto bad;
-	}
+	if (!write_disks(fmt, &pvs))
+		goto_bad;
 
 	dm_pool_destroy(mem);
 	return 1;
--- LVM2/lib/format1/import-extents.c	2007/03/15 13:38:28	1.32
+++ LVM2/lib/format1/import-extents.c	2007/04/26 16:44:58	1.33
@@ -59,22 +59,16 @@
 		if (ll->lv->status & SNAPSHOT)
 			continue;
 
-		if (!(lvm = dm_pool_alloc(mem, sizeof(*lvm)))) {
-			stack;
-			goto bad;
-		}
+		if (!(lvm = dm_pool_alloc(mem, sizeof(*lvm))))
+			goto_bad;
 
 		lvm->lv = ll->lv;
 		if (!(lvm->map = dm_pool_zalloc(mem, sizeof(*lvm->map)
-					     * ll->lv->le_count))) {
-			stack;
-			goto bad;
-		}
+					     * ll->lv->le_count)))
+			goto_bad;
 
-		if (!dm_hash_insert(maps, ll->lv->name, lvm)) {
-			stack;
-			goto bad;
-		}
+		if (!dm_hash_insert(maps, ll->lv->name, lvm))
+			goto_bad;
 	}
 
 	return maps;
--- LVM2/lib/format_text/import_vsn1.c	2006/11/30 23:11:41	1.38
+++ LVM2/lib/format_text/import_vsn1.c	2007/04/26 16:44:58	1.39
@@ -660,15 +660,11 @@
 	/* eg Set to instance of fmt1 here if reading a format1 backup? */
 	vg->fid = fid;
 
-	if (!(vg->name = dm_pool_strdup(mem, vgn->key))) {
-		stack;
-		goto bad;
-	}
+	if (!(vg->name = dm_pool_strdup(mem, vgn->key)))
+		goto_bad;
 
-	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN))) {
-		stack;
-		goto bad;
-	}
+	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN)))
+		goto_bad;
 
 	vgn = vgn->child;
 
--- LVM2/lib/log/log.h	2007/01/25 21:22:30	1.35
+++ LVM2/lib/log/log.h	2007/04/26 16:44:58	1.36
@@ -138,5 +138,6 @@
 #define return_0	do { stack; return 0; } while (0)
 #define return_NULL	do { stack; return NULL; } while (0)
 #define goto_out	do { stack; goto out; } while (0)
+#define goto_bad	do { stack; goto bad; } while (0)
 
 #endif
--- LVM2/lib/metadata/metadata.c	2007/04/25 21:10:55	1.107
+++ LVM2/lib/metadata/metadata.c	2007/04/26 16:44:59	1.108
@@ -280,10 +280,9 @@
 	vg->seqno = 0;
 
 	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
-	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN))) {
-		stack;
-		goto bad;
-	}
+	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN)))
+		goto_bad;
+
 	*vg->system_id = '\0';
 
 	vg->extent_size = extent_size;
@@ -320,7 +319,7 @@
 
 	/* attach the pv's */
 	if (!vg_extend(vg->fid, vg, pv_count, pv_names))
-		goto bad;
+		goto_bad;
 
 	return vg;
 
@@ -561,10 +560,8 @@
 
 	pv->dev = dev;
 
-	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN))) {
-		stack;
-		goto bad;
-	}
+	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN)))
+		goto_bad;
 
 	pv->status = ALLOCATABLE_PV;
 
--- LVM2/lib/misc/lvm-file.c	2007/02/28 18:27:12	1.19
+++ LVM2/lib/misc/lvm-file.c	2007/04/26 16:44:59	1.20
@@ -273,8 +273,12 @@
 	if ((c = strrchr(dir, '/')))
 		*c = '\0';
 
-	if (!create_dir(dir))
+	if (!create_dir(dir)) {
+		dm_free(dir);
 		return -1;
+	}
+
+	dm_free(dir);
 
 	log_very_verbose("Locking %s (%s, %hd)", file,
 			 (lock_type == F_WRLCK) ? "F_WRLCK" : "F_RDLCK",
--- LVM2/lib/regex/matcher.c	2006/05/09 21:23:50	1.15
+++ LVM2/lib/regex/matcher.c	2007/04/26 16:44:59	1.16
@@ -273,15 +273,12 @@
 	struct dm_pool *scratch = dm_pool_create("regex matcher", 10 * 1024);
 	struct matcher *m;
 
-	if (!scratch) {
-		stack;
-		return NULL;
-	}
+	if (!scratch)
+		return_NULL;
 
 	if (!(m = dm_pool_alloc(mem, sizeof(*m)))) {
-		stack;
 		dm_pool_destroy(scratch);
-		return NULL;
+		return_NULL;
 	}
 
 	memset(m, 0, sizeof(*m));
@@ -292,10 +289,8 @@
 
 	ptr = all = dm_pool_alloc(scratch, len + 1);
 
-	if (!all) {
-		stack;
-		goto bad;
-	}
+	if (!all)
+		goto_bad;
 
 	for (i = 0; i < num; i++) {
 		ptr += sprintf(ptr, "(.*(%s)%c)", patterns[i], TARGET_TRANS);
@@ -314,10 +309,8 @@
 	m->num_nodes = _count_nodes(rx);
 	m->nodes = dm_pool_alloc(scratch, sizeof(*m->nodes) * m->num_nodes);
 
-	if (!m->nodes) {
-		stack;
-		goto bad;
-	}
+	if (!m->nodes)
+		goto_bad;
 
 	_fill_table(m, rx);
 	_create_bitsets(m);
@@ -330,7 +323,7 @@
 
       bad:
 	dm_pool_destroy(scratch);
-	dm_pool_destroy(mem);
+	dm_pool_free(mem, m);
 	return NULL;
 }
 
--- LVM2/tools/lvmcmdline.c	2007/02/14 16:51:48	1.41
+++ LVM2/tools/lvmcmdline.c	2007/04/26 16:44:59	1.42
@@ -827,30 +827,30 @@
 	 * description for backups.
 	 */
 	if (!dm_pool_begin_object(cmd->mem, 128))
-		goto bad;
+		goto_bad;
 
 	for (i = 0; i < argc; i++) {
 		space = strchr(argv[i], ' ') ? 1 : 0;
 
 		if (space && !dm_pool_grow_object(cmd->mem, "'", 1))
-			goto bad;
+			goto_bad;
 
 		if (!dm_pool_grow_object(cmd->mem, argv[i], strlen(argv[i])))
-			goto bad;
+			goto_bad;
 
 		if (space && !dm_pool_grow_object(cmd->mem, "'", 1))
-			goto bad;
+			goto_bad;
 
 		if (i < (argc - 1))
 			if (!dm_pool_grow_object(cmd->mem, " ", 1))
-				goto bad;
+				goto_bad;
 	}
 
 	/*
 	 * Terminate.
 	 */
 	if (!dm_pool_grow_object(cmd->mem, "\0", 1))
-		goto bad;
+		goto_bad;
 
 	return dm_pool_end_object(cmd->mem);
 


