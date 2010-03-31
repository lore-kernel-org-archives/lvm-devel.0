From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: 31 Mar 2010 12:01:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c
Message-ID: <20100331120151.7432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2010-03-31 12:01:50

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 

Log message:
	Don't kill the parent if debugging.
	
	If dmeventd runs with -d flag, it doesn't fork into backgroud.
	The command kill(getppid(), SIGTERM) attempts to kill the parent dmeventd
	process, however, if there is no parent, it kills whatever process spawned
	dmeventd. In case of debugging with gdb, the parent is gdb, thus
	kill(getppid(), SIGTERM) kills the debugger.
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1490&r2=1.1491
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2010/03/31 07:43:41	1.1490
+++ LVM2/WHATS_NEW	2010/03/31 12:01:49	1.1491
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  When dmeventd is not forking because of -d flag, don't kill the parent process
   Fix 'make install' when $(builddir) is different from $(srcdir).
   Fix dso resource leak in error path of dmeventd.
   Use C locales and use_mlockall for dmeventd.
--- LVM2/daemons/dmeventd/dmeventd.c	2010/03/30 14:40:30	1.57
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/03/31 12:01:50	1.58
@@ -1737,7 +1737,8 @@
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */
-	kill(getppid(), SIGTERM);
+	if (!_debug)
+		kill(getppid(), SIGTERM);
 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
 
 	while (!_exit_now) {


