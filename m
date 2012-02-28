From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 14:25:37 -0000
Subject: LVM2/daemons/common daemon-server.c
Message-ID: <20120228142537.29580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 14:25:37

Modified files:
	daemons/common : daemon-server.c 

Log message:
	Check for failing dm_asprintf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/daemons/common/daemon-server.c	2012/02/28 13:05:21	1.18
+++ LVM2/daemons/common/daemon-server.c	2012/02/28 14:25:37	1.19
@@ -339,18 +339,23 @@
 
 static int buffer_rewrite(char **buf, const char *format, const char *string) {
 	char *old = *buf;
-	dm_asprintf(buf, format, *buf, string);
+	int r = dm_asprintf(buf, format, *buf, string);
+
 	dm_free(old);
-	return 0;
+
+	return (r < 0) ? 0 : 1;
 }
 
 static int buffer_line(const char *line, void *baton) {
 	response *r = baton;
-	if (r->buffer)
-		buffer_rewrite(&r->buffer, "%s\n%s", line);
-	else
-		dm_asprintf(&r->buffer, "%s\n", line);
-	return 0;
+
+	if (r->buffer) {
+		if (!buffer_rewrite(&r->buffer, "%s\n%s", line))
+			return 0;
+	} else if (dm_asprintf(&r->buffer, "%s\n", line) < 0)
+		return 0;
+
+	return 1;
 }
 
 static response builtin_handler(daemon_state s, client_handle h, request r)
@@ -387,7 +392,8 @@
 
 		if (!res.buffer) {
 			dm_config_write_node(res.cft->root, buffer_line, &res);
-			buffer_rewrite(&res.buffer, "%s\n\n", NULL);
+			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL))
+				goto fail;
 			dm_config_destroy(res.cft);
 		}
 


