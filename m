From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:30:46 -0000
Subject: LVM2 libdaemon/client/daemon-client.c libdaemo ...
Message-ID: <20120228183046.28445.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:30:41

Added files:
	libdaemon/client: daemon-client.c daemon-client.h 
	                  daemon-shared.c daemon-shared.h 
	libdaemon/server: daemon-server.c daemon-server.h 
Removed files:
	daemons/common : daemon-client.c daemon-client.h daemon-server.c 
	                 daemon-server.h daemon-shared.c daemon-shared.h 

Log message:
	move daemon files

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-shared.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-shared.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.16&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.19&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.13&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.h.diff?cvsroot=lvm2&r1=1.4&r2=NONE

/cvs/lvm2/LVM2/libdaemon/client/daemon-client.c,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/client/daemon-client.c
+++ -	2012-02-28 18:30:42.106265000 +0000
@@ -0,0 +1,102 @@
+#include "daemon-client.h"
+#include "daemon-shared.h"
+#include <sys/un.h>
+#include <sys/socket.h>
+#include <string.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <assert.h>
+#include <errno.h> // ENOMEM
+
+daemon_handle daemon_open(daemon_info i) {
+	daemon_handle h = { .protocol_version = 0, .error = 0 };
+	daemon_reply r = { .cft = NULL };
+	struct sockaddr_un sockaddr;
+
+	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0)
+		goto error;
+
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	strcpy(sockaddr.sun_path, i.socket);
+	sockaddr.sun_family = AF_UNIX;
+	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
+		goto error;
+
+	r = daemon_send_simple(h, "hello", NULL);
+	if (r.error || strcmp(daemon_reply_str(r, "response", "unknown"), "OK"))
+		goto error;
+
+	h.protocol = daemon_reply_str(r, "protocol", NULL);
+	if (h.protocol)
+		h.protocol = dm_strdup(h.protocol); /* keep around */
+	h.protocol_version = daemon_reply_int(r, "version", 0);
+
+	if (i.protocol && (!h.protocol || strcmp(h.protocol, i.protocol)))
+		goto error;
+	if (i.protocol_version && h.protocol_version != i.protocol_version)
+		goto error;
+
+	daemon_reply_destroy(r);
+	return h;
+
+error:
+	h.error = errno;
+	if (h.socket_fd >= 0)
+		close(h.socket_fd);
+	if (r.cft)
+		daemon_reply_destroy(r);
+	h.socket_fd = -1;
+	return h;
+}
+
+daemon_reply daemon_send(daemon_handle h, daemon_request rq)
+{
+	daemon_reply reply = { .cft = NULL, .error = 0 };
+	assert(h.socket_fd >= 0);
+
+	if (!rq.buffer) {
+		/* TODO: build the buffer from rq.cft */
+	}
+
+	assert(rq.buffer);
+	if (!write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer)))
+		reply.error = errno;
+
+	if (read_buffer(h.socket_fd, &reply.buffer)) {
+		reply.cft = dm_config_from_string(reply.buffer);
+	} else
+		reply.error = errno;
+
+	return reply;
+}
+
+void daemon_reply_destroy(daemon_reply r) {
+	if (r.cft)
+		dm_config_destroy(r.cft);
+	dm_free(r.buffer);
+}
+
+daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
+{
+	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
+	daemon_request rq = { .cft = NULL };
+	daemon_reply repl;
+	va_list ap;
+
+	va_start(ap, id);
+	rq.buffer = format_buffer("request", id, ap);
+	va_end(ap);
+
+	if (!rq.buffer)
+		return err;
+
+	repl = daemon_send(h, rq);
+	dm_free(rq.buffer);
+
+	return repl;
+}
+
+void daemon_close(daemon_handle h)
+{
+	dm_free((char *)h.protocol);
+}
/cvs/lvm2/LVM2/libdaemon/client/daemon-client.h,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/client/daemon-client.h
+++ -	2012-02-28 18:30:42.411969000 +0000
@@ -0,0 +1,105 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "libdevmapper.h" // for dm_list, needed by config.h
+
+#ifndef _LVM_DAEMON_COMMON_CLIENT_H
+#define _LVM_DAEMON_COMMON_CLIENT_H
+
+typedef struct {
+	int socket_fd; /* the fd we use to talk to the daemon */
+	const char *protocol;
+	int protocol_version;  /* version of the protocol the daemon uses */
+	int error;
+} daemon_handle;
+
+typedef struct {
+	const char *path; /* the binary of the daemon */
+	const char *socket; /* path to the comms socket */
+	unsigned autostart:1; /* start the daemon if not running? */
+
+	/*
+	 * If the following are not NULL/0, an attempt to talk to a daemon which
+	 * uses a different protocol or version will fail.
+	 */
+	const char *protocol;
+	int protocol_version;
+} daemon_info;
+
+typedef struct {
+	char *buffer;
+	/*
+	 * The request looks like this:
+	 *    request = "id"
+	 *    arg_foo = "something"
+	 *    arg_bar = 3
+	 *    arg_wibble {
+	 *        something_special = "here"
+	 *        amount = 75
+	 *        knobs = [ "twiddle", "tweak" ]
+	 *    }
+	 */
+	struct dm_config_tree *cft;
+} daemon_request;
+
+typedef struct {
+	int error; /* 0 for success */
+	char *buffer; /* textual reply */
+	struct dm_config_tree *cft; /* parsed reply, if available */
+} daemon_reply;
+
+/*
+ * Open the communication channel to the daemon. If the daemon is not running,
+ * it may be autostarted based on the binary path provided in the info (this
+ * will only happen if autostart is set to true). If the call fails for any
+ * reason, daemon_handle_valid(h) for the response will return false. Otherwise,
+ * the connection is good to start serving requests.
+ */
+daemon_handle daemon_open(daemon_info i);
+
+/*
+ * Send a request to the daemon, waiting for the reply. All communication with
+ * the daemon is synchronous. The function handles the IO details and parses the
+ * response, handling common error conditions. See "daemon_reply" for details.
+ *
+ * In case the request contains a non-NULL buffer pointer, this buffer is sent
+ * *verbatim* to the server. In this case, the cft pointer may be NULL (but will
+ * be ignored even if non-NULL). If the buffer is NULL, the cft is required to
+ * be a valid pointer, and is used to build up the request.
+ */
+daemon_reply daemon_send(daemon_handle h, daemon_request r);
+
+/*
+ * A simple interface to daemon_send. This function just takes the command id
+ * and possibly a list of parameters (of the form "name = %?", "value"). The
+ * type (string, integer) of the value is indicated by a character substituted
+ * for ? in %?: d for integer, s for string.
+ */
+daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...);
+
+void daemon_reply_destroy(daemon_reply r);
+
+static inline int daemon_reply_int(daemon_reply r, const char *path, int def) {
+	return dm_config_find_int(r.cft->root, path, def);
+}
+
+static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {
+	return dm_config_find_str(r.cft->root, path, def);
+}
+
+
+/* Shut down the communication to the daemon. Compulsory. */
+void daemon_close(daemon_handle h);
+
+#endif
/cvs/lvm2/LVM2/libdaemon/client/daemon-shared.c,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/client/daemon-shared.c
+++ -	2012-02-28 18:30:42.757282000 +0000
@@ -0,0 +1,125 @@
+#include <errno.h>
+#include <stdio.h>
+#include <malloc.h>
+#include <string.h>
+#include <unistd.h>
+#include <assert.h>
+#include "daemon-shared.h"
+
+/*
+ * Read a single message from a (socket) filedescriptor. Messages are delimited
+ * by blank lines. This call will block until all of a message is received. The
+ * memory will be allocated from heap. Upon error, all memory is freed and the
+ * buffer pointer is set to NULL.
+ *
+ * See also write_buffer about blocking (read_buffer has identical behaviour).
+ */
+int read_buffer(int fd, char **buffer) {
+	int bytes = 0;
+	int buffersize = 32;
+	char *new;
+	*buffer = malloc(buffersize + 1);
+
+	while (1) {
+		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
+		if (result > 0)
+			bytes += result;
+		if (result == 0) {
+			errno = ECONNRESET;
+			goto fail; /* we should never encounter EOF here */
+		}
+		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
+			goto fail;
+
+		if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
+			*(*buffer + bytes - 4) = 0;
+			break; /* success, we have the full message now */
+		}
+
+		if (bytes == buffersize) {
+			buffersize += 1024;
+			if (!(new = realloc(*buffer, buffersize + 1)))
+				goto fail;
+
+			*buffer = new;
+		}
+		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
+	}
+	return 1;
+fail:
+	free(*buffer);
+	*buffer = NULL;
+	return 0;
+}
+
+/*
+ * Write a buffer to a filedescriptor. Keep trying. Blocks (even on
+ * SOCK_NONBLOCK) until all of the write went through.
+ *
+ * TODO use select on EWOULDBLOCK/EAGAIN to avoid useless spinning
+ */
+int write_buffer(int fd, const char *buffer, int length) {
+	static const char terminate[] = "\n##\n";
+	int done = 0;
+	int written = 0;
+write:
+	while (1) {
+		int result = write(fd, buffer + written, length - written);
+		if (result > 0)
+			written += result;
+		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN)
+			return 0; /* too bad */
+		if (written == length) {
+			if (done)
+				return 1;
+			else
+				break; /* done */
+		}
+	}
+
+	buffer = terminate;
+	length = 4;
+	written = 0;
+	done = 1;
+	goto write;
+}
+
+char *format_buffer(const char *what, const char *id, va_list ap)
+{
+	char *buffer, *old;
+	char *next;
+	int keylen;
+
+	dm_asprintf(&buffer, "%s = \"%s\"\n", what, id);
+	if (!buffer) goto fail;
+
+	while ((next = va_arg(ap, char *))) {
+		old = buffer;
+		assert(strchr(next, '='));
+		keylen = strchr(next, '=') - next;
+		if (strstr(next, "%d")) {
+			int value = va_arg(ap, int);
+			dm_asprintf(&buffer, "%s%.*s= %d\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%s")) {
+			char *value = va_arg(ap, char *);
+			dm_asprintf(&buffer, "%s%.*s= \"%s\"\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%b")) {
+			char *block = va_arg(ap, char *);
+			if (!block)
+				continue;
+			dm_asprintf(&buffer, "%s%.*s%s", buffer, keylen, next, block);
+			dm_free(old);
+		} else {
+			dm_asprintf(&buffer, "%s%s", buffer, next);
+			dm_free(old);
+		}
+		if (!buffer) goto fail;
+	}
+
+	return buffer;
+fail:
+	dm_free(buffer);
+	return NULL;
+}
/cvs/lvm2/LVM2/libdaemon/client/daemon-shared.h,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/client/daemon-shared.h
+++ -	2012-02-28 18:30:42.923296000 +0000
@@ -0,0 +1,6 @@
+#include <stdarg.h>
+#include <libdevmapper.h>
+
+int read_buffer(int fd, char **buffer);
+int write_buffer(int fd, const char *buffer, int length);
+char *format_buffer(const char *what, const char *id, va_list ap);
/cvs/lvm2/LVM2/libdaemon/server/daemon-server.c,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/server/daemon-server.c
+++ -	2012-02-28 18:30:43.184833000 +0000
@@ -0,0 +1,522 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <dlfcn.h>
+#include <errno.h>
+#include <pthread.h>
+#include <sys/file.h>
+#include <sys/stat.h>
+#include <sys/wait.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+#include <netinet/in.h>
+#include <sys/un.h>
+#include <unistd.h>
+#include <signal.h>
+
+#include <syslog.h>
+#include "daemon-server.h"
+#include "daemon-shared.h"
+#include "libdevmapper.h"
+
+#if 0
+/* Create a device monitoring thread. */
+static int _pthread_create(pthread_t *t, void *(*fun)(void *), void *arg, int stacksize)
+{
+	pthread_attr_t attr;
+	pthread_attr_init(&attr);
+	/*
+	 * We use a smaller stack since it gets preallocated in its entirety
+	 */
+	pthread_attr_setstacksize(&attr, stacksize);
+	return pthread_create(t, &attr, fun, arg);
+}
+#endif
+
+static volatile sig_atomic_t _shutdown_requested = 0;
+static int _systemd_activation = 0;
+
+static void _exit_handler(int sig __attribute__((unused)))
+{
+	_shutdown_requested = 1;
+}
+
+#ifdef linux
+
+#include <stddef.h>
+
+/*
+ * Kernel version 2.6.36 and higher has
+ * new OOM killer adjustment interface.
+ */
+#  define OOM_ADJ_FILE_OLD "/proc/self/oom_adj"
+#  define OOM_ADJ_FILE "/proc/self/oom_score_adj"
+
+/* From linux/oom.h */
+/* Old interface */
+#  define OOM_DISABLE (-17)
+#  define OOM_ADJUST_MIN (-16)
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
+
+/*
+ * Protection against OOM killer if kernel supports it
+ */
+static int _protect_against_oom_killer(void)
+{
+	struct stat st;
+
+	if (stat(OOM_ADJ_FILE, &st) == -1) {
+		if (errno != ENOENT)
+			perror(OOM_ADJ_FILE ": stat failed");
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
+	}
+
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
+		return 0;
+
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
+
+	return 1;
+}
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
+#endif
+
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
+		perror("Can't create local socket.");
+		goto error;
+	}
+
+	/* Set Close-on-exec & non-blocking */
+	if (fcntl(fd, F_SETFD, 1))
+		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
+	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
+
+	fprintf(stderr, "[D] creating %s\n", s.socket_path);
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	strcpy(sockaddr.sun_path, s.socket_path);
+	sockaddr.sun_family = AF_UNIX;
+
+	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+		perror("can't bind local socket.");
+		goto error;
+	}
+	if (listen(fd, 1) != 0) {
+		perror("listen local");
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
+		if (close(fd))
+			perror("close failed");
+		if (unlink(s.socket_path))
+			perror("unlink failed");
+		fd = -1;
+	}
+	goto out;
+}
+
+static void remove_lockfile(const char *file)
+{
+	if (unlink(file))
+		perror("unlink failed");
+}
+
+static void _daemonise(void)
+{
+	int child_status;
+	int fd;
+	pid_t pid;
+	struct rlimit rlim;
+	struct timeval tval;
+	sigset_t my_sigset;
+
+	sigemptyset(&my_sigset);
+	if (sigprocmask(SIG_SETMASK, &my_sigset, NULL) < 0) {
+		fprintf(stderr, "Unable to restore signals.\n");
+		exit(EXIT_FAILURE);
+	}
+	signal(SIGTERM, &_exit_handler);
+
+	switch (pid = fork()) {
+	case -1:
+		perror("fork failed:");
+		exit(EXIT_FAILURE);
+
+	case 0:		/* Child */
+		break;
+
+	default:
+		/* Wait for response from child */
+		while (!waitpid(pid, &child_status, WNOHANG) && !_shutdown_requested) {
+			tval.tv_sec = 0;
+			tval.tv_usec = 250000;	/* .25 sec */
+			select(0, NULL, NULL, NULL, &tval);
+		}
+
+		if (_shutdown_requested) /* Child has signaled it is ok - we can exit now */
+			exit(0);
+
+		/* Problem with child.  Determine what it is by exit code */
+		fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
+		exit(WEXITSTATUS(child_status));
+	}
+
+	if (chdir("/"))
+		exit(1);
+
+	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0)
+		fd = 256; /* just have to guess */
+	else
+		fd = rlim.rlim_cur;
+
+	for (--fd; fd >= 0; fd--) {
+#ifdef linux
+		/* Do not close fds preloaded by systemd! */
+		if (_systemd_activation && fd == SD_FD_SOCKET_SERVER)
+			continue;
+#endif
+		close(fd);
+	}
+
+	if ((open("/dev/null", O_RDONLY) < 0) ||
+	    (open("/dev/null", O_WRONLY) < 0) ||
+	    (open("/dev/null", O_WRONLY) < 0))
+		exit(1);
+
+	setsid();
+}
+
+response daemon_reply_simple(const char *id, ...)
+{
+	va_list ap;
+	response res = { .cft = NULL };
+
+	va_start(ap, id);
+
+	if (!(res.buffer = format_buffer("response", id, ap)))
+		res.error = ENOMEM;
+
+	va_end(ap);
+
+	return res;
+}
+
+struct thread_baton {
+	daemon_state s;
+	client_handle client;
+};
+
+static int buffer_rewrite(char **buf, const char *format, const char *string) {
+	char *old = *buf;
+	int r = dm_asprintf(buf, format, *buf, string);
+
+	dm_free(old);
+
+	return (r < 0) ? 0 : 1;
+}
+
+static int buffer_line(const char *line, void *baton) {
+	response *r = baton;
+
+	if (r->buffer) {
+		if (!buffer_rewrite(&r->buffer, "%s\n%s", line))
+			return 0;
+	} else if (dm_asprintf(&r->buffer, "%s\n", line) < 0)
+		return 0;
+
+	return 1;
+}
+
+static response builtin_handler(daemon_state s, client_handle h, request r)
+{
+	const char *rq = daemon_request_str(r, "request", "NONE");
+
+	if (!strcmp(rq, "hello")) {
+		return daemon_reply_simple("OK", "protocol = %s", s.protocol ?: "default",
+					   "version = %d", s.protocol_version, NULL);
+	}
+
+	response res = { .buffer = NULL, .error = EPROTO };
+	return res;
+}
+
+static void *client_thread(void *baton)
+{
+	struct thread_baton *b = baton;
+	request req;
+	response res;
+
+	while (1) {
+		if (!read_buffer(b->client.socket_fd, &req.buffer))
+			goto fail;
+
+		req.cft = dm_config_from_string(req.buffer);
+		if (!req.cft)
+			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
+
+		res = builtin_handler(b->s, b->client, req);
+
+		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
+			res = b->s.handler(b->s, b->client, req);
+
+		if (!res.buffer) {
+			dm_config_write_node(res.cft->root, buffer_line, &res);
+			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL))
+				goto fail;
+			dm_config_destroy(res.cft);
+		}
+
+		if (req.cft)
+			dm_config_destroy(req.cft);
+		dm_free(req.buffer);
+
+		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
+
+		free(res.buffer);
+	}
+fail:
+	/* TODO what should we really do here? */
+	close(b->client.socket_fd);
+	free(baton);
+	return NULL;
+}
+
+static int handle_connect(daemon_state s)
+{
+	struct thread_baton *baton;
+	struct sockaddr_un sockaddr;
+	client_handle client = { .thread_id = 0 };
+	socklen_t sl = sizeof(sockaddr);
+
+	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
+	if (client.socket_fd < 0)
+		return 0;
+
+	if (!(baton = malloc(sizeof(struct thread_baton))))
+		return 0;
+
+	baton->s = s;
+	baton->client = client;
+
+	if (pthread_create(&baton->client.thread_id, NULL, client_thread, baton))
+		return 0;
+
+	pthread_detach(baton->client.thread_id);
+
+	return 1;
+}
+
+void daemon_start(daemon_state s)
+{
+	int failed = 0;
+	/*
+	 * Switch to C locale to avoid reading large locale-archive file used by
+	 * some glibc (on some distributions it takes over 100MB). Some daemons
+	 * need to use mlockall().
+	 */
+	if (setenv("LANG", "C", 1))
+		perror("Cannot set LANG to C");
+
+#ifdef linux
+	_systemd_activation = _systemd_handover(&s);
+#endif
+
+	if (!s.foreground)
+		_daemonise();
+
+	/* TODO logging interface should be somewhat more elaborate */
+	openlog(s.name, LOG_PID, LOG_DAEMON);
+
+	(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
+
+	/*
+	 * NB. Take care to not keep stale locks around. Best not exit(...)
+	 * after this point.
+	 */
+	if (dm_create_lockfile(s.pidfile) == 0)
+		exit(1);
+
+	(void) dm_prepare_selinux_context(NULL, 0);
+
+	/* Set normal exit signals to request shutdown instead of dying. */
+	signal(SIGINT, &_exit_handler);
+	signal(SIGHUP, &_exit_handler);
+	signal(SIGQUIT, &_exit_handler);
+	signal(SIGTERM, &_exit_handler);
+	signal(SIGALRM, &_exit_handler);
+	signal(SIGPIPE, SIG_IGN);
+
+#ifdef linux
+	/* Systemd has adjusted oom killer for us already */
+	if (s.avoid_oom && !_systemd_activation && !_protect_against_oom_killer())
+		syslog(LOG_ERR, "Failed to protect against OOM killer");
+#endif
+
+	if (!_systemd_activation && s.socket_path) {
+		s.socket_fd = _open_socket(s);
+		if (s.socket_fd < 0)
+			failed = 1;
+	}
+
+	/* Signal parent, letting them know we are ready to go. */
+	if (!s.foreground)
+		kill(getppid(), SIGTERM);
+
+	if (s.daemon_init)
+		s.daemon_init(&s);
+
+	while (!_shutdown_requested && !failed) {
+		fd_set in;
+		FD_ZERO(&in);
+		FD_SET(s.socket_fd, &in);
+		if (select(FD_SETSIZE, &in, NULL, NULL, NULL) < 0 && errno != EINTR)
+			perror("select error");
+		if (FD_ISSET(s.socket_fd, &in))
+			if (!handle_connect(s))
+				syslog(LOG_ERR, "Failed to handle a client connection.");
+	}
+
+	if (s.socket_fd >= 0)
+		if (unlink(s.socket_path))
+			perror("unlink error");
+
+	if (s.daemon_fini)
+		s.daemon_fini(&s);
+
+	syslog(LOG_NOTICE, "%s shutting down", s.name);
+	closelog();
+	remove_lockfile(s.pidfile);
+	if (failed)
+		exit(1);
+}
/cvs/lvm2/LVM2/libdaemon/server/daemon-server.h,v  -->  standard output
revision 1.1
--- LVM2/libdaemon/server/daemon-server.h
+++ -	2012-02-28 18:30:43.499961000 +0000
@@ -0,0 +1,122 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "daemon-client.h"
+
+#ifndef _LVM_DAEMON_COMMON_SERVER_H
+#define _LVM_DAEMON_COMMON_SERVER_H
+
+typedef struct {
+	int socket_fd; /* the fd we use to talk to the client */
+	pthread_t thread_id;
+	char *read_buf;
+	void *private; /* this holds per-client state */
+} client_handle;
+
+typedef struct {
+	struct dm_config_tree *cft;
+	char *buffer;
+} request;
+
+typedef struct {
+	int error;
+	struct dm_config_tree *cft;
+	char *buffer;
+} response;
+
+struct daemon_state;
+
+/*
+ * Craft a simple reply, without the need to construct a config_tree. See
+ * daemon_send_simple in daemon-client.h for the description of the parameters.
+ */
+response daemon_reply_simple(const char *id, ...);
+
+static inline int daemon_request_int(request r, const char *path, int def) {
+	if (!r.cft)
+		return def;
+	return dm_config_find_int(r.cft->root, path, def);
+}
+
+static inline const char *daemon_request_str(request r, const char *path, const char *def) {
+	if (!r.cft)
+		return def;
+	return dm_config_find_str(r.cft->root, path, def);
+}
+
+/*
+ * The callback. Called once per request issued, in the respective client's
+ * thread. It is presented by a parsed request (in the form of a config tree).
+ * The output is a new config tree that is serialised and sent back to the
+ * client. The client blocks until the request processing is done and reply is
+ * sent.
+ */
+typedef response (*handle_request)(struct daemon_state s, client_handle h, request r);
+
+typedef struct daemon_state {
+	/*
+	 * The maximal stack size for individual daemon threads. This is
+	 * essential for daemons that need to be locked into memory, since
+	 * pthread's default is 10M per thread.
+	 */
+	int thread_stack_size;
+
+	/* Flags & attributes affecting the behaviour of the daemon. */
+	unsigned avoid_oom:1;
+	unsigned foreground:1;
+	const char *name;
+	const char *pidfile;
+	const char *socket_path;
+	const char *protocol;
+	int protocol_version;
+
+	int log_level;
+	handle_request handler;
+	int (*daemon_init)(struct daemon_state *st);
+	int (*daemon_fini)(struct daemon_state *st);
+
+	/* Global runtime info maintained by the framework. */
+	int socket_fd;
+
+	void *private; /* the global daemon state */
+} daemon_state;
+
+/*
+ * Start serving the requests. This does all the daemonisation, socket setup
+ * work and so on. This function takes over the process, and upon failure, it
+ * will terminate execution. It may be called at most once.
+ */
+void daemon_start(daemon_state s);
+
+/*
+ * Take over from an already running daemon. This function handles connecting
+ * to the running daemon and telling it we are going to take over. The takeover
+ * request may be customised by passing in a non-NULL request.
+ *
+ * The takeover sequence: the old daemon stops accepting new clients, then it
+ * waits until all current client connections are closed. When that happens, it
+ * serializes its current state and sends that as a reply, which is then
+ * returned by this function (therefore, this function won't return until the
+ * previous instance has shut down).
+ *
+ * The daemon, after calling daemon_takeover is expected to set up its
+ * daemon_state using the reply from this function and call daemon_start as
+ * usual.
+ */
+daemon_reply daemon_takeover(daemon_info i, daemon_request r);
+
+/* Call this to request a clean shutdown of the daemon. Async safe. */
+void daemon_stop(void);
+
+#endif


