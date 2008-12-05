From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  5 Dec 2008 17:52:45 -0500
Subject: [PATCH] Make _init_rand() thread safe - use rand_r() instead of rand().
Message-ID: <1228517565-28873-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This random code is for temp files.  Other code which uses
/dev/urandom is used for uuids.  Should we be using /dev/urandom
everywhere?

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c    |    7 +++++++
 lib/commands/toolcontext.h    |    1 +
 lib/format_text/archive.c     |    3 ++-
 lib/format_text/format-text.c |    3 ++-
 lib/misc/lvm-file.c           |    5 +++--
 lib/misc/lvm-file.h           |    3 ++-
 tools/lvmcmdline.c            |    7 -------
 7 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f49c7c6..5eb1039 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -979,6 +979,11 @@ static int _init_backup(struct cmd_context *cmd)
 	return 1;
 }
 
+static void _init_rand(struct cmd_context *cmd)
+{
+	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 				       unsigned is_long_lived)
@@ -1077,6 +1082,8 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 	if (!_init_backup(cmd))
 		goto error;
 
+	_init_rand(cmd);
+
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 6cbf6a6..4ea3486 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -62,6 +62,7 @@ struct cmd_context {
 	const char *hostname;
 	const char *kernel_vsn;
 
+	unsigned rand_seed;
 	char *cmd_line;
 	struct command *command;
 	struct arg *args;
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index b232db7..3e5b0c4 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -236,7 +236,8 @@ int archive_vg(struct volume_group *vg,
 	/*
 	 * Write the vg out to a temporary file.
 	 */
-	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd)) {
+	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd,
+			      &vg->cmd->rand_seed)) {
 		log_err("Couldn't create temporary archive name.");
 		return 0;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index fc4e5ff..af9c2ac 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -848,7 +848,8 @@ static int _vg_write_file(struct format_instance *fid __attribute((unused)),
 		return 0;
 	}
 
-	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd)) {
+	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
+			      &vg->cmd->rand_seed)) {
 		log_err("Couldn't create temporary text file name.");
 		return 0;
 	}
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 3e812d1..a5a5f2b 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -29,7 +29,8 @@
  * rename the file after successfully writing it.  Grab
  * NFS-supported exclusive fcntl discretionary lock.
  */
-int create_temp_name(const char *dir, char *buffer, size_t len, int *fd)
+int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
+		     unsigned *seed)
 {
 	int i, num;
 	pid_t pid;
@@ -41,7 +42,7 @@ int create_temp_name(const char *dir, char *buffer, size_t len, int *fd)
 		.l_len = 0
 	};
 
-	num = rand();
+	num = rand_r(seed);
 	pid = getpid();
 	if (gethostname(hostname, sizeof(hostname)) < 0) {
 		log_sys_error("gethostname", "");
diff --git a/lib/misc/lvm-file.h b/lib/misc/lvm-file.h
index 8110be1..07327c3 100644
--- a/lib/misc/lvm-file.h
+++ b/lib/misc/lvm-file.h
@@ -19,7 +19,8 @@
 /*
  * Create a temporary filename, and opens a descriptor to the file.
  */
-int create_temp_name(const char *dir, char *buffer, size_t len, int *fd);
+int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
+		     unsigned *seed);
 
 /*
  * NFS-safe rename of a temporary file to a common name, designed
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 78e9e60..29b4c15 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -997,11 +997,6 @@ int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static void _init_rand(void)
-{
-	srand((unsigned) time(NULL) + (unsigned) getpid());
-}
-
 static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
@@ -1096,8 +1091,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	_init_rand();
-
 	_apply_settings(cmd);
 
 	return cmd;
-- 
1.5.5.1


