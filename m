From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 15:39:08 -0000
Subject: LVM2/test t-mdata-strings.sh
Message-ID: <20111023153908.22826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 15:39:08

Modified files:
	test           : t-mdata-strings.sh 

Log message:
	Expect failure with real /dev dir
	
	As udev is for now incapable to create such devices
	turn this test error into warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-mdata-strings.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-mdata-strings.sh	2011/10/23 15:39:08	1.7
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,8 +13,9 @@
 
 . lib/test
 
-aux prepare_devs 1
+aux prepare_devs 2
 
+# for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
 
 # 'set up temp files, loopback devices' 
@@ -23,9 +24,11 @@
 dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
 
 # 'pvcreate, vgcreate on filename with backslashed chars' 
-pvcreate "$dev1" 
-vgcreate $vg "$dev1"
-
+created=$dev1
+# when used with real udev without fallback, it will fail here
+pvcreate "$dev1" || created=$dev2
+pvs | should grep $dev1
+vgcreate $vg "$created"
 # 'no parse errors and VG really exists' 
 vgs 2>err
 not grep "Parse error" err;


