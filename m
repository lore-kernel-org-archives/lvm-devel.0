From: agk@sourceware.org <agk@sourceware.org>
Date: 28 May 2008 23:12:46 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20080528231246.7705.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-28 23:12:45

Modified files:
	lib/mm         : memlock.c 

Log message:
	fix setpriority int error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/lib/mm/memlock.c	2008/01/30 14:00:00	1.11
+++ LVM2/lib/mm/memlock.c	2008/05/28 23:12:45	1.12
@@ -105,7 +105,7 @@
 		log_sys_error("getpriority", "");
 	else
 		if (setpriority(PRIO_PROCESS, 0, _default_priority))
-			log_error("setpriority %u failed: %s",
+			log_error("setpriority %d failed: %s",
 				  _default_priority, strerror(errno));
 }
 


