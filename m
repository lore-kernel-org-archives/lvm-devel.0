From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:05 +0000 (GMT)
Subject: master - tests: enable tests for lvmlockd
Message-ID: <20201002202805.E46CD398E4B7@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99b6173f10fe7e2dbd54bb8734667ca8df69905e
Commit:        99b6173f10fe7e2dbd54bb8734667ca8df69905e
Parent:        5e26a2b74d14bebeeba20ec5b082fac752cc7236
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 21:35:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 22:27:00 2020 +0200

tests: enable tests for lvmlockd

---
 test/shell/lvconvert-snapshot.sh | 3 +--
 test/shell/lvconvert-thin.sh     | 5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 9a32776e9..15299dff0 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -12,7 +12,6 @@
 
 # Test various supported conversion of snapshot
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -20,7 +19,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2
 get_devs
 
-vgcreate -s 4k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 4k "$vg" "${DEVICES[@]}"
 
 lvcreate --type snapshot -V50 -L1 -n $lv1 -s $vg
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 1f8d2edb9..131965508 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -32,7 +31,7 @@ aux prepare_pvs 4 64
 get_devs
 
 # build one large PV
-vgcreate $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED $vg1 "$dev1" "$dev2" "$dev3"
 
 # 32bit linux kernels are fragille with device size >= 16T
 # maybe  uname -m    [ x86_64 | i686 ]
@@ -42,7 +41,7 @@ lvcreate --type snapshot -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
-vgcreate $vg -s 64K "$dev4" "$DM_DEV_DIR/$vg1/$lv"
+vgcreate $SHARED -s 64K $vg "$dev4" "$DM_DEV_DIR/$vg1/$lv"
 
 lvcreate -L1T -n $lv1 $vg
 invalid lvconvert --yes -c 8M --type thin --poolmetadatasize 1G $vg/$lv1


