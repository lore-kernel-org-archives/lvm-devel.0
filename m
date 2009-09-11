From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 16:06:32 -0000
Subject: LVM2 ./WHATS_NEW man/dmsetup.8.in
Message-ID: <20090911160632.4120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 16:06:32

Modified files:
	.              : WHATS_NEW 
	man            : dmsetup.8.in 

Log message:
	Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1258&r2=1.1259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2009/09/11 16:05:20	1.1258
+++ LVM2/WHATS_NEW	2009/09/11 16:06:31	1.1259
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.
   Add DM_UDEV_RULES_VSN udev enviroment variable.
   Check that udev is running and set internal state appropriately.
   Add libudev configuration check.
--- LVM2/man/dmsetup.8.in	2009/07/31 17:51:46	1.24
+++ LVM2/man/dmsetup.8.in	2009/09/11 16:06:31	1.25
@@ -67,6 +67,10 @@
 .B dmsetup udevcomplete
 .I cookie
 .br
+.B dmsetup udevcomplete_all
+.br
+.B dmsetup udevcookies
+.br
 .B dmsetup targets
 .br
 .B dmsetup version
@@ -291,6 +295,13 @@
 .br
 Wake any processes that are waiting for udev to complete processing the specified cookie.
 .br
+.IP \fBudevcomplete_all
+Remove all cookies. Any process waiting on a cookie will be resumed immediately.
+.br
+.IP \fBudevcookies
+List all existing cookies. Cookies are system-wide semaphores with keys
+prefixed by two predefined bytes (0x0D4D).
+.br
 .IP \fBversion
 .br
 Outputs version information.


