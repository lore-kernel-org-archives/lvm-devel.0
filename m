From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Jun 2011 22:20:17 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-ser ...
Message-ID: <20110629222017.14836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-29 22:20:14

Modified files:
	daemons/common : daemon-client.c daemon-server.c daemon-shared.c 
	                 daemon-shared.h 

Log message:
	Differentiate the request and response format, in daemon/common.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/daemons/common/daemon-client.c	2011/06/27 13:58:11	1.4
+++ LVM2/daemons/common/daemon-client.c	2011/06/29 22:20:14	1.5
@@ -60,7 +60,7 @@
 {
 	va_list ap;
 	va_start(ap, id);
-	daemon_request rq = { .buffer = format_buffer(id, ap) };
+	daemon_request rq = { .buffer = format_buffer("request", id, ap) };
 
 	if (!rq.buffer) {
 		daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
--- LVM2/daemons/common/daemon-server.c	2011/06/27 13:58:11	1.6
+++ LVM2/daemons/common/daemon-server.c	2011/06/29 22:20:14	1.7
@@ -205,7 +205,7 @@
 {
 	va_list ap;
 	va_start(ap, id);
-	response res = { .buffer = format_buffer(id, ap), .cft = NULL };
+	response res = { .buffer = format_buffer("response", id, ap), .cft = NULL };
 
 	if (!res.buffer)
 		res.error = ENOMEM;
--- LVM2/daemons/common/daemon-shared.c	2011/06/27 13:15:49	1.2
+++ LVM2/daemons/common/daemon-shared.c	2011/06/29 22:20:14	1.3
@@ -70,13 +70,13 @@
 	return 0;
 }
 
-char *format_buffer(char *id, va_list ap)
+char *format_buffer(const char *what, const char *id, va_list ap)
 {
 	char *buffer, *old;
 	char *next;
 	char *format;
 
-	dm_asprintf(&buffer, "request = \"%s\"\n", id);
+	dm_asprintf(&buffer, "%s = \"%s\"\n", what, id);
 	if (!buffer) goto fail;
 
 	while (next = va_arg(ap, char *)) {
--- LVM2/daemons/common/daemon-shared.h	2011/06/27 13:15:49	1.2
+++ LVM2/daemons/common/daemon-shared.h	2011/06/29 22:20:14	1.3
@@ -3,4 +3,4 @@
 
 int read_buffer(int fd, char **buffer);
 int write_buffer(int fd, char *buffer, int length);
-char *format_buffer(char *id, va_list ap);
+char *format_buffer(const char *what, const char *id, va_list ap);


