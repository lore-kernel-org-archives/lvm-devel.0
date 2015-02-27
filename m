From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 13:53:50 +0000 (UTC)
Subject: master - cleanup: change check order in condition in _check_pv_list fn
Message-ID: <20150227135350.B063560D23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=379fb90b05b9fae0559fb697981198d8bb58e0f9
Commit:        379fb90b05b9fae0559fb697981198d8bb58e0f9
Parent:        ee4cd2c73774feeef3794c24865add1c28adb946
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 27 14:52:31 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 14:52:38 2015 +0100

cleanup: change check order in condition in _check_pv_list fn

"!dev_cache_get(argv[i], cmd->full_filter) && !rescan_done" --> "!rescan_done && !dev_cache_get(argv[i], cmd->full_filter)

Check the simple condition first (variable), then the function return value
(which in this case certainly takes more time to evaluate) - save some time.
---
 tools/reporter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 0e563ac..9bf366e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -578,7 +578,7 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 
 	if (args_are_pvs && argc) {
 		for (i = 0; i < argc; i++) {
-			if (!dev_cache_get(argv[i], cmd->full_filter) && !rescan_done) {
+			if (!rescan_done && !dev_cache_get(argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);
 				/* FIXME scan only one device */
 				lvmcache_label_scan(cmd, 0);


