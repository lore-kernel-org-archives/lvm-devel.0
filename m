From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:45 -0400
Subject: master - tests: more zero usage
Message-ID: <201804232043.w3NKhjDi005032@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dcb5434a7f4a3b736d72c7bebe276be6735142ce
Commit:        dcb5434a7f4a3b736d72c7bebe276be6735142ce
Parent:        fc3ed8856f445079de43cd33f64582cee9bc80ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 21 11:21:38 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

tests: more zero usage

Another case where usage of zero backend for mirror legs is more
effective then using delayed_dev.
---
 test/shell/lvconvert-mirror-updown.sh |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index 5c7b130..d5059c2 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -16,26 +16,27 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
-aux prepare_pvs 3
+aux prepare_pvs 3 100
 get_devs
 
 vgcreate -s 64k "$vg" "${DEVICES[@]}"
 
-lvcreate -aey -l10 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2"
+# Use zero devices for big mirror legs
+aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
+aux zero_dev "$dev3" $(get first_extent_sector "$dev3"):
 
-# Slow down device so we are able to start next conversion in parallel
-aux delay_dev "$dev3" 0 200
+lvcreate -aey -L90 --type mirror --corelog --regionsize 16k -m1 -n $lv1 $vg "$dev1" "$dev2"
 
 lvconvert -m+1 -b $vg/$lv1 "$dev3"
 
-# To fix - wait helps here....
-#lvconvert $vg/$lv1
 
-lvs -a $vg
+# We want here ongoing conversion
 
-#
-# It fails so use 'should' and -vvvv for now
-#
-should lvconvert -vvvv -m-1 $vg/$lv1 "$dev2"
+lvs -a -o+seg_pe_ranges $vg
+
+# Now it should be able to drop 2nd. leg
+lvconvert -m-1 $vg/$lv1 "$dev2"
+
+lvs -a $vg
 
 vgremove -f $vg


