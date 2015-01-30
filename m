From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 11:35:17 +0000 (UTC)
Subject: master - tests: test stacked raid
Message-ID: <20150130113517.5AA3660247@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d021284bcfda0222f10787ea798077f312ee3275
Commit:        d021284bcfda0222f10787ea798077f312ee3275
Parent:        2055b04c111eb5df3a445a9b544aff7a17b411a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 12:30:35 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 12:33:52 2015 +0100

tests: test stacked raid

---
 test/shell/lvconvert-thin-raid.sh |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index d7a353b..3d7eee5 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -18,8 +18,10 @@ aux have_raid 1 4 0 || skip
 aux prepare_vg 4
 
 # create RAID LVs for data and metadata volumes
-lvcreate -aey --nosync -L10M --type raid1 -m1 -n $lv1 $vg
-lvcreate -aey --nosync -L8M --type raid1 -m1 -n $lv2 $vg
+lvcreate -aey -L10M --type raid1 -m3 -n $lv1 $vg
+lvcreate -aey -L8M --type raid1 -m3 -n $lv2 $vg
+aux wait_for_sync $vg $lv1
+aux wait_for_sync $vg $lv2
 lvchange -an $vg/$lv1
 
 # conversion fails for internal volumes
@@ -28,4 +30,22 @@ invalid lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
+lvchange -ay $vg
+
+lvconvert --splitmirrors 1 --name data2 $vg/${lv1}_tdata "$dev2"
+lvconvert --splitmirrors 1 --name data3 $vg/${lv1}_tdata "$dev3"
+lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tdata "$dev4"
+
+lvconvert --splitmirrors 1 --name meta1 $vg/${lv1}_tmeta "$dev1"
+lvconvert --splitmirrors 1 --name meta2 $vg/${lv1}_tmeta "$dev2"
+lvconvert --splitmirrors 1 --trackchanges $vg/${lv1}_tmeta "$dev4"
+
+lvremove -ff $vg/data2 $vg/data3 $vg/meta1 $vg/meta2
+
+lvconvert --merge $vg/${lv1}_tdata_rimage_1
+lvconvert --merge $vg/${lv1}_tmeta_rimage_1
+
+lvconvert -m+1 $vg/${lv1}_tdata "$dev2"
+lvconvert -m+1 $vg/${lv1}_tmeta "$dev1"
+
 vgremove -ff $vg


