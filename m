From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:10:22 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110128161022.31663.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:10:22

Modified files:
	test/lib       : aux.sh 

Log message:
	Add command to wait for udevadm settle

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/lib/aux.sh	2011/01/13 14:57:18	1.7
+++ LVM2/test/lib/aux.sh	2011/01/28 16:10:21	1.8
@@ -1,3 +1,4 @@
+#!/bin/bash
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -71,6 +72,7 @@
 
 	}
 
+	udev_wait
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
@@ -367,6 +369,15 @@
 	$abs_top_builddir/test/api/wrapper "$@"
 }
 
+udev_wait() {
+	pgrep udev >/dev/null || return
+	if test -n "$1" ; then
+		udevadm settle --exit-if-exists=$1
+	else
+		udevadm settle --timeout=5 
+	fi
+}
+
 test -f DEVICES && devs=$(cat DEVICES)
 test -f LOOP && LOOP=$(cat LOOP)
 


