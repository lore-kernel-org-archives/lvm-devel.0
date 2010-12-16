From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:24 +0100
Subject: [PATCH 16/20] Remove dead store in lvm_run_command
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <19010510f66ed4c645542dfdfca293b1a361fed1.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'ret' is not read before its next assignment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index dcb1f28..836dbaa 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1064,8 +1064,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = override_config_tree_from_string(cmd,
-			     arg_str_value(cmd, config_ARG, "")))) {
+		if (override_config_tree_from_string(cmd,
+		    arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
 			goto_out;
 		}
-- 
1.7.3.3


