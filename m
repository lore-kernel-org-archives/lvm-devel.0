From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Feb 2021 11:10:40 +0000 (GMT)
Subject: stable-2.02 - tests: make test complaint to local dev dir
Message-ID: <20210224111040.6D83A386103F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85795593b8449d9fb4fed0eb252906c9a28b0ddd
Commit:        85795593b8449d9fb4fed0eb252906c9a28b0ddd
Parent:        f3babcb59123e61b0ecead3c8547a4c0ad607276
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 24 11:54:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 24 11:56:12 2021 +0100

tests: make test complaint to local dev dir

For test running in 'local' dev dir we want to see loop devices there.
Also add missing notification to lvmetad after wipefs.
---
 test/shell/allow-mixed-block-sizes.sh | 57 ++++++++++++++++++++---------------
 1 file changed, 33 insertions(+), 24 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index 2f0b3a065..3e7bd11f6 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2019-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,32 +15,41 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 losetup -h | grep sector-size || skip
+which fallocate || skip
+which wipefs || skip
 
-dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
-dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
+fallocate -l 2M loopa
+fallocate -l 2M loopb
 LOOP1=$(losetup -f loopa --sector-size 4096 --show)
 LOOP2=$(losetup -f loopb --show)
 
-echo $LOOP1
-echo $LOOP2
-
-aux extend_filter "a|$LOOP1|"
-aux extend_filter "a|$LOOP2|"
-
-not vgcreate --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP1 $LOOP2
-vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1 $LOOP2
-vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
-
-wipefs -a $LOOP1
-wipefs -a $LOOP2
-
-vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1
-vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
-not vgextend --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOOP2
-vgextend --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP2
-
-losetup -d $LOOP1
-losetup -d $LOOP2
+# prepare devX mapping so it works for real & fake dev dir
+d=1
+for i in "$LOOP1" "$LOOP2"; do
+	echo "$i"
+	m=${i##*loop}
+	test -e "$DM_DEV_DIR/loop$m" || mknod "$DM_DEV_DIR/loop$m" b 7 "$m"
+	eval "dev$d=\"$DM_DEV_DIR/loop$m\""
+	d=$(( d + 1 ))
+done
+
+aux extend_filter "a|$dev1|" "a|$dev2|"
+
+not vgcreate --config 'devices/allow_mixed_block_sizes=0' $vg "$dev1" "$dev2"
+vgcreate --config 'devices/allow_mixed_block_sizes=1' $vg "$dev1" "$dev2"
+vgs --config 'devices/allow_mixed_block_sizes=1' $vg
+
+for i in "$dev1" "$dev2" ; do
+	wipefs -a "$i"
+        aux notify_lvmetad "$i"
+done
+
+vgcreate --config 'devices/allow_mixed_block_sizes=1' $vg "$dev1"
+vgs --config 'devices/allow_mixed_block_sizes=1' $vg
+not vgextend --config 'devices/allow_mixed_block_sizes=0' $vg "$dev2"
+vgextend --config 'devices/allow_mixed_block_sizes=1' $vg "$dev2"
+
+losetup -d "$LOOP1"
+losetup -d "$LOOP2"
 rm loopa
 rm loopb
-


