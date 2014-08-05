From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  5 Aug 2014 01:15:25 +0000 (UTC)
Subject: master - report: Remove lv_volume_type field.
Message-ID: <20140805011525.874B461073@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e94442bffa26d51a67b0102daac4d9f755fe5343
Commit:        e94442bffa26d51a67b0102daac4d9f755fe5343
Parent:        2dac5525fb39f83a8088c10ae6c9bc0131a01433
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 5 02:04:16 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 5 02:04:16 2014 +0100

report: Remove lv_volume_type field.

Like lv_target_type, this field needs reworking.
---
 lib/report/columns.h    |    2 +-
 lib/report/properties.c |    4 ++--
 lib/report/report.c     |    2 ++
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0d95806..1761a6d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -39,7 +39,7 @@ FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Bla
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
-FIELD(LVS, lv, STR, "Type", lvid, 10, lvvolumetype, lv_volume_type, "LV volume type.", 0)
+//FIELD(LVS, lv, STR, "Type", lvid, 10, lvvolumetype, lv_volume_type, "LV volume type.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
 FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Set if mirror/RAID image is synchronized.", 0)
 FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Set if snapshot LV is being merged to origin.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 72d689d..3be44f2 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -179,8 +179,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _vg_clustered_set prop_not_implemented_set
 #define _vg_clustered_get prop_not_implemented_get
 
-#define _lv_volume_type_set prop_not_implemented_set
-#define _lv_volume_type_get prop_not_implemented_get
+//#define _lv_volume_type_set prop_not_implemented_set
+//#define _lv_volume_type_get prop_not_implemented_get
 #define _lv_initial_image_sync_set prop_not_implemented_set
 #define _lv_initial_image_sync_get prop_not_implemented_get
 #define _lv_image_synced_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index cea2c3c..842a1a5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1318,6 +1318,7 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered_y), private);
 }
 
+/* FIXME Replace with something that provides a complete unique description for every combination.
 static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
@@ -1325,6 +1326,7 @@ static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
 	const char *type = lv_type_name((const struct logical_volume *) data);
 	return _string_disp(rh, mem, field, &type, private);
 }
+*/
 
 static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 				    struct dm_report_field *field,


