From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jun 2011 13:15:50 -0000
Subject: LVM2/daemons common/daemon-shared.c common/dae ...
Message-ID: <20110627131550.12647.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-27 13:15:49

Modified files:
	daemons/common : daemon-shared.c daemon-shared.h 
	daemons/lvmetad: lvmetad-core.c testclient.c 

Log message:
	Implement daemon_send_simple and use it in the testclient.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/daemons/common/daemon-shared.c	2011/06/14 02:34:18	1.1
+++ LVM2/daemons/common/daemon-shared.c	2011/06/27 13:15:49	1.2
@@ -2,12 +2,15 @@
 #include <stdio.h>
 #include <malloc.h>
 #include <string.h>
+#include "daemon-shared.h"
 
 /*
  * Read a single message from a (socket) filedescriptor. Messages are delimited
  * by blank lines. This call will block until all of a message is received. The
  * memory will be allocated from heap. Upon error, all memory is freed and the
  * buffer pointer is set to NULL.
+ *
+ * See also write_buffer about blocking (read_buffer has identical behaviour).
  */
 int read_buffer(int fd, char **buffer) {
 	int bytes = 0;
@@ -66,3 +69,43 @@
 	}
 	return 0;
 }
+
+char *format_buffer(char *id, va_list ap)
+{
+	char *buffer, *old;
+	char *next;
+	char *format;
+
+	dm_asprintf(&buffer, "request = \"%s\"\n", id);
+	if (!buffer) goto fail;
+
+	while (next = va_arg(ap, char *)) {
+		old = buffer;
+		if (strstr(next, "%d") || strstr(next, "%s")) {
+			dm_asprintf(&format, "%%s%s\n", next);
+			if (!format) goto fail;
+
+			if (strstr(format, "%d"))
+				dm_asprintf(&buffer, format, buffer, va_arg(ap, int));
+			else
+				dm_asprintf(&buffer, format, buffer, va_arg(ap, char *));
+
+			dm_free(format);
+			dm_free(old);
+			if (!buffer) goto fail;
+		} else {
+			dm_asprintf(&buffer, "%s%s", buffer, next);
+			dm_free(old);
+			if (!buffer) goto fail;
+		}
+	}
+
+	old = buffer;
+	dm_asprintf(&buffer, "%s\n", buffer);
+	dm_free(old);
+
+	return buffer;
+fail:
+	dm_free(buffer);
+	return NULL;
+}
--- LVM2/daemons/common/daemon-shared.h	2011/06/14 02:34:18	1.1
+++ LVM2/daemons/common/daemon-shared.h	2011/06/27 13:15:49	1.2
@@ -1,2 +1,6 @@
+#include <stdarg.h>
+#include <libdevmapper.h>
+
 int read_buffer(int fd, char **buffer);
 int write_buffer(int fd, char *buffer, int length);
+char *format_buffer(char *id, va_list ap);
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/14 02:36:38	1.1
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 13:15:49	1.2
@@ -7,7 +7,7 @@
 static response handler(daemon_state s, client_handle h, request r)
 {
 	response res;
-	fprintf(stderr, "handling client request: %s\n", r.buffer);
+	fprintf(stderr, "---- server obtained:\n%s\n----------------------\n", r.buffer);
 	res.error = 1;
 	res.buffer = strdup("hey hey.\n\n");
 	return res;
--- LVM2/daemons/lvmetad/testclient.c	2011/06/27 12:27:34	1.2
+++ LVM2/daemons/lvmetad/testclient.c	2011/06/27 13:15:49	1.3
@@ -2,10 +2,9 @@
 
 int main() {
 	daemon_handle h = lvmetad_open();
-	daemon_request rq = { .buffer= "hello worldn\n" };
 	int i;
 	for (i = 0; i < 5; ++i ) {
-		daemon_reply reply = daemon_send(h, rq);
+		daemon_reply reply = daemon_send_simple(h, "hello world", "param = %d", 3, NULL);
 		fprintf(stderr, "daemon says: %s\n", reply.buffer);
 	}
 	daemon_close(h);


