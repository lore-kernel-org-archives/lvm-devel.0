From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 12:00:29 -0400
Subject: master - tests: correct percent values are reported
Message-ID: <201706241600.v5OG0T0U026848@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cac9e0b681feaf71f59ecf4f41ef724129ad61d2
Commit:        cac9e0b681feaf71f59ecf4f41ef724129ad61d2
Parent:        cefb8bcfc4daf56309038088325c056b0860d5a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 17:24:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:42 2017 +0200

tests: correct percent values are reported

---
 test/shell/lvcreate-thin-big.sh |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 9c84288..235eead 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -29,15 +29,32 @@ vgcreate $vg -s 64K $(cat DEVICES)
 
 # Size 0 is not valid
 invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
-lvcreate -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
+lvcreate -Zn -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
 grep "WARNING: Minimum" out
 # FIXME: metadata allocation fails, if PV doesn't have at least 16GB
 # i.e. pool metadata device cannot be multisegment
-lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
+lvcreate -Zn -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
 grep "WARNING: Maximum" out
 check lv_field $vg/pool1_tmeta size "2.00m"
 check lv_field $vg/pool2_tmeta size "15.81g"
 
+# Check we do report correct percent values.
+lvcreate --type zero -L3G $vg -n pool3
+lvconvert -y --thinpool $vg/pool3
+lvchange --errorwhenfull y $vg/pool3
+lvchange --zero n $vg/pool3
+lvcreate -V10G $vg/pool3 -n $lv1
+lvcreate -V2G $vg/pool3 -n $lv2
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=512b count=1 conv=fdatasync
+# ...excercise write speed to 'zero' device ;)
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=64K count=32767 conv=fdatasync
+lvs -a $vg
+# Check the percentage is not shown as 0.00
+check lv_field $vg/$lv1 data_percent "0.01"
+# Check the percentage is not shown as 100.00
+check lv_field $vg/$lv2 data_percent "99.99"
+
+
 # Check can start and see thinpool with metadata size above kernel limit
 lvcreate -L4M --poolmetadatasize 16G -T $vg/poolM
 check lv_field $vg/poolM data_percent "0.00"


