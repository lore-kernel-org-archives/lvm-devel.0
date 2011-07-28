From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2011 13:06:51 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20110728130651.19872.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-07-28 13:06:50

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Add support for systemd file descriptor handover in dmeventd.
	
	Systemd preloads file descriptors for us and passes them in for
	newly spawned daemon when using on-demand fifo (or socket)
	based activation.
	
	This patch adds checks for file descriptors preloaded by
	systemd and uses them instead of opening the FIFOs again
	to properly support on-demand FIFO-based activation.
	
	(We'll change FIFOs to sockets soon - but still this
	part of the code will stay almost the same.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.484&r2=1.485
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/WHATS_NEW_DM	2011/07/28 13:03:37	1.484
+++ LVM2/WHATS_NEW_DM	2011/07/28 13:06:50	1.485
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Add support for systemd file descriptor handover in dmeventd.
   Add support for new oom killer adjustment interface (oom_score_adj).
   Add systemd unit files for dmeventd.
   Fix read-only identical table reload supression.
--- LVM2/daemons/dmeventd/dmeventd.c	2011/07/28 13:03:37	1.81
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/07/28 13:06:50	1.82
@@ -55,6 +55,13 @@
 /* New interface */
 #  define OOM_SCORE_ADJ_MIN (-1000)
 
+/* Systemd on-demand activation support */
+#  define SD_LISTEN_PID_ENV_VAR_NAME "LISTEN_PID"
+#  define SD_LISTEN_FDS_ENV_VAR_NAME "LISTEN_FDS"
+#  define SD_LISTEN_FDS_START 3
+#  define SD_FD_FIFO_SERVER SD_LISTEN_FDS_START
+#  define SD_FD_FIFO_CLIENT (SD_LISTEN_FDS_START + 1)
+
 #endif
 
 /* FIXME We use syslog for now, because multilog is not yet implemented */
@@ -104,6 +111,7 @@
 #define THREAD_STACK_SIZE (300*1024)
 
 int dmeventd_debug = 0;
+static int _systemd_activation = 0;
 static int _foreground = 0;
 static int _restart = 0;
 static char **_initial_registrations = 0;
@@ -1710,8 +1718,13 @@
 	else
 		fd = rlim.rlim_cur;
 
-	for (--fd; fd >= 0; fd--)
+	for (--fd; fd >= 0; fd--) {
+		/* Do not close fds preloaded by systemd! */
+		if (_systemd_activation &&
+		    (fd == SD_FD_FIFO_SERVER || fd == SD_FD_FIFO_CLIENT))
+			continue;
 		close(fd);
+	}
 
 	if ((open("/dev/null", O_RDONLY) < 0) ||
 	    (open("/dev/null", O_WRONLY) < 0) ||
@@ -1780,6 +1793,76 @@
 	fini_fifos(&fifos);
 }
 
+static int _handle_preloaded_fifo(int fd, const char *path)
+{
+	struct stat st_fd, st_path;
+	int flags;
+
+	if ((flags = fcntl(fd, F_GETFD)) < 0)
+		return 0;
+
+	if (flags & FD_CLOEXEC)
+		return 0;
+
+	if (fstat(fd, &st_fd) < 0 || !S_ISFIFO(st_fd.st_mode))
+		return 0;
+
+	if (stat(path, &st_path) < 0 ||
+	    st_path.st_dev != st_fd.st_dev ||
+	    st_path.st_ino != st_fd.st_ino)
+		return 0;
+
+	if (fcntl(fd, F_SETFD, flags | FD_CLOEXEC) < 0)
+		return 0;
+
+	return 1;
+}
+
+static int _systemd_handover(struct dm_event_fifos *fifos)
+{
+	const char *e;
+	char *p;
+	unsigned long env_pid, env_listen_fds;
+	int r = 0;
+
+	memset(fifos, 0, sizeof(*fifos));
+
+	/* LISTEN_PID must be equal to our PID! */
+	if (!(e = getenv(SD_LISTEN_PID_ENV_VAR_NAME)))
+		goto out;
+
+	errno = 0;
+	env_pid = strtoul(e, &p, 10);
+	if (errno || !p || *p || env_pid <= 0 ||
+	    getpid() != (pid_t) env_pid)
+		goto out;
+
+	/* LISTEN_FDS must be 2 and the fds must be FIFOSs! */
+	if (!(e = getenv(SD_LISTEN_FDS_ENV_VAR_NAME)))
+		goto out;
+
+	errno = 0;
+	env_listen_fds = strtoul(e, &p, 10);
+	if (errno || !p || *p || env_listen_fds != 2)
+		goto out;
+
+	/* Check and handle the FIFOs passed in */
+	r = (_handle_preloaded_fifo(SD_FD_FIFO_SERVER, DM_EVENT_FIFO_SERVER) &&
+	     _handle_preloaded_fifo(SD_FD_FIFO_CLIENT, DM_EVENT_FIFO_CLIENT));
+
+	if (r) {
+		fifos->server = SD_FD_FIFO_SERVER;
+		fifos->server_path = DM_EVENT_FIFO_SERVER;
+		fifos->client = SD_FD_FIFO_CLIENT;
+		fifos->client_path = DM_EVENT_FIFO_CLIENT;
+	}
+
+out:
+	unsetenv(SD_LISTEN_PID_ENV_VAR_NAME);
+	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
+	return r;
+}
+
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
@@ -1834,6 +1917,8 @@
 	if (_restart)
 		restart();
 
+	_systemd_activation = _systemd_handover(&fifos);
+
 	if (!_foreground)
 		_daemonize();
 
@@ -1852,7 +1937,8 @@
 	signal(SIGQUIT, &_exit_handler);
 
 #ifdef linux
-	if (!_protect_against_oom_killer())
+	/* Systemd has adjusted oom killer for us already */
+	if (!_systemd_activation && !_protect_against_oom_killer())
 		syslog(LOG_ERR, "Failed to protect against OOM killer");
 #endif
 
@@ -1863,11 +1949,12 @@
 	//multilog_init_verbose(std_syslog, _LOG_DEBUG);
 	//multilog_async(1);
 
-	_init_fifos(&fifos);
+	if (!_systemd_activation)
+		_init_fifos(&fifos);
 
 	pthread_mutex_init(&_global_mutex, NULL);
 
-	if (_open_fifos(&fifos))
+	if (!_systemd_activation && _open_fifos(&fifos))
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */


