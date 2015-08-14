From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:22 +0000 (UTC)
Subject: master - dmstats: add 'area_offset' field to stats reports
Message-ID: <20150814210522.AB55960358@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f3b81bb2e7de61457ec0f2a72f381b9992421c6
Commit:        0f3b81bb2e7de61457ec0f2a72f381b9992421c6
Parent:        00ed52365916753d0bd6eb0de09c46ad782fec2e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 21:49:40 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

dmstats: add 'area_offset' field to stats reports

---
 tools/dmsetup.c |   32 ++++++++++++++++++++++++++++++--
 1 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 74e7806..f69fbe4 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3319,6 +3319,34 @@ static int _dm_stats_area_start_disp(struct dm_report *rh,
 	return 1;
 }
 
+static int _dm_stats_area_offset_disp(struct dm_report *rh,
+				      struct dm_pool *mem __attribute__((unused)),
+				      struct dm_report_field *field, const void *data,
+				      void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t area_offset;
+	const char *repstr;
+	double *sortval;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_current_area_offset(dms, &area_offset))
+		return_0;
+
+	if (!(repstr = dm_size_to_string(mem, area_offset, units, 1, factor,
+					 _show_units(), DM_SIZE_UNIT)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = (double) area_offset;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
 static int _dm_stats_area_len_disp(struct dm_report *rh,
 				      struct dm_pool *mem __attribute__((unused)),
 				      struct dm_report_field *field, const void *data,
@@ -3976,12 +4004,12 @@ FIELD_F(STATS_META, NUM, "RgID", 5, dm_stats_region_id, "region_id", "Region ID.
 FIELD_F(STATS_META, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
 FIELD_F(STATS_META, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
 FIELD_F(STATS_META, NUM, "ArID", 5, dm_stats_area_id, "area_id", "Area ID.")
-FIELD_F(STATS_META, SIZ, "AStrt", 5, dm_stats_area_start, "area_start", "Area start.")
+FIELD_F(STATS_META, SIZ, "AStart", 5, dm_stats_area_start, "area_start", "Area offset from start of device.")
 FIELD_F(STATS_META, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
+FIELD_F(STATS_META, SIZ, "AOff", 5, dm_stats_area_offset, "area_offset", "Area offset from start of region.")
 FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
-
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


