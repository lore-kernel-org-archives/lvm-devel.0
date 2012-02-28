From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2012 13:05:21 -0000
Subject: LVM2/daemons/common daemon-server.c
Message-ID: <20120228130521.28603.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-28 13:05:21

Modified files:
	daemons/common : daemon-server.c 

Log message:
	Add support for systemd socket handover for common daemon-server code and also add support for new OOM killer adjustment interface.
	
	This code is already a part of dmeventd, but it's modified slightly to check
	sockets instead of FIFOs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/daemons/common/daemon-server.c	2012/02/23 23:52:11	1.17
+++ LVM2/daemons/common/daemon-server.c	2012/02/28 13:05:21	1.18
@@ -43,6 +43,7 @@
 #endif
 
 static volatile sig_atomic_t _shutdown_requested = 0;
+static int _systemd_activation = 0;
 
 static void _exit_handler(int sig __attribute__((unused)))
 {
@@ -50,41 +51,148 @@
 }
 
 #ifdef linux
-#  define OOM_ADJ_FILE "/proc/self/oom_adj"
-#  include <stdio.h>
+
+#include <stddef.h>
+
+/*
+ * Kernel version 2.6.36 and higher has
+ * new OOM killer adjustment interface.
+ */
+#  define OOM_ADJ_FILE_OLD "/proc/self/oom_adj"
+#  define OOM_ADJ_FILE "/proc/self/oom_score_adj"
 
 /* From linux/oom.h */
+/* Old interface */
 #  define OOM_DISABLE (-17)
 #  define OOM_ADJUST_MIN (-16)
+/* New interface */
+#  define OOM_SCORE_ADJ_MIN (-1000)
+
+/* Systemd on-demand activation support */
+#  define SD_LISTEN_PID_ENV_VAR_NAME "LISTEN_PID"
+#  define SD_LISTEN_FDS_ENV_VAR_NAME "LISTEN_FDS"
+#  define SD_LISTEN_FDS_START 3
+#  define SD_FD_SOCKET_SERVER SD_LISTEN_FDS_START
+
+#  include <stdio.h>
+
+static int _set_oom_adj(const char *oom_adj_path, int val)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(oom_adj_path, "w"))) {
+		perror("oom_adj: fopen failed");
+		return 0;
+	}
+
+	fprintf(fp, "%i", val);
+
+	if (dm_fclose(fp))
+		perror("oom_adj: fclose failed");
+
+	return 1;
+}
 
 /*
  * Protection against OOM killer if kernel supports it
  */
-static int _set_oom_adj(int val)
+static int _protect_against_oom_killer(void)
 {
-	FILE *fp;
-
 	struct stat st;
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
-		if (errno == ENOENT)
-			perror(OOM_ADJ_FILE " not found");
-		else
+		if (errno != ENOENT)
 			perror(OOM_ADJ_FILE ": stat failed");
-		return 1;
+
+		/* Try old oom_adj interface as a fallback */
+		if (stat(OOM_ADJ_FILE_OLD, &st) == -1) {
+			if (errno == ENOENT)
+				perror(OOM_ADJ_FILE_OLD " not found");
+			else
+				perror(OOM_ADJ_FILE_OLD ": stat failed");
+			return 1;
+		}
+
+		return _set_oom_adj(OOM_ADJ_FILE_OLD, OOM_DISABLE) ||
+		       _set_oom_adj(OOM_ADJ_FILE_OLD, OOM_ADJUST_MIN);
 	}
 
-	if (!(fp = fopen(OOM_ADJ_FILE, "w"))) {
-		perror(OOM_ADJ_FILE ": fopen failed");
+	return _set_oom_adj(OOM_ADJ_FILE, OOM_SCORE_ADJ_MIN);
+}
+
+union sockaddr_union {
+	struct sockaddr sa;
+	struct sockaddr_un un;
+};
+
+static int _handle_preloaded_socket(int fd, const char *path)
+{
+	struct stat st_fd;
+	union sockaddr_union sockaddr;
+	int type = 0;
+	socklen_t len = sizeof(type);
+	size_t path_len = strlen(path);
+
+	if (fd < 0)
 		return 0;
-	}
 
