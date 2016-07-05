From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:48 +0000 (UTC)
Subject: master - dmstats: add stats_name field
Message-ID: <20160705185448.B154C61253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=402d840aa726277a10ed026c7c3a660800669b6d
Commit:        402d840aa726277a10ed026c7c3a660800669b6d
Parent:        b55daa28e89ebc19da1292baaeeed437501aaeec
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jun 13 14:28:37 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: add stats_name field

To allow the names used to describe statistics report objects to
change (for e.g to support groups and region and group aliases)
introduce a new "stats_name" field that evaluates to the correct
name for the object being reported.
---
 tools/dmsetup.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9f63608..f7a3f74 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3462,6 +3462,19 @@ static int _dm_stats_aux_data_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const *) &aux_data);
 }
 
+static int _dm_stats_name_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *stats_name;
+	if (!(stats_name = dm_stats_get_alias(dms, DM_STATS_REGION_CURRENT)))
+		return_0;
+
+	return dm_report_field_string(rh, field, (const char * const *) &stats_name);
+}
+
 static int _dm_stats_precise_disp(struct dm_report *rh,
 				  struct dm_pool *mem __attribute__((unused)),
 				  struct dm_report_field *field, const void *data,
@@ -4229,6 +4242,7 @@ FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nano
 FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The number of histogram bins configured.")
 FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
 FIELD_F(STATS_META, STR, "Histogram Ranges", 16, dm_stats_hist_ranges, "hist_ranges", "Latency histogram bin ranges.")
+FIELD_F(STATS, STR, "Name", 16, dm_stats_name, "stats_name", "Stats name of current row.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


