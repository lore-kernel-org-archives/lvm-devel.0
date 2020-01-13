From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:43:36 -0500
Subject: master - tests: update for readahead
Message-ID: <79798.120011311433201949@us-mta-432.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30f4d0fcd497338be5eb994a9b5b1ccee993f62c
Commit:        30f4d0fcd497338be5eb994a9b5b1ccee993f62c
Parent:        5ccf3e6f30479331b9b47e0165ed191fbaa38f44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 12 15:54:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:42:31 2020 +0100

tests: update for readahead

---
 test/shell/lvcreate-usage.sh | 14 +++++++-------
 test/shell/read-ahead.sh     |  9 ++++-----
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index b1cd515..6d46939 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -180,16 +180,16 @@ check lv_field $vg/$lv4 lv_read_ahead "auto"
 # figure RA value of a PV origin device
 DEVICE=$(dmsetup deps -o blkdevname "$dev1" | sed -e "s,.*:\ (\(.*\)),/dev/\1,")
 RASZ=$(( $(blockdev --getra "$DEVICE" ) / 2 ))
-SZ="$RASZ.00k"
-test "$RASZ" -ge 128 || SZ="128.00k"
-check lv_field $vg/$lv4 lv_kernel_read_ahead "$SZ" --units k
-lvcreate -L 8 -n $lv5 -i2 --stripesize 16k --readahead auto $vg
+test "$RASZ" -ge 128 || RASZ="128"
+check lv_field $vg/$lv4 lv_kernel_read_ahead "${RASZ}.00k" --units k
+lvcreate -vvvvv -L 8 -n $lv5 -i2 --stripesize 16k --readahead auto $vg
 check lv_field $vg/$lv5 lv_read_ahead "auto"
-check lv_field $vg/$lv5 lv_kernel_read_ahead "$SZ" --units k
+# For 16k stripe we set '128k' as the is the minimum size we get when creating DM device
+check lv_field $vg/$lv5 lv_kernel_read_ahead "128.00k" --units k
 lvcreate -L 8 -n $lv6 -i2 --stripesize 128k --readahead auto $vg
 check lv_field $vg/$lv6 lv_read_ahead "auto"
-test "$RASZ" -ge 512 || SZ="512.00k"
-check lv_field $vg/$lv6 lv_kernel_read_ahead "$SZ" --units k
+# For striped device we set double of strip size unrelated to underlaying dev RA size
+check lv_field $vg/$lv6 lv_kernel_read_ahead "512.00k" --units k
 lvremove -ff $vg
 
 #
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 53cc572..2f061fa 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -35,12 +35,11 @@ lvremove -ff $vg
 #COMM "read ahead is properly inherited from underlying PV"
 blockdev --setra 768 "$dev1"
 vgscan
-DEVICE=$(dmsetup deps -o blkdevname "$dev1" | sed -e "s,.*:\ (\(.*\)),/dev/\1,")
-RASZ=$(blockdev --getra "$DEVICE")
-SZ=$RASZ
-test "$RASZ" -ge 768 || SZ=768
+# is there something in the system changing readahead settings behind the scene...
+RASZ=$(blockdev --getra "$dev1")
+test "$RASZ" -ge 768 || RASZ=768
 lvcreate -n $lv -L4m $vg "$dev1"
-test "$(blockdev --getra "$DM_DEV_DIR/$vg/$lv")" -eq "$SZ"
+test "$(blockdev --getra "$DM_DEV_DIR/$vg/$lv")" -eq "$RASZ"
 lvremove -ff $vg
 
 # Check default, active/inactive values for read_ahead / kernel_read_ahead



