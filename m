From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Feb 2021 16:52:55 +0000 (GMT)
Subject: main - include lvm version in debug output
Message-ID: <20210212165255.19A9E3857C75@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4486f08d51f4e6a6a47fa8cb484a70ca9a3ed541
Commit:        4486f08d51f4e6a6a47fa8cb484a70ca9a3ed541
Parent:        c94d78f068653293e42f0fe815ddeef98406c666
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 12 10:51:41 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 12 10:51:41 2021 -0600

include lvm version in debug output

---
 tools/lvmcmdline.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5e0edcade..5b7951f3b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3000,6 +3000,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	_get_current_output_settings_from_args(cmd);
 	_apply_current_output_settings(cmd);
 
+	log_debug("Version: %s", LVM_VERSION);
 	log_debug("Parsing: %s", cmd->cmd_line);
 
 	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))


