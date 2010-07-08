From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 14:47:47 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100708144747.23027.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 14:47:47

Modified files:
	lib/mm         : memlock.c 

Log message:
	Fix format string from patch apply mistake

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/lib/mm/memlock.c	2010/07/08 13:05:27	1.28
+++ LVM2/lib/mm/memlock.c	2010/07/08 14:47:46	1.29
@@ -137,7 +137,7 @@
 
 	/* Select readable maps */
 	if (fr != 'r') {
-		log_debug("% area unreadable %s : Skipping.",
+		log_debug("%s area unreadable %s : Skipping.",
 			  (lock == LVM_MLOCK) ? "mlock" : "munlock", line);
 		return 1;
 	}


