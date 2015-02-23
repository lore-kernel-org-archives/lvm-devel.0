From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 20:14:22 +0000 (UTC)
Subject: master - toolcontext: Move lvmlocal.conf loading.
Message-ID: <20150223201422.A818960E7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72e6888dc3aaeecc869715366b7d3fdcc7732992
Commit:        72e6888dc3aaeecc869715366b7d3fdcc7732992
Parent:        0551d1c56e2e901a885aba09a94ebc391930bbc5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 20:11:00 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 20:11:00 2015 +0000

toolcontext: Move lvmlocal.conf loading.

Load lvmlocal.conf after basic initialisation from lvm.conf.
---
 lib/commands/toolcontext.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 190f9bd..1b0a427 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -374,7 +374,8 @@ static int _check_config(struct cmd_context *cmd)
 	return 1;
 }
 
-int process_profilable_config(struct cmd_context *cmd) {
+int process_profilable_config(struct cmd_context *cmd)
+{
 	if (!(cmd->default_settings.unit_factor =
 	      dm_units_to_factor(find_config_tree_str(cmd, global_units_CFG, NULL),
 				 &cmd->default_settings.unit_type, 1, NULL))) {
@@ -699,9 +700,8 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag, int local
 }
 
 /*
- * Find and read lvm.conf and lvmlocal.conf.
+ * Find and read lvm.conf.
  */
-
 static int _init_lvm_conf(struct cmd_context *cmd)
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
@@ -716,8 +716,6 @@ static int _init_lvm_conf(struct cmd_context *cmd)
 	if (!_load_config_file(cmd, "", 0))
 		return_0;
 
-	_load_config_file(cmd, "", 1);
-
 	return 1;
 }
 
@@ -1697,6 +1695,10 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_tags(cmd, cmd->cft))
 		goto_out;
 
+	/* Load lvmlocal.conf */
+	if (*cmd->system_dir && !_load_config_file(cmd, "", 1))
+		return_0;
+
 	if (!_init_tag_configs(cmd))
 		goto_out;
 
@@ -1904,6 +1906,10 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_tags(cmd, cft_tmp))
 		return_0;
 
+	/* Load lvmlocal.conf */
+	if (*cmd->system_dir && !_load_config_file(cmd, "", 1))
+		return_0;
+
 	/* Doesn't change cmd->cft */
 	if (!_init_tag_configs(cmd))
 		return_0;


