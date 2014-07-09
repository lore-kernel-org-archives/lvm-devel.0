From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:51 +0000 (UTC)
Subject: master - report: add lv_active_{locally, remotely, exclusively} LV reporting fields
Message-ID: <20140709135751.BFB14600EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bccc2bef33af081264bbc356e37efe89ef78b796
Commit:        bccc2bef33af081264bbc356e37efe89ef78b796
Parent:        b6ac8819f694d0b28fc592e89f01a8cf8e4f1802
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 9 14:28:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 9 15:57:05 2014 +0200

report: add lv_active_{locally,remotely,exclusively} LV reporting fields

lv_active_{locally,remotely,exclusively} display the original
"lv_active" field in a more separate way so that we can create
selection criteria in a binary-based form (yes/no).
---
 WHATS_NEW               |    1 +
 lib/report/columns.h    |    3 ++
 lib/report/properties.c |    6 +++++
 lib/report/report.c     |   54 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d4649e4..21668f2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Add separate lv_active_{locally,remotely,exclusively} LV reporting fields.
   Recognize "auto"/"unmanaged" values in selection for appropriate fields only.
   Add report/binary_values_as_numeric lvm.conf option for binary values as 0/1.
   Add --binary arg to pvs,vgs,lvs and {pv,vg,lv}display -C for 0/1 on reports.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 5013834..3d3d76e 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -53,6 +53,9 @@ FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kerne
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
+FIELD(LVS, lv, BIN, "ActiveLoc", lvid, 10, lvactivelocally, lv_active_locally, "Set if the LV is active locally.", 0)
+FIELD(LVS, lv, BIN, "ActiveRem", lvid, 10, lvactiveremotely, lv_active_remotely, "Set if the LV is active remotely.", 0)
+FIELD(LVS, lv, BIN, "ActiveExcl", lvid, 10, lvactiveexclusively, lv_active_exclusively, "Set if the LV is active exclusively.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, SIZ, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8fb1e92..b4e183f 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -196,6 +196,12 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_allocation_policy_get prop_not_implemented_get
 #define _lv_allocation_locked_set prop_not_implemented_set
 #define _lv_allocation_locked_get prop_not_implemented_get
+#define _lv_active_locally_set prop_not_implemented_set
+#define _lv_active_locally_get prop_not_implemented_get
+#define _lv_active_remotely_set prop_not_implemented_set
+#define _lv_active_remotely_get prop_not_implemented_get
+#define _lv_active_exclusively_set prop_not_implemented_set
+#define _lv_active_exclusively_get prop_not_implemented_get
 #define _lv_fixed_minor_set prop_not_implemented_set
 #define _lv_fixed_minor_get prop_not_implemented_get
 #define _lv_merge_failed_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index adcd2be..d28c767 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -101,6 +101,9 @@ FIELD_RESERVED_VALUE(lv_merging, lv_merging, _one64, "merging")
 FIELD_RESERVED_VALUE(lv_converting, lv_converting, _one64, "converting")
 FIELD_RESERVED_VALUE(lv_allocation_locked, lv_allocation_locked, _one64, "allocation locked", "locked")
 FIELD_RESERVED_VALUE(lv_fixed_minor, lv_fixed_minor, _one64, "fixed minor", "fixed")
+FIELD_RESERVED_VALUE(lv_active_locally, lv_active_locally, _one64, "active locally", "active", "locally")
+FIELD_RESERVED_VALUE(lv_active_remotely, lv_active_remotely, _one64, "active remotely", "active", "remotely")
+FIELD_RESERVED_VALUE(lv_active_exclusively, lv_active_exclusively, _one64, "active exclusively", "active", "exclusively")
 FIELD_RESERVED_VALUE(lv_merge_failed, lv_merge_failed, _one64, "merge failed", "failed")
 FIELD_RESERVED_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, _one64, "snapsot invalid", "invalid")
 FIELD_RESERVED_VALUE(lv_suspended, lv_suspended, _one64, "suspended")
@@ -139,6 +142,9 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 	FIELD_RESERVED_VALUE_REG(lv_converting, "lv_converting reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_allocation_locked, "lv_allocation_locked reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_fixed_minor, "lv_fixed_minor reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_active_locally, "lv_active_locally reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_active_remotely, "lv_active_remotelly reserved values")
+	FIELD_RESERVED_VALUE_REG(lv_active_exclusively, "lv_active_exclusively reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_merge_failed, "lv_merge_failed reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_snapshot_invalid, "lv_snapshot_invalid reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_suspended, "lv_suspended reserved values")
@@ -1471,6 +1477,54 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor), private);
 }
 
+static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int active_locally;
+
+	if (vg_is_clustered(lv->vg)) {
+		lv = lv_lock_holder(lv);
+		active_locally = lv_is_active_locally(lv);
+	} else
+		active_locally = lv_is_active(lv);
+
+	return _binary_disp(rh, mem, field, active_locally, FIRST_NAME(lv_active_locally), private);
+}
+
+static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
+				  struct dm_report_field *field,
+				  const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int active_remotely;
+
+	if (vg_is_clustered(lv->vg)) {
+		lv = lv_lock_holder(lv);
+		active_remotely = lv_is_active_but_not_locally(lv);
+	} else
+		active_remotely = 0;
+
+	return _binary_disp(rh, mem, field, active_remotely, FIRST_NAME(lv_active_remotely), private);
+}
+
+static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int active_exclusively;
+
+	if (vg_is_clustered(lv->vg)) {
+		lv = lv_lock_holder(lv);
+		active_exclusively = lv_is_active_exclusive(lv);
+	} else
+		active_exclusively = lv_is_active(lv);
+
+	return _binary_disp(rh, mem, field, active_exclusively, FIRST_NAME(lv_active_exclusively), private);
+}
+
 static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)


