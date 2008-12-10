From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:53 -0500
Subject: [PATCH 03/11] Remove init_verbose() calls immediately after create_toolcontext() calls.
In-Reply-To: <1228932661-15662-2-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The rationale for removing init_verbose() call is very similar to removing
init_debug() call.  create_toolcontext() calls _init_logging() which
makes these calls:
        /* Verbose level for tty output */
        cmd->default_settings.verbose =
            find_config_tree_int(cmd, "log/verbose", DEFAULT_VERBOSE);
        init_verbose(cmd->default_settings.verbose + VERBOSE_BASE_LEVEL);

And being that create_toolcontext() copies default_settings into
current_settings at the bottom, the init_verbose() call we are removing:
        init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);

is redundant.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 -
 tools/lvmcmdline.c            |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 1a7b198..9da99dd 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -732,7 +732,6 @@ int init_lvm(int using_gulm)
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	set_activation(cmd->current_settings.activation);
 	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fdffed3..9fcf6fe 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,7 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
-- 
1.5.5.1


