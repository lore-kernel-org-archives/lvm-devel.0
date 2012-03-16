From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 13:00:24 -0000
Subject: LVM2/test api/pe_start.sh api/percent.sh api/v ...
Message-ID: <20120316130024.24357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 13:00:06

Modified files:
	test/api       : pe_start.sh percent.sh vgtest.sh 
	test/shell     : 000-basic.sh activate-missing.sh 
	                 activate-partial.sh covercmd.sh 
	                 dmeventd-restart.sh dumpconfig.sh fsadm.sh 
	                 inconsistent-metadata.sh listings.sh 
	                 lock-blocking.sh lvchange-mirror.sh 
	                 lvconvert-mirror-basic-0.sh 
	                 lvconvert-mirror-basic-1.sh 
	                 lvconvert-mirror-basic-2.sh 
	                 lvconvert-mirror-basic-3.sh 
	                 lvconvert-mirror-basic.sh lvconvert-mirror.sh 
	                 lvconvert-raid.sh lvconvert-repair-dmeventd.sh 
	                 lvconvert-repair-policy.sh 
	                 lvconvert-repair-replace.sh 
	                 lvconvert-repair-snapshot.sh 
	                 lvconvert-repair-transient-dmeventd.sh 
	                 lvconvert-repair-transient.sh 
	                 lvconvert-repair.sh lvconvert-twostep.sh 
	                 lvcreate-mirror.sh lvcreate-operation.sh 
	                 lvcreate-pvtags.sh lvcreate-raid.sh 
	                 lvcreate-repair.sh lvcreate-small-snap.sh 
	                 lvcreate-thin.sh lvcreate-usage.sh 
	                 lvextend-percent-extents.sh 
	                 lvextend-snapshot-dmeventd.sh 
	                 lvextend-snapshot-policy.sh lvm-init.sh 
	                 lvmcache-exercise.sh lvmetad-pvs.sh 
	                 lvresize-mirror.sh lvresize-rounding.sh 
	                 lvresize-usage.sh mdata-strings.sh 
	                 metadata-balance.sh metadata-dirs.sh 
	                 metadata.sh mirror-names.sh 
	                 mirror-vgreduce-removemissing.sh 
	                 name-mangling.sh nomda-missing.sh 
	                 pool-labels.sh pv-duplicate.sh pv-min-size.sh 
	                 pv-range-overflow.sh pvchange-usage.sh 
	                 pvcreate-metadata0.sh pvcreate-operation-md.sh 
	                 pvcreate-operation.sh pvcreate-usage.sh 
	                 pvmove-basic.sh pvremove-usage.sh read-ahead.sh 
	                 snapshot-autoumount-dmeventd.sh 
	                 snapshot-merge.sh snapshots-of-mirrors.sh 
	                 tags.sh test-partition.sh topology-support.sh 
	                 unlost-pv.sh vgcfgbackup-usage.sh 
	                 vgchange-maxlv.sh vgchange-sysinit.sh 
	                 vgchange-usage.sh vgcreate-usage.sh 
	                 vgextend-restoremissing.sh vgextend-usage.sh 
	                 vgimportclone.sh vgmerge-operation.sh 
	                 vgmerge-usage.sh 
	                 vgreduce-removemissing-snapshot.sh 
	                 vgreduce-usage.sh vgrename-usage.sh 
	                 vgsplit-operation.sh vgsplit-stacked.sh 
	                 vgsplit-usage.sh 

Log message:
	Update tests
	
	Indent
	
	Shell improvements - use internal function for checks
	
	Use PVs in ""   (LV and VG cannot have spaces)
	
	Several test very starting 'dmeventd' without annoucing
	it via prepade_dmeventd.
	
	Fix some of test actually.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/pe_start.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/000-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-missing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-partial.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/covercmd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dumpconfig.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/fsadm.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/listings.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lock-blocking.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvchange-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-0.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-1.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-2.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic-3.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-raid.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-small-snap.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-policy.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvm-init.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmetad-pvs.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-rounding.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvresize-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mdata-strings.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata-balance.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata-dirs.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/metadata.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-names.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/name-mangling.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/nomda-missing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pool-labels.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-duplicate.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-min-size.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/read-ahead.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/tags.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/test-partition.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/topology-support.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/unlost-pv.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-maxlv.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-sysinit.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgchange-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgextend-restoremissing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgreduce-removemissing-snapshot.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/pe_start.sh	2011/06/04 21:55:25	1.2
+++ LVM2/test/api/pe_start.sh	2012/03/16 13:00:05	1.3
@@ -1,4 +1,4 @@
-#
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
@@ -14,6 +14,8 @@
 . lib/test
 
 aux prepare_devs 2
+
 aux apitest pe_start test_vg $dev1
+
 not vgs test_vg
 not pvs $dev1
--- LVM2/test/api/percent.sh	2011/09/19 18:40:51	1.7
+++ LVM2/test/api/percent.sh	2012/03/16 13:00:05	1.8
@@ -1,4 +1,4 @@
-#
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
@@ -16,11 +16,12 @@
 kernel_at_least 2 6 33 || skip
 
 aux prepare_devs 2
+
 vgcreate -c n -s 4k $vg $(cat DEVICES)
-lvcreate -n foo $vg -l 5
+lvcreate -l 5 -n foo $vg
 lvcreate -s -n snap $vg/foo -l 2 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
-dd if=/dev/urandom of=$DM_DEV_DIR/$vg/snap2 count=1 bs=1024
+dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024
 lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs $vg
 aux apitest percent $vg
--- LVM2/test/api/vgtest.sh	2011/01/05 00:16:21	1.2
+++ LVM2/test/api/vgtest.sh	2012/03/16 13:00:05	1.3
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -13,6 +14,7 @@
 #
 
 . lib/test
-aux prepare_devs 2
-pvcreate $dev1 $dev2
-aux apitest vgtest $vg1 $dev1 $dev2
+
+aux prepare_pvs 2
+
+aux apitest vgtest $vg1 "$dev1" "$dev2"
--- LVM2/test/shell/000-basic.sh	2011/12/10 14:55:31	1.2
+++ LVM2/test/shell/000-basic.sh	2012/03/16 13:00:06	1.3
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -25,4 +26,4 @@
 
 # ensure we do not crash on a bug in config file
 aux lvmconf 'log/prefix = 1""'
-not lvs
+not lvs $(cat DEVICES)
--- LVM2/test/shell/activate-missing.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/activate-missing.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,4 @@
-#!/bin/bash
-
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -21,18 +20,18 @@
 
 aux prepare_vg 4
 
-lvcreate -l1 -n linear1 $vg $dev1
-lvcreate -l1 -n linear2 $vg $dev2
-lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+lvcreate -l1 -n linear1 $vg "$dev1"
+lvcreate -l1 -n linear2 $vg "$dev2"
+lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 
-lvcreate -l1 -n origin1 $vg $dev1
-lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+lvcreate -l1 -n origin1 $vg "$dev1"
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
-lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -45,8 +44,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-aux enable_dev $dev1
-aux disable_dev $dev2
+aux enable_dev "$dev1"
+aux disable_dev "$dev2"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -59,8 +58,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-aux enable_dev $dev2
-aux disable_dev $dev3
+aux enable_dev "$dev2"
+aux disable_dev "$dev3"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -73,8 +72,8 @@
 check active $vg mirror12
 
 vgchange -a n $vg
-aux enable_dev $dev3
-aux disable_dev $dev4
+aux enable_dev "$dev3"
+aux disable_dev "$dev4"
 vgchange -a y $vg
 not vgck $vg
 
--- LVM2/test/shell/activate-partial.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/activate-partial.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,7 +15,7 @@
 
 lvcreate -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 
 not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
--- LVM2/test/shell/covercmd.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/covercmd.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,5 @@
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,25 +15,17 @@
 
 . lib/test
 
-TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
-
-get_lvs_()
-{
-  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
-    *$2) true ;;
-    *) false ;;
-  esac
-}
-
 aux prepare_devs 5
 
-pvcreate $dev1
-pvcreate --metadatacopies 0 $dev2
-pvcreate --metadatacopies 0 $dev3
-pvcreate $dev4
-pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
+TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
+
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+pvcreate "$dev4"
+pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
 vgcreate -c n $vg $(cat DEVICES)
-lvcreate -n $lv -l 5 -i5 -I256 $vg
+lvcreate -l 5 -i5 -I256 -n $lv $vg
 
 # test *scan and *display tools
 pvscan
@@ -41,8 +34,8 @@
 lvmdiskscan
 vgdisplay --units k
 lvdisplay --units g
-for i in h b s k m g t p e H B S K M G T P E ; do
-    pvdisplay --units "$i" "$dev1"
+for i in h b s k m g t p e H B S K M G T P E; do
+	pvdisplay --units $i "$dev1"
 done
 
 # test vgexport vgimport tools
@@ -55,28 +48,28 @@
 # "-persistent n"
 # test various lvm utils
 for i in dumpconfig formats segtypes; do
-    lvm "$i"
+	lvm $i
 done
 
 for i in pr "p rw" an ay "-monitor y" "-monitor n" \
         -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
-    lvchange -$i "$vg"/"$lv"
+	lvchange -$i $vg/$lv
 done
 
 pvck "$dev1"
-vgck "$vg"
-lvrename "$vg" "$lv" "$lv-rename"
-vgcfgbackup -f "$(pwd)/backup.$$" "$vg"
-vgchange -an "$vg"
-vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
-pvremove -y -ff $dev5
-not vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
-pvcreate -u $TEST_UUID --restorefile  "$(pwd)/backup.$$" $dev5
-vgremove -f "$vg"
+vgck $vg
+lvrename $vg $lv $lv-rename
+vgcfgbackup -f backup.$$ $vg
+vgchange -an $vg
+vgcfgrestore  -f backup.$$ $vg
+pvremove -y -ff "$dev5"
+not vgcfgrestore  -f backup.$$ $vg
+pvcreate -u $TEST_UUID --restorefile  backup.$$ "$dev5"
+vgremove -f $vg
 pvresize --setphysicalvolumesize 10M "$dev1"
 
 # test various errors and obsoleted tools
 not lvmchange
-not lvrename "$vg"
-not lvrename "$vg-xxx"
-not lvrename "$vg"  "$vg"/"$lv-rename" "$vg"/"$lv"
+not lvrename $vg
+not lvrename $vg-xxx
+not lvrename $vg  $vg/$lv-rename $vg/$lv
--- LVM2/test/shell/dmeventd-restart.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/dmeventd-restart.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,10 +11,10 @@
 
 . lib/test
 
-aux prepare_vg 5
-aux prepare_dmeventd
+which mkfs.ext2 || skip
 
-which mkfs.ext2 || exit 200
+aux prepare_dmeventd
+aux prepare_vg 5
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
@@ -32,11 +32,11 @@
 grep 'already monitored' lvchange.out
 
 # now try what happens if no dmeventd is running
-kill -9 `cat LOCAL_DMEVENTD`
+kill -9 $(cat LOCAL_DMEVENTD)
 dmeventd -R -f &
-echo "$!" > LOCAL_DMEVENTD
 sleep 3
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 not grep 'already monitored' lvchange.out
+pgrep dmeventd >LOCAL_DMEVENTD
 
 vgremove -ff $vg
--- LVM2/test/shell/dumpconfig.sh	2011/12/11 23:14:37	1.1
+++ LVM2/test/shell/dumpconfig.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -18,7 +19,7 @@
     done
 }
 
-lvm dumpconfig -vvvv | flatten | sort > config.dump
+lvm dumpconfig | flatten | sort > config.dump
 flatten < etc/lvm.conf | sort > config.input
 
 # check that dumpconfig output corresponds to the lvm.conf input
@@ -32,4 +33,3 @@
 echo 'log { verbose = 1 }' > etc/lvm_foo.conf
 lvm dumpconfig | flatten | grep 'log/verbose=1'
 lvm dumpconfig | flatten | grep 'log/indent=1'
-
--- LVM2/test/shell/fsadm.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/fsadm.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
-#!/bin/bash
-# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -21,40 +21,45 @@
 check_xfs=
 check_reiserfs=
 
-which mkfs.ext3 || check_ext3=${check_ext3:=mkfs.ext3}
-which fsck.ext3 || check_ext3=${check_ext3:=fsck.ext3}
-which mkfs.xfs || check_xfs=${check_xfs:=mkfs.xfs}
-which xfs_check || check_xfs=${check_xfs:=xfs_check}
-which mkfs.reiserfs || check_reiserfs=${check_reiserfs:=mkfs.reiserfs}
-which reiserfsck || check_reiserfs=${check_reiserfs:=reiserfsck}
+which mkfs.ext3 || check_ext3=${check_ext3:-mkfs.ext3}
+which fsck.ext3 || check_ext3=${check_ext3:-fsck.ext3}
+which mkfs.xfs || check_xfs=${check_xfs:-mkfs.xfs}
+which xfs_check || check_xfs=${check_xfs:-xfs_check}
+which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
+which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
 
-vg_lv="$vg/$lv1"
+vg_lv=$vg/$lv1
+vg_lv2=$vg/${lv1}bar
 dev_vg_lv="$DM_DEV_DIR/$vg_lv"
-mount_dir="$TESTDIR/mnt"
+dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
+mount_dir="mnt"
+mount_space_dir="mnt space dir"
 # for recursive call
 export LVM_BINARY=$(which lvm)
 
-test ! -d $mount_dir && mkdir $mount_dir
+test ! -d "$mount_dir" && mkdir "$mount_dir"
+test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
 
 cleanup_mounted_and_teardown()
 {
-	umount $mount_dir || true
+	umount "$mount_dir" || true
+	umount "$mount_space_dir" || true
 	aux teardown
 }
 
 fscheck_ext3()
 {
-	fsck.ext3 -p -F -f $dev_vg_lv
+	fsck.ext3 -p -F -f "$dev_vg_lv"
 }
 
 fscheck_xfs()
 {
-	xfs_check $dev_vg_lv
+	xfs_check "$dev_vg_lv"
 }
 
 fscheck_reiserfs()
 {
-	reiserfsck --check -p -f $dev_vg_lv </dev/null
+	reiserfsck --check -p -f "$dev_vg_lv" </dev/null
 }
 
 check_missing()
@@ -63,36 +68,63 @@
 	test -z "$t" && return 0
 	test "$t" = skip && return 1
 	# trick for warning test
-	echo "TEST ""WARNING: fsadm skips $1 tests, $t tool is missing"
+	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing"
 	return 1
 }
 
 # Test for block sizes != 1024 (rhbz #480022)
 lvcreate -n $lv1 -L20M $vg
+lvcreate -n ${lv1}bar -L10M $vg
 trap 'cleanup_mounted_and_teardown' EXIT
 
+if check_missing ext2; then
+	mkfs.ext2 -b4096 -j "$dev_vg_lv"
+
+	fsadm --lvresize resize $vg_lv 30M
+	# Fails - not enough space for 4M fs
+	not fsadm -y --lvresize resize "$dev_vg_lv" 4M
+	lvresize -L+10M -r $vg_lv
+	lvreduce -L10M -r $vg_lv
+
+	fscheck_ext3
+	mount "$dev_vg_lv" "$mount_dir"
+	not fsadm -y --lvresize resize $vg_lv 4M
+	echo n | not lvresize -L4M -r -n $vg_lv
+	lvresize -L+20M -r -n $vg_lv
+	umount "$mount_dir"
+	fscheck_ext3
+
+	lvresize -f -L20M $vg_lv
+fi
+
 if check_missing ext3; then
-	mkfs.ext3 -b4096 -j $dev_vg_lv
+	mkfs.ext3 -b4096 -j "$dev_vg_lv"
+	mkfs.ext3 -b4096 -j "$dev_vg_lv2"
 
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
-	not fsadm -y --lvresize resize $dev_vg_lv 4M
+	not fsadm -y --lvresize resize "$dev_vg_lv" 4M
 	lvresize -L+10M -r $vg_lv
 	lvreduce -L10M -r $vg_lv
 
 	fscheck_ext3
-	mount $dev_vg_lv $mount_dir
+	mount "$dev_vg_lv" "$mount_dir"
+	lvresize -L+10M -r $vg_lv
+	mount "$dev_vg_lv2" "$mount_space_dir"
+	fsadm --lvresize -e -y resize $vg_lv2 25M
+
 	not fsadm -y --lvresize resize $vg_lv 4M
 	echo n | not lvresize -L4M -r -n $vg_lv
 	lvresize -L+20M -r -n $vg_lv
-	umount $mount_dir
+	umount "$mount_dir"
+	umount "$mount_space_dir"
 	fscheck_ext3
 
 	lvresize -f -L20M $vg_lv
 fi
 
 if check_missing xfs; then
-	mkfs.xfs -l internal,size=1000b -f $dev_vg_lv
+	mkfs.xfs -l internal,size=1000b -f "$dev_vg_lv"
 
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
@@ -100,26 +132,26 @@
 	not lvreduce -L10M -r $vg_lv
 
 	fscheck_xfs
-	mount $dev_vg_lv $mount_dir
+	mount "$dev_vg_lv" "$mount_dir"
 	lvresize -L+10M -r -n $vg_lv
-	umount $mount_dir
+	umount "$mount_dir"
 	fscheck_xfs
 
 	lvresize -f -L20M $vg_lv
 fi
 
 if check_missing reiserfs; then
-	mkfs.reiserfs -s 513 -f $dev_vg_lv
+	mkfs.reiserfs -s 513 -f "$dev_vg_lv"
 
 	fsadm --lvresize resize $vg_lv 30M
 	lvresize -L+10M -r $vg_lv
 	fsadm --lvresize -y resize $vg_lv 10M
 
 	fscheck_reiserfs
-	mount $dev_vg_lv $mount_dir
+	mount "$dev_vg_lv" "$mount_dir"
 
 	fsadm -y --lvresize resize $vg_lv 30M
-	umount $mount_dir
+	umount "$mount_dir"
 	fscheck_reiserfs
 
 	lvresize -f -L20M $vg_lv
--- LVM2/test/shell/inconsistent-metadata.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/inconsistent-metadata.sh	2012/03/16 13:00:06	1.3
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -24,7 +24,7 @@
 	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
 	grep resized lvs.out | not grep 8192
 	lvresize -L 8192K $vg/resized
-	aux restore_dev $dev1
+	aux restore_dev "$dev1"
 }
 
 check() {
@@ -44,25 +44,25 @@
 if !test -e LOCAL_LVMETAD; then
 	# vgdisplay fixes
 	init
-	vgdisplay 2>&1 | tee cmd.out
+	vgdisplay $vg 2>&1 | tee cmd.out
 	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgdisplay 2>&1 | tee cmd.out
+	vgdisplay $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
 	check
 
 	# lvs fixes up
 	init
-	lvs 2>&1 | tee cmd.out
+	lvs $vg 2>&1 | tee cmd.out
 	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgdisplay 2>&1 | tee cmd.out
+	vgdisplay $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
 	check
 
 	# vgs fixes up as well
 	init
-	vgs 2>&1 | tee cmd.out
+	vgs $vg 2>&1 | tee cmd.out
 	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgs 2>&1 | tee cmd.out
+	vgs $vg 2>&1 | tee cmd.out
 	not grep "Inconsistent metadata found for VG $vg" cmd.out
 	check
 fi
@@ -71,8 +71,8 @@
 vgremove -f $vg
 pvremove -ff $(cat DEVICES)
 pvcreate $(cat DEVICES)
-aux backup_dev $dev2
-vgcreate $vg $dev1
-vgextend $vg $dev2
-aux restore_dev $dev2
-should check compare_fields vgs $vg vg_mda_count pvs $dev2 vg_mda_count
+aux backup_dev "$dev2"
+vgcreate $vg "$dev1"
+vgextend $vg "$dev2"
+aux restore_dev "$dev2"
+should check compare_fields vgs $vg vg_mda_count pvs "$dev2" vg_mda_count
--- LVM2/test/shell/listings.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/listings.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,35 +15,25 @@
 
 . lib/test
 
-get_lvs_()
-{
-  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
-    *$2) true ;;
-    *) false ;;
-  esac
-}
-
 aux prepare_devs 5
 
-pvcreate $dev1
-pvcreate --metadatacopies 0 $dev2
-pvcreate --metadatacopies 0 $dev3
-pvcreate $dev4
-pvcreate --metadatacopies 0 $dev5
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+pvcreate "$dev4"
+pvcreate --metadatacopies 0 "$dev5"
 
 #COMM bz195276 -- pvs doesn't show PVs until a VG is created
-pvs --noheadings|tee out
-test $(wc -l <out) -eq 5
+test $(pvs --noheadings $(cat DEVICES) | wc -l) -eq 5
 
 #COMM pvs with segment attributes works even for orphans
-pvs --noheadings -o  seg_all,pv_all,lv_all,vg_all | tee out
-test $(wc -l <out) -eq 5
+test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l) -eq 5
 
 vgcreate -c n $vg $(cat DEVICES)
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
 pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
-for I in $dev2 $dev3 $dev5; do
+for I in "$dev2" "$dev3" "$dev5"; do
 	check pv_field $I pv_mda_count 0
 	check pv_field $I pv_mda_free 0
 done
@@ -50,26 +41,22 @@
 check vg_field $vg vg_mda_count 2
 
 #COMM pvs doesn't display --metadatacopies 0 PVs as orphans (bz409061)
-pvdisplay $dev2|grep "VG Name.*$vg"
-test $(pvs -o vg_name --noheadings $dev2) = $vg
+pvdisplay "$dev2"|grep "VG Name.*$vg"
+check pv_field "$dev2" vg_name $vg
 
 #COMM lvs displays snapshots (bz171215)
 lvcreate -l4 -n $lv1 $vg
 lvcreate -l4 -s -n $lv2 $vg/$lv1
-lvs $vg --noheadings|tee out
-test $(wc -l <out) -eq 2
-lvs -a --noheadings|tee out
+test $(lvs --noheadings $vg | wc -l) -eq 2
 # should lvs -a display cow && real devices? (it doesn't)
-test $(wc -l <out) -eq 2
+test $(lvs -a --noheadings $vg | wc -l)  -eq 2
 dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
-lvcreate -l4  -m2 -n$lv3 $vg
-lvs $vg --noheadings|tee out
-test $(wc -l <out) -eq 2
-lvs -a --noheadings|tee out
-test $(wc -l <out) -eq 6
+lvcreate -l4 -m2 -n $lv3 $vg
+test $(lvs --noheadings $vg | wc -l) -eq 2
+test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
 
 #COMM vgs with options from pvs still treats arguments as VGs (bz193543)
@@ -80,4 +67,3 @@
 pvdisplay $(cat DEVICES) >out
 pvdisplay --maps $(cat DEVICES) >out2
 not diff out out2
-
--- LVM2/test/shell/lock-blocking.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lock-blocking.sh	2012/03/16 13:00:06	1.2
@@ -14,9 +14,9 @@
 . lib/test
 
 aux prepare_devs 3
-test -e LOCAL_CLVMD && exit 200
-pvcreate $dev1 $dev2
-vgcreate $vg $dev1 $dev2
+test -e LOCAL_CLVMD && skip
+pvcreate "$dev1" "$dev2"
+vgcreate $vg "$dev1" "$dev2"
 
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
@@ -30,7 +30,7 @@
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
-vgcreate $vg $dev1 $dev2
+vgcreate $vg "$dev1" "$dev2"
 flock -w 5 $TESTDIR/var/lock/lvm/P_orphans -c "sleep 10" &
 
 while ! test -f $TESTDIR/var/lock/lvm/P_orphans ; do sleep .1 ; done
--- LVM2/test/shell/lvchange-mirror.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvchange-mirror.sh	2012/03/16 13:00:06	1.2
@@ -10,19 +10,21 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/test
+
+aux prepare_dmeventd
 aux prepare_vg 3
 
 # force resync 2-way active mirror
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
-check mirror $vg $lv1 $dev3
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+check mirror $vg $lv1 "$dev3"
 echo y | lvchange --resync $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # force resync 2-way inactive mirror
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 lvchange -an $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 lvchange --resync $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
--- LVM2/test/shell/lvconvert-mirror-basic-0.sh	2011/11/21 11:36:53	1.3
+++ LVM2/test/shell/lvconvert-mirror-basic-0.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvconvert-mirror-basic-1.sh	2011/11/21 11:36:53	1.3
+++ LVM2/test/shell/lvconvert-mirror-basic-1.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvconvert-mirror-basic-2.sh	2011/11/21 11:36:53	1.3
+++ LVM2/test/shell/lvconvert-mirror-basic-2.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvconvert-mirror-basic-3.sh	2011/11/21 11:36:53	1.3
+++ LVM2/test/shell/lvconvert-mirror-basic-3.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvconvert-mirror-basic.sh	2012/03/04 16:02:19	1.2
+++ LVM2/test/shell/lvconvert-mirror-basic.sh	2012/03/16 13:00:06	1.3
@@ -1,4 +1,5 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,15 +11,12 @@
 
 . lib/test
 
-log_name_to_count()
-{
-	if [ "$1" = "mirrored" ]; then
-		echo 2
-	elif [ "$1" = "disk" ]; then
-		echo 1
-	else
-		echo 0
-	fi
+log_name_to_count() {
+	case "$1"  in
+	mirrored) echo 2 ;;
+	disk)	  echo 1 ;;
+	*)	  echo 0 ;;
+	esac
 }
 
 # FIXME: For test_[up|down]convert, I'd still like to be able
@@ -38,15 +36,14 @@
 #          2-way disk-log mirror while not active
 # -> test_lvconvert 2 disk 3 disk 0
 
