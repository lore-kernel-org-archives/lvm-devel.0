From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:01 +0000 (GMT)
Subject: main - tests: add /dev requirement
Message-ID: <20220907130501.E7569385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f3997734480deaae8cb195c4c30bff1e2cfc463
Commit:        9f3997734480deaae8cb195c4c30bff1e2cfc463
Parent:        0ed3f7a1bf7d9a7a144526048e44dd19c29fcfed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 18:00:28 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: add /dev requirement

This test could only be run when user passes  LVM_TEST_DEVDIR=/dev
as it requires and expects actions to be going in this dir, skip
otherwise.

Also 'extend_filter' manages multiple args in on lvm.conf update.
---
 test/shell/vgchange-pvs-online.sh | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/test/shell/vgchange-pvs-online.sh b/test/shell/vgchange-pvs-online.sh
index 9bcf70e4b..8812de1a3 100644
--- a/test/shell/vgchange-pvs-online.sh
+++ b/test/shell/vgchange-pvs-online.sh
@@ -22,24 +22,19 @@ aux prepare_devs 4
 # skip rhel5 which doesn't seem to have /dev/mapper/LVMTESTpv1
 aux driver_at_least 4 15 || skip
 
+test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
+
 DFDIR="$LVM_SYSTEM_DIR/devices"
 mkdir -p "$DFDIR" || true
 DF="$DFDIR/system.devices"
 
 # Because mapping devno to devname gets dm name from sysfs
 aux lvmconf 'devices/scan = "/dev"'
-base1=$(basename $dev1)
-base2=$(basename $dev2)
-base3=$(basename $dev3)
-base4=$(basename $dev4)
-bd1=/dev/mapper/$base1
-bd2=/dev/mapper/$base2
-bd3=/dev/mapper/$base3
-bd4=/dev/mapper/$base4
-aux extend_filter "a|/dev/mapper/$base1|"
-aux extend_filter "a|/dev/mapper/$base2|"
-aux extend_filter "a|/dev/mapper/$base3|"
-aux extend_filter "a|/dev/mapper/$base4|"
+bd1="/dev/mapper/$(basename $dev1)"
+bd2="/dev/mapper/$(basename $dev2)"
+bd3="/dev/mapper/$(basename $dev3)"
+bd4="/dev/mapper/$(basename $dev4)"
+aux extend_filter "a|$bd1|" "a|$bd2|" "a|$bd3|" "a|$bd4|"
 
 # Changing names will confuse df based on devname
 if lvmdevices; then

