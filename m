From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  3 Oct 2016 17:17:44 +0000 (UTC)
Subject: master - Revert "cleanup: simplier assign of cmd vars"
Message-ID: <20161003171744.E450561B74@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c900cf7ed40e541fa8b2eeeb084c1061382e0b1e
Commit:        c900cf7ed40e541fa8b2eeeb084c1061382e0b1e
Parent:        9e33781d95f2fe7d412b97eb48cb8dddd1c07c61
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 3 18:14:17 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 3 18:14:17 2016 +0100

Revert "cleanup: simplier assign of cmd vars"

This reverts commit cea441f4d1e19f170d9161203ef843c59f3fbf70.

cmd->default_values is configurable and this code should not make
any assumptions about values it holds.
---
 tools/lvmcmdline.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bd29e25..9a4deb7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1049,19 +1049,23 @@ static int _get_settings(struct cmd_context *cmd)
 	const char *activation_mode;
 
 	cmd->current_settings = cmd->default_settings;
-	cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
-	cmd->current_settings.test = arg_is_set(cmd, test_ARG);
 
 	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL +
 		    (arg_count(cmd, debug_ARG) - 1);
 
+	if (arg_is_set(cmd, verbose_ARG))
+		cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
+
 	if (arg_is_set(cmd, quiet_ARG)) {
 		cmd->current_settings.debug = 0;
 		cmd->current_settings.verbose = 0;
 		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
 
+	if (arg_is_set(cmd, test_ARG))
+		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
+
 	if (arg_is_set(cmd, driverloaded_ARG)) {
 		cmd->current_settings.activation =
 		    arg_int_value(cmd, driverloaded_ARG,


