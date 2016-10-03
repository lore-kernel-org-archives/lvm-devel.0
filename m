From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:09 +0000 (UTC)
Subject: master - cleanup: simplier assign of cmd vars
Message-ID: <20161003155109.B7C2E60A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cea441f4d1e19f170d9161203ef843c59f3fbf70
Commit:        cea441f4d1e19f170d9161203ef843c59f3fbf70
Parent:        00f883a4aa10079bac21c294ce5ed34f11af8ac7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 13:00:50 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:49:55 2016 +0200

cleanup: simplier assign of cmd vars

Directly assign queried args as they provide matching values for
a setting.
---
 tools/lvmcmdline.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9a4deb7..bd29e25 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1049,23 +1049,19 @@ static int _get_settings(struct cmd_context *cmd)
 	const char *activation_mode;
 
 	cmd->current_settings = cmd->default_settings;
+	cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
+	cmd->current_settings.test = arg_is_set(cmd, test_ARG);
 
 	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL +
 		    (arg_count(cmd, debug_ARG) - 1);
 
-	if (arg_is_set(cmd, verbose_ARG))
-		cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
-
 	if (arg_is_set(cmd, quiet_ARG)) {
 		cmd->current_settings.debug = 0;
 		cmd->current_settings.verbose = 0;
 		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
 
-	if (arg_is_set(cmd, test_ARG))
-		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
-
 	if (arg_is_set(cmd, driverloaded_ARG)) {
 		cmd->current_settings.activation =
 		    arg_int_value(cmd, driverloaded_ARG,


