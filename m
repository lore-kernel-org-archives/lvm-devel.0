From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:36 +0000 (UTC)
Subject: master - report: add pv_in_use field to display whether PV is in use or not
Message-ID: <20160215120836.245BB60509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3436d5b79116d067e8f20d5365ae0dae6bd19dc8
Commit:        3436d5b79116d067e8f20d5365ae0dae6bd19dc8
Parent:        b6e3080fff7f101f2bbec21a7757e54e6026d61d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 10 16:10:16 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

report: add pv_in_use field to display whether PV is in use or not

For example:

$ pvs -o pv_name,vg_name,pv_in_use
  PV         VG     InUse
  /dev/sda   vg      used
  /dev/sdb
  /dev/sdc           used

(sda is part of vg - it's used
 sdb is not part of vg - it's not used
 sdc is part of vg, but MDAs missing - it's used)
---
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   13 +++++++++++++
 lib/report/values.h     |    1 +
 4 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 5cf9d04..e6f8485 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -138,6 +138,7 @@ FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata ar
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
 FIELD(PVS, pv, SIZ, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
 FIELD(PVS, pv, SIZ, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
+FIELD(PVS, pv, BIN, "PInUse", id, 6, pvinuse, pv_in_use, "Set if PV is used.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ef5a671..118e659 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -190,6 +190,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_exported_get prop_not_implemented_get
 #define _pv_missing_set prop_not_implemented_set
 #define _pv_missing_get prop_not_implemented_get
+#define _pv_in_use_get prop_not_implemented_get
+#define _pv_in_use_set prop_not_implemented_set
 
 #define _vg_permissions_set prop_not_implemented_set
 #define _vg_permissions_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 34e71f2..f7f3775 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2866,6 +2866,19 @@ static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, missing, GET_FIRST_RESERVED_NAME(pv_missing_y), private);
 }
 
+static int _pvinuse_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	int used = is_used_pv(pv);
+
+	if (used < 0)
+		return _binary_undef_disp(rh, mem, field, private);
+
+	return _binary_disp(rh, mem, field, used, GET_FIRST_RESERVED_NAME(pv_in_use_y), private);
+}
+
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index 1db85a2..8a430fc 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -52,6 +52,7 @@ TYPE_RESERVED_VALUE(NUM, NOFLAG, num_undef_64, "Reserved value for undefined num
 FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")
 FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "", "exported")
 FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "", "missing")
+FIELD_RESERVED_BINARY_VALUE(pv_in_use, pv_in_use, "", "used", "in use")
 
 /* Reserved values for VG fields */
 FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")


