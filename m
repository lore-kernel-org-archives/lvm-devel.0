From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Apr 2010 20:54:58 -0000
Subject: LVM2/daemons clvmd/clvmd.c dmeventd/dmeventd.c
Message-ID: <20100413205458.8481.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-13 20:54:58

Modified files:
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: dmeventd.c 

Log message:
	Add error diagnostic for setenv failure.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/daemons/clvmd/clvmd.c	2010/04/13 19:54:16	1.66
+++ LVM2/daemons/clvmd/clvmd.c	2010/04/13 20:54:57	1.67
@@ -365,7 +365,8 @@
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	setenv("LANG", "C", 1);
+	if (setenv("LANG", "C", 1) != 0)
+		perror("Can not set LANG to C");
 
 	/* Fork into the background (unless requested not to) */
 	if (debug != DEBUG_STDERR) {
--- LVM2/daemons/dmeventd/dmeventd.c	2010/03/31 12:01:50	1.58
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/04/13 20:54:58	1.59
@@ -1703,7 +1703,8 @@
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	setenv("LANG", "C", 1);
+	if (setenv("LANG", "C", 1) != 0)
+		perror("Can not set LANG to C");
 
 	if (!_debug)
 		_daemonize();


