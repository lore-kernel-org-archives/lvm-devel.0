From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:42 +0000 (UTC)
Subject: master - dmstats: add group_id report field type
Message-ID: <20160705185442.811BF61375@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4cbc8f2838ce52233151700a59e09b17a3d9a0d
Commit:        b4cbc8f2838ce52233151700a59e09b17a3d9a0d
Parent:        cda1622fef6c2160f92c88f4eab0200e4864d781
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Mar 7 18:01:45 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: add group_id report field type

---
 tools/dmsetup.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8ba12dd..5cd0ef4 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3416,6 +3416,25 @@ static int _dm_stats_area_count_disp(struct dm_report *rh,
 	return dm_report_field_uint64(rh, field, &area_count);
 }
 
+static int _dm_stats_group_id_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute__((unused)),
+				   struct dm_report_field *field, const void *data,
+				   void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t group_id;
+
+	group_id = dm_stats_get_group_id(dms,
+					 dm_stats_get_current_region(dms));
+
+	if (group_id == UINT64_MAX) {
+		dm_report_field_set_value(field, "-", &group_id);
+		return 1;
+	}
+
+	return dm_report_field_uint64(rh, field, &group_id);
+}
+
 static int _dm_stats_program_id_disp(struct dm_report *rh,
 				     struct dm_pool *mem __attribute__((unused)),
 				     struct dm_report_field *field, const void *data,
@@ -4200,6 +4219,7 @@ FIELD_F(STATS_META, SIZ, "ArStart", 7, dm_stats_area_start, "area_start", "Area
 FIELD_F(STATS_META, SIZ, "ArSize", 6, dm_stats_area_len, "area_len", "Area length.")
 FIELD_F(STATS_META, SIZ, "ArOff", 5, dm_stats_area_offset, "area_offset", "Area offset from start of region.")
 FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
+FIELD_F(STATS_META, NUM, "GrpID", 5, dm_stats_group_id, "group_id", "Group ID.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
 FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nanosecond precision counters are enabled.")


