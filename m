From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 13 Aug 2013 22:34:05 +0000 (UTC)
Subject: master - filters: check for mpath before opening devs
Message-ID: <20130813223405.2AF086115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80bcdb93ffcd69e03923ceeac5afc018831d0cfc
Commit:        80bcdb93ffcd69e03923ceeac5afc018831d0cfc
Parent:        0da72743ca46ae9f8185cd12d5c78b3c2b801872
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 13 23:26:58 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 13 23:26:58 2013 +0100

filters: check for mpath before opening devs

Split out the partitioned device filter that needs to open the device
and move the multipath filter in front of it.

When a device is multipathed, sending I/O to the underlying paths may
cause problems, the most obvious being I/O errors visible to lvm if a
path is down.

Revert the incorrect <backtrace> messages added when a device doesn't
pass a filter.

Log each filter initialisation to show sequence.

Avoid duplicate 'Using $device' debug messages.
---
 WHATS_NEW                        |    3 +
 include/.symlinks.in             |    6 ---
 lib/Makefile.in                  |    3 +-
 lib/commands/toolcontext.c       |   30 ++++++------
 lib/device/dev-cache.c           |   13 +++--
 lib/filters/filter-composite.c   |    8 ++--
 lib/filters/filter-composite.h   |   23 ----------
 lib/filters/filter-md.c          |    4 +-
 lib/filters/filter-md.h          |   24 ----------
 lib/filters/filter-mpath.c       |    4 +-
 lib/filters/filter-mpath.h       |   24 ----------
 lib/filters/filter-partitioned.c |   83 +++++++++++++++++++++++++++++++++++
 lib/filters/filter-persistent.c  |    4 +-
 lib/filters/filter-persistent.h  |   28 ------------
 lib/filters/filter-regex.c       |    5 ++-
 lib/filters/filter-regex.h       |   31 -------------
 lib/filters/filter-sysfs.c       |    5 ++-
 lib/filters/filter-sysfs.h       |   22 ---------
 lib/filters/filter-type.c        |   59 +++++++++++++++++++++++++
 lib/filters/filter.c             |   88 --------------------------------------
 lib/filters/filter.h             |   27 ++++++++++-
 tools/tools.h                    |    4 --
 22 files changed, 215 insertions(+), 283 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49360b2..67c4b18 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.101 - 
 ===================================
+  Move mpath device filter before partitioned filter (which opens devices).
+  Split partitioned filter out of lvm_type filter.
+  Merge filter*.h into a single filter.h.
   Require confirmation for vgchange -c when no VGs listed explicitly.
   Also skip /var and /var/log by default in blkdeactivate when unmounting.
   Add support for bind mounts in blkdeactivate.
diff --git a/include/.symlinks.in b/include/.symlinks.in
index 0fdcdb0..6de35b8 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -17,12 +17,6 @@
 @top_srcdir@/lib/device/dev-type.h
 @top_srcdir@/lib/device/device.h
 @top_srcdir@/lib/display/display.h
- at top_srcdir@/lib/filters/filter-composite.h
- at top_srcdir@/lib/filters/filter-md.h
- at top_srcdir@/lib/filters/filter-mpath.h
- at top_srcdir@/lib/filters/filter-persistent.h
- at top_srcdir@/lib/filters/filter-regex.h
- at top_srcdir@/lib/filters/filter-sysfs.h
 @top_srcdir@/lib/filters/filter.h
 @top_srcdir@/lib/format1/format1.h
 @top_srcdir@/lib/format_pool/format_pool.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index a58605c..8fdc194 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -66,7 +66,8 @@ SOURCES =\
 	filters/filter-sysfs.c \
 	filters/filter-md.c \
 	filters/filter-mpath.c \
-	filters/filter.c \
+	filters/filter-partitioned.c \
+	filters/filter-type.c \
 	format_text/archive.c \
 	format_text/archiver.c \
 	format_text/export.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 48fc489..65371b1 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -20,12 +20,6 @@
 #include "lvm-string.h"
 #include "activate.h"
 #include "filter.h"
