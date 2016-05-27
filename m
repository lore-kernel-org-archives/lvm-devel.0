From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:41 +0000 (UTC)
Subject: master - cleanup: substract integers
Message-ID: <20160527134741.0D32760642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb49ceeabaa011f51aa20c1a66c85ecbcb2c36a7
Commit:        cb49ceeabaa011f51aa20c1a66c85ecbcb2c36a7
Parent:        1c07e6746234e361ea68073b47a47df4bf4a7b2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 10:39:25 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

cleanup: substract integers

Instead of doing float arithmetic, do integer math first and
convert result to float.
---
 tools/lvconvert_poll.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 3f3beaf..36db1c7 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -153,10 +153,10 @@ progress_t poll_merge_progress(struct cmd_context *cmd,
 
 	if (parms->progress_display)
 		log_print_unless_silent("%s: %s: %.2f%%", lv->name, parms->progress_title,
-					100.0 - dm_percent_to_float(percent));
+					dm_percent_to_float(DM_PERCENT_100 - percent));
 	else
 		log_verbose("%s: %s: %.2f%%", lv->name, parms->progress_title,
-			    100.0 - dm_percent_to_float(percent));
+			    dm_percent_to_float(DM_PERCENT_100 - percent));
 
 	if (percent == DM_PERCENT_0)
 		return PROGRESS_FINISHED_ALL;


