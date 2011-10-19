From: Milan Broz <mbroz@redhat.com>
Date: Wed, 19 Oct 2011 17:41:46 +0200
Subject: [PATCH] Do not scan device if it is part of active multipath.
Message-ID: <1319038907-2655-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add filter which tries to check if scanned device is part
of active multipath.

It firstly checks for major number (only SCSI, major 8) devices are
passed through this filter.

Then it checks if device has exactly one holder (in sysfs) and
if it is device-mapper device and DM-UUID is prefixed by "MPATH-".

If so, this device is filtered out.

The whole filter can be switched off by setting
mpath_component_detection in lvm.conf.

https://bugzilla.redhat.com/show_bug.cgi?id=597010

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 doc/example.conf.in        |    5 +
 include/.symlinks.in       |    1 +
 lib/Makefile.in            |    1 +
 lib/commands/toolcontext.c |   10 ++-
 lib/config/defaults.h      |    1 +
 lib/filters/filter-mpath.c |  209 ++++++++++++++++++++++++++++++++++++++++++++
 lib/filters/filter-mpath.h |   24 +++++
 7 files changed, 250 insertions(+), 1 deletions(-)
 create mode 100644 lib/filters/filter-mpath.c
 create mode 100644 lib/filters/filter-mpath.h

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 3c08d12..8b89bba 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -103,6 +103,11 @@ devices {
     # 1 enables; 0 disables.
     sysfs_scan = 1
 
+    # By default, LVM2 will ignore devices used as components
+    # of device-mapper multipath by looking for parent multipath device.
+    # 1 enables; 0 disables.
+    mpath_component_detection = 1
+
     # By default, LVM2 will ignore devices used as components of
     # software RAID (md) devices by looking for md superblocks.
     # 1 enables; 0 disables.
diff --git a/include/.symlinks.in b/include/.symlinks.in
index c16e107..00d7d55 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -16,6 +16,7 @@
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter-composite.h
 @top_srcdir@/lib/filters/filter-md.h
+ at top_srcdir@/lib/filters/filter-mpath.h
 @top_srcdir@/lib/filters/filter-persistent.h
 @top_srcdir@/lib/filters/filter-regex.h
 @top_srcdir@/lib/filters/filter-sysfs.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index a46e596..4e9afd9 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -65,6 +65,7 @@ SOURCES =\
 	filters/filter-regex.c \
 	filters/filter-sysfs.c \
 	filters/filter-md.c \
+	filters/filter-mpath.c \
 	filters/filter.c \
 	format_text/archive.c \
 	format_text/archiver.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index db5ef03..47e4915 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -22,6 +22,7 @@
 #include "filter.h"
 #include "filter-composite.h"
 #include "filter-md.h"
+#include "filter-mpath.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
 #include "filter-sysfs.h"
@@ -714,7 +715,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 4
+#define MAX_FILTERS 5
 
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
@@ -766,6 +767,13 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
+	/* mpath component filter. Optional, non-critical. */
+	if (find_config_tree_bool(cmd, "devices/mpath_component_detection",
+			     DEFAULT_MPATH_COMPONENT_DETECTION)) {
+		if ((filters[nr_filt] = mpath_filter_create()))
+			nr_filt++;
+	}
+
 	/* Only build a composite filter if we really need it. */
 	return (nr_filt == 1) ?
 	    filters[0] : composite_filter_create(nr_filt, filters);
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 0583fd2..4fa64e2 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -33,6 +33,7 @@
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
+#define DEFAULT_MPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
new file mode 100644
index 0000000..31468f4
--- /dev/null
+++ b/lib/filters/filter-mpath.c
@@ -0,0 +1,209 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+#include "filter-mpath.h"
+#include "metadata.h"
+
+#ifdef linux
+#include <dirent.h>
+
+#define SCSI_MAJOR 8
+#define MPATH_PREFIX "mpath-"
+#define MPATH_PREFIX_LEN 6
+
+static const char *get_sysfs_name(struct device *dev)
+{
+	const char *name;
+
+	name = strrchr(dev_name(dev), '/');
+	if (!name)
+		return NULL;
+	name++;
+
+	if (!*name)
+		return NULL;
+
+	return name;
+}
+
+static int get_sysfs_string(const char *path, char *buffer, int max_size)
+{
+	FILE *fp;
+	int r = 0;
+
+	if (!(fp = fopen(path, "r")))
+		return_0;
+
+	if (!fgets(buffer, max_size, fp))
+		stack;
+	else
+		r = 1;
+
+	if (fclose(fp))
+		stack;
+
+	return r;
+}
+
+static int get_sysfs_get_major_minor(const char *kname, int *major, int *minor)
+{
+	char path[PATH_MAX], buffer[64];
+
+	if (snprintf(path, sizeof(path), "/sys/block/%s/dev", kname) < 0)
+		return_0;
+
+	if (!get_sysfs_string(path, buffer, sizeof(buffer)))
+		return 0;
+
+	if (sscanf(buffer, "%d:%d", major, minor) != 2)
+		return 0;
+
+	return 1;
+}
+
+static int mpath_uuid_check(const char *dm_name)
+{
+	struct dm_task *dmt;
+	const char *uuid;
+	int major, minor, r;
+
+	if (!get_sysfs_get_major_minor(dm_name, &major, &minor))
+		return 0;
+
+	if (major != dm_major())
+		return 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return 0;
+
+	if (!dm_task_set_minor(dmt, minor) ||
+	    !dm_task_set_major(dmt, major) ||
+	    !dm_task_run(dmt) ||
+	    !(uuid = dm_task_get_uuid(dmt))) {
+		dm_task_destroy(dmt);
+		return 0;
+	}
+
+	r = strncasecmp(uuid, MPATH_PREFIX, MPATH_PREFIX_LEN);
+	dm_task_destroy(dmt);
+
+	return (r == 0) ? 1 : 0;
+}
+
+static int get_parent_mpath(const char *dir, char *name, int max_size)
+{
+	struct dirent *d;
+	DIR *dr;
+	int r = 0;
+
+	if (!(dr = opendir(dir)))
+		return_0;
+
+	*name = '\0';
+	r = 0;
+	while ((d = readdir(dr))) {
+		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
+			continue;
+
+		/* only one holder allowed if it is multipath */
+		if (*name) {
+			r = 0;
+			break;
+		}
+
+		strncpy(name, d->d_name, max_size);
+		r = 1;
+	}
+
+	if (closedir(dr))
+		stack;
+
+	return r;
+}
+
+static int dev_is_mpath(struct device *dev)
+{
+	const char *name;
+	char path[PATH_MAX+1];
+	char parent_name[PATH_MAX+1];
+	struct stat info;
+	int r;
+
+	/* Limit this filter only to SCSI devices */
+	if (MAJOR(dev->dev) != SCSI_MAJOR)
+		return 0;
+
+	name = get_sysfs_name(dev);
+	if (!name)
+		return 0;
+
+	r = dm_snprintf(path, PATH_MAX, "/sys/block/%s/holders", name);
+	if (r < 0)
+		return_0;
+
+	if (stat(path, &info) == -1 || !S_ISDIR(info.st_mode))
+		return_0;
+
+	if (!get_parent_mpath(path, parent_name, PATH_MAX))
+		return 0;
+
+	return mpath_uuid_check(parent_name);
+}
+
+static int _ignore_mpath(struct dev_filter *f __attribute__((unused)),
+		         struct device *dev)
+{
+	if (dev_is_mpath(dev) == 1) {
+		log_debug("%s: Skipping mpath component device", dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *mpath_filter_create(void)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_malloc(sizeof(*f)))) {
+		log_error("mpath filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _ignore_mpath;
+	f->destroy = _destroy;
+	f->use_count = 0;
+	f->private = NULL;
+
+	return f;
+}
+
+#else
+
+struct dev_filter *mpath_filter_create(void)
+{
+	return NULL;
+}
+
+#endif
diff --git a/lib/filters/filter-mpath.h b/lib/filters/filter-mpath.h
new file mode 100644
index 0000000..4b7962e
--- /dev/null
+++ b/lib/filters/filter-mpath.h
@@ -0,0 +1,24 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
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
+#ifndef _LVM_FILTER_MPATH_H
+#define _LVM_FILTER_MPATH_H
+
+#include "config.h"
+#include "dev-cache.h"
+
+struct dev_filter *mpath_filter_create(void);
+
+#endif
+
-- 
1.7.7


