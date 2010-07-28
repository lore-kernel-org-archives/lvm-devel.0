From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:52 +0200
Subject: [PATCH 06/14] Testsuit: add missing prepare_dmeventd
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <11d017fb5e4805eb542bf539e13cd65c2f092931.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All these tests may start dmeventd, so use prepare_dmeventd function
to keep dmeventd local for the test.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-activate-missing.sh              |    1 +
 test/t-activate-partial.sh              |    1 +
 test/t-inconsistent-metadata.sh         |    1 +
 test/t-listings.sh                      |    1 +
 test/t-lvchange-mirror.sh               |    1 +
 test/t-lvconvert-mirror-basic.sh        |    1 +
 test/t-lvconvert-mirror.sh              |    1 +
 test/t-lvconvert-repair-dmeventd.sh     |    2 +-
 test/t-lvconvert-repair-policy.sh       |    1 +
 test/t-lvconvert-repair-replace.sh      |    1 +
 test/t-lvconvert-repair-transient.sh    |    1 +
 test/t-lvconvert-repair.sh              |    2 +-
 test/t-lvcreate-mirror.sh               |    1 +
 test/t-lvcreate-operation.sh            |    1 +
 test/t-lvcreate-pvtags.sh               |    1 +
 test/t-lvcreate-usage.sh                |    1 +
 test/t-lvresize-mirror.sh               |    1 +
 test/t-metadata.sh                      |    1 +
 test/t-mirror-names.sh                  |    1 +
 test/t-mirror-vgreduce-removemissing.sh |    1 +
 test/t-nomda-missing.sh                 |    1 +
 test/t-snapshots-of-mirrors.sh          |    1 +
 test/t-unknown-segment.sh               |    1 +
 test/t-unlost-pv.sh                     |    1 +
 24 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/test/t-activate-missing.sh b/test/t-activate-missing.sh
index 86fb09c..761a88f 100644
--- a/test/t-activate-missing.sh
+++ b/test/t-activate-missing.sh
@@ -8,6 +8,7 @@
 # - linear LVs with bits missing are not activated
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 4
 
diff --git a/test/t-activate-partial.sh b/test/t-activate-partial.sh
index 15f5965..1a18661 100644
--- a/test/t-activate-partial.sh
+++ b/test/t-activate-partial.sh
@@ -1,4 +1,5 @@
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_vg 3
 
diff --git a/test/t-inconsistent-metadata.sh b/test/t-inconsistent-metadata.sh
index 310dde5..75664e6 100644
--- a/test/t-inconsistent-metadata.sh
+++ b/test/t-inconsistent-metadata.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_vg 3
 
diff --git a/test/t-listings.sh b/test/t-listings.sh
index 9ea10b6..f069d15 100644
--- a/test/t-listings.sh
+++ b/test/t-listings.sh
@@ -13,6 +13,7 @@
 #
 
 . ./test-utils.sh