-#include "filter-composite.h"
-#include "filter-md.h"
-#include "filter-mpath.h"
-#include "filter-persistent.h"
-#include "filter-regex.h"
-#include "filter-sysfs.h"
 #include "label.h"
 #include "lvm-file.h"
 #include "format-text.h"
@@ -35,7 +29,6 @@
 #include "segtype.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
-#include "dev-cache.h"
 #include "archiver.h"
 
 #ifdef HAVE_LIBDL
@@ -824,7 +817,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 5
+#define MAX_FILTERS 6
 
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
@@ -853,7 +846,6 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	if (!(cn = find_config_tree_node(cmd, devices_filter_CFG, NULL)))
 		log_very_verbose("devices/filter not found in config file: "
 				 "no regex filter installed");
-
 	else if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
 		log_error("Failed to create regex device filter");
 		goto bad;
@@ -867,6 +859,19 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	}
 	nr_filt++;
 
+	/* mpath component filter. Optional, non-critical. */
+	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL)) {
+		if ((filters[nr_filt] = mpath_filter_create(cmd->dev_types)))
+			nr_filt++;
+	}
+
+	/* partitioned device filter. Required. */
+	if (!(filters[nr_filt] = partitioned_filter_create(cmd->dev_types))) {
+		log_error("Failed to create partitioned device filter");
+		goto bad;
+	}
+	nr_filt++;
+
 	/* md component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_md_component_detection_CFG, NULL)) {
 		init_md_filtering(1);
@@ -874,12 +879,6 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
-	/* mpath component filter. Optional, non-critical. */
-	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL)) {
-		if ((filters[nr_filt] = mpath_filter_create(cmd->dev_types)))
-			nr_filt++;
-	}
-
 	/* Only build a composite filter if we really need it. */
 	if (nr_filt == 1)
 		return filters[0];
@@ -888,6 +887,7 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 		goto_bad;
 
 	return composite;
+
 bad:
 	while (--nr_filt >= 0)
 		 filters[nr_filt]->destroy(filters[nr_filt]);
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 24046ca..46e5d65 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -14,10 +14,8 @@
  */
 
 #include "lib.h"
-#include "dev-cache.h"
 #include "lvm-types.h"
 #include "btree.h"
-#include "filter.h"
 #include "config.h"
 #include "toolcontext.h"
 
@@ -923,8 +921,11 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		}
 	}
 
-	return (d && (!f || (d->flags & DEV_REGULAR) ||
-		      f->passes_filter(f, d))) ? d : NULL;
+	if (!d || (f && !(d->flags & DEV_REGULAR) && !(f->passes_filter(f, d))))
+		return NULL;
+
+	log_debug_devs("Using %s", dev_name(d));
+	return d;
 }
 
 static struct device *_dev_cache_seek_devt(dev_t dev)
@@ -1007,8 +1008,10 @@ struct device *dev_iter_get(struct dev_iter *iter)
 	while (iter->current) {
 		struct device *d = _iter_next(iter);
 		if (!iter->filter || (d->flags & DEV_REGULAR) ||
-		    iter->filter->passes_filter(iter->filter, d))
+		    iter->filter->passes_filter(iter->filter, d)) {
+			log_debug_devs("Using %s", dev_name(d));
 			return d;
+		}
 	}
 
 	return NULL;
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 47d147e..a6ba71a 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -14,7 +14,7 @@
  */
 
 #include "lib.h"
-#include "filter-composite.h"
+#include "filter.h"
 
 static int _and_p(struct dev_filter *f, struct device *dev)
 {
@@ -22,9 +22,7 @@ static int _and_p(struct dev_filter *f, struct device *dev)
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		if (!(*filters)->passes_filter(*filters, dev))
-			return_0;
-
-	log_debug_devs("Using %s", dev_name(dev));
+			return 0;	/* No 'stack': a filter, not an error. */
 
 	return 1;
 }
