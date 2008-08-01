From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Aug 2008 19:51:28 -0000
Subject: LVM2 lib/datastruct/lvm-types.h ./WHATS_NEW to ...
Message-ID: <20080801195128.27026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-08-01 19:51:27

Modified files:
	lib/datastruct : lvm-types.h 
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Improve file descriptor leak detection to display likely culprit and filename.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.942&r2=1.943
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/lib/datastruct/lvm-types.h	2007/08/20 20:55:24	1.13
+++ LVM2/lib/datastruct/lvm-types.h	2008/08/01 19:51:27	1.14
@@ -24,6 +24,7 @@
 /* Define some portable printing types */
 #define PRIsize_t "zu"
 #define PRIptrdiff_t "td"
+#define PRIpid_t PRId32
 
 struct str_list {
 	struct list list;
--- LVM2/WHATS_NEW	2008/07/31 14:43:39	1.942
+++ LVM2/WHATS_NEW	2008/08/01 19:51:27	1.943
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Improve file descriptor leak detection to display likely culprit and filename.
   Change clustered mirror kernel module name from cmirror to dm-log-clustered.
   Avoid looping forever in _pv_analyze_mda_raw used by pvck.
   Change lvchange exit status to indicate if any part of the operation failed.
--- LVM2/tools/lvmcmdline.c	2008/07/31 15:38:52	1.68
+++ LVM2/tools/lvmcmdline.c	2008/08/01 19:51:27	1.69
@@ -1001,11 +1001,76 @@
 	srand((unsigned) time(NULL) + (unsigned) getpid());
 }
 
-static void _close_stray_fds(void)
+static const char *_get_cmdline(pid_t pid)
+{
+	static char _proc_cmdline[32];
+	char buf[256];
+	int fd;
+
+	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);
+	if ((fd = open(buf, O_RDONLY)) > 0) {
+		read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1);
+		_proc_cmdline[sizeof(_proc_cmdline) - 1] = '\0';
+		close(fd);
+	} else
+		_proc_cmdline[0] = '\0';
+
+	return _proc_cmdline;
+}
+
+static const char *_get_filename(int fd)
+{
+	static char filename[PATH_MAX];
+	char buf[32];	/* Assumes short DEFAULT_PROC_DIR */
+	int size;
+
+	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/self/fd/%u", fd);
+
+	if ((size = readlink(buf, filename, sizeof(filename) - 1)) == -1)
+		filename[0] = '\0';
+	else
+		filename[size] = '\0';
+
+	return filename;
+}
+
+static void _close_descriptor(int fd, unsigned suppress_warnings,
+			      const char *command, pid_t ppid,
+			      const char *parent_cmdline)
+{
+	int r;
+	const char *filename;
+
+	/* Ignore bad file descriptors */
+	if (fcntl(fd, F_GETFD) == -1 && errno == EBADF)
+		return;
+
+	if (!suppress_warnings)
+		filename = _get_filename(fd);
+
+	r = close(fd);
+	if (suppress_warnings)
+		return;
+
+	if (!r)
+		fprintf(stderr, "File descriptor %d (%s) leaked on "
+			"%s invocation.", fd, filename, command);
+	else if (errno == EBADF)
+		return;
+	else
+		fprintf(stderr, "Close failed on stray file descriptor "
+			"%d (%s): %s", fd, filename, strerror(errno));
+
+	fprintf(stderr, " Parent PID %" PRIpid_t ": %s\n", ppid, parent_cmdline);
+}
+
+static void _close_stray_fds(const char *command)
 {
 	struct rlimit rlim;
 	int fd;
-	int suppress_warnings = 0;
+	unsigned suppress_warnings = 0;
+	pid_t ppid = getppid();
+	const char *parent_cmdline = _get_cmdline(ppid);
 
 	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0) {
 		fprintf(stderr, "getrlimit(RLIMIT_NOFILE) failed: %s\n",
@@ -1016,15 +1081,9 @@
 	if (getenv("LVM_SUPPRESS_FD_WARNINGS"))
 		suppress_warnings = 1;
 
-	for (fd = 3; fd < rlim.rlim_cur; fd++) {
-		if (suppress_warnings)
-			close(fd);
-		else if (!close(fd))
-			fprintf(stderr, "File descriptor %d left open\n", fd);
-		else if (errno != EBADF)
-			fprintf(stderr, "Close failed on stray file "
-				"descriptor %d: %s\n", fd, strerror(errno));
-	}
+	for (fd = 3; fd < rlim.rlim_cur; fd++)
+		_close_descriptor(fd, suppress_warnings, command, ppid,
+				  parent_cmdline);
 }
 
 struct cmd_context *init_lvm(unsigned is_static)
@@ -1162,13 +1221,13 @@
 	int ret, alias = 0;
 	struct cmd_context *cmd;
 
-	_close_stray_fds();
-
 	base = last_path_component(argv[0]);
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
 	    strcmp(base, "initrd-lvm"))
 		alias = 1;
 
+	_close_stray_fds(base);
+
 	if (is_static && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {


