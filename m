From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Apr 2011 17:21:56 +0200
Subject: [PATCH 2/2] Update test case
In-Reply-To: <cover.1304090389.git.zkabelac@redhat.com>
References: <cover.1304090389.git.zkabelac@redhat.com>
Message-ID: <39b37fa94c513d19eff981efe86cb71637a8d7c8.1304090389.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This script probably obsoletes  t-pv-duplicate.sh
so that one would be removed together with this update
(as it's subtest of this larger script)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-vgimportclone.sh |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/test/t-vgimportclone.sh b/test/t-vgimportclone.sh
index a979383..d8838d7 100644
--- a/test/t-vgimportclone.sh
+++ b/test/t-vgimportclone.sh
@@ -1,4 +1,4 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,25 +12,19 @@
 
 aux prepare_devs 2
 
-pvcreate $dev1 $dev2
-vgcreate $vg1 $dev1
+vgcreate -c n --metadatasize 128k $vg1 $dev1
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Clone the LUN
-dd if=$dev1 of=$dev2
+dd if=$dev1 of=$dev2 bs=256K count=1
 
 # Verify pvs works on each device to give us vgname
-pvs --noheadings -o vg_name $dev1 1>err
-grep $vg1 err
-pvs --noheadings -o vg_name $dev2 1>err
-grep $vg1 err
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
 
 # Import the cloned PV to a new VG
-# FIXME: this fails on lenny buildslave, I think we need proper wrapper
-# vgimportclone --basevgname $vg2 $dev2
+vgimportclone --basevgname $vg2 $dev2
 
 # Verify we can activate / deactivate the LV from both VGs
-# lvchange -ay $vg1/$lv1
-# lvchange -ay $vg2/$lv1
-# vgchange -an $vg1
-# vgchange -an $vg2
+lvchange -ay $vg1/$lv1 $vg2/$lv1
+vgchange -an $vg1 $vg2
-- 
1.7.5