@@ -92,5 +90,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	cft->use_count = 0;
 	cft->private = filters_copy;
 
+	log_debug_devs("Composite filter initialised.");
+
 	return cft;
 }
diff --git a/lib/filters/filter-composite.h b/lib/filters/filter-composite.h
deleted file mode 100644
index 75c0b1f..0000000
--- a/lib/filters/filter-composite.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FILTER_COMPOSITE_H
-#define _LVM_FILTER_COMPOSITE_H
-
-#include "dev-cache.h"
-
-struct dev_filter *composite_filter_create(int n, struct dev_filter **filters);
-
-#endif
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index b18cd07..0089f93 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -14,7 +14,7 @@
  */
 
 #include "lib.h"
-#include "filter-md.h"
+#include "filter.h"
 
 #ifdef linux
 
@@ -64,6 +64,8 @@ struct dev_filter *md_filter_create(struct dev_types *dt)
 	f->use_count = 0;
 	f->private = dt;
 
+	log_debug_devs("MD filter initialised.");
+
 	return f;
 }
 
diff --git a/lib/filters/filter-md.h b/lib/filters/filter-md.h
deleted file mode 100644
index 79e4f0e..0000000
--- a/lib/filters/filter-md.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/*
- * Copyright (C) 2004 Luca Berra
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
-#ifndef _LVM_FILTER_MD_H
-#define _LVM_FILTER_MD_H
-
-#include "dev-cache.h"
-#include "dev-type.h"
-
-struct dev_filter *md_filter_create(struct dev_types *dt);
-
-#endif
-
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 2502f30..1db2264 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "filter-mpath.h"
+#include "filter.h"
 #include "activate.h"
 
 #ifdef linux
@@ -228,6 +228,8 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 	f->use_count = 0;
 	f->private = dt;
 
+	log_debug_devs("mpath filter initialised.");
+
 	return f;
 }
 
diff --git a/lib/filters/filter-mpath.h b/lib/filters/filter-mpath.h
deleted file mode 100644
index 5665f3b..0000000
--- a/lib/filters/filter-mpath.h
+++ /dev/null
@@ -1,24 +0,0 @@
-/*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FILTER_MPATH_H
-#define _LVM_FILTER_MPATH_H
-
-#include "dev-cache.h"
-#include "dev-type.h"
-
-struct dev_filter *mpath_filter_create(struct dev_types *dt);
-
-#endif
-
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
new file mode 100644
index 0000000..e3caa0e
--- /dev/null
+++ b/lib/filters/filter-partitioned.c
@@ -0,0 +1,83 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "filter.h"
+
+static int _passes_partitioned_filter(struct dev_filter *f, struct device *dev)
+{
+	struct dev_types *dt = (struct dev_types *) f->private;
+	const char *name = dev_name(dev);
+	int ret = 0;
+	uint64_t size;
+
+	/* Check it's accessible */
+	if (!dev_open_readonly_quiet(dev)) {
+		log_debug_devs("%s: Skipping: open failed", name);
+		return 0;
+	}
+
+	/* Check it's not too small */
+	if (!dev_get_size(dev, &size)) {
+		log_debug_devs("%s: Skipping: dev_get_size failed", name);
+		goto out;
+	}
+
+	if (size < pv_min_size()) {
+		log_debug_devs("%s: Skipping: Too small to hold a PV", name);
+		goto out;
+	}
+
+	if (dev_is_partitioned(dt, dev)) {
+		log_debug_devs("%s: Skipping: Partition table signature found",
+			       name);
+		goto out;
+	}
+
+	ret = 1;
+
+      out:
+	if (!dev_close(dev))
+		stack;
+
+	return ret;
+}
+
+static void _partitioned_filter_destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying partitioned filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *partitioned_filter_create(struct dev_types *dt)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+		log_error("Partitioned filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _passes_partitioned_filter;
+	f->destroy = _partitioned_filter_destroy;
+	f->use_count = 0;
+	f->private = dt;
+
+	log_debug_devs("Partitioned filter initialised.");
+
+	return f;
+}
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 2949b93..14a3480 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -14,7 +14,7 @@
  */
 
 #include "lib.h"
