From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2008 00:25:52 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20080715002552.29343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-15 00:25:52

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/metadata   : segtype.h 
	lib/mirror     : mirrored.c 
	lib/snapshot   : snapshot.c 

Log message:
	Cease recognising snapshot-in-use percentages returned by early development kernels.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.928&r2=1.929
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW	2008/07/10 11:30:57	1.928
+++ LVM2/WHATS_NEW	2008/07/15 00:25:51	1.929
@@ -1,6 +1,7 @@
 Version 2.02.40 - 
 ================================
-  Add "flags" metadata field (akin to "status") for backward-compatible flags.
+  Cease recognising snapshot-in-use percentages returned by early devt kernels.
+  Add backward-compatible flags field to on-disk format_text metadata.
   Fix dmeventd monitoring libraries to link against liblvm2cmd again. (2.02.39)
 
 Version 2.02.39 - 27th June 2008
--- LVM2/lib/activate/dev_manager.c	2008/06/18 11:32:14	1.138
+++ LVM2/lib/activate/dev_manager.c	2008/07/15 00:25:51	1.139
@@ -379,8 +379,7 @@
 		    !segtype->ops->target_percent(&dm->target_state, dm->mem,
 						  dm->cmd, seg, params,
 						  &total_numerator,
-						  &total_denominator,
-						  percent))
+						  &total_denominator))
 			goto_out;
 
 	} while (next);
@@ -393,7 +392,7 @@
 
 	if (total_denominator)
 		*percent = (float) total_numerator *100 / total_denominator;
-	else if (*percent < 0)
+	else
 		*percent = 100;
 
 	log_debug("LV percent: %f", *percent);
--- LVM2/lib/metadata/segtype.h	2008/06/25 16:52:26	1.20
+++ LVM2/lib/metadata/segtype.h	2008/07/15 00:25:51	1.21
@@ -77,7 +77,7 @@
 			       struct cmd_context *cmd,
 			       struct lv_segment *seg, char *params,
 			       uint64_t *total_numerator,
-			       uint64_t *total_denominator, float *percent);
+			       uint64_t *total_denominator);
 	int (*target_present) (const struct lv_segment *seg,
 			       unsigned *attributes);
 	int (*modules_needed) (struct dm_pool *mem,
--- LVM2/lib/mirror/mirrored.c	2008/04/10 18:53:36	1.55
+++ LVM2/lib/mirror/mirrored.c	2008/07/15 00:25:51	1.56
@@ -176,8 +176,7 @@
 static int _mirrored_target_percent(void **target_state, struct dm_pool *mem,
 			   struct cmd_context *cmd, struct lv_segment *seg,
 			   char *params, uint64_t *total_numerator,
-			   uint64_t *total_denominator,
-			   float *percent __attribute((unused)))
+			   uint64_t *total_denominator)
 {
 	struct mirror_state *mirr_state;
 	uint64_t numerator, denominator;
--- LVM2/lib/snapshot/snapshot.c	2008/04/07 10:23:47	1.30
+++ LVM2/lib/snapshot/snapshot.c	2008/07/15 00:25:52	1.31
@@ -95,20 +95,14 @@
 			   struct cmd_context *cmd __attribute((unused)),
 			   struct lv_segment *seg __attribute((unused)),
 			   char *params, uint64_t *total_numerator,
-			   uint64_t *total_denominator, float *percent)
+			   uint64_t *total_denominator)
 {
-	float percent2;
 	uint64_t numerator, denominator;
 
-	if (strchr(params, '/')) {
-		if (sscanf(params, "%" PRIu64 "/%" PRIu64,
-			   &numerator, &denominator) == 2) {
-			*total_numerator += numerator;
-			*total_denominator += denominator;
-		}
-	} else if (sscanf(params, "%f", &percent2) == 1) {
-		*percent += percent2;
-		*percent /= 2;
+	if (sscanf(params, "%" PRIu64 "/%" PRIu64,
+		   &numerator, &denominator) == 2) {
+		*total_numerator += numerator;
+		*total_denominator += denominator;
 	}
 
 	return 1;