-test_lvconvert()
-{
+test_lvconvert() {
 	local start_count=$1
 	local start_count_p1=$(($start_count + 1))
 	local start_log_type=$2
 	local finish_count=$3
 	local finish_count_p1=$(($finish_count + 1))
 	local finish_log_type=$4
-	local dev_array=($dev1 $dev2 $dev3 $dev4 $dev5)
+	local dev_array=("$dev1" "$dev2" "$dev3" "$dev4" "$dev5")
 	local start_log_count
 	local finish_log_count
 	local max_log_count
@@ -58,19 +55,15 @@
 	#test $finish_count -gt $start_count && up=true
 
 	# Do we have enough devices for the mirror images?
-	if [ $start_count_p1 -gt ${#dev_array[@]} ]; then
-		echo "Action requires too many devices"
-		return 1
-	fi
+	test $start_count_p1 -gt ${#dev_array[@]} && \
+		die "Action requires too many devices"
 
 	# Do we have enough devices for the mirror images?
-	if [ $finish_count_p1 -gt ${#dev_array[@]} ]; then
-		echo "Action requires too many devices"
-		return 1
-	fi
+	test $finish_count_p1 -gt ${#dev_array[@]} && \
+		die "Action requires too many devices"
 
-	start_log_count=`log_name_to_count $start_log_type`
-	finish_log_count=`log_name_to_count $finish_log_type`
+	start_log_count=$(log_name_to_count $start_log_type)
+	finish_log_count=$(log_name_to_count $finish_log_type)
 	if [ $finish_log_count -gt $start_log_count ]; then
 		max_log_count=$finish_log_count
 	else
@@ -92,9 +85,7 @@
 	fi
 
 	lvs -a -o name,copy_percent,devices $vg
-	if ! $active; then
-		lvchange -an $vg/$lv1
-	fi
+	test $active || lvchange -an $vg/$lv1
 
 	# Are there extra devices for the log or do we overlap
 	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
@@ -104,9 +95,7 @@
 	lvconvert -m $finish_count --mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
-	if ! $active; then
-		lvchange -ay $vg/$lv1
-	fi
+	test $active || lvchange -ay $vg/$lv1
 
 	check mirror_no_temporaries $vg $lv1
 	if [ "$finish_count_p1" -eq 1 ]; then
--- LVM2/test/shell/lvconvert-mirror.sh	2012/03/04 16:02:19	1.4
+++ LVM2/test/shell/lvconvert-mirror.sh	2012/03/16 13:00:06	1.5
@@ -11,9 +11,8 @@
 
 . lib/test
 
-wait_for_mirror_in_sync_()
-{
-	while [ $(lvs --noheadings -o copy_percent $1) != "100.00" ]; do sleep 1; done
+wait_for_mirror_in_sync_() {
+	while test $(get lv_field $1 copy_percent) != "100.00"; do sleep 1; done
 }
 
 # convert from linear to 2-way mirror
@@ -21,95 +20,95 @@
 # FIXME - test fails with extent size < 512k
 vgcreate -c n -s 512k $vg $(cat DEVICES)
 
-lvcreate -l2 -n $lv1 $vg $dev1
-lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1
-check mirror $vg $lv1 $dev3
+lvcreate -l2 -n $lv1 $vg "$dev1"
+lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1"
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # convert from 2-way mirror to linear
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
 lvremove -ff $vg
 # and now try removing a specific leg (bz453643)
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
-lvconvert -m0 $vg/$lv1 $dev2
-check lv_on $vg $lv1 $dev1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvconvert -m0 $vg/$lv1 "$dev2"
+check lv_on $vg $lv1 "$dev1"
 lvremove -ff $vg
 
 # convert from disklog to corelog, active
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, active
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
-lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
-check mirror $vg $lv1 $dev3
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # bz192865: lvconvert log of an inactive mirror lv
 # convert from disklog to corelog, inactive
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvchange -an $vg/$lv1
 echo y | lvconvert -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, inactive
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvchange -an $vg/$lv1
-lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
-check mirror $vg $lv1 $dev3
+lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # convert linear to 2-way mirror with 1 PV
-lvcreate -l2 -n $lv1 $vg $dev1
-not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
+lvcreate -l2 -n $lv1 $vg "$dev1"
+not lvconvert -m+1 --mirrorlog core $vg/$lv1 "$dev1"
 lvremove -ff $vg
 
 # Start w/ 3-way mirror
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0
+lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:0"
 # FIXME:
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
-should not lvconvert -m-1 $vg/$lv1 $dev1
+should not lvconvert -m-1 $vg/$lv1 "$dev1"
 
 lvconvert $vg/$lv1 # wait
-lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0 # If the above "should" failed...
+lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
 wait_for_mirror_in_sync_ $vg/$lv1
-lvconvert -m-1 $vg/$lv1 $dev1
-check mirror_images_on $lv1 $dev2 $dev4
-lvconvert -m-1 $vg/$lv1 $dev2
+lvconvert -m-1 $vg/$lv1 "$dev1"
+check mirror_images_on $lv1 "$dev2" "$dev4"
+lvconvert -m-1 $vg/$lv1 "$dev2"
 check linear $vg $lv1
-check lv_on $vg $lv1 $dev4
+check lv_on $vg $lv1 "$dev4"
 lvremove -ff $vg
 
 # No parallel lvconverts on a single LV please
 
-lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l5 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
-lvconvert -m+1 -b $vg/$lv1 $dev4
+lvconvert -m+1 -b $vg/$lv1 "$dev4"
 
 # Next convert should fail b/c we can't have 2@once
-should not lvconvert -m+1 $vg/$lv1 $dev5
+should not lvconvert -m+1 $vg/$lv1 "$dev5"
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvconvert -m +1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
@@ -128,28 +127,28 @@
 
 # add 1 mirror then add 1 more mirror during conversion
 # FIXME this has been explicitly forbidden?
-#lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
-#lvconvert -m+1 -b $vg/$lv1 $dev4
-#lvconvert -m+1 $vg/$lv1 $dev5
+#lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0
+#lvconvert -m+1 -b $vg/$lv1 "$dev4"
+#lvconvert -m+1 $vg/$lv1 "$dev5"
 #
-#check mirror $vg $lv1 $dev3
+#check mirror $vg $lv1 "$dev3"
 #check mirror_no_temporaries $vg $lv1
 #check mirror_legs $vg $lv1 4
 #lvremove -ff $vg
 
 # Linear to mirror with mirrored log using --alloc anywhere
-lvcreate -l2 -n $lv1 $vg $dev1
-lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
+lvcreate -l2 -n $lv1 $vg "$dev1"
+lvconvert -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 should check mirror $vg $lv1
 lvremove -ff $vg
 
 # convert inactive mirror and start polling
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 lvchange -an $vg/$lv1
-lvconvert -m+1 $vg/$lv1 $dev4
+lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -ay $vg/$lv1
 lvconvert $vg/$lv1 # wait
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 lvremove -ff $vg
 
@@ -157,45 +156,45 @@
 # removal during conversion
 
 # "remove newly added mirror"
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
-lvconvert -m+1 -b $vg/$lv1 $dev4
-lvconvert -m-1 $vg/$lv1 $dev4
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvconvert -m+1 -b $vg/$lv1 "$dev4"
+lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
 # "remove one of newly added mirrors"
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
-lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5
-lvconvert -m-1 $vg/$lv1 $dev4
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
+lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original is still mirror)"
-lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
-lvconvert -m+1 -b $vg/$lv1 $dev4 
-lvconvert -m-1 $vg/$lv1 $dev2 
-lvconvert $vg/$lv1 
+lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:0"
+lvconvert -m+1 -b $vg/$lv1 "$dev4"
+lvconvert -m-1 $vg/$lv1 "$dev2"
+lvconvert $vg/$lv1
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original becomes linear)"
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
-lvconvert -m+1 -b $vg/$lv1 $dev4 
-lvconvert -m-1 $vg/$lv1 $dev2 
-lvconvert $vg/$lv1 
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvconvert -m+1 -b $vg/$lv1 "$dev4"
+lvconvert -m-1 $vg/$lv1 "$dev2"
+lvconvert $vg/$lv1
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
 lvremove -ff $vg
@@ -203,21 +202,21 @@
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l`pvs --noheadings -ope_count "$dev1"` -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 wait_for_mirror_in_sync_ $vg/$lv1
-lvconvert -m0 $vg/$lv1 $dev1
+lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
 
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
-lvcreate -l2 -m1 -n$lv1 --nosync $vg 
+lvcreate -l2 -m1 -n$lv1 --nosync $vg
 lvconvert -m0 $vg/$lv1
 lvconvert -m1 $vg/$lv1
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
 lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
-lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
+lvcreate -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
 lvconvert -m1 $vg/$lv1
 
 should check mirror $vg $lv1
@@ -225,7 +224,7 @@
 lvremove -ff $vg
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
-lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
+lvcreate -l1 -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
@@ -235,13 +234,13 @@
 # ---
 # add mirror and disk log
 
-# "add 1 mirror and disk log" 
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+# "add 1 mirror and disk log"
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 
 # FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 "$dev4" "$dev3:0"
 
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
 lvremove -ff $vg
--- LVM2/test/shell/lvconvert-raid.sh	2012/03/15 20:00:54	1.4
+++ LVM2/test/shell/lvconvert-raid.sh	2012/03/16 13:00:06	1.5
@@ -1,6 +1,5 @@
-#!/bin/bash
-
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,22 +12,19 @@
 . lib/test
 
 # is_in_sync <VG/LV>
-function is_in_sync()
-{
-	local dm_name
+is_in_sync_() {
 	local a
 	local b
 	local idx
-
-	dm_name=`echo $1 | sed s:-:--: | sed s:/:-:`
+	local dm_name=$(echo $1 | sed s:-:--: | sed s:/:-:)
 
 	if ! a=(`dmsetup status $dm_name`); then
 		echo "Unable to get sync status of $1"
-		exit 1
+		return 1
 	elif [ ${a[2]} = "snapshot-origin" ]; then
 		if ! a=(`dmsetup status ${dm_name}-real`); then
 			echo "Unable to get sync status of $1"
-			exit 1
+			return 1
 		fi
 	fi
 
@@ -41,9 +37,9 @@
 		idx=$((${a[3]} + 4))
 	else
 		echo "Unable to get sync ratio for target type '${a[2]}'"
-		exit 1
+		return 1
 	fi
-	b=(`echo ${a[$idx]} | sed s:/:' ':`)
+	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
 
 	if [ ${b[0]} != ${b[1]} ]; then
 		echo "$dm_name (${a[3]}) is not in-sync"
@@ -52,7 +48,7 @@
 
 	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
 		echo "$dm_name in-sync, but 'a' characters in health status"
-		exit 1
+		return 1
 	fi
 
 	if [ ${a[2]} = "raid" ]; then
@@ -60,49 +56,26 @@
 	else
 		echo "$dm_name (${a[2]}) is in-sync"
 	fi
-
-	return 0
 }
 
 # wait_for_sync <VG/LV>
-function wait_for_sync()
-{
-	local i=0
-
-	while ! is_in_sync $1; do
-		sleep 2
-		i=$(($i + 1))
-		if [ $i -gt 500 ]; then
-			echo "Sync is taking too long - assume stuck"
-			exit 1
-		fi
+wait_for_sync_() {
+	for i in {1..100} ; do
+		is_in_sync_ $1 && return
+		sleep 1
 	done
-}
-
-function is_raid_available()
-{
-	local a
-
-	modprobe dm-raid
-	a=(`dmsetup targets | grep raid`)
-	if [ -z $a ]; then
-		echo "RAID target not available"
-		return 1
-	fi
-	if [ ${a[1]} != "v1.1.0" ]; then
-		echo "Bad RAID version"
-		return 1
-	fi
 
-	return 0
+	echo "Sync is taking too long - assume stuck"
+	return 1
 }
 
 ########################################################
 # MAIN
 ########################################################
-is_raid_available || skip
+aux target_at_least dm-raid 1 1 0 || skip
 
-aux prepare_vg 5 80
+aux prepare_pvs 5 80
+vgcreate -c n -s 256k $vg $(cat DEVICES)
 
 ###########################################
 # RAID1 convert tests
@@ -138,7 +111,7 @@
 			lvcreate -l 2 -n $lv1 $vg
 		else
 			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
-			wait_for_sync $vg/$lv1
+			wait_for_sync_ $vg/$lv1
 		fi
 
 		if $under_snap; then
@@ -159,7 +132,7 @@
 
 # 3-way to 2-way convert while specifying devices
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
-wait_for_sync $vg/$lv1
+wait_for_sync_ $vg/$lv1
 lvconvert -m1 $vg/$lv1 $dev2
 lvremove -ff $vg
 
@@ -172,7 +145,7 @@
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync $vg/$lv1
+wait_for_sync_ $vg/$lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg $lv2
@@ -181,7 +154,7 @@
 
 # 2-way to linear/linear
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-wait_for_sync $vg/$lv1
+wait_for_sync_ $vg/$lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check linear $vg $lv1
 check linear $vg $lv2
@@ -190,7 +163,7 @@
 
 # 3-way to linear/2-way
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync $vg/$lv1
+wait_for_sync_ $vg/$lv1
 # FIXME: Can't split off a RAID1 from a RAID1 yet
 should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
 #check linear $vg $lv1
@@ -203,7 +176,7 @@
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync $vg/$lv1
+wait_for_sync_ $vg/$lv1
 lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg ${lv1}_rimage_2
@@ -216,7 +189,7 @@
 ###########################################
 for i in 1 2 3 ; do
 	lvcreate --type mirror -m $i -l 2 -n $lv1 $vg
-	wait_for_sync $vg/$lv1
+	wait_for_sync_ $vg/$lv1
 	lvconvert --type raid1 $vg/$lv1
 	lvremove -ff $vg
 done
--- LVM2/test/shell/lvconvert-repair-dmeventd.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-dmeventd.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,16 +11,18 @@
 
 . lib/test
 
+which mkfs.ext2 || skip
+
 aux prepare_vg 5
 aux prepare_dmeventd
 
-which mkfs.ext2 || exit 200
-
 lvcreate -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
 sleep 10 # FIXME: need a "poll" utility, akin to "check"
-aux enable_dev $dev2 $dev4
+aux enable_dev "$dev2" "$dev4"
 check mirror $vg 4way
 check mirror_legs $vg 4way 2
+
+vgremove -ff $vg
--- LVM2/test/shell/lvconvert-repair-policy.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-policy.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -20,10 +20,10 @@
 # is always on $dev3.  ($dev4 behaves as a spare)
 cleanup() {
 	vgreduce --removemissing $vg
-	for d in "$@"; do aux enable_dev $d; done
-	for d in "$@"; do vgextend $vg $d; done
+	for d in "$@"; do aux enable_dev "$d"; done
+	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
-	lvcreate -m 1 --ig -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
+	lvcreate -m 1 --ig -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
 }
 
 repair() {
@@ -34,58 +34,58 @@
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 check linear $vg mirror
-cleanup $dev1
+cleanup "$dev1"
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced, should retain log)
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup $dev1
+cleanup "$dev1"
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup $dev1
+cleanup "$dev1"
 
 # Fail a leg of a mirror (use old name for policy specification)
 # Expected result: Mirror (leg replaced)
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 check active $vg mirror_mlog
-cleanup $dev1
+cleanup "$dev1"
 
 # Fail a leg of a mirror w/ no available spare
 # Expected result: linear
 #                  (or 2-way with leg/log overlap if alloc anywhere)
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 not check lv_exists $vg mirror_mlog
-cleanup $dev2 $dev4
+cleanup "$dev2" "$dev4"
 
 # Fail the log device of a mirror w/ no available spare
 # Expected result: mirror w/ corelog
-aux disable_dev $dev3 $dev4
+aux disable_dev "$dev3" "$dev4"
 repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
 check mirror $vg mirror
 not check lv_exists $vg mirror_mlog
-cleanup $dev3 $dev4
+cleanup "$dev3" "$dev4"
 
 # Fail the log device with a remove policy
 # Expected result: mirror w/ corelog
 lvchange -a y $vg/mirror
-aux disable_dev $dev3 $dev4
+aux disable_dev "$dev3" "$dev4"
 repair 'activation { mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror core
 not check lv_exists $vg mirror_mlog
-cleanup $dev3 $dev4
+cleanup "$dev3" "$dev4"
--- LVM2/test/shell/lvconvert-repair-replace.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-replace.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -17,77 +17,76 @@
 
 # 3-way, disk log
 # multiple failures, full replace
-lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
-aux disable_dev $dev1 $dev2
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
+aux disable_dev "$dev1" "$dev2"
 echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 not grep "WARNING: Failed" 3way.out
 vgreduce --removemissing $vg
 check mirror $vg 3way
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 
-vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 
 # 2-way, mirrored log
 # Double log failure, full replace
 lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
-    $dev1 $dev2 $dev3:0 $dev4:0
-aux disable_dev $dev3 $dev4
+    "$dev1" "$dev2" "$dev3":0 "$dev4":0
+aux disable_dev "$dev3" "$dev4"
 echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 not grep "WARNING: Failed" 2way.out
 vgreduce --removemissing $vg
 check mirror $vg 2way
-aux enable_dev $dev3 $dev4
+aux enable_dev "$dev3" "$dev4"
 
-vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 
 # 3-way, mirrored log
 # Single log failure, replace
 lvcreate --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
-    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
-aux disable_dev $dev4
+    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
+aux disable_dev "$dev4"
 echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 not grep "WARNING: Failed" 3way.out
 vgreduce --removemissing $vg
 check mirror $vg 3way
-aux enable_dev $dev4
+aux enable_dev "$dev4"
 
-vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
+vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
 # 3-way, disk log
 # multiple failures, partial replace
-lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
-aux disable_dev $dev1 $dev2
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
+aux disable_dev "$dev1" "$dev2"
 echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 3way
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 lvchange -a n $vg/3way
 
-vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3
+vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
 
-lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3
-aux disable_dev $dev1
+lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
+aux disable_dev "$dev1"
 echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 2way
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 lvchange -a n $vg/2way
 
-vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
+vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but covert should succeed (switch to corelog)
-lvcreate -m 2 --ig -l 2 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4:0
+lvcreate -m 2 --ig -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
-pvremove -ff -y $dev4
+pvremove -ff -y "$dev4"
 echo 'y' | lvconvert -y --repair $vg/mirror2
 check mirror $vg mirror2
-vgs
-
+vgs $vg
--- LVM2/test/shell/lvconvert-repair-snapshot.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-snapshot.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,14 +15,13 @@
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
-lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+lvcreate -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
-aux enable_dev $dev2 $dev4
-lvs -a -o +devices
-check mirror $vg 4way $dev5
-
+aux enable_dev "$dev2" "$dev4"
+lvs -a -o +devices $vg
+check mirror $vg 4way "$dev5"
--- LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-transient-dmeventd.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -16,12 +16,14 @@
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
-aux enable_dev $dev2 $dev4
+aux enable_dev "$dev2" "$dev4"
 sleep 3
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 check mirror $vg 4way
 check mirror_legs $vg 4way 2
-lvs -a -o +devices | not grep mimage_1
-lvs -a -o +devices | not grep mimage_3
+lvs -a -o +devices $vg | not grep mimage_1
+lvs -a -o +devices $vg | not grep mimage_3
+
+vgremove -f $vg
--- LVM2/test/shell/lvconvert-repair-transient.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair-transient.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,13 +14,15 @@
 aux prepare_vg 5
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way &
 sleep 1
-aux enable_dev $dev2 $dev4
+aux enable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 4way
 lvchange -a n $vg/4way
 wait
+
+vgremove -f $vg
--- LVM2/test/shell/lvconvert-repair.sh	2012/03/04 16:02:19	1.2
+++ LVM2/test/shell/lvconvert-repair.sh	2012/03/16 13:00:06	1.3
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -24,91 +24,91 @@
 
 # 4-way, disk log => 2-way, disk log
 aux prepare_vg 5
-lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
-aux disable_dev $dev2 $dev4
+lvcreate -m 3 --ig -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
-lvs -a -o +devices | not grep unknown
+lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
-aux enable_dev $dev2 $dev4
-check mirror $vg 4way $dev5
+aux enable_dev "$dev2" "$dev4"
+check mirror $vg 4way "$dev5"
 
 # 3-way, disk log => linear
 recreate_vg_
 lvcreate -m 2 --ig -L 1 -n 3way $vg
-aux disable_dev $dev1 $dev2
+aux disable_dev "$dev1" "$dev2"
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
-lvs -a -o +devices | not grep unknown
-lvs -a -o +devices | not grep mlog
+lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg | not grep mlog
 dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
-aux enable_dev $dev1 $dev2
+aux enable_dev "$dev1" "$dev2"
 check linear $vg 3way
 
 # fail just log and get it removed
 
 # 3-way, disk log => 3-way, core log
 recreate_vg_
-lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
-aux disable_dev $dev4
+lvcreate -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+aux disable_dev "$dev4"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
-lvs -a -o +devices | not grep unknown
-lvs -a -o +devices | not grep mlog
+lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg | not grep mlog
 dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
-aux enable_dev $dev4
+aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
 recreate_vg_
 lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
-    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
-aux disable_dev $dev4 $dev5
+    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
+aux disable_dev "$dev4" "$dev5"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
-lvs -a -o +devices | not grep unknown
-lvs -a -o +devices | not grep mlog
+lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg | not grep mlog
 dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
-aux enable_dev $dev4 $dev5
+aux enable_dev "$dev4" "$dev5"
 
 # 2-way, disk log => 2-way, core log
 recreate_vg_
-lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
-aux disable_dev $dev3
+lvcreate -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
+aux disable_dev "$dev3"
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
-lvs -a -o +devices | not grep unknown
-lvs -a -o +devices | not grep mlog
+lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg | not grep mlog
 vgreduce --removemissing $vg
-aux enable_dev $dev3
+aux enable_dev "$dev3"
 
 # fail single devices
 
 recreate_vg_
-vgreduce $vg $dev4
+vgreduce $vg "$dev4"
 
 lvcreate -m 1 --ig -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
-vgextend $vg $dev4
-aux disable_dev $dev1
+vgextend $vg "$dev4"
+aux disable_dev "$dev1"
 lvchange --partial -a y $vg/mirror
 
 not vgreduce -v --removemissing $vg
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
-aux enable_dev $dev1
-vgextend $vg $dev1
-aux disable_dev $dev2
+aux enable_dev "$dev1"
+vgextend $vg "$dev1"
+aux disable_dev "$dev2"
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
-aux enable_dev $dev2
-vgextend $vg $dev2
-aux disable_dev $dev3
+aux enable_dev "$dev2"
+vgextend $vg "$dev2"
+aux disable_dev "$dev3"
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
-aux enable_dev $dev3
-vgextend $vg $dev3
+aux enable_dev "$dev3"
+vgextend $vg "$dev3"
 vgremove -ff $vg
--- LVM2/test/shell/lvconvert-twostep.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-twostep.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,13 +14,13 @@
 aux prepare_vg 4
 
 lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
-not lvconvert -m 2 --mirrorlog core $vg/mirror $dev3 2>&1 | tee errs
+not lvconvert -m 2 --mirrorlog core $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
-lvconvert -m 2 $vg/mirror $dev3
+lvconvert -m 2 $vg/mirror "$dev3"
 lvconvert --mirrorlog core $vg/mirror
-not lvconvert -m 1 --mirrorlog disk $vg/mirror $dev3 2>&1 | tee errs
+not lvconvert -m 1 --mirrorlog disk $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
-not lvconvert -m 1 --mirrorlog mirrored $vg/mirror $dev3 $dev4 2>&1 | tee errs
+not lvconvert -m 1 --mirrorlog mirrored $vg/mirror "$dev3" "$dev4" 2>&1 | tee errs
 grep "two steps" errs
--- LVM2/test/shell/lvcreate-mirror.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-mirror.sh	2012/03/16 13:00:06	1.2
@@ -15,27 +15,27 @@
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 2-way mirror with corelog, 2 PVs
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 check mirror_images_redundant $vg $lv1
 lvremove -ff $vg
 
 # 2-way mirror with disklog, 3 PVs
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg $lv1 $dev3
+check mirror_log_on $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # 3-way mirror with disklog, 4 PVs
-lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3":0-1
 check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg $lv1 $dev3
+check mirror_log_on $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # lvcreate --nosync is in 100% sync after creation (bz429342)
-lvcreate -l2 -m1 --nosync -n $lv1 $vg $dev1 $dev2 $dev3:0-1 2>out
+lvcreate -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1 2>out
 grep "New mirror won't be synchronised." out
 lvs -o copy_percent --noheadings $vg/$lv1 | grep 100.00
 lvremove -ff $vg
 
 # creating 2-way mirror with disklog from 2 PVs fails
-not lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2
+not lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2"
--- LVM2/test/shell/lvcreate-operation.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-operation.sh	2012/03/16 13:00:06	1.2
@@ -22,22 +22,22 @@
 }
 
 aux prepare_pvs 2
-aux pvcreate --metadatacopies 0 $dev1
+aux pvcreate --metadatacopies 0 "$dev1"
 aux vgcreate -c n $vg $(cat DEVICES)
 
 # ---
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
-lvcreate -n$lv1 -l4 $vg $dev1
+lvcreate -n$lv1 -l4 $vg "$dev1"
 lvcreate -n$lv2 -l4 -s $vg/$lv1
 lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
 cleanup_lvs
 
 # ---
 # Create mirror on two devices with mirrored log using --alloc anywhere
-lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1 $dev2
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
 cleanup_lvs
 
 # --
 # Create mirror on one dev with mirrored log using --alloc anywhere, should fail
-not lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
+not lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
 cleanup_lvs
--- LVM2/test/shell/lvcreate-pvtags.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-pvtags.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -15,7 +16,7 @@
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # not required, just testing
-aux pvcreate --metadatacopies 0 $dev1
+aux pvcreate --metadatacopies 0 "$dev1"
 
 vgcreate -c n $vg $(cat DEVICES)
 pvchange --addtag fast $(cat DEVICES)
@@ -42,6 +43,6 @@
 not lvcreate -l1 -m3 --corelog $vg @fast
 
 # lvcreate mirror with a single PV arg
-not lvcreate -l1 -m1 --corelog $vg $dev1
+not lvcreate -l1 -m1 --corelog $vg "$dev1"
 
 vgremove -ff $vg
--- LVM2/test/shell/lvcreate-raid.sh	2012/03/04 16:02:19	1.2
+++ LVM2/test/shell/lvcreate-raid.sh	2012/03/16 13:00:06	1.3
@@ -1,5 +1,4 @@
-#!/bin/bash
-
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -15,13 +14,11 @@
 # is_raid_in_sync <VG/LV>
 function is_raid_in_sync()
 {
-	local dm_name
+	local dm_name=$(echo $1 | sed s:-:--: | sed s:/:-:)
 	local a
 	local b
 	local idx
 
-	dm_name=`echo $1 | sed s:-:--: | sed s:/:-:`
-
 	if ! a=(`dmsetup status $dm_name`); then
 		echo "Unable to get sync status of $1"
 		exit 1
--- LVM2/test/shell/lvcreate-repair.sh	2012/02/23 23:58:42	1.4
+++ LVM2/test/shell/lvcreate-repair.sh	2012/03/16 13:00:06	1.5
@@ -1,5 +1,5 @@
-#!/bin/bash
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,39 +14,38 @@
 aux prepare_vg 3
 
 # fail multiple devices
-for i in $dev1 $dev2 $dev3 ; do
-	for j in $dev2 $dev3 ; do
-
-		if test $i = $j ; then continue ; fi
+for i in "$dev1" "$dev2" "$dev3" ; do
+	for j in "$dev2" "$dev3" ; do
+		if test "$i" = "$j" ; then continue ; fi
 
 		vgremove -ff $vg
-		vgcreate $vg $dev1 $dev2 $dev3
+		vgcreate $vg "$dev1" "$dev2" "$dev3"
 		# exit 1
 
-		lvcreate -l1 -n $lv1 $vg $dev1
+		lvcreate -l1 -n $lv1 $vg "$dev1"
 
-		aux disable_dev $i $j
+		aux disable_dev "$i" "$j"
 
 		vgreduce --removemissing --force $vg
 
 		# check if reduced device was removed
-		test $i = $dev1 && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
+		test "$i" = "$dev1" && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
 
 		lvcreate -l1 -n $lv2 $vg
 
-		test $i != $dev1 && check lv_exists $vg $lv1
+		test "$i" != "$dev1" && check lv_exists $vg $lv1
 		check lv_exists $vg $lv2
 
-		aux enable_dev $i $j
+		aux enable_dev "$i" "$j"
 		vgscan
 
-		test $i != $dev1 && check lv_exists $vg $lv1
+		test "$i" != "$dev1" && check lv_exists $vg $lv1
 		check lv_exists $vg $lv2
 	done
 done
 
 vgremove -ff $vg
-vgcreate $vg $dev1 $dev2 $dev3
+vgcreate $vg "$dev1" "$dev2" "$dev3"
 
 # use tricky 'dd'
 for i in "$dev1" "$dev2" "$dev3" ; do
@@ -57,7 +56,7 @@
 		dd if="$i" of=backup_i bs=256K count=1
 		dd if="$j" of=backup_j bs=256K count=1
 
-		lvcreate -l1 -n $lv1 $vg $dev1
+		lvcreate -l1 -n $lv1 $vg "$dev1"
 
 		dd if=backup_j of="$j" bs=256K count=1
 		dd if=backup_i of="$i" bs=256K count=1
@@ -73,7 +72,7 @@
 dd if="$dev1" of=backup_i bs=256K count=1
 dd if="$dev2" of=backup_j bs=256K count=1
 
-lvcreate -l1 $vg $dev1
+lvcreate -l1 $vg "$dev1"
 
 dd if=backup_j of="$dev2" bs=256K count=1
 dd if=backup_i of="$dev1" bs=256K count=1
@@ -86,7 +85,7 @@
 
 # dirty game
 dd if=/dev/zero of="$dev3" bs=256K count=1
-aux notify_lvmetad $dev3 # udev be watching you
+aux notify_lvmetad "$dev3" # udev be watching you
 
 vgreduce --removemissing --force $vg
 
@@ -97,4 +96,4 @@
 # device-mapper: create ioctl failed: Device or resource busy
 # Failed to activate new LV.
 
-should lvcreate -l1 $vg $dev1
+should lvcreate -l1 $vg "$dev1"
--- LVM2/test/shell/lvcreate-small-snap.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-small-snap.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvcreate-thin.sh	2012/03/04 16:04:52	1.3
+++ LVM2/test/shell/lvcreate-thin.sh	2012/03/16 13:00:06	1.4
@@ -15,13 +15,6 @@
 
 . lib/test
 
-check_lv_exists_()
-{
-	for d in $*; do
-		check lv_exists $vg $d
-	done
-}
-
 check_lv_field_modules_()
 {
 	mod=$1
@@ -87,7 +80,7 @@
 lvcreate -L4M -V2G --type thin --thinpool $vg/pool5
 lvcreate -L4M -V2G --type thin --thinpool pool6 $vg
 
-check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+check lv_exists $vg lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
 lvremove -ff $vg
 
 
@@ -99,7 +92,7 @@
 lvcreate -L4M -V2G -T --thinpool pool5 --name lv5 $vg
 lvcreate -L4M -V2G -T --thinpool pool6 --name $vg/lv6 $vg
 
-check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
+check lv_exists $vg lv1 lv2 lv3 lv4 lv5 lv6
 lvremove -ff $vg
 
 
@@ -110,7 +103,7 @@
 lvcreate -L4M -V2G --type thin --thinpool pool5 --name lv5 $vg
 lvcreate -L4M -V2G --type thin --thinpool pool6 --name $vg/lv6 $vg
 
-check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
+check lv_exists $vg lv1 lv2 lv3 lv4 lv5 lv6
 lvremove -ff $vg
 
 
@@ -123,7 +116,7 @@
 lvcreate -V2G --type thin --thinpool $vg/pool
 lvcreate -V2G --type thin --thinpool pool $vg
 
-check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
+check lv_exists $vg lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
 
 
 # Create named thin LV in existing pool
@@ -140,7 +133,7 @@
 lvcreate -V2G --type thin --thinpool pool --name lv11 $vg
 lvcreate -V2G --type thin --thinpool pool --name $vg/lv12 $vg
 
-check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6 lv7 lv8 lv9 lv10 lv11 lv12
+check lv_exists $vg lv1 lv2 lv3 lv4 lv5 lv6 lv7 lv8 lv9 lv10 lv11 lv12
 check vg_field $vg lv_count 19
 
 lvremove -ff $vg
@@ -181,6 +174,8 @@
 not lvcreate --chunksize 256 -l1 -T $vg/pool1
 # Too small chunk size (min is 64KB -  128 sectors)
 not lvcreate --chunksize 32 -l1 -T $vg/pool1
+# Too large chunk size (max is 1GB)
+not lvcreate -L4M --chunksize 2G -T $vg/pool1
 
 lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
@@ -188,29 +183,30 @@
 vgremove -ff $vg
 
 
-# Test --poolmetadatasize
+# Test --poolmetadatasize range
 # allocating large devices for testing
 aux teardown_devs
-aux prepare_pvs 7 16500
+aux prepare_pvs 10 16500
 vgcreate $clustered $vg -s 64K $(cat DEVICES)
 
-lvcreate -L4M --chunksize 128 -T $vg/pool
 lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
 grep "WARNING: Minimum" out
 # FIXME: metadata allocation fails, if PV doesn't have at least 16GB
 # i.e. pool metadata device cannot be multisegment
-lvcreate -L4M --chunksize 128 --poolmetadatasize 17G -T $vg/pool2 2>out
+lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
 grep "WARNING: Maximum" out
-check lv_field $vg/pool_tmeta size  "2.00m"
 check lv_field $vg/pool1_tmeta size "2.00m"
 check lv_field $vg/pool2_tmeta size "16.00g"
 lvremove -ff $vg
 
-# check automatic calculation of poolmetadatasize
-lvcreate -L10G --chunksize 128 -T $vg/pool
+# Test automatic calculation of pool metadata size
+lvcreate -L160G -T $vg/pool
+check lv_field $vg/pool lv_metadata_size "80.00m"
+check lv_field $vg/pool chunksize        "128.00k"
+lvremove -ff $vg/pool
+
 lvcreate -L10G --chunksize 256 -T $vg/pool1
 lvcreate -L60G --chunksize 1024 -T $vg/pool2
-check lv_field $vg/pool_tmeta size  "5.00m"
 check lv_field $vg/pool1_tmeta size "2.50m"
 check lv_field $vg/pool2_tmeta size "3.75m"
 vgremove -ff $vg
--- LVM2/test/shell/lvcreate-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_pvs 4
-aux pvcreate --metadatacopies 0 $dev1
+aux pvcreate --metadatacopies 0 "$dev1"
 vgcreate -cn $vg $(cat DEVICES)
 
 # "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
@@ -26,34 +26,34 @@
 
 # "lvcreate rejects a negative stripe_size"
 not lvcreate -L 64m -n $lv -i2 --stripesize -4 $vg 2>err;
-grep "^  Negative stripesize is invalid\$" err
+grep "Negative stripesize is invalid" err
 
 # 'lvcreate rejects a too-large stripesize'
 not lvcreate -L 64m -n $lv -i2 --stripesize 4294967291 $vg 2>err
-grep "^  Stripe size cannot be larger than" err
+grep "Stripe size cannot be larger than" err
 
 # 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
 lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg 2> err | tee out
-grep "^  Ignoring stripesize argument with single stripe\$" out 
+grep "Ignoring stripesize argument with single stripe" out
 lvdisplay $vg 
 lvremove -ff $vg
 
 # 'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout'
 lvcreate -L 64m -n $lv -i2 $vg > out
-grep "^  Using default stripesize" out 
+grep "Using default stripesize" out
 lvdisplay $vg 
 check lv_field $vg/$lv stripesize "64.00k"
 lvremove -ff $vg
 
 # 'lvcreate rejects an invalid number of stripes' 
 not lvcreate -L 64m -n $lv -i129 $vg 2>err
-grep "^  Number of stripes (129) must be between 1 and 128\$" err
+grep "Number of stripes (129) must be between 1 and 128" err
 
 # The case on lvdisplay output is to verify that the LV was not created.
 # 'lvcreate rejects an invalid stripe size'
 not lvcreate -L 64m -n $lv -i2 --stripesize 3 $vg 2>err
-grep "^  Invalid stripe size" err
-case $(lvdisplay $vg) in "") true ;; *) false ;; esac
+grep "Invalid stripe size" err
+test -z "$(lvdisplay $vg)"
 
 # Setting max_lv works. (bz490298)
 lvremove -ff $vg
@@ -70,8 +70,7 @@
 
 lvremove -ff $vg/$lv3
 lvcreate -l1 -m1 -n $lv3 $vg
-lvs
-vgs -o +max_lv
+vgs -o +max_lv $vg
 not lvcreate -l1 -n $lv4 $vg
 not lvcreate -l1 -m1 -n $lv4 $vg
 
@@ -94,11 +93,11 @@
 not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
 not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
 lvcreate -L 8m -n $lv2 -s --chunksize 4k $vg/$lv1
-check lv_field $vg/$lv2 chunk_size 4.00k
-check lv_field $vg/$lv2 origin_size 32.00m
+check lv_field $vg/$lv2 chunk_size "4.00k"
+check lv_field $vg/$lv2 origin_size "32.00m"
 lvcreate -L 8m -n $lv3 -s --chunksize 512k $vg/$lv1
-check lv_field $vg/$lv3 chunk_size 512.00k
-check lv_field $vg/$lv3 origin_size 32.00m
+check lv_field $vg/$lv3 chunk_size "512.00k"
+check lv_field $vg/$lv3 origin_size "32.00m"
 lvremove -ff $vg
 vgchange -l 0 $vg
 
@@ -149,4 +148,3 @@
 check lv_field $vg/$lv lv_read_ahead "auto"
 check lv_field $vg/$lv lv_kernel_read_ahead "512.00k"
 lvremove -ff $vg
-
--- LVM2/test/shell/lvextend-percent-extents.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvextend-percent-extents.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -19,34 +19,34 @@
 
 # 'lvextend rejects both size and extents without PVs'
 not lvextend -l 10 -L 64m $vg/$lv 2>err
-grep "^  Please specify either size or extents but not both.\$" err
+grep "Please specify either size or extents but not both." err
 
 # 'lvextend rejects both size and extents with PVs'
-not lvextend -l 10 -L 64m $vg/$lv $dev1 2>err
-grep "^  Please specify either size or extents but not both.\$" err
+not lvextend -l 10 -L 64m $vg/$lv "$dev1" 2>err
+grep "Please specify either size or extents but not both." err
 
 # 'lvextend accepts no size or extents but one PV - bz154691'
-lvextend $vg/$lv $dev1 >out
-grep "^  Logical volume $lv successfully resized\$" out
-check pv_field $dev1 pv_free "0"
+lvextend $vg/$lv "$dev1" >out
+grep "Logical volume $lv successfully resized" out
+check pv_field "$dev1" pv_free "0"
 
-lvremove -f $vg/$lv 
+lvremove -f $vg/$lv
 
 # 'lvextend computes necessary free space correctly - bz213552'
-vgsize=$(vgs -o vg_extent_count --noheadings)
+vgsize=$(get vg_field $vg vg_extent_count)
 lvcreate -l $vgsize  -n $lv $vg
 lvreduce -f -l $(( $vgsize / 2 )) $vg/$lv
 lvextend -l $vgsize $vg/$lv
 
-# 'Reset LV to original size' 
-lvremove -f $vg/$lv 
+# 'Reset LV to original size'
+lvremove -f $vg/$lv
 lvcreate -L 64m -n $lv $vg
 
 # 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
-lvextend -l +100%PVS $vg/$lv $dev1 $dev2 >out
-grep "^  Logical volume $lv successfully resized\$" out 
-check pv_field $dev1 pv_free "0" 
-check pv_field $dev2 pv_free "0"
+lvextend -l +100%PVS $vg/$lv "$dev1" "$dev2" >out
+grep "Logical volume $lv successfully resized" out
+check pv_field "$dev1" pv_free "0"
+check pv_field "$dev2" pv_free "0"
 
 # Exercise the range overlap code.  Allocate every 2 extents.
 #
@@ -68,16 +68,16 @@
 # Total number of extents should be 12 + overlap = 12 + 6 = 18.
 # Thus, total size for the LV should be 18 * 4M = 72M
 #
-# 'Reset LV to 12 extents, allocate every other 2 extents' 
-create_pvs=`for i in $(seq 0 4 20); do echo -n "\$dev1:$i-$(($i + 1)) "; done` 
+# 'Reset LV to 12 extents, allocate every other 2 extents'
+create_pvs=$(for i in $(seq 0 4 20); do echo -n "$dev1:$i-$(($i + 1)) "; done)
 lvremove -f $vg/$lv
 lvcreate -l 12 -n $lv $vg $create_pvs
 check lv_field $vg/$lv lv_size "48.00m"
 
-# 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' 
-extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$dev1:$i-$(($i + 2)) "; done` 
+# 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges'
+extend_pvs=$(for i in $(seq 0 6 18); do echo -n "$dev1:$i-$(($i + 2)) "; done)
 lvextend -l +100%PVS $vg/$lv $extend_pvs >out
-grep "^  Logical volume $lv successfully resized\$" out 
+grep "Logical volume $lv successfully resized" out
 check lv_field $vg/$lv lv_size "72.00m"
 
 # Simple seg_count validation; initially create the LV with half the # of
@@ -85,19 +85,19 @@
 # then reduce (should be back to 1)
 # FIXME: test other segment fields such as seg_size, pvseg_start, pvseg_size
 lvremove -f $vg/$lv
-pe_count=$(pvs -o pv_pe_count --noheadings $dev1)
+pe_count=$(get pv_field "$dev1" pv_pe_count)
 pe1=$(( $pe_count / 2 ))
 lvcreate -l $pe1 -n $lv $vg
-pesize=$(lvs -ovg_extent_size --units b --nosuffix --noheadings $vg/$lv)
+pesize=$(get lv_field $vg/$lv vg_extent_size --units b --nosuffix)
 segsize=$(( $pe1 * $pesize / 1024 / 1024 ))m
-check lv_field $vg/$lv seg_count 1
-check lv_field $vg/$lv seg_start 0
-check lv_field $vg/$lv seg_start_pe 0
+check lv_field $vg/$lv seg_count "1"
+check lv_field $vg/$lv seg_start "0"
+check lv_field $vg/$lv seg_start_pe "0"
 #check lv_field $vg/$lv seg_size $segsize
 lvextend -l +$(( $pe_count * 1 )) $vg/$lv
-check lv_field $vg/$lv seg_count 2
+check lv_field $vg/$lv seg_count "2"
 lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
-check lv_field $vg/$lv seg_count 1
+check lv_field $vg/$lv seg_count "1"
 
 # do not reduce to 0 extents
 lvremove -f $vg/$lv
--- LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2012/03/04 16:02:19	1.4
+++ LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2012/03/16 13:00:06	1.5
@@ -1,5 +1,5 @@
-#!/bin/bash
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,48 +15,47 @@
 	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
 }
 
-write() {
-	mount $DM_DEV_DIR/$vg/snap mnt
-	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
-	umount mnt
+write_() {
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap" bs=1k count=$2 seek=$1
 }
 
-percent() {
-	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+percent_() {
+	get lv_field $vg/snap snap_percent | cut -d. -f1
 }
 
-which mkfs.ext2 || skip
+wait_for_change_() {
+	# dmeventd only checks every 10 seconds :(
+	for i in $(seq 1 15) ; do
+		test "$(percent_)" != "$1" && return
+		sleep 1
+	done
+
+	return 1  # timeout
+}
 
-aux prepare_vg 3
 aux prepare_dmeventd
+aux prepare_vg 2
 
-lvcreate -l 8 -n base $vg
-mkfs.ext2 $DM_DEV_DIR/$vg/base
+lvcreate -L16M -n base $vg
+lvcreate -s -L4M -n snap $vg/base
 
-lvcreate -s -l 4 -n snap $vg/base
-lvchange --monitor y $vg/snap
+write_ 0 1000
+test 24 -eq $(percent_)
 
-mkdir mnt
+lvchange --monitor y $vg/snap
 
-write 1 4096
-pre=`percent`
-sleep 15 # dmeventd only checks every 10 seconds :(
-post=`percent`
-
-test $pre = $post
-
-write 2 5000
-pre=`percent`
-sleep 15 # dmeventd only checks every 10 seconds :(
-post=`percent`
-test $pre -gt $post
+write_ 1000 1700
+pre=$(percent_)
+wait_for_change_ $pre
+test $pre -gt $(percent_)
 
 # check that a second extension happens; we used to fail to extend when the
 # utilisation ended up between THRESH and (THRESH + 10)... see RHBZ 754198
 # (the utilisation after the write should be 57 %)
 
-write 3 5000
-pre=`percent`
-sleep 15 # dmeventd only checks every 10 seconds :(
-post=`percent`
-test $pre -gt $post
+write_ 2700 2000
+pre=$(percent_)
+wait_for_change_ $pre
+test $pre -gt $(percent_)
+
+vgremove -f $vg
--- LVM2/test/shell/lvextend-snapshot-policy.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvextend-snapshot-policy.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,37 +11,39 @@
 
 . lib/test
 
+which mkfs.ext2 || skip
+
 extend() {
 	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
 }
 
 write() {
-	mount $DM_DEV_DIR/$vg/snap mnt
-	dd if=/dev/zero of=mnt/file$1 bs=1k count=$2
+	mount "$DM_DEV_DIR/$vg/snap" mnt
+	dd if=/dev/zero of="mnt/file$1" bs=1k count=$2
 	umount mnt
 }
 
 percent() {
-	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
+	get lv_field $vg/snap snap_percent | cut -d. -f1
 }
 
-which mkfs.ext2 || exit 200
-
+aux prepare_dmeventd
 aux prepare_vg 2
+
 lvcreate -l 8 -n base $vg
-mkfs.ext2 $DM_DEV_DIR/$vg/base
+mkfs.ext2 "$DM_DEV_DIR/$vg/base"
 
 lvcreate -s -l 4 -n snap $vg/base
 mkdir mnt
 
 write 1 4096
-pre=`percent`
+pre=$(percent)
 extend 50
-post=`percent`
+test $pre -eq $(percent)
 
-test $pre = $post
 write 2 4096
-pre=`percent`
+pre=$(percent)
 extend 50
-post=`percent`
-test $pre -gt $post
+test $pre -gt $(percent)
+
+vgremove -f $vg
--- LVM2/test/shell/lvm-init.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvm-init.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -18,4 +19,3 @@
 
 # invalid units
 not pvs --config 'global { units = "<" }'
-
--- LVM2/test/shell/lvmcache-exercise.sh	2012/02/23 14:21:18	1.3
+++ LVM2/test/shell/lvmcache-exercise.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -12,11 +13,11 @@
 
 aux prepare_pvs 5
 
-vgcreate $vg1 $dev1
-vgcreate $vg2 $dev3
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev3"
 
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 pvscan
-vgcreate $vg1 $dev2
-aux enable_dev $dev1
+vgcreate $vg1 "$dev2"
+aux enable_dev "$dev1"
 pvs
--- LVM2/test/shell/lvmetad-pvs.sh	2012/03/01 20:03:45	1.1
+++ LVM2/test/shell/lvmetad-pvs.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,10 +11,9 @@
 
 . lib/test
 
-aux prepare_devs 1 20000
-pvcreate $dev1
-pvs | grep $dev1
+aux prepare_pvs 1 20000
+pvs $(cat DEVICES) | grep "$dev1"
 
 # check for PV size overflows
-pvs | grep 19.53g
-pvs | not grep 16.00e
+pvs $(cat DEVICES) | grep 19.53g
+pvs $(cat DEVICES) | not grep 16.00e
--- LVM2/test/shell/lvresize-mirror.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvresize-mirror.sh	2012/03/16 13:00:06	1.2
@@ -10,29 +10,30 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/test
+
 aux prepare_vg 5 80
 
 # extend 2-way mirror
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 lvchange -an $vg/$lv1
 lvextend -l+2 $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_images_contiguous $vg $lv1
 lvremove -ff $vg
 
 # reduce 2-way mirror
-lvcreate -l4 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l4 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 lvchange -an $vg/$lv1
 lvreduce -l-2 $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # extend 2-way mirror (cling if not contiguous)
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
-lvcreate -l1 -n $lv2 $vg $dev1
-lvcreate -l1 -n $lv3 $vg $dev2
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+lvcreate -l1 -n $lv2 $vg "$dev1"
+lvcreate -l1 -n $lv3 $vg "$dev2"
 lvchange -an $vg/$lv1
 lvextend -l+2 $vg/$lv1
-check mirror $vg $lv1 $dev3
+check mirror $vg $lv1 "$dev3"
 check mirror_images_clung $vg $lv1
 lvremove -ff $vg
--- LVM2/test/shell/lvresize-rounding.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvresize-rounding.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/lvresize-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvresize-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/mdata-strings.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/mdata-strings.sh	2012/03/16 13:00:06	1.2
@@ -18,22 +18,20 @@
 # for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
 
-# 'set up temp files, loopback devices' 
+# 'set up temp files, loopback devices'
 name=$(basename "$dev1")
 dmsetup rename "$name" "$PREFIX$pv_ugly"
-dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
+dev1=$(dirname "$dev1")/"$PREFIX$pv_ugly"
 
 dmsetup table | grep -F "$pv_ugly"
 
-# 'pvcreate, vgcreate on filename with backslashed chars' 
-created=$dev1
+# 'pvcreate, vgcreate on filename with backslashed chars'
+created="$dev1"
 # when used with real udev without fallback, it will fail here
-pvcreate "$dev1" || created=$dev2
+pvcreate "$dev1" || created="$dev2"
 pvdisplay | should grep -F "$pv_ugly"
 should check pv_field "$dev1" pv_name "$dev1"
 vgcreate $vg "$created"
-# 'no parse errors and VG really exists' 
-vgs 2>err
-not grep "Parse error" err;
-vgs $vg
-
+# 'no parse errors and VG really exists'
+vgs $vg 2>err
+not grep "Parse error" err
--- LVM2/test/shell/metadata-balance.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/metadata-balance.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -15,24 +16,24 @@
 echo Make sure we can ignore / un-ignore mdas on a per-PV basis
 for pv_in_vg in 1 0; do
 for mdacp in 1 2; do
-	pvcreate --metadatacopies $mdacp $dev1 $dev2
-        pvcreate --metadatacopies 0 $dev3
+	pvcreate --metadatacopies $mdacp "$dev1" "$dev2"
+        pvcreate --metadatacopies 0 "$dev3"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate -c n "$vg" $dev1 $dev2 $dev3
+		vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
 	fi
-	pvchange --metadataignore y $dev1
-	check pv_field $dev1 pv_mda_count $mdacp
-	check pv_field $dev1 pv_mda_used_count 0
-	check pv_field $dev2 pv_mda_count $mdacp
-	check pv_field $dev2 pv_mda_used_count $mdacp
+	pvchange --metadataignore y "$dev1"
+	check pv_field "$dev1" pv_mda_count $mdacp
+	check pv_field "$dev1" pv_mda_used_count 0
+	check pv_field "$dev2" pv_mda_count $mdacp
+	check pv_field "$dev2" pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
 		check vg_field $vg vg_mda_count $(($mdacp * 2))
 		check vg_field $vg vg_mda_used_count $mdacp
 		check vg_field $vg vg_mda_copies unmanaged
 	fi
-	pvchange --metadataignore n $dev1
-	check pv_field $dev1 pv_mda_count $mdacp
-	check pv_field $dev1 pv_mda_used_count $mdacp
+	pvchange --metadataignore n "$dev1"
+	check pv_field "$dev1" pv_mda_count $mdacp
+	check pv_field "$dev1" pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
 		check vg_field $vg vg_mda_count $(($mdacp * 2))
 		check vg_field $vg vg_mda_used_count $(($mdacp * 2))
@@ -61,13 +62,13 @@
 
 echo Test of vgmetadatacopies with vgcreate and vgchange
 for mdacp in 1 2; do
-	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
-	check pv_field $dev1 pv_mda_used_count $mdacp
-	check pv_field $dev2 pv_mda_used_count $mdacp
-	check pv_field $dev4 pv_mda_used_count $mdacp
-	check pv_field $dev5 pv_mda_used_count $mdacp
-	pvcreate --metadatacopies 0 $dev3
-	vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
+	check pv_field "$dev1" pv_mda_used_count $mdacp
+	check pv_field "$dev2" pv_mda_used_count $mdacp
+	check pv_field "$dev4" pv_mda_used_count $mdacp
+	check pv_field "$dev5" pv_mda_used_count $mdacp
+	pvcreate --metadatacopies 0 "$dev3"
+	vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies unmanaged
 	echo ensure both --vgmetadatacopies and --metadatacopies accepted
 	vgchange --metadatacopies $(($mdacp * 1)) $vg
@@ -87,33 +88,33 @@
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds even when creating a VG w/all ignored mdas
-	pvchange --metadataignore y $dev1 $dev2
-	check pv_field $dev1 pv_mda_count $mdacp
-	check pv_field $dev2 pv_mda_used_count 0
-	vgcreate -c n "$vg" $dev1 $dev2
+	pvchange --metadataignore y "$dev1" "$dev2"
+	check pv_field "$dev1" pv_mda_count $mdacp
+	check pv_field "$dev2" pv_mda_used_count 0
+	vgcreate -c n $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds with a specific number of metadata copies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) "$vg" $dev1 $dev2
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 2))
 	vgremove -f $vg
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	vgremove -f $vg
 	echo vgcreate succeeds with a larger value than total metadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	vgremove -f $vg
 	echo vgcreate succeeds with --vgmetadatacopies unmanaged
-	vgcreate -c n --vgmetadatacopies unmanaged "$vg" $dev1 $dev2
+	vgcreate -c n --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	pvunignore_ $dev1
-	pvunignore_ $dev2
-	pvunignore_ $dev4
-	pvunignore_ $dev5
+	pvunignore_ "$dev1"
+	pvunignore_ "$dev2"
+	pvunignore_ "$dev4"
+	pvunignore_ "$dev5"
 	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
-	vgcreate -c n --vgmetadatacopies 1 "$vg" $dev1 $dev2 $dev4 $dev5
+	vgcreate -c n --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies 1
 	check vg_field $vg vg_mda_count $(($mdacp * 4))
 	check vg_field $vg vg_mda_used_count 1
@@ -130,103 +131,102 @@
 	vgchange --vgmetadatacopies 0 $vg
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2 $dev4 $dev5
+	vgcreate -c n --vgmetadatacopies 0 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 done
 
 echo Test vgextend / vgreduce with vgmetadatacopies
 for mdacp in 1 2; do
-	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
-	pvcreate --metadatacopies 0 $dev3
+	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
+	pvcreate --metadatacopies 0 "$dev3"
 	echo Set a large value of vgmetadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2 $dev3
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Large value of vgetadatacopies should automatically un-ignore mdas
-	pvchange --metadataignore y $dev4 $dev5
-	check pv_field $dev4 pv_mda_used_count 0
-	vgextend $vg $dev4 $dev5
-	check pv_field $dev4 pv_mda_used_count $mdacp
-	check pv_field $dev5 pv_mda_used_count $mdacp
+	pvchange --metadataignore y "$dev4" "$dev5"
+	check pv_field "$dev4" pv_mda_used_count 0
+	vgextend $vg "$dev4" "$dev5"
+	check pv_field "$dev4" pv_mda_used_count $mdacp
+	check pv_field "$dev5" pv_mda_used_count $mdacp
 	vgremove -f $vg
 	echo Set a small value of vgmetadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2 $dev3
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Small value of vgetadatacopies should leave mdas as ignored
-	pvchange --metadataignore y $dev4 $dev5
-	check pv_field $dev4 pv_mda_used_count 0
-	vgextend $vg $dev4 $dev5
-	check pv_field $dev4 pv_mda_used_count 0
-	check pv_field $dev5 pv_mda_used_count 0
+	pvchange --metadataignore y "$dev4" "$dev5"
+	check pv_field "$dev4" pv_mda_used_count 0
+	vgextend $vg "$dev4" "$dev5"
+	check pv_field "$dev4" pv_mda_used_count 0
+	check pv_field "$dev5" pv_mda_used_count 0
 	echo vgreduce of ignored pv w/mda should not trigger any change to ignore bits
-	vgreduce $vg $dev4
-	check pv_field $dev4 pv_mda_used_count 0
-	check pv_field $dev5 pv_mda_used_count 0
+	vgreduce $vg "$dev4"
+	check pv_field "$dev4" pv_mda_used_count 0
+	check pv_field "$dev5" pv_mda_used_count 0
 	echo vgreduce of un-ignored pv w/mda should trigger un-ignore on an mda
-	vgreduce $vg $dev1 $dev2 $dev3
-	check pv_field $dev5 pv_mda_used_count $mdacp
+	vgreduce $vg "$dev1" "$dev2" "$dev3"
+	check pv_field "$dev5" pv_mda_used_count $mdacp
 	check vg_field $vg vg_mda_copies $(($mdacp * 1))
-	pvunignore_ $dev1
-	pvunignore_ $dev2
+	pvunignore_ "$dev1"
+	pvunignore_ "$dev2"
 	echo setting vgmetadatacopies to unmanaged should allow vgextend to add w/out balancing
 	vgchange --vgmetadatacopies unmanaged $vg
-	vgextend $vg $dev1 $dev2
+	vgextend $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	check vg_field $vg vg_mda_count $(($mdacp * 3))
 	check vg_field $vg vg_mda_used_count $((mdacp * 3))
-	check pv_field $dev1 pv_mda_used_count $mdacp
-	check pv_field $dev2 pv_mda_used_count $mdacp
+	check pv_field "$dev1" pv_mda_used_count $mdacp
+	check pv_field "$dev2" pv_mda_used_count $mdacp
 	vgremove -f $vg
 done
 
 echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
-	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
-	vgcreate -c n --vgmetadatacopies 2 $vg1 $dev1 $dev2 $dev3
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 $dev4 $dev5
+	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	vgcreate -c n --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
-	vgsplit $vg1 $vg2 $dev1
+	vgsplit $vg1 $vg2 "$dev1"
 	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
 	vgmerge $vg1 $vg2
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg1 vg_mda_count $(($mdacp * 5))
 	echo vgsplit into new vg sets proper value of vgmetadatacopies
-	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 $dev1 $dev2
+	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 "$dev1" "$dev2"
 	check vg_field $vg2 vg_mda_copies $(($mdacp * 2))
 	echo vgchange fails if given both vgmetadatacopies and metadatacopies
 	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2
-	vgremove -f $vg1
-	vgremove -f $vg2
+	vgremove -f $vg1 $vg2
 done
 
 echo Test combination of --vgmetadatacopies and pvchange --metadataignore
 for mdacp in 1 2; do
-	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg1 $dev1 $dev2
+	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg1 "$dev1" "$dev2"
 	check vg_field $vg1 vg_mda_copies $(($mdacp * 1))
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
-	pvignore_ $dev3
+	pvignore_ "$dev3"
 	echo Ensure vgextend of PVs with ignored MDAs does not add to vg_mda_used_count
-	vgextend $vg1 $dev3
+	vgextend $vg1 "$dev3"
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
 	echo Using pvchange to unignore should update vg_mda_used_count
-	pvchange -f --metadataignore n $dev3
-	check pv_field $dev3 pv_mda_used_count $mdacp
+	pvchange -f --metadataignore n "$dev3"
+	check pv_field "$dev3" pv_mda_used_count $mdacp
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
 	echo Set unmanaged on the vg should keep ignore bits the same during vgextend
 	vgchange --vgmetadatacopies unmanaged $vg1
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
-	pvunignore_ $dev4
-	vgextend $vg1 $dev4
-	check pv_field $dev4 pv_mda_used_count $mdacp
+	pvunignore_ "$dev4"
+	vgextend $vg1 "$dev4"
+	check pv_field "$dev4" pv_mda_used_count $mdacp
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 3))
 	echo Using pvchange to ignore should update vg_mda_used_count
-	pvchange -f --metadataignore y $dev4
-	check pv_field $dev4 pv_mda_used_count 0
+	pvchange -f --metadataignore y "$dev4"
+	check pv_field "$dev4" pv_mda_used_count 0
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
 	vgremove -f $vg1
 done
--- LVM2/test/shell/metadata-dirs.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/metadata-dirs.sh	2012/03/16 13:00:06	1.2
@@ -12,32 +12,32 @@
 . lib/test
 
 aux prepare_devs 3
-pvcreate --metadatacopies 0 $(cat DEVICES)
 
+pvcreate --metadatacopies 0 $(cat DEVICES)
 not vgcreate $vg $(cat DEVICES)
 
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
 
-vgcreate $vg $dev1
+vgcreate $vg "$dev1"
 check vg_field $vg vg_mda_count 1
 vgremove -ff $vg
 
 vgcreate $vg $(cat DEVICES)
 check vg_field $vg vg_mda_count 1
-
 vgremove -ff $vg
-pvcreate --metadatacopies 1 --metadataignore y $dev1
+
+pvcreate --metadatacopies 1 --metadataignore y "$dev1"
 vgcreate $vg $(cat DEVICES)
 check vg_field $vg vg_mda_count 2
-
 vgremove -ff $vg
-pvcreate --metadatacopies 1 --metadataignore n $dev1
+
+pvcreate --metadatacopies 1 --metadataignore n "$dev1"
 vgcreate $vg $(cat DEVICES)
 check vg_field $vg vg_mda_count 2
-
 vgremove -ff $vg
-pvcreate --metadatacopies 0 $dev1
 
+pvcreate --metadatacopies 0 "$dev1"
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
 vgcreate $vg $(cat DEVICES)
 check vg_field $vg vg_mda_count 2
+vgremove -ff $vg
--- LVM2/test/shell/metadata.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/metadata.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -12,69 +13,64 @@
 
 aux prepare_devs 5
 
-pvcreate $dev1
-pvcreate --metadatacopies 0 $dev2
-pvcreate --metadatacopies 0 $dev3
-pvcreate $dev4
-pvcreate --metadatacopies 0 $dev5
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+pvcreate "$dev4"
+pvcreate --metadatacopies 0 "$dev5"
 
-vgcreate -c n "$vg" $(cat DEVICES)
+vgcreate -c n $vg $(cat DEVICES)
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
-pvchange -x n $dev1
-pvchange -x y $dev1
+pvchange -x n "$dev1"
+pvchange -x y "$dev1"
 vgchange -a n $vg
-pvchange --uuid $dev1
-pvchange --uuid $dev2
+pvchange --uuid "$dev1"
+pvchange --uuid "$dev2"
 vgremove -f $vg
 
 # check that PVs without metadata don't cause too many full device rescans (bz452606)
 for mdacp in 1 0; do
 	pvcreate --metadatacopies $mdacp $(cat DEVICES)
-	pvcreate $dev1
+	pvcreate "$dev1"
 	vgcreate -c n $vg $(cat DEVICES)
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -n $lv2 -m2 -l 2  $vg
-	#lvchange -an $vg
-	lvchange -an $vg/$lv1
-	lvchange -an $vg/$lv2
+	lvchange -an $vg/$lv1 $vg/$lv2
 	vgchange -ay $vg
-	lvchange -vvvv -an $vg/$lv1 >out$mdacp 2>&1 
-	lvchange -vvvv -an $vg/$lv2 >>out$mdacp 2>&1 
+	lvchange -an $vg/$lv1 $vg/$lv2
 	vgremove -f $vg
 done
 not grep "Cached VG .* incorrect PV list" out0
 
 # some M1 metadata tests
-pvcreate -M1 $dev1
-pvcreate -M1 $dev2
-pvcreate -M1 $dev3
-pv3_uuid=$(pvs --noheadings -o pv_uuid $dev3)
-vgcreate -M1 -c n $vg $dev1 $dev2 $dev3
-pvchange --uuid $dev1
+pvcreate -M1 "$dev1" "$dev2" "$dev3"
+pv3_uuid=$(get pv_field "$dev3" pv_uuid)
+vgcreate -M1 -c n $vg "$dev1" "$dev2" "$dev3"
+pvchange --uuid "$dev1"
 
 # verify pe_start of all M1 PVs
 pv_align="128.00k"
-check pv_field $dev1 pe_start $pv_align
-check pv_field $dev2 pe_start $pv_align
-check pv_field $dev3 pe_start $pv_align
+check pv_field "$dev1" pe_start $pv_align
+check pv_field "$dev2" pe_start $pv_align
+check pv_field "$dev3" pe_start $pv_align
 
-pvs --units k -o name,pe_start,vg_mda_size,vg_name
+pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
 
 # upgrade from v1 to v2 metadata
 vgconvert -M2 $vg
 
 # verify pe_start of all M2 PVs
-check pv_field $dev1 pe_start $pv_align
-check pv_field $dev2 pe_start $pv_align
-check pv_field $dev3 pe_start $pv_align
+check pv_field "$dev1" pe_start $pv_align
+check pv_field "$dev2" pe_start $pv_align
+check pv_field "$dev3" pe_start $pv_align
 
-pvs --units k -o name,pe_start,vg_mda_size,vg_name
+pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
 
 # create backup and then restore $dev3
 vgcfgbackup -f $TESTDIR/bak-%s $vg
-pvcreate -ff -y --restorefile $TESTDIR/bak-$vg --uuid $pv3_uuid $dev3
+pvcreate -ff -y --restorefile $TESTDIR/bak-$vg --uuid $pv3_uuid "$dev3"
 vgcfgrestore -f $TESTDIR/bak-$vg $vg
 
 # verify pe_start of $dev3
-check pv_field $dev3 pe_start $pv_align
+check pv_field "$dev3" pe_start $pv_align
--- LVM2/test/shell/mirror-names.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/mirror-names.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007-2008 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -18,134 +18,124 @@
 # Utilities
 
 lv_devices_() {
-  local d
-  local lv=$1
-  shift
-  local devices=$*
-
-  local devs=$(lvs -a -odevices --noheadings $lv | sed 's/([0-9]*)//g' |
-               sed 's/ //g' | sed 's/,/ /g')
-
-  for d in $devs; do
-    (echo $devices | grep $d >/dev/null)  || return 1
-    devices=$(echo $devices | sed "s/$d//")
-  done
+	local d
+	local lv=$1
+	shift
+	local devices=$@
+	local devs=$(get lv_field $lv devices -a | sed 's/([0-9]*)//g; s/ //g; s/,/ /g')
+
+	for d in $devs; do
+		(echo $devices | grep $d) || return 1
+		devices=$(echo $devices | sed "s/$d//")
+	done
 
-  [ "$(echo $devices | sed 's/ //g')" = "" ]
+	test -z "$(echo $devices | sed 's/ //g')"
 }
 
 lv_mirror_log_() {
-  local lv=$1
-
-  echo $(lvs -a -omirror_log --noheadings $lv | sed 's/ //g')
+	test $(get lv_field $1 mirror_log) = $2
 }
 
 lv_convert_lv_() {
-  local lv=$1
-
-  echo $(lvs -a -oconvert_lv --noheadings $lv | sed 's/ //g')
+	get lv_field $1 convert_lv
 }
 
 # ---------------------------------------------------------------------
-# Initialize PVs and VGs
-
-aux prepare_vg 5 80
-
-# ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
 prepare_lvs_() {
 	lvremove -ff $vg
-	if dmsetup table|grep $vg; then
+	(dmsetup table | not grep $vg) || {
 		echo "ERROR: lvremove did leave some some mappings in DM behind!"
 		return 1
-	fi
-  :
+	}
 }
 
 check_and_cleanup_lvs_() {
-  lvs -a -o+devices $vg 
-  lvremove -ff $vg
-	if dmsetup table|grep $vg; then
+	lvs -a -o+devices $vg
+	lvremove -ff $vg
+	(dmsetup table | not grep $vg) || {
 		echo "ERROR: lvremove did leave some some mappings in DM behind!"
 		return 1
-	fi
+	}
 }
 
-prepare_lvs_ 
+# ---------------------------------------------------------------------
+# Initialize PVs and VGs
+
+aux prepare_vg 5 80
+
+prepare_lvs_
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # basic
 
-#COMM "init: lvcreate" 
+#COMM "init: lvcreate"
 prepare_lvs_
 
 #COMM "mirror images are ${lv1}_mimage_x"
-lvcreate -l2 -m1 -n $lv1 $vg 
-lv_devices_ $vg/$lv1 "$lv1"_mimage_0 "$lv1"_mimage_1
+lvcreate -l2 -m1 -n $lv1 $vg
+lv_devices_ $vg/$lv1 ${lv1}_mimage_0 ${lv1}_mimage_1
 
 #COMM "mirror log is ${lv1}_mlog"
-lv_mirror_log_ $vg/$lv1 "$lv1"_mlog
+lv_mirror_log_ $vg/$lv1 ${lv1}_mlog
 
-# "cleanup" 
+# "cleanup"
 check_and_cleanup_lvs_
 
 #COMM "mirror with name longer than 22 characters (bz221322)"
 name="LVwithanamelogerthan22characters_butidontwonttocounthem"
-lvcreate -m1 -l2 -n"$name" $vg
-lvs $vg/"$name"
+lvcreate -m1 -l2 -n $name $vg
+lvs $vg/$name
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # lvrename
 
-#COMM "init: lvrename" 
+#COMM "init: lvrename"
 prepare_lvs_
 
-#COMM "renamed mirror names: $lv1 to $lv2" 
-lvcreate -l2 -m1 -n $lv1 $vg 
-lvrename $vg/$lv1 $vg/$lv2 
-lv_devices_ $vg/$lv2 "$lv2"_mimage_0 "$lv2"_mimage_1 
-lv_mirror_log_ $vg/$lv2 "$lv2"_mlog
+#COMM "renamed mirror names: $lv1 to $lv2"
+lvcreate -l2 -m1 -n $lv1 $vg
+lvrename $vg/$lv1 $vg/$lv2
+lv_devices_ $vg/$lv2 ${lv2}_mimage_0 ${lv2}_mimage_1
+lv_mirror_log_ $vg/$lv2 ${lv2}_mlog
 
-#COMM "cleanup" 
+#COMM "cleanup"
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # lvconvert
 
-#COMM "init: lvconvert" 
+#COMM "init: lvconvert"
 prepare_lvs_
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
-lvcreate -l2 -m1 -n $lv1 $vg 
+lvcreate -l2 -m1 -n $lv1 $vg
 lvconvert -m+1 -i+40 -b $vg/$lv1
-convlv=$(lv_convert_lv_ "$vg/$lv1") 
-test "$convlv" = "$lv1"_mimagetmp_2 
-lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
-lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
-loglv=$(lv_mirror_log_ "$vg/$convlv") 
-test "$loglv" = "$lv1"_mlog
+convlv=$(lv_convert_lv_ $vg/$lv1)
+test $convlv = ${lv1}_mimagetmp_2
+lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
+lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
+lv_mirror_log_ $vg/$convlv ${lv1}_mlog
 
 #COMM "mirror log name after re-adding is ${lv1}_mlog" \
-lvconvert --mirrorlog core $vg/$lv1 
-lvconvert --mirrorlog disk $vg/$lv1 
-convlv=$(lv_convert_lv_ "$vg/$lv1") 
-lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 
-lv_devices_ "$vg/$convlv" "$lv1"_mimage_0 "$lv1"_mimage_1 
-loglv=$(lv_mirror_log_ "$vg/$convlv") 
-test "$loglv" = "$lv1"_mlog
+lvconvert --mirrorlog core $vg/$lv1
+lvconvert --mirrorlog disk $vg/$lv1
+convlv=$(lv_convert_lv_ $vg/$lv1)
+lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
+lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
+lv_mirror_log_ $vg/$convlv ${lv1}_mlog
 
 #COMM "renamed converting mirror names: $lv1 to $lv2" \
-lvrename $vg/$lv1 $vg/$lv2 
-convlv=$(lv_convert_lv_ "$vg/$lv2") 
-lv_devices_ $vg/$lv2 "$convlv" "$lv2"_mimage_2 
-lv_devices_ "$vg/$convlv" "$lv2"_mimage_0 "$lv2"_mimage_1 
-loglv=$(lv_mirror_log_ "$vg/$convlv") 
-test "$loglv" = "$lv2"_mlog
+lvrename $vg/$lv1 $vg/$lv2
+convlv=$(lv_convert_lv_ $vg/$lv2)
+lv_devices_ $vg/$lv2 $convlv ${lv2}_mimage_2
+lv_devices_ $vg/$convlv ${lv2}_mimage_0 ${lv2}_mimage_1
+lv_mirror_log_ $vg/$convlv ${lv2}_mlog
 
-#COMM "cleanup" 
+#COMM "cleanup"
 check_and_cleanup_lvs_
 
 # Temporary mirror log should have "_mlogtmp_<n>" suffix
--- LVM2/test/shell/mirror-vgreduce-removemissing.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/mirror-vgreduce-removemissing.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,5 @@
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -17,15 +18,14 @@
 {
 	local lv=$vg/$1
 	shift
-	local pvs=$*
+	local pvs=$@
 
 	echo "Check if $lv is exactly on PVs $pvs"
 	rm -f out1 out2
 	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
 
 	lvs -a -o+devices $lv
-	lvs -a -odevices --noheadings $lv > lvs_log
-	sed 's/([^)]*)//g; s/[ ,]/\n/g' lvs_log | sort | uniq > out2 || true
+	get lv_devices $lv | sed 's/ /\n/g' | sort | uniq > out2 || true
 
 	diff --ignore-blank-lines out1 out2
 }
@@ -34,7 +34,7 @@
 {
 	local lv=$1
 	shift
-	local pvs="$*"
+	local pvs=$@
 	local mimages
 	local i
 
@@ -44,7 +44,7 @@
 	lvs --noheadings -a -o lv_name $vg > lvs_log
 	mimages=$(grep "${lv}_mimage_" lvs_log | \
 		sed 's/\[//g; s/\]//g' || true)
-	
+
 	for i in $mimages; do
 		echo "Checking $vg/$i"
 		lvs -a -o+devices $vg/$i
@@ -57,23 +57,22 @@
 
 mirrorlog_is_on_()
 {
-	local lv="$1"_mlog
+	local lv=${1}_mlog
 	shift
-	lv_is_on_ $lv $*
+	lv_is_on_ $lv "$@"
 }
 
 lv_is_linear_()
 {
 	echo "Check if $1 is linear LV (i.e. not a mirror)"
-	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
-	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep '^1-' >/dev/null
+	get lv_field $vg/$1 "stripes,attr" | grep "^1 -" >/dev/null
 }
 
 rest_pvs_()
 {
 	local index=$1
 	local num=$2
-	local rem=""
+	local rem=
 	local n
 
 	for n in $(seq 1 $(($index - 1))) $(seq $(($index + 1)) $num); do
@@ -95,33 +94,31 @@
 prepare_lvs_()
 {
 	lvremove -ff $vg;
-	if dmsetup table|grep -v -- "-missing_"|grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!"
-		return 1
+	if (dmsetup table | grep -v -- "-missing_" | grep $vg); then
+		die "ERROR: lvremove did leave some some mappings in DM behind!"
 	fi
 	:
 }
 
 check_and_cleanup_lvs_()
 {
-	lvs -a -o+devices $vg 
+	lvs -a -o+devices $vg
 	lvremove -ff $vg
-	if dmsetup table|grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!"
-		return 1
+	if (dmsetup table | grep $vg); then
+		die "ERROR: lvremove did leave some some mappings in DM behind!"
 	fi
 }
 
 recover_vg_()
 {
-	aux enable_dev $* 
-	pvcreate -ff $* 
-	vgextend $vg $* 
+	aux enable_dev "$@"
+	pvcreate -ff "$@"
+	vgextend $vg "$@"
 	check_and_cleanup_lvs_
 }
 
-#COMM "check environment setup/cleanup" 
-prepare_lvs_ 
+#COMM "check environment setup/cleanup"
+prepare_lvs_
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
@@ -129,17 +126,17 @@
 
 #COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0
 lvchange -an $vg/$lv1
 mimages_are_on_ $lv1 $dev1 $dev2
 mirrorlog_is_on_ $lv1 $dev3
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 vgreduce --removemissing --force $vg
 lv_is_linear_ $lv1
-lv_is_on_ $lv1 $dev1
+lv_is_on_ $lv1 "$dev1"
 
 # "cleanup"
-recover_vg_ $dev2
+recover_vg_ "$dev2"
 
 # ---------------------------------------------------------------------
 # LV has 3 images in flat,
@@ -150,15 +147,15 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
+	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 	lvchange -an $vg/$lv1
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
-	mirrorlog_is_on_ $lv1 $dev4
+	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
+	mirrorlog_is_on_ $lv1 "$dev4"
 	eval aux disable_dev \$dev$index
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
-	mirrorlog_is_on_ $lv1 $dev4
+	mirrorlog_is_on_ $lv1 "$dev4"
 }
 
 for n in $(seq 1 3); do
@@ -177,10 +174,10 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
+	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 	lvchange -an $vg/$lv1
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
-	mirrorlog_is_on_ $lv1 $dev4
+	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
+	mirrorlog_is_on_ $lv1 "$dev4"
 	rest_pvs_ $index 3
 	aux disable_dev $(rest_pvs_ $index 3)
 	vgreduce --force --removemissing $vg
@@ -205,17 +202,17 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
-	lvchange -an $vg/$lv1 
-	lvconvert -m+1 $vg/$lv1 $dev4 
-	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4 
-	check mirror_log_on $vg $lv1 $dev5 
-	eval aux disable_dev \$dev$index 
+	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":0
+	lvchange -an $vg/$lv1
+	lvconvert -m+1 $vg/$lv1 "$dev4"
+	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+	check mirror_log_on $vg $lv1 "$dev5"
+	eval aux disable_dev \$dev$index
         lvs -a -o +devices
-	vgreduce --removemissing --force $vg 
-	lvs -a -o+devices # $vg 
-	check mirror_images_on $vg $lv1 $dev5 # $(rest_pvs_ $index 4) 
-	check mirror_log_on $vg $lv1 $dev5
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices # $vg
+	check mirror_images_on $vg $lv1 "$dev5" # $(rest_pvs_ $index 4)
+	check mirror_log_on $vg $lv1 "$dev5"
 }
 
 for n in $(seq 1 4); do
@@ -234,11 +231,11 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
+	lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":0
 	lvchange -an $vg/$lv1
-	lvconvert -m+1 $vg/$lv1 $dev4
-	check mirror_images_on $vg $lv1 $dev1 $dev2 $dev3 $dev4
-	check mirror_log_on $vg $lv1 $dev5
+	lvconvert -m+1 $vg/$lv1 "$dev4"
+	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+	check mirror_log_on $vg $lv1 "$dev5"
 	lvs -a -o+devices $vg
 	aux disable_dev $(rest_pvs_ $index 4)
 	vgreduce --removemissing --force $vg
@@ -264,21 +261,21 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-	lvchange -an $vg/$lv1 
-	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
-	mirrorlog_is_on_ $lv1 $dev5 
-	eval aux disable_dev \$dev$n 
-	vgreduce --removemissing --force $vg 
-	lvs -a -o+devices $vg 
-	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
-	mirrorlog_is_on_ $lv1 $dev5
+	lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+	lvchange -an $vg/$lv1
+	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
+	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+	mirrorlog_is_on_ $lv1 "$dev5"
+	eval aux disable_dev \$dev$n
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
+	mimages_are_on_ $lv1 $(rest_pvs_ $index 4)
+	mirrorlog_is_on_ $lv1 "$dev5"
 }
 
 for n in $(seq 1 4); do
-	#COMM "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV" 
-	prepare_lvs_ 
+	#COMM "fail mirror image $(($n - 1)) of 4-way (2 converting) mirrored LV"
+	prepare_lvs_
 	test_2way_mirror_plus_2_fail_1_ $n
 	eval recover_vg_ \$dev$n
 done
@@ -292,17 +289,17 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-	lvchange -an $vg/$lv1 
-	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
-	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
-	mirrorlog_is_on_ $lv1 $dev5 
-	aux disable_dev $(rest_pvs_ $index 4) 
-	vgreduce --removemissing --force $vg 
-	lvs -a -o+devices $vg 
+	lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+	lvchange -an $vg/$lv1
+	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
+	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+	mirrorlog_is_on_ $lv1 "$dev5"
+	aux disable_dev $(rest_pvs_ $index 4)
+	vgreduce --removemissing --force $vg
+	lvs -a -o+devices $vg
 	eval local dev=\$dev$n
 	mimages_are_on_ $lv1 $dev || lv_is_on_ $lv1 $dev
-	not mirrorlog_is_on_ $lv1 $dev5
+	not mirrorlog_is_on_ $lv1 "$dev5"
 }
 
 for n in $(seq 1 4); do
@@ -315,110 +312,109 @@
 # ---------------------------------------------------------------------
 # log device is gone (flat mirror and stacked mirror)
 
-#COMM "fail mirror log of 2-way mirrored LV" 
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mirrorlog_is_on_ $lv1 $dev5 
-aux disable_dev $dev5 
-vgreduce --removemissing --force $vg 
-mimages_are_on_ $lv1 $dev1 $dev2 
-not mirrorlog_is_on_ $lv1 $dev5
-recover_vg_ $dev5
-
-#COMM "fail mirror log of 3-way (1 converting) mirrored LV" 
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-lvconvert -m+1 $vg/$lv1 $dev3 
-mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
-mirrorlog_is_on_ $lv1 $dev5 
-aux disable_dev $dev5 
-vgreduce --removemissing --force $vg 
-mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
-not mirrorlog_is_on_ $lv1 $dev5
-recover_vg_ $dev5
+#COMM "fail mirror log of 2-way mirrored LV"
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mirrorlog_is_on_ $lv1 "$dev5"
+aux disable_dev "$dev5"
+vgreduce --removemissing --force $vg
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+not mirrorlog_is_on_ $lv1 "$dev5"
+recover_vg_ "$dev5"
+
+#COMM "fail mirror log of 3-way (1 converting) mirrored LV"
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+lvconvert -m+1 $vg/$lv1 "$dev3"
+mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
+mirrorlog_is_on_ $lv1 "$dev5"
+aux disable_dev "$dev5"
+vgreduce --removemissing --force $vg
+mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
+not mirrorlog_is_on_ $lv1 "$dev5"
+recover_vg_ "$dev5"
 
 # ---------------------------------------------------------------------
 # all images are gone (flat mirror and stacked mirror)
 
 #COMM "fail all mirror images of 2-way mirrored LV"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mirrorlog_is_on_ $lv1 $dev5 
-aux disable_dev $dev1 $dev2 
-vgreduce --removemissing --force $vg 
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mirrorlog_is_on_ $lv1 "$dev5"
+aux disable_dev "$dev1" "$dev2"
+vgreduce --removemissing --force $vg
 not lvs $vg/$lv1
-recover_vg_ $dev1 $dev2
+recover_vg_ "$dev1" "$dev2"
 
 #COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-lvconvert -m+1 $vg/$lv1 $dev3 
-mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
-mirrorlog_is_on_ $lv1 $dev5 
-aux disable_dev $dev1 $dev2 $dev3 
-vgreduce --removemissing --force $vg 
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+lvconvert -m+1 $vg/$lv1 "$dev3"
+mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
+mirrorlog_is_on_ $lv1 "$dev5"
+aux disable_dev "$dev1" "$dev2" "$dev3"
+vgreduce --removemissing --force $vg
 not lvs $vg/$lv1
-recover_vg_ $dev1 $dev2 $dev3
+recover_vg_ "$dev1" "$dev2" "$dev3"
 
 # ---------------------------------------------------------------------
 # Multiple LVs
 
 #COMM "fail a mirror image of one of mirrored LV"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
-lvchange -an $vg/$lv2 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mimages_are_on_ $lv2 $dev3 $dev4 
-mirrorlog_is_on_ $lv1 $dev5 
-mirrorlog_is_on_ $lv2 $dev5 
-aux disable_dev $dev2 
-vgreduce --removemissing --force $vg 
-mimages_are_on_ $lv2 $dev3 $dev4 
-mirrorlog_is_on_ $lv2 $dev5 
-lv_is_linear_ $lv1 
-lv_is_on_ $lv1 $dev1
-recover_vg_ $dev2
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+lvcreate -l2 -m1 -n $lv2 $vg "$dev3" "$dev4" "$dev5":1
+lvchange -an $vg/$lv2
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mimages_are_on_ $lv2 "$dev3" "$dev4"
+mirrorlog_is_on_ $lv1 "$dev5"
+mirrorlog_is_on_ $lv2 "$dev5"
+aux disable_dev "$dev2"
+vgreduce --removemissing --force $vg
+mimages_are_on_ $lv2 "$dev3" "$dev4"
+mirrorlog_is_on_ $lv2 "$dev5"
+lv_is_linear_ $lv1
+lv_is_on_ $lv1 "$dev1"
+recover_vg_ "$dev2"
 
 #COMM "fail mirror images, one for each mirrored LV"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
-lvchange -an $vg/$lv2 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mimages_are_on_ $lv2 $dev3 $dev4 
-mirrorlog_is_on_ $lv1 $dev5 
-mirrorlog_is_on_ $lv2 $dev5 
-aux disable_dev $dev2 
-aux disable_dev $dev4 
-vgreduce --removemissing --force $vg 
-lv_is_linear_ $lv1 
-lv_is_on_ $lv1 $dev1 
-lv_is_linear_ $lv2 
-lv_is_on_ $lv2 $dev3
-recover_vg_ $dev2 $dev4
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+lvcreate -l2 -m1 -n $lv2 $vg "$dev3" "$dev4" "$dev5":1
+lvchange -an $vg/$lv2
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mimages_are_on_ $lv2 "$dev3" "$dev4"
+mirrorlog_is_on_ $lv1 "$dev5"
+mirrorlog_is_on_ $lv2 "$dev5"
+aux disable_dev "$dev2"
+aux disable_dev "$dev4"
+vgreduce --removemissing --force $vg
+lv_is_linear_ $lv1
+lv_is_on_ $lv1 "$dev1"
+lv_is_linear_ $lv2
+lv_is_on_ $lv2 "$dev3"
+recover_vg_ "$dev2" "$dev4"
 
 # ---------------------------------------------------------------------
 # no failure
 
 #COMM "no failures"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
-lvchange -an $vg/$lv1 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mirrorlog_is_on_ $lv1 $dev5 
-vgreduce --removemissing --force $vg 
-mimages_are_on_ $lv1 $dev1 $dev2 
-mirrorlog_is_on_ $lv1 $dev5
+prepare_lvs_
+lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":0
+lvchange -an $vg/$lv1
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mirrorlog_is_on_ $lv1 "$dev5"
+vgreduce --removemissing --force $vg
+mimages_are_on_ $lv1 "$dev1" "$dev2"
+mirrorlog_is_on_ $lv1 "$dev5"
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
-
--- LVM2/test/shell/name-mangling.sh	2012/03/06 03:16:05	1.2
+++ LVM2/test/shell/name-mangling.sh	2012/03/16 13:00:06	1.3
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
--- LVM2/test/shell/nomda-missing.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/nomda-missing.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
@@ -13,22 +13,22 @@
 . lib/test
 
 aux prepare_devs 4
-pvcreate $dev1 $dev2
-pvcreate --metadatacopies 0 $dev3 $dev4
-vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
-
-lvcreate -l1 -n linear1 $vg $dev1
-lvcreate -l1 -n linear2 $vg $dev2
-lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+pvcreate "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3" "$dev4"
+vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate -l1 -n linear1 $vg "$dev1"
+lvcreate -l1 -n linear2 $vg "$dev2"
+lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 
-lvcreate -l1 -n origin1 $vg $dev1
-lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+lvcreate -l1 -n origin1 $vg "$dev1"
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
-lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -41,8 +41,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-aux enable_dev $dev1
-aux disable_dev $dev2
+aux enable_dev "$dev1"
+aux disable_dev "$dev2"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -55,8 +55,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-aux enable_dev $dev2
-aux disable_dev $dev3
+aux enable_dev "$dev2"
+aux disable_dev "$dev3"
 not vgchange -a y $vg
 not vgck $vg
 
@@ -69,8 +69,8 @@
 check active $vg mirror12
 
 vgchange -a n $vg
-aux enable_dev $dev3
-aux disable_dev $dev4
+aux enable_dev "$dev3"
+aux disable_dev "$dev4"
 vgchange -a y $vg
 not vgck $vg
 
--- LVM2/test/shell/pool-labels.sh	2012/02/23 23:58:42	1.3
+++ LVM2/test/shell/pool-labels.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -10,18 +11,19 @@
 
 . lib/test
 
+env printf "" || skip # skip if printf is not available
+
 # create the old GFS pool labeled linear devices
 create_pool_label_()
 {
   # FIXME
   # echo -e is bashism, dash builtin sh doesn't do \xNN in printf either
   # printf comes from coreutils, and is probably not posix either
-  env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
+  env printf "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of="$2" bs=5 seek=1 conv=notrunc
   env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
   aux notify_lvmetad "$2"
 }
 
-env printf "" || exit 200 # skip if printf is not available
 
 aux prepare_devs 2
 
--- LVM2/test/shell/pv-duplicate.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pv-duplicate.sh	2012/03/16 13:00:06	1.2
@@ -15,11 +15,11 @@
 
 aux prepare_devs 3
 
-vgcreate -c n --metadatasize 128k $vg1 $dev1
+vgcreate -c n --metadatasize 128k $vg1 "$dev1"
 
 # copy mda
-dd if=$dev1 of=$dev2 bs=256K count=1
-dd if=$dev1 of=$dev3 bs=256K count=1
+dd if="$dev1" of="$dev2" bs=256K count=1
+dd if="$dev1" of="$dev3" bs=256K count=1
 
-pvs $dev1
+pvs "$dev1"
 vgs $vg1
--- LVM2/test/shell/pv-min-size.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pv-min-size.sh	2012/03/16 13:00:06	1.2
@@ -16,16 +16,16 @@
 
 aux prepare_pvs 1 8
 
-check pv_field $dev1 pv_name $dev1
+check pv_field "$dev1" pv_name "$dev1"
 
 # increase min size beyond created PV size 10MB
 aux lvmconf 'devices/pv_min_size = 10240'
 
 # and test device is not visible
-not check pv_field $dev1 pv_name $dev1
+not check pv_field "$dev1" pv_name "$dev1"
 
 # set too low value errornous value
 aux lvmconf 'devices/pv_min_size = -100'
 
 # check the incorrect value is printed
-pvs $dev1 2>&1 | grep -- -100
+pvs "$dev1" 2>&1 | grep -- -100
--- LVM2/test/shell/pv-range-overflow.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pv-range-overflow.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -20,13 +20,13 @@
 # Test for the bogus diagnostic reported in BZ 284771
 # http://bugzilla.redhat.com/284771.
 # 'run pvmove with an unrecognized LV name to show bad diagnostic'
-not pvmove -v -nbogus $dev1 $dev2 2> err
-grep "  Logical volume bogus not found." err
+not pvmove -v -nbogus "$dev1" "$dev2" 2> err
+grep "Logical volume bogus not found." err
 
 # With lvm-2.02.28 and earlier, on a system with 64-bit "long int",
 # the PE range parsing code would accept values up to 2^64-1, but would
 # silently truncate them to int32_t.  I.e., $dev1:$(echo 2^32|bc) would be
 # treated just like $dev1:0.
 # 'run the offending pvmove command'
-not pvmove -v -n$lv $dev1:4294967296 $dev2
+not pvmove -v -n$lv "$dev1":4294967296 "$dev2"
 
--- LVM2/test/shell/pvchange-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvchange-usage.sh	2012/03/16 13:00:06	1.2
@@ -15,52 +15,51 @@
 
 aux prepare_devs 4
 
-for mda in 0 1 2 
+for mda in 0 1 2
 do
-# "setup pv with metadatacopies = $mda" 
-	pvcreate $dev4 
-	pvcreate --metadatacopies $mda $dev1 
-	vgcreate $vg1 $dev1 $dev4 
-
-# "pvchange adds/dels tag to pvs with metadatacopies = $mda " 
-	pvchange $dev1 --addtag test$mda 
-	check pv_field $dev1 pv_tags test$mda 
-	pvchange $dev1 --deltag test$mda 
-	check pv_field $dev1 pv_tags ""
+# "setup pv with metadatacopies = $mda"
+	pvcreate "$dev4"
+	pvcreate --metadatacopies $mda "$dev1"
+	vgcreate $vg1 "$dev1" "$dev4"
+
+# "pvchange adds/dels tag to pvs with metadatacopies = $mda "
+	pvchange "$dev1" --addtag test$mda
+	check pv_field "$dev1" pv_tags test$mda
+	pvchange "$dev1" --deltag test$mda
+	check pv_field "$dev1" pv_tags ""
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
-	pvchange $dev1 -x n 
-	check pv_field $dev1 pv_attr  ---
-	pvchange $dev1 -x y 
-	check pv_field $dev1 pv_attr  a--
+	pvchange "$dev1" -x n
+	check pv_field "$dev1" pv_attr  ---
+	pvchange "$dev1" -x y
+	check pv_field "$dev1" pv_attr  a--
 
 # 'remove pv'
-	vgremove $vg1 
-	pvremove $dev1 $dev4
+	vgremove $vg1
+	pvremove "$dev1" "$dev4"
 done
 
 # "pvchange uuid"
-pvcreate --metadatacopies 0 $dev1 
-pvcreate --metadatacopies 2 $dev2 
-vgcreate $vg1 $dev1 $dev2 
-pvchange -u $dev1 
-pvchange -u $dev2 
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 2 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+pvchange -u "$dev1"
+pvchange -u "$dev2"
 check pvlv_counts $vg1 2 0 0
 pvchange -u --all
 check pvlv_counts $vg1 2 0 0
 
-# "pvchange rejects uuid change under an active lv" 
-lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 
-check pvlv_counts $vg1 2 1 0 
-not pvchange -u $dev1
-lvchange -an "$vg1"/"$lv" 
-pvchange -u $dev1
+# "pvchange rejects uuid change under an active lv"
+lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1
+check pvlv_counts $vg1 2 1 0
+not pvchange -u "$dev1"
+lvchange -an $vg1/$lv
+pvchange -u "$dev1"
 
-# "cleanup" 
-lvremove -f "$vg1"/"$lv"
+# "cleanup"
+lvremove -f $vg1/$lv
 vgremove $vg1
 
 # "pvchange reject --addtag to lvm1 pv"
-pvcreate -M1 $dev1 
-not pvchange $dev1 --addtag test
-
+pvcreate -M1 "$dev1"
+not pvchange "$dev1" --addtag test
--- LVM2/test/shell/pvcreate-metadata0.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvcreate-metadata0.sh	2012/03/16 13:00:06	1.2
@@ -23,10 +23,10 @@
 pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 
-# "check lv snapshot" 
-vgcreate -c n "$vg" "$dev1" "$dev2" 
-lvcreate -n "$lv" -l 60%FREE "$vg" 
-lvcreate -s -n $lv2 -l 10%FREE "$vg"/"$lv" 
-pvdisplay 
+# "check lv snapshot"
+vgcreate -c n $vg "$dev1" "$dev2"
+lvcreate -n $lv -l 60%FREE $vg
+lvcreate -s -n $lv2 -l 10%FREE $vg/$lv
+pvdisplay
 lvdisplay
-vgremove -f "$vg"
+vgremove -f $vg
--- LVM2/test/shell/pvcreate-operation-md.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvcreate-operation-md.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -8,18 +9,19 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+. lib/test
+
 # skip this test if mdadm or sfdisk (or others) aren't available
-which mdadm || exit 200
-which sfdisk || exit 200
-which perl || exit 200
-which awk || exit 200
-which cut || exit 200
+which mdadm || skip
+which sfdisk || skip
+which perl || skip
+which awk || skip
+which cut || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
-modprobe raid0 || exit 200
-
-. lib/test
+	modprobe raid0 || skip
 
+aux lvmconf 'devices/md_component_detection = 1'
 aux lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
 aux prepare_devs 2
 
@@ -50,10 +52,10 @@
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-test -b "$mddev" && exit 200
-mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
+test -b "$mddev" && skip
+mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
-test -b "$mddev" || exit 200
+test -b "$mddev" || skip
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
@@ -104,7 +106,7 @@
     # in case the system is running without devtmpfs /dev
     # wait here for created device node on tmpfs
     aux udev_wait $mddev_p
-    test -b $mddev_p || exit 200
+    test -b $mddev_p || skip
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
@@ -117,7 +119,7 @@
         # default alignment is 1M, add alignment_offset
 	pv_align=$((1048576+$alignment_offset))B
 	pvcreate --metadatasize 128k $mddev_p
-	check pv_field $mddev_p pe_start $pv_align "--units b"
+	check pv_field $mddev_p pe_start $pv_align --units b
 	pvremove $mddev_p
     fi
 fi
@@ -125,13 +127,13 @@
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if kernel_at_least 2 6 33 ; then
     cleanup_md
-    pvcreate -f $dev1
-    pvcreate -f $dev2
+    pvcreate -f "$dev1"
+    pvcreate -f "$dev2"
 
     # create 2 disk MD raid0 array (stripe_width=2M)
-    test -b "$mddev" && exit 200
-    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 $dev1 $dev2
-    test -b "$mddev" || exit 200
+    test -b "$mddev" && skip
+    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 "$dev1" "$dev2"
+    test -b "$mddev" || skip
 
     # optimal_io_size=2097152, minimum_io_size=1048576
     pv_align="2.00m"
--- LVM2/test/shell/pvcreate-operation.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvcreate-operation.sh	2012/03/16 13:00:06	1.2
@@ -10,84 +10,83 @@
 
 . lib/test
 
+aux lvmconf 'devices/md_component_detection = 1'
+
 aux prepare_devs 4
 
 for mdatype in 1 2
 do
 # pvcreate (lvm$mdatype) refuses to overwrite an mounted filesystem (bz168330)
-	test ! -d $TESTDIR/mnt && mkdir $TESTDIR/mnt
-	if mke2fs $dev1; then
-		mount $dev1 $TESTDIR/mnt
-		not pvcreate -M$mdatype $dev1 2>err
-		grep "Can't open $dev1 exclusively.  Mounted filesystem?" err
-		umount $dev1
+	test ! -d mnt && mkdir mnt
+	if mke2fs "$dev1"; then
+		mount "$dev1" mnt
+		not pvcreate -M$mdatype "$dev1" 2>err
+		grep "Can't open "$dev1" exclusively.  Mounted filesystem?" err
+		umount "$dev1"
 	fi
 
 # pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)
-    pvcreate -M$mdatype $dev1
-    pvcreate -M$mdatype $dev1
-    pvremove -f $dev1
-
-# pvcreate (lvm$mdatype) fails when PV belongs to VG" \
-    pvcreate -M$mdatype $dev1
-    vgcreate -M$mdatype $vg1 $dev1
-    not pvcreate -M$mdatype $dev1
+    pvcreate -M$mdatype "$dev1"
+    pvcreate -M$mdatype "$dev1"
+    pvremove -f "$dev1"
+
+# pvcreate (lvm$mdatype) fails when PV belongs to VG
+#   pvcreate -M$mdatype "$dev1"
+    vgcreate -M$mdatype $vg1 "$dev1"
+    not pvcreate -M$mdatype "$dev1"
 
     vgremove -f $vg1
-    pvremove -f $dev1
+    pvremove -f "$dev1"
 
 # pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG
-    pvcreate -M$mdatype $dev1
-    pvcreate -M$mdatype $dev2
-    vgcreate -M$mdatype $vg1 $dev1
+    pvcreate -M$mdatype "$dev1"
+    pvcreate -M$mdatype "$dev2"
+    vgcreate -M$mdatype $vg1 "$dev1"
 
 # pvcreate a second time on $dev2 and $dev1
-    not pvcreate -M$mdatype $dev2 $dev1
+    not pvcreate -M$mdatype "$dev2" "$dev1"
 
     vgremove -f $vg1
-    pvremove -f $dev2
-    pvremove -f $dev1
+    pvremove -f "$dev2" "$dev1"
 
 # NOTE: Force pvcreate after test completion to ensure clean device
-#test_expect_success \
-#  "pvcreate (lvm$mdatype) fails on md component device" \
-#  'mdadm -C -l raid0 -n 2 /dev/md0 $dev1 $dev2 &&
-#   pvcreate -M$mdatype $dev1;
+#test_expect_success
+#  "pvcreate (lvm$mdatype) fails on md component device"
+#  'mdadm -C -l raid0 -n 2 /dev/md0 "$dev1" "$dev2" &&
+#   pvcreate -M$mdatype "$dev1";
 #   status=$?; echo status=$status; test $status != 0 &&
 #   mdadm --stop /dev/md0 &&
-#   pvcreate -ff -y -M$mdatype $dev1 $dev2 &&
-#   pvremove -f $dev1 $dev2'
+#   pvcreate -ff -y -M$mdatype "$dev1" "$dev2" &&
+#   pvremove -f "$dev1" "$dev2"'
 done
 
 # pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG
-pvcreate --metadatacopies 0 $dev1
-pvcreate --metadatacopies 1 $dev2
-vgcreate $vg1 $dev1 $dev2
-not pvcreate $dev1
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+not pvcreate "$dev1"
 vgremove -f $vg1
-pvremove -f $dev2
-pvremove -f $dev1
+pvremove -f "$dev2" "$dev1"
 
 # pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG
-pvcreate --metadatacopies 0 $dev1 
-pvcreate --metadatacopies 1 $dev2
-vgcreate $vg1 $dev1 $dev2 
-pvcreate -ff -y $dev1 
-vgreduce --removemissing $vg1 
-vgremove -ff $vg1 
-pvremove -f $dev2 
-pvremove -f $dev1
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+pvcreate -ff -y "$dev1"
+vgreduce --removemissing $vg1
+vgremove -ff $vg1
+pvremove -f "$dev2" "$dev1"
 
 for i in 0 1 2 3
 do
 # pvcreate (lvm2) succeeds writing LVM label at sector $i
-    pvcreate --labelsector $i $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
-    pvremove -f $dev1
+    pvcreate --labelsector $i "$dev1"
+    dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    pvremove -f "$dev1"
 done
 
 # pvcreate (lvm2) fails writing LVM label at sector 4
-not pvcreate --labelsector 4 $dev1
+not pvcreate --labelsector 4 "$dev1"
 
 backupfile=$PREFIX.mybackupfile
 uuid1=freddy-fred-fred-fred-fred-fred-freddy
@@ -95,27 +94,27 @@
 bogusuuid=fred
 
 # pvcreate rejects uuid option with less than 32 characters
-not pvcreate --norestorefile --uuid $bogusuuid $dev1
+not pvcreate --norestorefile --uuid $bogusuuid "$dev1"
 
 # pvcreate rejects uuid option without restorefile
-not pvcreate --uuid $uuid1 $dev1
+not pvcreate --uuid $uuid1 "$dev1"
 
 # pvcreate rejects uuid already in use
-pvcreate --norestorefile --uuid $uuid1 $dev1
-not pvcreate --norestorefile --uuid $uuid1 $dev2
+pvcreate --norestorefile --uuid $uuid1 "$dev1"
+not pvcreate --norestorefile --uuid $uuid1 "$dev2"
 
 # pvcreate rejects non-existent file given with restorefile
-not pvcreate --uuid $uuid1 --restorefile $backupfile $dev1
+not pvcreate --uuid $uuid1 --restorefile $backupfile "$dev1"
 
 # pvcreate rejects restorefile with uuid not found in file
-pvcreate --norestorefile --uuid $uuid1 $dev1
+pvcreate --norestorefile --uuid $uuid1 "$dev1"
 vgcfgbackup -f $backupfile
-not pvcreate --uuid $uuid2 --restorefile $backupfile $dev2
+not pvcreate --uuid $uuid2 --restorefile $backupfile "$dev2"
 
 # pvcreate wipes swap signature when forced
-dd if=/dev/zero of=$dev1 bs=1024 count=64
-mkswap $dev1
-blkid -c /dev/null $dev1 | grep "swap"
-pvcreate -f $dev1
+dd if=/dev/zero of="$dev1" bs=1024 count=64
+mkswap "$dev1"
+blkid -c /dev/null "$dev1" | grep "swap"
+pvcreate -f "$dev1"
 # blkid cannot make up its mind whether not finding anything it knows is a failure or not
-(blkid -c /dev/null $dev1 || true) | not grep "swap"
+(blkid -c /dev/null "$dev1" || true) | not grep "swap"
--- LVM2/test/shell/pvcreate-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvcreate-usage.sh	2012/03/16 13:00:06	1.2
@@ -17,59 +17,57 @@
 aux prepare_devs 4
 
 #COMM 'pvcreate rejects negative setphysicalvolumesize'
-not pvcreate --setphysicalvolumesize -1024 $dev1
+not pvcreate --setphysicalvolumesize -1024 "$dev1"
 
 #COMM 'pvcreate rejects negative metadatasize'
-not pvcreate --metadatasize -1024 $dev1
+not pvcreate --metadatasize -1024 "$dev1"
 
 # x. metadatasize 0, defaults to 255
 # FIXME: unable to check default value, not in reporting cmds
 # should default to 255 according to code
 #   check pv_field pv_mda_size 255 
 #COMM 'pvcreate accepts metadatasize 0'
-pvcreate --metadatasize 0 $dev1
-pvremove $dev1
+pvcreate --metadatasize 0 "$dev1"
+pvremove "$dev1"
 
 #Verify vg_mda_size is smaller pv_mda_size
-pvcreate --metadatasize 512k $dev1
-pvcreate --metadatasize 96k $dev2
-vgcreate $vg $dev1 $dev2
-check compare_fields vgs $vg vg_mda_size pvs $dev2 pv_mda_size
-vgremove -ff $vg
+pvcreate --metadatasize 512k "$dev1"
+pvcreate --metadatasize 96k "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+check compare_fields vgs $vg vg_mda_size pvs "$dev2" pv_mda_size
+vgremove $vg
 
 # x. metadatasize too large
 # For some reason we allow this, even though there's no room for data?
 ##COMM  'pvcreate rejects metadatasize too large' 
-#not pvcreate --metadatasize 100000000000000 $dev1
+#not pvcreate --metadatasize 100000000000000 "$dev1"
 
 #COMM 'pvcreate rejects metadatacopies < 0'
-not pvcreate --metadatacopies -1 $dev1
+not pvcreate --metadatacopies -1 "$dev1"
 
 #COMM 'pvcreate accepts metadatacopies = 0, 1, 2'
 for j in metadatacopies pvmetadatacopies
 do
-pvcreate --$j 0 $dev1
-pvcreate --$j 1 $dev2
-pvcreate --$j 2 $dev3
-check pv_field $dev1 pv_mda_count 0
-check pv_field $dev2 pv_mda_count 1
-check pv_field $dev3 pv_mda_count 2
-pvremove $dev1 
-pvremove $dev2 
-pvremove $dev3
+pvcreate --$j 0 "$dev1"
+pvcreate --$j 1 "$dev2"
+pvcreate --$j 2 "$dev3"
+check pv_field "$dev1" pv_mda_count 0
+check pv_field "$dev2" pv_mda_count 1
+check pv_field "$dev3" pv_mda_count 2
+pvremove "$dev1" "$dev2" "$dev3"
 done
 
 #COMM 'pvcreate rejects metadatacopies > 2'
-not pvcreate --metadatacopies 3 $dev1
+not pvcreate --metadatacopies 3 "$dev1"
 
 #COMM 'pvcreate rejects invalid device'
-not pvcreate $dev1bogus
+not pvcreate "$dev1"bogus
 
 #COMM 'pvcreate rejects labelsector < 0'
-not pvcreate --labelsector -1 $dev1
+not pvcreate --labelsector -1 "$dev1"
 
 #COMM 'pvcreate rejects labelsector > 1000000000000'
-not pvcreate --labelsector 1000000000000 $dev1
+not pvcreate --labelsector 1000000000000 "$dev1"
 
 # other possibilites based on code inspection (not sure how hard)
 # x. device too small (min of 512 * 1024 KB)
@@ -82,109 +80,107 @@
 # x. set size to value inconsistent with device / PE size
 
 #COMM 'pvcreate basic dataalignment sanity checks'
-not pvcreate --dataalignment -1 $dev1
-not pvcreate -M 1 --dataalignment 1 $dev1
-not pvcreate --dataalignment 1e $dev1
+not pvcreate --dataalignment -1 "$dev1"
+not pvcreate -M 1 --dataalignment 1 "$dev1"
+not pvcreate --dataalignment 1e "$dev1"
 
 #COMM 'pvcreate always rounded up to page size for start of device'
-#pvcreate --metadatacopies 0 --dataalignment 1 $dev1
+#pvcreate --metadatacopies 0 --dataalignment 1 "$dev1"
 # amuse shell experts
-#check pv_field $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00k"
+#check pv_field "$dev1" pe_start $(($(getconf PAGESIZE)/1024))".00k"
 
 #COMM 'pvcreate sets data offset directly'
-pvcreate --dataalignment 512k $dev1
-check pv_field $dev1 pe_start 512.00k
+pvcreate --dataalignment 512k "$dev1"
+check pv_field "$dev1" pe_start "512.00k"
 
 #COMM 'vgcreate/vgremove do not modify data offset of existing PV'
-vgcreate $vg $dev1  --config 'devices { data_alignment = 1024 }'
-check pv_field $dev1 pe_start 512.00k
+vgcreate $vg "$dev1"  --config 'devices { data_alignment = 1024 }'
+check pv_field "$dev1" pe_start "512.00k"
 vgremove $vg --config 'devices { data_alignment = 1024 }'
-check pv_field $dev1 pe_start 512.00k
+check pv_field "$dev1" pe_start "512.00k"
 
 #COMM 'pvcreate sets data offset next to mda area'
-pvcreate --metadatasize 100k --dataalignment 100k $dev1
-check pv_field $dev1 pe_start 200.00k
+pvcreate --metadatasize 100k --dataalignment 100k "$dev1"
+check pv_field "$dev1" pe_start "200.00k"
 
 # metadata area start is aligned according to pagesize
-if [ $PAGESIZE -eq 65536 ] ; then
-	pv_align="192.50k"
-elif [ $PAGESIZE -eq 8192 ] ; then
-	pv_align="136.50k"
-else
-	pv_align="133.00k"
-fi
+case "$PAGESIZE" in
+ 65536) pv_align="192.50k" ;;
+ 8192)	pv_align="136.50k" ;;
+ *)	pv_align="133.00k" ;;
+esac
 
-pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
-check pv_field $dev1 pe_start $pv_align
+pvcreate --metadatasize 128k --dataalignment 3.5k "$dev1"
+check pv_field "$dev1" pe_start $pv_align
 
-pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
-check pv_field $dev1 pe_start $pv_align
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k "$dev1"
+check pv_field "$dev1" pe_start $pv_align
 
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="1052160B" # 1048576 + (7*512)
-pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
-check pv_field $dev1 pe_start $pv_align "--units b"
+pv_align=1052160B # 1048576 + (7*512)
+pvcreate --metadatasize 128k --dataalignmentoffset 7s "$dev1"
+check pv_field "$dev1" pe_start $pv_align --units b
 
 # 2nd metadata area is created without problems when
 # data area start is shifted by the specified alignment_offset
-pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s $dev1
-check pv_field $dev1 pv_mda_count 2
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s "$dev1"
+check pv_field "$dev1" pv_mda_count 2
 # FIXME: compare start of 2nd mda with and without --dataalignmentoffset
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
-pvcreate --dataalignment 256k $dev1
-vgcreate -s 1m $vg $dev1
+pvcreate --dataalignment 256k "$dev1"
+vgcreate -s 1m $vg "$dev1"
 vgconvert -M1 $vg
 vgconvert -M2 $vg
