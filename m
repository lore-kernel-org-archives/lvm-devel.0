From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:24 +0000 (GMT)
Subject: dev-next - tests: skip more tests for lvmpolld pass
Message-ID: <20210331214924.B37423858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49575a6ce1940528aaaac5eada8f8938e6cf4a84
Commit:        49575a6ce1940528aaaac5eada8f8938e6cf4a84
Parent:        7768650d87d4086a76f1558aab4436acda1b5e44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:05:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:40 2021 +0100

tests: skip more tests for lvmpolld pass

These test do not test polling, so skip them for lvmpolld pass.
---
 test/api/dbustest.sh                 |  1 +
 test/shell/exported.sh               |  2 ++
 test/shell/lvm-conf-error.sh         |  2 ++
 test/shell/metadata-bad-mdaheader.sh |  2 ++
 test/shell/metadata-bad-text.sh      |  2 ++
 test/shell/metadata-old.sh           |  2 ++
 test/shell/missing-pv-unused.sh      | 13 +++----------
 test/shell/missing-pv.sh             |  9 +++------
 test/shell/outdated-pv.sh            |  8 +++-----
 test/shell/pvck-dump.sh              |  3 +++
 test/shell/pvck-repair.sh            |  4 ++++
 11 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 83e40d056..622022277 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -11,6 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
diff --git a/test/shell/exported.sh b/test/shell/exported.sh
index b6d17ce7d..18a86462f 100644
--- a/test/shell/exported.sh
+++ b/test/shell/exported.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # Check what is and is not permitted on an exported VG/PV
diff --git a/test/shell/lvm-conf-error.sh b/test/shell/lvm-conf-error.sh
index 01461c174..590834bbe 100644
--- a/test/shell/lvm-conf-error.sh
+++ b/test/shell/lvm-conf-error.sh
@@ -12,6 +12,8 @@
 
 # Check what happens when reading of lvm.conf fails
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 MKFS=mkfs.ext3
diff --git a/test/shell/metadata-bad-mdaheader.sh b/test/shell/metadata-bad-mdaheader.sh
index 2096dbba8..ad2bcc496 100644
--- a/test/shell/metadata-bad-mdaheader.sh
+++ b/test/shell/metadata-bad-mdaheader.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 xxd -v || skip
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 971b861ca..9ccfe5f76 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
diff --git a/test/shell/metadata-old.sh b/test/shell/metadata-old.sh
index a193ebf31..ad7bf101e 100644
--- a/test/shell/metadata-old.sh
+++ b/test/shell/metadata-old.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 3
diff --git a/test/shell/missing-pv-unused.sh b/test/shell/missing-pv-unused.sh
index 2265a5bd9..d74365ffc 100644
--- a/test/shell/missing-pv-unused.sh
+++ b/test/shell/missing-pv-unused.sh
@@ -10,12 +10,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-aux prepare_devs 3
-get_devs
+. lib/inittest
 
-vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+aux prepare_vg 3
 
 lvcreate -n $lv1 -L8M $vg "$dev2"
 lvcreate -n $lv2 -L8M $vg "$dev3"
@@ -24,10 +23,6 @@ lvcreate -n $lv4 -L8M $vg "$dev3"
 
 vgchange -an $vg
 
-pvs
-vgs
-lvs -a -o+devices
-
 # Fail device that is not used by any LVs.
 aux disable_dev "$dev1"
 
@@ -81,6 +76,4 @@ pvs
 vgs
 lvs -a -o+devices
 
-vgchange -an $vg
 vgremove -ff $vg
-
diff --git a/test/shell/missing-pv.sh b/test/shell/missing-pv.sh
index 74cc43b0e..3662483b0 100644
--- a/test/shell/missing-pv.sh
+++ b/test/shell/missing-pv.sh
@@ -10,12 +10,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-aux prepare_devs 3
-get_devs
+. lib/inittest
 
-vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+aux prepare_vg 3
 
 lvcreate -n $lv1 -L8M --type mirror -m 1 $vg
 lvcreate -n $lv2 -L8M --type mirror -m 1 $vg
@@ -147,6 +146,4 @@ pvs
 vgs
 lvs -a -o+devices
 
-vgchange -an $vg
 vgremove -ff $vg
-
diff --git a/test/shell/outdated-pv.sh b/test/shell/outdated-pv.sh
index 5c9b1b2f3..6a361d3ce 100644
--- a/test/shell/outdated-pv.sh
+++ b/test/shell/outdated-pv.sh
@@ -10,10 +10,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
-aux prepare_devs 3
-get_devs
+aux prepare_vg 3
 
 #
 # Test handling of "outdated PV" which occurs when a PV goes missing
@@ -22,8 +23,6 @@ get_devs
 # member.  That outdated metadata needs to be cleared.
 #
 
-vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
-
 lvcreate -n $lv1 -l1 -an $vg "$dev1"
 lvcreate -n $lv2 -l1 -an $vg "$dev1"
 
@@ -63,4 +62,3 @@ pvs "$dev2" | tee out
 grep "$vg" out
 
 vgremove -ff $vg
-
diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index c27fcc471..81e164d73 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -10,6 +10,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 SIZE_MB=80
diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
index d48e25198..0a794da68 100644
--- a/test/shell/pvck-repair.sh
+++ b/test/shell/pvck-repair.sh
@@ -10,6 +10,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+
 . lib/inittest
 
 SIZE=34


