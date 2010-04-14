From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 18:54:38 -0000
Subject: LVM2/daemons clvmd/clvmd.c dmeventd/dmeventd.c
Message-ID: <20100414185438.2117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 18:54:37

Modified files:
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: dmeventd.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/daemons/clvmd/clvmd.c	2010/04/14 18:53:04	1.68
+++ LVM2/daemons/clvmd/clvmd.c	2010/04/14 18:54:37	1.69
@@ -365,7 +365,7 @@
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	if (setenv("LANG", "C", 1) != 0)
+	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
 	/* Fork into the background (unless requested not to) */
--- LVM2/daemons/dmeventd/dmeventd.c	2010/04/14 18:53:05	1.60
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/04/14 18:54:37	1.61
@@ -1703,7 +1703,7 @@
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	if (!setenv("LANG", "C", 1))
+	if (setenv("LANG", "C", 1))
 		perror("Cannot set LANG to C");
 
 	if (!_debug)


