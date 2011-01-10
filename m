From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 19:31:03 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-exec.c tools/pol ...
Message-ID: <20110110193103.1658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 19:31:02

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-exec.c 
	tools          : polldaemon.c 

Log message:
	Avoid cookie sharing between forked processes
	
	Before fork, ensure cookie is reset so it's not shared between processes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1872&r2=1.1873
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2011/01/10 14:51:33	1.1872
+++ LVM2/WHATS_NEW	2011/01/10 19:31:02	1.1873
@@ -1,5 +1,6 @@
 Version 2.02.81 - 
 ===================================
+  Fix cookie sharing between forked lvm processes (2.02.80).
 
 Version 2.02.80 - 10th January 2011
 ===================================
--- LVM2/lib/misc/lvm-exec.c	2010/11/01 14:17:36	1.8
+++ LVM2/lib/misc/lvm-exec.c	2011/01/10 19:31:02	1.9
@@ -54,6 +54,8 @@
 
 	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
+	fs_unlock(); /* Flush oops and ensure cookie is not shared */
+
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
 		return 0;
--- LVM2/tools/polldaemon.c	2011/01/05 12:59:47	1.40
+++ LVM2/tools/polldaemon.c	2011/01/10 19:31:02	1.41
@@ -42,6 +42,8 @@
 
 	sigaction(SIGCHLD, &act, NULL);
 
+	fs_unlock(); /* Flush oops and ensure cookie is not shared */
+
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
 		return -1;


