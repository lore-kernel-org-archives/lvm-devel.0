From: Thomas Woerner <twoerner@redhat.com>
Date: Thu, 11 Dec 2008 17:43:40 +0100
Subject: [PATCH] Renamed create_toolcontext function to _create_context and added sys_dir as argument, new functions create_librarycontext and create_toolcontext.
In-Reply-To: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
Message-ID: <1229013822-10809-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/commands/toolcontext.c |   25 +++++++++++++++++++++----
 lib/commands/toolcontext.h |    1 +
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e9ef66c..e37af6e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -990,9 +990,10 @@ static void _init_rand(struct cmd_context *cmd)
 	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
 }
 
-/* Entry point */
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
-				       unsigned is_long_lived)
+static struct cmd_context *_create_context(struct arg *the_args,
+					   unsigned is_static,
+					   unsigned is_long_lived,
+					   const char *sys_dir)
 {
 	struct cmd_context *cmd;
 
@@ -1024,7 +1025,10 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
 
-	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
+	strncpy(cmd->sys_dir, DEFAULT_SYS_DIR, PATH_MAX);
+	
+	if (sys_dir)
+		strncpy(cmd->sys_dir, sys_dir, PATH_MAX);
 
 	if (!_get_env_vars(cmd))
 		goto error;
@@ -1101,6 +1105,19 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 	return NULL;
 }
 
+/* Library Entry point */
+struct cmd_context *create_librarycontext(const char *sys_dir)
+{
+	return _create_context(NULL, 0, 1, sys_dir);
+}
+
+/* Tool Entry point */
+struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
+				       unsigned is_long_lived)
+{
+	return _create_context(the_args, is_static, is_long_lived, NULL);
+}
+
 static void _destroy_formats(struct dm_list *formats)
 {
 	struct dm_list *fmtl, *tmp;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4ea3486..a37911f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -96,6 +96,7 @@ struct cmd_context {
 	char sysfs_dir[PATH_MAX];
 };
 
+struct cmd_context *create_librarycontext(const char *sys_dir);
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
-- 
1.6.0.4


