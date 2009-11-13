From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Nov 2009 12:48:02 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/Makefile.in
Message-ID: <20091113124802.31139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-13 12:48:01

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: Makefile.in 

Log message:
	Fix install_device-mapper Makefile target to not build dmeventd plugins.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.314&r2=1.315
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW_DM	2009/11/13 12:43:21	1.314
+++ LVM2/WHATS_NEW_DM	2009/11/13 12:48:01	1.315
@@ -1,5 +1,6 @@
 Version 1.02.40 - 
 ===================================
+  Fix install_device-mapper Makefile target to not build dmeventd plugins.
   Support udev flags even when udev_sync is disabled or not compiled in.
   Remove 'last_rule' from udev rules: honor ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}.
   Add dmsetup --inactive support.
--- LVM2/daemons/dmeventd/Makefile.in	2009/10/13 02:35:26	1.29
+++ LVM2/daemons/dmeventd/Makefile.in	2009/11/13 12:48:01	1.30
@@ -103,7 +103,7 @@
 
 install: install_include install_lib install_dmeventd
 
-install_device-mapper: install
+install_device-mapper: install_include install_lib install_dmeventd
 
 .PHONY: distclean_lib distclean
 