-check pv_field $dev1 pe_start 256.00k
+check pv_field "$dev1" pe_start 256.00k
 vgremove $vg
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
-pvcreate --dataalignment 10k $dev1
-vgcreate -s 1m $vg $dev1
+pvcreate --dataalignment 10k "$dev1"
+vgcreate -s 1m $vg "$dev1"
 not vgconvert -M1 $vg
 vgremove $vg
 
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,
 #not that final cfg is usable...
-pvcreate --metadatacopies 0 $dev1
-pvcreate $dev2
-vgcreate $vg $dev1 $dev2
-vgcfgbackup -f "$(pwd)/backup.$$" $vg
-sed 's/pe_start = [0-9]*/pe_start = 0/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
-vgcfgrestore -f "$(pwd)/backup.$$1" $vg
-check pv_field $dev1 pe_start 0
-check pv_field $dev2 pe_start 0
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+vgcfgbackup -f backup.$$ $vg
+sed 's/pe_start = [0-9]*/pe_start = 0/' backup.$$ > backup.$$1
+vgcfgrestore -f backup.$$1 $vg
+check pv_field "$dev1" pe_start "0"
+check pv_field "$dev2" pe_start "0"
 vgremove $vg
 
-echo test pvcreate --metadataignore
+echo "test pvcreate --metadataignore"
 for pv_in_vg in 1 0; do
 for mdacp in 1 2; do
 for ignore in y n; do
