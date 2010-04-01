From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Apr 2010 13:43:14 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100401134314.5404.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-01 13:43:12

Modified files:
	lib/mm         : memlock.c 

Log message:
	Set ret value to success initially.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/mm/memlock.c	2010/03/30 14:41:58	1.24
+++ LVM2/lib/mm/memlock.c	2010/04/01 13:43:12	1.25
@@ -195,7 +195,7 @@
 	char *line = NULL;
 	size_t len;
 	ssize_t n;
-	int ret = 0;
+	int ret = 1;
 
 	if (_use_mlockall) {
 #ifdef MCL_CURRENT


