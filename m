From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:37:37 +0200
Subject: [PATCH 2/2] Fix report of uninitalized pool leak (t-lvm-init.sh)
In-Reply-To: <cover.1281256324.git.zkabelac@redhat.com>
References: <cover.1281256324.git.zkabelac@redhat.com>
Message-ID: <164cdbee51f23138d194639e2358dfa14201b70f.1281256324.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6c66fab..b29acfb 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1048,6 +1048,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
+			if (cmd->cft_override) {
+				destroy_config_tree(cmd->cft_override);
+				cmd->cft_override = NULL;
+			}
 			log_error("Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}
-- 
1.7.2.1


