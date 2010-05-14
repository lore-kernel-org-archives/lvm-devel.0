From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 May 2010 11:33:30 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_fix_conf.sh scr ...
Message-ID: <20100514113330.6342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-14 11:33:21

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_fix_conf.sh fsadm.sh last_cvs_update.sh 
	                 lvmconf.sh lvmconf_lockingtype2.sh 
	                 vgimportclone.sh 

Log message:
	Use /bin/bash for scripts with bashisms

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1557&r2=1.1558
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_fix_conf.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/last_cvs_update.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmconf.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmconf_lockingtype2.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2010/05/13 18:38:38	1.1557
+++ LVM2/WHATS_NEW	2010/05/14 11:33:20	1.1558
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Use /bin/bash for scripts with bashisms.
   Skip internal lvm devices in scan if ignore suspended devices is requested.
   Do not merge old device cache after we run full scan. (2.02.56)
   Add pkgconfigdir Makefile variable for make install override.
--- LVM2/scripts/clvmd_fix_conf.sh	2004/12/01 14:47:31	1.2
+++ LVM2/scripts/clvmd_fix_conf.sh	2010/05/14 11:33:21	1.3
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Edit an lvm.conf file to enable cluster locking.
 #
--- LVM2/scripts/fsadm.sh	2009/06/09 15:31:36	1.11
+++ LVM2/scripts/fsadm.sh	2010/05/14 11:33:21	1.12
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
 #
--- LVM2/scripts/last_cvs_update.sh	2001/08/15 16:20:45	1.1
+++ LVM2/scripts/last_cvs_update.sh	2010/05/14 11:33:21	1.2
@@ -1,5 +1,5 @@
-#!/bin/sh
-#$Header: /cvs/lvm2/LVM2/scripts/last_cvs_update.sh,v 1.1 2001/08/15 16:20:45 lewis Exp $
+#!/bin/bash
+#$Header: /cvs/lvm2/LVM2/scripts/last_cvs_update.sh,v 1.2 2010/05/14 11:33:21 zkabelac Exp $
 ################################################################################
 ##
 ##    Copyright 2001 Sistina Software, Inc.
--- LVM2/scripts/lvmconf.sh	2009/11/27 14:32:16	1.5
+++ LVM2/scripts/lvmconf.sh	2010/05/14 11:33:21	1.6
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
--- LVM2/scripts/lvmconf_lockingtype2.sh	2009/11/27 14:32:16	1.1
+++ LVM2/scripts/lvmconf_lockingtype2.sh	2010/05/14 11:33:21	1.2
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
 #
--- LVM2/scripts/vgimportclone.sh	2009/06/17 15:47:01	1.2
+++ LVM2/scripts/vgimportclone.sh	2010/05/14 11:33:21	1.3
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.


