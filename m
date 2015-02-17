From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Feb 2015 10:05:53 +0000 (UTC)
Subject: master - tests: syncaction update
Message-ID: <20150217100553.2D20260DF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd1a76a49222feb975b440199881d7c70faf103a
Commit:        cd1a76a49222feb975b440199881d7c70faf103a
Parent:        120e1aa4bd13a8b2f49b7d6660f83b0277190774
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 17 11:03:20 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 17 11:05:04 2015 +0100

tests: syncaction update

Improve syncaction testing with some minor
workaround for current upstream kernel
---
 test/shell/lvchange-syncaction-raid.sh |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 7ef4e01..9c51299 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -27,17 +27,28 @@ START=$(get pv_field "$dev2" pe_start --units 1k)
 METASIZE=$(get lv_field $vg/${lv1}_rmeta_1 size -a --units 1k)
 SEEK=$((${START%\.00k} + ${METASIZE%\.00k}))
 # Overwrite some portion of  _rimage_1
+
+#aux delay_dev "$dev2" 10 10
 dd if=/dev/urandom of="$dev2" bs=1K count=1 seek=$SEEK oflag=direct
+# FIXME
+# Some delay - there is currently race in upstream kernel
+# test may occasionaly fail with:
+# device-mapper: message ioctl on  failed: Device or resource busy
+#
+# Heinz's kernel seems to fix this particular issue but
+# has some other problem for now
+aux udev_wait
 
-aux wait_for_sync $vg $lv1
 lvchange --syncaction check $vg/$lv1
+
+# Wait till scrubbing is finished
+aux wait_for_sync $vg $lv1
+
 check lv_field $vg/$lv1 raid_mismatch_count "128"
 
 # Let's deactivate
 lvchange -an $vg/$lv1
 
-# Slow down write by 100ms
-aux delay_dev "$dev2" 0 50
 lvchange -ay $vg/$lv1
 # noone has it open and target is read & running
 dmsetup info -c | grep $vg
@@ -55,9 +66,17 @@ dmsetup info -c | grep $vg
 # As solution for now - user needs to run --synaction on synchronous raid array
 #
 aux wait_for_sync $vg $lv1
-should lvchange --syncaction check $vg/$lv1
 
-aux enable_dev "$dev2"
+# Check raid array doesn't know about error yet
 check lv_field $vg/$lv1 raid_mismatch_count "0"
 
+# Start scrubbing
+lvchange --syncaction check $vg/$lv1
+
+# Wait till scrubbing is finished
+aux wait_for_sync $vg $lv1
+
+# Retest mistmatch exists
+check lv_field $vg/$lv1 raid_mismatch_count "128"
+
 vgremove -ff $vg


