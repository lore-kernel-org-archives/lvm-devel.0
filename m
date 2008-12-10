From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:52 -0500
Subject: [PATCH 02/11] Remove init_debug() calls immediately after create_toolcontext() call.
In-Reply-To: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We can safely remove because create_toolcontext() calls _init_logging(),
which makes these calls:
        /* Debug level for log file output */
        cmd->default_settings.debug =
            find_config_tree_int(cmd, "log/level", DEFAULT_LOGLEVEL);
        init_debug(cmd->default_settings.debug);

Then at the bottom of create_toolcontext() we do this:
        cmd->current_settings = cmd->default_settings;

So the call we are removing from init_lvm() functions (clvmd and lvmcmdline):
        init_debug(cmd->current_settings.debug);

Just sets the value of debug based on 'cmd->current_settings.debug'.
Since cmd->current_settings is equivalent to cmd->default_settings, and
init_debug() was called with cmd->default_settings, the call we remove is
redundant.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 -
 tools/lvmcmdline.c            |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 621493c..1a7b198 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -732,7 +732,6 @@ int init_lvm(int using_gulm)
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	set_activation(cmd->current_settings.activation);
 	archive_enable(cmd, cmd->current_settings.archive);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 37ae834..fdffed3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1091,7 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
-- 
1.5.5.1


