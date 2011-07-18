From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 14:42:44 -0000
Subject: LVM2/daemons/common daemon-shared.c
Message-ID: <20110718144244.25566.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 14:42:44

Modified files:
	daemons/common : daemon-shared.c 

Log message:
	Improve format_buffer in daemon-shared.c, adding block formatting in addition
	to string/integer (this propagates to the *simple* family of request/response
	functionality).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/common/daemon-shared.c	2011/06/29 22:20:14	1.3
+++ LVM2/daemons/common/daemon-shared.c	2011/07/18 14:42:44	1.4
@@ -2,6 +2,7 @@
 #include <stdio.h>
 #include <malloc.h>
 #include <string.h>
+#include <assert.h>
 #include "daemon-shared.h"
 
 /*
@@ -74,30 +75,34 @@
 {
 	char *buffer, *old;
 	char *next;
-	char *format;
+	int keylen;
 
 	dm_asprintf(&buffer, "%s = \"%s\"\n", what, id);
 	if (!buffer) goto fail;
 
 	while (next = va_arg(ap, char *)) {
 		old = buffer;
-		if (strstr(next, "%d") || strstr(next, "%s")) {
-			dm_asprintf(&format, "%%s%s\n", next);
-			if (!format) goto fail;
-
-			if (strstr(format, "%d"))
-				dm_asprintf(&buffer, format, buffer, va_arg(ap, int));
-			else
-				dm_asprintf(&buffer, format, buffer, va_arg(ap, char *));
-
-			dm_free(format);
+		assert(strchr(next, '='));
+		keylen = strchr(next, '=') - next;
+		if (strstr(next, "%d")) {
+			int value = va_arg(ap, int);
+			dm_asprintf(&buffer, "%s%.*s= %d\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%s")) {
+			char *value = va_arg(ap, char *);
+			dm_asprintf(&buffer, "%s%.*s= \"%s\"\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%b")) {
+			char *block = va_arg(ap, char *);
+			if (!block)
+				continue;
+			dm_asprintf(&buffer, "%s%.*s%s", buffer, keylen, next, block);
 			dm_free(old);
-			if (!buffer) goto fail;
 		} else {
 			dm_asprintf(&buffer, "%s%s", buffer, next);
 			dm_free(old);
-			if (!buffer) goto fail;
 		}
+		if (!buffer) goto fail;
 	}
 
 	old = buffer;


