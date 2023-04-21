From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:35 +0000 (GMT)
Subject: main - tests: use aux clear_dev
Message-ID: <20230421125335.84F123858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2360437e027fc4735afb58d193dc53b61c592d9
Commit:        b2360437e027fc4735afb58d193dc53b61c592d9
Parent:        c331a3b1da280f78aefcfc8dad82eb042022bc84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 13:16:22 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

tests: use aux clear_dev

Use wrapper over 'blkdiscard -z'
---
 test/shell/integrity-caching.sh          |  6 +-----
 test/shell/integrity-syncaction.sh       |  4 +---
 test/shell/integrity.sh                  |  6 +-----
 test/shell/metadata-bad-text.sh          | 21 +++++----------------
 test/shell/metadata-old.sh               |  7 ++-----
 test/shell/process-each-duplicate-pvs.sh |  3 +--
 6 files changed, 11 insertions(+), 36 deletions(-)

diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 5539ac575..23ade6838 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -39,11 +39,7 @@ dd if=/dev/urandom of=randC bs=512K count=4
 _prepare_vg() {
 	# zero devs so we are sure to find the correct file data
 	# on the underlying devs when corrupting it
-	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev4" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev5" bs=1M oflag=direct || true
+	aux clear_devs "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 	pvs
 }
diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index e404f6b6d..32d7a43a5 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -34,9 +34,7 @@ awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 _prepare_vg() {
 	# zero devs so we are sure to find the correct file data
 	# on the underlying devs when corrupting it
-	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
+	aux clear_devs "$dev1" "$dev2" "$dev3"
 	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 	pvs
 }
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index a7dd5b565..290090e2d 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -39,11 +39,7 @@ dd if=/dev/urandom of=randC bs=512K count=4
 _prepare_vg() {
 	# zero devs so we are sure to find the correct file data
 	# on the underlying devs when corrupting it
-	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev4" bs=1M oflag=direct || true
-	dd if=/dev/zero of="$dev5" bs=1M oflag=direct || true
+	aux clear_devs "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	pvs
 }
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 17f79eb59..e51268823 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -29,9 +29,7 @@ _clear_online_files() {
 aux prepare_devs 3
 get_devs
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
@@ -74,9 +72,7 @@ vgremove -ff $vg
 # copy of the metadata.
 #
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
@@ -125,9 +121,7 @@ vgremove -ff $vg
 # makes the VG usable.
 #
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -182,9 +176,7 @@ vgremove -ff $vg
 # devices.
 #
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -258,9 +250,7 @@ if test -n "$LVM_TEST_LVMLOCKD"; then
 exit 0
 fi
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
@@ -328,4 +318,3 @@ pvs "$dev3"
 
 vgchange -an $vg
 vgremove -ff $vg
-
diff --git a/test/shell/metadata-old.sh b/test/shell/metadata-old.sh
index ad7bf101e..9a0351c23 100644
--- a/test/shell/metadata-old.sh
+++ b/test/shell/metadata-old.sh
@@ -118,9 +118,7 @@ vgremove -ff $vg
 # metadata, and the second mda has current metadata.
 #
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+aux clear_devs "$dev1" "$dev2" "$dev3"
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -181,8 +179,7 @@ vgremove -ff $vg
 # Test when the metadata on two PVs have the same seqno
 # but different checksums.
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+aux clear_devs "$dev1" "$dev2"
 
 pvcreate "$dev1"
 pvcreate "$dev2"
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index bf86c141f..f3063ab39 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -383,8 +383,7 @@ check pv_field "$dev4" dev_size "$SIZE4"
 # Verify that devs being used by an active LV are
 # preferred over duplicates that are not used by an LV.
 
-dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
-dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
+aux clear_devs "$dev3" "$dev4"
 #pvscan --cache
 
 # The previous steps prevent us from nicely cleaning up

