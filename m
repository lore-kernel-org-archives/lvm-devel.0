From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:01 +0000 (UTC)
Subject: master - report: add lv_historical field to identify historical LVs
Message-ID: <20160303132001.62D8F6024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2af59715235dedb0ab9f1768d6bbccfdc5d28d02
Commit:        2af59715235dedb0ab9f1768d6bbccfdc5d28d02
Parent:        e112f5ce05792885ffa5082d7073b139fe468149
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:23:43 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: add lv_historical field to identify historical LVs

The lv_historical reporting field is a simple binary field that reports
whether an LV is historical one ("historical" value or value of "1" displayed)
or not (blank string "" or value of "0" displayed).
---
 lib/report/columns.h    |    1 +
 lib/report/properties.c |    2 ++
 lib/report/report.c     |    8 ++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 35c2b2f..11d5639 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -96,6 +96,7 @@ FIELD(LVS, lv, TIM, "CTime", lvid, 26, lvtime, lv_time, "Creation time of the LV
 FIELD(LVS, lv, TIM, "RTime", lvid, 26, lvtimeremoved, lv_time_removed, "Removal time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
+FIELD(LVS, lv, BIN, "Historical", lvid, 8, lvhistorical, lv_historical, "Set if the LV is historical.", 0)
 
 FIELD(LVSINFO, lv, SNUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SNUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 030936b..9c1b23a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -253,6 +253,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_skip_activation_get prop_not_implemented_get
 #define _lv_check_needed_set prop_not_implemented_set
 #define _lv_check_needed_get prop_not_implemented_get
+#define _lv_historical_set prop_not_implemented_set
+#define _lv_historical_get prop_not_implemented_get
 
 #define _cache_total_blocks_set prop_not_implemented_set
 #define _cache_total_blocks_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 47a911e..8ef8eaf 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3385,6 +3385,14 @@ static int _lvskipactivation_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, skip_activation, "skip activation", private);
 }
 
+static int _lvhistorical_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	return _binary_disp(rh, mem, field, lv_is_historical(lv), "historical", private);
+}
+
 /*
  * Macro to generate '_cache_<cache_status_field_name>_disp' reporting function.
  * The 'cache_status_field_name' is field name from struct dm_cache_status.


