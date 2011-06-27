From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 13:14:54 -0000
Subject: LVM2/daemons/common daemon-client.c
Message-ID: <20110627131454.10827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 13:14:53

Modified files:
	daemons/common : daemon-client.c 

Log message:
	Do not open the socket with SOCK_NONBLOCK in daemon-client, since we have no
	use for that behaviour (at least for now).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/common/daemon-client.c	2011/06/14 02:34:18	1.1
+++ LVM2/daemons/common/daemon-client.c	2011/06/27 13:14:53	1.2
@@ -5,11 +5,12 @@
 #include <string.h>
 #include <stdio.h>
 #include <assert.h>
+#include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i) {
 	daemon_handle h;
 	struct sockaddr_un sockaddr;
-	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM | SOCK_NONBLOCK, 0)) < 0) {
+	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
 		perror("socket");
 		goto error;
 	}
@@ -50,5 +51,22 @@
 	return reply;
 }
 
-void daemon_close(daemon_handle h) {
+daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
+{
+	va_list ap;
+	va_start(ap, id);
+	daemon_request rq = { .buffer = format_buffer(id, ap) };
+
+	if (!rq.buffer) {
+		daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
+		return err;
+	}
+
+	daemon_reply repl = daemon_send(h, rq);
+	dm_free(rq.buffer);
+	return repl;
+}
+
+void daemon_close(daemon_handle h)
+{
 }


