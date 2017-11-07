From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:28 -0500
Subject: master - tests: snasphot merging
Message-ID: <201711072036.vA7KaSTY008059@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e822a9f38ddf416378ccc5c09859a39ed9794306
Commit:        e822a9f38ddf416378ccc5c09859a39ed9794306
Parent:        0c9e3e8df25e4c8239945de7ea3629426ffe08bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 22:59:43 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:34:35 2017 +0100

tests: snasphot merging

---
 test/shell/snapshot-merge.sh |   10 +++++++++-
 test/shell/thin-merge.sh     |   12 +++++++++---
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 9b2d663..9d0a264 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -106,6 +106,14 @@ setup_merge_ $vg $lv1 1
 lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
 lvremove -f $vg/$lv1
 
+# test merging cannot start on already merging origin
+setup_merge_ $vg $lv1 3
+lvchange -an $vg
+lvs -a $vg
+lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
+not lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")_1" 2>&1 | tee err
+grep "Cannot merge snapshot" err
+lvremove -f $vg/$lv1
 
 # test merging multiple snapshots that share the same tag
 setup_merge_ $vg $lv1
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 1841bf7..3abda40 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -45,9 +45,15 @@ touch mntsnap/test_snap
 
 lvs -o+tags,thin_id $vg
 
+lvcreate -s -n snap1 $vg/$lv1
+
 lvconvert --merge $vg/snap &>out
 grep "Merging of thin snapshot $vg/snap will occur on next activation of $vg/${lv1}." out
 
+# Can't merge another snapshot while "snap" is still being 'merged'.
+not lvconvert --merge $vg/snap1 &>out
+grep "Cannot merge snapshot" out
+
 umount mnt
 
 # Merge cannot happen
@@ -111,13 +117,13 @@ check lv_not_exists $vg oldsnapof_${lv1}
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
 lvconvert --merge $vg/snap
 lvremove -f $vg/oldsnapof_snap
-check lv_field  $vg/$lv1 thin_id "3"
+check lv_field  $vg/$lv1 thin_id "4"
 
 # Check --mergethin
 lvcreate -s -n snap $vg/$lv1
-check lv_field  $vg/snap thin_id "4"
+check lv_field  $vg/snap thin_id "5"
 lvconvert --mergethin $vg/snap  &>out
 grep "Volume $vg/snap replaced origin $vg/${lv1}." out
-check lv_field  $vg/$lv1 thin_id "4"
+check lv_field  $vg/$lv1 thin_id "5"
 
 vgremove -ff $vg


