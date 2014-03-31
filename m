From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:48 +0000 (UTC)
Subject: master - tests: more listing tests
Message-ID: <20140331100648.EFC1C60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee8708cc8ebfcbb55800e6ca8782394b5f3db2f7
Commit:        ee8708cc8ebfcbb55800e6ca8782394b5f3db2f7
Parent:        f93c9b447b52058526ca8aadedcd3aed78f8f0fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:44:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:05:35 2014 +0200

tests: more listing tests

---
 test/shell/listings.sh |   49 ++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 414b146..d46ee7f 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,6 +17,10 @@
 
 aux prepare_devs 5
 
+# Check there is no PV
+pvscan | tee out
+grep "No matching" out
+
 pvcreate --uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE --norestorefile "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
@@ -65,6 +69,7 @@ dmsetup ls|grep "$PREFIX"|grep -v "LVMTEST.*pv."
 #COMM vgs with options from pvs still treats arguments as VGs (bz193543)
 vgs -o pv_name,vg_name $vg
 # would complain if not
+vgs -o all $vg
 
 #COMM pvdisplay --maps feature (bz149814)
 pvdisplay $(cat DEVICES) >out
@@ -75,39 +80,52 @@ aux disable_dev "$dev1"
 pvs -o +pv_uuid | grep BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
 aux enable_dev "$dev1"
 
+pvscan --uuid
+pvscan -e
+pvscan -s
+pvscan --novolumegroup
+vgscan --mknodes
+lvscan
+lvmdiskscan
+
+invalid pvscan "$dev1"
+invalid pvscan -aay
+invalid pvscan --major 254
+invalid pvscan --minor 0
+invalid pvscan --novolumegroup -e
+invalid vgscan $vg
+invalid lvscan $vg
+
 if aux have_readline; then
-# test *scan and *display tools
 cat <<EOF | lvm
-vgdisplay --units k $vg
-lvdisplay --units g $vg
 pvdisplay -c "$dev1"
 pvdisplay -s "$dev1"
+vgdisplay --units k $vg
 vgdisplay -c $vg
 vgdisplay -C $vg
 vgdisplay -s $vg
+vgdisplay -v $vg
 lvdisplay -c $vg
 lvdisplay -C $vg
 lvdisplay -m $vg
+lvdisplay --units g $vg
 EOF
 
 for i in h b s k m g t p e H B S K M G T P E; do
 	echo pvdisplay --units $i "$dev1"
 done | lvm
 else
-pvscan --uuid
-vgscan --mknodes
-lvscan
-lvmdiskscan
-vgdisplay --units k $vg
-lvdisplay --units g $vg
 pvdisplay -c "$dev1"
 pvdisplay -s "$dev1"
+vgdisplay --units k $vg
 vgdisplay -c $vg
 vgdisplay -C $vg
 vgdisplay -s $vg
+vgdisplay -v $vg
 lvdisplay -c $vg
 lvdisplay -C $vg
 lvdisplay -m $vg
+lvdisplay --units g $vg
 
 for i in h b s k m g t p e H B S K M G T P E; do
 	pvdisplay --units $i "$dev1"
@@ -115,7 +133,7 @@ done
 fi
 
 invalid lvdisplay -C -m $vg
-invalid lvdisplay -c -v $vg
+invalid lvdisplay -c -m $vg
 invalid lvdisplay --aligned $vg
 invalid lvdisplay --noheadings $vg
 invalid lvdisplay --options lv_name $vg
@@ -127,6 +145,12 @@ invalid vgdisplay -C -A
 invalid vgdisplay -C -c
 invalid vgdisplay -C -s
 invalid vgdisplay -c -s
+invalid vgdisplay --aligned
+invalid vgdisplay --noheadings
+invalid vgdisplay --options
+invalid vgdisplay --separator :
+invalid vgdisplay --sort size
+invalid vgdisplay --unbuffered
 invalid vgdisplay -A $vg1
 
 invalid pvdisplay -C -A
@@ -135,7 +159,7 @@ invalid pvdisplay -C -m
 invalid pvdisplay -C -s
 invalid pvdisplay -c -m
 invalid pvdisplay -c -s
-invalid pvdisplay --alianed
+invalid pvdisplay --aligned
 invalid pvdisplay --all
 invalid pvdisplay --noheadings
 invalid pvdisplay --options
@@ -147,6 +171,7 @@ invalid pvdisplay -A $vg1
 # Check exported VG listing
 vgchange -an $vg
 vgexport -a
+pvscan
 pvdisplay --noheadings -C -o attr,name | tee out
 not grep -v "ax-" out
 vgimport -a


