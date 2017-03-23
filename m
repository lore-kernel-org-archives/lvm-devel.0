From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 Mar 2017 04:09:00 -0400
Subject: master - commands: fix commands with run with path basename
Message-ID: <201703230809.v2N890YI030774@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dabe7237c531459792de953879a5c4c6de41c65
Commit:        0dabe7237c531459792de953879a5c4c6de41c65
Parent:        e8362b4cb7fcb4575d843f5b1f6e5c8b66fa99c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 23 03:06:07 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 23 03:06:07 2017 -0500

commands: fix commands with run with path basename

The recent command definitions commit took the command
name from argv[0] without applying basename to the value,
so a pathname, e.g. /usr/sbin, would cause lvm to not
recognize the command name.
---
 tools/lvmcmdline.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f339928..4f0610d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2632,7 +2632,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
-	cmd->name = dm_pool_strdup(cmd->mem, argv[0]);
+	cmd->name = dm_pool_strdup(cmd->mem, dm_basename(argv[0]));
 
 	configure_command_option_values(cmd->name);
 
@@ -3356,7 +3356,7 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && argc == 1)
 		name = NULL;
 	else if (alias)
-		name = argv[0];
+		name = (char *)dm_basename(argv[0]);
 	else
 		name = argv[1];
 


