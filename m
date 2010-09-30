From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Sep 2010 10:09:00 -0000
Subject: LVM2/daemons/dmeventd/plugins lvm2/Makefile.in ...
Message-ID: <20100930100900.22616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-09-30 10:08:59

Modified files:
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 

Log message:
	Add missing cleanup rule for generated .exported_symbols_generated

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/04/09 21:42:49	1.5
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/09/30 10:08:58	1.6
@@ -29,3 +29,5 @@
 install_lvm2: install_lib_shared
 
 install: install_lvm2
+
+DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/05/11 08:41:58	1.21
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/09/30 10:08:59	1.22
@@ -35,3 +35,5 @@
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
+
+DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/05/11 08:41:59	1.16
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/09/30 10:08:59	1.17
@@ -31,3 +31,5 @@
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
+
+DISTCLEAN_TARGETS += .exported_symbols_generated


