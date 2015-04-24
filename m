From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:31 +0000 (UTC)
Subject: master - tests: use new help in aux
Message-ID: <20150424224231.E95BD60C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7d28639eb4a2cd5adbf5b14b07702ba4d84593c
Commit:        a7d28639eb4a2cd5adbf5b14b07702ba4d84593c
Parent:        1e3c135d7178426d3cd1c92a3ab9a71303b64aa2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 25 00:38:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:40:02 2015 +0200

tests: use new help in aux

Simplify tests and use aux mdadm helpers.
---
 test/shell/lvmetad-pvscan-md.sh     |   65 +++---------------
 test/shell/pvcreate-operation-md.sh |  133 +++++++++++------------------------
 2 files changed, 50 insertions(+), 148 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index ff86fdd..bfa6171 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,72 +12,25 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
-which mdadm || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 
-aux lvmconf 'devices/md_component_detection = 1'
-aux extend_filter_LVMTEST
-aux extend_filter "a|/dev/md.*|"
-
 aux prepare_devs 2
 
-# TODO factor out the following MD-creation code into lib/
-
-# Have MD use a non-standard name to avoid colliding with an existing MD device
-# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
-# - newer mdadm _completely_ defers to udev to create the associated device node
-mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
-[ $mdadm_maj -ge 3 ] && \
-    mddev=/dev/md/md_lvm_test0 || \
-    mddev=/dev/md_lvm_test0
-
-cleanup_md() {
-    # sleeps offer hack to defeat: 'md: md127 still in use'
-    # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
-    aux udev_wait
-    mdadm --stop "$mddev" || true
-    # also remove singnatures
-    mdadm --zero-superblock "$dev1" "$dev2" || true
-    aux udev_wait
-    if [ -b "$mddev" ]; then
-        # mdadm doesn't always cleanup the device node
-	sleep 2
-	rm -f "$mddev"
-    fi
-}
-
-cleanup_md_and_teardown() {
-    cleanup_md
-    aux teardown
-}
-
 # create 2 disk MD raid0 array (stripe_width=128K)
-test -b "$mddev" && skip
-trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
-mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
-test -b "$mddev" || skip
-if test "$DM_DEV_DIR" != "/dev" ; then
-	cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
-	pvdev="$DM_DEV_DIR/md_lvm_test0"
-else
-	pvdev=$(readlink -f "$mddev")
-fi
-# TODO end MD-creation code
+aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
 
-# maj=$(($(stat -L --printf=0x%t "$dev2")))
-# min=$(($(stat -L --printf=0x%T "$dev2")))
+aux lvmconf 'devices/md_component_detection = 1'
+aux extend_filter_LVMTEST
+aux extend_filter "a|/dev/md.*|"
 
-pvcreate "$pvdev"
+pvdev=$(< MD_DEV_PV)
 
-pvscan --cache "$pvdev"
+pvcreate "$pvdev"
 
 # ensure that lvmetad can only see the toplevel MD device
-pvscan --cache "$dev1" 2>&1 | grep "not found"
-pvscan --cache "$dev2" 2>&1 | grep "not found"
-
 pvs | tee out
 grep "$pvdev" out
-pvs | not grep "$dev1"
-pvs | not grep "$dev2"
+not grep "$dev1" out
+not grep "$dev2" out
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index ec15c5d..2bfb937 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,11 +12,7 @@
 . lib/inittest
 
 # skip this test if mdadm or sfdisk (or others) aren't available
-which mdadm || skip
 which sfdisk || skip
-which perl || skip
-which awk || skip
-which cut || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
@@ -27,66 +23,33 @@ aux extend_filter "a|/dev/md.*|"
 
 aux prepare_devs 2
 
-# Have MD use a non-standard name to avoid colliding with an existing MD device
-# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
-# - newer mdadm _completely_ defers to udev to create the associated device node
-mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
-[ $mdadm_maj -ge 3 ] && \
-    mddev=/dev/md/md_lvm_test0 || \
-    mddev=/dev/md_lvm_test0
-
-cleanup_md() {
-    # sleeps offer hack to defeat: 'md: md127 still in use'
-    # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
-    aux udev_wait
-    mdadm --stop "$mddev" || true
-    mdadm --zero-superblock "$dev1" "$dev2" || true
-    aux udev_wait
-    if [ -b "$mddev" ]; then
-        # mdadm doesn't always cleanup the device node
-	sleep 2
-	rm -f "$mddev"
-    fi
-}
-
-cleanup_md_and_teardown() {
-    cleanup_md
-    aux teardown
-}
-
 # create 2 disk MD raid0 array (stripe_width=128K)
-test -b "$mddev" && skip
-trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
-mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
-test -b "$mddev" || skip
-test "$DM_DEV_DIR" != "/dev" && cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
-lvmdev="$DM_DEV_DIR/md_lvm_test0"
+aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
+
+mddev=$(< MD_DEV)
+pvdev=$(< MD_DEV_PV)
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
-pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    "$lvmdev"
+    "$pvdev"
 
