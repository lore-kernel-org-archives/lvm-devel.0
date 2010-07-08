From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 13:05:27 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100708130527.3469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 13:05:27

Modified files:
	lib/mm         : memlock.c 

Log message:
	Small update of memlock debug messages.
	Gives slightly better alligned lines for reading.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/mm/memlock.c	2010/06/24 08:29:31	1.27
+++ LVM2/lib/mm/memlock.c	2010/07/08 13:05:27	1.28
@@ -137,7 +137,8 @@
 
 	/* Select readable maps */
 	if (fr != 'r') {
-		log_debug("mlock area unreadable '%s': Skipping.", line);
+		log_debug("% area unreadable %s : Skipping.",
+			  (lock == LVM_MLOCK) ? "mlock" : "munlock", line);
 		return 1;
 	}
 
@@ -171,7 +172,7 @@
 	}
 
 	*mstats += sz;
-	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
+	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s",
 		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
 		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
 


