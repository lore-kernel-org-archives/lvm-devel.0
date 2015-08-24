From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Aug 2015 19:04:22 +0000 (UTC)
Subject: master - dmstats: add 'precise' flag field to stats report
Message-ID: <20150824190422.ECBFF60993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=463f59eca4330300c549b40603065b8640fdb790
Commit:        463f59eca4330300c549b40603065b8640fdb790
Parent:        e4145ebc47a833d443a7c8bcec26d9d2ec9e5518
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:09:43 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 24 20:03:21 2015 +0100

dmstats: add 'precise' flag field to stats report

Add a flag indicating whether or not precise_timestamps are enabled for
a given region or area.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 01ceefb..28bc933 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.106 -
 ===================================
+  Add 'precise' column to statistics reports.
   Add --precise switch to 'dmstats create' to request nanosecond counters.
   Add precise argument to dm_stats_create_region().
   Add support to libdm-stats for precise_timestamps
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e98bdcd..dcf44de 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3425,6 +3425,17 @@ static int _dm_stats_aux_data_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const *) &aux_data);
 }
 
+static int _dm_stats_precise_disp(struct dm_report *rh,
+				  struct dm_pool *mem __attribute__((unused)),
+				  struct dm_report_field *field, const void *data,
+				  void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	int precise;
+	precise = dm_stats_get_current_region_precise_timestamps(dms);
+	return dm_report_field_int(rh, field, (const int *) &precise);
+}
+
 static int _dm_stats_rrqm_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -4021,6 +4032,7 @@ FIELD_F(STATS_META, SIZ, "AOff", 5, dm_stats_area_offset, "area_offset", "Area o
 FIELD_F(STATS_META, NUM, "#Areas", 3, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
+FIELD_F(STATS_META, STR, "Precise", 5, dm_stats_precise, "precise", "Set if the nanosecond precision timers are enabled.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


