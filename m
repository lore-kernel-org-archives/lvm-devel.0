From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Sep 2014 11:32:17 +0000 (UTC)
Subject: master - filters: add "usable device" filter
Message-ID: <20140930113217.7D7246022D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a843d0d97c66aae1872c05b0f6cf4bda176aae2
Commit:        8a843d0d97c66aae1872c05b0f6cf4bda176aae2
Parent:        00d8ab84923af87191110b1cb77b13a483659ef1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 23 12:49:01 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 30 13:11:58 2014 +0200

filters: add "usable device" filter

Usable device filter is responsible for filtering out unusable DM devices.
The filter has 3 modes of operation:

  - FILTER_MODE_NO_LVMETAD:
    When this mode is used, we check DM device usability by looking:
      - whether device is empty
      - whether device is blocked
      - whether device is suspended (only on devices/ignore_suspended_devices=1)
      - whether device uses an error target
      - whether device name/uuid is reserved

  - FILTER_MODE_PRE_LVMETAD:
    When this mode is used, we check DM device usability by looking:
      - whether device is empty
      - whether device is suspended (only on devices/ignore_suspended_devices=1)
      - whether device uses an error target
      - whether device name/uuid is reserved

  - FILTER_MODE_POST_LVMETAD:
    When this mode is used, we check DM device usability by looking:
      - whether device is blocked
      - whether device is suspended (only on devices/ignore_suspended_devices=1)

These modes will be used by subsequent patch to create different
instances of this filter, depending on lvmetad use.
---
 lib/Makefile.in             |    1 +
 lib/filters/filter-usable.c |   89 +++++++++++++++++++++++++++++++++++++++++++
 lib/filters/filter.h        |    7 +++
 3 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 9f101f3..bad5d8c 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -72,6 +72,7 @@ SOURCES =\
 	filters/filter-mpath.c \
 	filters/filter-partitioned.c \
 	filters/filter-type.c \
+	filters/filter-usable.c \
 	format_text/archive.c \
 	format_text/archiver.c \
 	format_text/export.c \
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
new file mode 100644
index 0000000..e91c3f3
--- /dev/null
+++ b/lib/filters/filter-usable.c
@@ -0,0 +1,89 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
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
+#include "activate.h" /* device_is_usable */
+
+static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
+{
+	filter_mode_t mode = *((filter_mode_t *) f->private);
+	struct dev_usable_check_params ucp;
+	int r;
+
+	/* filter only device-mapper devices */
+	if (!dm_is_dm_major(MAJOR(dev->dev)))
+		return 1;
+
+	switch (mode) {
+		case FILTER_MODE_NO_LVMETAD:
+			ucp.check_empty = 1;
+			ucp.check_blocked = 1;
+			ucp.check_suspended = ignore_suspended_devices();
+			ucp.check_error_target = 1;
+			ucp.check_reserved = 1;
+			break;
+		case FILTER_MODE_PRE_LVMETAD:
+			ucp.check_empty = 1;
+			ucp.check_blocked = 0;
+			ucp.check_suspended = ignore_suspended_devices();
+			ucp.check_error_target = 1;
+			ucp.check_reserved = 1;
+			break;
+		case FILTER_MODE_POST_LVMETAD:
+			ucp.check_empty = 0;
+			ucp.check_blocked = 1;
+			ucp.check_suspended = ignore_suspended_devices();
+			ucp.check_error_target = 0;
+			ucp.check_reserved = 0;
+			break;
+	}
+
+	if (!(r = device_is_usable(dev, ucp)))
+		log_debug_devs("%s: Skipping unusable device", dev_name(dev));
+
+	return r;
+}
+
+static void _usable_filter_destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying usable device filter while in use %u times.", f->use_count);
+
+	dm_free(f->private);
+	dm_free(f);
+}
+
+struct dev_filter *usable_filter_create(struct dev_types *dt __attribute__((unused)), filter_mode_t mode)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
+		log_error("Usable device filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _passes_usable_filter;
+	f->destroy = _usable_filter_destroy;
+	f->use_count = 0;
+	if (!(f->private = dm_zalloc(sizeof(filter_mode_t)))) {
+		log_error("Usable device filter mode allocation failed");
+		return NULL;
+	}
+	*((filter_mode_t *) f->private) = mode;
+
+	log_debug_devs("Usable device filter initialised.");
+
+	return f;
+}
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 219d3f7..0519439 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -40,6 +40,13 @@ struct dev_filter *sysfs_filter_create(void);
 
 struct dev_filter *regex_filter_create(const struct dm_config_value *patterns);
 
+typedef enum {
+	FILTER_MODE_NO_LVMETAD,
+	FILTER_MODE_PRE_LVMETAD,
+	FILTER_MODE_POST_LVMETAD
+} filter_mode_t;
+struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
+
 int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
 
 #endif 	/* _LVM_FILTER_H */


