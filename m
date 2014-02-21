From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 21 Feb 2014 11:32:53 +0100
Subject: [PATCH] logging: Promote command line to info
Message-ID: <1392978773-26463-1-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Amount of information in debug is so high it is difficult to understand
when testing.

OTOH having command line in syslog increases log readability while not
using debug.
---
 tools/lvmcmdline.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6fe4670..c692a63 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1147,7 +1147,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	init_dmeventd_monitor(monitoring);
 
-	log_debug("Processing: %s", cmd->cmd_line);
+	log_info("Processing: %s", cmd->cmd_line);
 
 #ifdef O_DIRECT_SUPPORT
 	log_debug("O_DIRECT will be used");
-- 
1.7.12.1


