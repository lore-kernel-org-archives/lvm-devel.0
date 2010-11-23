From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 15:09:02 -0000
Subject: LVM2/lib/config config.c
Message-ID: <20101123150902.29444.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 15:08:58

Modified files:
	lib/config     : config.c 

Log message:
	Move va_end() so it is also used before error path  return

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/lib/config/config.c	2010/09/30 21:06:51	1.82
+++ LVM2/lib/config/config.c	2010/11/23 15:08:57	1.83
@@ -381,11 +381,12 @@
 
 	va_start(ap, fmt);
 	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
+	va_end(ap);
+
 	if (n < 0 || n > (int) sizeof buf - 1) {
 		log_error("vsnprintf failed for config line");
 		return 0;
 	}
-	va_end(ap);
 
 	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
 		log_error("dm_pool_grow_object failed for config line");


