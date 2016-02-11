From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:37 +0000 (UTC)
Subject: master - config: fix verbose type to int
Message-ID: <20160211173937.B53C960DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b76e9fd98bcbe89e1a73c8a0f7419c21799eecb
Commit:        3b76e9fd98bcbe89e1a73c8a0f7419c21799eecb
Parent:        02f2916b5be3f2f1dfdb9d1a76c753e46f1e480f
Author:        M.H. Tsai <mingnus@gmail.com>
AuthorDate:    Wed Jan 27 19:11:03 2016 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:30:39 2016 +0100

config: fix verbose type to int

'verbose' was marked as a boolean option while it
takes integer args - so it has limited usage to 0 or 1,
but we supported 0-4 at least.

Fix it by switching to corrent int type.
(Hopefully noone was trying to use this variable as true/yes/false/no
way - as the would be unsupported/undocumented).
---
 WHATS_NEW                    |    1 +
 lib/commands/toolcontext.c   |    2 +-
 lib/config/config_settings.h |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 002217d..a757f79 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Fix config type of 'log/verbose' from bool to int (2.02.99).
   Fix thinp watermark calc for data LV for faster dmeventd responce (2.02.133).
   Use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in.
   Do not check for suspended devices if scanning for lvmetad update.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4f94df4..1d7ca58 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -315,7 +315,7 @@ static void _init_logging(struct cmd_context *cmd)
 	init_silent(cmd->default_settings.silent);
 
 	/* Verbose level for tty output */
-	cmd->default_settings.verbose = find_config_tree_bool(cmd, log_verbose_CFG, NULL);
+	cmd->default_settings.verbose = find_config_tree_int(cmd, log_verbose_CFG, NULL);
 	init_verbose(cmd->default_settings.verbose + VERBOSE_BASE_LEVEL);
 
 	/* Log message formatting */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e554b8e..1143c8b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -535,7 +535,7 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
-cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
 
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL, 0, NULL,


