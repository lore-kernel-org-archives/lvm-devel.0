From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 Feb 2012 11:13:52 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20120227111352.28380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-27 11:13:52

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Systemd is linux-specific - move the supporting code under the 'ifdef linux'.
	
	Some 'defines' used in this specific code were already under an ifdef so this
	patch just completes it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/daemons/dmeventd/dmeventd.c	2012/02/13 11:18:45	1.89
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/02/27 11:13:51	1.90
@@ -1657,6 +1657,76 @@
 
 	return _set_oom_adj(OOM_ADJ_FILE, OOM_SCORE_ADJ_MIN);
 }
+
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
 #endif
 
 static void remove_lockfile(void)
@@ -1723,10 +1793,12 @@
 		fd = rlim.rlim_cur;
 
 	for (--fd; fd >= 0; fd--) {
+#ifdef linux
 		/* Do not close fds preloaded by systemd! */
 		if (_systemd_activation &&
 		    (fd == SD_FD_FIFO_SERVER || fd == SD_FD_FIFO_CLIENT))
 			continue;
+#endif
 		close(fd);
 	}
 
@@ -1804,76 +1876,6 @@
 	fini_fifos(&fifos);
 }
 
-static int _handle_preloaded_fifo(int fd, const char *path)
-{
-	struct stat st_fd, st_path;
-	int flags;
-
-	if ((flags = fcntl(fd, F_GETFD)) < 0)
-		return 0;
-
-	if (flags & FD_CLOEXEC)
-		return 0;
-
-	if (fstat(fd, &st_fd) < 0 || !S_ISFIFO(st_fd.st_mode))
-		return 0;
-
-	if (stat(path, &st_path) < 0 ||
-	    st_path.st_dev != st_fd.st_dev ||
-	    st_path.st_ino != st_fd.st_ino)
-		return 0;
-
-	if (fcntl(fd, F_SETFD, flags | FD_CLOEXEC) < 0)
-		return 0;
-
-	return 1;
-}
-
-static int _systemd_handover(struct dm_event_fifos *fifos)
-{
-	const char *e;
-	char *p;
-	unsigned long env_pid, env_listen_fds;
-	int r = 0;
-
-	memset(fifos, 0, sizeof(*fifos));
-
-	/* LISTEN_PID must be equal to our PID! */
-	if (!(e = getenv(SD_LISTEN_PID_ENV_VAR_NAME)))
-		goto out;
-
-	errno = 0;
-	env_pid = strtoul(e, &p, 10);
-	if (errno || !p || *p || env_pid <= 0 ||
-	    getpid() != (pid_t) env_pid)
-		goto out;
-
-	/* LISTEN_FDS must be 2 and the fds must be FIFOSs! */
-	if (!(e = getenv(SD_LISTEN_FDS_ENV_VAR_NAME)))
-		goto out;
-
-	errno = 0;
-	env_listen_fds = strtoul(e, &p, 10);
-	if (errno || !p || *p || env_listen_fds != 2)
-		goto out;
-
-	/* Check and handle the FIFOs passed in */
-	r = (_handle_preloaded_fifo(SD_FD_FIFO_SERVER, DM_EVENT_FIFO_SERVER) &&
-	     _handle_preloaded_fifo(SD_FD_FIFO_CLIENT, DM_EVENT_FIFO_CLIENT));
-
-	if (r) {
-		fifos->server = SD_FD_FIFO_SERVER;
-		fifos->server_path = DM_EVENT_FIFO_SERVER;
-		fifos->client = SD_FD_FIFO_CLIENT;
-		fifos->client_path = DM_EVENT_FIFO_CLIENT;
-	}
-
-out:
-	unsetenv(SD_LISTEN_PID_ENV_VAR_NAME);
-	unsetenv(SD_LISTEN_FDS_ENV_VAR_NAME);
-	return r;
-}
-
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
@@ -1928,7 +1930,9 @@
 	if (_restart)
 		restart();
 
+#ifdef linux
 	_systemd_activation = _systemd_handover(&fifos);
+#endif
 
 	if (!_foreground)
 		_daemonize();


