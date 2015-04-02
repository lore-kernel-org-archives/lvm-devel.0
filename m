From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:14 +0000 (UTC)
Subject: master - tests: more duplicate testing
Message-ID: <20150402114114.6006760E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d1c9a0eb814a7eca55c67cfd89bbf056c65f13e
Commit:        6d1c9a0eb814a7eca55c67cfd89bbf056c65f13e
Parent:        53ef14fca0e85fef0df41665a64d21166d8b684d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 12:42:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: more duplicate testing

---
 test/shell/pv-duplicate.sh |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index ede9600..9b218e6 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,6 +15,10 @@
 
 aux prepare_devs 3
 
+pvcreate "$dev1"
+
+dd if="$dev1" of=backup_dev1 bs=256K count=1
+
 vgcreate --metadatasize 128k $vg1 "$dev1"
 
 # copy mda
@@ -22,4 +26,12 @@ dd if="$dev1" of="$dev2" bs=256K count=1
 dd if="$dev1" of="$dev3" bs=256K count=1
 
 pvs "$dev3" -o pv_uuid
+
 vgs $vg1
+
+dd if=backup_dev1 of="$dev3" bs=256K count=1
+pvs
+#-vvvv
+# TODO: Surely needs more inspecition about correct
+#       behavior for such case
+# vgs $vg1


