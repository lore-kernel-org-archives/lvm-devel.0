From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  2 Mar 2015 09:35:21 +0000 (UTC)
Subject: master - report: check value of args_are_pvs, not the pointer (fix for commit 9ea77b7)
Message-ID: <20150302093521.96EC261076@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=047fe6c59fe2cf3a52208b219caebed469ed6bdc
Commit:        047fe6c59fe2cf3a52208b219caebed469ed6bdc
Parent:        c32efc7f7ed9fa3257e667cd8b70d8a5c8379b4b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 2 10:36:32 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 2 10:36:32 2015 +0100

report: check value of args_are_pvs, not the pointer (fix for commit 9ea77b7)

---
 tools/reporter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 9bf366e..eb6a4ed 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -576,7 +576,7 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 			 *report_type == LABEL ||
 			 *report_type == PVSEGS) ? 1 : 0;
 
-	if (args_are_pvs && argc) {
+	if (*args_are_pvs && argc) {
 		for (i = 0; i < argc; i++) {
 			if (!rescan_done && !dev_cache_get(argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);


