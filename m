From: David Teigland <teigland@sourceware.org>
Date: Mon,  7 Feb 2022 22:47:34 +0000 (GMT)
Subject: main - tests: udev-pvscan-vgchange fix service wait
Message-ID: <20220207224734.9C11B3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61f23fe15e0c6e5b7882263e0d527f363535da4d
Commit:        61f23fe15e0c6e5b7882263e0d527f363535da4d
Parent:        13122bcc3329f3c1aee0a1cc478eda8906cd96df
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 7 16:44:57 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 7 16:44:57 2022 -0600

tests: udev-pvscan-vgchange fix service wait

As a result of removing -r from systemd-run in
commit fbd8b0cf43dc67f51f86f060dce748f446985855
this test needs to change how it handles the
transient services.
---
 test/shell/udev-pvscan-vgchange.sh | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index a209dc048..eb6984078 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -75,7 +75,7 @@ wait_lvm_activate() {
 	local vgw=$1
 	local wait=0
 
-	while systemctl status lvm-activate-$vgw | grep "active (running)" && test "$wait" -le 30; do
+	while systemctl status lvm-activate-$vgw > /dev/null && test "$wait" -le 30; do
 		sleep .2
 		wait=$(( wait + 1 ))
 	done
@@ -382,7 +382,6 @@ lvcreate -l1 -an -n $lv1 $vg9
 lvcreate -l1 -an -n $lv2 $vg9
 
 mdadm --stop "$mddev"
-systemctl stop lvm-activate-$vg9 || true
 _clear_online_files
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 
@@ -405,17 +404,6 @@ mdadm --stop "$mddev"
 aux udev_wait
 wipe_all
 
-systemctl stop lvm-activate-$vg1
-systemctl stop lvm-activate-$vg2
-systemctl stop lvm-activate-$vg3
-systemctl stop lvm-activate-$vg4
-systemctl stop lvm-activate-$vg5
-systemctl stop lvm-activate-$vg6
-systemctl stop lvm-activate-$vg7
-systemctl stop lvm-activate-$vg8
-systemctl stop lvm-activate-$vg9
-
-
 # no devices file, filter with symlink of PV
 # the pvscan needs to look at all dev names to
 # match the symlink in the filter with the
@@ -439,7 +427,6 @@ udevadm trigger --settle -c add /sys/block/$BDEV1
 ls /dev/disk/by-id/lvm-pv-uuid-$OPVID1
 
 vgchange -an $vg10
-systemctl stop lvm-activate-$vg10
 _clear_online_files
 
 aux lvmconf "devices/filter = [ \"a|/dev/disk/by-id/lvm-pv-uuid-$OPVID1|\", \"r|.*|\" ]"


