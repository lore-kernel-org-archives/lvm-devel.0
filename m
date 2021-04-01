From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Apr 2021 19:39:22 +0000 (GMT)
Subject: main - hints: don't use hints when --sysinit is used
Message-ID: <20210401193922.B290F3846033@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12949ea886259ead84597a1d4de37c8715d8edb7
Commit:        12949ea886259ead84597a1d4de37c8715d8edb7
Parent:        01d5e4d1ca27b5dbf4dce19be3da2ab83cefd40d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 1 14:37:24 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 1 14:37:24 2021 -0500

hints: don't use hints when --sysinit is used

Devices are not in a steady state during system init,
so hints are repeatedly invalidated, and hardly used,
so maintaining them is wasted effort.
---
 tools/lvmcmdline.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 796ecfa78..23ab6fa37 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2488,6 +2488,14 @@ static int _get_current_settings(struct cmd_context *cmd)
 	if (arg_is_set(cmd, devicesfile_ARG) || arg_is_set(cmd, devices_ARG))
 		cmd->use_hints = 0;
 
+	/*
+	 * During system init, hints are repeatedly invalidated due to PVs
+	 * appearing, so it's wasted effort to try to maintain hints.
+	 * Hints are only effective when devices are in a steady-state.
+	 */
+	if (arg_is_set(cmd, sysinit_ARG))
+		cmd->use_hints = 0;
+
 	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
 		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;