-	fprintf(fp, "%i", val);
-	if (fclose(fp))
-		perror(OOM_ADJ_FILE ": fclose failed");
+	if (fstat(fd, &st_fd) < 0 || !S_ISSOCK(st_fd.st_mode))
+		return 0;
+
+	if (getsockopt(fd, SOL_SOCKET, SO_TYPE, &type, &len) < 0 ||
+	    len != sizeof(type) || type != SOCK_STREAM)
+		return 0;
+
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	len = sizeof(sockaddr);
+	if (getsockname(fd, &sockaddr.sa, &len) < 0 ||
+	    len < sizeof(sa_family_t) ||
+	    sockaddr.sa.sa_family != PF_UNIX)
+		return 0;
+
+	if (!(len >= offsetof(struct sockaddr_un, sun_path) + path_len + 1 &&
+	      memcmp(path, sockaddr.un.sun_path, path_len) == 0))
+		return 0;
 
 	return 1;
 }
+
+static int _systemd_handover(struct daemon_state *ds)
+{
+	const char *e;
+	char *p;
+	unsigned long env_pid, env_listen_fds;
+	int r = 0;
+
+	/* LISTEN_PID must be equal to our PID! */
+	if (!(e = getenv(SD_LISTEN_PID_ENV_VAR_NAME)))
+		goto out;
+
+	errno = 0;
+	env_pid = strtoul(e, &p, 10);
+	if (errno || !p || *p || env_pid <= 0 ||
+	    getpid() != (pid_t) env_pid)
+		;
+
+	/* LISTEN_FDS must be 1 and the fd must be a socket! */
+	if (!(e = getenv(SD_LISTEN_FDS_ENV_VAR_NAME)))
+		goto out;
+
+	errno = 0;
+	env_listen_fds = strtoul(e, &p, 10);
+	if (errno || !p || *p || env_listen_fds != 1)
+		goto out;
+
+	/* Check and handle the socket passed in */
+	if ((r = _handle_preloaded_socket(SD_FD_SOCKET_SERVER, ds->socket_path)))
+		ds->socket_fd = SD_FD_SOCKET_SERVER;
+
+out:
+	unsetenv(SD_LISTEN_PID_ENV_VAR_NAME);
+	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
+	return r;
+}
+
 #endif
 
 static int _open_socket(daemon_state s)
@@ -192,8 +300,14 @@
 	else
 		fd = rlim.rlim_cur;
 
-	for (--fd; fd >= 0; fd--)
+	for (--fd; fd >= 0; fd--) {
+#ifdef linux
+		/* Do not close fds preloaded by systemd! */
+		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
+			continue;
+#endif
 		close(fd);
+	}
 
 	if ((open("/dev/null", O_RDONLY) < 0) ||
 	    (open("/dev/null", O_WRONLY) < 0) ||
@@ -328,6 +442,10 @@
 	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
+#ifdef linux
+	_systemd_activation = _systemd_handover(&s);
+#endif
+
 	if (!s.foreground)
 		_daemonise();
 
@@ -354,11 +472,12 @@
 	signal(SIGPIPE, SIG_IGN);
 
 #ifdef linux
-	if (s.avoid_oom && !_set_oom_adj(OOM_DISABLE) && !_set_oom_adj(OOM_ADJUST_MIN))
-		syslog(LOG_ERR, "Failed to set oom_adj to protect against OOM killer");
+	/* Systemd has adjusted oom killer for us already */
+	if (s.avoid_oom && !_systemd_activation && !_protect_against_oom_killer())
+		syslog(LOG_ERR, "Failed to protect against OOM killer");
 #endif
 
-	if (s.socket_path) {
+	if (!_systemd_activation && s.socket_path) {
 		s.socket_fd = _open_socket(s);
 		if (s.socket_fd < 0)
 			failed = 1;


