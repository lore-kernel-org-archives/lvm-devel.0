From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 24 Mar 2009 11:49:16 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20090324114916.2279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-03-24 11:49:16

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Block SIGINT & SIGTERM in clvmd subthreads so they don't delay shutdown.
	Patch from Xinwei Hu, Thanks

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1071&r2=1.1072
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2009/03/23 22:57:27	1.1071
+++ LVM2/WHATS_NEW	2009/03/24 11:49:15	1.1072
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Block SIGTERM & SIGINT in clvmd subthreads.
   Detect and conditionally wipe swapspace signatures in pvcreate.
   Fix maximal volume count check for snapshots if max_lv set for volume group.
   Fix lvcreate to remove cow volume if the snapshot creation fails.
--- LVM2/daemons/clvmd/clvmd.c	2009/02/22 22:11:58	1.55
+++ LVM2/daemons/clvmd/clvmd.c	2009/03/24 11:49:15	1.56
@@ -372,9 +372,11 @@
 	signal(SIGHUP,  sighup_handler);
 	signal(SIGPIPE, SIG_IGN);
 
-	/* Block SIGUSR2 in the main process */
+	/* Block SIGUSR2/SIGINT/SIGTERM in process */
 	sigemptyset(&ss);
 	sigaddset(&ss, SIGUSR2);
+	sigaddset(&ss, SIGINT);
+	sigaddset(&ss, SIGTERM);
 	sigprocmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the LVM thread variables */
@@ -669,6 +671,11 @@
 {
 	DEBUGLOG("Using timeout of %d seconds\n", cmd_timeout);
 
+	sigset_t ss;
+	sigemptyset(&ss);
+	sigaddset(&ss, SIGINT);
+	sigaddset(&ss, SIGTERM);
+	pthread_sigmask(SIG_UNBLOCK, &ss, NULL);
 	/* Main loop */
 	while (!quit) {
 		fd_set in;


