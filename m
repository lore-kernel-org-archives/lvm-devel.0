From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:29 -0400
Subject: [PATCH 3/8] Add generated files, lvm_object_prop.[ch], to liblvm build.
In-Reply-To: <1241034934-25639-3-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These files were generated from using the current columns.h file as input
into lvm_object_prop.pl.  They are a starting point for liblvm object
property get/set functions.  Actual code implementing the functions will
be added later.

Include lvm_object_prop.h in lvm.h

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks        |    1 +
 liblvm/Makefile.in       |    3 +-
 liblvm/lvm.h             |    1 +
 liblvm/lvm_object_prop.c | 1009 ++++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_object_prop.h |  494 +++++++++++++++++++++++
 5 files changed, 1507 insertions(+), 1 deletions(-)
 create mode 100644 liblvm/lvm_object_prop.c
 create mode 100644 liblvm/lvm_object_prop.h

diff --git a/include/.symlinks b/include/.symlinks
index 28da67f..35461af 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -1,6 +1,7 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
 ../liblvm/lvm.h
+../liblvm/lvm_object_prop.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 3ab4950..a560533 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -17,7 +17,8 @@ top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
 SOURCES =\
-	lvm_base.c
+	lvm_base.c \
+	lvm_object_prop.c
 
 LIB_NAME = liblvm
 LIB_VERSION = $(LIB_VERSION_LVM)
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 4e71e15..55dcb68 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -68,5 +68,6 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+#include "lvm_object_prop.h"
 
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_object_prop.c b/liblvm/lvm_object_prop.c
new file mode 100644
index 0000000..2b02457
--- /dev/null
+++ b/liblvm/lvm_object_prop.c
@@ -0,0 +1,1009 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include "lvm.h"
+
+/**
+ * lvm_lv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_lv_get_uuid(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_uuid(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_name
+ * name - Name.  LVs created for internal use are enclosed in brackets.
+ */
+const char *lvm_lv_get_name(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_name(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_lv_get_attr(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_attr(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_major
+ * major - Persistent major number or -1 if not persistent.
+ */
+const uint64_t lvm_lv_get_major(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_major(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_minor
+ * minor - Persistent minor number or -1 if not persistent.
+ */
+const uint64_t lvm_lv_get_minor(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_minor(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_read_ahead
+ * read_ahead - Read ahead setting in current units.
+ */
+const uint64_t lvm_lv_get_read_ahead(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_read_ahead(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_major
+ * kernel_major - Currently assigned major number or -1 if LV is not active.
+ */
+const char *lvm_lv_get_kernel_major(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_kernel_major(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_minor
+ * kernel_minor - Currently assigned minor number or -1 if LV is not active.
+ */
+const char *lvm_lv_get_kernel_minor(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_kernel_minor(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_read_ahead
+ * kernel_read_ahead - Currently-in-use read ahead setting in current units.
+ */
+const uint64_t lvm_lv_get_kernel_read_ahead(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_kernel_read_ahead(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_size
+ * size - Size of LV in current units.
+ */
+const uint64_t lvm_lv_get_size(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_size(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_seg_count
+ * seg_count - Number of segments in LV.
+ */
+const uint64_t lvm_lv_get_seg_count(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_seg_count(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_origin
+ * origin - For snapshots, the origin device of this LV.
+ */
+const char *lvm_lv_get_origin(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_origin(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_origin_size
+ * origin_size - For snapshots, the size of the origin device of this LV.
+ */
+const uint64_t lvm_lv_get_origin_size(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_origin_size(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_snap_percent
+ * snap_percent - For snapshots, the percentage full if LV is active.
+ */
+const uint64_t lvm_lv_get_snap_percent(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_snap_percent(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_copy_percent
+ * copy_percent - For mirrors and pvmove, current percentage in-sync.
+ */
+const uint64_t lvm_lv_get_copy_percent(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lv_set_copy_percent(lv_t *lv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_move_pv
+ * move_pv - For pvmove, Source PV of temporary LV created by pvmove.
+ */
+const char *lvm_lv_get_move_pv(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_move_pv(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_convert_lv
+ * convert_lv - For lvconvert, Name of temporary LV created by lvconvert.
+ */
+const char *lvm_lv_get_convert_lv(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_convert_lv(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_lv_get_tags(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_tags(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_mirror_log
+ * mirror_log - For mirrors, the LV holding the synchronisation log.
+ */
+const char *lvm_lv_get_mirror_log(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_mirror_log(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lv_{get|set}_modules
+ * modules - Kernel device-mapper modules required for this LV.
+ */
+const char *lvm_lv_get_modules(lv_t *lv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lv_set_modules(lv_t *lv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+const char *lvm_pv_get_fmt(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_pv_set_fmt(pv_t *pv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_pv_get_uuid(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_pv_set_uuid(pv_t *pv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_dev_size
+ * dev_size - Size of underlying device in current units.
+ */
+const uint64_t lvm_pv_get_dev_size(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_dev_size(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_name
+ * name - Name.
+ */
+const char *lvm_pv_get_name(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_pv_set_name(pv_t *pv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_free
+ * mda_free - Free metadata area space on this device in current units.
+ */
+const uint64_t lvm_pv_get_mda_free(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area on this device in current units.
+ */
+const uint64_t lvm_pv_get_mda_size(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_mda_size(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_start
+ * pe_start - Offset to the start of data on the underlying device.
+ */
+const uint64_t lvm_pv_get_pe_start(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_pe_start(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_size
+ * size - Size of PV in current units.
+ */
+const uint64_t lvm_pv_get_size(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_size(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_free
+ * free - Total amount of unallocated space in current units.
+ */
+const uint64_t lvm_pv_get_free(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_free(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_used
+ * used - Total amount of allocated space in current units.
+ */
+const uint64_t lvm_pv_get_used(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_used(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_pv_get_attr(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_pv_set_attr(pv_t *pv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_count
+ * pe_count - Total number of Physical Extents.
+ */
+const uint64_t lvm_pv_get_pe_count(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_pe_count(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_alloc_count
+ * pe_alloc_count - Total number of allocated Physical Extents.
+ */
+const uint64_t lvm_pv_get_pe_alloc_count(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_pe_alloc_count(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_pv_get_tags(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_pv_set_tags(pv_t *pv, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_count
+ * mda_count - Number of metadata areas on this device.
+ */
+const uint64_t lvm_pv_get_mda_count(pv_t *pv)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pv_set_mda_count(pv_t *pv, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+const char *lvm_vg_get_fmt(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_fmt(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_vg_get_uuid(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_uuid(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_name
+ * name - Name.
+ */
+const char *lvm_vg_get_name(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_name(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_vg_get_attr(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_attr(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_size
+ * size - Total size of VG in current units.
+ */
+const uint64_t lvm_vg_get_size(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_size(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_free
+ * free - Total amount of free space in current units.
+ */
+const uint64_t lvm_vg_get_free(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_free(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_sysid
+ * sysid - System ID indicating when and where it was created.
+ */
+const char *lvm_vg_get_sysid(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_sysid(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_extent_size
+ * extent_size - Size of Physical Extents in current units.
+ */
+const uint64_t lvm_vg_get_extent_size(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_extent_size(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_extent_count
+ * extent_count - Total number of Physical Extents.
+ */
+const uint64_t lvm_vg_get_extent_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_extent_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_free_count
+ * free_count - Total number of unallocated Physical Extents.
+ */
+const uint64_t lvm_vg_get_free_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_free_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_max_lv
+ * max_lv - Maximum number of LVs allowed in VG or 0 if unlimited.
+ */
+const uint64_t lvm_vg_get_max_lv(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_max_lv(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_max_pv
+ * max_pv - Maximum number of PVs allowed in VG or 0 if unlimited.
+ */
+const uint64_t lvm_vg_get_max_pv(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_max_pv(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_pv_count
+ * pv_count - Number of PVs.
+ */
+const uint64_t lvm_vg_get_pv_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_pv_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_lv_count
+ * lv_count - Number of LVs.
+ */
+const uint64_t lvm_vg_get_lv_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_lv_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_snap_count
+ * snap_count - Number of snapshots.
+ */
+const uint64_t lvm_vg_get_snap_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_snap_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_seqno
+ * seqno - Revision number of internal metadata.  Incremented whenever it changes.
+ */
+const uint64_t lvm_vg_get_seqno(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_seqno(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_vg_get_tags(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_vg_set_tags(vg_t *vg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_count
+ * mda_count - Number of metadata areas in use by this VG.
+ */
+const uint64_t lvm_vg_get_mda_count(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_free
+ * mda_free - Free metadata area space for this VG in current units.
+ */
+const uint64_t lvm_vg_get_mda_free(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area for this VG in current units.
+ */
+const uint64_t lvm_vg_get_mda_size(vg_t *vg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_vg_set_mda_size(vg_t *vg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_ype
+ * ype - Type of LV segment.
+ */
+const char *lvm_lvseg_get_ype(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lvseg_set_ype(lvseg_t *lvseg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_stripes
+ * stripes - Number of stripes or mirror legs.
+ */
+const uint64_t lvm_lvseg_get_stripes(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_stripes(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_stripe_size
+ * stripe_size - For stripes, amount of data placed on one device before switching to the next.
+ */
+const uint64_t lvm_lvseg_get_stripe_size(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_stripe_size(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_region_size
+ * region_size - For mirrors, the unit of data copied when synchronising devices.
+ */
+const uint64_t lvm_lvseg_get_region_size(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_region_size(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_chunk_size
+ * chunk_size - For snapshots, the unit of data used when tracking changes.
+ */
+const uint64_t lvm_lvseg_get_chunk_size(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_start
+ * start - Offset within the LV to the start of the segment in current units.
+ */
+const uint64_t lvm_lvseg_get_start(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_start_pe
+ * start_pe - Offset within the LV to the start of the segment in physical extents.
+ */
+const uint64_t lvm_lvseg_get_start_pe(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_size
+ * size - Size of segment in current units.
+ */
+const uint64_t lvm_lvseg_get_size(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_lvseg_set_size(lvseg_t *lvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_lvseg_get_tags(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lvseg_set_tags(lvseg_t *lvseg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_pe_ranges
+ * pe_ranges - Ranges of Physical Extents of underlying devices in command line format.
+ */
+const char *lvm_lvseg_get_pe_ranges(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lvseg_set_pe_ranges(lvseg_t *lvseg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_devices
+ * devices - Underlying devices used with starting extent numbers.
+ */
+const char *lvm_lvseg_get_devices(lvseg_t *lvseg)
+{
+    /* FIXME: implement function body */
+    return (const char *)0;
+}
+int lvm_lvseg_set_devices(lvseg_t *lvseg, const char *value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pvseg_{get|set}_start
+ * start - Physical Extent number of start of segment.
+ */
+const uint64_t lvm_pvseg_get_start(pvseg_t *pvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pvseg_set_start(pvseg_t *pvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+/**
+ * lvm_pvseg_{get|set}_size
+ * size - Number of extents in segment.
+ */
+const uint64_t lvm_pvseg_get_size(pvseg_t *pvseg)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+int lvm_pvseg_set_size(pvseg_t *pvseg, const uint64_t value)
+{
+    /* FIXME: implement function body */
+    return -1;
+}
diff --git a/liblvm/lvm_object_prop.h b/liblvm/lvm_object_prop.h
new file mode 100644
index 0000000..9ef3337
--- /dev/null
+++ b/liblvm/lvm_object_prop.h
@@ -0,0 +1,494 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#ifndef _LVM_OBJECT_PROP_H
+#define _LVM_OBJECT_PROP_H
+
+/**
+ * lvm_lv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_lv_get_uuid(lv_t *lv);
+int lvm_lv_set_uuid(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_name
+ * name - Name.  LVs created for internal use are enclosed in brackets.
+ */
+const char *lvm_lv_get_name(lv_t *lv);
+int lvm_lv_set_name(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_lv_get_attr(lv_t *lv);
+int lvm_lv_set_attr(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_major
+ * major - Persistent major number or -1 if not persistent.
+ */
+const uint64_t lvm_lv_get_major(lv_t *lv);
+int lvm_lv_set_major(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_minor
+ * minor - Persistent minor number or -1 if not persistent.
+ */
+const uint64_t lvm_lv_get_minor(lv_t *lv);
+int lvm_lv_set_minor(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_read_ahead
+ * read_ahead - Read ahead setting in current units.
+ */
+const uint64_t lvm_lv_get_read_ahead(lv_t *lv);
+int lvm_lv_set_read_ahead(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_kernel_major
+ * kernel_major - Currently assigned major number or -1 if LV is not active.
+ */
+const char *lvm_lv_get_kernel_major(lv_t *lv);
+int lvm_lv_set_kernel_major(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_kernel_minor
+ * kernel_minor - Currently assigned minor number or -1 if LV is not active.
+ */
+const char *lvm_lv_get_kernel_minor(lv_t *lv);
+int lvm_lv_set_kernel_minor(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_kernel_read_ahead
+ * kernel_read_ahead - Currently-in-use read ahead setting in current units.
+ */
+const uint64_t lvm_lv_get_kernel_read_ahead(lv_t *lv);
+int lvm_lv_set_kernel_read_ahead(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_size
+ * size - Size of LV in current units.
+ */
+const uint64_t lvm_lv_get_size(lv_t *lv);
+int lvm_lv_set_size(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_seg_count
+ * seg_count - Number of segments in LV.
+ */
+const uint64_t lvm_lv_get_seg_count(lv_t *lv);
+int lvm_lv_set_seg_count(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_origin
+ * origin - For snapshots, the origin device of this LV.
+ */
+const char *lvm_lv_get_origin(lv_t *lv);
+int lvm_lv_set_origin(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_origin_size
+ * origin_size - For snapshots, the size of the origin device of this LV.
+ */
+const uint64_t lvm_lv_get_origin_size(lv_t *lv);
+int lvm_lv_set_origin_size(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_snap_percent
+ * snap_percent - For snapshots, the percentage full if LV is active.
+ */
+const uint64_t lvm_lv_get_snap_percent(lv_t *lv);
+int lvm_lv_set_snap_percent(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_copy_percent
+ * copy_percent - For mirrors and pvmove, current percentage in-sync.
+ */
+const uint64_t lvm_lv_get_copy_percent(lv_t *lv);
+int lvm_lv_set_copy_percent(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_move_pv
+ * move_pv - For pvmove, Source PV of temporary LV created by pvmove.
+ */
+const char *lvm_lv_get_move_pv(lv_t *lv);
+int lvm_lv_set_move_pv(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_convert_lv
+ * convert_lv - For lvconvert, Name of temporary LV created by lvconvert.
+ */
+const char *lvm_lv_get_convert_lv(lv_t *lv);
+int lvm_lv_set_convert_lv(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_lv_get_tags(lv_t *lv);
+int lvm_lv_set_tags(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_mirror_log
+ * mirror_log - For mirrors, the LV holding the synchronisation log.
+ */
+const char *lvm_lv_get_mirror_log(lv_t *lv);
+int lvm_lv_set_mirror_log(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_modules
+ * modules - Kernel device-mapper modules required for this LV.
+ */
+const char *lvm_lv_get_modules(lv_t *lv);
+int lvm_lv_set_modules(lv_t *lv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+const char *lvm_pv_get_fmt(pv_t *pv);
+int lvm_pv_set_fmt(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_pv_get_uuid(pv_t *pv);
+int lvm_pv_set_uuid(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_dev_size
+ * dev_size - Size of underlying device in current units.
+ */
+const uint64_t lvm_pv_get_dev_size(pv_t *pv);
+int lvm_pv_set_dev_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_name
+ * name - Name.
+ */
+const char *lvm_pv_get_name(pv_t *pv);
+int lvm_pv_set_name(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_mda_free
+ * mda_free - Free metadata area space on this device in current units.
+ */
+const uint64_t lvm_pv_get_mda_free(pv_t *pv);
+int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area on this device in current units.
+ */
+const uint64_t lvm_pv_get_mda_size(pv_t *pv);
+int lvm_pv_set_mda_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_pe_start
+ * pe_start - Offset to the start of data on the underlying device.
+ */
+const uint64_t lvm_pv_get_pe_start(pv_t *pv);
+int lvm_pv_set_pe_start(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_size
+ * size - Size of PV in current units.
+ */
+const uint64_t lvm_pv_get_size(pv_t *pv);
+int lvm_pv_set_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_free
+ * free - Total amount of unallocated space in current units.
+ */
+const uint64_t lvm_pv_get_free(pv_t *pv);
+int lvm_pv_set_free(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_used
+ * used - Total amount of allocated space in current units.
+ */
+const uint64_t lvm_pv_get_used(pv_t *pv);
+int lvm_pv_set_used(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_pv_get_attr(pv_t *pv);
+int lvm_pv_set_attr(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_pe_count
+ * pe_count - Total number of Physical Extents.
+ */
+const uint64_t lvm_pv_get_pe_count(pv_t *pv);
+int lvm_pv_set_pe_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_pe_alloc_count
+ * pe_alloc_count - Total number of allocated Physical Extents.
+ */
+const uint64_t lvm_pv_get_pe_alloc_count(pv_t *pv);
+int lvm_pv_set_pe_alloc_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_pv_get_tags(pv_t *pv);
+int lvm_pv_set_tags(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_mda_count
+ * mda_count - Number of metadata areas on this device.
+ */
+const uint64_t lvm_pv_get_mda_count(pv_t *pv);
+int lvm_pv_set_mda_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+const char *lvm_vg_get_fmt(vg_t *vg);
+int lvm_vg_set_fmt(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+const char *lvm_vg_get_uuid(vg_t *vg);
+int lvm_vg_set_uuid(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_name
+ * name - Name.
+ */
+const char *lvm_vg_get_name(vg_t *vg);
+int lvm_vg_set_name(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+const char *lvm_vg_get_attr(vg_t *vg);
+int lvm_vg_set_attr(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_size
+ * size - Total size of VG in current units.
+ */
+const uint64_t lvm_vg_get_size(vg_t *vg);
+int lvm_vg_set_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_free
+ * free - Total amount of free space in current units.
+ */
+const uint64_t lvm_vg_get_free(vg_t *vg);
+int lvm_vg_set_free(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_sysid
+ * sysid - System ID indicating when and where it was created.
+ */
+const char *lvm_vg_get_sysid(vg_t *vg);
+int lvm_vg_set_sysid(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_extent_size
+ * extent_size - Size of Physical Extents in current units.
+ */
+const uint64_t lvm_vg_get_extent_size(vg_t *vg);
+int lvm_vg_set_extent_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_extent_count
+ * extent_count - Total number of Physical Extents.
+ */
+const uint64_t lvm_vg_get_extent_count(vg_t *vg);
+int lvm_vg_set_extent_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_free_count
+ * free_count - Total number of unallocated Physical Extents.
+ */
+const uint64_t lvm_vg_get_free_count(vg_t *vg);
+int lvm_vg_set_free_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_max_lv
+ * max_lv - Maximum number of LVs allowed in VG or 0 if unlimited.
+ */
+const uint64_t lvm_vg_get_max_lv(vg_t *vg);
+int lvm_vg_set_max_lv(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_max_pv
+ * max_pv - Maximum number of PVs allowed in VG or 0 if unlimited.
+ */
+const uint64_t lvm_vg_get_max_pv(vg_t *vg);
+int lvm_vg_set_max_pv(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_pv_count
+ * pv_count - Number of PVs.
+ */
+const uint64_t lvm_vg_get_pv_count(vg_t *vg);
+int lvm_vg_set_pv_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_lv_count
+ * lv_count - Number of LVs.
+ */
+const uint64_t lvm_vg_get_lv_count(vg_t *vg);
+int lvm_vg_set_lv_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_snap_count
+ * snap_count - Number of snapshots.
+ */
+const uint64_t lvm_vg_get_snap_count(vg_t *vg);
+int lvm_vg_set_snap_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_seqno
+ * seqno - Revision number of internal metadata.  Incremented whenever it changes.
+ */
+const uint64_t lvm_vg_get_seqno(vg_t *vg);
+int lvm_vg_set_seqno(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_vg_get_tags(vg_t *vg);
+int lvm_vg_set_tags(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_mda_count
+ * mda_count - Number of metadata areas in use by this VG.
+ */
+const uint64_t lvm_vg_get_mda_count(vg_t *vg);
+int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_mda_free
+ * mda_free - Free metadata area space for this VG in current units.
+ */
+const uint64_t lvm_vg_get_mda_free(vg_t *vg);
+int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area for this VG in current units.
+ */
+const uint64_t lvm_vg_get_mda_size(vg_t *vg);
+int lvm_vg_set_mda_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_ype
+ * ype - Type of LV segment.
+ */
+const char *lvm_lvseg_get_ype(lvseg_t *lvseg);
+int lvm_lvseg_set_ype(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_stripes
+ * stripes - Number of stripes or mirror legs.
+ */
+const uint64_t lvm_lvseg_get_stripes(lvseg_t *lvseg);
+int lvm_lvseg_set_stripes(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_stripe_size
+ * stripe_size - For stripes, amount of data placed on one device before switching to the next.
+ */
+const uint64_t lvm_lvseg_get_stripe_size(lvseg_t *lvseg);
+int lvm_lvseg_set_stripe_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_region_size
+ * region_size - For mirrors, the unit of data copied when synchronising devices.
+ */
+const uint64_t lvm_lvseg_get_region_size(lvseg_t *lvseg);
+int lvm_lvseg_set_region_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_chunk_size
+ * chunk_size - For snapshots, the unit of data used when tracking changes.
+ */
+const uint64_t lvm_lvseg_get_chunk_size(lvseg_t *lvseg);
+int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_start
+ * start - Offset within the LV to the start of the segment in current units.
+ */
+const uint64_t lvm_lvseg_get_start(lvseg_t *lvseg);
+int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_start_pe
+ * start_pe - Offset within the LV to the start of the segment in physical extents.
+ */
+const uint64_t lvm_lvseg_get_start_pe(lvseg_t *lvseg);
+int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_size
+ * size - Size of segment in current units.
+ */
+const uint64_t lvm_lvseg_get_size(lvseg_t *lvseg);
+int lvm_lvseg_set_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+const char *lvm_lvseg_get_tags(lvseg_t *lvseg);
+int lvm_lvseg_set_tags(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_pe_ranges
+ * pe_ranges - Ranges of Physical Extents of underlying devices in command line format.
+ */
+const char *lvm_lvseg_get_pe_ranges(lvseg_t *lvseg);
+int lvm_lvseg_set_pe_ranges(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_devices
+ * devices - Underlying devices used with starting extent numbers.
+ */
+const char *lvm_lvseg_get_devices(lvseg_t *lvseg);
+int lvm_lvseg_set_devices(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_pvseg_{get|set}_start
+ * start - Physical Extent number of start of segment.
+ */
+const uint64_t lvm_pvseg_get_start(pvseg_t *pvseg);
+int lvm_pvseg_set_start(pvseg_t *pvseg, const uint64_t value);
+
+/**
+ * lvm_pvseg_{get|set}_size
+ * size - Number of extents in segment.
+ */
+const uint64_t lvm_pvseg_get_size(pvseg_t *pvseg);
+int lvm_pvseg_set_size(pvseg_t *pvseg, const uint64_t value);
+
+#endif
-- 
1.6.0.6


