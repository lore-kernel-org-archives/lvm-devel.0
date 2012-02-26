From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Feb 2012 08:46:29 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-cli ...
Message-ID: <20120226084629.12304.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-26 08:46:28

Modified files:
	daemons/common : daemon-client.c daemon-client.h daemon-shared.c 

Log message:
	Improve error handling & reporting in common daemon code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/daemons/common/daemon-client.c	2012/02/24 00:02:54	1.14
+++ LVM2/daemons/common/daemon-client.c	2012/02/26 08:46:28	1.15
@@ -9,22 +9,18 @@
 #include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i) {
-	daemon_handle h = { .protocol_version = 0 };
+	daemon_handle h = { .protocol_version = 0, .error = 0 };
 	daemon_reply r = { .cft = NULL };
 	struct sockaddr_un sockaddr;
 
-	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
-		perror("socket");
+	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0)
 		goto error;
-	}
+
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	fprintf(stderr, "[C] connecting to %s\n", i.socket);
 	strcpy(sockaddr.sun_path, i.socket);
 	sockaddr.sun_family = AF_UNIX;
-	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
-		perror("connect");
+	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr)))
 		goto error;
-	}
 
 	r = daemon_send_simple(h, "hello", NULL);
 	if (r.error || strcmp(daemon_reply_str(r, "response", "unknown"), "OK"))
@@ -42,7 +38,9 @@
 
 	daemon_reply_destroy(r);
 	return h;
+
 error:
+	h.error = errno;
 	if (h.socket_fd >= 0)
 		close(h.socket_fd);
 	if (r.cft)
@@ -61,13 +59,15 @@
 	}
 
 	assert(rq.buffer);
-	write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer));
+	if (!write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer)))
+		reply.error = errno;
+
 	dm_free(rq.buffer);
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
 		reply.cft = dm_config_from_string(reply.buffer);
 	} else
-		reply.error = 1;
+		reply.error = errno;
 
 	return reply;
 }
--- LVM2/daemons/common/daemon-client.h	2012/02/23 23:52:11	1.10
+++ LVM2/daemons/common/daemon-client.h	2012/02/26 08:46:28	1.11
@@ -21,6 +21,7 @@
 	int socket_fd; /* the fd we use to talk to the daemon */
 	const char *protocol;
 	int protocol_version;  /* version of the protocol the daemon uses */
+	int error;
 } daemon_handle;
 
 typedef struct {
--- LVM2/daemons/common/daemon-shared.c	2012/01/25 13:06:57	1.10
+++ LVM2/daemons/common/daemon-shared.c	2012/02/26 08:46:28	1.11
@@ -24,12 +24,14 @@
 		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
 		if (result > 0)
 			bytes += result;
-		if (result == 0)
+		if (result == 0) {
+			errno = ECONNRESET;
 			goto fail; /* we should never encounter EOF here */
+		}
 		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK)
 			goto fail;
 
-		if ((!strncmp((*buffer) + bytes - 4, "\n##\n", 4))) {
+		if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
 			*(*buffer + bytes - 4) = 0;
 			break; /* success, we have the full message now */
 		}


