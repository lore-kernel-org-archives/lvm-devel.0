From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 21 Nov 2008 13:48:01 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20081121134801.10871.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-11-21 13:48:00

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix a starup race in clvmd that could result in huge waits for the first command to be processed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.998&r2=1.999
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2008/11/19 19:33:25	1.998
+++ LVM2/WHATS_NEW	2008/11/21 13:48:00	1.999
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Fix startup race in clvmd.
   Generate Red Hat clvmd startup script at configuration time with correct paths.
   Fix clvmd & dmeventd builds after tree restructuring.
   Cope with snapshot dependencies when removing a whole VG with lvremove.
--- LVM2/daemons/clvmd/clvmd.c	2008/11/04 16:41:47	1.51
+++ LVM2/daemons/clvmd/clvmd.c	2008/11/21 13:48:00	1.52
@@ -423,6 +423,9 @@
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
 	DEBUGLOG("starting LVM thread\n");
+
+	/* Don't let anyone else to do work until we are started */
+	pthread_mutex_lock(&lvm_start_mutex);
 	pthread_create(&lvm_thread, NULL, lvm_thread_fn,
 			(void *)(long)using_gulm);
 
@@ -1758,9 +1761,6 @@
 	sigset_t ss;
 	int using_gulm = (int)(long)arg;
 
-	/* Don't let anyone else to do work until we are started */
-	pthread_mutex_lock(&lvm_start_mutex);
-
 	DEBUGLOG("LVM thread function started\n");
 
 	/* Ignore SIGUSR1 & 2 */


