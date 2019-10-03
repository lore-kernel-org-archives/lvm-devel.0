From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 Oct 2019 16:11:19 -0400
Subject: master - tests: update to md dev name
Message-ID: <201910032011.x93KBJgj009697@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2ff8876f97a5840cd9d6fcda1bec55ef6220dc3
Commit:        c2ff8876f97a5840cd9d6fcda1bec55ef6220dc3
Parent:        b138a87f43bcfdd3f523556d54f0a482ecf8c40b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 2 12:51:17 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 2 14:09:51 2019 -0500

tests: update to md dev name

Use /dev/md33 instead of /dev/md0 to reduce chances of
conflicting with an existing name.

Only call 'mdadm --stop /dev/md33' for cleanup and don't
use 'mdadm --stop --scan' to avoid stopping other md devs.
---
 test/lib/aux.sh                     |    7 +++++--
 test/shell/duplicate-pvs-md0.sh     |   12 +++---------
 test/shell/duplicate-pvs-md1.sh     |   15 +++------------
 test/shell/lvm-on-md.sh             |    7 +++----
 test/shell/pvcreate-operation-md.sh |    5 ++---
 5 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7b0ef22..3c7ee62 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -421,13 +421,15 @@ teardown_devs() {
 	teardown_udev_cookies
 
 	test ! -f MD_DEV || cleanup_md_dev
+
+	test ! -f WAIT_MD_DEV || mddev=$(< WAIT_MD_DEV)
 	udev_wait
-	mdadm --stop --scan || true
+	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
 	udev_wait
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
-	mdadm --stop --scan || true
+	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
@@ -792,6 +794,7 @@ wait_md_create() {
 			break
 		fi
 	done
+	echo "$md" > WAIT_MD_DEV
 }
 
 prepare_backing_dev() {
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index d5164ce..e3f453f 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -32,7 +32,9 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
         modprobe raid0 || skip
-not grep md0 /proc/mdstat || skip
+
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -64,7 +66,6 @@ pvcreate "$dev3"
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -137,7 +138,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -210,7 +210,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -266,7 +265,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -327,7 +325,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -374,7 +371,6 @@ aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
-mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
@@ -389,7 +385,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -441,7 +436,6 @@ aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
-mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index 334ac41..a642c55 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -37,7 +37,9 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
         modprobe raid1 || skip
-not grep md0 /proc/mdstat || skip
+
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -69,7 +71,6 @@ pvcreate "$dev3"
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -143,7 +144,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -229,7 +229,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -294,7 +293,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -363,7 +361,6 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -421,7 +418,6 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
-mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
@@ -435,7 +431,6 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -487,7 +482,6 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
-mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
@@ -502,7 +496,6 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -567,7 +560,6 @@ aux udev_wait
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
 aux wait_md_create "$mddev"
 pvcreate "$mddev"
@@ -628,7 +620,6 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
-mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index a8df814..726adf2 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -32,7 +32,9 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
-not grep md0 /proc/mdstat || skip
+
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -52,7 +54,6 @@ aux prepare_devs 3
 # create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data at the end of device
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 vgcreate $vg "$mddev"
@@ -177,7 +178,6 @@ aux udev_wait
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 vgcreate $vg "$mddev"
@@ -308,7 +308,6 @@ aux lvmconf 'devices/obtain_device_list_from_udev = 1'
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
 
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 6e43e5f..49edf4c 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -22,7 +22,8 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
-not grep md0 /proc/mdstat || skip
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 aux extend_filter_md "a|/dev/md|"
@@ -30,7 +31,6 @@ aux extend_filter_md "a|/dev/md|"
 aux prepare_devs 2
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-mddev="/dev/md0"
 mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 aux wait_md_create "$mddev"
 
@@ -122,7 +122,6 @@ aux udev_wait
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if aux kernel_at_least 2 6 33 ; then
 
-    mddev="/dev/md0"
     mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=1024 --raid-devices=2 "$dev1" "$dev2"
     aux wait_md_create "$mddev"
     pvdev="$mddev"


