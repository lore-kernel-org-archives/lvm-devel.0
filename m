From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Sep 2019 11:11:45 -0400
Subject: master - tests: use standard md devices
Message-ID: <201909121511.x8CFBjRn018464@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fe04f89efa97bf25b7b5ca6f382e957a9adf43d
Commit:        1fe04f89efa97bf25b7b5ca6f382e957a9adf43d
Parent:        772dbb1e39d007c770dd7ddb5ca912009658f8a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:26:41 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 10:11:27 2019 -0500

tests: use standard md devices

---
 test/lib/aux.sh                     |   27 ++++++++++-
 test/shell/duplicate-pvs-md0.sh     |   74 +++++++++++++++------------
 test/shell/duplicate-pvs-md1.sh     |   95 +++++++++++++++++------------------
 test/shell/lvm-on-md.sh             |   50 +++++++++++--------
 test/shell/pvcreate-operation-md.sh |   37 ++++++++++----
 5 files changed, 169 insertions(+), 114 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 32d5a0b..b7207eb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -775,6 +775,20 @@ cleanup_md_dev() {
 	rm -f MD_DEV MD_DEVICES MD_DEV_PV
 }
 
+wait_md_create() {
+	local md=$1
+
+	while :; do
+		if ! grep `basename $md` /proc/mdstat; then
+			echo "$md not ready"
+			cat /proc/mdstat
+			sleep 2
+		else
+			break
+		fi
+	done
+}
+
 prepare_backing_dev() {
 	local size=${1=32}
 	shift
@@ -1093,6 +1107,17 @@ extend_filter() {
 	lvmconf "$filter" "devices/scan_lvs = 1"
 }
 
+extend_filter_md() {
+	local filter
+
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	for rx in "$@"; do
+		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
+	done
+	lvmconf "$filter"
+	lvmconf "devices/scan = [ \"$DM_DEV_DIR\", \"/dev\" ]"
+}
+
 extend_filter_LVMTEST() {
 	extend_filter "a|$DM_DEV_DIR/$PREFIX|" "$@"
 }
@@ -1165,7 +1190,7 @@ devices/dir = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
 devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection = 0
-devices/scan = "$DM_DEV_DIR"
+devices/scan = [ "$DM_DEV_DIR" ]
 devices/sysfs_scan = 1
 devices/write_cache_state = 0
 global/abort_on_internal_errors = 1
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 5578a0c..4c7863d 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
@@ -29,6 +30,7 @@ _clear_online_files() {
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
         modprobe raid0 || skip
+not grep md0 /proc/mdstat
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -37,7 +39,7 @@ aux lvmconf 'devices/md_component_detection = 1'
 # want to rely on that ability in this test.
 aux lvmconf 'devices/obtain_device_list_from_udev = 0'
 
-aux extend_filter_LVMTEST "a|/dev/md|"
+aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 4
 
@@ -60,10 +62,9 @@ pvcreate "$dev3"
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -119,7 +120,11 @@ not grep "active" out
 
 vgchange -an $vg
 vgremove -f $vg
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
 
 ##########################################
@@ -130,10 +135,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -189,7 +193,11 @@ not grep "active" out
 
 vgchange -an $vg
 vgremove -f $vg
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
 
 ##########################################
@@ -200,10 +208,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -245,7 +252,9 @@ pvscan --cache -aay "$dev2"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-aux cleanup_md_dev
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
 ##########################################
 # PV on an md raid0 device, start+stopped
@@ -255,11 +264,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-wipefs -a "$dev1" "$dev2"
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -304,7 +311,9 @@ not ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
 not grep "active" out
 
-aux cleanup_md_dev
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
 
 ##########################################
@@ -316,11 +325,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-wipefs -a "$dev1" "$dev2"
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -361,7 +368,7 @@ not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
-aux udev_wait
+aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
@@ -369,6 +376,7 @@ mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
+aux udev_wait
 
 ##########################################
 # PV on an md raid0 device, auto+stopped
@@ -379,10 +387,9 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -428,7 +435,7 @@ not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
-aux udev_wait
+aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
@@ -436,3 +443,4 @@ mdadm --stop --scan
 cat /proc/mdstat
 wipefs -a "$dev1" || true
 wipefs -a "$dev2" || true
+aux udev_wait
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index ccd113f..d242e03 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -16,6 +16,7 @@
 # . a single PV/VG cloned plus a dm wrapper (two separate dups of a PV)
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
@@ -34,6 +35,7 @@ _clear_online_files() {
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
         modprobe raid1 || skip
+not grep md0 /proc/mdstat
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -42,7 +44,7 @@ aux lvmconf 'devices/md_component_detection = 1'
 # want to rely on that ability in this test.
 aux lvmconf 'devices/obtain_device_list_from_udev = 0'
 
-aux extend_filter_LVMTEST "a|/dev/md|"
+aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 4
 
@@ -65,11 +67,9 @@ pvcreate "$dev3"
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -125,7 +125,12 @@ not grep "active" out
 
 vgchange -an $vg
 vgremove -f $vg
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
+
 
 
 ##########################################
@@ -136,11 +141,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -210,7 +213,11 @@ not pvscan --cache -aay "$dev1"
 
 vgchange -an $vg
 vgremove -f $vg
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
 
 ##########################################
@@ -221,11 +228,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -267,7 +272,10 @@ pvscan --cache -aay "$dev2"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-aux cleanup_md_dev
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
+
 
 ##########################################
 # PV on an md raid1 device, start+stopped
@@ -285,12 +293,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-wipefs -a "$dev1" "$dev2"
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -367,12 +372,9 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-wipefs -a "$dev1" "$dev2"
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -442,11 +444,9 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -511,11 +511,9 @@ wipefs -a "$dev2" || true
 
 aux lvmconf 'devices/md_component_checks = "auto"'
 
-aux prepare_md_dev 1 64 3 "$dev1" "$dev2" "$dev4"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
@@ -563,7 +561,11 @@ pvscan --cache -aay "$dev4"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-aux cleanup_md_dev
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+wipefs -a "$dev4"
+aux udev_wait
+
 
 
 ##########################################
@@ -574,12 +576,9 @@ aux cleanup_md_dev
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
-wipefs -a "$dev1" "$dev2" "$dev4"
-aux prepare_md_dev 1 64 3 "$dev1" "$dev2" "$dev4"
-sleep 4
-cat /proc/mdstat
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
+aux wait_md_create "$mddev"
 pvcreate "$mddev"
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 echo $PVIDMD
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 2877ea2..6862101 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
@@ -29,6 +30,7 @@ _clear_online_files() {
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
+not grep md0 /proc/mdstat
 
 aux lvmconf 'devices/md_component_detection = 1'
 
@@ -41,19 +43,16 @@ aux lvmconf 'devices/hints = "none"'
 # want to rely on that ability in this test.
 aux lvmconf 'devices/obtain_device_list_from_udev = 0'
 
-aux extend_filter_LVMTEST "a|/dev/md|"
+aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 3
 
 # create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data at the end of device
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
-
-cat /proc/mdstat
-
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
 
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 vgcreate $vg "$mddev"
 
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
@@ -164,19 +163,21 @@ aux udev_wait
 
 vgremove -f $vg
 
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
+
 
 # create 2 disk MD raid0 array
 # by default using metadata format 1.0 with data at the end of device
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-
-cat /proc/mdstat
-
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
 
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 vgcreate $vg "$mddev"
 
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
@@ -288,7 +289,12 @@ aux udev_wait
 
 vgremove -f $vg
 
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
+
 
 # Repeat tests using the default config settings
 
@@ -299,12 +305,10 @@ aux lvmconf 'devices/obtain_device_list_from_udev = 1'
 # by default using metadata format 1.0 with data at the end of device
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
 
-cat /proc/mdstat
-
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 
 # Create an unused PV so that there is@least one PV in the hints
 # when the MD dev is stopped.  If there are no PVs, the hints are
@@ -454,5 +458,9 @@ aux udev_wait
 
 vgremove -f $vg
 
-aux cleanup_md_dev
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 4b51932..12cf891 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -20,17 +20,19 @@ which sfdisk || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
+not grep md0 /proc/mdstat
 
 aux lvmconf 'devices/md_component_detection = 1'
-aux extend_filter_LVMTEST "a|/dev/md|"
+aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 2
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
+mddev="/dev/md0"
+mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux wait_md_create "$mddev"
 
-mddev=$(< MD_DEV)
-pvdev=$(< MD_DEV_PV)
+pvdev="$mddev"
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
@@ -82,7 +84,7 @@ EOF
     if aux kernel_at_least 2 6 33 ; then
 	# in case the system is running without devtmpfs /dev
 	# wait here for created device node on tmpfs
-	test "$DM_DEV_DIR" = "/dev" || cp -LR "${mddev}p1" "${pvdev%/*}"
+	# test "$DM_DEV_DIR" = "/dev" || cp -LR "${mddev}p1" "${pvdev%/*}"
 
 	pvcreate --metadatasize 128k "${pvdev}p1"
 
@@ -105,17 +107,23 @@ EOF
 	check pv_field "${pvdev}p1" pe_start $pv_align --units b --nosuffix
 
 	pvremove "${pvdev}p1"
-	test "$DM_DEV_DIR" = "/dev" || rm -f "${pvdev}p1"
+	# test "$DM_DEV_DIR" = "/dev" || rm -f "${pvdev}p1"
     fi
 fi
 
+mdadm --stop "$mddev"
+aux udev_wait
+wipefs -a "$dev1"
+wipefs -a "$dev2"
+aux udev_wait
+
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if aux kernel_at_least 2 6 33 ; then
-    # make sure we're clean for another test
-    dd if=/dev/zero of="$mddev" bs=512 count=4 conv=fdatasync
-    partprobe -s "$mddev"
-    aux prepare_md_dev 0 1024 2 "$dev1" "$dev2"
-    pvdev=$(< MD_DEV_PV)
+
+    mddev="/dev/md0"
+    mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=1024 --raid-devices=2 "$dev1" "$dev2"
+    aux wait_md_create "$mddev"
+    pvdev="$mddev"
 
     # optimal_io_size=2097152, minimum_io_size=1048576
     pvcreate --metadatasize 128k \
@@ -130,4 +138,11 @@ if aux kernel_at_least 2 6 33 ; then
     pvcreate --dataalignment 64k --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
     check pv_field "$pvdev" pe_start "192.00k"
+
+    mdadm --stop "$mddev"
+    aux udev_wait
+    wipefs -a "$dev1"
+    wipefs -a "$dev2"
+    aux udev_wait
+
 fi


