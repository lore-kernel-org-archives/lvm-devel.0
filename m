From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 22:15:21 -0500
Subject: [PATCH] Create _init_globals() and call from bottom of create_toolcontext().
In-Reply-To: <20081211231005.GM24785@agk.fab.redhat.com>
References: <20081211231005.GM24785@agk.fab.redhat.com>
Message-ID: <1229051721-14977-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move init_full_scan_done(0) and init_mirror_in_sync(0) from init_lvm()
after call to create_toolcontext() to _init_globals(), called from bottom
of create_toolcontext().  No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c |    9 +++++++++
 tools/lvmcmdline.c         |    3 ---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e9ef66c..8e31b9d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -990,6 +990,13 @@ static void _init_rand(struct cmd_context *cmd)
 	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
 }
 
+static void _init_globals(struct cmd_context *cmd)
+{
+	init_full_scan_done(0);
+	init_mirror_in_sync(0);
+
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 				       unsigned is_long_lived)
@@ -1090,6 +1097,8 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 
 	_init_rand(cmd);
 
+	_init_globals(cmd);
+
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 66a20ad..e1e9826 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,9 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_full_scan_done(0);
-	init_mirror_in_sync(0);
-
 	return cmd;
 }
 
-- 
1.5.5.1


