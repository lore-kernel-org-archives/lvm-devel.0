From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Aug 2015 19:04:18 +0000 (UTC)
Subject: master - libdm: add per region precise timestamps property methods
Message-ID: <20150824190418.C5C0760993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=567189cc7617a4d239d0f2ea052801fe2573d011
Commit:        567189cc7617a4d239d0f2ea052801fe2573d011
Parent:        f4262026b671ac2604ec8143c6fe328e9ab159aa
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:08:18 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 24 20:03:21 2015 +0100

libdm: add per region precise timestamps property methods

---
 libdm/.exported_symbols.DM_1_02_106 |    2 ++
 libdm/libdevmapper.h                |   16 ++++++++++++++++
 libdm/libdm-stats.c                 |   12 ++++++++++++
 3 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_106 b/libdm/.exported_symbols.DM_1_02_106
index b664cc6..0bec544 100644
--- a/libdm/.exported_symbols.DM_1_02_106
+++ b/libdm/.exported_symbols.DM_1_02_106
@@ -1,3 +1,5 @@
 dm_message_supports_precise_timestamps
 dm_stats_create_region
 dm_stats_driver_supports_precise
+dm_stats_get_current_region_precise_timestamps
+dm_stats_get_region_precise_timestamps
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 71b8ce4..59eb5e9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -480,6 +480,22 @@ int dm_message_supports_precise_timestamps(void);
  */
 int dm_stats_driver_supports_precise(void);
 
+/*
+ * Returns 1 if the specified region has the precise_timestamps feature
+ * enabled (i.e. produces nanosecond-precision counter values) or 0 for
+ * a region using the default milisecond precision.
+ */
+int dm_stats_get_region_precise_timestamps(const struct dm_stats *dms,
+					   uint64_t region_id);
+
+/*
+ * Returns 1 if the region at the current cursor location has the
+ * precise_timestamps feature enabled (i.e. produces
+ * nanosecond-precision counter values) or 0 for a region using the
+ * default milisecond precision.
+ */
+int dm_stats_get_current_region_precise_timestamps(const struct dm_stats *dms);
+
 #define DM_STATS_ALL_PROGRAMS ""
 /*
  * Parse the response from a @stats_list message. dm_stats_list will
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b85300f..800bde6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1489,3 +1489,15 @@ const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms)
 {
 	return dm_stats_get_region_aux_data(dms, dms->cur_region);
 }
+
+int dm_stats_get_region_precise_timestamps(const struct dm_stats *dms,
+					   uint64_t region_id)
+{
+	struct dm_stats_region *region = &dms->regions[region_id];
+	return region->timescale == 1;
+}
+
+int dm_stats_get_current_region_precise_timestamps(const struct dm_stats *dms)
+{
+	return dm_stats_get_region_precise_timestamps(dms, dms->cur_region);
+}