-#include "filter-persistent.h"
+#include "filter.h"
 #include "config.h"
 #include "lvm-file.h"
 #include "activate.h"
@@ -366,6 +366,8 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 	f->wipe = _persistent_filter_wipe;
 	f->dump = _persistent_filter_dump;
 
+	log_debug_devs("Persistent filter initialised.");
+
 	return f;
 
       bad:
diff --git a/lib/filters/filter-persistent.h b/lib/filters/filter-persistent.h
deleted file mode 100644
index bdbf887..0000000
--- a/lib/filters/filter-persistent.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FILTER_PERSISTENT_H
-#define _LVM_FILTER_PERSISTENT_H
-
-#include "dev-cache.h"
-#include "dev-type.h"
-
-struct dev_filter *persistent_filter_create(struct dev_types *dt,
-					    struct dev_filter *f,
-					    const char *file);
-
-int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
-
-#endif
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 4fe9a7a..b30290e 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -14,7 +14,7 @@
  */
 
 #include "lib.h"
-#include "filter-regex.h"
+#include "filter.h"
 
 struct rfilter {
 	struct dm_pool *mem;
@@ -212,6 +212,9 @@ struct dev_filter *regex_filter_create(const struct dm_config_value *patterns)
 	f->destroy = _regex_destroy;
 	f->use_count = 0;
 	f->private = rf;
+
+	log_debug_devs("Regex filter initialised.");
+
 	return f;
 
       bad:
diff --git a/lib/filters/filter-regex.h b/lib/filters/filter-regex.h
deleted file mode 100644
index de05206..0000000
--- a/lib/filters/filter-regex.h
+++ /dev/null
@@ -1,31 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FILTER_REGEX_H
-#define _LVM_FILTER_REGEX_H
-
-#include "dev-cache.h"
-
-/*
- * patterns must be an array of strings of the form:
- * [ra]<sep><regex><sep>, eg,
- * r/cdrom/          - reject cdroms
- * a|loop/[0-4]|     - accept loops 0 to 4
- * r|.*|             - reject everything else
- */
-
-struct dev_filter *regex_filter_create(const struct dm_config_value *patterns);
-
-#endif
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index cd039c0..e03beca 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib.h"
-#include "filter-sysfs.h"
+#include "filter.h"
 
 #ifdef linux
 
@@ -324,6 +324,9 @@ struct dev_filter *sysfs_filter_create(void)
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = ds;
+
+	log_debug_devs("Sysfs filter initialised.");
+
 	return f;
 
  bad:
diff --git a/lib/filters/filter-sysfs.h b/lib/filters/filter-sysfs.h
deleted file mode 100644
index 4b26ea6..0000000
--- a/lib/filters/filter-sysfs.h
+++ /dev/null
@@ -1,22 +0,0 @@
-/*
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FILTER_SYSFS_H
-#define _LVM_FILTER_SYSFS_H
-
-#include "dev-cache.h"
-
-struct dev_filter *sysfs_filter_create(void);
-
-#endif
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
new file mode 100644
index 0000000..b55269b
--- /dev/null
+++ b/lib/filters/filter-type.c
@@ -0,0 +1,59 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "filter.h"
+
+static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
+{
+	struct dev_types *dt = (struct dev_types *) f->private;
+	const char *name = dev_name(dev);
+
+	/* Is this a recognised device type? */
+	if (!dt->dev_type_array[MAJOR(dev->dev)].max_partitions) {
+		log_debug_devs("%s: Skipping: Unrecognised LVM device type %"
+			       PRIu64, name, (uint64_t) MAJOR(dev->dev));
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _lvm_type_filter_destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *lvm_type_filter_create(struct dev_types *dt)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+		log_error("LVM type filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _passes_lvm_type_device_filter;
+	f->destroy = _lvm_type_filter_destroy;
+	f->use_count = 0;
+	f->private = dt;
+
+	log_debug_devs("LVM type filter initialised.");
+
+	return f;
+}
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
deleted file mode 100644
index 56935f9..0000000
--- a/lib/filters/filter.c
+++ /dev/null
@@ -1,88 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "filter.h"
-
-static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
-{
-	struct dev_types *dt = (struct dev_types *) f->private;
-	const char *name = dev_name(dev);
-	int ret = 0;
-	uint64_t size;
-
-	/* Is this a recognised device type? */
-	if (!dt->dev_type_array[MAJOR(dev->dev)].max_partitions) {
-		log_debug_devs("%s: Skipping: Unrecognised LVM device type %"
-			       PRIu64, name, (uint64_t) MAJOR(dev->dev));
-		return 0;
-	}
-
-	/* Check it's accessible */
-	if (!dev_open_readonly_quiet(dev)) {
-		log_debug_devs("%s: Skipping: open failed", name);
-		return 0;
-	}
-
-	/* Check it's not too small */
-	if (!dev_get_size(dev, &size)) {
-		log_debug_devs("%s: Skipping: dev_get_size failed", name);
-		goto out;
-	}
-
-	if (size < pv_min_size()) {
-		log_debug_devs("%s: Skipping: Too small to hold a PV", name);
-		goto out;
-	}
-
-	if (dev_is_partitioned(dt, dev)) {
-		log_debug_devs("%s: Skipping: Partition table signature found",
-			       name);
-		goto out;
-	}
-
-	ret = 1;
-
-      out:
-	if (!dev_close(dev))
-		stack;
-
-	return ret;
-}
-
-static void _lvm_type_filter_destroy(struct dev_filter *f)
-{
-	if (f->use_count)
-		log_error(INTERNAL_ERROR "Destroying lvm_type filter while in use %u times.", f->use_count);
-
-	dm_free(f);
-}
-
-struct dev_filter *lvm_type_filter_create(struct dev_types *dt)
-{
-	struct dev_filter *f;
-
-	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
-		log_error("LVM type filter allocation failed");
-		return NULL;
-	}
-
-	f->passes_filter = _passes_lvm_type_device_filter;
-	f->destroy = _lvm_type_filter_destroy;
-	f->use_count = 0;
-	f->private = dt;
-
-	return f;
-}
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index e0a0c6a..219d3f7 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -1,6 +1,7 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004 Luca Berra
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +20,26 @@
 #include "dev-cache.h"
 #include "dev-type.h"
 
+struct dev_filter *composite_filter_create(int n, struct dev_filter **filters);
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
+struct dev_filter *md_filter_create(struct dev_types *dt);
+struct dev_filter *mpath_filter_create(struct dev_types *dt);
+struct dev_filter *partitioned_filter_create(struct dev_types *dt);
+struct dev_filter *persistent_filter_create(struct dev_types *dt,
+					    struct dev_filter *f,
+					    const char *file);
+struct dev_filter *sysfs_filter_create(void);
 
-#endif
+/*
+ * patterns must be an array of strings of the form:
+ * [ra]<sep><regex><sep>, eg,
+ * r/cdrom/          - reject cdroms
+ * a|loop/[0-4]|     - accept loops 0 to 4
+ * r|.*|             - reject everything else
+ */
+
+struct dev_filter *regex_filter_create(const struct dm_config_value *patterns);
+
+int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
+
+#endif 	/* _LVM_FILTER_H */
diff --git a/tools/tools.h b/tools/tools.h
index 6e820bf..a2bfe0d 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -36,10 +36,6 @@
 #include "device.h"
 #include "display.h"
 #include "errors.h"
-#include "filter.h"
-#include "filter-composite.h"
-#include "filter-persistent.h"
-#include "filter-regex.h"
 #include "metadata-exported.h"
 #include "locking.h"
 #include "lvm-exec.h"


