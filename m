From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Jul 2021 21:40:11 +0000 (GMT)
Subject: main - pvscan: narrow the previous commit slightly
Message-ID: <20210713214011.52CC83855037@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e33c2e032cab40cf8607afa1cb92176400d1cabd
Commit:        e33c2e032cab40cf8607afa1cb92176400d1cabd
Parent:        25f0f5daac5606e557d2124c219f5bb255c5d9dc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 13 16:26:36 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 13 16:38:04 2021 -0500

pvscan: narrow the previous commit slightly

to avoid change to pvscan-autoactivate.sh
---
 tools/pvscan.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 78cb5e764..6787c4cfc 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1611,6 +1611,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	struct pvscan_aa_params pp = { 0 };
 	struct dm_list complete_vgnames;
 	int do_activate = arg_is_set(cmd, activate_ARG);
+	int event_activation;
 	int devno_args = 0;
 	int do_all;
 	int ret;
@@ -1619,6 +1620,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->check_devs_used = 0;
 
+	event_activation = find_config_tree_bool(cmd, global_event_activation_CFG, NULL);
+
+	if (do_activate && !event_activation) {
+		log_verbose("Ignoring pvscan --cache -aay because event_activation is disabled.");
+		return ECMD_PROCESSED;
+	}
+
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 
@@ -1629,17 +1637,17 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	do_all = !argc && !devno_args;
 
-	if (!do_all && !find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
-		log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
-		return ECMD_PROCESSED;
-	}
-
 	_online_dir_setup();
 
 	if (do_all) {
 		if (!_pvscan_cache_all(cmd, argc, argv, &complete_vgnames))
 			return ECMD_FAILED;
 	} else {
+		if (!event_activation) {
+			/* Avoid doing anything for device removal: pvscan --cache <devno> */
+			log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
+			return ECMD_PROCESSED;
+		}
 		if (!_pvscan_cache_args(cmd, argc, argv, &complete_vgnames))
 			return ECMD_FAILED;
 	}


