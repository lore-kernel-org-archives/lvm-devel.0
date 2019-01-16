From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jan 2019 12:46:29 -0500
Subject: master - move init_use_aio
Message-ID: <201901161746.x0GHkTiw016424@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebaaff3590b60933f6f1e2bfd010a86fc373f7eb
Commit:        ebaaff3590b60933f6f1e2bfd010a86fc373f7eb
Parent:        e158835a05963c8cb4166100c9d01e7ff3991c82
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 15 15:19:04 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 16 11:45:53 2019 -0600

move init_use_aio

it doesn't make sense to call from init_logging
---
 lib/commands/toolcontext.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index bd216aa..62e21f7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -328,8 +328,6 @@ static void _init_logging(struct cmd_context *cmd)
 	    find_config_tree_bool(cmd, global_test_CFG, NULL);
 	init_test(cmd->default_settings.test);
 
-	init_use_aio(find_config_tree_bool(cmd, global_use_aio_CFG, NULL));
-
 	/* Settings for logging to file */
 	if (find_config_tree_bool(cmd, log_overwrite_CFG, NULL))
 		append = 0;
@@ -1661,6 +1659,8 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 						find_config_tree_array(cmd, devices_types_CFG, NULL))))
 		goto_out;
 
+	init_use_aio(find_config_tree_bool(cmd, global_use_aio_CFG, NULL));
+
 	if (!_init_dev_cache(cmd))
 		goto_out;
 


