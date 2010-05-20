From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 11:20:43 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in scripts/Makefi ...
Message-ID: <20100520112043.17465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 11:20:38

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	scripts        : Makefile.in lvmconf.sh 

Log message:
	Install lvmconf script by default.
	Remove unnecessary versioned dmeventd plugin symlinks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1567&r2=1.1568
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmconf.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2010/05/19 11:57:05	1.1567
+++ LVM2/WHATS_NEW	2010/05/20 11:20:35	1.1568
@@ -1,5 +1,7 @@
 Version 2.02.66 - 
 ===============================
+  Install lvmconf script by default.
+  Remove unnecessary versioned dmeventd plugin symlinks.
   Add tests for lvm_vgname_from_{pvid|device}.
   Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
   Update pvchange to always obtain a vg handle for each pv to process.
--- LVM2/make.tmpl.in	2010/05/14 13:32:36	1.98
+++ LVM2/make.tmpl.in	2010/05/20 11:20:35	1.99
@@ -310,7 +310,6 @@
 install_dm_plugin: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/device-mapper/$(<F)
 	$(LN_S) -f device-mapper/$(<F) $(libdir)/$(<F)
-	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
 
 install_lvm2_plugin: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/lvm2/$(<F)
--- LVM2/scripts/Makefile.in	2010/04/14 20:03:16	1.16
+++ LVM2/scripts/Makefile.in	2010/05/20 11:20:38	1.17
@@ -17,7 +17,7 @@
 
 include $(top_builddir)/make.tmpl
 
-SCRIPTS = lvmdump.sh vgimportclone.sh
+SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
 ifeq ("@FSADM@", "yes")
 	SCRIPTS += fsadm.sh
 endif
--- LVM2/scripts/lvmconf.sh	2010/05/14 11:33:21	1.6
+++ LVM2/scripts/lvmconf.sh	2010/05/20 11:20:38	1.7
@@ -2,7 +2,7 @@
 #
 # Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the lvm2-cluster package.
+# This file is part of the lvm2 package.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions


