From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 00:14:07 +0000 (UTC)
Subject: dev-mornfall-nix - toolcontext: Deal with NULL cmd->filter gracefully.
Message-ID: <20130527001407.9600860F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e3a2d44241d3b688714025f862700ad2dfdcf69
Commit:        0e3a2d44241d3b688714025f862700ad2dfdcf69
Parent:        b71acdcdaf36f0456ae20f7b014bdcfe5f70a590
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 02:13:23 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 02:13:23 2013 +0200

toolcontext: Deal with NULL cmd->filter gracefully.

---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3b0d96e..af1aa63 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1652,7 +1652,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	struct dm_config_tree *cft_cmdline;
 	FILE *new_stream;
 
-	if (cmd->dump_filter && cmd->filter->dump)
+	if (cmd->dump_filter && cmd->filter && cmd->filter->dump)
 		cmd->filter->dump(cmd->filter);
 
 	archive_exit(cmd);


