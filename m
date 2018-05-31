From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 17:22:29 -0400
Subject: master - tests: enable more working tests with lvmlockd
Message-ID: <201805312122.w4VLMTTo001290@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00f6a8466edfc386067efb1e000a808080966076
Commit:        00f6a8466edfc386067efb1e000a808080966076
Parent:        06b2e5c176b7a371efa62b27af2acb1e6f7984be
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 15:55:18 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 16:13:58 2018 -0500

tests: enable more working tests with lvmlockd

---
 test/shell/lvconvert-repair-cache.sh     |    1 -
 test/shell/lvconvert-repair.sh           |    8 +++++---
 test/shell/lvcreate-repair.sh            |    5 ++---
 test/shell/lvextend-snapshot-dmeventd.sh |    1 -
 test/shell/mdata-strings.sh              |    3 +--
 5 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 6afb7ea..348dbaf 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -12,7 +12,6 @@
 
 # Test repairing of broken cached LV
 
-SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index b5ae206..9ee7980 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -10,14 +10,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
-
 . lib/inittest
 
 recreate_vg_()
 {
 	vgremove -ff $vg
-	vgcreate "$vg" "$@" "${DEVICES[@]}"
+	vgcreate $SHARED "$vg" "$@" "${DEVICES[@]}"
 }
 
 _check_mlog()
@@ -70,7 +68,11 @@ vgreduce --removemissing $vg
 aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
+if test -n "$LVM_TEST_LVMLOCKD"; then
+recreate_vg_
+else
 recreate_vg_ -c n
+fi
 lvcreate -aey --type mirror -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4" "$dev5"
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 5e02e7f..cff0018 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -23,7 +22,7 @@ for i in "$dev1" "$dev2" "$dev3" ; do
 		if test "$i" = "$j" ; then continue ; fi
 
 		vgremove -ff $vg
-		vgcreate $vg "$dev1" "$dev2" "$dev3"
+		vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 		# exit 1
 
 		lvcreate -l1 -n $lv1 $vg "$dev1"
@@ -49,7 +48,7 @@ for i in "$dev1" "$dev2" "$dev3" ; do
 done
 
 vgremove -ff $vg
-vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
 # use tricky 'dd'
 for i in "$dev1" "$dev2" "$dev3" ; do
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 0f9b0a9..01fc843 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 4fcb89c..c87cd75 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -12,7 +12,6 @@
 
 # 'Test for proper escaping of strings in metadata (bz431474)'
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -42,7 +41,7 @@ pvcreate "$dev1" || created="$dev2"
 pvdisplay 2>&1 | tee err
 should grep -F "$pv_ugly" err
 should check pv_field "$dev1" pv_name "$dev1"
-vgcreate $vg "$created"
+vgcreate $SHARED $vg "$created"
 # 'no parse errors and VG really exists'
 vgs $vg 2>err
 not grep "Parse error" err


