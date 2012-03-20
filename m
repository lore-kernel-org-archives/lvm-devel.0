From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 10:49:00 -0000
Subject: LVM2/test/shell dmeventd-restart.sh pvcreate-o ...
Message-ID: <20120320104900.6692.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 10:48:59

Modified files:
	test/shell     : dmeventd-restart.sh pvcreate-operation-md.sh 

Log message:
	Update test for dmevent restart
	
	Actually restart was failing for different reason - so pass in proper
	location of dmeventd for restart from lvm command and avoid using
	the one from /sbin location.
	
	Update pv create test with "" around path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/dmeventd-restart.sh	2012/03/16 19:11:29	1.3
+++ LVM2/test/shell/dmeventd-restart.sh	2012/03/20 10:48:59	1.4
@@ -11,15 +11,8 @@
 
 . lib/test
 
-which mkfs.ext2 || skip
-
 aux prepare_dmeventd
 
-# Currently dmeventd doesn't support any other location
-# for dmeventd restart, so FIXME in dmeventd
-# and update this check
-test -x /sbin/dmeventd || skip
-
 aux prepare_vg 5
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
@@ -28,9 +21,8 @@
 lvchange --monitor y $vg/3way
 
 dmeventd -R -f &
-echo "$!" > LOCAL_DMEVENTD
-
-sleep 1 # wait a bit, so we talk to the new dmeventd later
+echo $! >LOCAL_DMEVENTD
+sleep 2 # wait a bit, so we talk to the new dmeventd later
 
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 grep 'already monitored' lvchange.out
@@ -40,9 +32,15 @@
 # now try what happens if no dmeventd is running
 kill -9 $(cat LOCAL_DMEVENTD)
 dmeventd -R -f &
-sleep 3
+sleep 1
+# now dmeventd should not be running
+pgrep dmeventd
+rm LOCAL_DMEVENTD
+
+# set dmeventd path
+aux lvmconf "dmeventd/executable=\"$abs_top_builddir/test/lib/dmeventd\""
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
-not grep 'already monitored' lvchange.out
 pgrep dmeventd >LOCAL_DMEVENTD
+not grep 'already monitored' lvchange.out
 
 vgremove -ff $vg
--- LVM2/test/shell/pvcreate-operation-md.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/pvcreate-operation-md.sh	2012/03/20 10:48:59	1.3
@@ -37,12 +37,12 @@
     # sleeps offer hack to defeat: 'md: md127 still in use'
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
     aux udev_wait
-    mdadm --stop $mddev || true
+    mdadm --stop "$mddev" || true
     aux udev_wait
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
 	sleep 2
-	rm -f $mddev
+	rm -f "$mddev"
     fi
 }
 
@@ -53,7 +53,7 @@
 
 # create 2 disk MD raid0 array (stripe_width=128K)
 test -b "$mddev" && skip
-mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
+mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
 trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
 test -b "$mddev" || skip
 
@@ -62,15 +62,15 @@
 pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    $mddev
-check pv_field $mddev pe_start $pv_align
+    "$mddev"
+check pv_field "$mddev" pe_start $pv_align
 
 # Test md_chunk_alignment independent of topology-aware detection
 pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
-    $mddev
-check pv_field $mddev pe_start $pv_align
+    "$mddev"
+check pv_field "$mddev" pe_start $pv_align
 
 
 # Test newer topology-aware alignment detection
@@ -79,34 +79,34 @@
     pv_align="1.00m"
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check pv_field $mddev pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$mddev"
+    check pv_field "$mddev" pe_start $pv_align
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
 if kernel_at_least 2 6 28 ; then
     # create one partition
-    sfdisk $mddev <<EOF
+    sfdisk "$mddev" <<EOF
 ,,83
 EOF
     # make sure partition on MD is _not_ removed
     # - tests partition -> parent lookup via sysfs paths
-    not pvcreate --metadatasize 128k $mddev
+    not pvcreate --metadatasize 128k "$mddev"
 
     # verify alignment_offset is accounted for in pe_start
     # - topology infrastructure is available in Linux >= 2.6.31
     # - also tests partition -> parent lookup via sysfs paths
 
     # Oh joy: need to lookup /sys/block/md127 rather than /sys/block/md_lvm_test0
-    mddev_maj_min=$(ls -lL $mddev | awk '{ print $5 $6 }' | perl -pi -e 's|,|:|')
+    mddev_maj_min=$(ls -lL "$mddev" | awk '{ print $5 $6 }' | perl -pi -e 's|,|:|')
     mddev_p_sysfs_name=$(echo /sys/dev/block/${mddev_maj_min}/*p1)
     base_mddev_p=`basename $mddev_p_sysfs_name`
     mddev_p=/dev/${base_mddev_p}
 
     # in case the system is running without devtmpfs /dev
     # wait here for created device node on tmpfs
-    aux udev_wait $mddev_p
-    test -b $mddev_p || skip
+    aux udev_wait "$mddev_p"
+    test -b "$mddev_p" || skip
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
@@ -118,9 +118,9 @@
     if [ $alignment_offset -gt 0 ]; then
         # default alignment is 1M, add alignment_offset
 	pv_align=$((1048576+$alignment_offset))B
-	pvcreate --metadatasize 128k $mddev_p
-	check pv_field $mddev_p pe_start $pv_align --units b
-	pvremove $mddev_p
+	pvcreate --metadatasize 128k "$mddev_p"
+	check pv_field "$mddev_p" pe_start $pv_align --units b
+	pvremove "$mddev_p"
     fi
 fi
 
@@ -132,18 +132,18 @@
 
     # create 2 disk MD raid0 array (stripe_width=2M)
     test -b "$mddev" && skip
-    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 "$dev1" "$dev2"
+    mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 1024 "$dev1" "$dev2"
     test -b "$mddev" || skip
 
     # optimal_io_size=2097152, minimum_io_size=1048576
     pv_align="2.00m"
     pvcreate --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check pv_field $mddev pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$mddev"
+    check pv_field "$mddev" pe_start $pv_align
 
     # now verify pe_start alignment override using --dataalignment
     pv_align="192.00k"
     pvcreate --dataalignment 64k --metadatasize 128k \
-	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check pv_field $mddev pe_start $pv_align
+	--config 'devices { md_chunk_alignment=0 }' "$mddev"
+    check pv_field "$mddev" pe_start $pv_align
 fi


