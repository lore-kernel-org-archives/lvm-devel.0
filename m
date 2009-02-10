From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 10 Feb 2009 11:53:34 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20090210115334.13425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-10 11:53:34

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Add option to /etc/sysconfig/cluster to select cluster type for clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1039&r2=1.1040
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/02/10 11:52:40	1.1039
+++ LVM2/WHATS_NEW	2009/02/10 11:53:33	1.1040
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
   Allow clvmd to start up if its lockspace already exists.
   Separate PV label attributes which do not need parse metadata when reporting.
   Remove external dependency on the 'cut' command in fsadm.
--- LVM2/scripts/clvmd_init_red_hat.in	2008/11/19 20:14:24	1.1
+++ LVM2/scripts/clvmd_init_red_hat.in	2009/02/10 11:53:34	1.2
@@ -26,6 +26,8 @@
 
 [ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
 
+[ -n "$CLVMD_CLUSTER_IFACE" ] && CLVMDOPTS="$CLVMDOPTS -I $CLVMD_CLUSTER_IFACE" 
+
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
 start()