+prepare_dmeventd
 
 get_lvs_()
 {
diff --git a/test/t-lvchange-mirror.sh b/test/t-lvchange-mirror.sh
index 7c915be..bc5841f 100644
--- a/test/t-lvchange-mirror.sh
+++ b/test/t-lvchange-mirror.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 aux prepare_vg 3
 
 # force resync 2-way active mirror
diff --git a/test/t-lvconvert-mirror-basic.sh b/test/t-lvconvert-mirror-basic.sh
index 665f34f..77ff1de 100644
--- a/test/t-lvconvert-mirror-basic.sh
+++ b/test/t-lvconvert-mirror-basic.sh
@@ -1,4 +1,5 @@
 . ./test-utils.sh
+prepare_dmeventd
 
 log_name_to_count()
 {
diff --git a/test/t-lvconvert-mirror.sh b/test/t-lvconvert-mirror.sh
index 3a58f35..20ec4be 100644
--- a/test/t-lvconvert-mirror.sh
+++ b/test/t-lvconvert-mirror.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 # convert from linear to 2-way mirror
 aux prepare_vg 5
diff --git a/test/t-lvconvert-repair-dmeventd.sh b/test/t-lvconvert-repair-dmeventd.sh
index 27744bf..ea6cef3 100644
--- a/test/t-lvconvert-repair-dmeventd.sh
+++ b/test/t-lvconvert-repair-dmeventd.sh
@@ -10,9 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 5
-prepare_dmeventd
 
 which mkfs.ext2 || exit 200
 
diff --git a/test/t-lvconvert-repair-policy.sh b/test/t-lvconvert-repair-policy.sh
index 1f31215..89c096f 100644
--- a/test/t-lvconvert-repair-policy.sh
+++ b/test/t-lvconvert-repair-policy.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 4
 
diff --git a/test/t-lvconvert-repair-replace.sh b/test/t-lvconvert-repair-replace.sh
index 7315a0e..ec380ba 100644
--- a/test/t-lvconvert-repair-replace.sh
+++ b/test/t-lvconvert-repair-replace.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 6
 
diff --git a/test/t-lvconvert-repair-transient.sh b/test/t-lvconvert-repair-transient.sh
index b4e1a06..2b21314 100644
--- a/test/t-lvconvert-repair-transient.sh
+++ b/test/t-lvconvert-repair-transient.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 5
 
diff --git a/test/t-lvconvert-repair.sh b/test/t-lvconvert-repair.sh
index bce8b53..80fd053 100644
--- a/test/t-lvconvert-repair.sh
+++ b/test/t-lvconvert-repair.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
-
+prepare_dmeventd
 
 # fail multiple devices
 
diff --git a/test/t-lvcreate-mirror.sh b/test/t-lvcreate-mirror.sh
index ae3fceb..706674c 100644
--- a/test/t-lvcreate-mirror.sh
+++ b/test/t-lvcreate-mirror.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 aux prepare_vg 5 80
 
 # 2-way mirror with corelog, 2 PVs
diff --git a/test/t-lvcreate-operation.sh b/test/t-lvcreate-operation.sh
index 8a31759..67f245b 100644
--- a/test/t-lvcreate-operation.sh
+++ b/test/t-lvcreate-operation.sh
@@ -12,6 +12,7 @@
 # 'Exercise some lvcreate diagnostics'
 
 . ./test-utils.sh
+prepare_dmeventd
 
 cleanup_lvs() {
 	lvremove -ff $vg
diff --git a/test/t-lvcreate-pvtags.sh b/test/t-lvcreate-pvtags.sh
index b9a4380..a066069 100755
--- a/test/t-lvcreate-pvtags.sh
+++ b/test/t-lvcreate-pvtags.sh
@@ -9,6 +9,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_pvs 3
 # not required, just testing
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 0bb06ab..7fe89dc 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -12,6 +12,7 @@
 # 'Exercise some lvcreate diagnostics'
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 $dev1
diff --git a/test/t-lvresize-mirror.sh b/test/t-lvresize-mirror.sh
index 0d63102..758b9b2 100644
--- a/test/t-lvresize-mirror.sh
+++ b/test/t-lvresize-mirror.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 aux prepare_vg 5 80
 
 # extend 2-way mirror
diff --git a/test/t-metadata.sh b/test/t-metadata.sh
index 6f0268e..5a8648e 100755
--- a/test/t-metadata.sh
+++ b/test/t-metadata.sh
@@ -9,6 +9,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_devs 5
 
diff --git a/test/t-mirror-names.sh b/test/t-mirror-names.sh
index 1363d84..930d5e2 100644
--- a/test/t-mirror-names.sh
+++ b/test/t-mirror-names.sh
@@ -13,6 +13,7 @@
 test_description="check namings of mirrored LV"
 
 . ./test-utils.sh
+prepare_dmeventd
 
 # ---------------------------------------------------------------------
 # Utilities
diff --git a/test/t-mirror-vgreduce-removemissing.sh b/test/t-mirror-vgreduce-removemissing.sh
index 0f6a8b0..9e7f3de 100755
--- a/test/t-mirror-vgreduce-removemissing.sh
+++ b/test/t-mirror-vgreduce-removemissing.sh
@@ -12,6 +12,7 @@
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
 . ./test-utils.sh
+prepare_dmeventd
 
 lv_is_on_ ()
 {
diff --git a/test/t-nomda-missing.sh b/test/t-nomda-missing.sh
index fa4ca49..9aaed13 100644
--- a/test/t-nomda-missing.sh
+++ b/test/t-nomda-missing.sh
@@ -1,6 +1,7 @@
 #!/bin/bash
 
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_devs 4
 pvcreate $dev1 $dev2
diff --git a/test/t-snapshots-of-mirrors.sh b/test/t-snapshots-of-mirrors.sh
index 7ee8249..4e01bf2 100644
--- a/test/t-snapshots-of-mirrors.sh
+++ b/test/t-snapshots-of-mirrors.sh
@@ -1,4 +1,5 @@
 . ./test-utils.sh
+prepare_dmeventd
 
 prepare_vg 4
 
diff --git a/test/t-unknown-segment.sh b/test/t-unknown-segment.sh
index 74a2710..4707ade 100644
--- a/test/t-unknown-segment.sh
+++ b/test/t-unknown-segment.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_vg 4
 
diff --git a/test/t-unlost-pv.sh b/test/t-unlost-pv.sh
index 7a120fb..6a894ca 100644
--- a/test/t-unlost-pv.sh
+++ b/test/t-unlost-pv.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
+prepare_dmeventd
 
 aux prepare_vg 3
 
-- 
1.7.2


