From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:50 +0000 (UTC)
Subject: master - lvmcmdline: profile: early profile load for lvm shell
Message-ID: <20160809173950.06B566072E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e805ef2d66bc8a06481de648497ff1369965d3c3
Commit:        e805ef2d66bc8a06481de648497ff1369965d3c3
Parent:        f21afddeb71c052617afb41fed9a2bd68ad532cf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 16:45:27 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

lvmcmdline: profile: early profile load for lvm shell

Make it possible to also load profile for lvm shell by honouring
LVM_COMMAND_PROFILE environment variable.
---
 tools/lvmcmdline.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 81118c1..cb41534 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1395,6 +1395,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 			cmd->profile_params->global_metadata_profile = profile;
 		}
 
+		remove_config_tree_by_source(cmd, source);
 		if (!override_config_tree_from_profile(cmd, profile)) {
 			log_error(_failed_to_apply_profile_msg, source_name, name);
 			return 0;
@@ -1420,6 +1421,8 @@ static int _prepare_profiles(struct cmd_context *cmd)
 			log_error(_failed_to_add_profile_msg, source_name, name);
 			return 0;
 		}
+
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE_COMMAND);
 		if (!override_config_tree_from_profile(cmd, profile)) {
 			log_error(_failed_to_apply_profile_msg, source_name, name);
 			return 0;
@@ -1438,6 +1441,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 			log_error(_failed_to_add_profile_msg, source_name, name);
 			return 0;
 		}
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE_METADATA);
 		if (!override_config_tree_from_profile(cmd, profile)) {
 			log_error(_failed_to_apply_profile_msg, source_name, name);
 			return 0;
@@ -2217,6 +2221,10 @@ int lvm2_main(int argc, char **argv)
 #ifdef READLINE_SUPPORT
 	if (!alias && argc == 1) {
 		_nonroot_warning();
+		if (!_prepare_profiles(cmd)) {
+			ret = ECMD_FAILED;
+			goto out;
+		}
 		ret = lvm_shell(cmd, &_cmdline);
 		goto out;
 	}


