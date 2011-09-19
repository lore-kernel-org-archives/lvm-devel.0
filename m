From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 12:48:03 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-exec.c
Message-ID: <20110919124803.6874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 12:48:02

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-exec.c 

Log message:
	Move debug message
	
	so it does not look like we are executing command in the middle of
	critical_section in log trace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2116&r2=1.2117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/09/16 14:40:06	1.2116
+++ LVM2/WHATS_NEW	2011/09/19 12:48:02	1.2117
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Move debug message in exec_cmd after sync_local_dev_names.
   Fix clvmd processing of invalid request on local socket.
   Fix command line option decoding.
   Reset LV status when unlinking LV from VG.
--- LVM2/lib/misc/lvm-exec.c	2011/08/04 14:30:51	1.13
+++ LVM2/lib/misc/lvm-exec.c	2011/09/19 12:48:02	1.14
@@ -54,7 +54,6 @@
 	int status;
 	char buf[PATH_MAX * 2];
 
-	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
 	if (rstatus)
 		*rstatus = -1;
@@ -63,6 +62,8 @@
 		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
 			return_0;
 
+	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
+
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
 		return 0;


