From: David Teigland <teigland@sourceware.org>
Date: Wed,  6 Apr 2022 17:52:00 +0000 (GMT)
Subject: main - filters: remove unused internal filter
Message-ID: <20220406175200.C9A6B385380D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99f9bb28c9bf9cc5bda14674a3827ec5164b2872
Commit:        99f9bb28c9bf9cc5bda14674a3827ec5164b2872
Parent:        6cb0b44cd2f518ed32c9bef571986d51c775c99b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 1 15:09:18 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 6 12:51:34 2022 -0500

filters: remove unused internal filter

---
 lib/Makefile.in               |  1 -
 lib/commands/toolcontext.c    |  9 +----
 lib/filters/filter-internal.c | 86 -------------------------------------------
 lib/filters/filter.h          |  4 --
 4 files changed, 1 insertion(+), 99 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index e97f57a4d..22b96134b 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -54,7 +54,6 @@ SOURCES =\
 	filters/filter-partitioned.c \
 	filters/filter-type.c \
 	filters/filter-usable.c \
-	filters/filter-internal.c \
 	filters/filter-signature.c \
 	filters/filter-deviceid.c \
 	format_text/archive.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 301596482..4cb81bf94 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1128,7 +1128,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 11
+#define MAX_FILTERS 10
 
 static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 {
@@ -1143,13 +1143,6 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	 * Update MAX_FILTERS definition above when adding new filters.
 	 */
 
-	/* internal filter used by command processing. */
-	if (!(filters[nr_filt] = internal_filter_create())) {
-		log_error("Failed to create internal device filter");
-		goto bad;
-	}
-	nr_filt++;
-
 	/* global regex filter. Optional. */
 	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
 		if (!(filters[nr_filt] = regex_filter_create(cn->v, 0, 1))) {
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
deleted file mode 100644
index a49c07e53..000000000
--- a/lib/filters/filter-internal.c
+++ /dev/null
@@ -1,86 +0,0 @@
-/*
- * Copyright (C) 2006 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "base/memory/zalloc.h"
-#include "lib/misc/lib.h"
-#include "lib/filters/filter.h"
-
-static DM_LIST_INIT(_allow_devs);
-
-int internal_filter_allow(struct dm_pool *mem, struct device *dev)
-{
-	struct device_list *devl;
-
-	if (!(devl = dm_pool_alloc(mem, sizeof(*devl)))) {
-		log_error("device_list element allocation failed");
-		return 0;
-	}
-	devl->dev = dev;
-
-	dm_list_add(&_allow_devs, &devl->list);
-	return 1;
-}
-
-void internal_filter_clear(void)
-{
-	dm_list_init(&_allow_devs);
-}
-
-static int _passes_internal(struct cmd_context *cmd, struct dev_filter *f __attribute__((unused)),
-			    struct device *dev, const char *use_filter_name)
-{
-	struct device_list *devl;
-
-	dev->filtered_flags &= ~DEV_FILTERED_INTERNAL;
-
-	if (!internal_filtering())
-		return 1;
-	
-	dm_list_iterate_items(devl, &_allow_devs) {
-		if (devl->dev == dev)
-			return 1;
-	}
-	
-	dev->filtered_flags |= DEV_FILTERED_INTERNAL;
-	log_debug_devs("%s: Skipping for internal filtering.", dev_name(dev));
-	return 0;
-}
-
-static void _destroy(struct dev_filter *f)
-{
-	if (f->use_count)
-		log_error(INTERNAL_ERROR "Destroying internal filter while in use %u times.", f->use_count);
-
-	free(f);
-}
-
-struct dev_filter *internal_filter_create(void)
-{
-	struct dev_filter *f;
-
-	if (!(f = zalloc(sizeof(*f)))) {
-		log_error("md filter allocation failed");
-		return NULL;
-	}
-
-	f->passes_filter = _passes_internal;
-	f->destroy = _destroy;
-	f->use_count = 0;
-	f->name = "internal";
-
-	log_debug_devs("Internal filter initialised.");
-
-	return f;
-}
-
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index bff58c9a4..4cdfa2c9b 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -32,10 +32,6 @@ struct dev_filter *sysfs_filter_create(void);
 struct dev_filter *signature_filter_create(struct dev_types *dt);
 struct dev_filter *deviceid_filter_create(struct cmd_context *cmd);
 
-struct dev_filter *internal_filter_create(void);
-int internal_filter_allow(struct dm_pool *mem, struct device *dev);
-void internal_filter_clear(void);
-
 /*
  * patterns must be an array of strings of the form:
  * [ra]<sep><regex><sep>, eg,

