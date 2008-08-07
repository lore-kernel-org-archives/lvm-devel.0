From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Aug 2008 13:59:50 -0000
Subject: LVM2/lib/uuid uuid.c
Message-ID: <20080807135950.28284.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-07 13:59:50

Modified files:
	lib/uuid       : uuid.c 

Log message:
	added const and saved relocation entry

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/uuid/uuid.c	2008/01/30 14:00:01	1.24
+++ LVM2/lib/uuid/uuid.c	2008/08/07 13:59:49	1.25
@@ -20,7 +20,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 
-static char _c[] =
+static const char _c[] =
     "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#";
 
 static int _built_inverse;
@@ -110,7 +110,7 @@
  */
 static void _build_inverse(void)
 {
-	char *ptr;
+	const char *ptr;
 
 	if (_built_inverse)
 		return;


