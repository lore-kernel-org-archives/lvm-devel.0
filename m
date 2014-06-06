From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 05 Jun 2014 23:52:14 -0500
Subject: [PATCH] poll_daemon: cleanly exit if LV is no longer active
Message-ID: <1402030334.4356.6.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is in response to bug 692186, where the most relevant comment
is:
https://bugzilla.redhat.com/show_bug.cgi?id=692186#c6

 brassow

poll_daemon:  Quietly exit polling if the LV is no longer active

If the we are polling an LV due to some sort of conversion and it
becomes inactive, a rather worrisome message is produced, e.g.:
"  ABORTING: Mirror percentage check failed."

We can quietly exit if we do a simple check to see if the LV is
active before performing the check.  This eliminates the scary
message.

Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -24,6 +24,12 @@ progress_t poll_mirror_progress(struct c
 	percent_t segment_percent = PERCENT_0, overall_percent = PERCENT_0;
 	uint32_t event_nr = 0;
 
+	if (!lv_is_active(lv)) {
+		log_print_unless_silent("%s: Interrupted: No longer active.",
+					name);
+		return PROGRESS_INTERRUPTED;
+	}
+
 	if (!lv_is_mirrored(lv) ||
 	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
 			       &event_nr) ||
@@ -77,6 +83,9 @@ static int _check_lv_status(struct cmd_c
 	if (progress == PROGRESS_CHECK_FAILED)
 		return_0;
 
+	if (progress == PROGRESS_INTERRUPTED)
+		return 1;
+
 	if (progress == PROGRESS_UNFINISHED) {
 		/* The only case the caller *should* try again later */
 		*finished = 0;
Index: lvm2/tools/polldaemon.h
===================================================================
--- lvm2.orig/tools/polldaemon.h
+++ lvm2/tools/polldaemon.h
@@ -22,7 +22,8 @@ typedef enum {
 	PROGRESS_CHECK_FAILED = 0,
 	PROGRESS_UNFINISHED = 1,
 	PROGRESS_FINISHED_SEGMENT = 2,
-	PROGRESS_FINISHED_ALL = 3
+	PROGRESS_FINISHED_ALL = 3,
+	PROGRESS_INTERRUPTED = 4
 } progress_t;
 
 struct daemon_parms;



