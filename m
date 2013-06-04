From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:42 +0000 (UTC)
Subject: master - tests: fix strings test
Message-ID: <20130604135842.BBA5D60D2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fce72434270cb1bdd14ff896cd1640bc51c93084
Commit:        fce72434270cb1bdd14ff896cd1640bc51c93084
Parent:        c0f995050f04f075eda9025db514be08b13c9a6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 4 11:07:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:42 2013 +0200

tests: fix strings test

For non udev path use DM_DEFAULT_NAME_MANGLING_MODE.
Skip this test when using real /dev dir, since udev is not able
to create such device name unless mangled...
---
 test/shell/mdata-strings.sh |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 95a630e..0102d4b 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,10 +13,15 @@
 
 . lib/test
 
+# For udev impossible to create
+test "$LVM_TEST_DEVDIR" = "/dev" && skip
+
 aux prepare_devs 2
-aux lvmconf 'devices/global_filter = [ "a|.*dev/mapper/.*LVMTEST.*pv[0-9_]*$|", "r|.*|" ]'
+aux extend_filter_LVMTEST
+
+# Setup mangling to 'none' globaly for all libdm users
+export DM_DEFAULT_NAME_MANGLING_MODE=none
 
-# for udev impossible to create
 pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
 
 # 'set up temp files, loopback devices'
@@ -30,7 +35,8 @@ dm_table | grep -F "$pv_ugly"
 created="$dev1"
 # when used with real udev without fallback, it will fail here
 pvcreate "$dev1" || created="$dev2"
-pvdisplay | should grep -F "$pv_ugly"
+pvdisplay 2>&1 | tee >err
+should grep -F "$pv_ugly" err
 should check pv_field "$dev1" pv_name "$dev1"
 vgcreate $vg "$created"
 # 'no parse errors and VG really exists'