-	echo pvcreate --metadataignore has proper mda_count and mda_used_count
-	pvcreate --metadatacopies $mdacp --metadataignore $ignore $dev1 $dev2
-	check pv_field $dev1 pv_mda_count $mdacp
-	check pv_field $dev2 pv_mda_count $mdacp
+	echo "pvcreate --metadataignore has proper mda_count and mda_used_count"
+	pvcreate --metadatacopies $mdacp --metadataignore $ignore "$dev1" "$dev2"
+	check pv_field "$dev1" pv_mda_count "$mdacp"
+	check pv_field "$dev2" pv_mda_count "$mdacp"
 	if [ $ignore = y ]; then
-		check pv_field $dev1 pv_mda_used_count 0
-		check pv_field $dev2 pv_mda_used_count 0
+		check pv_field "$dev1" pv_mda_used_count "0"
+		check pv_field "$dev2" pv_mda_used_count "0"
 	else
-		check pv_field $dev1 pv_mda_used_count $mdacp
-		check pv_field $dev2 pv_mda_used_count $mdacp
+		check pv_field "$dev1" pv_mda_used_count "$mdacp"
+		check pv_field "$dev2" pv_mda_used_count "$mdacp"
 	fi
-	echo vgcreate has proper vg_mda_count and vg_mda_used_count
+	echo "vgcreate has proper vg_mda_count and vg_mda_used_count"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate -c n "$vg" $dev1 $dev2
-		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		vgcreate -c n $vg "$dev1" "$dev2"
+		check vg_field $vg vg_mda_count "$(($mdacp * 2))"
 		if [ $ignore = y ]; then
-			check vg_field $vg vg_mda_used_count 1
+			check vg_field $vg vg_mda_used_count "1"
 		else
-			check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+			check vg_field $vg vg_mda_used_count "$(($mdacp * 2))"
 		fi
-		check vg_field $vg vg_mda_copies unmanaged
+		check vg_field $vg vg_mda_copies "unmanaged"
 		vgremove $vg
 	fi
 done
--- LVM2/test/shell/pvmove-basic.sh	2012/03/04 16:02:19	1.2
+++ LVM2/test/shell/pvmove-basic.sh	2012/03/16 13:00:06	1.3
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 # Copyright (C) 2007 NEC Corporation
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -58,31 +58,31 @@
 FIRST=""
 
 prepare_lvs_() {
-  lvcreate -l2 -n $lv1 $vg $dev1 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1
-  lvcreate -l9 -i3 -n $lv2 $vg $dev2 $dev3 $dev4 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4
-  lvextend -l+2 $vg/$lv1 $dev2 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2
-  lvextend -l+2 $vg/$lv1 $dev3 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3
-  lvextend -l+2 $vg/$lv1 $dev1 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1
-  lvcreate -l1 -n $lv3 $vg $dev2 
-    test -z "$FIRST" && lv_is_on_ $vg/$lv3 $dev2
-  save_dev_sum_ $(lvdev_ $vg $lv1) 
-  save_dev_sum_ $(lvdev_ $vg $lv2) 
-  save_dev_sum_ $(lvdev_ $vg $lv3) 
+  lvcreate -l2 -n $lv1 $vg "$dev1"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1"
+  lvcreate -l9 -i3 -n $lv2 $vg "$dev2" "$dev3" "$dev4"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev4"
+  lvextend -l+2 $vg/$lv1 "$dev2"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2"
+  lvextend -l+2 $vg/$lv1 "$dev3"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev3"
+  lvextend -l+2 $vg/$lv1 "$dev1"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev3" "$dev1"
+  lvcreate -l1 -n $lv3 $vg "$dev2"
+    test -z "$FIRST" && lv_is_on_ $vg/$lv3 "$dev2"
+  save_dev_sum_ $(lvdev_ $vg $lv1)
+  save_dev_sum_ $(lvdev_ $vg $lv2)
+  save_dev_sum_ $(lvdev_ $vg $lv3)
   if test -z "$FIRST" ; then
-    lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs
-    lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs
-    lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+    get lv_field $vg/$lv1 devices > ${lv1}_devs
+    get lv_field $vg/$lv2 devices > ${lv2}_devs
+    get lv_field $vg/$lv3 devices > ${lv3}_devs
   fi
   FIRST=done
 }
 
 lv_not_changed_() {
-  lvs -a -o devices --noheadings $1 > out
+  get lv_field $1 devices > out
   diff $(basename $1)_devs out
 }
 
@@ -110,276 +110,276 @@
 # filter by LV
 
 #COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
-prepare_lvs_ 
-pvmove -i1 -n $vg/$lv1 $dev2 $dev5
-lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i1 -n $vg/$lv1 "$dev2" "$dev5"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3" "$dev1"
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # segments in a LV
 
 #COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv1 $dev1 $dev4
-lv_is_on_ $vg/$lv1 $dev4 $dev2 $dev3 $dev4 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv1 "$dev1" "$dev4"
+lv_is_on_ $vg/$lv1 "$dev4" "$dev2" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv1 $dev2 $dev4
-lv_is_on_ $vg/$lv1 $dev1 $dev4 $dev3 $dev1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv1 "$dev2" "$dev4"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev4" "$dev3" "$dev1"
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv1 $dev3 $dev4
-lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev4 $dev1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv1 "$dev3" "$dev4"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev1"
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # multiple LVs matching
 
 #COMM "1 out of 3 LVs is moved: from pv4 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev4 $dev5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev5 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev4" "$dev5"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev5"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "2 out of 3 LVs are moved: from pv3 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev3 $dev5
-lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 $dev1 
-lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev3" "$dev5"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev5" "$dev1"
+lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "3 out of 3 LVs are moved: from pv2 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev2 $dev5
-lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
-lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
-lv_is_on_ $vg/$lv3 $dev5 
+prepare_lvs_
+pvmove -i0 "$dev2" "$dev5"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3" "$dev1"
+lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
+lv_is_on_ $vg/$lv3 "$dev5"
 check_and_cleanup_lvs_
 
 # ---
 # areas of striping
 
 #COMM "move the 1st stripe: from pv2 of lv2 to pv1"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv2 $dev2 $dev1
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev1 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv2 "$dev2" "$dev1"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev1" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv2 $dev3 $dev1
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv2 "$dev3" "$dev1"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev1" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
-prepare_lvs_ 
-pvmove -i0 -n $vg/$lv2 $dev4 $dev1
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev1 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 -n $vg/$lv2 "$dev4" "$dev1"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev1"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # partial segment match (source segment splitted)
 
 #COMM "match to the start of segment:from pv2:0-0 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev2:0-0 $dev5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev5 $dev2 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev2":0-0 "$dev5"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev5" "$dev2" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "match to the middle of segment: from pv2:1-1 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev2:1-1 $dev5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev2 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev2":1-1 "$dev5"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev2" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "match to the end of segment: from pv2:2-2 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev2:2-2 $dev5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev2":2-2 "$dev5"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # destination segment splitted
 
 #COMM "no destination split: from pv2:0-2 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev2:0-2 $dev5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev2":0-2 "$dev5"
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
-prepare_lvs_ 
-pvmove -i0 --alloc anywhere $dev2:0-2 $dev5:5-5 $dev4:5-6
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev5 $dev4 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev5" "$dev4" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
-prepare_lvs_ 
-pvmove -i0 --alloc anywhere $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev3 $dev4 $dev5 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 --alloc anywhere "$dev2":0-2 "$dev3":5-5 "$dev4":5-5 "$dev5":5-5
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev3" "$dev4" "$dev5" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # alloc policy (anywhere, contiguous) with both success and failure cases
 
-#COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" 
-prepare_lvs_ 
-not pvmove -i0 $dev3:0-2 $dev3:5-7
+#COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7"
+prepare_lvs_
+not pvmove -i0 "$dev3":0-2 "$dev3":5-7
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+lv_not_changed_ $vg/$lv1
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
-prepare_lvs_ 
-pvmove -i0 --alloc anywhere $dev3:0-2 $dev3:5-7
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev2" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5"
-prepare_lvs_ 
-pvmove -i0 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5
-lv_not_changed_ $vg/$lv1 
-#lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 --alloc anywhere "$dev3":0-2 "$dev3":5-7 "$dev5":5-6 "$dev4":5-5
+lv_not_changed_ $vg/$lv1
+#lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
-prepare_lvs_ 
-not pvmove -i0 --alloc contiguous $dev2:0-2 $dev5:5-5 $dev4:5-6
+prepare_lvs_
+not pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":5-5 "$dev4":5-6
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+lv_not_changed_ $vg/$lv1
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
-prepare_lvs_ 
-pvmove -i0 --alloc contiguous $dev2:0-2 $dev5:0-0 $dev5:3-5 $dev4:5-6
-lv_not_changed_ $vg/$lv1 
-lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 --alloc contiguous "$dev2":0-2 "$dev5":0-0 "$dev5":3-5 "$dev4":5-6
+lv_not_changed_ $vg/$lv1
+lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # multiple segments in a LV
 
 #COMM "multiple source LVs: from pv3 to pv5"
-prepare_lvs_ 
-pvmove -i0 $dev3 $dev5
-lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 
-lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
-lv_not_changed_ $vg/$lv3 
+prepare_lvs_
+pvmove -i0 "$dev3" "$dev5"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev5"
+lv_is_on_ $vg/$lv2 "$dev2" "$dev5" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---
 # move inactive LV
 
 #COMM "move inactive LV: from pv2 to pv5"
-prepare_lvs_ 
-lvchange -an $vg/$lv1 
-lvchange -an $vg/$lv3 
-pvmove -i0 $dev2 $dev5
-lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 
-lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
-lv_is_on_ $vg/$lv3 $dev5 
+prepare_lvs_
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv3
+pvmove -i0 "$dev2" "$dev5"
+lv_is_on_ $vg/$lv1 "$dev1" "$dev5" "$dev3"
+lv_is_on_ $vg/$lv2 "$dev5" "$dev3" "$dev4"
+lv_is_on_ $vg/$lv3 "$dev5"
 check_and_cleanup_lvs_
 
 # ---
 # other failure cases
 
 #COMM "no PEs to move: from pv3 to pv1"
-prepare_lvs_ 
-pvmove -i0 $dev3 $dev1
-not pvmove -i0 $dev3 $dev1
+prepare_lvs_
+pvmove -i0 "$dev3" "$dev1"
+not pvmove -i0 "$dev3" "$dev1"
 # "(cleanup previous test)"
-lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev1 
-lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
-lv_not_changed_ $vg/$lv3 
+lv_is_on_ $vg/$lv1 "$dev1" "$dev2" "$dev1"
+lv_is_on_ $vg/$lv2 "$dev2" "$dev1" "$dev4"
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
-#COMM "no space available: from pv2:0-0 to pv1:0-0" 
-prepare_lvs_ 
-not pvmove -i0 $dev2:0-0 $dev1:0-0
+#COMM "no space available: from pv2:0-0 to pv1:0-0"
+prepare_lvs_
+not pvmove -i0 "$dev2":0-0 "$dev1":0-0
 # "(cleanup previous test)"
-lv_not_changed_ $vg/$lv1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+lv_not_changed_ $vg/$lv1
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM 'same source and destination: from pv1 to pv1'
-prepare_lvs_ 
-not pvmove -i0 $dev1 $dev1
+prepare_lvs_
+not pvmove -i0 "$dev1" "$dev1"
 #"(cleanup previous test)"
-lv_not_changed_ $vg/$lv1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+lv_not_changed_ $vg/$lv1
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 #COMM "sum of specified destination PEs is large enough, but it includes source PEs and the free PEs are not enough"
-prepare_lvs_ 
-not pvmove --alloc anywhere $dev1:0-2 $dev1:0-2 $dev5:0-0 2> err
+prepare_lvs_
+not pvmove --alloc anywhere "$dev1":0-2 "$dev1":0-2 "$dev5":0-0 2> err
 #"(cleanup previous test)"
-grep "Insufficient free space" err 
-lv_not_changed_ $vg/$lv1 
-lv_not_changed_ $vg/$lv2 
-lv_not_changed_ $vg/$lv3 
+grep "Insufficient free space" err
+lv_not_changed_ $vg/$lv1
+lv_not_changed_ $vg/$lv2
+lv_not_changed_ $vg/$lv3
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
 #COMM "pvmove abort"
-prepare_lvs_ 
-pvmove -i100 -b $dev1 $dev3
-pvmove --abort 
+prepare_lvs_
+pvmove -i100 -b "$dev1" "$dev3"
+pvmove --abort
 check_and_cleanup_lvs_
 
 #COMM "pvmove out of --metadatacopies 0 PV (bz252150)"
 vgremove -ff $vg
 pvcreate $(cat DEVICES)
-pvcreate --metadatacopies 0 $dev1 $dev2
+pvcreate --metadatacopies 0 "$dev1" "$dev2"
 create_vg_
-lvcreate -l4 -n $lv1 $vg $dev1
-pvmove $dev1
+lvcreate -l4 -n $lv1 $vg "$dev1"
+pvmove "$dev1"
 
 #COMM "pvmove fails activating mirror, properly restores state before pvmove"
-dmsetup create "$vg-pvmove0" --notable
-not pvmove -i 1 $dev2
-test $(dmsetup info --noheadings -c -o suspended "$vg-$lv1") = "Active"
-dmsetup remove "$vg-pvmove0"
+dmsetup create $vg-pvmove0 --notable
+not pvmove -i 1 "$dev2"
+test $(dmsetup info --noheadings -c -o suspended $vg-$lv1) = "Active"
+dmsetup remove $vg-pvmove0
--- LVM2/test/shell/pvremove-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvremove-usage.sh	2012/03/16 13:00:06	1.2
@@ -12,57 +12,57 @@
 . lib/test
 
 aux prepare_devs 3
-pvcreate $dev1
-pvcreate --metadatacopies 0 $dev2
-pvcreate --metadatacopies 2 $dev3
-pvremove $dev2
+pvcreate "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+pvcreate --metadatacopies 2 "$dev3"
+pvremove "$dev2"
 
 # failing, but still removing everything what can be removed
 # is somewhat odd as default, what do we have -f for?
-pvs | not grep $dev2
-pvcreate  --metadatacopies 0 $dev2
+pvs | not grep "$dev2"
+pvcreate  --metadatacopies 0 "$dev2"
 
 # check pvremove refuses to remove pv in a vg
-vgcreate -c n $vg $dev1 $dev2
-not pvremove $dev2 $dev3
+vgcreate -c n $vg "$dev1" "$dev2"
+not pvremove "$dev2" "$dev3"
 
 for mdacp in 0 1 2; do
     # check pvremove truly wipes the label (pvscan wont find) (---metadatacopies $mdacp)
-    pvcreate --metadatacopies $mdacp $dev3
-    pvremove $dev3
+    pvcreate --metadatacopies $mdacp "$dev3"
+    pvremove "$dev3"
     # try to remove agail - should fail cleanly
-    not pvremove $dev3
-    pvscan | not grep $dev3
+    not pvremove "$dev3"
+    pvscan | not grep "$dev3"
 
 	# bz179473 refuse to wipe non-PV device without -f
-    not pvremove $dev3
-    pvremove -f $dev3
+    not pvremove "$dev3"
+    pvremove -f "$dev3"
 
     # reset setup
     vgremove -ff $vg
-    pvcreate --metadatacopies $mdacp $dev1
-    pvcreate $dev2
-    vgcreate $vg $dev1 $dev2 
+    pvcreate --metadatacopies $mdacp "$dev1"
+    pvcreate "$dev2"
+    vgcreate $vg "$dev1" "$dev2"
 
     # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
-    not pvremove -f $dev1
-    pvs $dev1
+    not pvremove -f "$dev1"
+    pvs "$dev1"
 
     # pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)
-    echo n | not pvremove -ff $dev1
+    echo n | not pvremove -ff "$dev1"
 
     # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
-    pvremove -ffy $dev1
-    not pvs $dev1
+    pvremove -ffy "$dev1"
+    not pvs "$dev1"
 
     vgreduce --removemissing $vg
-    pvcreate --metadatacopies $mdacp $dev1
-    vgextend $vg $dev1
+    pvcreate --metadatacopies $mdacp "$dev1"
+    vgextend $vg "$dev1"
 
     # pvremove -ff -y is sufficient when pv in a vg (---metadatacopies $mdacp)" '
-    pvremove -ff -y $dev1
+    pvremove -ff -y "$dev1"
 
     vgreduce --removemissing $vg
-    pvcreate --metadatacopies $mdacp $dev1
-    vgextend $vg $dev1
+    pvcreate --metadatacopies $mdacp "$dev1"
+    vgextend $vg "$dev1"
 done
--- LVM2/test/shell/read-ahead.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/read-ahead.sh	2012/03/16 13:00:06	1.2
@@ -17,36 +17,23 @@
 
 . lib/test
 
-
-get_lvs_() {
-   lvs --units s --nosuffix --noheadings -o $1 "$vg"/"$lv"
-}
-
-check_lvs_() {
-   case $(get_lvs_ $1) in
-    *$2) true ;;
-    *) false ;;
-   esac
-}
-
 aux prepare_vg 5
 
 #COMM "test various read ahead settings (bz450922)"
-lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"
-ra="$(get_lvs_ lv_kernel_read_ahead)"
-test "$(( ( $ra / 5 ) * 5 ))" -eq $ra
-lvdisplay "$vg"/"$lv"
-not lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
-check_lvs_ lv_read_ahead auto
-check_lvs_ lv_kernel_read_ahead 5120
-lvchange -r 640 "$vg/$lv"
-check_lvs_ lv_read_ahead 640
-lvremove -ff "$vg"
+lvcreate -l 100%FREE -i5 -I256 -n $lv $vg
+ra=$(get lv_field $vg/$lv lv_kernel_read_ahead --units s --nosuffix)
+test $(( ( $ra / 5 ) * 5 )) -eq $ra
+not lvchange -r auto $vg/$lv 2>&1 | grep auto
+check lv_field $vg/$lv lv_read_ahead auto
+check lv_field $vg/$lv lv_kernel_read_ahead 5120 --units s --nosuffix
+lvchange -r 640 $vg/$lv
+check lv_field $vg/$lv lv_read_ahead 640 --units s --nosuffix
+lvremove -ff $vg
 
 #COMM "read ahead is properly inherited from underlying PV"
-blockdev --setra 768 $dev1
+blockdev --setra 768 "$dev1"
 vgscan
-lvcreate -n $lv -L4m $vg $dev1
+lvcreate -n $lv -L4m $vg "$dev1"
 test $(blockdev --getra $DM_DEV_DIR/$vg/$lv) -eq 768
 lvremove -ff $vg
 
--- LVM2/test/shell/snapshot-autoumount-dmeventd.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/snapshot-autoumount-dmeventd.sh	2012/03/16 13:00:06	1.2
@@ -13,27 +13,30 @@
 
 . lib/test
 
-which mkfs.ext2 || exit 200
+which mkfs.ext2 || skip
 
 aux lvmconf "activation/snapshot_autoextend_percent = 0" \
             "activation/snapshot_autoextend_threshold = 100"
 
-aux prepare_vg 2
 aux prepare_dmeventd
+aux prepare_vg 2
+mntdir="${PREFIX}mnt"
 
 lvcreate -l 8 -n base $vg
-mkfs.ext2 $DM_DEV_DIR/$vg/base
+mkfs.ext2 "$DM_DEV_DIR/$vg/base"
 
 lvcreate -s -l 4 -n snap $vg/base
 lvchange --monitor y $vg/snap
 
-mkdir mnt
-mount $DM_DEV_DIR/mapper/$vg-snap mnt
+mkdir "$mntdir"
+mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 mount
-cat /proc/mounts | grep $vg-snap
+cat /proc/mounts | grep "$mntdir"
 
-dd if=/dev/zero of=mnt/file$1 bs=1M count=17
+dd if=/dev/zero of="$mntdir/file$1" bs=1M count=17
 sync
 sleep 10 # dmeventd only checks every 10 seconds :(
 
-cat /proc/mounts | not grep $vg-snap
+cat /proc/mounts | not grep "$mntdir"
+
+vgremove -f $vg
--- LVM2/test/shell/snapshot-merge.sh	2012/02/15 13:51:17	1.2
+++ LVM2/test/shell/snapshot-merge.sh	2012/03/16 13:00:06	1.3
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -8,14 +8,12 @@
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-set -xv
-
-which mkfs.ext3 || exit 200
 
 . lib/test
 
-lvdev_()
-{
+which mkfs.ext3 || skip
+
+lvdev_() {
     echo "$DM_DEV_DIR/$1/$2"
 }
 
@@ -23,16 +21,15 @@
     echo ${1}_snap
 }
 
