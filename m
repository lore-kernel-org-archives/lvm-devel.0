From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 May 2014 13:43:57 +0000 (UTC)
Subject: master - dumpconfig: fix dumpconfig --type diff used in lvm shell as second and later command
Message-ID: <20140519134357.66E2060CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24f32721a9e6a61943122f3d06d2329f5f81597c
Commit:        24f32721a9e6a61943122f3d06d2329f5f81597c
Parent:        9a324df3b329f1a28462f246219522da62a022ce
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 14:51:11 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 15:41:25 2014 +0200

dumpconfig: fix dumpconfig --type diff used in lvm shell as second and later command

The dumpconfig reuses existing config_def_check results in case
the check is done during general lvm command context initialization
(when enabled by config/checks=1) so dumpconfig does not need to run
the same check again during its execution, hence saving some time.

However, we don't check for differences from defaults during general
lvm command initialization as it's useless at that time. It makes
sense only in case when such a check is directly requested (like in
the case of lvm dumpconfig --type diff). We need to take care that
the reused information was already produced with this "diff" checking
before and if not, we need to force the check so the check status also
gathers the new "diff" info now.

Also, do not do diff checking for any other dumpconfig command that
is run after dumpconfig --type diff.
---
 WHATS_NEW          |    1 +
 tools/dumpconfig.c |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 06d0854..6cbd622 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix dumpconfig --type diff when run as second and later cmd in lvm shell.
   Fix wrong profile reuse from previous run if another cmd is run in lvm shell.
   Move cache description from lvm(8) to lvmcache(7) man page.
   Display skipped prompt in silent mode.
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 49a6a68..141a030 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -41,10 +41,14 @@ static int _do_def_check(struct config_def_tree_spec *spec,
 	handle->force_check = 1;
 	handle->suppress_messages = 1;
 
-	if (spec->type == CFG_DEF_TREE_DIFF)
+	if (spec->type == CFG_DEF_TREE_DIFF) {
+		if (!handle->check_diff)
+			handle->skip_if_checked = 0;
 		handle->check_diff = 1;
-	else
+	} else {
 		handle->skip_if_checked = 1;
+		handle->check_diff = 0;
+	}
 
 	config_def_check(handle);
 	*cft_check_handle = handle;


