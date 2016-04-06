From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:40 +0000 (UTC)
Subject: master - lvconvert: show percent with %.2
Message-ID: <20160406095540.8D2DD60FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0584e85736b164d07434619622d6d06ad15fe690
Commit:        0584e85736b164d07434619622d6d06ad15fe690
Parent:        261a85ced94e2f4ed7c3f01d7d0a7624032e2697
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 5 14:51:05 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

lvconvert: show percent with %.2

lvm2 shows percent values with 2 decimal digits elsewhere so use
it consistently also for this output.
---
 tools/lvconvert_poll.c |    4 ++--
 tools/polldaemon.c     |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 9b758f2..3f3beaf 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -152,10 +152,10 @@ progress_t poll_merge_progress(struct cmd_context *cmd,
 	}
 
 	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %.1f%%", lv->name, parms->progress_title,
+		log_print_unless_silent("%s: %s: %.2f%%", lv->name, parms->progress_title,
 					100.0 - dm_percent_to_float(percent));
 	else
-		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
+		log_verbose("%s: %s: %.2f%%", lv->name, parms->progress_title,
 			    100.0 - dm_percent_to_float(percent));
 
 	if (percent == DM_PERCENT_0)
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 8f1ff90..71d6b3e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -40,10 +40,10 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 
 	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
-		log_print_unless_silent("%s: %s: %.1f%%", name, parms->progress_title,
+		log_print_unless_silent("%s: %s: %.2f%%", name, parms->progress_title,
 					dm_percent_to_float(overall_percent));
 	else
-		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
+		log_verbose("%s: %s: %.2f%%", name, parms->progress_title,
 			    dm_percent_to_float(overall_percent));
 
 	if (segment_percent != DM_PERCENT_100)


