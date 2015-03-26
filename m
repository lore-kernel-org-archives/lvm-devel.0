From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 15:05:04 +0000 (UTC)
Subject: master - tests: pvmove better delay check
Message-ID: <20150326150504.D606661057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=147b0a17005f632647b31394dda402483322ccad
Commit:        147b0a17005f632647b31394dda402483322ccad
Parent:        d24b6cfb1ff1f29eec49c3113f8cef9904cf4a8b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 16:03:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 16:03:24 2015 +0100

tests: pvmove better delay check

Improve testing for condition that pvmove0 is already running in the
table (so we do not kill pvmove while it has loaded target, but
it's not yet Live).

Also delay_dev for 200ms.
---
 test/shell/lvresize-rounding.sh |    1 -
 test/shell/pvmove-restart.sh    |   10 +++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 24ca00b..5c30539 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -11,7 +11,6 @@
 
 . lib/inittest
 
-# 15 extents
 aux prepare_pvs 3 22
 
 vgcreate -s 32K $vg $(cat DEVICES)
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 022e7c8..06455f5 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -29,12 +29,16 @@ lvextend -l+5 $vg/$lv1 "$dev1"
 lvextend -l+10 $vg/$lv1 "$dev2"
 
 # Slowdown writes
-aux delay_dev "$dev3" 0 100
+aux delay_dev "$dev3" 0 200
 
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
-while not dmsetup status "$vg-pvmove0"; do sleep .1; done
+while : ; do
+	dmsetup info -c -o tables_loaded "$vg-pvmove0" > out || true;
+	not grep Live out || break
+	sleep .1
+done
 kill -9 $PVMOVE
 wait
 


