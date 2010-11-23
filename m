From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 15:00:53 -0000
Subject: LVM2/libdm libdm-string.c
Message-ID: <20101123150053.24357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 15:00:52

Modified files:
	libdm          : libdm-string.c 

Log message:
	Move va_end(ap)  so we do not leave with return -1 without calling it.
	Remove unneeded ';'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/libdm/libdm-string.c	2010/10/25 13:13:53	1.13
+++ LVM2/libdm/libdm-string.c	2010/11/23 15:00:52	1.14
@@ -144,6 +144,8 @@
 	while (!ok) {
 		va_start(ap, format);
 		n = vsnprintf(buf, size, format, ap);
+		va_end(ap);
+
 		if (0 <= n && n < size)
 			ok = 1;
 		else {
@@ -152,8 +154,7 @@
 			buf = dm_malloc(size);
 			if (!buf)
 				return -1;
-		};
-		va_end(ap);
+		}
 	}
 
 	*result = dm_strdup(buf);


