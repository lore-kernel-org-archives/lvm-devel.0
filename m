From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Jun 2011 02:34:19 -0000
Subject: LVM2/daemons/common daemon-client.h daemon-ser ...
Message-ID: <20110614023419.2122.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-14 02:34:18

Modified files:
	daemons/common : daemon-client.h daemon-server.c daemon-server.h 
Added files:
	daemons/common : daemon-client.c daemon-shared.c daemon-shared.h 

Log message:
	Common daemon code: Implement basic socket-based communication infrastructure
	(both client and server side). The server handles each connection in a separate
	thread.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

/cvs/lvm2/LVM2/daemons/common/daemon-client.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-client.c
+++ -	2011-06-14 02:34:19.031404000 +0000
@@ -0,0 +1,54 @@
+#include "daemon-client.h"
+#include "daemon-shared.h"
+#include <sys/un.h>
+#include <sys/socket.h>
+#include <string.h>
+#include <stdio.h>
+#include <assert.h>
+
+daemon_handle daemon_open(daemon_info i) {
+	daemon_handle h;
+	struct sockaddr_un sockaddr;
+	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0)) < 0) {
+		perror("socket");
+		goto error;
+	}
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	fprintf(stderr, "connecting to %s\n", i.socket);
+	strcpy(sockaddr.sun_path, i.socket);
+	sockaddr.sun_family = AF_UNIX;
+	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
+		perror("connect");
+		goto error;
+	}
+	h.protocol = 0;
+	return h;
+error:
+	if (h.socket_fd >= 0)
+		close(h.socket_fd);
+	h.socket_fd = -1;
+	return h;
+}
+
+daemon_reply daemon_send(daemon_handle h, daemon_request rq)
+{
+	daemon_reply reply;
+	assert(h.socket_fd >= 0);
+
+	if (!rq.buffer) {
+		/* TODO: build the buffer from rq.cft */
+	}
+
+	assert(rq.buffer);
+	write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer));
+
+	if (read_buffer(h.socket_fd, &reply.buffer)) {
+		/* TODO: parse reply.buffer into reply.cft */
+	} else
+		reply.error = 1;
+
+	return reply;
+}
+
+void daemon_close(daemon_handle h) {
+}
/cvs/lvm2/LVM2/daemons/common/daemon-shared.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-shared.c
+++ -	2011-06-14 02:34:19.142467000 +0000
@@ -0,0 +1,68 @@
+#include <errno.h>
+#include <stdio.h>
+#include <malloc.h>
+#include <string.h>
+
+/*
+ * Read a single message from a (socket) filedescriptor. Messages are delimited
+ * by blank lines. This call will block until all of a message is received. The
+ * memory will be allocated from heap. Upon error, all memory is freed and the
+ * buffer pointer is set to NULL.
+ */
+int read_buffer(int fd, char **buffer) {
+	int bytes = 0;
+	int buffersize = 32;
+	*buffer = malloc(buffersize + 1);
+
+	while (1) {
+		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
+		if (result > 0)
+			bytes += result;
+		if (result == 0)
+			goto fail; /* we should never encounter EOF here */
+		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
+			goto fail;
+
+		if (bytes == buffersize) {
+			buffersize += 1024;
+			char *new = realloc(*buffer, buffersize + 1);
+			if (new)
+				*buffer = new;
+			else
+				goto fail;
+		} else {
+			(*buffer)[bytes] = 0;
+			char *end;
+			if ((end = strstr((*buffer) + bytes - 2, "\n\n"))) {
+				*end = 0;
+				break; /* success, we have the full message now */
+			}
+			/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK */
+		}
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
+int write_buffer(int fd, char *buffer, int length) {
+	int written = 0;
+	while (1) {
+		int result = write(fd, buffer + written, length - written);
+		if (result > 0)
+			written += result;
+		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN)
+			break; /* too bad */
+		if (written == length)
+			return 1; /* done */
+	}
+	return 0;
+}
/cvs/lvm2/LVM2/daemons/common/daemon-shared.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-shared.h
+++ -	2011-06-14 02:34:19.240114000 +0000
@@ -0,0 +1,2 @@
+int read_buffer(int fd, char **buffer);
+int write_buffer(int fd, char *buffer, int length);
--- LVM2/daemons/common/daemon-client.h	2011/05/15 11:02:29	1.2
+++ LVM2/daemons/common/daemon-client.h	2011/06/14 02:34:18	1.3
@@ -12,6 +12,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "config.h" // should become part of libdevmapper later
+
 #ifndef _LVM_DAEMON_COMMON_CLIENT_H
 #define _LVM_DAEMON_COMMON_CLIENT_H
 
@@ -28,13 +30,14 @@
 } daemon_info;
 
 typedef struct {
-	char *request;
+	char *buffer;
+	struct config_node *cft;
 } daemon_request;
 
 typedef struct {
 	int error; /* 0 for success */
-	char *reply; /* textual reply */
-	struct config_tree *cft; /* parsed reply, if available */
+	char *buffer; /* textual reply */
+	struct config_node *cft; /* parsed reply, if available */
 } daemon_reply;
 
 /*
--- LVM2/daemons/common/daemon-server.c	2011/05/15 11:02:29	1.3
+++ LVM2/daemons/common/daemon-server.c	2011/06/14 02:34:18	1.4
@@ -107,8 +107,9 @@
 		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
 	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
 
+	fprintf(stderr, "creating %s\n", s.socket_path);
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	memcpy(sockaddr.sun_path, s.socket_path, strlen(s.socket_path));
+	strcpy(sockaddr.sun_path, s.socket_path);
 	sockaddr.sun_family = AF_UNIX;
 
 	if (bind(fd, (struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
@@ -128,6 +129,7 @@
 error:
 	if (fd >= 0) {
 		close(fd);
+		unlink(s.socket_path);
 		fd = -1;
 	}
 	goto out;
@@ -198,6 +200,60 @@
 	setsid();
 }
 
+struct thread_baton {
+	daemon_state s;
+	client_handle client;
+};
+
+void *client_thread(void *baton)
+{
+	struct thread_baton *b = baton;
+	request req;
+	while (1) {
+		if (!read_buffer(b->client.socket_fd, &req.buffer))
+			goto fail;
+
+		/* TODO parse the buffer into req.cft */
+		response res = b->s.handler(b->s, b->client, req);
+
+		if (!res.buffer) {
+			/* TODO fill in the buffer from res.cft */
+		}
+
+		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
+
+		free(res.buffer);
+		free(req.buffer);
+	}
+fail:
+	/* TODO what should we really do here? */
+	return NULL;
+}
+
+int handle_connect(daemon_state s)
+{
+	struct sockaddr_un sockaddr;
+	client_handle client;
+	socklen_t sl = sizeof(sockaddr);
+	int client_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
+	if (client_fd < 0)
+		return 0;
+
+	struct thread_baton *baton = malloc(sizeof(struct thread_baton));
+	if (!baton)
+		return 0;
+
+	client.socket_fd = client_fd;
+	client.read_buf = 0;
+	client.private = 0;
+	baton->s = s;
+	baton->client = client;
+
+	if (pthread_create(&baton->client.thread_id, NULL, client_thread, baton))
+		return 0;
+	return 1;
+}
+
 void daemon_start(daemon_state s)
 {
 	int failed = 0;
@@ -230,6 +286,8 @@
 	signal(SIGINT, &_exit_handler);
 	signal(SIGHUP, &_exit_handler);
 	signal(SIGQUIT, &_exit_handler);
+	signal(SIGTERM, &_exit_handler);
+	signal(SIGPIPE, SIG_IGN);
 
 #ifdef linux
 	if (s.avoid_oom && !_set_oom_adj(OOM_DISABLE) && !_set_oom_adj(OOM_ADJUST_MIN))
@@ -247,9 +305,20 @@
 		kill(getppid(), SIGTERM);
 
 	while (!_shutdown_requested && !failed) {
-		/* TODO: do work */
+		int status;
+		fd_set in;
+		FD_ZERO(&in);
+		FD_SET(s.socket_fd, &in);
+		if (select(FD_SETSIZE, &in, NULL, NULL, NULL) < 0 && errno != EINTR)
+			perror("select error");
+		if (FD_ISSET(s.socket_fd, &in))
+			if (!handle_connect(s))
+				syslog(LOG_ERR, "Failed to handle a client connection.");
 	}
 
+	if (s.socket_fd >= 0)
+		unlink(s.socket_path);
+
 	syslog(LOG_NOTICE, "%s shutting down", s.name);
 	closelog();
 	remove_lockfile(s.pidfile);
--- LVM2/daemons/common/daemon-server.h	2011/05/15 11:02:29	1.4
+++ LVM2/daemons/common/daemon-server.h	2011/06/14 02:34:18	1.5
@@ -13,6 +13,7 @@
  */
 
 #include "daemon-client.h"
+#include "config.h" // XXX will be in libdevmapper.h later
 
 #ifndef _LVM_DAEMON_COMMON_SERVER_H
 #define _LVM_DAEMON_COMMON_SERVER_H
@@ -25,12 +26,14 @@
 } client_handle;
 
 typedef struct {
-	struct config_tree *cft;
+	struct config_node *cft;
+	char *buffer;
 } request;
 
 typedef struct {
 	int error;
-	struct config_tree *cft;
+	struct config_node *cft;
+	char *buffer;
 } response;
 
 struct daemon_state;


