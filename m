From: David Teigland <teigland@sourceware.org>
Date: Fri, 25 Mar 2022 21:14:47 +0000 (GMT)
Subject: main - Move nolocking warning to man page
Message-ID: <20220325211447.38DDF3840C05@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1578b4a5d0bf49ab2b07c86c982cfa5aaa60a84
Commit:        f1578b4a5d0bf49ab2b07c86c982cfa5aaa60a84
Parent:        72f0b637d239c893ca49b05b83e2ebddc327e900
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 25 15:43:53 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 25 15:43:53 2022 -0500

Move nolocking warning to man page

It's more logical to warn about --nolocking in the man page
before it's used rather than after it's used and too late.
Also, warnings are usually for things the user may not know.
---
 tools/args.h       | 3 ++-
 tools/lvmcmdline.c | 5 +----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 56669645d..ecb650234 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -499,7 +499,8 @@ arg(nohistory_ARG, '\0', "nohistory", 0, 0, 0,
     "metadata/record_lvs_history is enabled.\n")
 
 arg(nolocking_ARG, '\0', "nolocking", 0, 0, 0,
-    "Disable locking.\n")
+    "Disable locking. Use with caution, concurrent commands may produce\n")
+    "incorrect results.\n")
 
 arg(norestorefile_ARG, '\0', "norestorefile", 0, 0, 0,
     "In conjunction with --uuid, this allows a uuid to be specified\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 241c6df18..1e3547ed7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3267,10 +3267,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, readonly_ARG))
 		readonly = 1;
 
-	if (cmd->nolocking) {
-		if (!_cmd_no_meta_proc(cmd))
-			log_warn("WARNING: File locking is disabled.");
-	} else {
+	if (!cmd->nolocking) {
 		if (!init_locking(cmd, sysinit, readonly, cmd->ignorelockingfailure)) {
 			ret = ECMD_FAILED;
 			goto_out;

