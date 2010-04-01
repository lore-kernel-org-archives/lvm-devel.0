From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Apr 2010 14:53:52 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100401145352.17934.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-01 14:53:48

Modified files:
	lib/mm         : memlock.c 

Log message:
	Better debug message for Un/Locked memory size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/lib/mm/memlock.c	2010/04/01 13:43:12	1.25
+++ LVM2/lib/mm/memlock.c	2010/04/01 14:53:47	1.26
@@ -228,7 +228,8 @@
 
 	free(line);
 
-	log_debug("Mapped size: %ld", (long)*mstats);
+	log_debug("%socked %ld bytes",
+		  (lock == LVM_MLOCK) ? "L" : "Unl", (long)*mstats);
 
 	return ret;
 }


