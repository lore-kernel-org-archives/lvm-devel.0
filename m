From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:35:41 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20100330143541.15773.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:35:41

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Remove mlockall() form dmeventd
	
	As the header file <sys/mman.h> was not included in dmeventd.c
	thus missed definition of MCL_CURRENT so this patch only makes
	it obvious we were not locking memory here.
	
	This patch has no functional change.
	Later part of this patch set handles mlockall() via memlock_inc_daemon().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/daemons/dmeventd/dmeventd.c	2008/11/04 15:07:44	1.54
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:35:40	1.55
@@ -1725,11 +1725,6 @@
 
 	pthread_mutex_init(&_global_mutex, NULL);
 
-#ifdef MCL_CURRENT
-	if (mlockall(MCL_CURRENT | MCL_FUTURE) == -1)
-		exit(EXIT_FAILURE);
-#endif
-
 	if ((ret = _open_fifos(&fifos)))
 		exit(EXIT_FIFO_FAILURE);
 
@@ -1749,9 +1744,6 @@
 
 	_exit_dm_lib();
 
-#ifdef MCL_CURRENT
-	munlockall();
-#endif
 	pthread_mutex_destroy(&_global_mutex);
 
 	syslog(LOG_NOTICE, "dmeventd shutting down.");


