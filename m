From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 22:58:36 +0000 (UTC)
Subject: master - tests: use skip flags
Message-ID: <20151026225836.D7F7A60BD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46395f22ea6089a508d30e0ef2e85f0e036359da
Commit:        46395f22ea6089a508d30e0ef2e85f0e036359da
Parent:        a2dd1f6e191de8d0ba1292e01338d480958c5a0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 20:09:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 23:57:48 2015 +0100

tests: use skip flags

---
 test/shell/activate-minor.sh           |    3 ++-
 test/shell/activate-missing-segment.sh |    4 ++--
 test/shell/activate-missing.sh         |    4 ++--
 test/shell/activate-partial.sh         |    4 ++--
 test/shell/activation-skip.sh          |    4 ++--
 test/shell/clvmd-restart.sh            |    5 +++--
 test/shell/lvmetad-ambiguous.sh        |    6 +++---
 test/shell/lvmetad-autoshutdown.sh     |    6 +++---
 test/shell/lvmetad-client-filter.sh    |    6 +++---
 test/shell/lvmetad-disabled.sh         |    6 +++---
 test/shell/lvmetad-dump.sh             |    6 +++---
 test/shell/lvmetad-lvm1.sh             |    6 +++---
 test/shell/lvmetad-lvscan-cache.sh     |    6 +++---
 test/shell/lvmetad-no-cluster.sh       |    3 +++
 test/shell/lvmetad-override.sh         |    6 +++---
 test/shell/lvmetad-pvs.sh              |    4 ++--
 test/shell/lvmetad-pvscan-cache.sh     |    6 +++---
 test/shell/lvmetad-pvscan-filter.sh    |    6 +++---
 test/shell/lvmetad-pvscan-md.sh        |    6 +++---
 test/shell/lvmetad-pvscan-nomda-bg.sh  |    6 +++---
 test/shell/lvmetad-pvscan-nomda.sh     |    6 +++---
 test/shell/lvmetad-restart.sh          |    6 +++---
 test/shell/lvmetad-test.sh             |    4 ++--
 test/shell/lvmetad-warning.sh          |    6 +++---
 24 files changed, 65 insertions(+), 60 deletions(-)

diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index d7ae5f9..086a1ca 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -9,12 +9,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # Just skip this test if minor is already in use...
 dmsetup info | tee info
 egrep "^Major, minor: *[0-9]+, 123" info && skip
-test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_vg 2
 lvcreate -a n --zero n -l 1 -n foo $vg
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 988c9cb..05d6a36 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -16,9 +16,9 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index e33a6ef..3078b9d 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -16,9 +16,9 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index 3720e1d..75a66e2 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index 5259d9d..18bb218 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # Test skip activation flag  -k|--setactivationskip
 
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index afe4834..5d8525f 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -13,11 +13,12 @@
 export LVM_CLVMD_BINARY=clvmd
 export LVM_BINARY=lvm
 
+SKIP_WITHOUT_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # only clvmd based test, skip otherwise
-test -e LOCAL_LVMPOLLD && skip
-test -e LOCAL_CLVMD || skip
 read LOCAL_CLVMD < LOCAL_CLVMD
 
 # TODO read from build, for now hardcoded
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 777a63e..1711f71 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
index fdee4a6..425ee33 100644
--- a/test/shell/lvmetad-autoshutdown.sh
+++ b/test/shell/lvmetad-autoshutdown.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 kill -0 $(< LOCAL_LVMETAD) || die "lvmetad is already dead"
 
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
index 5e6d967..4119e64 100644
--- a/test/shell/lvmetad-client-filter.sh
+++ b/test/shell/lvmetad-client-filter.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 9c71717..4f15165 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 kill $(< LOCAL_LVMETAD)
 while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 631636e..c9a7736 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index f234b15..3b14fdd 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2
 pvcreate --metadatatype 1 "$dev1"
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index 220e464..a4a0982 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index 83fee47..0421c59 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -9,6 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITHOUT_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 test -e LOCAL_CLVMD || skip
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 15ada7b..a0a983b 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 81174f4..21b404b 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 1 20000
 pvs $(cat DEVICES) | grep "$dev1"
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 33b4d94..f2a3afa 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index b7bdf33..8ec31ed 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index 9c5e3fa..82831e5 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
index e17dfd2..5cf4602 100644
--- a/test/shell/lvmetad-pvscan-nomda-bg.sh
+++ b/test/shell/lvmetad-pvscan-nomda-bg.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 kill $(< LOCAL_LVMETAD)
 rm LOCAL_LVMETAD
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index f7e13a7..6a78b6c 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 kill $(< LOCAL_LVMETAD)
 rm LOCAL_LVMETAD
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index 8805bc8..18b2b2c 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 146a7f1..7d47979 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 44edb12..4c8cc59 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2
 


