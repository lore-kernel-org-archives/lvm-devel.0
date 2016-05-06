From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:52 +0000 (UTC)
Subject: master - pvs: new attr and field for unchosen duplicate device
Message-ID: <20160506140052.802C660722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4e434d1e6082ff4d448f4fbc03962c6f0926da4
Commit:        d4e434d1e6082ff4d448f4fbc03962c6f0926da4
Parent:        d3d13e134af15611c3f12107aa1627b12110a974
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 29 14:42:14 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

pvs: new attr and field for unchosen duplicate device

When there are duplicate devices for a PV, one device
is preferred and chosen to exist in the VG.  The other
devices are not used by lvm, but are displayed by pvs
with a new PV attr "d", indicating that they are
unchosen duplicate PVs.

The "duplicate" reporting field is set to "duplicate"
when the PV is an unchosen duplicate, and that field
is blank for the chosen PV.
---
 lib/cache/lvmcache.c    |   11 +++++++++++
 lib/cache/lvmcache.h    |    2 ++
 lib/metadata/pv.c       |   11 ++++++++++-
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   10 ++++++++++
 lib/report/values.h     |    1 +
 man/pvs.8.in            |    4 ++--
 8 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ba87312..f04f7ea 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -782,6 +782,17 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 	return 0;
 }
 
+int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+		if (devl->dev == dev)
+			return 1;
+	}
+	return 0;
+}
+
 /*
  * Compare _found_duplicate_devs entries with the corresponding duplicate dev
  * in lvmcache.  There may be multiple duplicates in _found_duplicate_devs for
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9b3c67b..45318b9 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -209,4 +209,6 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
 
 void lvmcache_lock_ordering(int enable);
 
+int lvmcache_dev_is_unchosen_duplicate(struct device *dev);
+
 #endif
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 7ea993f..7169f31 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -236,6 +236,7 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
 	char *repstr;
 	int used = is_used_pv(pv);
+	int duplicate = lvmcache_dev_is_unchosen_duplicate(pv->dev);
 
 	if (!(repstr = dm_pool_zalloc(mem, 4))) {
 		log_error("dm_pool_alloc failed");
@@ -245,7 +246,15 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 	/*
 	 * An allocatable PV is always used, so we don't need to show 'u'.
 	 */
-	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : (used > 0) ? 'u' : '-';
+	if (duplicate)
+		repstr[0] = 'd';
+	else if (pv->status & ALLOCATABLE_PV)
+		repstr[0] = 'a';
+	else if (used > 0)
+		repstr[0] = 'u';
+	else
+		repstr[0] = '-';
+
 	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	repstr[2] = (pv->status & MISSING_PV) ? 'm' : '-';
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index b31b3f1..a17b3eb 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -148,6 +148,7 @@ FIELD(PVS, pv, NUM, "#PMdaUse", id, 0, pvmdasused, pv_mda_used_count, "Number of
 FIELD(PVS, pv, SIZ, "BA Start", ba_start, 0, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
 FIELD(PVS, pv, SIZ, "BA Size", ba_size, 0, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 FIELD(PVS, pv, BIN, "PInUse", id, 0, pvinuse, pv_in_use, "Set if PV is used.", 0)
+FIELD(PVS, pv, BIN, "Duplicate", id, 0, pvduplicate, pv_duplicate, "Set if PV is an unchosen duplicate.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 0, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 234712c..46f58be 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -194,6 +194,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_ext_vsn_set prop_not_implemented_set
 #define _pv_in_use_get prop_not_implemented_get
 #define _pv_in_use_set prop_not_implemented_set
+#define _pv_duplicate_get prop_not_implemented_get
+#define _pv_duplicate_set prop_not_implemented_set
 #define _pv_major_get prop_not_implemented_get
 #define _pv_major_set prop_not_implemented_set
 #define _pv_minor_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 016d41d..3a58cee 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3111,6 +3111,16 @@ static int _pvinuse_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, used, GET_FIRST_RESERVED_NAME(pv_in_use_y), private);
 }
 
+static int _pvduplicate_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	int duplicate = lvmcache_dev_is_unchosen_duplicate(pv->dev);
+
+	return _binary_disp(rh, mem, field, duplicate, GET_FIRST_RESERVED_NAME(pv_duplicate_y), private);
+}
+
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index 4a6c235..652689b 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -53,6 +53,7 @@ FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")
 FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "", "exported")
 FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "", "missing")
 FIELD_RESERVED_BINARY_VALUE(pv_in_use, pv_in_use, "", "used", "in use")
+FIELD_RESERVED_BINARY_VALUE(pv_duplicate, pv_duplicate, "", "duplicate")
 
 /* Reserved values for VG fields */
 FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 0e0ad92..24d16fb 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -85,8 +85,8 @@ pv_mda_used_count, pvseg_start, and pvseg_size
 .IP
 With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
-be chosen. The pv_attr bits are: (a)llocatable, e(x)ported, (m)issing and
-(u)sed (but not allocatable).
+be chosen. The pv_attr bits are: (a)llocatable, e(x)ported, (m)issing,
+(u)sed (but not allocatable), (d)uplicate.
 .TP
 .B \-\-segments
 Produces one line of output for each contiguous allocation of space on each


