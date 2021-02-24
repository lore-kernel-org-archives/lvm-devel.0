From: David Teigland <teigland@sourceware.org>
Date: Wed, 24 Feb 2021 16:32:40 +0000 (GMT)
Subject: main - Revert "tests: enable tests for lvmlockd"
Message-ID: <20210224163240.ABA57387086A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa34da6eccb4dafe0a35129ddfb8ad7fb63fb7d2
Commit:        aa34da6eccb4dafe0a35129ddfb8ad7fb63fb7d2
Parent:        6fad7f2eac84af60d301816dc06ef7276cd6415f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 24 10:30:51 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 24 10:30:51 2021 -0600

Revert "tests: enable tests for lvmlockd"

This reverts commit 99b6173f10fe7e2dbd54bb8734667ca8df69905e.

These tests are disabled with lvmlockd because they use
snapshots without an origin which is not permitted in a
shared vg.
---
 test/shell/lvconvert-snapshot.sh | 3 ++-
 test/shell/lvconvert-thin.sh     | 5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 15299dff0..9a32776e9 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -12,6 +12,7 @@
 
 # Test various supported conversion of snapshot
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -19,7 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2
 get_devs
 
-vgcreate $SHARED -s 4k "$vg" "${DEVICES[@]}"
+vgcreate -s 4k "$vg" "${DEVICES[@]}"
 
 lvcreate --type snapshot -V50 -L1 -n $lv1 -s $vg
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index ee8569164..bfda8e50d 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -31,7 +32,7 @@ aux prepare_pvs 4 64
 get_devs
 
 # build one large PV
-vgcreate $SHARED $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $vg1 "$dev1" "$dev2" "$dev3"
 
 # 32bit linux kernels are fragille with device size >= 16T
 # maybe  uname -m    [ x86_64 | i686 ]
@@ -41,7 +42,7 @@ lvcreate --type snapshot -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
-vgcreate $SHARED -s 64K $vg "$dev4" "$DM_DEV_DIR/$vg1/$lv"
+vgcreate $vg -s 64K "$dev4" "$DM_DEV_DIR/$vg1/$lv"
 
 lvcreate -L1T -n $lv1 $vg
 invalid lvconvert --yes -c 8M --type thin --poolmetadatasize 1G $vg/$lv1


