From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 May 2011 09:34:13 -0000
Subject: LVM2/daemons/common daemon-server.c daemon-ser ...
Message-ID: <20110513093413.32414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-13 09:34:12

Modified files:
	daemons/common : daemon-server.c daemon-server.h 

Log message:
	More scavenging of common daemon code, this time the clvmd local socket setup
	sequence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/daemons/common/daemon-server.c	2011/05/13 08:45:46	1.1
+++ LVM2/daemons/common/daemon-server.c	2011/05/13 09:34:12	1.2
@@ -79,6 +79,53 @@
 }
 #endif
 
+static int _open_socket(daemon_state s)
+{
+	int fd = -1;
+	struct sockaddr_un sockaddr;
+	mode_t old_mask;
+
+	(void) dm_prepare_selinux_context(s.socket_path, S_IFSOCK);
+	old_mask = umask(0077);
+
+	/* Open local socket */
+	fd = socket(PF_UNIX, SOCK_STREAM, 0);
+	if (fd < 0) {
+		log_error("Can't create local socket: %m");
+		goto error;
+	}
+
+	/* Set Close-on-exec & non-blocking */
+	if (fcntl(fd, F_SETFD, 1))
+		DEBUGLOG("setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
+	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
+
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	memcpy(sockaddr.sun_path, s.socket_path, strlen(s.socket_path));
+	sockaddr.sun_family = AF_UNIX;
+
+	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+		log_error("can't bind local socket: %m");
+		goto error;
+	}
+	if (listen(fd, 1) != 0) {
+		log_error("listen local: %m");
+		goto error;
+	}
+
+out:
+	umask(old_mask);
+	(void) dm_prepare_selinux_context(NULL, 0);
+	return fd;
+
+error:
+	if (fd >= 0) {
+		close(fd);
+		fd = -1;
+	}
+	goto out;
+}
+
 static void remove_lockfile(const char *file)
 {
 	if (unlink(file))
@@ -155,6 +202,7 @@
 
 void daemon_start(daemon_state s, handle_request r)
 {
+	int failed = 0;
 	/*
 	 * Switch to C locale to avoid reading large locale-archive file used by
 	 * some glibc (on some distributions it takes over 100MB). Some daemons
@@ -172,8 +220,8 @@
 	(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
 
 	/*
-	 * NB. Past this point, exit is not allowed. You have to return to this
-	 * function at all costs. More or less.
+	 * NB. Take care to not keep stale locks around. Best not exit(...)
+	 * after this point.
 	 */
 	if (dm_create_lockfile(s.pidfile) == 0)
 		exit(1);
@@ -190,15 +238,23 @@
 		syslog(LOG_ERR, "Failed to set oom_adj to protect against OOM killer");
 #endif
 
+	if (s.socket_path) {
+		s.socket_fd = _open_socket(s);
+		if (s.socket_fd < 0)
+			failed = 1;
+	}
+
 	/* Signal parent, letting them know we are ready to go. */
 	if (!s.foreground)
 		kill(getppid(), SIGTERM);
 
-	while (!_shutdown_requested) {
+	while (!_shutdown_requested && !failed) {
 		/* TODO: do work */
 	}
 
 	syslog(LOG_NOTICE, "%s shutting down", s.name);
 	closelog();
 	remove_lockfile(s.pidfile);
+	if (failed)
+		exit(1);
 }
--- LVM2/daemons/common/daemon-server.h	2011/05/13 08:45:46	1.2
+++ LVM2/daemons/common/daemon-server.h	2011/05/13 09:34:12	1.3
@@ -35,6 +35,10 @@
 	unsigned foreground:1;
 	const char *name;
 	const char *pidfile;
+	const char *socket_path;
+
+	/* Global runtime info maintained by the framework. */
+	int socket_fd;
 
 	void *private; /* the global daemon state */
 } daemon_state;


