From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 12:34:21 -0500
Subject: master - tests: reduce sizes in pvck-dump and improve checks
Message-ID: <202003041734.024HYLJI028371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b5bfa779a744b3ad3b3d28dcb6797110a39dbab
Commit:        4b5bfa779a744b3ad3b3d28dcb6797110a39dbab
Parent:        f6667f94cb1204aad5703d129aeeca8286ebaf18
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 4 11:30:50 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 4 11:30:50 2020 -0600

tests: reduce sizes in pvck-dump and improve checks

Smaller devs can be used so tests can be run on small vms.
Improve checks.
---
 test/shell/pvck-dump.sh | 66 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 50 insertions(+), 16 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 5c662f6..3277312 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -12,13 +12,16 @@
 
 . lib/inittest
 
-aux prepare_devs 8 512
+# 4 devs each 128MB
+aux prepare_devs 4 128
 get_devs
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+dd if=/dev/zero of="$dev1" bs=1M count=32 || true
+dd if=/dev/zero of="$dev2" bs=1M count=32 || true
+dd if=/dev/zero of="$dev3" bs=1M count=32 || true
+dd if=/dev/zero of="$dev4" bs=1M count=32 || true
+# clear entire dev to cover mda2
 dd if=/dev/zero of="$dev3" || true
-dd if=/dev/zero of="$dev4" || true
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -27,6 +30,8 @@ pvcreate --pvmetadatacopies 0 "$dev4"
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
+pvs
+
 pvck --dump headers "$dev1" > h1
 pvck --dump headers "$dev2" > h2
 pvck --dump headers "$dev3" > h3
@@ -129,14 +134,17 @@ diff area1 area3b
 
 vgremove -ff $vg
 
-pvremove "$dev1"
-pvremove "$dev2"
-pvremove "$dev3"
-pvremove "$dev4"
+
+dd if=/dev/zero of="$dev1" bs=1M count=32 || true
+dd if=/dev/zero of="$dev2" bs=1M count=32 || true
+dd if=/dev/zero of="$dev3" bs=1M count=32 || true
+dd if=/dev/zero of="$dev4" bs=1M count=32 || true
+# clear entire dev to cover mda2
+dd if=/dev/zero of="$dev1" || true
 
 pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
-vgcreate $SHARED -s 512K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8"
+vgcreate $SHARED -s 512K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 for i in `seq 1 500`; do lvcreate -an -n lv$i -l1 $vg; done
 
@@ -145,20 +153,46 @@ pvck --dump headers "$dev1" > h1
 pvck --dump metadata_search "$dev1" > m1
 grep "seqno 500" m1
 
-dd if="$dev1" of=dev1dd bs=1M count=32
+# When metadatasize is 32M, headers/rounding can mean that
+# we need more than the first 32M of the dev to get all the
+# metadata.
+dd if="$dev1" of=dev1dd bs=1M count=34
+
+# Clear the header so that we force metadata_search to use
+# the settings instead of getting the mda_size/mda_offset
+# from the headers.
 dd if=/dev/zero of="$dev1" bs=4K count=1
 
-# mda_size for mda1 is 32M - 4K
-pvck --dump metadata_search --settings "mda_num=1 mda_size=33550336" "$dev1" > m1b
+# Warning: these checks are based on copying specific numbers
+# seen when running these commands, but these numbers could
+# change as side effects of other things.  That makes this
+# somewhat fragile, and we might want to remove some of the
+# these checks if they are hard to keep working.
+
+# by experimentation, mda_size for mda1 is 34598912
+pvck --dump metadata_search --settings "mda_num=1 mda_size=34598912" "$dev1" > m1b
+# by experimentation, metadata 484 is the last in the mda1 buffer
+grep "seqno 484" m1b
+# by experimentation, metadata 485 is the last in the mda1 buffer
+grep "seqno 485" m1b
 grep "seqno 500" m1b
 
-pvck --dump metadata_search --settings "mda_num=1 mda_size=33550336" dev1dd > m1c
-grep "seqno 500" m1c
+# same results when using file as on device
+pvck --dump metadata_search --settings "mda_num=1 mda_size=34598912" dev1dd > m1c
+# by experimentation, metadata 484 is the last in the mda1 buffer
+grep "seqno 484" m1b
+# by experimentation, metadata 485 is the last in the mda1 buffer
+grep "seqno 485" m1b
+grep "seqno 500" m1b
 
-# mda_size for mda2 is 32M
+# by experimentation, mda_size for mda2 is 33554432
 pvck --dump metadata_search --settings "mda_num=2 mda_size=33554432" "$dev1" > m2
+# by experimentation, metadata 477 is the last in the mda2 buffer
+grep "seqno 477" m1b
+# by experimentation, metadata 478 is the last in the mda2 buffer
+grep "seqno 478" m1b
 grep "seqno 500" m2
 
-dd if=dev1dd of="$dev1" bs=1M count=32
+dd if=dev1dd of="$dev1" bs=4K count=1
 
 vgremove -ff $vg



