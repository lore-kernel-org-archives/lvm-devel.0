From: David Teigland <teigland@redhat.com>
Date: Wed, 21 Aug 2013 18:55:42 -0400
Subject: [PATCH] test: add process-each-duplicate-vgnames
Message-ID: <20130821225542.GA23463@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test that vgs shows both vgs when two vgs
exist with the same name but different uuids.
---
 test/shell/process-each-duplicate-vgnames.sh | 52 ++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)
 create mode 100644 test/shell/process-each-duplicate-vgnames.sh

diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
new file mode 100644
index 0000000..8be8168
--- /dev/null
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -0,0 +1,52 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+
+test_description='Test vgs with duplicate vg names'
+
+. lib/test
+
+aux prepare_devs 2
+
+pvcreate $dev1
+pvcreate $dev2
+
+aux disable_dev $dev1
+aux disable_dev $dev2
+
+aux enable_dev $dev1
+vgcreate $vg1 $dev1
+UUID1=$(vgs --noheading -o vg_uuid $vg1)
+aux disable_dev $dev1
+
+aux enable_dev $dev2
+vgcreate $vg1 $dev2
+UUID2=$(vgs --noheading -o vg_uuid $vg1)
+aux disable_dev $dev2
+
+aux enable_dev $dev1
+aux enable_dev $dev2
+
+vgs >err
+grep $UUID1 err
+grep $UUID2 err
+
+# should we specify and test which should be displayed?
+# vgs --noheading -o vg_uuid $vg1 >err
+# grep $UUID1 err
+
+aux disable_dev $dev2
+vgs >err
+grep $UUID1 err
+not grep $UUID2 err
+aux enable_dev $dev2
+
+aux disable_dev $dev1
+vgs >err
+grep $UUID2 err
+not grep $UUID1 err
+aux enable_dev $dev1
+
-- 
1.8.3.1


