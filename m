From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:25 -0500
Subject: master - libdm-stats: correct checking of dm_snprintf error
Message-ID: <201802122120.w1CLKPW1023643@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60b61f2db3d6e98329213e11b65581ea1ee080a5
Commit:        60b61f2db3d6e98329213e11b65581ea1ee080a5
Parent:        afdbb28f7222b3a5a38964d47d750aad8aec12f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 12 10:27:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:13:57 2018 +0100

libdm-stats: correct checking of dm_snprintf error

Function dm_snprintf returns -1 on error, while 0 is still
considered valid result code so correcting error path testing.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |   36 ++++++++++++++++++------------------
 tools/dmsetup.c     |   22 +++++++++++-----------
 3 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index bf3ae19..52593c5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Fix tests for failing dm_snprintf() in stats code.
   Parsing mirror status accepts 'userspace' keyword in status.
   Introduce dm_malloc_aligned for page alignment of buffers.
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index bc49867..c74444a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1894,10 +1894,10 @@ static int _stats_set_aux(struct dm_stats *dms,
 		}
 	}
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_set_aux " FMTu64 " %s%s%s ",
-			 region_id, (group_tag) ? group_tag : "",
-			 (group_tag) ? DMS_AUX_SEP : "",
-			 (strlen(aux_data)) ? aux_data : "-")) {
+	if (dm_snprintf(msg, sizeof(msg), "@stats_set_aux " FMTu64 " %s%s%s ",
+			region_id, (group_tag) ? group_tag : "",
+			(group_tag) ? DMS_AUX_SEP : "",
+			(strlen(aux_data)) ? aux_data : "-") < 0) {
 		log_error("Could not prepare @stats_set_aux message");
 		goto bad;
 	}
@@ -1940,8 +1940,8 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 		program_id = dms->program_id;
 
 	if (start || len) {
-		if (!dm_snprintf(range, sizeof(range), FMTu64 "+" FMTu64,
-				 start, len)) {
+		if (dm_snprintf(range, sizeof(range), FMTu64 "+" FMTu64,
+				start, len) < 0) {
 			log_error(err_fmt, "range");
 			return 0;
 		}
@@ -1971,11 +1971,11 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	} else
 		opt_args = dm_strdup("");
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64
-			 " %s %s %s", (start || len) ? range : "-",
-			 (step < 0) ? "/" : "",
-			 (uint64_t)llabs(step),
-			 opt_args, program_id, aux_data)) {
+	if (dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64
+			" %s %s %s", (start || len) ? range : "-",
+			(step < 0) ? "/" : "",
+			(uint64_t)llabs(step),
+			opt_args, program_id, aux_data) < 0) {
 		log_error(err_fmt, "message");
 		dm_free((void *) opt_args);
 		return 0;
@@ -2079,7 +2079,7 @@ static int _stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 			return 0;
 		}
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
+	if (dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id) < 0) {
 		log_error("Could not prepare @stats_delete message.");
 		return 0;
 	}
@@ -2163,7 +2163,7 @@ int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_clear " FMTu64, region_id)) {
+	if (dm_snprintf(msg, sizeof(msg), "@stats_clear " FMTu64, region_id) < 0) {
 		log_error("Could not prepare @stats_clear message.");
 		return 0;
 	}
@@ -2188,15 +2188,15 @@ static struct dm_task *_stats_print_region(struct dm_stats *dms,
 	struct dm_task *dmt = NULL;
 
 	if (start_line || num_lines)
-		if (!dm_snprintf(lines, sizeof(lines),
-				 "%u %u", start_line, num_lines)) {
+		if (dm_snprintf(lines, sizeof(lines),
+				"%u %u", start_line, num_lines) < 0) {
 			log_error(err_fmt, "row specification");
 			return NULL;
 		}
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_print%s " FMTu64 " %s",
-			 (clear) ? "_clear" : "",
-			 region_id, (start_line || num_lines) ? lines : "")) {
+	if (dm_snprintf(msg, sizeof(msg), "@stats_print%s " FMTu64 " %s",
+			(clear) ? "_clear" : "",
+			region_id, (start_line || num_lines) ? lines : "") < 0) {
 		log_error(err_fmt, "message");
 		return NULL;
 	}
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e85680f..cc47d11 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4051,7 +4051,7 @@ static int _dm_stats_rrqm_disp(struct dm_report *rh,
 					    DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", rrqm))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", rrqm) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4082,7 +4082,7 @@ static int _dm_stats_wrqm_disp(struct dm_report *rh,
 					    DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", wrqm))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", wrqm) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4113,7 +4113,7 @@ static int _dm_stats_rs_disp(struct dm_report *rh,
 					DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", rs))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", rs) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4144,7 +4144,7 @@ static int _dm_stats_ws_disp(struct dm_report *rh,
 					 DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", ws))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", ws) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4265,7 +4265,7 @@ static int _dm_stats_qusz_disp(struct dm_report *rh,
 					     DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", qusz))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", qusz) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4299,7 +4299,7 @@ static int _dm_stats_await_disp(struct dm_report *rh,
 	/* display in msecs */
 	await /= NSEC_PER_MSEC;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", await))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", await) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4333,7 +4333,7 @@ static int _dm_stats_r_await_disp(struct dm_report *rh,
 	/* display in msecs */
 	r_await /= NSEC_PER_MSEC;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", r_await))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", r_await) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4367,7 +4367,7 @@ static int _dm_stats_w_await_disp(struct dm_report *rh,
 	/* display in msecs */
 	w_await /= NSEC_PER_MSEC;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", w_await))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", w_await) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4397,7 +4397,7 @@ static int _dm_stats_tput_disp(struct dm_report *rh,
 				     DM_STATS_AREA_CURRENT))
 		return_0;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", tput))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", tput) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4431,7 +4431,7 @@ static int _dm_stats_svctm_disp(struct dm_report *rh,
 	/* display in msecs */
 	svctm /= NSEC_PER_MSEC;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%.2f", svctm))
+	if (dm_snprintf(buf, sizeof(buf), "%.2f", svctm) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))
@@ -4487,7 +4487,7 @@ static int _dm_stats_sample_interval_disp(struct dm_report *rh,
 
 	*sortval = (double)_last_interval / (double) NSEC_PER_SEC;
 
-	if (!dm_snprintf(buf, sizeof(buf), "%2.6f", *sortval))
+	if (dm_snprintf(buf, sizeof(buf), "%2.6f", *sortval) < 0)
 		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, buf)))