-check pv_field "$lvmdev" pe_start $pv_align
+check pv_field "$pvdev" pe_start "1.00m"
 
 # Test md_chunk_alignment independent of topology-aware detection
-pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    "$lvmdev"
-check pv_field "$lvmdev" pe_start $pv_align
-
+    "$pvdev"
+check pv_field "$pvdev" pe_start "1.00m"
 
 # Test newer topology-aware alignment detection
 # - first added to 2.6.31 but not "reliable" until 2.6.33
 if kernel_at_least 2 6 33 ; then
-    pv_align="1.00m"
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
-    check pv_field "$lvmdev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
+    check pv_field "$pvdev" pe_start "1.00m"
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
@@ -98,67 +61,53 @@ EOF
     pvscan
     # make sure partition on MD is _not_ removed
     # - tests partition -> parent lookup via sysfs paths
-    not pvcreate --metadatasize 128k "$lvmdev"
+    not pvcreate --metadatasize 128k "$pvdev"
 
     # verify alignment_offset is accounted for in pe_start
     # - topology infrastructure is available in Linux >= 2.6.31
     # - also tests partition -> parent lookup via sysfs paths
 
-    # Oh joy: need to lookup /sys/block/md127 rather than /sys/block/md_lvm_test0
-    mddev_maj_min=$(ls -lL "$mddev" | awk '{ print $5 $6 }' | perl -pi -e 's|,|:|')
-    mddev_p_sysfs_name=$(echo /sys/dev/block/${mddev_maj_min}/*p1)
-    base_mddev_p=`basename $mddev_p_sysfs_name`
-    mddev_p=/dev/${base_mddev_p}
-
-    # in case the system is running without devtmpfs /dev
-    # wait here for created device node on tmpfs
-    aux udev_wait "$mddev_p"
-    test -b "$mddev_p" || skip
-    test "$DM_DEV_DIR" != "/dev" && cp -LR "$mddev_p" "$DM_DEV_DIR"
-    lvmdev_p="$DM_DEV_DIR/$base_mddev_p"
-
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
-    sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
-    [ -f $sysfs_alignment_offset ] && kernel_at_least 2 6 33 && \
-	alignment_offset=`cat $sysfs_alignment_offset` || \
-	alignment_offset=0
-
-    if [ $alignment_offset -gt 0 ]; then
-        # default alignment is 1M, add alignment_offset
-	pv_align=$((1048576+$alignment_offset))B
-	pvcreate --metadatasize 128k "$lvmdev_p"
-	check pv_field "$lvmdev_p" pe_start $pv_align --units b
-	pvremove "$lvmdev_p"
+    if kernel_at_least 2 6 33 ; then
+	# in case the system is running without devtmpfs /dev
+	# wait here for created device node on tmpfs
+	test "$DM_DEV_DIR" != "/dev" && cp -LR "${mddev}p1" "$DM_DEV_DIR"
+
+	pvcreate --metadatasize 128k "${pvdev}p1"
+	check sysfs "${pvdev}p1" alignment_offset 0
+
+	maj=$(($(stat -L --printf=0x%t "${mddev}p1")))
+	min=$(($(stat -L --printf=0x%T "${mddev}p1")))
+
+	sysfs_alignment_offset="/sys/dev/block/$maj:$min/alignment_offset"
+	[ -f "$sysfs_alignment_offset" ] && \
+		alignment_offset=$(< "$sysfs_alignment_offset") || \
+		alignment_offset=0
+
+	# default alignment is 1M, add alignment_offset
+	pv_align=$((1048576+$alignment_offset))
+	check pv_field "${pvdev}p1" pe_start $pv_align --units b --nosuffix
+
+	pvremove "${pvdev}p1"
+	test "$DM_DEV_DIR" != "/dev" && rm -f "$DM_DEV_DIR/${mddev}p1"
     fi
 fi
 
-
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if kernel_at_least 2 6 33 ; then
     # make sure we're clean for another test
-    test -b "$mddev" && cleanup_md
-    dd if=/dev/zero of="$dev1" bs=512 count=1
-    dd if=/dev/zero of="$dev2" bs=512 count=1
-
-    pvcreate -f "$dev1"
-    pvcreate -f "$dev2"
-
-    # create 2 disk MD raid0 array (stripe_width=2M)
-    test -b "$mddev" && skip
-    mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 1024 "$dev1" "$dev2"
-    test -b "$mddev" || skip
+    dd if=/dev/zero of="$mddev" bs=512 count=1
+    aux prepare_md_dev 0 1024 2 "$dev1" "$dev2"
+    pvdev=$(< MD_DEV_PV)
 
     # optimal_io_size=2097152, minimum_io_size=1048576
-    pv_align="2.00m"
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
-    pvscan # Something is seriously broken.
-    check pv_field "$lvmdev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
+    check pv_field "$pvdev" pe_start "2.00m"
 
     # now verify pe_start alignment override using --dataalignment
-    pv_align="192.00k"
     pvcreate --dataalignment 64k --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' "$lvmdev"
-    check pv_field "$lvmdev" pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
+    check pv_field "$pvdev" pe_start "192.00k"
 fi


