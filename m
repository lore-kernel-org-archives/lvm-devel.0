From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Aug 2008 00:49:46 -0000
Subject: LVM2/lib/uuid uuid.c
Message-ID: <20080829004946.31638.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-08-29 00:49:46

Modified files:
	lib/uuid       : uuid.c 

Log message:
	Add ctype.h header file to silence compile warning on 'isdigit'.
	
	uuid/uuid.c:86: warning: implicit declaration of function 'isdigit'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/lib/uuid/uuid.c	2008/08/28 18:41:51	1.26
+++ LVM2/lib/uuid/uuid.c	2008/08/29 00:49:46	1.27
@@ -19,6 +19,7 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <ctype.h>
 
 static const char _c[] =
     "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#";


