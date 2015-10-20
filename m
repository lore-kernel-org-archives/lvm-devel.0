From: okozina <okozina@fedoraproject.org>
Date: Tue, 20 Oct 2015 10:19:29 +0000 (UTC)
Subject: master - tests: add test for missing mirror in-sync info
Message-ID: <20151020101929.30E8160F6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=392248186e56fb216e49a2fee0caad5a506e3dd1
Commit:        392248186e56fb216e49a2fee0caad5a506e3dd1
Parent:        33465066c5eddaa6169814d645d543e5673bc2a6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 20 11:55:51 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 20 12:19:02 2015 +0200

tests: add test for missing mirror in-sync info

---
 test/shell/lvconvert-mirror.sh |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 844f8e9..029112c 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -313,4 +313,11 @@ lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
+# bz1272175: check lvconvert reports progress while waiting for mirror
+# to get synced
+lvcreate -l2 -n $lv1 $vg
+lvconvert --type mirror -i1 -m1 $vg/$lv1 | tee out
+grep -e "$vg/$lv1: Converted:" out || fail "Missing sync info in foreground mode"
+lvremove -ff $vg
+
 vgremove -ff $vg


