From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 30 Jul 2009 13:32:40 -0000
Subject: LVM2 ./WHATS_NEW man/clvmd.8.in
Message-ID: <20090730133240.6783.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-07-30 13:32:39

Modified files:
	.              : WHATS_NEW 
	man            : clvmd.8.in 

Log message:
	Document the -I option to clvmd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1211&r2=1.1212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/07/30 12:25:42	1.1211
+++ LVM2/WHATS_NEW	2009/07/30 13:32:38	1.1212
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Document -I option of clvmd in the man page.
   Fix configure script to handle multiple clvmd selections.
   Fix lvm2app.pc installation filename.
   Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
--- LVM2/man/clvmd.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/clvmd.8.in	2009/07/30 13:32:39	1.2
@@ -74,6 +74,14 @@
 re-read the lvm configuration file. This command should be run whenever the
 devices on a cluster system are changed.
 .TP
+.I \-I
+Selects the cluster manager to use for locking and internal communications,
+the available managers will be listed as part of the 'clvmd -h' output.
+clvmd will use the first cluster manager that succeeds, and it checks them
+in the order cman,gulm,corosync,openais. As it is quite possible to have
+(eg) corosync and cman available on the same system you might have to
+manually specify this option to override the search.
+.TP
 .I \-V
 Display the version of the cluster LVM daemon.
 .SH SEE ALSO


