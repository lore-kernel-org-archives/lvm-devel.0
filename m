From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:15 -0400
Subject: [PATCH 03/20] Refactor metadata.[ch] into lv.[ch] for lv functions.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is similar to the other patches for pv and vg
functionality, and separates lv functionality into separate
files, concentrating on reporting fields and simple functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in             |    1 +
 lib/Makefile.in                  |    1 +
 lib/metadata/lv.c                |   21 +++++++++++++++
 lib/metadata/lv.h                |   52 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |   29 +--------------------
 lib/metadata/metadata.c          |    5 ---
 6 files changed, 76 insertions(+), 33 deletions(-)
 create mode 100644 lib/metadata/lv.c
 create mode 100644 lib/metadata/lv.h

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 398e856..7fd6171 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -30,6 +30,7 @@
 @top_srcdir@/lib/locking/locking.h
 @top_srcdir@/lib/log/log.h
 @top_srcdir@/lib/log/lvm-logging.h
+ at top_srcdir@/lib/metadata/lv.h
 @top_srcdir@/lib/metadata/lv_alloc.h
 @top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/metadata-exported.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 2c173b3..ab944fa 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -73,6 +73,7 @@ SOURCES =\
 	locking/locking.c \
 	locking/no_locking.c \
 	log/log.c \
+	metadata/lv.c \
 	metadata/lv_manip.c \
 	metadata/merge.c \
 	metadata/metadata.c \
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
new file mode 100644
index 0000000..49f0b3d
--- /dev/null
+++ b/lib/metadata/lv.c
@@ -0,0 +1,21 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#include "metadata.h"
+
+uint64_t lv_size(const struct logical_volume *lv)
+{
+	return lv->size;
+}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
new file mode 100644
index 0000000..d3b0d82
--- /dev/null
+++ b/lib/metadata/lv.h
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+#ifndef _LV_H
+#define _LV_H
+
+union lvid;
+struct volume_group;
+struct dm_list;
+struct lv_segment;
+struct replicator_device;
+
+struct logical_volume {
+	union lvid lvid;
+	char *name;
+
+	struct volume_group *vg;
+
+	uint64_t status;
+	alloc_policy_t alloc;
+	uint32_t read_ahead;
+	int32_t major;
+	int32_t minor;
+
+	uint64_t size;		/* Sectors */
+	uint32_t le_count;
+
+	uint32_t origin_count;
+	struct dm_list snapshot_segs;
+	struct lv_segment *snapshot;
+
+	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
+	struct dm_list rsites;	/* For replicators - all sites */
+
+	struct dm_list segments;
+	struct dm_list tags;
+	struct dm_list segs_using_this_lv;
+};
+
+uint64_t lv_size(const struct logical_volume *lv);
+
+#endif
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 86c90fa..447e4af 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -24,6 +24,7 @@
 #include "uuid.h"
 #include "pv.h"
 #include "vg.h"
+#include "lv.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -291,33 +292,6 @@ struct lv_segment {
 #define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
 
-struct logical_volume {
-	union lvid lvid;
-	char *name;
-
-	struct volume_group *vg;
-
-	uint64_t status;
-	alloc_policy_t alloc;
-	uint32_t read_ahead;
-	int32_t major;
-	int32_t minor;
-
-	uint64_t size;		/* Sectors */
-	uint32_t le_count;
-
-	uint32_t origin_count;
-	struct dm_list snapshot_segs;
-	struct lv_segment *snapshot;
-
-	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
-	struct dm_list rsites;	/* For replicators - all sites */
-
-	struct dm_list segments;
-	struct dm_list tags;
-	struct dm_list segs_using_this_lv;
-};
-
 struct pe_range {
 	struct dm_list list;
 	uint32_t start;		/* PEs */
@@ -744,7 +718,6 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 */
 int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
-uint64_t lv_size(const struct logical_volume *lv);
 
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ac19603..1251345 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3920,11 +3920,6 @@ int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 	return 1;
 }
 
-uint64_t lv_size(const struct logical_volume *lv)
-{
-	return lv->size;
-}
-
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
-- 
1.7.2.2


