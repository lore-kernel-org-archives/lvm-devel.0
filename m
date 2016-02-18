From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 15:50:22 +0000 (UTC)
Subject: master - thin: report needs_check and fail state
Message-ID: <20160218155022.D99DC60C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f31d596c0d0fddf69b71b9553f87e780c33c9eb6
Commit:        f31d596c0d0fddf69b71b9553f87e780c33c9eb6
Parent:        0358ca3aadaddd8ed60c817abb67ea38bf07a420
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 13:19:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 16:49:34 2016 +0100

thin: report needs_check and fail state

Fix reporting of Fail thin-pool target status
as attr[8] letter 'F'.

Report  'needs_check' status from thin-pool target via
attr field [4] (letter 'c'/'C'), and also via CheckNeeded field.

TODO: think about better name here?
TODO: lots of prop_not_implemented_set
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    4 +++-
 lib/metadata/lv.c          |   12 ++++++++++++
 lib/report/columns.h       |    1 +
 lib/report/properties.c    |    2 ++
 lib/report/report.c        |   13 +++++++++++++
 lib/report/values.h        |    1 +
 7 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 27bb7e2..8d9294b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.143 -
 =====================================
+  Support reporting CheckNeeded and Fail state for thin-pool and thin LV.
   For failing thin-pool and thin volume correctly report percentage as INVALID.
   Report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary.
   Add configure --enable-dbus-service for an LVM D-Bus service.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 66a301a..2826218 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -130,7 +130,9 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	 * linear/striped, old snapshots and raids have proper
 	 * segment selected for status!
 	 */
-	if (strcmp(target_name, "cache") && strcmp(target_name, "thin-pool"))
+	if (strcmp(target_name, "cache") &&
+	    strcmp(target_name, "thin-pool") &&
+	    strcmp(target_name, "thin"))
 		return 1;
 
 	if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 526284e..98b1ddb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1129,6 +1129,12 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 			}
 		}
 
+		/* 'c' when thin-pool active with needs_check flag
+		 * 'C' for suspend */
+		if (lv_is_thin_pool(lv) &&
+		    lvdm->seg_status.thin_pool->needs_check)
+			repstr[4] = lvdm->info.suspended ? 'C' : 'c';
+
 		/*
 		 * 'R' indicates read-only activation of a device that
 		 * does not have metadata flagging it as read-only.
@@ -1190,6 +1196,12 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 			repstr[8] = 'D';
 		else if (lvdm->seg_status.thin_pool->read_only)
 			repstr[8] = 'M';
+	} else if (lv_is_thin_volume(lv) &&
+		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
+			repstr[8] = 'X'; /* Unknown */
+		else if (lvdm->seg_status.thin->fail)
+			repstr[8] = 'F';
 	}
 
 	if (lv->status & LV_ACTIVATION_SKIP)
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 7ea7f52..040caf3 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -115,6 +115,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cach
 FIELD(LVSSTATUS, lv, STR_LIST, "KCache Settings", lvid, 18, kernel_cache_settings, kernel_cache_settings, "Cache settings/parameters as set in kernel, including default values (cached segments only).", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 8, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
+FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools, whether metadata check is needed.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d23e4c9..024919c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -251,6 +251,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_health_status_get prop_not_implemented_get
 #define _lv_skip_activation_set prop_not_implemented_set
 #define _lv_skip_activation_get prop_not_implemented_get
+#define _lv_check_needed_set prop_not_implemented_set
+#define _lv_check_needed_get prop_not_implemented_get
 
 #define _cache_total_blocks_set prop_not_implemented_set
 #define _cache_total_blocks_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 542cbc4..b96dcfc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3311,6 +3311,19 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &health, private);
 }
 
+static int _lvcheckneeded_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if (lv_is_thin_pool(lvdm->lv))
+		return _binary_disp(rh, mem, field, lvdm->seg_status.thin_pool->needs_check,
+				    GET_FIRST_RESERVED_NAME(lv_check_needed_y), private);
+
+	return _binary_undef_disp(rh, mem, field, private);
+}
+
 static int _lvskipactivation_disp(struct dm_report *rh, struct dm_pool *mem,
 				  struct dm_report_field *field,
 				  const void *data, void *private)
diff --git a/lib/report/values.h b/lib/report/values.h
index 8a430fc..43c5abe 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -81,6 +81,7 @@ FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "", "inactive
 FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
 FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
+FIELD_RESERVED_BINARY_VALUE(lv_check_needed, lv_check_needed, "", "check needed", "needed")
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")


