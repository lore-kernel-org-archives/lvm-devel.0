From: David Teigland <teigland@redhat.com>
Date: Thu, 22 Aug 2013 18:43:45 -0400
Subject: [PATCH] test: add vg-name-from-env
Message-ID: <20130822224345.GA2401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vg name should come from env var LVM_VG_NAME
for commands that take vg name and lv name,
but vg name is not specified on command line.
---
 test/shell/vg-name-from-env.sh | 104 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 104 insertions(+)
 create mode 100644 test/shell/vg-name-from-env.sh

diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
new file mode 100644
index 0000000..c8e8c76
--- /dev/null
+++ b/test/shell/vg-name-from-env.sh
@@ -0,0 +1,104 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+
+test_description='Test the vg name for an lv from env var'
+
+. lib/test
+
+aux prepare_devs 2
+
+pvcreate $dev1
+pvcreate $dev2
+
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+
+export LVM_VG_NAME=$vg1
+
+# should use env
+lvcreate -n $lv1 -l 2
+lvcreate -n $lv3 -l 2
+
+lvcreate -n $lv2 -l 2 $vg2
+lvcreate -n $lv4 -l 2 $vg2
+
+lvs >err
+grep $lv1 err
+grep $lv3 err
+grep $lv2 err
+grep $lv4 err
+
+not lvs $vg1 >err
+not grep $lv1 err
+not grep $lv3 err
+not grep $lv2 err
+not grep $lv4 err
+
+not lvs $vg2 >err
+not grep $lv1 err
+not grep $lv3 err
+not grep $lv2 err
+not grep $lv4 err
+
+lvs $lv1 >err
+grep $lv1 err
+not grep $lv3 err
+not grep $lv2 err
+not grep $lv4 err
+
+lvs $lv1 $lv3 >err
+grep $lv1 err
+grep $lv3 err
+not grep $lv2 err
+not grep $lv4 err
+
+# should use env and fail to fine lv4 in vg1
+not lvs $lv4 >err
+not grep $lv1 err
+not grep $lv3 err
+not grep $lv2 err
+not grep $lv4 err
+
+lvs $vg2/$lv4 >err
+not grep $lv1 err
+not grep $lv3 err
+not grep $lv2 err
+grep $lv4 err
+
+lvs $vg2/$lv2 $vg2/$lv4 >err
+not grep $lv1 err
+not grep $lv3 err
+grep $lv2 err
+grep $lv4 err
+
+# should use env
+lvchange -an $lv3
+lvremove $lv3
+not lvremove $lv4
+
+lvs >err
+grep $lv1 err
+not grep $lv3 err
+grep $lv2 err
+grep $lv4 err
+
+# should use env
+lvcreate -n $lv3 -l 2
+lvchange --addtag foo $lv3
+lvchange -an $lv3
+
+# lvremove by tag should apply to all vgs, not env vg
+lvchange --addtag foo $vg2/$lv4
+lvchange -an $vg2/$lv4
+lvremove @foo
+
+lvs >err
+grep $lv1 err
+not grep $lv3 err
+grep $lv2 err
+not grep $lv4 err
+
-- 
1.8.3.1


