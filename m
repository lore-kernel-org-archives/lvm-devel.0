From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Feb 2010 14:03:52 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100202140352.11557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-02-02 14:03:51

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	daemons/dmeventd/plugins: Makefile.in 

Log message:
	Fix dmeventd snapshot plugin build dependency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1414&r2=1.1415
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.341&r2=1.342
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/VERSION	2010/01/23 02:14:30	1.224
+++ LVM2/VERSION	2010/02/02 14:03:50	1.225
@@ -1 +1 @@
-2.02.60(1)-cvs (2010-01-23)
+2.02.61(1)-cvs (2010-02-02)
--- LVM2/VERSION_DM	2010/01/23 02:14:30	1.36
+++ LVM2/VERSION_DM	2010/02/02 14:03:50	1.37
@@ -1 +1 @@
-1.02.43-cvs (2010-01-23)
+1.02.44-cvs (2010-02-02)
--- LVM2/WHATS_NEW	2010/02/02 08:54:29	1.1414
+++ LVM2/WHATS_NEW	2010/02/02 14:03:50	1.1415
@@ -1,8 +1,7 @@
-Version 2.02.60 - 
+Version 2.02.61 - 
 ===================================
   Make clvmd -V return zero status.
 
-
 Version 2.02.60 - 23rd January 2010
 ===================================
   Fix lvconvert issue with cluster mirrors due to un'_safe' list processing
--- LVM2/WHATS_NEW_DM	2010/01/23 02:14:30	1.341
+++ LVM2/WHATS_NEW_DM	2010/02/02 14:03:50	1.342
@@ -1,3 +1,7 @@
+Version 1.02.44 - 
+===================================
+  Fix dmeventd snapshot plugin build dependency.
+
 Version 1.02.43 - 21st January 2010
 ===================================
   Remove bitset, hash and pool headers superceded by libdevmapper.h.
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2010/01/21 22:15:46	1.5
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2010/02/02 14:03:51	1.6
@@ -19,8 +19,8 @@
 
 SUBDIRS += lvm2 mirror snapshot
 
+include ../../../make.tmpl
+
 mirror: lvm2
 snapshot: lvm2
 
-include ../../../make.tmpl
-


