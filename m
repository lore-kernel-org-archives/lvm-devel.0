From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:46:54 +0000 (UTC)
Subject: master - commands: fix memleak
Message-ID: <20170219234654.393B560554@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a21a19d904c34e56e3ab3fe026dbc5658f68925
Commit:        2a21a19d904c34e56e3ab3fe026dbc5658f68925
Parent:        87c89ac2791e9b443db8c009db67610cbd97b4f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 18 18:49:19 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 19 22:59:43 2017 +0100

commands: fix memleak

Keep all allocations 'mempool' allocated for simple cleanup.
---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 26f7476..c304602 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2519,7 +2519,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
-	cmd->name = strdup(argv[0]);
+	cmd->name = dm_pool_strdup(cmd->mem, argv[0]);
 
 	/* eliminate '-' from all options starting with -- */
 	for (i = 1; i < argc; i++) {


