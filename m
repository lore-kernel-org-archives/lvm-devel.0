From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:00:49 +0000 (UTC)
Subject: master - report: Remove lv_target_type field.
Message-ID: <20140722200049.4C504601B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50961f43d03aec309dd06e121d03a6fd7b301850
Commit:        50961f43d03aec309dd06e121d03a6fd7b301850
Parent:        99e3c1301294fdd1cd8be25adb303e24e1260c76
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 22 20:57:57 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 22 20:57:57 2014 +0100

report: Remove lv_target_type field.

This field is too complicated to be useful on its own and either needs
redefining or splitting up into multiple fields.
---
 lib/report/columns.h    |    2 +-
 lib/report/properties.c |    5 ++---
 lib/report/report.c     |    2 ++
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index af39008..0d95806 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -49,7 +49,7 @@ FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_loc
 FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV has fixed minor number assigned.", 0)
 FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
 FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
-FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kernel target type the LV is related to.", 0)
+//FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kernel target type the LV is related to.", 0)
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index b4e183f..72d689d 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -216,11 +216,10 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_inactive_table_get prop_not_implemented_get
 #define _lv_device_open_set prop_not_implemented_set
 #define _lv_device_open_get prop_not_implemented_get
-#define _lv_target_type_set prop_not_implemented_set
-#define _lv_target_type_get prop_not_implemented_get
+//#define _lv_target_type_set prop_not_implemented_set
+//#define _lv_target_type_get prop_not_implemented_get
 #define _lv_health_status_set prop_not_implemented_set
 #define _lv_health_status_get prop_not_implemented_get
-#define _lv_target_type_get prop_not_implemented_get
 #define _lv_skip_activation_set prop_not_implemented_set
 #define _lv_skip_activation_get prop_not_implemented_get
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 91dfac0..cea2c3c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1603,6 +1603,7 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_undef_disp(rh, mem, field, private);
 }
 
+/* FIXME Replace with something that provides a complete unique description for every combination.
 static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
@@ -1629,6 +1630,7 @@ static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	return _string_disp(rh, mem, field, &target_type, private);
 }
+*/
 
 static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,


