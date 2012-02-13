From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 13 Feb 2012 05:24:58 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20120213052458.28874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2012-02-13 05:24:58

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	In the new corosync world, dlm is a standalone service.
	
	Fix clvmd init script to Require dlm service when building for the
	new corosync or clvmd will fail to start.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2279&r2=1.2280
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/WHATS_NEW	2012/02/13 00:23:21	1.2279
+++ LVM2/WHATS_NEW	2012/02/13 05:24:57	1.2280
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add clvmd init dependency on dlm service when running with new corosync.
 
 Version 2.02.91 - 12th February 2012
 ====================================
--- LVM2/configure.in	2012/01/31 21:21:54	1.180
+++ LVM2/configure.in	2012/02/13 05:24:57	1.181
@@ -675,6 +675,15 @@
 	fi
 fi
 
+dnl -- Fixup CLVMD_CMANAGERS with new corosync
+dnl -- clvmd built with corosync >= 2.0 needs dlm (either init or systemd service)
+dnl -- to be started.
+if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
+   if test x$HAVE_CMAP = xyes; then
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
+   fi
+fi
+
 ################################################################################
 dnl -- clvmd pidfile
 if test "x$CLVMD" != xnone; then


