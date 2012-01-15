From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jan 2012 11:17:18 -0000
Subject: LVM2/daemons/common daemon-shared.c daemon-sha ...
Message-ID: <20120115111718.4173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-01-15 11:17:17

Modified files:
	daemons/common : daemon-shared.c daemon-shared.h 

Log message:
	Unfortunately, blank lines are sometimes produced by config serializer, and
	this interferes with their role as message separator in the lvmetad
	protocol. Switch to using "##" on an otherwise blank line as a separator.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/common/daemon-shared.c	2011/09/17 14:49:18	1.6
+++ LVM2/daemons/common/daemon-shared.c	2012/01/15 11:17:16	1.7
@@ -38,7 +38,7 @@
 			*buffer = new;
 		} else {
 			(*buffer)[bytes] = 0;
-			if ((end = strstr((*buffer) + bytes - 2, "\n\n"))) {
+			if ((end = strstr((*buffer) + bytes - 4, "\n##\n"))) {
 				*end = 0;
 				break; /* success, we have the full message now */
 			}
@@ -58,18 +58,29 @@
  *
  * TODO use select on EWOULDBLOCK/EAGAIN to avoid useless spinning
  */
-int write_buffer(int fd, char *buffer, int length) {
+int write_buffer(int fd, const char *buffer, int length) {
+	int done = 0;
 	int written = 0;
+write:
 	while (1) {
 		int result = write(fd, buffer + written, length - written);
 		if (result > 0)
 			written += result;
 		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN)
-			break; /* too bad */
-		if (written == length)
-			return 1; /* done */
+			return 0; /* too bad */
+		if (written == length) {
+			if (done)
+				return 1;
+			else
+				break; /* done */
+		}
 	}
-	return 0;
+	const char *terminate = "\n##\n";
+	buffer = terminate;
+	length = 4;
+	written = 0;
+	done = 1;
+	goto write;
 }
 
 char *format_buffer(const char *what, const char *id, va_list ap)
@@ -106,10 +117,6 @@
 		if (!buffer) goto fail;
 	}
 
-	old = buffer;
-	dm_asprintf(&buffer, "%s\n", buffer);
-	dm_free(old);
-
 	return buffer;
 fail:
 	dm_free(buffer);
--- LVM2/daemons/common/daemon-shared.h	2011/06/29 22:20:14	1.3
+++ LVM2/daemons/common/daemon-shared.h	2012/01/15 11:17:16	1.4
@@ -2,5 +2,5 @@
 #include <libdevmapper.h>
 
 int read_buffer(int fd, char **buffer);
-int write_buffer(int fd, char *buffer, int length);
+int write_buffer(int fd, const char *buffer, int length);
 char *format_buffer(const char *what, const char *id, va_list ap);


