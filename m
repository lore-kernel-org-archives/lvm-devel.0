From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:00:54 -0000
Subject: LVM2 daemons/dmeventd/Makefile.in daemons/dmev ...
Message-ID: <20110924210054.838.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:00:53

Modified files:
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/raid: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	tools          : Makefile.in 

Log message:
	Drop cleanup of .exported_symbols_generated in DISTCLEAN_TARGETS
	
	Makefile cosmetics - since .exported_symbols_generated in cleardir:
	target via make.tmpl, there is no need to set them in DISTCLEAN_TARGETS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/raid/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/daemons/dmeventd/Makefile.in	2010/08/16 22:54:36	1.45
+++ LVM2/daemons/dmeventd/Makefile.in	2011/09/24 21:00:52	1.46
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -105,4 +105,4 @@
 
 install_device-mapper: install_include install_lib install_dmeventd
 
-DISTCLEAN_TARGETS += libdevmapper-event.pc .exported_symbols_generated
+DISTCLEAN_TARGETS += libdevmapper-event.pc
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/09/30 10:08:58	1.6
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2011/09/24 21:00:52	1.7
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -29,5 +29,3 @@
 install_lvm2: install_lib_shared
 
 install: install_lvm2
-
-DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/09/30 10:08:59	1.22
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2011/09/24 21:00:52	1.23
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005, 2008-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -35,5 +35,3 @@
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
-
-DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/daemons/dmeventd/plugins/raid/Makefile.in	2011/08/11 05:00:21	1.1
+++ LVM2/daemons/dmeventd/plugins/raid/Makefile.in	2011/09/24 21:00:53	1.2
@@ -1,6 +1,5 @@
 #
-# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005, 2008-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -35,5 +34,3 @@
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
-
-DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/09/30 10:08:59	1.17
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2011/09/24 21:00:53	1.18
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
@@ -31,5 +31,3 @@
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
-
-DISTCLEAN_TARGETS += .exported_symbols_generated
--- LVM2/tools/Makefile.in	2010/10/15 09:41:21	1.122
+++ LVM2/tools/Makefile.in	2011/09/24 21:00:53	1.123
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -203,5 +203,3 @@
 install_lvm2: $(INSTALL_LVM_TARGETS)
 
 install: install_lvm2 install_device-mapper
-
-DISTCLEAN_TARGETS += .exported_symbols_generated


