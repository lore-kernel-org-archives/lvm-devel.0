From: David Teigland <teigland@sourceware.org>
Date: Tue,  1 Sep 2020 22:14:29 +0000 (GMT)
Subject: master - integrity: report mismatches
Message-ID: <20200901221429.9CC95386F01F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed249a2c539098aa4451b475cbf461212a93f77d
Commit:        ed249a2c539098aa4451b475cbf461212a93f77d
Parent:        47b5fb138cef3e49357af99004275f36d346b0f2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 1 16:15:31 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 1 17:13:21 2020 -0500

integrity: report mismatches

with lvs -o integritymismatches

reported for integrity images, which may report
different values
---
 lib/metadata/integrity_manip.c   | 41 ++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |  1 +
 lib/report/columns.h             |  1 +
 lib/report/properties.c          | 11 +++++++++++
 lib/report/report.c              | 15 +++++++++++++++
 5 files changed, 69 insertions(+)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 290b7a863..6b2d352a7 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -885,3 +885,44 @@ int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_s
 	return 0;
 }
 
+int lv_integrity_mismatches(struct cmd_context *cmd,
+			    const struct logical_volume *lv,
+			    uint64_t *mismatches)
+{
+	struct lv_with_info_and_seg_status status;
+
+	memset(&status, 0, sizeof(status));
+	status.seg_status.type = SEG_STATUS_NONE;
+
+	status.seg_status.seg = first_seg(lv);
+
+	/* FIXME: why reporter_pool? */
+	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024))) {
+		log_error("Failed to get mem for LV status.");
+		return 0;
+	}
+
+	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 1, 1)) {
+		log_error("Failed to get device mapper status for %s", display_lvname(lv));
+		goto fail;
+	}
+
+	if (!status.info.exists)
+		goto fail;
+
+	if (status.seg_status.type != SEG_STATUS_INTEGRITY) {
+		log_error("Invalid device mapper status type (%d) for %s",
+			  (uint32_t)status.seg_status.type, display_lvname(lv));
+		goto fail;
+	}
+
+	*mismatches = status.seg_status.integrity->number_of_mismatches;
+
+	dm_pool_destroy(status.seg_status.mem);
+	return 1;
+
+fail:
+	dm_pool_destroy(status.seg_status.mem);
+	return 0;
+}
+
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e5c8e4305..670656a0f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1415,5 +1415,6 @@ int lv_raid_has_integrity(struct logical_volume *lv);
 int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh);
 int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_settings **isettings);
 int integrity_mode_set(const char *mode, struct integrity_settings *settings);
+int lv_integrity_mismatches(struct cmd_context *cmd, const struct logical_volume *lv, uint64_t *mismatches);
 
 #endif
diff --git a/lib/report/columns.h b/lib/report/columns.h
index f784de5cf..426a32c50 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -86,6 +86,7 @@ FIELD(LVS, lv, NUM, "MinSync", lvid, 0, raidminrecoveryrate, raid_min_recovery_r
 FIELD(LVS, lv, NUM, "MaxSync", lvid, 0, raidmaxrecoveryrate, raid_max_recovery_rate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, STR, "IntegMode", lvid, 0, raidintegritymode, raidintegritymode, "The integrity mode", 0)
 FIELD(LVS, lv, NUM, "IntegBlkSize", lvid, 0, raidintegrityblocksize, raidintegrityblocksize, "The integrity block size", 0)
+FIELD(LVS, lv, NUM, "IntegMismatches", lvid, 0, integritymismatches, integritymismatches, "The number of integrity mismatches.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 0, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Move UUID", lvid, 38, movepvuuid, move_pv_uuid, "For pvmove, the UUID of Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 0, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index baf841434..d4ac8c47e 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -121,6 +121,15 @@ static uint32_t _raidintegrityblocksize(const struct logical_volume *lv)
 	return settings->block_size;
 }
 
+static uint64_t _integritymismatches(const struct logical_volume *lv)
+{
+	uint64_t cnt;
+
+	if (!lv_integrity_mismatches(lv->vg->cmd, lv, &cnt))
+		return 0;
+	return cnt;
+}
+
 static dm_percent_t _snap_percent(const struct logical_volume *lv)
 {
 	dm_percent_t percent;
@@ -434,6 +443,8 @@ GET_LV_STR_PROPERTY_FN(raidintegritymode, _raidintegritymode(lv))
 #define _raidintegritymode_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(raidintegrityblocksize, _raidintegrityblocksize(lv))
 #define _raidintegrityblocksize_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(integritymismatches, _integritymismatches(lv))
+#define _integritymismatches_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv_uuid, lv_move_pv_uuid_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index dae797dee..cd7971562 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3323,6 +3323,21 @@ static int _raidintegrityblocksize_disp(struct dm_report *rh __attribute__((unus
 	return dm_report_field_uint32(rh, field, &settings->block_size);
 }
 
+static int _integritymismatches_disp(struct dm_report *rh __attribute__((unused)),
+				   struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data,
+				   void *private __attribute__((unused)))
+{
+	struct logical_volume *lv = (struct logical_volume *) data;
+	uint64_t mismatches = 0;
+
+	if (lv_is_integrity(lv) && lv_integrity_mismatches(lv->vg->cmd, lv, &mismatches))
+		return dm_report_field_uint64(rh, field, &mismatches);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)


