From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Jun 2016 17:08:31 +0000 (UTC)
Subject: master - pvscan: don't activate LVs when use_lvmetad=0
Message-ID: <20160616170831.11BC96061D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f77fe436afb76ddb798d236d34daf50413a184f6
Commit:        f77fe436afb76ddb798d236d34daf50413a184f6
Parent:        944ae4d2df0f15afb29ac0a68d0dd012d9df9acf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 16 12:04:05 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 16 12:04:05 2016 -0500

pvscan: don't activate LVs when use_lvmetad=0

commit 15da467b was meant to address the case where
use_lvmetad=1 in lvm.conf, and lvmetad is not available,
in which case, pvscan --cache -aay should activate LVs.

But the commit unintentionally also changed the case
where use_lvmetad=0 in lvm.conf, in which case
pvscan --cache -aay should not activate LVs, so fix
that here.
---
 tools/pvscan.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 78dad82..73a97be 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -306,7 +306,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	int devno_args = 0;
 	struct arg_value_group_list *current_group;
 	dev_t devno;
-	int do_activate = 0;
+	int do_activate;
 	int all_vgs = 0;
 	int remove_errors = 0;
 	int add_errors = 0;
@@ -315,17 +315,21 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_init(&found_vgnames);
 	dm_list_init(&pp.changed_vgnames);
 
-	if (!lvmetad_used() && !arg_is_set(cmd, activate_ARG)) {
-		log_verbose("Ignoring pvscan --cache command because lvmetad is not in use.");
+	do_activate = arg_is_set(cmd, activate_ARG);
+
+	if (!lvmetad_used() && !do_activate) {
+		log_verbose("Ignoring pvscan --cache because lvmetad is not in use.");
 		return ret;
 	}
 
-	if (arg_is_set(cmd, activate_ARG)) {
-		if (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY) {
-			log_error("Only --activate ay allowed with pvscan.");
-			return 0;
-		}
-		do_activate = 1;
+	if (do_activate && (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY)) {
+		log_error("Only --activate ay allowed with pvscan.");
+		return 0;
+	}
+
+	if (!lvmetad_used() && do_activate && !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
+		log_verbose("Ignoring pvscan --cache -aay because lvmetad is not in use.");
+		return ret;
 	}
 
 	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
@@ -341,8 +345,13 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!lvmetad_used() && do_activate) {
-		log_verbose("Activating all VGs without lvmetad running.");
+	/*
+	 * This a special case where use_lvmetad=1 in lvm.conf but pvscan
+	 * cannot use lvmetad for some reason.  In this case pvscan should
+	 * still activate LVs even though it's not updating the cache.
+	 */
+	if (do_activate && !lvmetad_used()) {
+		log_verbose("Activating all VGs without lvmetad.");
 		all_vgs = 1;
 		devno_args = 0;
 		goto activate;


