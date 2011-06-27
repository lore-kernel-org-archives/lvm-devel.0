From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 13:46:47 -0000
Subject: LVM2/daemons common/daemon-client.c common/dae ...
Message-ID: <20110627134647.21121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 13:46:45

Modified files:
	daemons/common : daemon-client.c daemon-server.c daemon-server.h 
	daemons/lvmetad: lvmetad-core.c testclient.c 

Log message:
	Parse the incoming config tree in daemon-server.c, providing the
	daemon-specific handler with a struct config_tree pointer to look things up in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/common/daemon-client.c	2011/06/27 13:14:53	1.2
+++ LVM2/daemons/common/daemon-client.c	2011/06/27 13:46:45	1.3
@@ -15,7 +15,7 @@
 		goto error;
 	}
 	memset(&sockaddr, 0, sizeof(sockaddr));
-	fprintf(stderr, "connecting to %s\n", i.socket);
+	fprintf(stderr, "[C] connecting to %s\n", i.socket);
 	strcpy(sockaddr.sun_path, i.socket);
 	sockaddr.sun_family = AF_UNIX;
 	if (connect(h.socket_fd,(struct sockaddr *) &sockaddr, sizeof(sockaddr))) {
--- LVM2/daemons/common/daemon-server.c	2011/06/14 02:34:18	1.4
+++ LVM2/daemons/common/daemon-server.c	2011/06/27 13:46:45	1.5
@@ -107,7 +107,7 @@
 		fprintf(stderr, "setting CLOEXEC on socket fd %d failed: %s\n", fd, strerror(errno));
 	fcntl(fd, F_SETFL, fcntl(fd, F_GETFL, 0) | O_NONBLOCK);
 
-	fprintf(stderr, "creating %s\n", s.socket_path);
+	fprintf(stderr, "[D] creating %s\n", s.socket_path);
 	memset(&sockaddr, 0, sizeof(sockaddr));
 	strcpy(sockaddr.sun_path, s.socket_path);
 	sockaddr.sun_family = AF_UNIX;
@@ -213,8 +213,10 @@
 		if (!read_buffer(b->client.socket_fd, &req.buffer))
 			goto fail;
 
-		/* TODO parse the buffer into req.cft */
+		req.cft = create_config_tree_from_string(req.buffer);
 		response res = b->s.handler(b->s, b->client, req);
+		destroy_config_tree(req.cft);
+		dm_free(req.buffer);
 
 		if (!res.buffer) {
 			/* TODO fill in the buffer from res.cft */
@@ -223,7 +225,6 @@
 		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
 
 		free(res.buffer);
-		free(req.buffer);
 	}
 fail:
 	/* TODO what should we really do here? */
--- LVM2/daemons/common/daemon-server.h	2011/06/14 02:34:18	1.5
+++ LVM2/daemons/common/daemon-server.h	2011/06/27 13:46:45	1.6
@@ -26,13 +26,13 @@
 } client_handle;
 
 typedef struct {
-	struct config_node *cft;
+	struct config_tree *cft;
 	char *buffer;
 } request;
 
 typedef struct {
 	int error;
-	struct config_node *cft;
+	struct config_tree *cft;
 	char *buffer;
 } response;
 
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:15:49	1.2
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:46:45	1.3
@@ -7,7 +7,7 @@
 static response handler(daemon_state s, client_handle h, request r)
 {
 	response res;
-	fprintf(stderr, "---- server obtained:\n%s\n----------------------\n", r.buffer);
+	fprintf(stderr, "[D] REQUEST: %s\n", find_config_str(r.cft->root, "request", "NONE"));
 	res.error = 1;
 	res.buffer = strdup("hey hey.\n\n");
 	return res;
--- LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:15:49	1.3
+++ LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:46:45	1.4
@@ -5,7 +5,7 @@
 	int i;
 	for (i = 0; i < 5; ++i ) {
 		daemon_reply reply = daemon_send_simple(h, "hello world", "param = %d", 3, NULL);
-		fprintf(stderr, "daemon says: %s\n", reply.buffer);
+		fprintf(stderr, "[C] obtained: %s\n", reply.buffer);
 	}
 	daemon_close(h);
 	return 0;


