From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:28 +0200
Subject: [PATCH 5/5] Set our own in/out buffers
In-Reply-To: <cover.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
Message-ID: <0e34a9ec4665a437ec685e7845099d5080a2f659.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Memory lock from critical_section is now being kept over the critical
section - mallopt() should ensure, that mmap is not used for allocation,
and we preallocate some memory to be able to satisfy some small
alloc request. However when glibc needs buffers for line buffering of
input and output buffers - it allocates these buffers in such way it
adds memory page for each such buffer and size of unlock memory check will
mismatch by 1 or 2 pages.

This happens when we print or read lines without '\n' so these buffers
are used. To avoid this extra allocation, use setvbuf to set these
bufffers ahead.

Buffer are preallocated by the create_toolcontext flag.
For clvmd we keep the original glibc settings.

FIXME: Bigger fix is needs to avoid quering users while holding VG
locks, as such question might take quite some time....
Thus should in effect unlock memory before displaying such message.
But some more work needs to be done for this - so hack for now.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |   30 +++++++++++++++++++++++++++++-
 lib/commands/toolcontext.h    |    4 +++-
 liblvm/lvm_base.c             |    2 +-
 tools/lvmcmdline.c            |    2 +-
 5 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 166cd7f..8e68ed9 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -919,7 +919,7 @@ int init_clvm(int using_gulm, char **argv)
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 
-	if (!(cmd = create_toolcontext(1, NULL))) {
+	if (!(cmd = create_toolcontext(1, NULL, 0))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 30c8fc6..c2a8568 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -58,6 +58,8 @@
 #  include <malloc.h>
 #endif
 
+static const size_t linebuffer_size = 4096;
+
 static int _get_env_vars(struct cmd_context *cmd)
 {
 	const char *e;
@@ -1127,7 +1129,8 @@ static void _init_globals(struct cmd_context *cmd)
 
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
-				       const char *system_dir)
+				       const char *system_dir,
+				       unsigned set_buffering)
 {
 	struct cmd_context *cmd;
 
@@ -1162,6 +1165,22 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
 
+	/* Set in/out stream buffering before glibc */
+	if (set_buffering) {
+		/* Allocate 2 buffers */
+		if (!(cmd->linebuffer = dm_malloc(2 * linebuffer_size))) {
+			log_error("Failed to allocate line buffer.");
+			goto out;
+		}
+		if ((setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size) ||
+		     setvbuf(stdout, cmd->linebuffer + linebuffer_size,
+			     _IOLBF, linebuffer_size))) {
+			log_sys_error("setvbuf", "");
+			goto out;
+		}
+		/* Buffers are used for lines without '\n' */
+	}
+
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
@@ -1398,6 +1417,15 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	_destroy_tag_configs(cmd);
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
+
+	if (cmd->linebuffer) {
+		/* Reset stream buffering to defaults */
+		setlinebuf(stdin);
+		fflush(stdout);
+		setlinebuf(stdout);
+		dm_free(cmd->linebuffer);
+	}
+
 	dm_free(cmd);
 
 	release_log_memory();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4628c7c..1c3368e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -66,6 +66,7 @@ struct cmd_context {
 	const char *kernel_vsn;
 
 	unsigned rand_seed;
+	char *linebuffer;
 	const char *cmd_line;
 	struct command *command;
 	char **argv;
@@ -109,7 +110,8 @@ struct cmd_context {
  * The environment variable LVM_SYSTEM_DIR always takes precedence.
  */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
-				       const char *system_dir);
+				       const char *system_dir,
+				       unsigned set_buffering);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int refresh_filters(struct cmd_context *cmd);
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 9e1a8ec..f44b786 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -34,7 +34,7 @@ lvm_t lvm_init(const char *system_dir)
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
-	cmd = create_toolcontext(0, system_dir);
+	cmd = create_toolcontext(0, system_dir, 1);
 	if (!cmd)
 		return NULL;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ddf0b5e..04f6a5c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1283,7 +1283,7 @@ struct cmd_context *init_lvm(void)
 {
 	struct cmd_context *cmd;
 
-	if (!(cmd = create_toolcontext(0, NULL)))
+	if (!(cmd = create_toolcontext(0, NULL, 1)))
 		return_NULL;
 
 	_cmdline.arg_props = &_arg_props[0];
-- 
1.7.4.4


