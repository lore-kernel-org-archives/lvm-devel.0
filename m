From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 18:05:17 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-string.c
Message-ID: <20120223180517.22672.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 18:05:13

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-string.c 

Log message:
	Limit number of mem allocs and copies
	
	If we have good enough glibc to return number of needed chars, do not
	loop try to reach good size, but use this size directly for allocation,
	saving also last strdup.
	
	Since now we start with 16 bytes - skip buffer realloc for shorter string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.570&r2=1.571
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW_DM	2012/02/20 21:11:06	1.570
+++ LVM2/WHATS_NEW_DM	2012/02/23 18:05:12	1.571
@@ -1,5 +1,6 @@
 Version 1.02.72 - 
 ====================================
+  Avoid memory reallocation for dm_asprintf.
 
 Version 1.02.71 - 20th February 2012
 ====================================
--- LVM2/libdm/libdm-string.c	2012/02/10 13:56:20	1.18
+++ LVM2/libdm/libdm-string.c	2012/02/23 18:05:12	1.19
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2006-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -131,7 +131,7 @@
 
 int dm_asprintf(char **result, const char *format, ...)
 {
-	int n, ok = 0, size = 32;
+	int i, n, size = 16;
 	va_list ap;
 	char *buf = dm_malloc(size);
 
@@ -140,26 +140,30 @@
 	if (!buf)
 		return -1;
 
-	while (!ok) {
+	for (i = 0;; i++) {
 		va_start(ap, format);
 		n = vsnprintf(buf, size, format, ap);
 		va_end(ap);
 
 		if (0 <= n && n < size)
-			ok = 1;
-		else {
-			dm_free(buf);
-			size *= 2;
-			buf = dm_malloc(size);
-			if (!buf)
-				return -1;
-		}
+			break;
+
+		dm_free(buf);
+		/* Up to glibc 2.0.6 returns -1 */
+		size = (n < 0) ? size * 2 : n + 1;
+		if (!(buf = dm_malloc(size)))
+			return -1;
 	}
 
-	if (!(*result = dm_strdup(buf)))
-		n = -2; /* return -1 */
+	if (i > 1) {
+		/* Reallocating more then once? */
+		if (!(*result = dm_strdup(buf))) {
+			dm_free(buf);
+			return -1;
+		}
+	} else
+		*result = buf;
 
-	dm_free(buf);
 	return n + 1;
 }
 


