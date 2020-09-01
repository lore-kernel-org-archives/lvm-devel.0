From: David Teigland <teigland@sourceware.org>
Date: Tue,  1 Sep 2020 22:14:28 +0000 (GMT)
Subject: master - integrity: report raidintegritymode randintegrityblocksize
Message-ID: <20200901221428.794D1385E005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47b5fb138cef3e49357af99004275f36d346b0f2
Commit:        47b5fb138cef3e49357af99004275f36d346b0f2
Parent:        f2c1de783cd1afc522b65f5deb45567c6cb2ffbf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 1 14:39:34 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 1 17:12:36 2020 -0500

integrity: report raidintegritymode randintegrityblocksize

reported for the raid lv and the integrity images
---
 lib/report/columns.h    |  2 ++
 lib/report/properties.c | 34 ++++++++++++++++++++++++++++++++
 lib/report/report.c     | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 88 insertions(+)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 31a1d1702..f784de5cf 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -84,6 +84,8 @@ FIELD(LVS, lv, STR, "SyncAction", lvid, 0, raidsyncaction, raid_sync_action, "Fo
 FIELD(LVS, lv, NUM, "WBehind", lvid, 0, raidwritebehind, raid_write_behind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
 FIELD(LVS, lv, NUM, "MinSync", lvid, 0, raidminrecoveryrate, raid_min_recovery_rate, "For RAID1, the minimum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, NUM, "MaxSync", lvid, 0, raidmaxrecoveryrate, raid_max_recovery_rate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
+FIELD(LVS, lv, STR, "IntegMode", lvid, 0, raidintegritymode, raidintegritymode, "The integrity mode", 0)
+FIELD(LVS, lv, NUM, "IntegBlkSize", lvid, 0, raidintegrityblocksize, raidintegrityblocksize, "The integrity block size", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 0, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Move UUID", lvid, 38, movepvuuid, move_pv_uuid, "For pvmove, the UUID of Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 0, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 325750559..baf841434 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -91,6 +91,36 @@ static uint32_t _raidmaxrecoveryrate(const struct logical_volume *lv)
 	return first_seg(lv)->max_recovery_rate;
 }
 
+static const char *_raidintegritymode(const struct logical_volume *lv)
+{
+	struct integrity_settings *settings;
+
+	if (lv_raid_has_integrity((struct logical_volume *)lv))
+		lv_get_raid_integrity_settings((struct logical_volume *)lv, &settings);
+	else if (lv_is_integrity(lv))
+		settings = &first_seg(lv)->integrity_settings;
+
+	if (settings->mode[0] == 'B')
+		return "bitmap";
+	if (settings->mode[0] == 'J')
+		return "journal";
+	return "unknown";
+}
+
+static uint32_t _raidintegrityblocksize(const struct logical_volume *lv)
+{
+	struct integrity_settings *settings;
+
+	if (lv_raid_has_integrity((struct logical_volume *)lv))
+		lv_get_raid_integrity_settings((struct logical_volume *)lv, &settings);
+	else if (lv_is_integrity(lv))
+		settings = &first_seg(lv)->integrity_settings;
+	else
+		return 0;
+
+	return settings->block_size;
+}
+
 static dm_percent_t _snap_percent(const struct logical_volume *lv)
 {
 	dm_percent_t percent;
@@ -400,6 +430,10 @@ GET_LV_NUM_PROPERTY_FN(raid_max_recovery_rate, _raidmaxrecoveryrate(lv))
 #define _raid_max_recovery_rate_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(raid_sync_action, _raidsyncaction(lv))
 #define _raid_sync_action_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(raidintegritymode, _raidintegritymode(lv))
+#define _raidintegritymode_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(raidintegrityblocksize, _raidintegrityblocksize(lv))
+#define _raidintegrityblocksize_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv_uuid, lv_move_pv_uuid_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index b0d514202..dae797dee 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3271,6 +3271,58 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
 }
 
+static int _raidintegritymode_disp(struct dm_report *rh __attribute__((unused)),
+				   struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data,
+				   void *private __attribute__((unused)))
+{
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct integrity_settings *settings;
+	const char *mode = NULL;
+	char *repstr;
+
+	if (lv_raid_has_integrity(lv))
+		lv_get_raid_integrity_settings(lv, &settings);
+	else if (lv_is_integrity(lv))
+		settings = &first_seg(lv)->integrity_settings;
+
+	if (settings->mode[0]) {
+		if (settings->mode[0] == 'B')
+			mode = "bitmap";
+		else if (settings->mode[0] == 'J')
+			mode = "journal";
+
+		if (mode) {
+			if (!(repstr = dm_pool_strdup(mem, mode))) {
+				log_error("Failed to allocate buffer for mode.");
+				return 0;
+			}
+			return _field_set_value(field, repstr, NULL);
+		}
+	}
+	return _field_set_value(field, "", NULL);
+}
+
+static int _raidintegrityblocksize_disp(struct dm_report *rh __attribute__((unused)),
+				   struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data,
+				   void *private __attribute__((unused)))
+{
+	struct logical_volume *lv = (struct logical_volume *) data;
+	struct integrity_settings *settings;
+
+	if (lv_raid_has_integrity(lv))
+		lv_get_raid_integrity_settings(lv, &settings);
+	else if (lv_is_integrity(lv))
+		settings = &first_seg(lv)->integrity_settings;
+	else
+		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
+
+	return dm_report_field_uint32(rh, field, &settings->block_size);
+}
+
 static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)


