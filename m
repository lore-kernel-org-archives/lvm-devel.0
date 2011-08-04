From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 10:12:45 -0000
Subject: LVM2 ./WHATS_NEW tools/commands.h
Message-ID: <20110804101245.26247.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 10:12:44

Modified files:
	.              : WHATS_NEW 
	tools          : commands.h 

Log message:
	Add missing new line in lvrename help text.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2046&r2=1.2047
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/WHATS_NEW	2011/08/02 22:07:20	1.2046
+++ LVM2/WHATS_NEW	2011/08/04 10:12:44	1.2047
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Add missing new line in lvrename help text.
   Add basic support for RAID 1/4/5/6 (i.e. create, remove, display)
   Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
   Add systemd unit file to provide lvm2 monitoring.
--- LVM2/tools/commands.h	2011/06/01 19:21:03	1.158
+++ LVM2/tools/commands.h	2011/08/04 10:12:44	1.159
@@ -362,7 +362,7 @@
 xx(lvrename,
    "Rename a logical volume",
    0,
-   "lvrename "
+   "lvrename\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"


