From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 19 Feb 2015 21:26:43 +0000 (UTC)
Subject: master - report: fix foreign reporting without lvmetad
Message-ID: <20150219212643.3CDDD610FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6bc35a351ace5ff5da07280fda288027cf614a13
Commit:        6bc35a351ace5ff5da07280fda288027cf614a13
Parent:        b896bf8f5a4e811578c0cb606b2ad73220f985fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 19 15:24:31 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 19 15:24:31 2015 -0600

report: fix foreign reporting without lvmetad

---
 test/shell/system_id.sh |    3 ---
 tools/reporter.c        |    5 ++---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index feb66ae..71e6ee9 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -13,9 +13,6 @@ test_description='Test system_id'
 
 . lib/inittest
 
-# FIXME: vgs --foreign is not seeing foreign vg when lvmetad is not used
-test -e LOCAL_LVMETAD || skip
-
 aux prepare_devs 1
 
 # create vg with system_id using each source
diff --git a/tools/reporter.c b/tools/reporter.c
index ef74dc4..cd0db6f 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -587,10 +587,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	 * to their own VGs.  We also want to override the default
 	 * behavior which skips over foreign VGs.
 	 */
-	if (arg_is_set(cmd, foreign_ARG) && lvmetad_used()) {
+	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG);
+	if (cmd->include_foreign_vgs && lvmetad_used())
 		lvmetad_pvscan_all_devs(cmd, NULL);
-		cmd->include_foreign_vgs = 1;
-	}
 
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);


