From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Dec 2016 12:16:55 +0000 (UTC)
Subject: master - tests: update test
Message-ID: <20161223121655.23BEF607A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96a1943fb8d208aa84c386cf48f2b62038b09e2e
Commit:        96a1943fb8d208aa84c386cf48f2b62038b09e2e
Parent:        14902d173917e814061a80f16ea54435abba1f91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 23 12:52:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 23 13:16:35 2016 +0100

tests: update test

lvm2 now correctly reports thin_id  after action of merged thin,
but before physical metadata update as we know the merge has happened.
---
 test/shell/thin-vglock.sh |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index e59636d..40f3adf 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -37,15 +37,24 @@ check lv_field $vg/snap thin_id "3"
 lvconvert --merge $vg/snap
 
 umount mnt
+
+check lv_field $vg/$lv1 thin_id "1"
+check lv_field $vg/pool transaction_id "3"
+
 vgchange -an $vg
 
 # Check reboot case
 vgchange -ay --sysinit $vg
-# Metadata are still not updated (--poll n)
-check lv_field $vg/$lv1 thin_id "1"
+
+# Check correct thin_id is shown after activation
+# even when metadata were not yet physically modified.
+# Merge take its place during activation,
+# but pool transaction_id still needs metadata update.
+check lv_field $vg/$lv1 thin_id "3"
 check lv_field $vg/pool transaction_id "3"
 
 # Check the metadata are updated after refresh
+#
 vgchange --refresh $vg
 check lv_field $vg/$lv1 thin_id "3"
 check lv_field $vg/pool transaction_id "4"


