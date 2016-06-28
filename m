From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:15 +0000 (UTC)
Subject: master - coverity: fix issues detected in recent code
Message-ID: <20160628013315.E25E260E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0768f636edb8da08e46b029380779fd623399de
Commit:        f0768f636edb8da08e46b029380779fd623399de
Parent:        a46f5242471018faca5d20204d0bab5fb2d6b9cd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 27 10:12:41 2016 +0200
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:26:54 2016 +0100

coverity: fix issues detected in recent code

Uninitialized variables  (UNINIT) /safe/guest2/covscan/LVM2.2.02.158/tools/toollib.c: 3520 in _process_pvs_in_vgs()
Uninitialized variables  (UNINIT) Using uninitialized value "do_report_ret_code".

Null pointer dereferences  (REVERSE_INULL) /safe/guest2/covscan/LVM2.2.02.158/libdm/libdm-report.c: 4745 in dm_report_output()
Null pointer dereferences  (REVERSE_INULL) Null-checking "rh" suggests that it may be null, but it has already been dereferenced on all paths leading to the check.

Incorrect expression  (MISSING_COMMA) /safe/guest2/covscan/LVM2.2.02.158/lib/log/log.c: 280 in _get_log_level_name()
Incorrect expression  (MISSING_COMMA) In the initialization of "log_level_names", a suspicious concatenated string ""noticeinfo"" is produced.

Null pointer dereferences  (FORWARD_NULL) /safe/guest2/covscan/LVM2.2.02.158/tools/reporter.c: 816 in_get_report_options()
Null pointer dereferences  (FORWARD_NULL) Comparing "mem" to null implies that "mem" might be null.
---
 lib/log/log.c        |    2 +-
 libdm/libdm-report.c |    4 ++--
 tools/reporter.c     |    2 +-
 tools/toollib.c      |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index b3453dc..30d71ef 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -277,7 +277,7 @@ static const char *_get_log_level_name(int use_stderr, int level)
 						"fatal", /* _LOG_FATAL */
 						"error", /* _LOG_ERROR */
 						"warn",  /* _LOG_WARN */
-						"notice" /* _LOG_NOTICE */
+						"notice",/* _LOG_NOTICE */
 						"info",  /* _LOG_INFO */
 						"debug"  /* _LOG_DEBUG */
 						};
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6bea34c..ad03c6e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4001,7 +4001,7 @@ static int _report_set_selection(struct dm_report *rh, const char *selection, in
 			goto_bad;
 	}
 
-	if (!selection || !strcasecmp(selection, SPECIAL_SELECTION_ALL))
+	if (!selection || !selection[0] || !strcasecmp(selection, SPECIAL_SELECTION_ALL))
 		return 1;
 
 	rh->selection->add_new_fields = add_new_fields;
@@ -4742,7 +4742,7 @@ int dm_report_output(struct dm_report *rh)
 	else
 		r = _output_as_columns(rh);
 out:
-	if (r && rh && rh->group_item)
+	if (r && rh->group_item)
 		rh->group_item->output_done = 1;
 	return r;
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index ee2d251..40d449c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -815,7 +815,7 @@ static int _get_report_options(struct cmd_context *cmd,
 
 	if (!(mem = dm_pool_create("report_options", 128))) {
 		log_error("Failed to create temporary mempool to process report options.");
-		goto out;
+		return ECMD_FAILED;
 	}
 
 	if (single_args->report_type == CMDLOG) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 5c61ddd..80d0f32 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3439,7 +3439,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int skip;
 	int notfound;
 	int already_locked;
-	int do_report_ret_code;
+	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 


