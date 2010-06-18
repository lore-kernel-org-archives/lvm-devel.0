From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Jun 2010 20:58:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20100618205804.9372.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-18 20:58:04

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	daemons/cmirrord/functions.c (part of cmirrord) was referencing
	linux/kdev_t.h even though it wasn't needed.  Strangely, it seems
	to be causing problems on various architectures (i686) in the
	function daemons/cmirrord/functions.c:disk_status_info()->sprintf.
	
	I'm not sure why this is a problem since none of the macros in
	kdev_t.h are used in that code, but it certainly doesn't hurt to
	pull an unnecessary header and it seems to fix the problem.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1618&r2=1.1619
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2010/06/18 10:19:29	1.1618
+++ LVM2/WHATS_NEW	2010/06/18 20:58:04	1.1619
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Unneeded kdev_t.h reference causing harm for cmirrord on some archs.
   Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
   Fix exit code when requesting help using documented -o help option.
   Do not use internal DLM lock definitions in generic LVM2 clvmd code.
--- LVM2/daemons/cmirrord/functions.c	2010/01/22 00:43:28	1.18
+++ LVM2/daemons/cmirrord/functions.c	2010/06/18 20:58:04	1.19
@@ -15,7 +15,6 @@
 #include <dirent.h>
 #include <errno.h>
 #include <fcntl.h>
-#include <linux/kdev_t.h>
 #include <signal.h>
 #include <sys/stat.h>
 #include <time.h>


