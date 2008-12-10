From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:55 -0500
Subject: [PATCH 05/11] Move init_test() from _apply_settings into _init_logging().
In-Reply-To: <1228932661-15662-4-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one we actually need to move.  _init_logging() is called from
    create_toolcontext(), which makes this call:
        /* Test mode */
        cmd->default_settings.test =
            find_config_tree_int(cmd, "global/test", 0);

But it does not call init_test().  So we need an init_test() somewhere.
The most logical place is to put it inside _init_logging(), since this
is where the config value is read and default_settings are set.  Placing
the init_test() call here matches what is done with other variables and
seems to make sense.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 tools/lvmcmdline.c         |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a987469..b240dc2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -162,6 +162,7 @@ static void _init_logging(struct cmd_context *cmd)
 	/* Test mode */
 	cmd->default_settings.test =
 	    find_config_tree_int(cmd, "global/test", 0);
+	init_test(cmd->default_settings.test);
 
 	/* Settings for logging to file */
 	if (find_config_tree_int(cmd, "log/overwrite", DEFAULT_OVERWRITE))
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 75f9c8c..a55c508 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,7 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 
-- 
1.5.5.1


