From: David Teigland <teigland@sourceware.org>
Date: Wed, 14 Nov 2018 11:01:19 -0500
Subject: master - remove unused backgroundfork option
Message-ID: <201811141601.wAEG1Jdq029212@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ca8ed66a737c3b078e292752461befd157d49b4
Commit:        3ca8ed66a737c3b078e292752461befd157d49b4
Parent:        814cff0c20158b89592bac437faa375d7d8ff682
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 14 09:34:49 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 14 09:34:49 2018 -0600

remove unused backgroundfork option

---
 tools/args.h       |    5 -----
 tools/lvmcmdline.c |    8 --------
 2 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 3e737f8..1ceba99 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -932,16 +932,11 @@ arg(activevolumegroups_ARG, 'A', "activevolumegroups", 0, 0, 0,
     "Only select active VGs. The VG is considered active\n"
     "if at least one of its LVs is active.\n")
 
-/* FIXME: remove background option from pvscan, it's not used */
-
 arg(background_ARG, 'b', "background", 0, 0, 0,
     "If the operation requires polling, this option causes the command to\n"
     "return before the operation is complete, and polling is done in the\n"
     "background.\n")
 
-/* Not used */
-arg(backgroundfork_ARG, 'b', "background", 0, 0, 0, NULL)
-
 arg(basevgname_ARG, 'n', "basevgname", string_VAL, 0, 0,
     "By default the snapshot VG will be renamed to the original name plus a\n"
     "numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f49843d..9c0476e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2825,14 +2825,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	set_cmd_name(cmd->name);
 
-	if (arg_is_set(cmd, backgroundfork_ARG)) {
-		if (!become_daemon(cmd, 1)) {
-			/* parent - quit immediately */
-			ret = ECMD_PROCESSED;
-			goto out;
-		}
-	}
-
 	if (arg_is_set(cmd, config_ARG))
 		if (!override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;


