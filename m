From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 Mar 2017 04:35:59 -0400
Subject: master - commands: improve error message for unknown command
Message-ID: <201703230835.v2N8ZxjJ001886@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6471bb2c41cf0e692a8fe7ea00033327359d42fc
Commit:        6471bb2c41cf0e692a8fe7ea00033327359d42fc
Parent:        0dabe7237c531459792de953879a5c4c6de41c65
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 23 03:35:06 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 23 03:35:06 2017 -0500

commands: improve error message for unknown command

when running "lvm foo".
---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4f0610d..9cb506a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2674,7 +2674,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 
 	if (!_process_command_line(cmd, &argc, &argv)) {
-		log_error("Error during parsing of command line.");
+		log_error("Command name not found.");
 		return EINVALID_CMD_LINE;
 	}
 


