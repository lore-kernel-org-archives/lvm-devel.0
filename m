From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 13:25:50 -0000
Subject: LVM2 daemons/common/daemon-server.h lib/comman ...
Message-ID: <20110901132550.4200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 13:25:50

Modified files:
	daemons/common : daemon-server.h 
	lib/commands   : toolcontext.c 

Log message:
	Keep the old-style prototypes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/daemons/common/daemon-server.h	2011/08/31 12:39:58	1.11
+++ LVM2/daemons/common/daemon-server.h	2011/09/01 13:25:50	1.12
@@ -114,6 +114,6 @@
 daemon_reply daemon_takeover(daemon_info i, daemon_request r);
 
 /* Call this to request a clean shutdown of the daemon. Async safe. */
-void daemon_stop();
+void daemon_stop(void);
 
 #endif
--- LVM2/lib/commands/toolcontext.c	2011/08/30 14:55:16	1.131
+++ LVM2/lib/commands/toolcontext.c	2011/09/01 13:25:50	1.132
@@ -206,7 +206,7 @@
  * 856a6f1dbd8940e72755af145ebcd806408ecedd
  * some operations could not be performed by udev, requiring our fallback code.
  */
-static int _dm_driver_has_stable_udev_support()
+static int _dm_driver_has_stable_udev_support(void)
 {
 	char vsn[80];
 	unsigned maj, min, patchlevel;


