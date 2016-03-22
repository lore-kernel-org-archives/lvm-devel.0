From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Mar 2016 10:13:35 +0000 (UTC)
Subject: master - tests: update vg-check-devs-used.sh
Message-ID: <20160322101335.BBB17610AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a915270fc7837d18c2e6daf55d75c3763bc2866
Commit:        6a915270fc7837d18c2e6daf55d75c3763bc2866
Parent:        ed002ed22adc61dfe477c3d42c9aae356f450d2c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 22 11:13:28 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 22 11:13:28 2016 +0100

tests: update vg-check-devs-used.sh

---
 test/shell/vg-check-devs-used.sh |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index b368227..09109e5 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -21,4 +21,14 @@ dd if="$dev1" of="$dev3" bs=1M
 pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
 grep "WARNING: Device mismatch detected for $vg/$lv which is accessing $dev1 instead of $dev3" err
 
+dd if=/dev/zero of="$dev3" bs=1M count=8
+lvremove -ff $vg
+
+# Also test if sub LVs with suffixes are correctly processed.
+# Check with thick snapshot which has sub LVs with -real and -cow suffix in UUID.
+lvcreate -l1 -n $lv $vg
+lvcreate -l1 -s $vg/$lv
+pvs 2>err
+not grep "WARNING: Device mismatch detected for $vg/$lv" err
+
 vgremove -ff $vg


