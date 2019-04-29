From: David Teigland <teigland@sourceware.org>
Date: Mon, 29 Apr 2019 15:31:59 -0400
Subject: master - hints: skip hint flock if nolocking option is set
Message-ID: <201904291931.x3TJVxLj011022@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3e385c1087321986ae1bc9346f2b00f5790e75c
Commit:        c3e385c1087321986ae1bc9346f2b00f5790e75c
Parent:        a519be8d4b9818f6715eb43a4e9427a4b1dd61ab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 25 13:34:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 29 13:01:15 2019 -0500

hints: skip hint flock if nolocking option is set

---
 lib/commands/toolcontext.c |    4 ++--
 lib/commands/toolcontext.h |    1 +
 lib/label/hints.c          |   34 ++++++++++++++++++++--------------
 lib/label/hints.h          |    2 +-
 tools/lvmcmdline.c         |    6 ++++--
 5 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 15e3499..2642d23 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1821,7 +1821,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	 */
 
 	activation_release();
-	hints_exit();
+	hints_exit(cmd);
 	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
 	label_exit();
@@ -1941,7 +1941,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	archive_exit(cmd);
 	backup_exit(cmd);
-	hints_exit();
+	hints_exit(cmd);
 	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
 	label_exit();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 095477c..c9def87 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -162,6 +162,7 @@ struct cmd_context {
 	unsigned lockd_lv_sh_for_ex:1;
 	unsigned lockd_global_ex:1;		/* set while global lock held ex (lockd) */
 	unsigned lockf_global_ex:1;		/* set while global lock held ex (flock) */
+	unsigned nolocking:1;
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
diff --git a/lib/label/hints.c b/lib/label/hints.c
index ecb70ef..00bfbe3 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -294,12 +294,15 @@ static int _clear_hints(struct cmd_context *cmd)
 	return 1;
 }
 
-static int _lock_hints(int mode, int nonblock)
+static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 {
 	int fd;
 	int op = mode;
 	int ret;
 
+	if (cmd->nolocking)
+		return 1;
+
 	if (nonblock)
 		op |= LOCK_NB;
 
@@ -326,10 +329,13 @@ static int _lock_hints(int mode, int nonblock)
 	return 0;
 }
 
-static void _unlock_hints(void)
+static void _unlock_hints(struct cmd_context *cmd)
 {
 	int ret;
 
+	if (cmd->nolocking)
+		return;
+
 	if (_hints_fd == -1) {
 		log_warn("unlock_hints no existing fd");
 		return;
@@ -344,11 +350,11 @@ static void _unlock_hints(void)
 	_hints_fd = -1;
 }
 
-void hints_exit(void)
+void hints_exit(struct cmd_context *cmd)
 {
 	if (_hints_fd == -1)
 		return;
-	return _unlock_hints();
+	return _unlock_hints(cmd);
 }
 
 static struct hint *_find_hint_name(struct dm_list *hints, const char *name)
@@ -941,7 +947,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
  out_unlock:
 	/* get_hints() took ex lock before returning with newhints set */
-	_unlock_hints();
+	_unlock_hints(cmd);
 
 	return ret;
 }
@@ -1006,7 +1012,7 @@ void clear_hint_file(struct cmd_context *cmd)
 	if (!_touch_nohints())
 		stack;
 
-	if (!_lock_hints(LOCK_EX, 0))
+	if (!_lock_hints(cmd, LOCK_EX, 0))
 		stack;
 
 	_unlink_nohints();
@@ -1042,7 +1048,7 @@ void pvscan_recreate_hints_begin(struct cmd_context *cmd)
 	if (!_touch_nohints())
 		stack;
 
-	if (!_lock_hints(LOCK_EX, 0))
+	if (!_lock_hints(cmd, LOCK_EX, 0))
 		stack;
 
 	_unlink_nohints();
@@ -1194,7 +1200,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 		log_debug("get_hints: newhints file");
 		if (!_hints_exists())
 			_touch_hints();
-		if (!_lock_hints(LOCK_EX, NONBLOCK))
+		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 		/* create new hints after scan */
 		*newhints = NEWHINTS_FILE;
@@ -1208,7 +1214,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 		log_debug("get_hints: no file");
 		if (!_touch_hints())
 			return 0;
-		if (!_lock_hints(LOCK_EX, NONBLOCK))
+		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 		/* create new hints after scan */
 		*newhints = NEWHINTS_INIT;
@@ -1221,7 +1227,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 * We hold a sh lock on the hints file while reading it to prevent
 	 * another command from clearing it while we're reading
 	 */
-	if (!_lock_hints(LOCK_SH, NONBLOCK)) {
+	if (!_lock_hints(cmd, LOCK_SH, NONBLOCK)) {
 		log_debug("get_hints: lock fail");
 		return 0;
 	}
@@ -1231,11 +1237,11 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 */
 	if (!_read_hint_file(cmd, &hints_list, &needs_refresh)) {
 		log_debug("get_hints: read fail");
-		_unlock_hints();
+		_unlock_hints(cmd);
 		return 0;
 	}
 
-	_unlock_hints();
+	_unlock_hints(cmd);
 
 	/*
 	 * The content of the hint file is invalid and should be refreshed,
@@ -1244,7 +1250,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	if (needs_refresh) {
 		log_debug("get_hints: needs refresh");
 
-		if (!_lock_hints(LOCK_EX, NONBLOCK))
+		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 
 		/* create new hints after scan */
@@ -1261,7 +1267,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	if (dm_list_empty(&hints_list)) {
 		log_debug("get_hints: no entries");
 
-		if (!_lock_hints(LOCK_EX, NONBLOCK))
+		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 
 		/* create new hints after scan */
diff --git a/lib/label/hints.h b/lib/label/hints.h
index 0134f1e..7f47648 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -35,7 +35,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 
 int validate_hints(struct cmd_context *cmd, struct dm_list *hints);
 
-void hints_exit(void);
+void hints_exit(struct cmd_context *cmd);
 
 void pvscan_recreate_hints_begin(struct cmd_context *cmd);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1e3b1e3..0422613 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2958,7 +2958,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		log_warn("WARNING: locking_type (%d) is deprecated, using file locking.", locking_type);
 	}
 
-	if (arg_is_set(cmd, nolocking_ARG) || _cmd_no_meta_proc(cmd))
+	cmd->nolocking = arg_is_set(cmd, nolocking_ARG);
+
+	if (cmd->nolocking || _cmd_no_meta_proc(cmd))
 		nolocking = 1;
 
 	if (arg_is_set(cmd, sysinit_ARG))
@@ -2997,7 +2999,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
       out:
 
-	hints_exit();
+	hints_exit(cmd);
 	lvmcache_destroy(cmd, 1, 1);
 	label_scan_destroy(cmd);
 


