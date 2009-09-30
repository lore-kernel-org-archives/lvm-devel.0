From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 30 Sep 2009 19:08:10 -0400
Subject: [PATCH v2 2/2] Change copy_percent to returned a defined TARGET_STATUS_*
In-Reply-To: <1254352090-23243-1-git-send-email-snitzer@redhat.com>
References: <1254352090-23243-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254352090-23243-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Change copy_percent to return status (one of TARGET_STATUS_ macros) and to
return float variable by reference. So that there are no more decisions made
based on the comparison of floating point value.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>

---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/mirror.c            |    6 ++++--
 lib/report/report.c              |    2 +-
 tools/polldaemon.c               |    6 +++---
 4 files changed, 9 insertions(+), 7 deletions(-)

Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -684,7 +684,7 @@ struct logical_volume *find_pvmove_lv_fr
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-float copy_percent(struct logical_volume *lv_mirr);
+int copy_percent(struct logical_volume *lv_mirr, float *percent);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -1113,7 +1113,7 @@ struct dm_list *lvs_using_lv(struct cmd_
 	return lvs;
 }
 
-float copy_percent(struct logical_volume *lv_mirr)
+int copy_percent(struct logical_volume *lv_mirr, float *percent)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -1127,7 +1127,9 @@ float copy_percent(struct logical_volume
 			numerator += seg->area_len;
 	}
 
-	return denominator ? (float) numerator *100 / denominator : 100.0;
+	*percent = denominator ? (float) numerator * 100 / denominator : 100.0;
+	return denominator == numerator ? TARGET_STATUS_FINISHED
+					: TARGET_STATUS_PROCESSING;
 }
 
 /*
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -1072,7 +1072,7 @@ static int _copypercent_disp(struct dm_r
 		return 1;
 	}
 
-	percent = copy_percent(lv);
+	copy_percent(lv, &percent);
 
 	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -68,7 +68,7 @@ progress_t poll_mirror_progress(struct c
 				struct daemon_parms *parms)
 {
 	float segment_percent = 0.0, overall_percent = 0.0;
-	int status;
+	int status, overall_status;
 	uint32_t event_nr = 0;
 
 	if (!(status = lv_mirror_percent(cmd, lv, !parms->interval,
@@ -77,7 +77,7 @@ progress_t poll_mirror_progress(struct c
 		return PROGRESS_CHECK_FAILED;
 	}
 
-	overall_percent = copy_percent(lv);
+	overall_status = copy_percent(lv, &overall_percent);
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", name, parms->progress_title,
 			  overall_percent);
@@ -88,7 +88,7 @@ progress_t poll_mirror_progress(struct c
 	if (status < TARGET_STATUS_FINISHED)
 		return PROGRESS_UNFINISHED;
 
-	if (overall_percent >= 100.0)
+	if (overall_percent == TARGET_STATUS_FINISHED)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_FINISHED_SEGMENT;


