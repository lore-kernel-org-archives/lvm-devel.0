From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:17 +0000 (UTC)
Subject: master - report: select: refactor: move str_list to libdm
Message-ID: <20140617143417.CA7F560C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5abdb52fdc66316d3e7d54085d4e79160024b95e
Commit:        5abdb52fdc66316d3e7d54085d4e79160024b95e
Parent:        fe952e735ae260849a9a9c04f38bbb08f8e6c22b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:41:03 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: refactor: move str_list to libdm

The list of strings is used quite frequently and we'd like to reuse
this simple structure for report selection support too. Make it part
of libdevmapper for general reuse throughout the code.

This also simplifies the LVM code a bit since we don't need to
include and manage lvm-types.h anymore (the string list was the
only structure defined there).
---
 daemons/clvmd/lvm-functions.c   |    1 -
 include/.symlinks.in            |    1 -
 lib/cache/lvmcache.h            |    6 +++---
 lib/commands/toolcontext.c      |    2 +-
 lib/datastruct/lvm-types.h      |   26 --------------------------
 lib/datastruct/str_list.c       |   12 ++++++------
 lib/device/dev-cache.c          |   19 +++++++++----------
 lib/device/dev-cache.h          |    2 +-
 lib/device/dev-io.c             |    3 +--
 lib/device/device.h             |    5 ++---
 lib/display/display.c           |    2 +-
 lib/filters/filter-persistent.c |    2 +-
 lib/filters/filter-regex.c      |    2 +-
 lib/format1/disk-rep.h          |    1 -
 lib/format_text/format-text.h   |    1 -
 lib/format_text/layout.h        |    1 -
 lib/format_text/tags.c          |    2 +-
 lib/log/log.c                   |    2 +-
 lib/metadata/lv_manip.c         |    2 +-
 lib/metadata/metadata.c         |    8 ++++----
 lib/metadata/mirror.c           |    4 ++--
 lib/misc/lib.h                  |    1 -
 lib/report/properties.h         |    1 -
 libdm/libdevmapper.h            |    8 ++++++++
 liblvm/lvm_misc.c               |    2 +-
 liblvm/lvm_prop.c               |    1 -
 old-tests/device/dev_cache_t.c  |    4 ++--
 old-tests/device/random.h       |    2 --
 tools/lvrename.c                |    1 -
 tools/pvchange.c                |    2 +-
 tools/toollib.c                 |    6 +++---
 tools/tools.h                   |    1 -
 tools/vgrename.c                |    2 +-
 33 files changed, 51 insertions(+), 84 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 9fd71e8..1754b7d 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -17,7 +17,6 @@
 
 #include <pthread.h>
 
-#include "lvm-types.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
diff --git a/include/.symlinks.in b/include/.symlinks.in
index ced2cb3..48c4d9d 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -11,7 +11,6 @@
 @top_srcdir@/lib/config/config_settings.h
 @top_srcdir@/lib/config/defaults.h
 @top_srcdir@/lib/datastruct/btree.h
- at top_srcdir@/lib/datastruct/lvm-types.h
 @top_srcdir@/lib/datastruct/str_list.h
 @top_srcdir@/lib/device/dev-cache.h
 @top_srcdir@/lib/device/dev-type.h
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 83d561b..d43866d 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -88,17 +88,17 @@ int lvmcache_vgname_is_locked(const char *vgname);
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
 
-/* Returns list of struct str_lists containing pool-allocated copy of vgnames */
+/* Returns list of struct dm_str_list containing pool-allocated copy of vgnames */
 /* If include_internal is not set, return only proper vg names. */
 struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
 				     int include_internal);
 
-/* Returns list of struct str_lists containing pool-allocated copy of vgids */
+/* Returns list of struct dm_str_list containing pool-allocated copy of vgids */
 /* If include_internal is not set, return only proper vg ids. */
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal);
 
