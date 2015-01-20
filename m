From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:03:03 +0000 (UTC)
Subject: master - report: seg_monitor undefined
Message-ID: <20150120140303.F361E60D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d80d832ae963e1d7bae94e96fd2d5362042fbfea
Commit:        d80d832ae963e1d7bae94e96fd2d5362042fbfea
Parent:        ae8b9baa04d8d24133ec7a2e80762ae5c7b6490f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 14:36:21 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 15:02:10 2015 +0100

report: seg_monitor  undefined

Add 'undefined' value for segment which do not support monitoring.
Fixes crash for commands like 'pvs -o+seg_monitor'.
---
 WHATS_NEW           |    1 +
 lib/metadata/lv.c   |    1 +
 lib/report/report.c |    7 ++++++-
 lib/report/values.h |    1 +
 4 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c96d5b..022e4cf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Report segment types without monitoring support as undefined.
   Support lvchange --errorwhenfull for thin pools.
   Improve the processing and reporting of duplicate PVs.
   Report lv_health_status and health attribute also for thin pool.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index cb6577d..540eedb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -157,6 +157,7 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
 	if ((dmeventd_monitor_mode() != 1) ||
+	    !segm->segtype->ops ||
 	    !segm->segtype->ops->target_monitored)
 		/* Nothing to do, monitoring not supported */;
 	else if (lv_is_cow_covering_origin(seg->lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 4338190..01e8f06 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -776,9 +776,14 @@ static int _segmonitor_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)
 {
+	const struct lv_segment *seg = (const struct lv_segment *)data;
 	char *str;
 
-	if (!(str = lvseg_monitor_dup(mem, (const struct lv_segment *)data)))
+	if (!seg->segtype->ops || !seg->segtype->ops->target_monitored)
+		return _field_set_value(field, GET_FIRST_RESERVED_NAME(seg_monitor_undef),
+					GET_FIELD_RESERVED_VALUE(seg_monitor_undef));
+
+	if (!(str = lvseg_monitor_dup(mem, seg)))
 		return_0;
 
 	return _field_set_value(field, str, NULL);
diff --git a/lib/report/values.h b/lib/report/values.h
index 2b2a4d3..9d7b272 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -88,6 +88,7 @@ FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_V
 
 /* Reserved values for SEG fields */
 FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(seg_monitor, seg_monitor_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(lv_health_status, health_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")


