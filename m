From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Sep 2009 17:43:52 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c
Message-ID: <20090930174352.11315.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-30 17:43:52

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 

Log message:
	Factor out poll_mirror_progress and introduce progress_t.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1283&r2=1.1284
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2009/09/30 14:19:00	1.1283
+++ LVM2/WHATS_NEW	2009/09/30 17:43:51	1.1284
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Factor out poll_mirror_progress and introduce progress_t.
   Distinguish between powers of 1000 and powers of 1024 in unit suffixes.
   Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
   Generalise polldaemon code by changing mirror-specific variable names.
--- LVM2/tools/polldaemon.c	2009/09/29 19:35:26	1.24
+++ LVM2/tools/polldaemon.c	2009/09/30 17:43:51	1.25
@@ -63,6 +63,43 @@
 	return 1;
 }
 
+typedef enum {
+	PROGRESS_CHECK_FAILED = 0,
+	PROGRESS_UNFINISHED = 1,
+	PROGRESS_FINISHED_SEGMENT = 2,
+	PROGRESS_FINISHED_ALL = 3
+} progress_t;
+
+progress_t poll_mirror_progress(struct cmd_context *cmd,
+				struct logical_volume *lv, const char *name,
+				struct daemon_parms *parms)
+{
+	float segment_percent = 0.0, overall_percent = 0.0;
+	uint32_t event_nr = 0;
+
+	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
+			       &event_nr)) {
+		log_error("ABORTING: Mirror percentage check failed.");
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	overall_percent = copy_percent(lv);
+	if (parms->progress_display)
+		log_print("%s: %s: %.1f%%", name, parms->progress_title,
+			  overall_percent);
+	else
+		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
+			    overall_percent);
+
+	if (segment_percent < 100.0)
+		return PROGRESS_UNFINISHED;
+
+	if (overall_percent >= 100.0)
+		return PROGRESS_FINISHED_ALL;
+
+	return PROGRESS_FINISHED_SEGMENT;
+}
+
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
@@ -70,8 +107,7 @@
 			    int *finished)
 {
 	struct dm_list *lvs_changed;
-	float segment_percent = 0.0, overall_percent = 0.0;
-	uint32_t event_nr = 0;
+	progress_t progress;
 
 	/* By default, caller should not retry */
 	*finished = 1;
@@ -86,21 +122,11 @@
 		return 0;
 	}
 
-	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
-			       &event_nr)) {
-		log_error("ABORTING: Mirror percentage check failed.");
-		return 0;
-	}
-
-	overall_percent = copy_percent(lv);
-	if (parms->progress_display)
-		log_print("%s: %s: %.1f%%", name, parms->progress_title,
-			  overall_percent);
-	else
-		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
-			    overall_percent);
+	progress = poll_mirror_progress(cmd, lv, name, parms);
+	if (progress == PROGRESS_CHECK_FAILED)
+		return_0;
 
-	if (segment_percent < 100.0) {
+	if (progress == PROGRESS_UNFINISHED) {
 		/* The only case the caller *should* try again later */
 		*finished = 0;
 		return 1;
@@ -112,7 +138,7 @@
 	}
 
 	/* Finished? Or progress to next segment? */
-	if (overall_percent >= 100.0) {
+	if (progress == PROGRESS_FINISHED_ALL) {
 		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
 			return 0;
 	} else {


