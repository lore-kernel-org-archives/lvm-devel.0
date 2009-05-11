From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:16 -0400
Subject: [PATCH 03/30] Add generated files, lvm_object_prop.[ch], to lib/report directory and build
In-Reply-To: <1242046903-15133-3-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These files were generated from using the current columns.h file as input
into lvm_object_prop.pl.  They are a starting point for liblvm object
property get/set functions.  The 'NUM' fields that are simple dereferences
are generated from the perl script.  Code implementing the functions for other
fields will be added later.

Include lvm_object_prop.h in lvm.h

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks            |    1 +
 lib/Makefile.in              |    1 +
 lib/report/lvm_object_prop.c |  950 ++++++++++++++++++++++++++++++++++++++++++
 lib/report/lvm_object_prop.h |  494 ++++++++++++++++++++++
 liblvm/lvm.h                 |    1 +
 5 files changed, 1447 insertions(+), 0 deletions(-)
 create mode 100644 lib/report/lvm_object_prop.c
 create mode 100644 lib/report/lvm_object_prop.h

diff --git a/include/.symlinks b/include/.symlinks
index 28da67f..4f79ec0 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -51,6 +51,7 @@
 ../lib/misc/lvm-wrappers.h
 ../lib/misc/sharedlib.h
 ../lib/report/report.h
+../lib/report/lvm_object_prop.h
 ../lib/uuid/uuid.h
 ../libdm/libdevmapper.h
 ../libdm/misc/dm-ioctl.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index e65d0c2..2ddb4ec 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -85,6 +85,7 @@ SOURCES =\
 	misc/util.c \
 	mm/memlock.c \
 	report/report.c \
+	report/lvm_object_prop.c \
 	striped/striped.c \
 	uuid/uuid.c \
 	zero/zero.c
diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
new file mode 100644
index 0000000..e353772
--- /dev/null
+++ b/lib/report/lvm_object_prop.c
@@ -0,0 +1,950 @@
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
+#include "lib.h"
+#include "metadata-exported.h"
+
+/**
+ * lvm_lv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+char *lvm_lv_get_uuid(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_uuid(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_name
+ * name - Name.  LVs created for internal use are enclosed in brackets.
+ */
+char *lvm_lv_get_name(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_name(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_lv_get_attr(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_attr(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_major
+ * major - Persistent major number or -1 if not persistent.
+ */
+uint64_t lvm_lv_get_major(const lv_t *lv)
+{
+	return lv->major;
+}
+int lvm_lv_set_major(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_minor
+ * minor - Persistent minor number or -1 if not persistent.
+ */
+uint64_t lvm_lv_get_minor(const lv_t *lv)
+{
+	return lv->minor;
+}
+int lvm_lv_set_minor(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_read_ahead
+ * read_ahead - Read ahead setting in current units.
+ */
+uint64_t lvm_lv_get_read_ahead(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_read_ahead(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_major
+ * kernel_major - Currently assigned major number or -1 if LV is not active.
+ */
+uint64_t lvm_lv_get_kernel_major(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_kernel_major(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_minor
+ * kernel_minor - Currently assigned minor number or -1 if LV is not active.
+ */
+uint64_t lvm_lv_get_kernel_minor(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_kernel_minor(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_kernel_read_ahead
+ * kernel_read_ahead - Currently-in-use read ahead setting in current units.
+ */
+uint64_t lvm_lv_get_kernel_read_ahead(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_kernel_read_ahead(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_size
+ * size - Size of LV in current units.
+ */
+uint64_t lvm_lv_get_size(const lv_t *lv)
+{
+	return lv->size;
+}
+int lvm_lv_set_size(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_seg_count
+ * seg_count - Number of segments in LV.
+ */
+uint64_t lvm_lv_get_seg_count(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_seg_count(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_origin
+ * origin - For snapshots, the origin device of this LV.
+ */
+char *lvm_lv_get_origin(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_origin(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_origin_size
+ * origin_size - For snapshots, the size of the origin device of this LV.
+ */
+uint64_t lvm_lv_get_origin_size(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_origin_size(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_snap_percent
+ * snap_percent - For snapshots, the percentage full if LV is active.
+ */
+uint64_t lvm_lv_get_snap_percent(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_snap_percent(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_copy_percent
+ * copy_percent - For mirrors and pvmove, current percentage in-sync.
+ */
+uint64_t lvm_lv_get_copy_percent(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_copy_percent(lv_t *lv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_move_pv
+ * move_pv - For pvmove, Source PV of temporary LV created by pvmove.
+ */
+char *lvm_lv_get_move_pv(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_move_pv(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_convert_lv
+ * convert_lv - For lvconvert, Name of temporary LV created by lvconvert.
+ */
+char *lvm_lv_get_convert_lv(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_convert_lv(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_lv_get_tags(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_tags(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_mirror_log
+ * mirror_log - For mirrors, the LV holding the synchronisation log.
+ */
+char *lvm_lv_get_mirror_log(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_mirror_log(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lv_{get|set}_modules
+ * modules - Kernel device-mapper modules required for this LV.
+ */
+char *lvm_lv_get_modules(const lv_t *lv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lv_set_modules(lv_t *lv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+char *lvm_pv_get_fmt(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_fmt(pv_t *pv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+char *lvm_pv_get_uuid(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_uuid(pv_t *pv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_dev_size
+ * dev_size - Size of underlying device in current units.
+ */
+uint64_t lvm_pv_get_dev_size(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_dev_size(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_name
+ * name - Name.
+ */
+char *lvm_pv_get_name(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_name(pv_t *pv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_free
+ * mda_free - Free metadata area space on this device in current units.
+ */
+uint64_t lvm_pv_get_mda_free(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area on this device in current units.
+ */
+uint64_t lvm_pv_get_mda_size(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_mda_size(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_start
+ * pe_start - Offset to the start of data on the underlying device.
+ */
+uint64_t lvm_pv_get_pe_start(const pv_t *pv)
+{
+	return pv->pe_start;
+}
+int lvm_pv_set_pe_start(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_size
+ * size - Size of PV in current units.
+ */
+uint64_t lvm_pv_get_size(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_size(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_free
+ * free - Total amount of unallocated space in current units.
+ */
+uint64_t lvm_pv_get_free(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_free(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_used
+ * used - Total amount of allocated space in current units.
+ */
+uint64_t lvm_pv_get_used(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_used(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_pv_get_attr(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_attr(pv_t *pv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_count
+ * pe_count - Total number of Physical Extents.
+ */
+uint64_t lvm_pv_get_pe_count(const pv_t *pv)
+{
+	return pv->pe_count;
+}
+int lvm_pv_set_pe_count(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_pe_alloc_count
+ * pe_alloc_count - Total number of allocated Physical Extents.
+ */
+uint64_t lvm_pv_get_pe_alloc_count(const pv_t *pv)
+{
+	return pv->pe_alloc_count;
+}
+int lvm_pv_set_pe_alloc_count(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_pv_get_tags(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_tags(pv_t *pv, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pv_{get|set}_mda_count
+ * mda_count - Number of metadata areas on this device.
+ */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_pv_set_mda_count(pv_t *pv, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+char *lvm_vg_get_fmt(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_fmt(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+char *lvm_vg_get_uuid(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_uuid(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_name
+ * name - Name.
+ */
+char *lvm_vg_get_name(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_name(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_vg_get_attr(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_attr(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_size
+ * size - Total size of VG in current units.
+ */
+uint64_t lvm_vg_get_size(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_size(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_free
+ * free - Total amount of free space in current units.
+ */
+uint64_t lvm_vg_get_free(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_free(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_sysid
+ * sysid - System ID indicating when and where it was created.
+ */
+char *lvm_vg_get_sysid(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_sysid(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_extent_size
+ * extent_size - Size of Physical Extents in current units.
+ */
+uint64_t lvm_vg_get_extent_size(const vg_t *vg)
+{
+	return vg->extent_size;
+}
+int lvm_vg_set_extent_size(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_extent_count
+ * extent_count - Total number of Physical Extents.
+ */
+uint64_t lvm_vg_get_extent_count(const vg_t *vg)
+{
+	return vg->extent_count;
+}
+int lvm_vg_set_extent_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_free_count
+ * free_count - Total number of unallocated Physical Extents.
+ */
+uint64_t lvm_vg_get_free_count(const vg_t *vg)
+{
+	return vg->free_count;
+}
+int lvm_vg_set_free_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_max_lv
+ * max_lv - Maximum number of LVs allowed in VG or 0 if unlimited.
+ */
+uint64_t lvm_vg_get_max_lv(const vg_t *vg)
+{
+	return vg->max_lv;
+}
+int lvm_vg_set_max_lv(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_max_pv
+ * max_pv - Maximum number of PVs allowed in VG or 0 if unlimited.
+ */
+uint64_t lvm_vg_get_max_pv(const vg_t *vg)
+{
+	return vg->max_pv;
+}
+int lvm_vg_set_max_pv(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_pv_count
+ * pv_count - Number of PVs.
+ */
+uint64_t lvm_vg_get_pv_count(const vg_t *vg)
+{
+	return vg->pv_count;
+}
+int lvm_vg_set_pv_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_lv_count
+ * lv_count - Number of LVs.
+ */
+uint64_t lvm_vg_get_lv_count(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_lv_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_snap_count
+ * snap_count - Number of snapshots.
+ */
+uint64_t lvm_vg_get_snap_count(const vg_t *vg)
+{
+	return vg->snapshot_count;
+}
+int lvm_vg_set_snap_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_seqno
+ * seqno - Revision number of internal metadata.  Incremented whenever it changes.
+ */
+uint64_t lvm_vg_get_seqno(const vg_t *vg)
+{
+	return vg->seqno;
+}
+int lvm_vg_set_seqno(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_vg_get_tags(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_tags(vg_t *vg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_count
+ * mda_count - Number of metadata areas in use by this VG.
+ */
+uint64_t lvm_vg_get_mda_count(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_free
+ * mda_free - Free metadata area space for this VG in current units.
+ */
+uint64_t lvm_vg_get_mda_free(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_vg_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area for this VG in current units.
+ */
+uint64_t lvm_vg_get_mda_size(const vg_t *vg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_vg_set_mda_size(vg_t *vg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_ype
+ * ype - Type of LV segment.
+ */
+char *lvm_lvseg_get_ype(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_ype(lvseg_t *lvseg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_stripes
+ * stripes - Number of stripes or mirror legs.
+ */
+uint64_t lvm_lvseg_get_stripes(const lvseg_t *lvseg)
+{
+	return lvseg->area_count;
+}
+int lvm_lvseg_set_stripes(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_stripe_size
+ * stripe_size - For stripes, amount of data placed on one device before switching to the next.
+ */
+uint64_t lvm_lvseg_get_stripe_size(const lvseg_t *lvseg)
+{
+	return lvseg->stripe_size;
+}
+int lvm_lvseg_set_stripe_size(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_region_size
+ * region_size - For mirrors, the unit of data copied when synchronising devices.
+ */
+uint64_t lvm_lvseg_get_region_size(const lvseg_t *lvseg)
+{
+	return lvseg->region_size;
+}
+int lvm_lvseg_set_region_size(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_chunk_size
+ * chunk_size - For snapshots, the unit of data used when tracking changes.
+ */
+uint64_t lvm_lvseg_get_chunk_size(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_start
+ * start - Offset within the LV to the start of the segment in current units.
+ */
+uint64_t lvm_lvseg_get_start(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_start_pe
+ * start_pe - Offset within the LV to the start of the segment in physical extents.
+ */
+uint64_t lvm_lvseg_get_start_pe(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_size
+ * size - Size of segment in current units.
+ */
+uint64_t lvm_lvseg_get_size(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_size(lvseg_t *lvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_lvseg_get_tags(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_tags(lvseg_t *lvseg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_pe_ranges
+ * pe_ranges - Ranges of Physical Extents of underlying devices in command line format.
+ */
+char *lvm_lvseg_get_pe_ranges(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_pe_ranges(lvseg_t *lvseg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_lvseg_{get|set}_devices
+ * devices - Underlying devices used with starting extent numbers.
+ */
+char *lvm_lvseg_get_devices(const lvseg_t *lvseg)
+{
+	/* FIXME: implement function body */
+	return 0;
+}
+int lvm_lvseg_set_devices(lvseg_t *lvseg, const char *value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pvseg_{get|set}_start
+ * start - Physical Extent number of start of segment.
+ */
+uint64_t lvm_pvseg_get_start(const pvseg_t *pvseg)
+{
+	return pvseg->pe;
+}
+int lvm_pvseg_set_start(pvseg_t *pvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
+/**
+ * lvm_pvseg_{get|set}_size
+ * size - Number of extents in segment.
+ */
+uint64_t lvm_pvseg_get_size(const pvseg_t *pvseg)
+{
+	return pvseg->len;
+}
+int lvm_pvseg_set_size(pvseg_t *pvseg, const uint64_t value)
+{
+	/* FIXME: implement function body */
+	return -1;
+}
diff --git a/lib/report/lvm_object_prop.h b/lib/report/lvm_object_prop.h
new file mode 100644
index 0000000..c674d64
--- /dev/null
+++ b/lib/report/lvm_object_prop.h
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
+char *lvm_lv_get_uuid(const lv_t *lv);
+int lvm_lv_set_uuid(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_name
+ * name - Name.  LVs created for internal use are enclosed in brackets.
+ */
+char *lvm_lv_get_name(const lv_t *lv);
+int lvm_lv_set_name(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_lv_get_attr(const lv_t *lv);
+int lvm_lv_set_attr(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_major
+ * major - Persistent major number or -1 if not persistent.
+ */
+uint64_t lvm_lv_get_major(const lv_t *lv);
+int lvm_lv_set_major(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_minor
+ * minor - Persistent minor number or -1 if not persistent.
+ */
+uint64_t lvm_lv_get_minor(const lv_t *lv);
+int lvm_lv_set_minor(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_read_ahead
+ * read_ahead - Read ahead setting in current units.
+ */
+uint64_t lvm_lv_get_read_ahead(const lv_t *lv);
+int lvm_lv_set_read_ahead(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_kernel_major
+ * kernel_major - Currently assigned major number or -1 if LV is not active.
+ */
+uint64_t lvm_lv_get_kernel_major(const lv_t *lv);
+int lvm_lv_set_kernel_major(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_kernel_minor
+ * kernel_minor - Currently assigned minor number or -1 if LV is not active.
+ */
+uint64_t lvm_lv_get_kernel_minor(const lv_t *lv);
+int lvm_lv_set_kernel_minor(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_kernel_read_ahead
+ * kernel_read_ahead - Currently-in-use read ahead setting in current units.
+ */
+uint64_t lvm_lv_get_kernel_read_ahead(const lv_t *lv);
+int lvm_lv_set_kernel_read_ahead(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_size
+ * size - Size of LV in current units.
+ */
+uint64_t lvm_lv_get_size(const lv_t *lv);
+int lvm_lv_set_size(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_seg_count
+ * seg_count - Number of segments in LV.
+ */
+uint64_t lvm_lv_get_seg_count(const lv_t *lv);
+int lvm_lv_set_seg_count(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_origin
+ * origin - For snapshots, the origin device of this LV.
+ */
+char *lvm_lv_get_origin(const lv_t *lv);
+int lvm_lv_set_origin(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_origin_size
+ * origin_size - For snapshots, the size of the origin device of this LV.
+ */
+uint64_t lvm_lv_get_origin_size(const lv_t *lv);
+int lvm_lv_set_origin_size(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_snap_percent
+ * snap_percent - For snapshots, the percentage full if LV is active.
+ */
+uint64_t lvm_lv_get_snap_percent(const lv_t *lv);
+int lvm_lv_set_snap_percent(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_copy_percent
+ * copy_percent - For mirrors and pvmove, current percentage in-sync.
+ */
+uint64_t lvm_lv_get_copy_percent(const lv_t *lv);
+int lvm_lv_set_copy_percent(lv_t *lv, const uint64_t value);
+
+/**
+ * lvm_lv_{get|set}_move_pv
+ * move_pv - For pvmove, Source PV of temporary LV created by pvmove.
+ */
+char *lvm_lv_get_move_pv(const lv_t *lv);
+int lvm_lv_set_move_pv(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_convert_lv
+ * convert_lv - For lvconvert, Name of temporary LV created by lvconvert.
+ */
+char *lvm_lv_get_convert_lv(const lv_t *lv);
+int lvm_lv_set_convert_lv(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_lv_get_tags(const lv_t *lv);
+int lvm_lv_set_tags(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_mirror_log
+ * mirror_log - For mirrors, the LV holding the synchronisation log.
+ */
+char *lvm_lv_get_mirror_log(const lv_t *lv);
+int lvm_lv_set_mirror_log(lv_t *lv, const char *value);
+
+/**
+ * lvm_lv_{get|set}_modules
+ * modules - Kernel device-mapper modules required for this LV.
+ */
+char *lvm_lv_get_modules(const lv_t *lv);
+int lvm_lv_set_modules(lv_t *lv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+char *lvm_pv_get_fmt(const pv_t *pv);
+int lvm_pv_set_fmt(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+char *lvm_pv_get_uuid(const pv_t *pv);
+int lvm_pv_set_uuid(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_dev_size
+ * dev_size - Size of underlying device in current units.
+ */
+uint64_t lvm_pv_get_dev_size(const pv_t *pv);
+int lvm_pv_set_dev_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_name
+ * name - Name.
+ */
+char *lvm_pv_get_name(const pv_t *pv);
+int lvm_pv_set_name(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_mda_free
+ * mda_free - Free metadata area space on this device in current units.
+ */
+uint64_t lvm_pv_get_mda_free(const pv_t *pv);
+int lvm_pv_set_mda_free(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area on this device in current units.
+ */
+uint64_t lvm_pv_get_mda_size(const pv_t *pv);
+int lvm_pv_set_mda_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_pe_start
+ * pe_start - Offset to the start of data on the underlying device.
+ */
+uint64_t lvm_pv_get_pe_start(const pv_t *pv);
+int lvm_pv_set_pe_start(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_size
+ * size - Size of PV in current units.
+ */
+uint64_t lvm_pv_get_size(const pv_t *pv);
+int lvm_pv_set_size(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_free
+ * free - Total amount of unallocated space in current units.
+ */
+uint64_t lvm_pv_get_free(const pv_t *pv);
+int lvm_pv_set_free(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_used
+ * used - Total amount of allocated space in current units.
+ */
+uint64_t lvm_pv_get_used(const pv_t *pv);
+int lvm_pv_set_used(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_pv_get_attr(const pv_t *pv);
+int lvm_pv_set_attr(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_pe_count
+ * pe_count - Total number of Physical Extents.
+ */
+uint64_t lvm_pv_get_pe_count(const pv_t *pv);
+int lvm_pv_set_pe_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_pe_alloc_count
+ * pe_alloc_count - Total number of allocated Physical Extents.
+ */
+uint64_t lvm_pv_get_pe_alloc_count(const pv_t *pv);
+int lvm_pv_set_pe_alloc_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_pv_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_pv_get_tags(const pv_t *pv);
+int lvm_pv_set_tags(pv_t *pv, const char *value);
+
+/**
+ * lvm_pv_{get|set}_mda_count
+ * mda_count - Number of metadata areas on this device.
+ */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+int lvm_pv_set_mda_count(pv_t *pv, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_fmt
+ * fmt - Type of metadata.
+ */
+char *lvm_vg_get_fmt(const vg_t *vg);
+int lvm_vg_set_fmt(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_uuid
+ * uuid - Unique identifier.
+ */
+char *lvm_vg_get_uuid(const vg_t *vg);
+int lvm_vg_set_uuid(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_name
+ * name - Name.
+ */
+char *lvm_vg_get_name(const vg_t *vg);
+int lvm_vg_set_name(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_attr
+ * attr - Various attributes - see man page.
+ */
+char *lvm_vg_get_attr(const vg_t *vg);
+int lvm_vg_set_attr(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_size
+ * size - Total size of VG in current units.
+ */
+uint64_t lvm_vg_get_size(const vg_t *vg);
+int lvm_vg_set_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_free
+ * free - Total amount of free space in current units.
+ */
+uint64_t lvm_vg_get_free(const vg_t *vg);
+int lvm_vg_set_free(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_sysid
+ * sysid - System ID indicating when and where it was created.
+ */
+char *lvm_vg_get_sysid(const vg_t *vg);
+int lvm_vg_set_sysid(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_extent_size
+ * extent_size - Size of Physical Extents in current units.
+ */
+uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+int lvm_vg_set_extent_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_extent_count
+ * extent_count - Total number of Physical Extents.
+ */
+uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+int lvm_vg_set_extent_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_free_count
+ * free_count - Total number of unallocated Physical Extents.
+ */
+uint64_t lvm_vg_get_free_count(const vg_t *vg);
+int lvm_vg_set_free_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_max_lv
+ * max_lv - Maximum number of LVs allowed in VG or 0 if unlimited.
+ */
+uint64_t lvm_vg_get_max_lv(const vg_t *vg);
+int lvm_vg_set_max_lv(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_max_pv
+ * max_pv - Maximum number of PVs allowed in VG or 0 if unlimited.
+ */
+uint64_t lvm_vg_get_max_pv(const vg_t *vg);
+int lvm_vg_set_max_pv(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_pv_count
+ * pv_count - Number of PVs.
+ */
+uint64_t lvm_vg_get_pv_count(const vg_t *vg);
+int lvm_vg_set_pv_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_lv_count
+ * lv_count - Number of LVs.
+ */
+uint64_t lvm_vg_get_lv_count(const vg_t *vg);
+int lvm_vg_set_lv_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_snap_count
+ * snap_count - Number of snapshots.
+ */
+uint64_t lvm_vg_get_snap_count(const vg_t *vg);
+int lvm_vg_set_snap_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_seqno
+ * seqno - Revision number of internal metadata.  Incremented whenever it changes.
+ */
+uint64_t lvm_vg_get_seqno(const vg_t *vg);
+int lvm_vg_set_seqno(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_vg_get_tags(const vg_t *vg);
+int lvm_vg_set_tags(vg_t *vg, const char *value);
+
+/**
+ * lvm_vg_{get|set}_mda_count
+ * mda_count - Number of metadata areas in use by this VG.
+ */
+uint64_t lvm_vg_get_mda_count(const vg_t *vg);
+int lvm_vg_set_mda_count(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_mda_free
+ * mda_free - Free metadata area space for this VG in current units.
+ */
+uint64_t lvm_vg_get_mda_free(const vg_t *vg);
+int lvm_vg_set_mda_free(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_vg_{get|set}_mda_size
+ * mda_size - Size of smallest metadata area for this VG in current units.
+ */
+uint64_t lvm_vg_get_mda_size(const vg_t *vg);
+int lvm_vg_set_mda_size(vg_t *vg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_ype
+ * ype - Type of LV segment.
+ */
+char *lvm_lvseg_get_ype(const lvseg_t *lvseg);
+int lvm_lvseg_set_ype(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_stripes
+ * stripes - Number of stripes or mirror legs.
+ */
+uint64_t lvm_lvseg_get_stripes(const lvseg_t *lvseg);
+int lvm_lvseg_set_stripes(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_stripe_size
+ * stripe_size - For stripes, amount of data placed on one device before switching to the next.
+ */
+uint64_t lvm_lvseg_get_stripe_size(const lvseg_t *lvseg);
+int lvm_lvseg_set_stripe_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_region_size
+ * region_size - For mirrors, the unit of data copied when synchronising devices.
+ */
+uint64_t lvm_lvseg_get_region_size(const lvseg_t *lvseg);
+int lvm_lvseg_set_region_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_chunk_size
+ * chunk_size - For snapshots, the unit of data used when tracking changes.
+ */
+uint64_t lvm_lvseg_get_chunk_size(const lvseg_t *lvseg);
+int lvm_lvseg_set_chunk_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_start
+ * start - Offset within the LV to the start of the segment in current units.
+ */
+uint64_t lvm_lvseg_get_start(const lvseg_t *lvseg);
+int lvm_lvseg_set_start(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_start_pe
+ * start_pe - Offset within the LV to the start of the segment in physical extents.
+ */
+uint64_t lvm_lvseg_get_start_pe(const lvseg_t *lvseg);
+int lvm_lvseg_set_start_pe(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_size
+ * size - Size of segment in current units.
+ */
+uint64_t lvm_lvseg_get_size(const lvseg_t *lvseg);
+int lvm_lvseg_set_size(lvseg_t *lvseg, const uint64_t value);
+
+/**
+ * lvm_lvseg_{get|set}_tags
+ * tags - Tags, if any.
+ */
+char *lvm_lvseg_get_tags(const lvseg_t *lvseg);
+int lvm_lvseg_set_tags(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_pe_ranges
+ * pe_ranges - Ranges of Physical Extents of underlying devices in command line format.
+ */
+char *lvm_lvseg_get_pe_ranges(const lvseg_t *lvseg);
+int lvm_lvseg_set_pe_ranges(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_lvseg_{get|set}_devices
+ * devices - Underlying devices used with starting extent numbers.
+ */
+char *lvm_lvseg_get_devices(const lvseg_t *lvseg);
+int lvm_lvseg_set_devices(lvseg_t *lvseg, const char *value);
+
+/**
+ * lvm_pvseg_{get|set}_start
+ * start - Physical Extent number of start of segment.
+ */
+uint64_t lvm_pvseg_get_start(const pvseg_t *pvseg);
+int lvm_pvseg_set_start(pvseg_t *pvseg, const uint64_t value);
+
+/**
+ * lvm_pvseg_{get|set}_size
+ * size - Number of extents in segment.
+ */
+uint64_t lvm_pvseg_get_size(const pvseg_t *pvseg);
+int lvm_pvseg_set_size(pvseg_t *pvseg, const uint64_t value);
+
+#endif
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 4e71e15..55dcb68 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -68,5 +68,6 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+#include "lvm_object_prop.h"
 
 #endif /* _LIB_LVM_H */
-- 
1.6.0.6


