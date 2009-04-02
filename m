From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:28 -0400
Subject: [RFC PATCH 5/7] add metadata cache interface
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F3A0.70906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Metadata cache is loaded into lvmcache if the lvm configuration parameter,
"backup/metadata_cache" has a value of "1" and MCACHE_DISABLE flag is not
set in its lvm command context.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/commands/toolcontext.c |   14 ++++++++++++++
 lib/config/defaults.h      |    1 +
 tools/lvmcmdline.c         |    4 ++++
 tools/tools.h              |    3 ++-
 4 files changed, 21 insertions(+), 1 deletion(-)

Index: LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/commands/toolcontext.c
+++ LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
@@ -929,6 +929,7 @@ static int _init_backup(struct cmd_conte
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
+		mcache_init(cmd, "", 0);
 		return 1;
 	}
 
@@ -980,6 +981,19 @@ static int _init_backup(struct cmd_conte
 		return 0;
 	}
 
+	/* set up the metadata cache */
+	cmd->default_settings.mcache =
+		find_config_tree_bool(cmd, "backup/metadata_cache",
+				      DEFAULT_MCACHE_ENABLED);
+
+	/* TODO: Currently mcache uses the same directory as backup, but
+	 * mcache should be put in its own directory, ex) /etc/lvm/mcache.
+	 */
+	if (!mcache_init(cmd, dir, cmd->default_settings.mcache)) {
+		log_debug("mcache_init failed.");
+		return 0;
+	}
+
 	return 1;
 }
 
Index: LVM2.02.46-cvs-20090324/lib/config/defaults.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/config/defaults.h
+++ LVM2.02.46-cvs-20090324/lib/config/defaults.h
@@ -18,6 +18,7 @@
 
 #define DEFAULT_ARCHIVE_ENABLED 1
 #define DEFAULT_BACKUP_ENABLED 1
+#define DEFAULT_MCACHE_ENABLED 0
 
 #define DEFAULT_ARCHIVE_SUBDIR "archive"
 #define DEFAULT_BACKUP_SUBDIR "backup"
Index: LVM2.02.46-cvs-20090324/tools/lvmcmdline.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/tools/lvmcmdline.c
+++ LVM2.02.46-cvs-20090324/tools/lvmcmdline.c
@@ -777,6 +777,7 @@ static int _get_settings(struct cmd_cont
 
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
+	cmd->current_settings.mcache &= cmd->command->flags & MCACHE_DISABLE ? 0 : 1;
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
 	cmd->partial_activation = 0;
 
@@ -892,6 +893,7 @@ static void _apply_settings(struct cmd_c
 
 	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
+	mcache_enable(cmd, cmd->current_settings.mcache);
 
 	set_activation(cmd->current_settings.activation);
 
@@ -1004,6 +1006,8 @@ int lvm_run_command(struct cmd_context *
 		goto out;
 	}
 
+	mcache_load(cmd);
+
 	ret = cmd->command->fn(cmd, argc, argv);
 
 	fin_locking();
Index: LVM2.02.46-cvs-20090324/tools/tools.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/tools/tools.h
+++ LVM2.02.46-cvs-20090324/tools/tools.h
@@ -116,7 +116,8 @@ struct arg {
 	void *ptr;
 };
 
-#define CACHE_VGMETADATA 0x00000001
+#define CACHE_VGMETADATA	0x00000001
+#define MCACHE_DISABLE		0x00000002
 
 /* a register of the lvm commands */
 struct command {





