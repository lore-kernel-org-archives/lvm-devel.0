From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 12:18:41 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-ser ...
Message-ID: <20110831121841.10846.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 12:18:40

Modified files:
	daemons/common : daemon-client.c daemon-server.c daemon-shared.c 

Log message:
	Fix warnings in daemons/common.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/daemons/common/daemon-client.c	2011/08/30 15:42:56	1.6
+++ LVM2/daemons/common/daemon-client.c	2011/08/31 12:18:40	1.7
@@ -4,6 +4,7 @@
 #include <sys/socket.h>
 #include <string.h>
 #include <stdio.h>
+#include <unistd.h>
 #include <assert.h>
 #include <errno.h> // ENOMEM
 
@@ -53,7 +54,7 @@
 
 void daemon_reply_destroy(daemon_reply r) {
 	if (r.cft)
-		destroy_config_tree(r.cft);
+		dm_config_destroy(r.cft);
 }
 
 daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
--- LVM2/daemons/common/daemon-server.c	2011/08/31 11:31:58	1.11
+++ LVM2/daemons/common/daemon-server.c	2011/08/31 12:18:40	1.12
@@ -218,14 +218,14 @@
 	client_handle client;
 };
 
-int buffer_rewrite(char **buf, const char *format, const char *string) {
+static int buffer_rewrite(char **buf, const char *format, const char *string) {
 	char *old = *buf;
 	dm_asprintf(buf, format, *buf, string);
 	dm_free(old);
 	return 0;
 }
 
-int buffer_line(const char *line, void *baton) {
+static int buffer_line(const char *line, void *baton) {
 	response *r = baton;
 	if (r->buffer)
 		buffer_rewrite(&r->buffer, "%s\n%s", line);
@@ -234,7 +234,7 @@
 	return 0;
 }
 
-void *client_thread(void *baton)
+static void *client_thread(void *baton)
 {
 	struct thread_baton *b = baton;
 	request req;
@@ -266,7 +266,7 @@
 	return NULL;
 }
 
-int handle_connect(daemon_state s)
+static int handle_connect(daemon_state s)
 {
 	struct sockaddr_un sockaddr;
 	client_handle client;
@@ -345,7 +345,6 @@
 		s.daemon_init(&s);
 
 	while (!_shutdown_requested && !failed) {
-		int status;
 		fd_set in;
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
--- LVM2/daemons/common/daemon-shared.c	2011/07/18 14:42:44	1.4
+++ LVM2/daemons/common/daemon-shared.c	2011/08/31 12:18:40	1.5
@@ -2,6 +2,7 @@
 #include <stdio.h>
 #include <malloc.h>
 #include <string.h>
+#include <unistd.h>
 #include <assert.h>
 #include "daemon-shared.h"
 
@@ -80,7 +81,7 @@
 	dm_asprintf(&buffer, "%s = \"%s\"\n", what, id);
 	if (!buffer) goto fail;
 
-	while (next = va_arg(ap, char *)) {
+	while ((next = va_arg(ap, char *))) {
 		old = buffer;
 		assert(strchr(next, '='));
 		keylen = strchr(next, '=') - next;


