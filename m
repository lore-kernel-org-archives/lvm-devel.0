From: Kylie McClain <somasissounds@gmail.com>
Date: Mon, 30 May 2016 16:55:59 -0400
Subject: [PATCH] Fix building on musl libc
Message-ID: <20160530205559.10864-1-somasissounds@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Kylie McClain <somasis@exherbo.org>

This patch fixes building and using lvm2 on musl libc. These are taken from
Alpine Linux, with permission to submit upstream from Natanael Copa <ncopa@alpinelinux.org>.
---
 lib/commands/toolcontext.c | 22 +++++++++++-----------
 lib/mm/memlock.c           |  2 +-
 tools/lvmcmdline.c         |  6 +++---
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1e3f14a..5c6a030 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1645,7 +1645,10 @@ static void _init_globals(struct cmd_context *cmd)
 /*
  * Close and reopen stream on file descriptor fd.
  */
-static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *name, FILE **new_stream)
+#ifdef __GLIBC__
+#define _reopen_stream(stream, fd, mode, name) __reopen_stream(stream, fd, mode, name, &stream)
+
+static int __reopen_stream(FILE *stream, int fd, const char *mode, const char *name, FILE **new_stream)
 {
 	int fd_copy, new_fd;
 
@@ -1672,6 +1675,9 @@ static int _reopen_stream(FILE *stream, int fd, const char *mode, const char *na
 
 	return 1;
 }
+#else
+#define _reopen_stream(stream, fd, mode, name) (freopen(NULL, mode, stream) != NULL)
+#endif
 
 /*
  * init_connections();
@@ -1828,7 +1834,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       unsigned set_filters)
 {
 	struct cmd_context *cmd;
-	FILE *new_stream;
 	int flags;
 
 #ifdef M_MMAP_MAX
@@ -1878,9 +1883,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDIN_FILENO) &&
 		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_WRONLY) {
-			if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
+			if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin"))
 				goto_out;
-			stdin = new_stream;
 			if (setvbuf(stdin, cmd->linebuffer, _IOLBF, linebuffer_size)) {
 				log_sys_error("setvbuf", "");
 				goto out;
@@ -1890,9 +1894,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		if (is_valid_fd(STDOUT_FILENO) &&
 		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_RDONLY) {
-			if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream))
+			if (!_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout"))
 				goto_out;
-			stdout = new_stream;
 			if (setvbuf(stdout, cmd->linebuffer + linebuffer_size,
 				     _IOLBF, linebuffer_size)) {
 				log_sys_error("setvbuf", "");
@@ -2218,7 +2221,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 void destroy_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline;
-	FILE *new_stream;
 	int flags;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
@@ -2254,8 +2256,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 		if (is_valid_fd(STDIN_FILENO) &&
 		    ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_WRONLY) {
-			if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
-				stdin = new_stream;
+			if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin")) {
 				setlinebuf(stdin);
 			} else
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
@@ -2264,8 +2265,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 		if (is_valid_fd(STDOUT_FILENO) &&
 		    ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
 		    (flags & O_ACCMODE) != O_RDONLY) {
-			if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
-				stdout = new_stream;
+			if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout")) {
 				setlinebuf(stdout);
 			} else
 				cmd->linebuffer = NULL;	/* Leave buffer in place (deliberate leak) */
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 851cd33..1a1915b 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -145,7 +145,7 @@ static void _touch_memory(void *mem, size_t size)
 
 static void _allocate_memory(void)
 {
-#ifndef VALGRIND_POOL
+#if !defined(VALGRIND_POOL) && defined(__GLIBC__)
 	void *stack_mem;
 	struct rlimit limit;
 	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32, hblks;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index be6821b..2095fbe 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1798,7 +1798,7 @@ static int _check_standard_fds(void)
 	int err = is_valid_fd(STDERR_FILENO);
 
 	if (!is_valid_fd(STDIN_FILENO) &&
-	    !(stdin = fopen(_PATH_DEVNULL, "r"))) {
+	    !freopen(_PATH_DEVNULL, "r", stdin)) {
 		if (err)
 			perror("stdin stream open");
 		else
@@ -1808,7 +1808,7 @@ static int _check_standard_fds(void)
 	}
 
 	if (!is_valid_fd(STDOUT_FILENO) &&
-	    !(stdout = fopen(_PATH_DEVNULL, "w"))) {
+	    !freopen(_PATH_DEVNULL, "w", stdout)) {
 		if (err)
 			perror("stdout stream open");
 		/* else no stdout */
@@ -1816,7 +1816,7 @@ static int _check_standard_fds(void)
 	}
 
 	if (!is_valid_fd(STDERR_FILENO) &&
-	    !(stderr = fopen(_PATH_DEVNULL, "w"))) {
+	    !freopen(_PATH_DEVNULL, "w", stderr)) {
 		printf("stderr stream open: %s\n",
 		       strerror(errno));
 		return 0;
-- 
2.8.3


