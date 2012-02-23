From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 23:52:13 -0000
Subject: LVM2/daemons common/daemon-client.c common/dae ...
Message-ID: <20120223235213.28670.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 23:52:12

Modified files:
	daemons/common : daemon-client.c daemon-client.h daemon-server.c 
	                 daemon-server.h 
	daemons/lvmetad: lvmetad-client.h lvmetad-core.c 

Log message:
	Couple of improvements in the daemon (common + lvmetad) code:
	- some client-side memory leak fixes
	- announce and check protocols and protocol versions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/daemons/common/daemon-client.c	2012/02/15 09:14:54	1.12
+++ LVM2/daemons/common/daemon-client.c	2012/02/23 23:52:11	1.13
@@ -9,7 +9,7 @@
 #include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i) {
-	daemon_handle h = { .protocol = 0 };
+	daemon_handle h = { .protocol_version = 0 };
 	struct sockaddr_un sockaddr;
 
 	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
@@ -24,10 +24,28 @@
 		perror("connect");
 		goto error;
 	}
+
+	daemon_reply r = daemon_send_simple(h, "hello", NULL);
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
 	return h;
 error:
 	if (h.socket_fd >= 0)
 		close(h.socket_fd);
+	if (r.cft)
+		daemon_reply_destroy(r);
 	h.socket_fd = -1;
 	return h;
 }
@@ -43,6 +61,7 @@
 
 	assert(rq.buffer);
 	write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer));
+	dm_free(rq.buffer);
 
 	if (read_buffer(h.socket_fd, &reply.buffer)) {
 		reply.cft = dm_config_from_string(reply.buffer);
@@ -55,6 +74,7 @@
 void daemon_reply_destroy(daemon_reply r) {
 	if (r.cft)
 		dm_config_destroy(r.cft);
+	dm_free(r.buffer);
 }
 
 daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
@@ -72,10 +92,10 @@
 		return err;
 
 	repl = daemon_send(h, rq);
-	dm_free(rq.buffer);
 	return repl;
 }
 
 void daemon_close(daemon_handle h)
 {
+	dm_free((char *)h.protocol);
 }
--- LVM2/daemons/common/daemon-client.h	2012/01/15 15:16:50	1.9
+++ LVM2/daemons/common/daemon-client.h	2012/02/23 23:52:11	1.10
@@ -19,13 +19,21 @@
 
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the daemon */
-	int protocol;  /* version of the protocol the daemon uses */
+	const char *protocol;
+	int protocol_version;  /* version of the protocol the daemon uses */
 } daemon_handle;
 
 typedef struct {
 	const char *path; /* the binary of the daemon */
 	const char *socket; /* path to the comms socket */
 	unsigned autostart:1; /* start the daemon if not running? */
+
+	/*
+	 * If the following are not NULL/0, an attempt to talk to a daemon which
+	 * uses a different protocol or version will fail.
+	 */
+	const char *protocol;
+	int protocol_version;
 } daemon_info;
 
 typedef struct {
--- LVM2/daemons/common/daemon-server.c	2012/01/25 21:30:27	1.16
+++ LVM2/daemons/common/daemon-server.c	2012/02/23 23:52:11	1.17
@@ -239,6 +239,19 @@
 	return 0;
 }
 
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
 static void *client_thread(void *baton)
 {
 	struct thread_baton *b = baton;
@@ -252,7 +265,11 @@
 		req.cft = dm_config_from_string(req.buffer);
 		if (!req.cft)
 			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
-		res = b->s.handler(b->s, b->client, req);
+
+		res = builtin_handler(b->s, b->client, req);
+
+		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
+			res = b->s.handler(b->s, b->client, req);
 
 		if (!res.buffer) {
 			dm_config_write_node(res.cft->root, buffer_line, &res);
--- LVM2/daemons/common/daemon-server.h	2011/09/01 13:25:50	1.12
+++ LVM2/daemons/common/daemon-server.h	2012/02/23 23:52:11	1.13
@@ -78,6 +78,9 @@
 	const char *name;
 	const char *pidfile;
 	const char *socket_path;
+	const char *protocol;
+	int protocol_version;
+
 	int log_level;
 	handle_request handler;
 	int (*daemon_init)(struct daemon_state *st);
--- LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 17:59:32	1.8
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 23:52:11	1.9
@@ -64,6 +64,8 @@
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
 		.socket = socket ?: DEFAULT_RUN_DIR "/lvmetad.socket",
+		.protocol = "lvmetad",
+		.protocol_version = 1,
 		.autostart = 0
 	};
 
--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/23 17:59:32	1.39
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/23 23:52:11	1.40
@@ -984,6 +984,8 @@
 		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
 	s.pidfile = DEFAULT_RUN_DIR "/lvmetad.pid";
         s.log_level = 0;
+	s.protocol = "lvmetad";
+	s.protocol_version = 1;
 
 	// use getopt_long
 	while ((opt = getopt(argc, argv, "?fhVdRs:")) != EOF) {


