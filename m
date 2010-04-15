From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Apr 2010 19:15:05 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm2_monitoring_init_ ...
Message-ID: <20100415191505.31010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-15 19:15:04

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm2_monitoring_init_red_hat.in 

Log message:
	Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1528&r2=1.1529
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/04/15 15:12:20	1.1528
+++ LVM2/WHATS_NEW	2010/04/15 19:15:03	1.1529
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
   Added awk script relpath.awk to calculate relative paths.
   Fix double DESTDIR usage for infodir and mandir.
   Install symbolic .so links with relative paths between usrlibdir and libdir.
--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2010/01/05 20:56:52	1.3
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2010/04/15 19:15:04	1.4
@@ -31,7 +31,7 @@
 
 . /etc/init.d/functions
 
-DAEMON=lvm2_monitor
+DAEMON=lvm2-monitor
 
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@


