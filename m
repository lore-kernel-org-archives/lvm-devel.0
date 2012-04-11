From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:53:46 -0000
Subject: LVM2/test/shell lvresize-rounding.sh
Message-ID: <20120411125346.11194.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:53:46

Modified files:
	test/shell     : lvresize-rounding.sh 

Log message:
	Update test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-rounding.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvresize-rounding.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/lvresize-rounding.sh	2012/04/11 12:53:46	1.3
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -11,16 +11,80 @@
 
 . lib/test
 
-aux prepare_vg 2
+aux prepare_pvs 3 22
 
-lvcreate -l 10 -n lv -i2 $vg
+vgcreate -s 32K $vg "$dev1" "$dev2" "$dev3"
 
-lvextend -l +1 $vg/lv 2>&1 | tee log
-grep 'down to stripe' log
-lvresize -l +1 $vg/lv 2>&1 | tee log
-grep 'down to stripe' log
-
-lvreduce -f -l -1 $vg/lv 2>&1 | tee log
-grep 'up to stripe' log
-lvresize -f -l -1 $vg/lv 2>&1 | tee log
-grep 'up to stripe' log
+lvcreate -l4 -i3 -I64 $vg
+
+lvcreate -l8 -i2 -I64 $vg
+
+lvcreate -l16 $vg
+
+lvcreate -l32 -i3 -I64 -n $lv1 $vg
+
+lvresize -l+64 -i3 -I64 $vg/$lv1
+
+lvresize -l+64 -i3 -I128 $vg/$lv1
+
+#lvcreate -l100%FREE -i3 -I64 --alloc anywhere $vg
+
+dmsetup table
+
+vgcfgbackup -f /tmp/vg $vg
+vgremove -f $vg
+
+# 15 extents
+aux prepare_vg 3 22
+
+# Block some extents
+lvcreate -l4 -i3 $vg
+lvcreate -l1 $vg
+
+lvcreate -l100%FREE -n $lv1 -i3 $vg
+check vg_field $vg vg_free_count 2
+lvremove -f $vg/$lv1
+
+lvcreate -l1 -n $lv1 -i3 $vg
+lvextend -l+100%FREE -i3 $vg/$lv1
+check vg_field $vg vg_free_count 2
+
+lvreduce -f -l50%LV $vg/$lv1
+vgremove -f $vg
+
+
+vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
+
+# Expect to play with 15 extents
+check vg_field $vg vg_free_count 15
+
+# Should be rounded to 12 extents
+lvcreate -l10 -n lv -i3 $vg
+check vg_field $vg vg_free_count 3
+
+# Should want 16 extents
+not lvextend -l+4 $vg/lv
+
+# Round up to whole free space
+lvextend -l+100%FREE $vg/lv
+check vg_field $vg vg_free_count 0
+
+# Rounds up and should reduce just by 3 extents
+lvreduce -f -l-4 $vg/lv
+check vg_field $vg vg_free_count 3
+
+# Should round up to 15 extents
+lvextend -f -l+1 $vg/lv
+check vg_field $vg vg_free_count 0
+
+lvreduce -f -l-4 $vg/lv
+check vg_field $vg vg_free_count 3
+
+lvextend -l90%VG $vg/lv
+check vg_field $vg vg_free_count 0
+
+lvreduce -f -l-10%LV $vg/lv
+check vg_field $vg vg_free_count 0
+
+lvreduce -f -l-20%LV $vg/lv
+check vg_field $vg vg_free_count 3


