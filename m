From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Sep 2009 23:40:20 -0000
Subject: LVM2/scripts lvm2_monitoring_init_red_hat.in
Message-ID: <20090916234020.17198.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-16 23:40:19

Modified files:
	scripts        : lvm2_monitoring_init_red_hat.in 

Log message:
	drop -ing suffix

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2009/09/16 23:22:40	1.1
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2009/09/16 23:40:19	1.2
@@ -21,7 +21,7 @@
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
 #	       
 ### BEGIN INIT INFO
-# Provides: lvm2-monitoring
+# Provides: lvm2-monitor
 # Required-Start: $local_fs
 # Required-Stop: $local_fs
 # Default-Start: 1 2 3 4 5
@@ -31,7 +31,7 @@
 
 . /etc/init.d/functions
 
-DAEMON=lvm2_monitoring
+DAEMON=lvm2_monitor
 
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@


