From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Oct 2009 01:04:28 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091001010428.2480.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-01 01:04:27

Modified files:
	lib/metadata   : metadata-exported.h mirror.c 
	lib/report     : report.c 
	tools          : polldaemon.c 

Log message:
	Add percent_range to copy_percent too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/metadata/metadata-exported.h	2009/10/01 00:35:29	1.113
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/01 01:04:27	1.114
@@ -691,7 +691,8 @@
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-float copy_percent(struct logical_volume *lv_mirr);
+float copy_percent(struct logical_volume *lv_mirr,
+		   percent_range_t *percent_range);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
--- LVM2/lib/metadata/mirror.c	2009/10/01 00:35:29	1.90
+++ LVM2/lib/metadata/mirror.c	2009/10/01 01:04:27	1.91
@@ -1114,7 +1114,8 @@
 	return lvs;
 }
 
-float copy_percent(struct logical_volume *lv_mirr)
+float copy_percent(struct logical_volume *lv_mirr,
+		   percent_range_t *percent_range)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -1128,6 +1129,13 @@
 			numerator += seg->area_len;
 	}
 
+	if (!denominator || (numerator == denominator))
+		*percent_range = PERCENT_100;
+	else if (numerator == 0)
+		*percent_range = PERCENT_0;
+	else
+		*percent_range = PERCENT_0_TO_100;
+		
 	return denominator ? (float) numerator *100 / denominator : 100.0;
 }
 
--- LVM2/lib/report/report.c	2009/10/01 00:35:30	1.103
+++ LVM2/lib/report/report.c	2009/10/01 01:04:27	1.104
@@ -1054,7 +1054,8 @@
 	return 1;
 }
 
-static int _copypercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
+static int _copypercent_disp(struct dm_report *rh __attribute((unused)),
+			     struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute((unused)))
 {
@@ -1077,7 +1078,7 @@
 		return 1;
 	}
 
-	percent = copy_percent(lv);
+	percent = copy_percent(lv, &percent_range);
 
 	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
--- LVM2/tools/polldaemon.c	2009/10/01 00:35:30	1.27
+++ LVM2/tools/polldaemon.c	2009/10/01 01:04:27	1.28
@@ -68,7 +68,7 @@
 				struct daemon_parms *parms)
 {
 	float segment_percent = 0.0, overall_percent = 0.0;
-	percent_range_t percent_range;
+	percent_range_t percent_range, overall_percent_range;
 	uint32_t event_nr = 0;
 
 	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
@@ -78,7 +78,7 @@
 		return PROGRESS_CHECK_FAILED;
 	}
 
-	overall_percent = copy_percent(lv);
+	overall_percent = copy_percent(lv, &overall_percent_range);
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", name, parms->progress_title,
 			  overall_percent);
@@ -89,7 +89,7 @@
 	if (percent_range != PERCENT_100)
 		return PROGRESS_UNFINISHED;
 
-	if (overall_percent >= 100.0)
+	if (overall_percent_range == PERCENT_100)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_FINISHED_SEGMENT;


