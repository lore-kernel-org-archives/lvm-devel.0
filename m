From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 11:25:29 -0400
Subject: master - vgs: add report field for shared
Message-ID: <201805311525.w4VFPTbJ010921@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdaa7e2e87d4a59b39e701961da6961f371ca980
Commit:        fdaa7e2e87d4a59b39e701961da6961f371ca980
Parent:        2beb3009bd7e34604dbd4f03c95fb7cd85eb98a6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 10:23:03 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 10:23:03 2018 -0500

vgs: add report field for shared

equivalent to a non-empty -o locktype.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    5 +++++
 lib/report/columns.h             |    1 +
 lib/report/properties.c          |    2 ++
 lib/report/report.c              |    8 ++++++++
 lib/report/values.h              |    1 +
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ccf6004..916d029 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1310,6 +1310,7 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 			      const char *vg_name_new);
 
 int is_lockd_type(const char *lock_type);
+int vg_is_shared(const struct volume_group *vg);
 
 int is_system_id_allowed(struct cmd_context *cmd, const char *system_id);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index da66e15..ab53bfa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -6052,6 +6052,11 @@ int is_lockd_type(const char *lock_type)
 	return 0;
 }
 
+int vg_is_shared(const struct volume_group *vg)
+{
+	return (vg->lock_type && is_lockd_type(vg->lock_type));
+}
+
 int vg_strip_outdated_historical_lvs(struct volume_group *vg) {
 	struct glv_list *glvl, *tglvl;
 	time_t current_time = time(NULL);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index be39ed9..827a157 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -211,6 +211,7 @@ FIELD(VGS, vg, BIN, "Exported", cmd, 10, vgexported, vg_exported, "Set if VG is
 FIELD(VGS, vg, BIN, "Partial", cmd, 10, vgpartial, vg_partial, "Set if VG is partial.", 0)
 FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_policy, "VG allocation policy.", 0)
 FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
+FIELD(VGS, vg, BIN, "Shared", cmd, 7, vgshared, vg_shared, "Set if VG is shared.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 0, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, SIZ, "VFree", cmd, 0, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", cmd, 0, vgsystemid, vg_sysid, "System ID of the VG indicating which host owns it.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8e86b7a..72c8f32 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -213,6 +213,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _vg_allocation_policy_get prop_not_implemented_get
 #define _vg_clustered_set prop_not_implemented_set
 #define _vg_clustered_get prop_not_implemented_get
+#define _vg_shared_set prop_not_implemented_set
+#define _vg_shared_get prop_not_implemented_get
 
 #define _lv_layout_set prop_not_implemented_set
 #define _lv_layout_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 01ab627..19f0f5c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3385,6 +3385,14 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, clustered, GET_FIRST_RESERVED_NAME(vg_clustered_y), private);
 }
 
+static int _vgshared_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
+{
+	int shared = (vg_is_shared((const struct volume_group *) data)) != 0;
+	return _binary_disp(rh, mem, field, shared, GET_FIRST_RESERVED_NAME(vg_shared_y), private);
+}
+
 static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index 7c53651..96729ef 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -60,6 +60,7 @@ FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")
 FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "", "exported")
 FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
+FIELD_RESERVED_BINARY_VALUE(vg_shared, vg_shared, "", "shared")
 FIELD_RESERVED_VALUE(NAMED, vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(NAMED, vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(NOFLAG, vg_mda_copies, vg_mda_copies_unmanaged, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "unmanaged")


