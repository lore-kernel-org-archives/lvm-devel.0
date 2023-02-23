From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:50 +0000 (GMT)
Subject: main - tests: use aux mdadm wrapper
Message-ID: <20230223154850.1593C3858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5acdc2d79d7bf662f85694ec3d89db65d5f3701
Commit:        f5acdc2d79d7bf662f85694ec3d89db65d5f3701
Parent:        d7c4fb77436d529c3a8d7a454a5acb7ff767abba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 15:37:39 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

tests: use aux mdadm wrapper

Wrapper takes care of proper MD device name around its various
incarnations.
---
 test/shell/devicesfile-devname.sh  | 7 +++----
 test/shell/udev-pvscan-vgchange.sh | 9 ++++-----
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 211f4dbed..76c978fb0 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -586,9 +586,6 @@ aux wipefs_a "$dev2"
 aux wipefs_a "$dev3"
 aux wipefs_a "$dev4"
 
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
 rm "$DF"
 touch "$DF"
 vgcreate $vg1 "$dev1" "$dev2"
@@ -603,7 +600,9 @@ OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
 PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
 PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
 
-mdadm --create --metadata=1.0 "$mddev" --level 1 --raid-devices=2 "$dev3" "$dev4"
+aux mdadm_create --metadata=1.0 --level 1 --raid-devices=2 "$dev3" "$dev4"
+mddev=$(< MD_DEV)
+
 wait_md_create "$mddev"
 
 sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index e9fda5797..0d43e1bf3 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -363,14 +363,13 @@ wait_md_create() {
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
        modprobe raid1 || skip
 
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
 wipe_all
 rm $DF
 touch $DF
 
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+aux mdadm_create --metadata=1.0 --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
+
 wait_md_create "$mddev"
 vgcreate $vg9 "$mddev"
 lvmdevices --adddev "$mddev" || true
@@ -383,7 +382,7 @@ lvcreate -l1 -an -n $lv2 $vg9
 
 mdadm --stop "$mddev"
 _clear_online_files
-mdadm --assemble "$mddev" "$dev1" "$dev2"
+aux mdadm_assemble "$mddev" "$dev1" "$dev2"
 
 # this trigger might be redundant because the mdadm --assemble
 # probably triggers an add uevent