-/* Returns list of struct str_lists containing pool-allocated copy of pvids */
+/* Returns list of struct dm_str_list containing pool-allocated copy of pvids */
 struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 519d36a..cc08747 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -615,7 +615,7 @@ static int _init_lvm_conf(struct cmd_context *cmd)
 /* Read any additional config files */
 static int _init_tag_configs(struct cmd_context *cmd)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	/* Tag list may grow while inside this loop */
 	dm_list_iterate_items(sl, &cmd->tags) {
diff --git a/lib/datastruct/lvm-types.h b/lib/datastruct/lvm-types.h
deleted file mode 100644
index b38798f..0000000
--- a/lib/datastruct/lvm-types.h
+++ /dev/null
@@ -1,26 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_TYPES_H
-#define _LVM_TYPES_H
-
-#include "libdevmapper.h"
-
-struct str_list {
-	struct dm_list list;
-	const char *str;
-};
-
-#endif
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index dfce69c..f519679 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -32,7 +32,7 @@ struct dm_list *str_list_create(struct dm_pool *mem)
 
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str)
 {
-	struct str_list *sln;
+	struct dm_str_list *sln;
 
 	if (!str)
 		return_0;
@@ -55,14 +55,14 @@ void str_list_del(struct dm_list *sll, const char *str)
 	struct dm_list *slh, *slht;
 
 	dm_list_iterate_safe(slh, slht, sll)
-		if (!strcmp(str, dm_list_item(slh, struct str_list)->str))
+		if (!strcmp(str, dm_list_item(slh, struct dm_str_list)->str))
 			 dm_list_del(slh);
 }
 
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	dm_list_init(sllnew);
 
@@ -79,7 +79,7 @@ int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
  */
 int str_list_match_item(const struct dm_list *sll, const char *str)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	dm_list_iterate_items(sl, sll)
 	    if (!strcmp(str, sl->str))
@@ -94,7 +94,7 @@ int str_list_match_item(const struct dm_list *sll, const char *str)
  */
 int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, const char **tag_matched)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	dm_list_iterate_items(sl, sll)
 		if (str_list_match_item(sll2, sl->str)) {
@@ -111,7 +111,7 @@ int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, c
  */
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	if (dm_list_size(sll) != dm_list_size(sll2))
 		return 0;
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index f76e527..1d7a517 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -14,7 +14,6 @@
  */
 
 #include "lib.h"
-#include "lvm-types.h"
 #include "btree.h"
 #include "config.h"
 #include "toolcontext.h"
@@ -70,7 +69,7 @@ static void _dev_init(struct device *dev, int max_error_count)
 }
 
 struct device *dev_create_file(const char *filename, struct device *dev,
-			       struct str_list *alias, int use_malloc)
+			       struct dm_str_list *alias, int use_malloc)
 {
 	int allocate = !dev;
 
@@ -81,7 +80,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 				return NULL;
 			}
 			if (!(alias = dm_zalloc(sizeof(*alias)))) {
-				log_error("struct str_list allocation failed");
+				log_error("struct dm_str_list allocation failed");
 				dm_free(dev);
 				return NULL;
 			}
@@ -97,7 +96,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 				return NULL;
 			}
 			if (!(alias = _zalloc(sizeof(*alias)))) {
-				log_error("struct str_list allocation failed");
+				log_error("struct dm_str_list allocation failed");
 				_free(dev);
 				return NULL;
 			}
@@ -133,7 +132,7 @@ static struct device *_dev_create(dev_t d)
 	return dev;
 }
 
