From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Sep 2011 14:49:19 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-ser ...
Message-ID: <20110917144919.19685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-17 14:49:18

Modified files:
	daemons/common : daemon-client.c daemon-server.c daemon-shared.c 

Log message:
	More gcc warnings removed

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/common/daemon-client.c	2011/08/31 12:18:40	1.7
+++ LVM2/daemons/common/daemon-client.c	2011/09/17 14:49:18	1.8
@@ -9,8 +9,9 @@
 #include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i) {
-	daemon_handle h;
+	daemon_handle h = { .protocol = 0 };
 	struct sockaddr_un sockaddr;
+
 	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
 		perror("socket");
 		goto error;
@@ -23,7 +24,6 @@
 		perror("connect");
 		goto error;
 	}
-	h.protocol = 0;
 	return h;
 error:
 	if (h.socket_fd >= 0)
@@ -59,16 +59,19 @@
 
 daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
 {
+	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
+	daemon_request rq;
+	daemon_reply repl;
 	va_list ap;
+
 	va_start(ap, id);
-	daemon_request rq = { .buffer = format_buffer("request", id, ap) };
+	rq.buffer = format_buffer("request", id, ap);
+	va_end(ap);
 
-	if (!rq.buffer) {
-		daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
+	if (!rq.buffer)
 		return err;
-	}
 
-	daemon_reply repl = daemon_send(h, rq);
+	repl = daemon_send(h, rq);
 	dm_free(rq.buffer);
 	return repl;
 }
--- LVM2/daemons/common/daemon-server.c	2011/08/31 12:39:58	1.13
+++ LVM2/daemons/common/daemon-server.c	2011/09/17 14:49:18	1.14
@@ -204,12 +204,15 @@
 response daemon_reply_simple(const char *id, ...)
 {
 	va_list ap;
+	response res = { .cft = NULL };
+
 	va_start(ap, id);
-	response res = { .buffer = format_buffer("response", id, ap), .cft = NULL };
 
-	if (!res.buffer)
+	if (!(res.buffer = format_buffer("response", id, ap)))
 		res.error = ENOMEM;
 
+	va_end(ap);
+
 	return res;
 }
 
@@ -238,6 +241,8 @@
 {
 	struct thread_baton *b = baton;
 	request req;
+	response res;
+
 	while (1) {
 		if (!read_buffer(b->client.socket_fd, &req.buffer))
 			goto fail;
@@ -245,7 +250,7 @@
 		req.cft = dm_config_from_string(req.buffer);
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
-		response res = b->s.handler(b->s, b->client, req);
+		res = b->s.handler(b->s, b->client, req);
 		if (req.cft)
 			dm_config_destroy(req.cft);
 		dm_free(req.buffer);
@@ -268,25 +273,24 @@
 
 static int handle_connect(daemon_state s)
 {
+	struct thread_baton *baton;
 	struct sockaddr_un sockaddr;
-	client_handle client;
+	client_handle client = { .thread_id = 0 };
 	socklen_t sl = sizeof(sockaddr);
-	int client_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
-	if (client_fd < 0)
+
+	client.socket_fd = accept(s.socket_fd, (struct sockaddr *) &sockaddr, &sl);
+	if (client.socket_fd < 0)
 		return 0;
 
-	struct thread_baton *baton = malloc(sizeof(struct thread_baton));
-	if (!baton)
+	if (!(baton = malloc(sizeof(struct thread_baton))))
 		return 0;
 
-	client.socket_fd = client_fd;
-	client.read_buf = 0;
-	client.private = 0;
 	baton->s = s;
 	baton->client = client;
 
 	if (pthread_create(&baton->client.thread_id, NULL, client_thread, baton))
 		return 0;
+
 	return 1;
 }
 
--- LVM2/daemons/common/daemon-shared.c	2011/08/31 12:18:40	1.5
+++ LVM2/daemons/common/daemon-shared.c	2011/09/17 14:49:18	1.6
@@ -17,6 +17,8 @@
 int read_buffer(int fd, char **buffer) {
 	int bytes = 0;
 	int buffersize = 32;
+	char *new;
+	char *end;
 	*buffer = malloc(buffersize + 1);
 
 	while (1) {
@@ -30,14 +32,12 @@
 
 		if (bytes == buffersize) {
 			buffersize += 1024;
-			char *new = realloc(*buffer, buffersize + 1);
-			if (new)
-				*buffer = new;
-			else
+			if (!(new = realloc(*buffer, buffersize + 1)))
 				goto fail;
+
+			*buffer = new;
 		} else {
 			(*buffer)[bytes] = 0;
-			char *end;
 			if ((end = strstr((*buffer) + bytes - 2, "\n\n"))) {
 				*end = 0;
 				break; /* success, we have the full message now */