-setup_merge() {
+setup_merge_() {
     local VG_NAME=$1
     local LV_NAME=$2
-    local NUM_EXTRA_SNAPS="$3"
-    test -z "$NUM_EXTRA_SNAPS" && NUM_EXTRA_SNAPS=0
+    local NUM_EXTRA_SNAPS=${3:-0}
     local BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
 
     lvcreate -n $LV_NAME -l 50%FREE $VG_NAME
     lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
-    mkfs.ext3 $(lvdev_ $VG_NAME $LV_NAME)
+    mkfs.ext3 "$(lvdev_ $VG_NAME $LV_NAME)"
 
     if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
 	for i in `seq 1 $NUM_EXTRA_SNAPS`; do
@@ -42,13 +39,13 @@
 }
 
 aux prepare_vg 1 100
-
+mkdir test_mnt
 
 # test full merge of a single LV
-setup_merge $vg $lv1
+setup_merge_ $vg $lv1
 # now that snapshot LV is created: test if snapshot-merge target is available
-$(dmsetup targets | grep snapshot-merge >/dev/null) || exit 200
-lvs -a
+aux target_at_least snapshot-merge 1 0 0 || skip
+
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge 2>err
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
@@ -56,30 +53,27 @@
 
 
 # test that an actively merging snapshot may not be removed
-setup_merge $vg $lv1
+setup_merge_ $vg $lv1
 lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
 not lvremove -f $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
 # "onactivate merge" test
-setup_merge $vg $lv1
-lvs -a
-mkdir test_mnt
-mount $(lvdev_ $vg $lv1) test_mnt
+setup_merge_ $vg $lv1
+mount "$(lvdev_ $vg $lv1)" test_mnt
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
-rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep " snapshot-origin "
+dmsetup table $vg-$lv1 | grep " snapshot-origin "
 
 # -- refresh LV to start merge (now that FS is unmounted),
 #    an active merge uses the 'snapshot-merge' target
 lvchange --refresh $vg/$lv1
 # check whether it's still merging - or maybe got already merged (slow test)
-dmsetup table ${vg}-${lv1} | grep " snapshot-merge " || dmsetup table ${vg}-${lv1} | grep " linear "
+dmsetup table $vg-$lv1 | grep " snapshot-merge " || dmsetup table $vg-$lv1 | grep " linear "
 # -- don't care if merge is still active; lvremove at this point
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
@@ -88,38 +82,33 @@
 # "onactivate merge" test
 # -- deactivate/remove after disallowed merge attempt, tests
 #    to make sure preload of origin's metadata is _not_ performed
-setup_merge $vg $lv1
-lvs -a
-mkdir test_mnt
-mount $(lvdev_ $vg $lv1) test_mnt
+setup_merge_ $vg $lv1
+mount "$(lvdev_ $vg $lv1)" test_mnt
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
-rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep " snapshot-origin " >/dev/null
+dmsetup table $vg-$lv1 | grep " snapshot-origin " >/dev/null
 lvremove -f $vg/$lv1
 
 
 # test multiple snapshot merge; tests copy out that is driven by merge
-setup_merge $vg $lv1 1
-lvs -a
+setup_merge_ $vg $lv1 1
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
 # test merging multiple snapshots that share the same tag
-setup_merge $vg $lv1
-setup_merge $vg $lv2
-lvs -a
+setup_merge_ $vg $lv1
+setup_merge_ $vg $lv2
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
 lvconvert --merge @this_is_a_test
-lvs | not grep $(snap_lv_name_ $lv1)
-lvs | not grep $(snap_lv_name_ $lv2)
-lvremove -f $vg/$lv1
-lvremove -f $vg/$lv2
+lvs $vg >out
+not grep $(snap_lv_name_ $lv1) out
+not grep $(snap_lv_name_ $lv2) out
+lvremove -f $vg/$lv1 $vg/$lv2
 
 # FIXME following tests would need to poll merge progress, via periodic lvs?
 # Background processes don't lend themselves to lvm testsuite...
@@ -130,5 +119,4 @@
 
 # test: multiple onactivate merge
 
-
-vgremove -f "$vg"
+vgremove -f $vg
--- LVM2/test/shell/snapshots-of-mirrors.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/snapshots-of-mirrors.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -40,5 +41,5 @@
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv
 
-# Clean-up
-lvremove -ff $vg
+## Clean-up
+vgremove -f $vg
--- LVM2/test/shell/tags.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/tags.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,5 @@
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,19 +11,18 @@
 
 . lib/test
 
-aux prepare_pvs 5
+aux prepare_pvs 4
 
 # vgcreate with --addtag
-vgcreate -c n --addtag firstvg $vg1 $dev1 $dev2
-vgcreate -c n --addtag secondvg $vg2 $dev3 $dev4
-check vg_field $vg1 tags firstvg
-check vg_field $vg2 tags secondvg
-vgremove -ff $vg1
-vgremove -ff $vg2
+vgcreate -c n --addtag firstvg $vg1 "$dev1" "$dev2"
+vgcreate -c n --addtag secondvg $vg2 "$dev3" "$dev4"
+check vg_field $vg1 tags "firstvg"
+check vg_field $vg2 tags "secondvg"
+vgremove -f $vg1 $vg2
 
 # vgchange with --addtag and --deltag
-vgcreate -c n $vg1 $dev1 $dev2
-vgcreate -c n $vg2 $dev3 $dev4
+vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate -c n $vg2 "$dev3" "$dev4"
 vgchange --addtag firstvgtag1 $vg1
 # adding a tag multiple times is not an error
 vgchange --addtag firstvgtag2 $vg1
@@ -38,21 +38,20 @@
 # deleting a tag multiple times is not an error
 vgchange --deltag firstvgtag2 $vg1
 vgchange --deltag firstvgtag1 $vg2
-vgremove -ff $vg1
-vgremove -ff $vg2
+vgremove -f $vg1 $vg2
 
 # lvcreate with --addtag
-vgcreate -c n $vg1 $dev1 $dev2
+vgcreate -c n $vg1 "$dev1" "$dev2"
 lvcreate --addtag firstlvtag1 -l 4 -n $lv1 $vg1
 lvcreate --addtag secondlvtag1 -l 4 -n $lv2 $vg1
 check lv_field @firstlvtag1 tags "firstlvtag1"
 not check lv_field @secondlvtag1 tags "firstlvtag1"
 check lv_field $vg1/$lv2 tags "secondlvtag1"
 not check lv_field $vg1/$lv1 tags "secondlvtag1"
-vgremove -ff $vg1
+vgremove -f $vg1
 
 # lvchange with --addtag and --deltag
-vgcreate -c n $vg1 $dev1 $dev2
+vgcreate -c n $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv2 $vg1
 lvchange --addtag firstlvtag1 $vg1/$lv1
@@ -64,9 +63,9 @@
 lvchange --addtag secondlvtag2 $vg1/$lv2
 lvchange --addtag secondlvtag3 $vg1/$lv2
 check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag2,firstlvtag3"
-not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
+not check lv_field $vg1/$lv1 tags "secondlvtag1"
 check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
-not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
+not check lv_field $vg1/$lv1 tags "secondlvtag1"
 # deleting a tag multiple times is not an error
 lvchange --deltag firstlvtag2 $vg1/$lv1
 lvchange --deltag firstlvtag2 $vg1/$lv1
--- LVM2/test/shell/test-partition.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/test-partition.sh	2012/03/16 13:00:06	1.2
@@ -14,17 +14,18 @@
 # excercises partition table scanning code path
 #
 
-which sfdisk || exit 200
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
 . lib/test
 
+which sfdisk || skip
+
 aux prepare_pvs 1 30
 
-pvs
+pvs "$dev1"
 
 # create small partition table
-echo "1 2" | sfdisk $dev1
+echo "1 2" | sfdisk "$dev1"
 
-pvs
+pvs "$dev1"
--- LVM2/test/shell/topology-support.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/topology-support.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -8,39 +9,36 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-which mkfs.ext3 || exit 200
-
 . lib/test
 
-check_logical_block_size()
-{
+which mkfs.ext3 || skip
+
+check_logical_block_size() {
     local DEV_=$(cat SCSI_DEBUG_DEV)
     # Verify logical_block_size - requires Linux >= 2.6.31
-    SYSFS_LOGICAL_BLOCK_SIZE=`echo /sys/block/$(basename $DEV_)/queue/logical_block_size`
+    SYSFS_LOGICAL_BLOCK_SIZE=$(echo /sys/block/$(basename $DEV_)/queue/logical_block_size)
     if [ -f "$SYSFS_LOGICAL_BLOCK_SIZE" ] ; then
-	ACTUAL_LOGICAL_BLOCK_SIZE=`cat $SYSFS_LOGICAL_BLOCK_SIZE`
+	ACTUAL_LOGICAL_BLOCK_SIZE=$(cat $SYSFS_LOGICAL_BLOCK_SIZE)
 	test $ACTUAL_LOGICAL_BLOCK_SIZE = $1
     fi
 }
 
-lvdev_()
-{
+lvdev_() {
     echo "$DM_DEV_DIR/$1/$2"
 }
 
-test_snapshot_mount()
-{
-    lvcreate -L 16M -n $lv1 $vg $dev1
+test_snapshot_mount() {
+    lvcreate -L 16M -n $lv1 $vg "$dev1"
     mkfs.ext3 $(lvdev_ $vg $lv1)
     mkdir test_mnt
-    mount $(lvdev_ $vg $lv1) test_mnt
+    mount "$(lvdev_ $vg $lv1)" test_mnt
     lvcreate -L 16M -n $lv2 -s $vg/$lv1
     umount test_mnt
     # mount the origin
-    mount $(lvdev_ $vg $lv1) test_mnt
+    mount "$(lvdev_ $vg $lv1)" test_mnt
     umount test_mnt
     # mount the snapshot
-    mount $(lvdev_ $vg $lv2) test_mnt
+    mount "$(lvdev_ $vg $lv2)" test_mnt
     umount test_mnt
     rm -r test_mnt
     vgchange -an $vg
@@ -58,7 +56,7 @@
 aux prepare_scsi_debug_dev $DEV_SIZE
 if [ ! -e /sys/block/$(basename $(cat SCSI_DEBUG_DEV))/alignment_offset ] ; then
 	aux cleanup_scsi_debug_dev
-	exit 200
+	skip
 fi
 aux cleanup_scsi_debug_dev
 
--- LVM2/test/shell/unlost-pv.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/unlost-pv.sh	2012/03/16 13:00:06	1.2
@@ -11,28 +11,28 @@
 
 . lib/test
 
+check_() {
+	vgscan 2>&1 | tee vgscan.out
+	grep "Inconsistent metadata found for VG $vg" vgscan.out
+	vgscan 2>&1 | tee vgscan.out
+	not grep "Inconsistent metadata found for VG $vg" vgscan.out
+}
+
 aux prepare_vg 3
 
 lvcreate -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
-check() {
-vgscan 2>&1 | tee vgscan.out
-grep "Inconsistent metadata found for VG $vg" vgscan.out
-vgscan 2>&1 | tee vgscan.out
-not grep "Inconsistent metadata found for VG $vg" vgscan.out
-}
-
 # try orphaning a missing PV (bz45867)
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 vgreduce --removemissing --force $vg
-aux enable_dev $dev1
-check
+aux enable_dev "$dev1"
+check_
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
-vgextend $vg $dev1
-aux disable_dev $dev1
+vgextend $vg "$dev1"
+aux disable_dev "$dev1"
 lvremove $vg/mirror
-aux enable_dev $dev1
-check
+aux enable_dev "$dev1"
+check_
--- LVM2/test/shell/vgcfgbackup-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgcfgbackup-usage.sh	2012/03/16 13:00:06	1.2
@@ -16,29 +16,28 @@
 # vgcfgbackup handles similar VG names (bz458941)
 vg1=${PREFIX}vg00
 vg2=${PREFIX}vg01
-vgcreate $vg1 $dev1
-vgcreate $vg2 $dev2
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
 vgcfgbackup -f $TESTDIR/bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
-vgremove -ff $vg1
-vgremove -ff $vg2
+vgremove -ff $vg1 $vg2
 
 # vgcfgbackup correctly stores metadata with missing PVs
 # and vgcfgrestore able to restore them when device reappears
-pv1_uuid=$(pvs --noheadings -o pv_uuid $dev1)
-pv2_uuid=$(pvs --noheadings -o pv_uuid $dev2)
+pv1_uuid=$(get pv_field "$dev1" pv_uuid)
+pv2_uuid=$(get pv_field "$dev2" pv_uuid)
 vgcreate $vg $(cat DEVICES)
-lvcreate -l1 -n $lv1 $vg $dev1
-lvcreate -l1 -n $lv2 $vg $dev2
-lvcreate -l1 -n $lv3 $vg $dev3
+lvcreate -l1 -n $lv1 $vg "$dev1"
+lvcreate -l1 -n $lv2 $vg "$dev2"
+lvcreate -l1 -n $lv3 $vg "$dev3"
 vgchange -a n $vg
-pvcreate -ff -y $dev1
-pvcreate -ff -y $dev2
+pvcreate -ff -y "$dev1"
+pvcreate -ff -y "$dev2"
 vgcfgbackup -f "$(pwd)/backup.$$" $vg
 sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
-pvcreate -ff -y --norestorefile -u $pv1_uuid $dev1
-pvcreate -ff -y --norestorefile -u $pv2_uuid $dev2
+pvcreate -ff -y --norestorefile -u $pv1_uuid "$dev1"
+pvcreate -ff -y --norestorefile -u $pv2_uuid "$dev2"
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
 vgremove -ff $vg
 
@@ -48,7 +47,7 @@
 vgscan
 pvcreate -M1 $(cat DEVICES)
 vgcreate -M1 -c n $vg $(cat DEVICES)
-lvcreate -l1 -n $lv1 $vg $dev1
-pvremove -ff -y $dev2
-not lvcreate -l1 -n $lv1 $vg $dev3
+lvcreate -l1 -n $lv1 $vg "$dev1"
+pvremove -ff -y "$dev2"
+not lvcreate -l1 -n $lv1 $vg "$dev3"
 vgcfgbackup -f "$(pwd)/backup.$$" $vg
--- LVM2/test/shell/vgchange-maxlv.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgchange-maxlv.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -14,14 +14,13 @@
 aux prepare_dmeventd
 aux prepare_pvs 3
 
-vgcreate -c n -l 2 $vg $dev1 $dev2 $dev3
+vgcreate -c n -l 2 $vg $(cat DEVICES)
 lvcreate -n one -l 1 $vg
 lvcreate -n two -l 1 $vg
 not lvcreate -n three -l 1 $vg
-vgchange -an $vg
 vgremove -ff $vg
 
-vgcreate -c n -l 3 $vg $dev1 $dev2 $dev3
+vgcreate -c n -l 3 $vg $(cat DEVICES)
 lvcreate -n one -l 1 $vg
 lvcreate -n snap -s -l 1 $vg/one
 lvcreate -n two -l 1 $vg
--- LVM2/test/shell/vgchange-sysinit.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgchange-sysinit.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,32 +11,32 @@
 
 . lib/test
 
-which mkfs.ext3 || exit 200
+which mkfs.ext3 || skip
 
 aux prepare_pvs 2 8
-test -e LOCAL_CLVMD && exit 200
+test -e LOCAL_CLVMD && skip
 
 var_lock="$DM_DEV_DIR/$vg1/$lv1"
 # keep in sync with aux configured lockingdir
-mount_dir="$TESTDIR/var/lock/lvm"
+mount_dir="var/lock/lvm"
 
 cleanup_mounted_and_teardown()
 {
-	umount $mount_dir || true
+	umount "$mount_dir" || true
 	aux teardown
 }
 
-vgcreate -c n $vg1 $dev1
-vgcreate -c n $vg2 $dev2
+vgcreate -c n $vg1 "$dev1"
+vgcreate -c n $vg2 "$dev2"
 
 lvcreate -l 1 -n $lv2 $vg2
 vgchange -an $vg2
 
 lvcreate -n $lv1 -l 100%FREE $vg1
-mkfs.ext3 -b4096 -j $var_lock
+mkfs.ext3 -b4096 -j "$var_lock"
 
 trap 'cleanup_mounted_and_teardown' EXIT
-mount -n -r $var_lock $mount_dir
+mount -n -r "$var_lock" "$mount_dir"
 
 # locking must fail on read-only filesystem
 not vgchange -ay $vg2
--- LVM2/test/shell/vgchange-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgchange-usage.sh	2012/03/16 13:00:06	1.2
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_pvs 3
-pvcreate --metadatacopies 0 $dev1
+pvcreate --metadatacopies 0 "$dev1"
 vgcreate $vg $(cat DEVICES)
 
 vgdisplay $vg
@@ -34,8 +34,8 @@
 vgchange -l 128 $vg
 aux check vg_field $vg max_lv 128
 
-lvcreate -l4 -n$lv1 $vg
-lvcreate -l4 -n$lv2 $vg
+lvcreate -l4 -n $lv1 $vg
+lvcreate -l4 -n $lv2 $vg
 
 lv_count=$(get vg_field $vg lv_count)
 not vgchange -l 1 $vg 2>err
--- LVM2/test/shell/vgcreate-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgcreate-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,13 +14,13 @@
 . lib/test
 
 aux prepare_devs 3
-pvcreate $dev1 $dev2
-pvcreate --metadatacopies 0 $dev3
+pvcreate "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
 
 vg=${PREFIX}vg
 
 #COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
-vgcreate -c n $vg --physicalextentsize 8.00m $dev1 $dev2
+vgcreate -c n $vg --physicalextentsize 8.00m "$dev1" "$dev2"
 check vg_field  $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
@@ -28,62 +28,62 @@
 not vgck $vg
 
 #COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
-vgcreate -c n $vg --maxlogicalvolumes 128 $dev1 $dev2 
+vgcreate -c n $vg --maxlogicalvolumes 128 "$dev1" "$dev2" 
 check vg_field $vg max_lv 128 
 vgremove $vg
 
 #COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
-vgcreate -c n $vg --maxphysicalvolumes 128 $dev1 $dev2
+vgcreate -c n $vg --maxphysicalvolumes 128 "$dev1" "$dev2"
 check vg_field $vg max_pv 128
 vgremove $vg
 
 #COMM 'vgcreate rejects a zero physical extent size'
-not vgcreate -c n --physicalextentsize 0 $vg $dev1 $dev2 2>err
-grep "^  Physical extent size may not be zero\$" err
+not vgcreate -c n --physicalextentsize 0 $vg "$dev1" "$dev2" 2>err
+grep "Physical extent size may not be zero" err
 
 #COMM 'vgcreate rejects "inherit" allocation policy'
-not vgcreate -c n --alloc inherit $vg $dev1 $dev2 2>err
-grep "^  Volume Group allocation policy cannot inherit from anything\$" err
+not vgcreate -c n --alloc inherit $vg "$dev1" "$dev2" 2>err
+grep "Volume Group allocation policy cannot inherit from anything" err
 
 #COMM 'vgcreate rejects vgname "."'
 vginvalid=.; 
-not vgcreate -c n $vginvalid $dev1 $dev2 2>err
-grep "New volume group name \"$vginvalid\" is invalid\$" err
+not vgcreate -c n $vginvalid "$dev1" "$dev2" 2>err
+grep "New volume group name \"$vginvalid\" is invalid" err
 
 #COMM 'vgcreate rejects vgname greater than 128 characters'
 vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
-not vgcreate -c n $vginvalid $dev1 $dev2 2>err
-grep "New volume group name \"$vginvalid\" is invalid\$" err
+not vgcreate -c n $vginvalid "$dev1" "$dev2" 2>err
+grep "New volume group name \"$vginvalid\" is invalid" err
 
 #COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
 #touch /tmp/$vg
-#not vgcreate $vg $dev1 $dev2 2>err
+#not vgcreate $vg "$dev1" "$dev2" 2>err
 #grep "New volume group name \"$vg\" is invalid\$" err
 
 #COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
-vgcreate -c n $vg $dev1 $dev2
-not vgcreate -c n $vg $dev1 $dev2
+vgcreate -c n $vg "$dev1" "$dev2"
+not vgcreate -c n $vg "$dev1" "$dev2"
 vgremove -ff $vg
 
 #COMM 'vgcreate rejects MaxLogicalVolumes > 255'
-not vgcreate -c n --metadatatype 1 --maxlogicalvolumes 1024 $vg $dev1 $dev2 2>err
-grep "^  Number of volumes may not exceed 255\$" err
+not vgcreate -c n --metadatatype 1 --maxlogicalvolumes 1024 $vg "$dev1" "$dev2" 2>err
+grep "Number of volumes may not exceed 255" err
 
 #COMM "vgcreate fails when the only pv has --metadatacopies 0"
-not vgcreate -c n $vg $dev3
+not vgcreate -c n $vg "$dev3"
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
-not vgcreate -c n --physicalextentsize 0k $vg $dev1 $dev2
-vgcreate -c n --physicalextentsize 1k $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 0k $vg "$dev1" "$dev2"
+vgcreate -c n --physicalextentsize 1k $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 1.00k
 vgremove -ff $vg
-not vgcreate -c n --physicalextentsize 3K $vg $dev1 $dev2
-not vgcreate -c n --physicalextentsize 1024t $vg $dev1 $dev2
-#not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 3K $vg "$dev1" "$dev2"
+not vgcreate -c n --physicalextentsize 1024t $vg "$dev1" "$dev2"
+#not vgcreate --physicalextentsize 1T $vg "$dev1" "$dev2"
 # FIXME: vgcreate allows physicalextentsize larger than pv size!
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
-vgcreate -c n $vg $dev1 $dev2
+vgcreate -c n $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 4.00m
 check vg_field $vg max_lv 0
 check vg_field $vg max_pv 0
@@ -93,71 +93,71 @@
 # Implicit pvcreate tests, test pvcreate options on vgcreate
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
-pvremove $dev1 $dev2
-vgcreate -c n --force --yes --zero y $vg $dev1 $dev2
+pvremove "$dev1" "$dev2"
+vgcreate -c n --force --yes --zero y $vg "$dev1" "$dev2"
 vgremove -f $vg
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
-    vgcreate -c n --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    vgcreate -c n --labelsector $i $vg "$dev1"
+    dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgremove -f $vg
-    pvremove -f $dev1
+    pvremove -f "$dev1"
 done
 
 # pvmetadatacopies
 for i in 1 2
 do
-    vgcreate -c n --pvmetadatacopies $i $vg $dev1
-    check pv_field $dev1 pv_mda_count $i
+    vgcreate -c n --pvmetadatacopies $i $vg "$dev1"
+    check pv_field "$dev1" pv_mda_count $i
     vgremove -f $vg
-    pvremove -f $dev1
+    pvremove -f "$dev1"
 done
-not vgcreate -c n --pvmetadatacopies 0 $vg $dev1
-pvcreate --metadatacopies 1 $dev2
-vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
-check pv_field $dev1 pv_mda_count 0
-check pv_field $dev2 pv_mda_count 1
+not vgcreate -c n --pvmetadatacopies 0 $vg "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate -c n --pvmetadatacopies 0 $vg "$dev1" "$dev2"
+check pv_field "$dev1" pv_mda_count 0
+check pv_field "$dev2" pv_mda_count 1
 vgremove -f $vg
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
-vgcreate -c n --metadatasize 100k --dataalignment 100k $vg $dev1
-check pv_field $dev1 pe_start 200.00k
+vgcreate -c n --metadatasize 100k --dataalignment 100k $vg "$dev1"
+check pv_field "$dev1" pe_start 200.00k
 vgremove -f $vg
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="1052160B" # 1048576 + (7*512)
-vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check pv_field $dev1 pe_start $pv_align "--units b"
+pv_align=1052160 # 1048576 + (7*512)
+vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
+check pv_field "$dev1" pe_start ${pv_align}B --units b
 vgremove -f $vg
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 # metadatatype
 for i in 1 2
 do
-    vgcreate -c n -M $i $vg $dev1
+    vgcreate -c n -M $i $vg "$dev1"
     check vg_field $vg vg_fmt lvm$i
     vgremove -f $vg
-    pvremove -f $dev1
+    pvremove -f "$dev1"
 done
 
 # vgcreate fails if pv belongs to existing vg
-vgcreate -c n $vg1 $dev1 $dev2
-not vgcreate $vg2 $dev2
+vgcreate -c n $vg1 "$dev1" "$dev2"
+not vgcreate $vg2 "$dev2"
 vgremove -f $vg1
-pvremove -f $dev1 $dev2
+pvremove -f "$dev1" "$dev2"
 
 # all PVs exist in the VG after created
-pvcreate $dev1
-vgcreate -c n $vg1 $dev1 $dev2 $dev3
-check pv_field $dev1 vg_name $vg1
-check pv_field $dev2 vg_name $vg1
-check pv_field $dev3 vg_name $vg1
+pvcreate "$dev1"
+vgcreate -c n $vg1 "$dev1" "$dev2" "$dev3"
+check pv_field "$dev1" vg_name $vg1
+check pv_field "$dev2" vg_name $vg1
+check pv_field "$dev3" vg_name $vg1
 vgremove -f $vg1
-pvremove -f $dev1 $dev2 $dev3
+pvremove -f "$dev1" "$dev2" "$dev3"
--- LVM2/test/shell/vgextend-restoremissing.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgextend-restoremissing.sh	2012/03/16 13:00:06	1.2
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,20 +11,20 @@
 
 . lib/test
 
-
 aux prepare_vg 3
+
 lvcreate -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
-lvcreate -l 1 -n lv1 $vg $dev1
+lvcreate -l 1 -n lv1 $vg "$dev1"
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 lvremove $vg/mirror
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
 not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
-vgextend --restore $vg $dev1 # restore the missing device
+vgextend --restore $vg "$dev1" # restore the missing device
 vgck $vg
 lvcreate -m 1 -l 1 -n mirror $vg
--- LVM2/test/shell/vgextend-usage.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/vgextend-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -20,100 +21,100 @@
 do
 
 # Explicit pvcreate
-pvcreate -M$mdatype $dev1 $dev2 $dev3 $dev4 $dev5
-vgcreate -M$mdatype $vg1 $dev1 $dev2
-vgextend $vg1 $dev3 $dev4 $dev5
+pvcreate -M$mdatype "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgextend $vg1 "$dev3" "$dev4" "$dev5"
 vgremove -ff $vg1
 
 # Implicit pvcreate
-pvremove $dev1 $dev2 $dev3 $dev4 $dev5
-vgcreate -M$mdatype $vg1 $dev1 $dev2
-vgextend -M$mdatype $vg1 $dev3 $dev4 $dev5
+pvremove "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgextend -M$mdatype $vg1 "$dev3" "$dev4" "$dev5"
 vgremove -ff $vg1
-pvremove $dev1 $dev2 $dev3 $dev4 $dev5
+pvremove "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
 done
 
 # Implicit pvcreate tests, test pvcreate options on vgcreate
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
-vgcreate $vg $dev2
-vgextend --force --yes --zero y $vg $dev1
-vgreduce $vg $dev1
-pvremove -f $dev1
+vgcreate $vg "$dev2"
+vgextend --force --yes --zero y $vg "$dev1"
+vgreduce $vg "$dev1"
+pvremove -f "$dev1"
 
 for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
-    vgextend --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
-    vgreduce $vg $dev1
-    pvremove -f $dev1
+    vgextend --labelsector $i $vg "$dev1"
+    dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
+    vgreduce $vg "$dev1"
+    pvremove -f "$dev1"
 done
 
 # pvmetadatacopies
 for i in 0 1 2
 do
-    vgextend --pvmetadatacopies $i $vg $dev1
-    check pv_field $dev1 pv_mda_count $i
-    vgreduce $vg $dev1
-    pvremove -f $dev1
+    vgextend --pvmetadatacopies $i $vg "$dev1"
+    check pv_field "$dev1" pv_mda_count $i
+    vgreduce $vg "$dev1"
+    pvremove -f "$dev1"
 done
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
-vgextend --metadatasize 100k --dataalignment 100k $vg $dev1
-check pv_field $dev1 pe_start 200.00k
-vgreduce $vg $dev1
-pvremove -f $dev1
+vgextend --metadatasize 100k --dataalignment 100k $vg "$dev1"
+check pv_field "$dev1" pe_start 200.00k
+vgreduce $vg "$dev1"
+pvremove -f "$dev1"
 
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="1052160B" # 1048576 + (7*512)
-vgextend --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check pv_field $dev1 pe_start $pv_align "--units b"
+pv_align=1052160B # 1048576 + (7*512)
+vgextend --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
+check pv_field "$dev1" pe_start $pv_align --units b
 vgremove -f $vg
-pvremove -f $dev1
+pvremove -f "$dev1"
 
 # vgextend fails if pv belongs to existing vg
-vgcreate $vg1 $dev1 $dev3
-vgcreate $vg2 $dev2
-not vgextend $vg2 $dev3
+vgcreate $vg1 "$dev1" "$dev3"
+vgcreate $vg2 "$dev2"
+not vgextend $vg2 "$dev3"
 vgremove -f $vg1
 vgremove -f $vg2
-pvremove -f $dev1 $dev2 $dev3
+pvremove -f "$dev1" "$dev2" "$dev3"
 
 #vgextend fails if vg is not resizeable
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 vgchange --resizeable n $vg1
-not vgextend $vg1 $dev3
+not vgextend $vg1 "$dev3"
 vgremove -f $vg1
-pvremove -f $dev1 $dev2
+pvremove -f "$dev1" "$dev2"
 
 # all PVs exist in the VG after extended
-pvcreate $dev1
-vgcreate $vg1 $dev2
-vgextend $vg1 $dev1 $dev3
-check pv_field $dev1 vg_name $vg1
-check pv_field $dev2 vg_name $vg1
-check pv_field $dev3 vg_name $vg1
+pvcreate "$dev1"
+vgcreate $vg1 "$dev2"
+vgextend $vg1 "$dev1" "$dev3"
+check pv_field "$dev1" vg_name $vg1
+check pv_field "$dev2" vg_name $vg1
+check pv_field "$dev3" vg_name $vg1
 vgremove -f $vg1
-pvremove -f $dev1 $dev2 $dev3
+pvremove -f "$dev1" "$dev2" "$dev3"
 
 echo test vgextend --metadataignore
 for mdacp in 1 2; do
 for ignore in y n; do
 	echo vgextend --metadataignore has proper mda_count and mda_used_count
-	vgcreate $vg $dev3
-	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg $dev1 $dev2
-	check pv_field $dev1 pv_mda_count $mdacp
-	check pv_field $dev2 pv_mda_count $mdacp
+	vgcreate $vg "$dev3"
+	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg "$dev1" "$dev2"
+	check pv_field "$dev1" pv_mda_count $mdacp
+	check pv_field "$dev2" pv_mda_count $mdacp
 	if [ $ignore = y ]; then
-		check pv_field $dev1 pv_mda_used_count 0
-		check pv_field $dev2 pv_mda_used_count 0
+		check pv_field "$dev1" pv_mda_used_count 0
+		check pv_field "$dev2" pv_mda_used_count 0
 	else
-		check pv_field $dev1 pv_mda_used_count $mdacp
-		check pv_field $dev2 pv_mda_used_count $mdacp
+		check pv_field "$dev1" pv_mda_used_count $mdacp
+		check pv_field "$dev2" pv_mda_used_count $mdacp
 	fi
 	echo vg has proper vg_mda_count and vg_mda_used_count
 	check vg_field $vg vg_mda_count $(($mdacp * 2 + 1))
@@ -124,6 +125,6 @@
 	fi
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove $vg
-	pvremove -ff $dev1 $dev2 $dev3
+	pvremove -ff "$dev1" "$dev2" "$dev3"
 done
 done
--- LVM2/test/shell/vgimportclone.sh	2012/02/23 23:58:42	1.3
+++ LVM2/test/shell/vgimportclone.sh	2012/03/16 13:00:06	1.4
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -12,26 +13,26 @@
 
 aux prepare_devs 2
 
-vgcreate -c n --metadatasize 128k $vg1 $dev1
+vgcreate -c n --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Clone the LUN
-dd if=$dev1 of=$dev2 bs=256K count=1
-aux notify_lvmetad $dev2
+dd if="$dev1" of="$dev2" bs=256K count=1
+aux notify_lvmetad "$dev2"
 
 # Verify pvs works on each device to give us vgname
-check pv_field $dev1 vg_name $vg1
-check pv_field $dev2 vg_name $vg1
+check pv_field "$dev1" vg_name $vg1
+check pv_field "$dev2" vg_name $vg1
 
 # Import the cloned PV to a new VG
-vgimportclone --basevgname $vg2 $dev2
+vgimportclone --basevgname $vg2 "$dev2"
 
 # We need to re-scan *both* $dev1 and $dev2 since a PV, as far as lvmetad is
 # concerned, can only live on a single device. With the last pvscan, we told it
 # that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
 # since we wrote a different PV over $dev2.
-aux notify_lvmetad $dev2
-aux notify_lvmetad $dev1
+aux notify_lvmetad "$dev2"
+aux notify_lvmetad "$dev1"
 
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
--- LVM2/test/shell/vgmerge-operation.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgmerge-operation.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,57 +16,57 @@
 aux prepare_pvs 4 64
 
 # 'vgmerge succeeds with single linear LV in source VG'
-vgcreate -c n $vg1 $dev1 $dev2 
-vgcreate -c n $vg2 $dev3 $dev4 
-lvcreate -l 4 -n $lv1 $vg1 $dev1 
-vgchange -an $vg1 
-check pvlv_counts $vg1 2 1 0 
-check pvlv_counts $vg2 2 0 0 
-vgmerge $vg2 $vg1 
-check pvlv_counts $vg2 4 1 0 
+vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate -c n $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 $vg1 "$dev1"
+vgchange -an $vg1
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 0 0
+vgmerge $vg2 $vg1
+check pvlv_counts $vg2 4 1 0
 vgremove -f $vg2
 
 # 'vgmerge succeeds with single linear LV in source and destination VG'
-vgcreate -c n $vg1 $dev1 $dev2 
-vgcreate -c n $vg2 $dev3 $dev4 
-lvcreate -l 4 -n $lv1 $vg1 
-lvcreate -l 4 -n $lv2 $vg2 
-vgchange -an $vg1 
-vgchange -an $vg2 
-check pvlv_counts $vg1 2 1 0 
-check pvlv_counts $vg2 2 1 0 
-vgmerge $vg2 $vg1 
-check pvlv_counts $vg2 4 2 0 
+vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate -c n $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv2 $vg2
+vgchange -an $vg1
+vgchange -an $vg2
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 1 0
+vgmerge $vg2 $vg1
+check pvlv_counts $vg2 4 2 0
 vgremove -f $vg2
 
 # 'vgmerge succeeds with linear LV + snapshots in source VG'
-vgcreate -c n $vg1 $dev1 $dev2 
-vgcreate -c n $vg2 $dev3 $dev4 
-lvcreate -l 16 -n $lv1 $vg1 
-lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
-vgchange -an $vg1 
-check pvlv_counts $vg1 2 2 1 
-check pvlv_counts $vg2 2 0 0 
-vgmerge $vg2 $vg1 
-check pvlv_counts $vg2 4 2 1 
-lvremove -f $vg2/$lv2 
+vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate -c n $vg2 "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 $vg1
+lvcreate -l 4 -s -n $lv2 $vg1/$lv1
+vgchange -an $vg1
+check pvlv_counts $vg1 2 2 1
+check pvlv_counts $vg2 2 0 0
+vgmerge $vg2 $vg1
+check pvlv_counts $vg2 4 2 1
+lvremove -f $vg2/$lv2
 vgremove -f $vg2
 
 # 'vgmerge succeeds with mirrored LV in source VG'
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 
-vgcreate -c n $vg2 $dev4 
-lvcreate -l 4 -n $lv1 -m1 $vg1 
-vgchange -an $vg1 
-check pvlv_counts $vg1 3 1 0 
-check pvlv_counts $vg2 1 0 0 
-vgmerge $vg2 $vg1 
-check pvlv_counts $vg2 4 1 0 
-lvremove -f $vg2/$lv1 
+vgcreate -c n $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate -c n $vg2 "$dev4"
+lvcreate -l 4 -n $lv1 -m1 $vg1
+vgchange -an $vg1
+check pvlv_counts $vg1 3 1 0
+check pvlv_counts $vg2 1 0 0
+vgmerge $vg2 $vg1
+check pvlv_counts $vg2 4 1 0
+lvremove -f $vg2/$lv1
 vgremove -f $vg2
 
 # 'vgmerge rejects LV name collision'
-vgcreate -c n $vg1 $dev1 $dev2
-vgcreate -c n $vg2 $dev3 $dev4
+vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate -c n $vg2 "$dev3" "$dev4"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv1 $vg2
 vgchange -an $vg1
@@ -76,6 +76,4 @@
 grep "Duplicate logical volume name \"$lv1\" in \"$vg2\" and \"$vg1" err
 check pvlv_counts $vg1 2 1 0
 check pvlv_counts $vg2 2 1 0
-vgremove -f $vg1
-vgremove -f $vg2
-
+vgremove -f $vg1 $vg2
--- LVM2/test/shell/vgmerge-usage.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgmerge-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,51 +17,51 @@
 
 # 'vgmerge normal operation'
 # ensure ordering does not matter
-vgcreate  $vg1 $dev1 $dev2 
-vgcreate  $vg2 $dev3 $dev4 
-vgmerge $vg1 $vg2 
+vgcreate  $vg1 "$dev1" "$dev2"
+vgcreate  $vg2 "$dev3" "$dev4"
+vgmerge $vg1 $vg2
 vgremove $vg1
-vgcreate -c n $vg2 $dev1 $dev2
-vgcreate -c n $vg1 $dev3 $dev4
+vgcreate -c n $vg2 "$dev1" "$dev2"
+vgcreate -c n $vg1 "$dev3" "$dev4"
 vgmerge $vg2 $vg1
 vgremove $vg2
 
 # 'vgmerge rejects duplicate vg name'
-vgcreate  $vg1 $dev1 $dev2 
-vgcreate  $vg2 $dev3 $dev4 
+vgcreate  $vg1 "$dev1" "$dev2"
+vgcreate  $vg2 "$dev3" "$dev4"
 not vgmerge $vg1 $vg1 2>err
-grep "^  Duplicate volume group name \"$vg1\"\$" err 
+grep "Duplicate volume group name \"$vg1\"\$" err
 vgremove $vg1 $vg2
 
 # 'vgmerge rejects vgs with incompatible extent_size'
-vgcreate  --physicalextentsize 4M $vg1 $dev1 $dev2 
-vgcreate  --physicalextentsize 8M $vg2 $dev3 $dev4 
+vgcreate  --physicalextentsize 4M $vg1 "$dev1" "$dev2"
+vgcreate  --physicalextentsize 8M $vg2 "$dev3" "$dev4"
 not vgmerge $vg1 $vg2 2>err
-grep "^  Extent sizes differ" err 
+grep "Extent sizes differ" err
 vgremove $vg1 $vg2
 
 # 'vgmerge rejects vgmerge because max_pv is exceeded'
-vgcreate  --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate  --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+vgcreate  --maxphysicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate  --maxphysicalvolumes 2 $vg2 "$dev3" "$dev4"
 not vgmerge $vg1 $vg2 2>err
-grep "^  Maximum number of physical volumes (2) exceeded" err 
+grep "Maximum number of physical volumes (2) exceeded" err
 vgremove $vg1 $vg2
 
 # 'vgmerge rejects vg with active lv'
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
-lvcreate -l 4 -n lv1 $vg2 
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n lv1 $vg2
 not vgmerge $vg1 $vg2 2>err
-grep "^  Logical volumes in \"$vg2\" must be inactive\$" err 
+grep "Logical volumes in \"$vg2\" must be inactive" err
 vgremove -f $vg1 $vg2
 
-# 'vgmerge rejects vgmerge because max_lv is exceeded' 
-vgcreate --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
-lvcreate -l 4 -n lv1 $vg1 
-lvcreate -l 4 -n lv2 $vg1 
-lvcreate -l 4 -n lv3 $vg2 
+# 'vgmerge rejects vgmerge because max_lv is exceeded'
+vgcreate --maxlogicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate --maxlogicalvolumes 2 $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n lv1 $vg1
+lvcreate -l 4 -n lv2 $vg1
+lvcreate -l 4 -n lv3 $vg2
 vgchange -an $vg1 $vg2
 not vgmerge $vg1 $vg2 2>err
-grep "^  Maximum number of logical volumes (2) exceeded" err 
+grep "Maximum number of logical volumes (2) exceeded" err
 vgremove -f $vg1 $vg2
--- LVM2/test/shell/vgreduce-removemissing-snapshot.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgreduce-removemissing-snapshot.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,16 +12,16 @@
 . lib/test
 
 aux prepare_vg 5
-lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+
+lvcreate -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
-lvcreate -i 2 -L 2M $vg $dev1 $dev2 -n stripe
+lvcreate -i 2 -L 2M $vg "$dev1" "$dev2" -n stripe
 
-aux disable_dev $dev2 $dev4
+aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way
-aux enable_dev $dev2 $dev4
+aux enable_dev "$dev2" "$dev4"
 #not vgreduce --removemissing $vg
-vgreduce -v --removemissing --force $vg # $dev2 $dev4
-lvs -a -o +devices | not grep unknown
-lvs -a -o +devices
-check mirror $vg 4way $dev5
-
+vgreduce -v --removemissing --force $vg # "$dev2" "$dev4"
+lvs -a -o +devices $vg | not grep unknown
+lvs -a -o +devices $vg
+check mirror $vg 4way "$dev5"
--- LVM2/test/shell/vgreduce-usage.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgreduce-usage.sh	2012/03/16 13:00:06	1.2
@@ -16,72 +16,74 @@
 for mdatype in 1 2
 do
     # setup PVs
-    pvcreate -M$mdatype $dev1 $dev2 
+    pvcreate -M$mdatype "$dev1" "$dev2"
 
     # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
-    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
-    vgreduce $vg1 $dev1
-    check pv_field $dev2 vg_name $vg1
+    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
+    vgreduce $vg1 "$dev1"
+    check pv_field "$dev2" vg_name $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
-    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
+    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
     not vgreduce --all $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv
-    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
-    not vgreduce $vg1 $dev1 $dev2
+    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
+    not vgreduce $vg1 "$dev1" "$dev2"
     vgremove -f $vg1
 
-    pvremove -ff $dev1 $dev2
+    pvremove -ff "$dev1" "$dev2"
 done
 
 mdatype=2 # we only expect the following to work for lvm2 metadata
 
 # (lvm$mdatype) setup PVs (--metadatacopies 0)
-pvcreate -M$mdatype $dev1 $dev2
-pvcreate --metadatacopies 0 -M$mdatype $dev3 $dev4
+pvcreate -M$mdatype "$dev1" "$dev2"
+pvcreate --metadatacopies 0 -M$mdatype "$dev3" "$dev4"
 
 # (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
-vgcreate -c n -M$mdatype $vg1 $dev1 $dev3
-not vgreduce $vg1 $dev1
+vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev3"
+not vgreduce $vg1 "$dev1"
 vgremove -f $vg1
 
 #COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
-vgcreate -c n -M$mdatype $vg1 $dev1 $dev2 $dev3
+vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -n $lv1 -m1 -l 4 $vg1
-lvcreate -n $lv2  -l 4 $vg1 $dev2
-lvcreate -n $lv3 -l 4 $vg1 $dev3
+lvcreate -n $lv2  -l 4 $vg1 "$dev2"
+lvcreate -n $lv3 -l 4 $vg1 "$dev3"
 vgchange -an $vg1
-aux disable_dev $dev1
+aux disable_dev "$dev1"
 # (lvm$mdatype) vgreduce --removemissing --force repares to linear
 vgreduce --removemissing --force $vg1
 check lv_field $vg1/$lv1 segtype linear
 check pvlv_counts $vg1 2 3 0
 # cleanup
-aux enable_dev $dev1
+aux enable_dev "$dev1"
 pvscan
-vgremove -ff $vg1
+vgremove -f $vg1
 not vgs $vg1 # just double-check it's really gone
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
 vgcreate -c n -M$mdatype $vg1 $(cat DEVICES)
 lvcreate -n $lv2 -l 4 $vg1
-lvcreate -m1 -n $lv1 -l 4 $vg1 $dev1 $dev2 $dev3
-lvcreate -n $lv3 -l 4 $vg1 $dev3
-pvs --segments -o +lv_name # for record only
+lvcreate -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -n $lv3 -l 4 $vg1 "$dev3"
+pvs --segments -o +lv_name $(cat DEVICES) # for record only
 # (lvm$mdatype) setup: damage one pv
-vgchange -an $vg1 
-aux disable_dev $dev1
-#pvcreate -ff -y $dev1
+vgchange -an $vg1
+aux disable_dev "$dev1"
+#pvcreate -ff -y "$dev1"
 # vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too
-not vgreduce -c n --removemissing --mirrorsonly --force $vg1
-
-aux enable_dev $dev1
-
-pvs -P # for record
-lvs -P # for record
-vgs -P # for record
+#not vgreduce -c n --removemissing --mirrorsonly --force $vg1
+# CHECKME - command above was rejected becuase of '-c n'
+vgreduce --removemissing --mirrorsonly --force $vg1
+
+aux enable_dev "$dev1"
+
+pvs -P $(cat DEVICES) # for record
+lvs -P $vg1           # for record
+vgs -P $vg1           # for record
--- LVM2/test/shell/vgrename-usage.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgrename-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,13 +12,13 @@
 . lib/test
 
 aux prepare_devs 4
-pvcreate $dev1 $dev2
-pvcreate --metadatacopies 0 $dev3 $dev4
+pvcreate "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3" "$dev4"
 
 # vgrename normal operation - rename vg1 to vg2
 # vgrename normal operation - rename vg2 to vg1
 # ensure name ordering does not matter
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 vgrename $vg1 $vg2
 check vg_field $vg2 vg_name $vg2
 vgrename $vg2 $vg1
@@ -25,7 +26,7 @@
 vgremove $vg1
 
 # vgrename by uuid (bz231187)
-vgcreate $vg1 $dev1 $dev3
+vgcreate $vg1 "$dev1" "$dev3"
 UUID=$(vgs --noheading -o vg_uuid $vg1)
 check vg_field $vg1 vg_uuid $UUID
 vgrename $UUID $vg2
@@ -33,9 +34,7 @@
 vgremove $vg2
 
 # vgrename fails - new vg already exists
-vgcreate $vg1 $dev1
-vgcreate $vg2 $dev2
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
 not vgrename $vg1 $vg2
-vgremove $vg1
-vgremove $vg2
-
+vgremove $vg1 $vg2
--- LVM2/test/shell/vgsplit-operation.sh	2012/03/04 16:02:19	1.2
+++ LVM2/test/shell/vgsplit-operation.sh	2012/03/16 13:00:06	1.3
@@ -13,7 +13,7 @@
 
 . lib/test
 
-COMM() {  
+COMM() {
 	LAST_TEST="$@"
 }
 
@@ -37,74 +37,74 @@
 	for j in PV LV
 	do
 COMM "vgsplit correctly splits single linear LV into $i VG ($j args)"
-		create_vg_ $vg1 $dev1 $dev2
-		test $i = existing && create_vg_ $vg2 $dev3 $dev4
+		create_vg_ $vg1 "$dev1" "$dev2"
+		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
 
-		lvcreate -l 4 -n $lv1 $vg1 $dev1 
-		vgchange -an $vg1 
+		lvcreate -l 4 -n $lv1 $vg1 "$dev1"
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev1
+		  vgsplit $vg1 $vg2 "$dev1"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
-		fi 
-		check pvlv_counts $vg1 1 0 0 
+		fi
+		check pvlv_counts $vg1 1 0 0
 		if [ $i = existing ]; then
 		   check pvlv_counts $vg2 3 1 0
 		else
 		   check pvlv_counts $vg2 1 1 0
-		fi 
-		lvremove -f $vg2/$lv1 
+		fi
+		lvremove -f $vg2/$lv1
 		vgremove -f $vg2 $vg1
 
 COMM "vgsplit correctly splits single striped LV into $i VG ($j args)"
-		create_vg_ $vg1 $dev1 $dev2
-		test $i = existing && create_vg_ $vg2 $dev3 $dev4
+		create_vg_ $vg1 "$dev1" "$dev2"
+		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
 
-		lvcreate -l 4 -i 2 -n $lv1 $vg1 $dev1 $dev2 
-		vgchange -an $vg1 
+		lvcreate -l 4 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev1 $dev2
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
-		fi 
+		fi
 		if [ $i = existing ]; then
 		  check pvlv_counts $vg2 4 1 0
 		else
 		  check pvlv_counts $vg2 2 1 0
-		fi 
-		lvremove -f $vg2/$lv1 
+		fi
+		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
 
-COMM "vgsplit correctly splits mirror LV into $i VG ($j args)" 
-		create_vg_ $vg1 $dev1 $dev2 $dev3
-		test $i = existing && create_vg_ $vg2 $dev4
+COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+		test $i = existing && create_vg_ $vg2 "$dev4"
 
-		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
-		vgchange -an $vg1 
+		lvcreate -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
-		fi 
+		fi
 		if [ $i = existing ]; then
 		  check pvlv_counts $vg2 4 1 0
 		else
 		  check pvlv_counts $vg2 3 1 0
-		fi 
-		lvremove -f $vg2/$lv1 
+		fi
+		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
 # FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
 COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
-		create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-		test $i = existing && create_vg_ $vg2 $dev5
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+		test $i = existing && create_vg_ $vg2 "$dev5"
 
 		lvcreate -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
-		    $dev1 $dev2 $dev3 $dev4
+		    "$dev1" "$dev2" "$dev3" "$dev4"
 
 		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3 $dev4
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3" "$dev4"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi
@@ -117,73 +117,72 @@
 		vgremove -f $vg2
 # FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
-COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
-		create_vg_ $vg1 $dev1 $dev2
-		test $i = existing && create_vg_ $vg2 $dev3 $dev4
-
-		lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
-		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
-		vgchange -an $vg1 
+COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2"
+		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
+
+		lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev1 $dev2
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
-		fi 
+		fi
 		if [ $i = existing ]; then
 		  check pvlv_counts $vg2 4 2 1
 		else
 		  check pvlv_counts $vg2 2 2 1
-		fi 
+		fi
 		lvremove -f $vg2/$lv2
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
 
-COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" 
-		create_vg_ $vg1 $dev1 $dev2
-		test $i = existing && create_vg_ $vg2 $dev3
-
-		lvcreate -l 64 -i 2 -n $lv1 $vg1 
-		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
-		vgextend $vg1 $dev4 
-		lvcreate -l 64 -n $lv3 $vg1 $dev4 
-		vgchange -an $vg1 
+COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2"
+		test $i = existing && create_vg_ $vg2 "$dev3"
+
+		lvcreate -l 64 -i 2 -n $lv1 $vg1
+		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
+		vgextend $vg1 "$dev4"
+		lvcreate -l 64 -n $lv3 $vg1 "$dev4"
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev4
+		  vgsplit $vg1 $vg2 "$dev4"
 		else
 		  vgsplit -n $lv3 $vg1 $vg2
-		fi 
+		fi
 		if [ $i = existing ]; then
 		  check pvlv_counts $vg2 2 1 0
 		  check pvlv_counts $vg1 2 2 1
 		else
 		  check pvlv_counts $vg2 1 1 0
 		  check pvlv_counts $vg1 2 2 1
-		fi 
+		fi
 		lvremove -f $vg1/$lv2
 		lvremove -f $vg1/$lv1 $vg2/$lv3
 		vgremove -f $vg1 $vg2
 
-COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" 
-		create_vg_ $vg1 $dev1 $dev2 $dev3 
-		test $i = existing && create_vg_ $vg2 $dev5
-
-		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
-		vgextend $vg1 $dev4 
-		lvcreate -l 64 -n $lv2 $vg1 $dev4 
-		vgchange -an $vg1 
+COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+		test $i = existing && create_vg_ $vg2 "$dev5"
+
+		lvcreate -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		vgextend $vg1 "$dev4"
+		lvcreate -l 64 -n $lv2 $vg1 "$dev4"
+		vgchange -an $vg1
 		if [ $j = PV ]; then
-		  vgsplit $vg1 $vg2 $dev4
+		  vgsplit $vg1 $vg2 "$dev4"
 		else
 		  vgsplit -n $lv2 $vg1 $vg2
-		fi 
+		fi
 		if [ $i = existing ]; then
 		  check pvlv_counts $vg1 3 1 0
 		  check pvlv_counts $vg2 2 1 0
 		else
 		  check pvlv_counts $vg1 3 1 0
 		  check pvlv_counts $vg2 1 1 0
-		fi 
-		lvremove -f $vg1/$lv1 $vg2/$lv2
+		fi
 		vgremove -f $vg1 $vg2
 
 	done
@@ -192,104 +191,104 @@
 #
 # Test more complex setups where the code has to find associated PVs and
 # LVs to split the VG correctly
-# 
-COMM "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 4 -n $lv1 -i 2 $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv2 -i 2 $vg1 $dev2 $dev3 
-lvcreate -l 4 -n $lv3 -i 2 $vg1 $dev3 $dev4 
-vgchange -an $vg1 
+#
+COMM "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 -i 2 $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv2 -i 2 $vg1 "$dev2" "$dev3"
+lvcreate -l 4 -n $lv3 -i 2 $vg1 "$dev3" "$dev4"
+vgchange -an $vg1
 not vgsplit -n $lv1 $vg1 $vg2
-vgremove -ff $vg1
+vgremove -f $vg1
 
-COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
-lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
-check pvlv_counts $vg1 4 3 2 
-vgchange -an $vg1 
+COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 "$dev3"
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 "$dev4"
+check pvlv_counts $vg1 4 3 2
+vgchange -an $vg1
 not vgsplit -n $lv1 $vg1 $vg2;
 lvremove -f $vg1/$lv2 $vg1/$lv3
 lvremove -f $vg1/$lv1
-vgremove -ff $vg1
+vgremove -f $vg1
 
-COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
-lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
-check pvlv_counts $vg1 4 3 2 
-vgchange -an $vg1 
+COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 "$dev3"
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 "$dev4"
+check pvlv_counts $vg1 4 3 2
+vgchange -an $vg1
 not vgsplit -n $lv2 $vg1 $vg2
 lvremove -f $vg1/$lv2 $vg1/$lv3
 lvremove -f $vg1/$lv1
-vgremove -ff $vg1
+vgremove -f $vg1
 
-COMM "vgsplit fails splitting one mirror LV, only one PV specified" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
-check pvlv_counts $vg1 4 1 0 
-vgchange -an $vg1 
-not vgsplit $vg1 $vg2 $dev2 
+COMM "vgsplit fails splitting one mirror LV, only one PV specified"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+check pvlv_counts $vg1 4 1 0
+vgchange -an $vg1
+not vgsplit $vg1 $vg2 "$dev2"
 vgremove -ff $vg1
 
-COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
-lvcreate -l 16 -n $lv2 -i 2 $vg1 $dev3 $dev4 
-check pvlv_counts $vg1 4 2 0 
-vgchange -an $vg1 
+COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
+check pvlv_counts $vg1 4 2 0
+vgchange -an $vg1
 not vgsplit -n $lv2 $vg1 $vg2 2>err
-vgremove -ff $vg1
+vgremove -f $vg1
 
 #
 # Verify vgsplit rejects active LVs only when active LVs involved in split
 #
-COMM "vgsplit fails, active mirror involved in split" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
-lvcreate -l 16 -n $lv2 $vg1 $dev4 
-lvchange -an $vg1/$lv2 
-check pvlv_counts $vg1 4 2 0 
+COMM "vgsplit fails, active mirror involved in split"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -l 16 -n $lv2 $vg1 "$dev4"
+lvchange -an $vg1/$lv2
+check pvlv_counts $vg1 4 2 0
 not vgsplit -n $lv1 $vg1 $vg2;
-check pvlv_counts $vg1 4 2 0 
-vgremove -ff $vg1
+check pvlv_counts $vg1 4 2 0
+vgremove -f $vg1
 
-COMM "vgsplit succeeds, active mirror not involved in split" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
-lvcreate -l 16 -n $lv2 $vg1 $dev4 
-lvchange -an $vg1/$lv2 
-check pvlv_counts $vg1 4 2 0 
-vgsplit -n $lv2 $vg1 $vg2 
-check pvlv_counts $vg1 3 1 0 
-check pvlv_counts $vg2 1 1 0 
-vgremove -ff $vg1 $vg2
-
-COMM "vgsplit fails, active snapshot involved in split" 
-create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
-lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
-lvcreate -l 64 -i 2 -n $lv3 $vg1 $dev3 $dev4 
-lvchange -an $vg1/$lv3 
-check pvlv_counts $vg1 4 3 1 
+COMM "vgsplit succeeds, active mirror not involved in split"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -l 16 -n $lv2 $vg1 "$dev4"
+lvchange -an $vg1/$lv2
+check pvlv_counts $vg1 4 2 0
+vgsplit -n $lv2 $vg1 $vg2
+check pvlv_counts $vg1 3 1 0
+check pvlv_counts $vg2 1 1 0
+vgremove -f $vg1 $vg2
+
+COMM "vgsplit fails, active snapshot involved in split"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
+lvcreate -l 64 -i 2 -n $lv3 $vg1 "$dev3" "$dev4"
+lvchange -an $vg1/$lv3
+check pvlv_counts $vg1 4 3 1
 not vgsplit -n $lv2 $vg1 $vg2;
-check pvlv_counts $vg1 4 3 1 
-lvremove -f $vg1/$lv2 
-vgremove -ff $vg1
-
-COMM "vgsplit succeeds, active snapshot not involved in split" 
-create_vg_ $vg1 $dev1 $dev2 $dev3
-lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
-vgextend $vg1 $dev4 
-lvcreate -l 64 -n $lv3 $vg1 $dev4 
-lvchange -an $vg1/$lv3 
-check pvlv_counts $vg1 4 3 1 
-vgsplit -n $lv3 $vg1 $vg2 
-check pvlv_counts $vg1 3 2 1 
-check pvlv_counts $vg2 1 1 0 
-vgchange -an $vg1 
-lvremove -f $vg1/$lv2 
-vgremove -ff $vg1 $vg2
+check pvlv_counts $vg1 4 3 1
+lvremove -f $vg1/$lv2
+vgremove -f $vg1
+
+COMM "vgsplit succeeds, active snapshot not involved in split"
+create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -s -n $lv2 $vg1/$lv1
+vgextend $vg1 "$dev4"
+lvcreate -l 64 -n $lv3 $vg1 "$dev4"
+lvchange -an $vg1/$lv3
+check pvlv_counts $vg1 4 3 1
+vgsplit -n $lv3 $vg1 $vg2
+check pvlv_counts $vg1 3 2 1
+check pvlv_counts $vg2 1 1 0
+vgchange -an $vg1
+lvremove -f $vg1/$lv2
+vgremove -f $vg1 $vg2
--- LVM2/test/shell/vgsplit-stacked.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgsplit-stacked.sh	2012/03/16 13:00:06	1.2
@@ -1,3 +1,4 @@
+#!/bin/sh
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -11,19 +12,16 @@
 . lib/test
 
 aux lvmconf 'devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
-cat $TESTDIR/etc/lvm.conf
-aux prepare_devs 3
+aux prepare_pvs 3
 
-pvcreate $(cat DEVICES)
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 100%FREE $vg1
 
 #top VG
 pvcreate $DM_DEV_DIR/$vg1/$lv1
-vgcreate $vg $DM_DEV_DIR/$vg1/$lv1 $dev3
+vgcreate $vg $DM_DEV_DIR/$vg1/$lv1 "$dev3"
 
-vgchange -a n $vg
-vgchange -a n $vg1
+vgchange -a n $vg $vg1
 
 # this should fail but not segfault, RHBZ 481793.
-not vgsplit $vg $vg1 $dev3
+not vgsplit $vg $vg1 "$dev3"
--- LVM2/test/shell/vgsplit-usage.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgsplit-usage.sh	2012/03/16 13:00:06	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -23,146 +23,146 @@
 # ensure name order does not matter
 # NOTE: if we're using lvm1, we must use -M on vgsplit
 vgcreate -M$mdatype $vg1 $(cat DEVICES)
-vgsplit -M$mdatype $vg1 $vg2 $dev1
+vgsplit -M$mdatype $vg1 $vg2 "$dev1"
 vgremove $vg1 $vg2
 
 vgcreate -M$mdatype $vg2 $(cat DEVICES)
-vgsplit -M$mdatype $vg2 $vg1 $dev1
+vgsplit -M$mdatype $vg2 $vg1 "$dev1"
 vgremove $vg1 $vg2
 
 # vgsplit accepts new vg as destination of split
 # lvm1 -- bz244792
 vgcreate -M$mdatype $vg1 $(cat DEVICES)
-vgsplit $vg1 $vg2 $dev1 1>err
-grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgsplit $vg1 $vg2 "$dev1" 1>err
+grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err
 vgremove $vg1 $vg2
 
 # vgsplit accepts existing vg as destination of split
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-vgcreate -M$mdatype $vg2 $dev3 $dev4 
-vgsplit $vg1 $vg2 $dev1 1>err
-grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype $vg2 "$dev3" "$dev4"
+vgsplit $vg1 $vg2 "$dev1" 1>err
+grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err
 vgremove $vg1 $vg2
 
 # vgsplit accepts --maxphysicalvolumes 128 on new VG
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $dev1 
-check vg_field $vg2 max_pv 128 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgsplit --maxphysicalvolumes 128 $vg1 $vg2 "$dev1"
+check vg_field $vg2 max_pv 128
 vgremove $vg1 $vg2
 
 # vgsplit accepts --maxlogicalvolumes 128 on new VG
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $dev1 
-check vg_field $vg2 max_lv 128 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgsplit --maxlogicalvolumes 128 $vg1 $vg2 "$dev1"
+check vg_field $vg2 max_lv 128
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because max_pv of destination would be exceeded
-vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2
-vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4
-not vgsplit $vg1 $vg2 $dev1 2>err;
-grep "^  Maximum number of physical volumes (2) exceeded" err
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 "$dev3" "$dev4"
+not vgsplit $vg1 $vg2 "$dev1" 2>err;
+grep "Maximum number of physical volumes (2) exceeded" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because maxphysicalvolumes given with existing vg
-vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
-not vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $dev1 2>err;
-grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 "$dev3" "$dev4"
+not vgsplit --maxphysicalvolumes 2 $vg1 $vg2 "$dev1" 2>err;
+grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because maxlogicalvolumes given with existing vg
-vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
-not vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $dev1 2>err
-grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 "$dev3" "$dev4"
+not vgsplit --maxlogicalvolumes 2 $vg1 $vg2 "$dev1" 2>err
+grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because alloc given with existing vg
-vgcreate -M$mdatype --alloc cling $vg1 $dev1 $dev2 
-vgcreate -M$mdatype --alloc cling $vg2 $dev3 $dev4 
-not vgsplit --alloc cling $vg1 $vg2 $dev1 2>err;
-grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgcreate -M$mdatype --alloc cling $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --alloc cling $vg2 "$dev3" "$dev4"
+not vgsplit --alloc cling $vg1 $vg2 "$dev1" 2>err;
+grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects split because clustered given with existing vg
-vgcreate -M$mdatype --clustered n $vg1 $dev1 $dev2 
-vgcreate -M$mdatype --clustered n $vg2 $dev3 $dev4 
-not vgsplit --clustered n $vg1 $vg2 $dev1 2>err
-grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
+vgcreate -M$mdatype --clustered n $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --clustered n $vg2 "$dev3" "$dev4"
+not vgsplit --clustered n $vg1 $vg2 "$dev1" 2>err
+grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
 # vgsplit rejects vg with active lv
-pvcreate -M$mdatype -ff $dev3 $dev4 
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-vgcreate -M$mdatype $vg2 $dev3 $dev4 
-lvcreate -l 4 -n $lv1 $vg1 
-not vgsplit $vg1 $vg2 $dev1 2>err;
-grep "^  Logical volumes in \"$vg1\" must be inactive\$" err 
+pvcreate -M$mdatype -ff "$dev3" "$dev4"
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 $vg1
+not vgsplit $vg1 $vg2 "$dev1" 2>err;
+grep "Logical volumes in \"$vg1\" must be inactive\$" err
 vgremove -f $vg1 $vg2
 
 # vgsplit rejects split because max_lv is exceeded
-vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
-lvcreate -l 4 -n $lv1 $vg1 
-lvcreate -l 4 -n $lv2 $vg1 
-lvcreate -l 4 -n $lv3 $vg2 
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv2 $vg1
+lvcreate -l 4 -n $lv3 $vg2
 vgchange -an $vg1 $vg2
-not vgsplit $vg1 $vg2 $dev1 2>err;
-grep "^  Maximum number of logical volumes (2) exceeded" err 
+not vgsplit $vg1 $vg2 "$dev1" 2>err;
+grep "Maximum number of logical volumes (2) exceeded" err
 vgremove -f $vg1 $vg2
 
 # vgsplit verify default - max_lv attribute from new VG is same as source VG" \
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv1 $vg1 
-vgchange -an $vg1 
-vgsplit $vg1 $vg2 $dev1 
-check compare_vg_field $vg1 $vg2 max_lv 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv1 $vg1
+vgchange -an $vg1
+vgsplit $vg1 $vg2 "$dev1"
+check compare_vg_field $vg1 $vg2 max_lv
 vgremove -f $vg1 $vg2
 
 # vgsplit verify default - max_pv attribute from new VG is same as source VG" \
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv1 $vg1 
-vgchange -an $vg1 
-vgsplit $vg1 $vg2 $dev1 
-check compare_vg_field $vg1 $vg2 max_pv 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv1 $vg1
+vgchange -an $vg1
+vgsplit $vg1 $vg2 "$dev1"
+check compare_vg_field $vg1 $vg2 max_pv
 vgremove -f $vg1 $vg2
 
 # vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv1 $vg1 
-vgchange -an $vg1 
-vgsplit $vg1 $vg2 $dev1 
-check compare_vg_field $vg1 $vg2 vg_fmt 
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+lvcreate -l 4 -n $lv1 $vg1
+vgchange -an $vg1
+vgsplit $vg1 $vg2 "$dev1"
+check compare_vg_field $vg1 $vg2 vg_fmt
 vgremove -f $vg2 $vg1
 
 # vgsplit rejects split because PV not in VG
-vgcreate -M$mdatype $vg1 $dev1 $dev2 
-vgcreate -M$mdatype $vg2 $dev3 $dev4 
-lvcreate -l 4 -n $lv1 $vg1 
-lvcreate -l 4 -n $lv2 $vg1 
-vgchange -an $vg1 
-not vgsplit $vg1 $vg2 $dev3 2>err;
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate -M$mdatype $vg2 "$dev3" "$dev4"
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv2 $vg1
+vgchange -an $vg1
+not vgsplit $vg1 $vg2 "$dev3" 2>err;
 vgremove -f $vg2 $vg1
 done
 
 # ONLY LVM2 metadata
 # setup PVs" '
-pvcreate --metadatacopies 0 $dev5
+pvcreate --metadatacopies 0 "$dev5"
 
 # vgsplit rejects to give away pv with the last mda copy
-vgcreate $vg1 $dev5 $dev2  
-lvcreate -l 10 -n $lv1  $vg1 
-lvchange -an $vg1/$lv1 
-check pvlv_counts $vg1 2 1 0 
-not vgsplit  $vg1 $vg2 $dev5;
-check pvlv_counts $vg1 2 1 0 
-vgremove -ff $vg1
+vgcreate $vg1 "$dev5" "$dev2"
+lvcreate -l 10 -n $lv1  $vg1
+lvchange -an $vg1/$lv1
+check pvlv_counts $vg1 2 1 0
+not vgsplit  $vg1 $vg2 "$dev5";
+check pvlv_counts $vg1 2 1 0
+vgremove -f $vg1
 
 # vgsplit rejects split because metadata types differ
-pvcreate -ff -M1 $dev3 $dev4 
-pvcreate -ff $dev1 $dev2 
-vgcreate -M1 $vg1 $dev3 $dev4 
-vgcreate $vg2 $dev1 $dev2 
-not vgsplit $vg1 $vg2 $dev3 2>err;
-grep "^  Metadata types differ" err 
-vgremove $vg1 $vg2
+pvcreate -ff -M1 "$dev3" "$dev4"
+pvcreate -ff "$dev1" "$dev2"
+vgcreate -M1 $vg1 "$dev3" "$dev4"
+vgcreate $vg2 "$dev1" "$dev2"
+not vgsplit $vg1 $vg2 "$dev3" 2>err;
+grep "Metadata types differ" err
+vgremove -f $vg1 $vg2


