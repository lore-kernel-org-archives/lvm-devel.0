From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 16 Jan 2009 17:42:27 -0500
Subject: [PATCH] Replace is_long_lived with configuration variable read_cache_state.
Message-ID: <1232145747-31079-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This removes the last parameter from create_toolcontext() and
gives us a clean libLVM init API.

Original code was as follows.  Callers of create_toolcontext()
were:
1) commandline tools (lvmcmdline.c).  Set is_long_lived = 0.
2) clvmd.  Set is_long_lived = 1.

is_long_lived influenced both reading and writing of the
persistent devices cache.  I propose going forward we only
use the two explicit configuration variables to do this,
1) write_cache_state (already exists) and 2) read_cache_state.

For reading the persistent devices cache, read_cache_state is
== !is_long_lived (original code read the cache only
when !is_long_lived).  For writing the cache, the caller/user
must set write_cache_state.

We set read_cache_state to 1 by default, which matches the
original behavior of the tools, but not clvmd, for reading the
cache.  To replace original clvmd behavior, we will need another
API most likely or explicitly set the variable before calling
create_toolcontext().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |   17 +++++++++++------
 lib/commands/toolcontext.h    |    4 ++--
 lib/config/defaults.h         |    1 +
 lib/lvm2.h                    |    4 ++--
 man/lvm.conf.5.in             |    4 ++++
 tools/lvmcmdline.c            |    2 +-
 7 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c74bf26..c744768 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -724,7 +724,7 @@ void lvm_do_backup(const char *vgname)
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(1))) {
+	if (!(cmd = create_toolcontext())) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a98325..f82ab7c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -691,14 +691,20 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	if (find_config_tree_int(cmd, "devices/write_cache_state", 1))
 		cmd->dump_filter = 1;
 
-	if (!*cmd->sys_dir)
+	/* Should we ever load persistent filter state? */
+	if (find_config_tree_int(cmd, "devices/read_cache_state", 1))
+		cmd->read_cache_state = DEFAULT_READ_CACHE_STATE;
+
+	if (!*cmd->sys_dir) {
 		cmd->dump_filter = 0;
+		cmd->read_cache_state = DEFAULT_READ_CACHE_STATE;
+	}
 
 	/*
 	 * Only load persistent filter device cache on startup if it is newer
-	 * than the config file and this is not a long-lived process.
+	 * than the config file and told to do so
 	 */
-	if (load_persistent_cache && !cmd->is_long_lived &&
+	if (load_persistent_cache && cmd->read_cache_state &&
 	    !stat(dev_cache, &st) &&
 	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
 	    !persistent_filter_load(f4, NULL))
@@ -998,7 +1004,7 @@ static void _init_globals(struct cmd_context *cmd)
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(unsigned is_long_lived)
+struct cmd_context *create_toolcontext(void)
 {
 	struct cmd_context *cmd;
 
@@ -1020,7 +1026,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived)
 		return NULL;
 	}
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->formats);
@@ -1205,7 +1210,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	 * If we are a long-lived process, write out the updated persistent
 	 * device cache for the benefit of short-lived processes.
 	 */
-	if (cmd->is_long_lived && cmd->dump_filter)
+	if (cmd->dump_filter)
 		persistent_filter_dump(cmd->filter);
 
 	cmd->config_valid = 1;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7d2aef9..a4ef0e9 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -66,12 +66,12 @@ struct cmd_context {
 	char *cmd_line;
 	struct command *command;
 	char **argv;
-	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned partial_activation:1;
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
+	unsigned read_cache_state; /* read devices cache state during init */
 
 	struct dm_list config_files;
 	int config_valid;
@@ -94,7 +94,7 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
+struct cmd_context *create_toolcontext(void);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 605bc49..67bbe1b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -23,6 +23,7 @@
 #define DEFAULT_BACKUP_SUBDIR "backup"
 #define DEFAULT_CACHE_SUBDIR "cache"
 #define DEFAULT_CACHE_FILE_PREFIX ""
+#define DEFAULT_READ_CACHE_STATE 1
 
 #define DEFAULT_ARCHIVE_DAYS 30
 #define DEFAULT_ARCHIVE_NUMBER 10
diff --git a/lib/lvm2.h b/lib/lvm2.h
index b18cead..9101321 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -24,7 +24,7 @@
  */
 struct arg;
 struct cmd_context;
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
+struct cmd_context *create_toolcontext(void);
 void destroy_toolcontext(struct cmd_context *cmd);
 
 /*
@@ -37,7 +37,7 @@ lvm_handle_t lvm2_create(void);
  * NULL: Fail - unable to initialise handle.
  * non-NULL: Success - valid LVM2 handle returned
  */
-#define lvm2_create(X) create_toolcontext(1)
+#define lvm2_create(X) create_toolcontext()
 
 /*
  * lvm2_destroy
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index fdd728a..d1ce30b 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -111,6 +111,10 @@ Defaults to "/etc/lvm/cache".
 persistent filter cache file when \fBlvm\fP exits.
 Defaults to 1.
 .IP
+\fBread_cache_state\fP \(em Set to 0 to disable the reading in of the
+persistent filter cache file when \fBlvm\fP initializes.
+Defaults to 1.
+.IP
 \fBtypes\fP \(em List of pairs of additional acceptable block device types
 found in /proc/devices together with maximum (non-zero) number of
 partitions (normally 16).  By default, LVM2 supports ide, sd, md, loop, 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0b12750..4bcac86 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1159,7 +1159,7 @@ struct cmd_context *init_lvm(void)
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(0)))
+	if (!(cmd = create_toolcontext()))
 		return_NULL;
 
 	return cmd;
-- 
1.5.5.1