-void dev_set_preferred_name(struct str_list *sl, struct device *dev)
+void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev)
 {
 	/*
 	 * Don't interfere with ordering specified in config file.
@@ -308,8 +307,8 @@ static int _compare_paths(const char *path0, const char *path1)
 
 static int _add_alias(struct device *dev, const char *path)
 {
-	struct str_list *sl = _zalloc(sizeof(*sl));
-	struct str_list *strl;
+	struct dm_str_list *sl = _zalloc(sizeof(*sl));
+	struct dm_str_list *strl;
 	const char *oldpath;
 	int prefer_old = 1;
 
@@ -327,7 +326,7 @@ static int _add_alias(struct device *dev, const char *path)
 	sl->str = path;
 
 	if (!dm_list_empty(&dev->aliases)) {
-		oldpath = dm_list_item(dev->aliases.n, struct str_list)->str;
+		oldpath = dm_list_item(dev->aliases.n, struct dm_str_list)->str;
 		prefer_old = _compare_paths(path, oldpath);
 		log_debug_devs("%s: Aliased to %s in device cache%s",
 			       path, oldpath, prefer_old ? "" : " (preferred name)");
@@ -889,7 +888,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 		return dev_name(dev);
 
 	while ((r = stat(name = dm_list_item(dev->aliases.n,
-					  struct str_list)->str, &buf)) ||
+					  struct dm_str_list)->str, &buf)) ||
 	       (buf.st_rdev != dev->dev)) {
 		if (r < 0) {
 			if (quiet)
@@ -1073,6 +1072,6 @@ int dev_fd(struct device *dev)
 
 const char *dev_name(const struct device *dev)
 {
-	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct str_list)->str :
+	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
 	    "unknown device";
 }
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index fcc69a5..4fca358 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -54,7 +54,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f);
 // TODO
 struct device *dev_cache_get_by_devt(dev_t device, struct dev_filter *f);
 
-void dev_set_preferred_name(struct str_list *sl, struct device *dev);
+void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
 
 /*
  * Object for iterating through the cache.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 6697456..0a75088 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -14,7 +14,6 @@
  */
 
 #include "lib.h"
-#include "lvm-types.h"
 #include "device.h"
 #include "metadata.h"
 #include "lvmcache.h"
@@ -591,7 +590,7 @@ static void _close(struct device *dev)
 	log_debug_devs("Closed %s", dev_name(dev));
 
 	if (dev->flags & DEV_ALLOCED) {
-		dm_free((void *) dm_list_item(dev->aliases.n, struct str_list)->
+		dm_free((void *) dm_list_item(dev->aliases.n, struct dm_str_list)->
 			 str);
 		dm_free(dev->aliases.n);
 		dm_free(dev);
diff --git a/lib/device/device.h b/lib/device/device.h
index 35d7505..c916a4b 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -17,7 +17,6 @@
 #define _LVM_DEVICE_H
 
 #include "uuid.h"
-#include "lvm-types.h"
 
 #include <fcntl.h>
 
@@ -34,7 +33,7 @@
  * pointer comparisons are valid.
  */
 struct device {
-	struct dm_list aliases;	/* struct str_list from lvm-types.h */
+	struct dm_list aliases;	/* struct dm_str_list */
 	dev_t dev;
 
 	/* private */
@@ -96,7 +95,7 @@ int dev_set(struct device *dev, uint64_t offset, size_t len, int value);
 void dev_flush(struct device *dev);
 
 struct device *dev_create_file(const char *filename, struct device *dev,
-			       struct str_list *alias, int use_malloc);
+			       struct dm_str_list *alias, int use_malloc);
 
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
diff --git a/lib/display/display.c b/lib/display/display.c
index 3c47aa8..70a4cda 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -833,7 +833,7 @@ void display_segtypes(const struct cmd_context *cmd)
 
 void display_tags(const struct cmd_context *cmd)
 {
-	const struct str_list *sl;
+	const struct dm_str_list *sl;
 
 	dm_list_iterate_items(sl, &cmd->tags) {
 		log_print("%s", sl->str);
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 7eaae71..6d406c7 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -272,7 +272,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	/* Cached BAD? */
 	if (l == PF_BAD_DEVICE) {
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index b30290e..f60a47f 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -149,7 +149,7 @@ static int _accept_p(struct dev_filter *f, struct device *dev)
 {
 	int m, first = 1, rejected = 0;
 	struct rfilter *rf = (struct rfilter *) f->private;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	dm_list_iterate_items(sl, &dev->aliases) {
 		m = dm_regex_match(rf->engine, sl->str);
diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 52ee303..43e2e57 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -16,7 +16,6 @@
 #ifndef DISK_REP_FORMAT1_H
 #define DISK_REP_FORMAT1_H
 
-#include "lvm-types.h"
 #include "metadata.h"
 #include "toolcontext.h"
 
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 7d2543d..39591d1 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -16,7 +16,6 @@
 #ifndef _LVM_FORMAT_TEXT_H
 #define _LVM_FORMAT_TEXT_H
 
-#include "lvm-types.h"
 #include "metadata.h"
 
 #define FMT_TEXT_NAME "lvm2"
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 6fb3e49..4753fde 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -17,7 +17,6 @@
 #define _LVM_TEXT_LAYOUT_H
 
 #include "config.h"
-#include "lvm-types.h"
 #include "metadata.h"
 #include "uuid.h"
 
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index d0bf2b1..dc138d1 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -21,7 +21,7 @@
 
 char *alloc_printed_tags(struct dm_list *tagsl)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	int first = 1;
 	size_t size = 0;
 	char *buffer, *buf;
diff --git a/lib/log/log.c b/lib/log/log.c
index a3c0139..83e5be4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -23,7 +23,7 @@
 
 static FILE *_log_file;
 static struct device _log_dev;
-static struct str_list _log_dev_alias;
+static struct dm_str_list _log_dev_alias;
 
 static int _syslog = 0;
 static int _log_to_file = 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 76a9103..9fe441d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5281,7 +5281,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	int r;
 	char *name;
 	size_t len;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	struct logical_volume *layer_lv;
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 15f9249..5c0a474 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2322,7 +2322,7 @@ int vg_validate(struct volume_group *vg)
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	struct lv_segment *seg;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
 	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
@@ -3571,7 +3571,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	const char *vgname;
 	struct dm_list *vgnames;
 	struct volume_group *vg;
-	struct str_list *strl;
+	struct dm_str_list *strl;
 	int consistent = 0;
 
 	/* Is corresponding vgname already cached? */
@@ -3802,7 +3802,7 @@ struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 static int _get_pvs(struct cmd_context *cmd, int warnings,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
-	struct str_list *strl;
+	struct dm_str_list *strl;
 	const char *vgname, *vgid;
 	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;
@@ -4712,7 +4712,7 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	if (!dm_pool_begin_object(mem, 256)) {
 		log_error("dm_pool_begin_object failed");
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 9a413e8..b03cdbe 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -281,7 +281,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 			    struct logical_volume *log_lv, int in_sync,
 			    struct dm_list *tagsl, int remove_on_failure)
 {
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	uint64_t orig_status = log_lv->status;
 	int was_active = 0;
 
@@ -420,7 +420,7 @@ static int _activate_lv_like_model(struct logical_volume *model,
 static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv)
 {
 	struct cmd_context *cmd = mirror_lv->vg->cmd;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	/* Inherit tags - maybe needed for activation */
 	if (!str_list_match_list(&mirror_lv->tags, &lv->tags, NULL)) {
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 5bd968a..3a35c22 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -40,7 +40,6 @@
 #  include "lvm-logging.h"
 #  include "lvm-globals.h"
 #  include "lvm-wrappers.h"
-#  include "lvm-types.h"
 #endif
 
 #include <unistd.h>
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 4e8bf86..14e65ed 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -15,7 +15,6 @@
 #define _LVM_PROPERTIES_H
 
 #include "libdevmapper.h"
-#include "lvm-types.h"
 #include "metadata.h"
 #include "report.h"
 #include "prop_common.h"
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 319b07c..f3e2b92 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1179,6 +1179,14 @@ struct dm_list {
 };
 
 /*
+ * String list.
+ */
+struct dm_str_list {
+	struct dm_list list;
+	const char *str;
+};
+
+/*
  * Initialise a list before use.
  * The list head's next and previous pointers point back to itself.
  */
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index d9b4323..ff26cdf 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -22,7 +22,7 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
 	struct dm_list *list;
 	lvm_str_list_t *lsl;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	if (!(list = dm_pool_zalloc(p, sizeof(*list)))) {
 		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
index cbbd6f5..79ed113 100644
--- a/liblvm/lvm_prop.c
+++ b/liblvm/lvm_prop.c
@@ -14,7 +14,6 @@
 
 #include "lvm_prop.h"
 #include "libdevmapper.h"
-#include "lvm-types.h"
 #include "metadata.h"
 
 /* lv create parameters */
diff --git a/old-tests/device/dev_cache_t.c b/old-tests/device/dev_cache_t.c
index f19a56f..26895b8 100644
--- a/old-tests/device/dev_cache_t.c
+++ b/old-tests/device/dev_cache_t.c
@@ -24,7 +24,7 @@ int main(int argc, char **argv)
 	struct device *dev;
 	struct dev_iter *iter;
 	struct list_head *tmp;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 
 	if (argc < 2) {
 		fprintf(stderr, "usage: %s <dir>\n", argv[0]);
@@ -55,7 +55,7 @@ int main(int argc, char **argv)
 		printf("%s", dev->name);
 
 		list_for_each(tmp, &dev->aliases) {
-			sl = list_entry(tmp, struct str_list, list);
+			sl = list_entry(tmp, struct dm_str_list, list);
 			printf(", %s", sl->str);
 		}
 		printf("\n");
diff --git a/old-tests/device/random.h b/old-tests/device/random.h
index abcbda6..9e3783b 100644
--- a/old-tests/device/random.h
+++ b/old-tests/device/random.h
@@ -21,8 +21,6 @@
 #ifndef _LVM_RANDOM_H
 #define _LVM_RANDOM_H
 
-#include "lvm-types.h"
-
 void rand_init(int32_t seed);
 int32_t rand_get(void);
 
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 0fea039..3bf4793 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "lvm-types.h"
 
 /*
  * lvrename command implementation.
diff --git a/tools/pvchange.c b/tools/pvchange.c
index afa6829..c2adc34 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -161,7 +161,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	struct pv_list *pvl;
 	struct dm_list *vgnames;
-	struct str_list *sll;
+	struct dm_str_list *sll;
 
 	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
diff --git a/tools/toollib.c b/tools/toollib.c
index c619d9b..d4c915d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -293,7 +293,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
-	struct str_list *sll, *strl;
+	struct dm_str_list *sll, *strl;
 	struct cmd_vg *cvl_vg;
 	struct dm_list cmd_vgs;
 	struct dm_list failed_lvnames;
@@ -621,7 +621,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	struct dm_list *vgnames, *vgids;
 	struct dm_list arg_vgnames, tagsl;
 
@@ -803,7 +803,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	struct physical_volume *pv;
 	struct dm_list *pvslist = NULL, *vgnames;
 	struct dm_list tagsl;
-	struct str_list *sll;
+	struct dm_str_list *sll;
 	char *at_sign, *tagname;
 	struct device *dev;
 
diff --git a/tools/tools.h b/tools/tools.h
index 11111cb..2b09f37 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -23,7 +23,6 @@
 #include <assert.h>
 #include "libdevmapper.h"
 
-#include "lvm-types.h"
 #include "lvm-logging.h"
 #include "activate.h"
 #include "archiver.h"
diff --git a/tools/vgrename.c b/tools/vgrename.c
index d97b871..860ccf1 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -62,7 +62,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	int match = 0;
 	int found_id = 0;
 	struct dm_list *vgids;
-	struct str_list *sl;
+	struct dm_str_list *sl;
 	const char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];


