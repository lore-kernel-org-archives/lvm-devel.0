From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 11 Apr 2013 14:37:08 +0000 (UTC)
Subject: master - config: remove typo in handling devices/write_cache_state config
Message-ID: <20130411143708.DCFDB606@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7ccad2ef0e813f6ca42ab5090e76aa5bee05912
Commit:        e7ccad2ef0e813f6ca42ab5090e76aa5bee05912
Parent:        91c9771fc3c97b0ff1169cf81f29918d3e3a501d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 11 16:32:10 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 11 16:32:10 2013 +0200

config: remove typo in handling devices/write_cache_state config

...which caused the cmd->dump_filter to be always set irrespective
of the actual devices/write_cache_state setting.
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 5dff340..c42a0bf 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -932,7 +932,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	}
 
 	/* Should we ever dump persistent filter state? */
-	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG));
+	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG))
 		cmd->dump_filter = 1;
 
 	if (!*cmd->system_dir)


