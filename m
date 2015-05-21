From: okozina <okozina@fedoraproject.org>
Date: Thu, 21 May 2015 09:26:30 +0000 (UTC)
Subject: master - polldaemon.c: modify log levels in report_progress
Message-ID: <20150521092630.3A63860FCB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01b06cb71b25111c9d0ddaccca97e788f2dedf9d
Commit:        01b06cb71b25111c9d0ddaccca97e788f2dedf9d
Parent:        43224f22e460eddd3d4ee993d4585b4c8f421357
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 21 10:17:29 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Thu May 21 11:20:11 2015 +0200

polldaemon.c: modify log levels in report_progress

There's a race when asking lvmpolld about progress_status and
actually reading the progress info from kernel:

Even with lvmpolld being used we read status info from
LVM2 command issued by a user (client side from lvmpolld perspective).
The whole cycle may look like following:

1) set up an operation that requires polling (i.e. pvmove /dev/sda)
2) notify lvmpolld about such operation (lvmpolld_poll_init())
3) in case 1) was not called with --background it would continue with:
4) Ask lvmpolld about progress status. it may respond with one of:
   a) in_progress
   b) not_found
   c) finished
   d) any low level error

5) provided the answer was 4a) try to read progress info from polling LV
(i.e. vg00/pvmove1). Repeat steps 4) and 5) until the answer is != 4a).

And now we got into racy configuration: lvmpolld answered with in_progress
but it may be the that in_between 4) and 5) the operation has already
finished and polling LV is already gone or there's nothing to ask for.
Up to now, 5) would report warning and it could print such warning many
times if --interval was set to 0.

We don't want to scary users by warnings in such situation so let's just
print these messages in verbose mode. Error messages due to error while
reading kernel status info (on existing, active and locked LV) remained
the same.
---
 tools/polldaemon.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index fe2e7fd..2e86cb1 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -375,24 +375,19 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 	if (lv && parms->lv_type && !(lv->status & parms->lv_type))
 		lv = NULL;
 
-	if (!lv && parms->lv_type == PVMOVE) {
-		log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
-					id->display_name);
-		unlock_and_release_vg(cmd, vg, vg->name);
-		return 1;
-	}
-
 	if (!lv) {
-		log_warn("Can't find LV in %s for %s. Already finished or removed.",
-			  vg->name, id->display_name);
-		unlock_and_release_vg(cmd, vg, vg->name);
-		return 1;
+		if (parms->lv_type == PVMOVE)
+			log_verbose("%s: No pvmove in progress - already finished or aborted.",
+				    id->display_name);
+		else
+			log_verbose("Can't find LV in %s for %s. Already finished or removed.",
+				    vg->name, id->display_name);
+		goto out;
 	}
 
 	if (!lv_is_active_locally(lv)) {
-		log_print_unless_silent("%s: Interrupted: No longer active.", id->display_name);
-		unlock_and_release_vg(cmd, vg, vg->name);
-		return 1;
+		log_verbose("%s: Interrupted: No longer active.", id->display_name);
+		goto out;
 	}
 
 	if (parms->poll_fns->poll_progress(cmd, lv, id->display_name, parms) == PROGRESS_CHECK_FAILED) {
@@ -400,6 +395,7 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 		return_0;
 	}
 
+out:
 	unlock_and_release_vg(cmd, vg, vg->name);
 
 	return 1;


