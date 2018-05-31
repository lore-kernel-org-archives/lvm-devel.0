From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:15:25 -0400
Subject: master - tests: enable vg repair tests with lvmlockd
Message-ID: <201805311415.w4VEFPFr031328@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05ee83579be1f7aa1107de438762d039e0424edf
Commit:        05ee83579be1f7aa1107de438762d039e0424edf
Parent:        6cd052333719e4ae23bfaaa03011ed1a2f384f69
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 12:55:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 12:57:46 2018 -0500

tests: enable vg repair tests with lvmlockd

---
 test/shell/inconsistent-metadata.sh               |    4 ++--
 test/shell/lvchange-partial.sh                    |    2 +-
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-mirror.sh             |    2 +-
 test/shell/lvconvert-repair-policy.sh             |    2 +-
 test/shell/lvconvert-repair-raid-dmeventd.sh      |    2 +-
 test/shell/lvconvert-repair-replace.sh            |   12 ++++++------
 test/shell/lvconvert-repair-snapshot.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 test/shell/mda-rollback.sh                        |    4 ++--
 test/shell/unlost-pv.sh                           |    2 +-
 test/shell/vgextend-restoremissing.sh             |    2 +-
 test/shell/vgreduce-removemissing-snapshot.sh     |    2 +-
 test/shell/vgreduce-usage.sh                      |   14 +++++++-------
 15 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 358ffcb..f5ccd13 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -74,7 +74,7 @@ vgremove -f $vg
 pvremove -ff "${DEVICES[@]}"
 pvcreate "${DEVICES[@]}"
 aux backup_dev "$dev2"
-vgcreate $vg "$dev1"
+vgcreate $SHARED $vg "$dev1"
 vgextend $vg "$dev2"
 aux restore_dev "$dev2"
 vgscan $cache
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 60b2b50..7913811 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index b7efda2..9e0dd8c 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-mirror.sh b/test/shell/lvconvert-repair-mirror.sh
index b0c199d..a37dec9 100644
--- a/test/shell/lvconvert-repair-mirror.sh
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 15d4e7c..f9fca00 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index f08b3da..5519c4e 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 4a55969..1fe7965 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
@@ -32,7 +32,7 @@ vgremove -ff $vg
 
 # 3-way, disk log
 # multiple failures, partial replace
-vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 lvcreate -aey --mirrorlog disk --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
@@ -43,7 +43,7 @@ check mirror $vg 3way
 aux enable_dev "$dev1" "$dev2"
 vgremove -ff $vg
 
-vgcreate $vg "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 lvcreate -aey --mirrorlog disk --type mirror -m 1 --ignoremonitoring --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev1"
 lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
@@ -61,7 +61,7 @@ test -e LOCAL_CLVMD && exit 0
 
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but convert should succeed (switch to corelog)
-vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lvcreate -aey --type mirror -m 2 --ignoremonitoring -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
@@ -73,7 +73,7 @@ vgremove -ff $vg
 if aux kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace
-	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 	lvcreate -aey --mirrorlog mirrored --type mirror -m 1 --ignoremonitoring --nosync -L 1 -n 2way $vg \
 	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
 	aux disable_dev "$dev3" "$dev4"
@@ -88,7 +88,7 @@ fi
 
 # 3-way, mirrored log
 # Single log failure, replace
-vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 lvcreate -aey --mirrorlog mirrored --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4"
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 8e66664..0e9b2a3 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 7b2dd3f..6679dd6 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 082f7f2..aa697f9 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index 34080fa..adfc110 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -10,14 +10,14 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
 aux prepare_devs 3
 
-vgcreate --metadatasize 128k $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED --metadatasize 128k $vg1 "$dev1" "$dev2" "$dev3"
 
 vgreduce $vg1 "$dev1"
 dd if="$dev1" of=badmda bs=256K count=1
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index ffc22b8..edf7f31 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 969140a..afbe5ba 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 8ddb3d9..a74ff34 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index e24be36..e6f10f0 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -30,18 +30,18 @@ do
     pvcreate -M$mdatype "$dev1" "$dev2"
 
     # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
-    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2"
     vgreduce $vg1 "$dev1"
     check pv_field "$dev2" vg_name $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
-    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2"
     not vgreduce --all $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv
-    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2"
     not vgreduce $vg1 "$dev1" "$dev2"
     vgremove -f $vg1
 
@@ -55,13 +55,13 @@ pvcreate -M$mdatype "$dev1" "$dev2"
 pvcreate --metadatacopies 0 -M$mdatype "$dev3" "$dev4"
 
 # (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
-vgcreate -M$mdatype $vg1 "$dev1" "$dev3"
+vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev3"
 not vgreduce $vg1 "$dev1"
 vgremove -f $vg1
 
 #COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
-vgcreate -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -aey -n $lv1 --type mirror -m1 -l 4 $vg1
 lvcreate -n $lv2  -l 4 $vg1 "$dev2"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
@@ -79,7 +79,7 @@ not vgs $vg1 # just double-check it's really gone
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -M$mdatype "$vg1" "${DEVICES[@]}"
+vgcreate $SHARED -M$mdatype "$vg1" "${DEVICES[@]}"
 lvcreate -n $lv2 -l 4 $vg1
 lvcreate -aey --type mirror -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"


