From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Oct 2015 15:03:59 +0000 (UTC)
Subject: master - tests: use more SKIP
Message-ID: <20151027150359.C389860C54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4159680a0ee7eceb4d5124c1e4e78b418b12f357
Commit:        4159680a0ee7eceb4d5124c1e4e78b418b12f357
Parent:        76cff10a734a7c1e26b3835ff967dac0b7e46bcb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 27 15:10:06 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 27 16:00:09 2015 +0100

tests: use more SKIP

Speed-up check_lvmpolld.
---
 test/api/lvtest.sh                                |    2 ++
 test/api/pe_start.sh                              |    2 ++
 test/api/percent.sh                               |    2 ++
 test/api/pytest.sh                                |   10 +++++-----
 test/api/thin_percent.sh                          |    2 ++
 test/api/vglist.sh                                |    2 ++
 test/shell/000-basic.sh                           |    4 ++--
 test/shell/covercmd.sh                            |    4 ++--
 test/shell/discards-thin.sh                       |    4 ++--
 test/shell/dmeventd-restart.sh                    |    4 ++--
 test/shell/dumpconfig.sh                          |    4 ++--
 test/shell/error-usage.sh                         |    4 ++--
 test/shell/fsadm.sh                               |    3 +--
 test/shell/inconsistent-metadata.sh               |    4 ++--
 test/shell/listings.sh                            |    4 ++--
 test/shell/lock-blocking.sh                       |    5 ++---
 test/shell/lock-parallel.sh                       |    4 ++--
 test/shell/lvchange-cache.sh                      |    4 ++--
 test/shell/lvchange-mirror.sh                     |    9 ++++-----
 test/shell/lvchange-partial-raid10.sh             |    4 ++--
 test/shell/lvchange-partial.sh                    |    4 ++--
 test/shell/lvchange-raid.sh                       |    2 ++
 test/shell/lvchange-raid10.sh                     |    2 --
 test/shell/lvchange-raid456.sh                    |    2 --
 test/shell/lvchange-syncaction-raid.sh            |    4 ++--
 test/shell/lvchange-thin.sh                       |    4 ++--
 test/shell/lvconvert-cache-raid.sh                |    4 ++--
 test/shell/lvconvert-cache-smq.sh                 |    4 ++--
 test/shell/lvconvert-cache-thin.sh                |    4 ++--
 test/shell/lvconvert-cache.sh                     |    4 ++--
 test/shell/lvconvert-raid-allocation.sh           |    4 ++--
 test/shell/lvconvert-raid.sh                      |    5 +++--
 test/shell/lvconvert-raid10.sh                    |    4 ++--
 test/shell/lvconvert-raid456.sh                   |    4 ++--
 test/shell/lvconvert-repair-dmeventd.sh           |    4 ++--
 test/shell/lvconvert-repair-raid-dmeventd.sh      |    4 ++--
 test/shell/lvconvert-repair-raid.sh               |    4 ++--
 test/shell/lvconvert-repair-snapshot.sh           |    4 ++--
 test/shell/lvconvert-repair-thin-raid.sh          |    3 ++-
 test/shell/lvconvert-repair-thin.sh               |    4 ++--
 test/shell/lvconvert-repair-transient-dmeventd.sh |    4 ++--
 test/shell/lvconvert-repair-transient.sh          |    4 ++--
 test/shell/lvconvert-snapshot.sh                  |    4 ++--
 test/shell/lvconvert-thin-external.sh             |    4 ++--
 test/shell/lvconvert-thin-raid.sh                 |    4 ++--
 test/shell/lvconvert-thin.sh                      |    4 ++--
 test/shell/lvcreate-cache-raid.sh                 |    4 ++--
 test/shell/lvcreate-cache.sh                      |    4 ++--
 test/shell/lvcreate-large-raid.sh                 |    4 ++--
 test/shell/lvcreate-large-raid10.sh               |    5 ++---
 test/shell/lvcreate-large.sh                      |    4 ++--
 test/shell/lvcreate-mirror.sh                     |    4 ++--
 test/shell/lvcreate-missing.sh                    |    4 ++--
 test/shell/lvcreate-operation.sh                  |    4 ++--
 test/shell/lvcreate-pvtags.sh                     |    4 ++--
 test/shell/lvcreate-raid.sh                       |    4 ++--
 test/shell/lvcreate-raid10.sh                     |    4 ++--
 test/shell/lvcreate-repair.sh                     |    4 ++--
 test/shell/lvcreate-signature-wiping.sh           |    4 ++--
 test/shell/lvcreate-small-snap.sh                 |    4 ++--
 test/shell/lvcreate-striped-mirror.sh             |    4 ++--
 test/shell/lvcreate-thin-big.sh                   |    4 ++--
 test/shell/lvcreate-thin-external-size.sh         |    4 ++--
 test/shell/lvcreate-thin-external.sh              |    4 ++--
 test/shell/lvcreate-thin-power2.sh                |    4 ++--
 test/shell/lvcreate-thin-snap.sh                  |    4 ++--
 test/shell/lvcreate-thin.sh                       |    4 ++--
 test/shell/lvextend-percent-extents.sh            |    4 ++--
 test/shell/lvextend-snapshot-dmeventd.sh          |    4 ++--
 test/shell/lvextend-snapshot-policy.sh            |    4 ++--
 test/shell/lvextend-thin-full.sh                  |    4 ++--
 test/shell/lvextend-thin-metadata-dmeventd.sh     |    4 ++--
 test/shell/lvextend-thin.sh                       |    4 ++--
 test/shell/lvm-init.sh                            |    4 ++--
 test/shell/lvmcache-exercise.sh                   |    4 ++--
 test/shell/lvmetad-no-cluster.sh                  |    3 ---
 test/shell/lvresize-mirror.sh                     |    4 ++--
 test/shell/lvresize-raid.sh                       |    4 ++--
 test/shell/lvresize-raid10.sh                     |    4 ++--
 test/shell/lvresize-rounding.sh                   |    4 ++--
 test/shell/lvresize-thin-external-origin.sh       |    4 ++--
 test/shell/lvresize-thin-metadata.sh              |    4 ++--
 test/shell/lvresize-usage.sh                      |    4 ++--
 test/shell/lvs-cache.sh                           |    4 ++--
 test/shell/mda-rollback.sh                        |    4 ++--
 test/shell/mdata-strings.sh                       |    4 ++--
 test/shell/metadata-balance.sh                    |    4 ++--
 test/shell/metadata-dirs.sh                       |    4 ++--
 test/shell/metadata.sh                            |    4 ++--
 test/shell/mirror-vgreduce-removemissing.sh       |    3 +--
 test/shell/name-mangling.sh                       |   10 +++++-----
 test/shell/nomda-missing.sh                       |    4 ++--
 test/shell/nomda-restoremissing.sh                |    4 ++--
 test/shell/orphan-ondisk.sh                       |    4 ++--
 test/shell/pool-labels.sh                         |    8 ++++----
 test/shell/process-each-duplicate-vgnames.sh      |    3 +--
 test/shell/process-each-lv.sh                     |    1 +
 test/shell/process-each-pv-nomda-all.sh           |    1 +
 test/shell/process-each-pv-nomda.sh               |    1 +
 test/shell/process-each-pv.sh                     |    1 +
 test/shell/process-each-pvresize.sh               |    3 +--
 test/shell/profiles-thin.sh                       |    4 ++--
 test/shell/profiles.sh                            |    4 ++--
 test/shell/pv-duplicate-uuid.sh                   |    4 ++--
 test/shell/pv-duplicate.sh                        |    4 ++--
 test/shell/pv-min-size.sh                         |    4 ++--
 test/shell/pvchange-usage.sh                      |    4 ++--
 test/shell/pvcreate-bootloaderarea.sh             |    3 +--
 test/shell/pvcreate-ff.sh                         |    4 ++--
 test/shell/pvcreate-metadata0.sh                  |    4 ++--
 test/shell/pvcreate-operation-md.sh               |    4 ++--
 test/shell/pvcreate-operation.sh                  |    4 ++--
 test/shell/pvcreate-usage.sh                      |    3 +--
 test/shell/pvmove-cache-segtypes.sh               |    2 +-
 test/shell/pvmove-raid-segtypes.sh                |    2 +-
 test/shell/pvmove-resume-1.sh                     |    4 ++--
 test/shell/pvmove-resume-2.sh                     |    4 ++--
 test/shell/pvmove-resume-multiseg.sh              |    4 ++--
 test/shell/pvmove-thin-segtypes.sh                |    3 ++-
 test/shell/pvremove-thin.sh                       |    4 ++--
 test/shell/pvremove-usage.sh                      |    4 ++--
 test/shell/pvremove-warnings.sh                   |    4 ++--
 test/shell/read-ahead.sh                          |    3 +--
 test/shell/select-report.sh                       |    4 ++--
 test/shell/select-tools-thin.sh                   |    4 ++--
 test/shell/select-tools.sh                        |    4 ++--
 test/shell/snapshot-autoumount-dmeventd.sh        |    4 ++--
 test/shell/snapshot-cluster.sh                    |    4 ++--
 test/shell/snapshot-lvm1.sh                       |    4 ++--
 test/shell/snapshot-maxsize.sh                    |    4 ++--
 test/shell/snapshot-reactivate.sh                 |    5 +++--
 test/shell/snapshot-remove-dmsetup.sh             |    8 ++++----
 test/shell/snapshot-rename.sh                     |    4 ++--
 test/shell/snapshot-usage-exa.sh                  |    4 ++--
 test/shell/snapshot-usage.sh                      |    4 ++--
 test/shell/stray-device-node.sh                   |    4 ++--
 test/shell/system_id.sh                           |    3 +--
 test/shell/tags.sh                                |    4 ++--
 test/shell/test-partition.sh                      |    4 ++--
 test/shell/thin-autoumount-dmeventd.sh            |    4 ++--
 test/shell/thin-defaults.sh                       |    4 ++--
 test/shell/thin-restore.sh                        |    4 ++--
 test/shell/thin-volume-list.sh                    |    4 ++--
 test/shell/topology-support.sh                    |    4 ++--
 test/shell/unknown-segment.sh                     |    4 ++--
 test/shell/unlost-pv.sh                           |    4 ++--
 test/shell/vg-name-from-env.sh                    |    3 +--
 test/shell/vgcfgbackup-usage.sh                   |    4 ++--
 test/shell/vgchange-many.sh                       |    4 ++--
 test/shell/vgchange-maxlv.sh                      |    4 ++--
 test/shell/vgchange-partial.sh                    |    4 ++--
 test/shell/vgchange-sysinit.sh                    |    6 +++---
 test/shell/vgchange-usage.sh                      |    3 +--
 test/shell/vgck.sh                                |    4 ++--
 test/shell/vgcreate-many-pvs.sh                   |    4 ++--
 test/shell/vgcreate-usage.sh                      |    3 +--
 test/shell/vgextend-restoremissing.sh             |    4 ++--
 test/shell/vgextend-usage.sh                      |    4 ++--
 test/shell/vgimportclone.sh                       |    4 ++--
 test/shell/vgmerge-operation.sh                   |    3 +--
 test/shell/vgmerge-usage.sh                       |    3 +--
 test/shell/vgreduce-removemissing-snapshot.sh     |    7 ++++---
 test/shell/vgreduce-usage.sh                      |    4 ++--
 test/shell/vgremove-corrupt-vg.sh                 |    4 ++--
 test/shell/vgrename-usage.sh                      |    4 ++--
 test/shell/vgsplit-operation.sh                   |    4 ++--
 test/shell/vgsplit-raid.sh                        |    3 +--
 test/shell/vgsplit-stacked.sh                     |    4 ++--
 test/shell/vgsplit-thin.sh                        |    4 ++--
 test/shell/vgsplit-usage.sh                       |    4 ++--
 test/shell/zero-usage.sh                          |    4 ++--
 171 files changed, 333 insertions(+), 336 deletions(-)

diff --git a/test/api/lvtest.sh b/test/api/lvtest.sh
index 5fe6f57..aacceba 100644
--- a/test/api/lvtest.sh
+++ b/test/api/lvtest.sh
@@ -11,6 +11,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_vg 1
diff --git a/test/api/pe_start.sh b/test/api/pe_start.sh
index 2fc118f..6a47ced 100644
--- a/test/api/pe_start.sh
+++ b/test/api/pe_start.sh
@@ -11,6 +11,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 2
diff --git a/test/api/percent.sh b/test/api/percent.sh
index a9b7b90..d574080 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -11,6 +11,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux kernel_at_least 2 6 33 || skip
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 3b7c5b6..7ede416 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -11,8 +11,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_CLVMD=1
+
 . lib/inittest
 
+aux prepare_dmeventd
+
 #
 # TODO:
 # lvm2app is not yet capable to respect many lvm.conf options
@@ -29,11 +34,6 @@ python_lib=$(find $abs_top_builddir -name lvm.so)
 # Unable to test python bindings if library not available
 test -n "$python_lib" || skip
 
-test -e LOCAL_CLVMD && skip
-test -e LOCAL_LVMETAD && skip
-
-aux prepare_dmeventd
-
 #If you change this change the unit test case too.
 aux prepare_pvs 6
 
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index fd64e3b..cd95e4f 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -11,6 +11,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/api/vglist.sh b/test/api/vglist.sh
index 421705b..66cf7bf 100644
--- a/test/api/vglist.sh
+++ b/test/api/vglist.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_vg 2
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 582c5ef..89b2178 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 lvm version
 
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 5e47bd9..db84524 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -14,9 +14,9 @@
 # to improve code coverage
 #
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 5
 get_devs
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index fbd0d87..95a5880 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -13,12 +13,12 @@
 # test support of thin discards
 #
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index a64509e..c9f4dc0 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_dmeventd
 
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index 0d33761..312854e 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 flatten() {
 	cat > flatten.config
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index f617b61..ba9afe8 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -11,9 +11,9 @@
 
 # Basic usage of zero target
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which md5sum || skip
 
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 12f1593..f539981 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise fsadm filesystem resize'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_vg 1 100
 
 # set to "skip" to avoid testing given fs and test warning result
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index a606330..6fc09ee 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3 12
 
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index d018510..3f1f302 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -13,9 +13,9 @@
 # tests functionality of lvs, pvs, vgs, *display tools
 #
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 5
 get_devs
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 5c004c9..35bf793 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -10,12 +10,11 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='test some blocking / non-blocking multi-vg operations'
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-test -e LOCAL_CLVMD && skip
-
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 vgcreate $vg "$dev1" "$dev2"
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index ebe6336..b931e4f 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -12,9 +12,9 @@
 # Test parallel use of lvm commands and check locks aren't dropped
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1049296
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext3 || skip
 which fsck || skip
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 3efd762..4a5c8af 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 aux prepare_vg 3
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index bd4c868..a828251 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -9,13 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
-
-test -e LOCAL_LVMPOLLD && skip
-
 # FIXME RESYNC doesn't work in cluster with exclusive activation
 # seriously broken!
-test -e LOCAL_CLVMD && skip
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
 
 aux prepare_dmeventd
 aux prepare_vg 3
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index d83d193..0a20a01 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_raid 1 3 2 || skip
 
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 7b1f68d..6ce46eb 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 4ce776f..c572836 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # Writemostly has been in every version since the begining
diff --git a/test/shell/lvchange-raid10.sh b/test/shell/lvchange-raid10.sh
index 574ac7d..0d17928 100644
--- a/test/shell/lvchange-raid10.sh
+++ b/test/shell/lvchange-raid10.sh
@@ -13,8 +13,6 @@ TEST_RAID=raid10
 
 . shell/lvchange-raid.sh
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_raid 1 5 2 || skip
 
 run_types raid10 -m 1 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index bdce2e6..b1dd1db 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -13,8 +13,6 @@ TEST_RAID=raid456
 
 . shell/lvchange-raid.sh
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux raid456_replace_works || skip
 aux have_raid 1 5 2 || skip
 
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 558157b..704c5d8 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -11,9 +11,9 @@
 
 # test activation race for raid's --syncaction check
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6
 aux have_raid 1 3 5 &&
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index b66c5ee..cad4873 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -9,12 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 3
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 284ffbe..b0d8da2 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -11,9 +11,9 @@
 
 # Exercise usage of stacked cache volume using raid volume
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 aux have_raid 1 0 0 || skip
diff --git a/test/shell/lvconvert-cache-smq.sh b/test/shell/lvconvert-cache-smq.sh
index cdc7838..75f447f 100644
--- a/test/shell/lvconvert-cache-smq.sh
+++ b/test/shell/lvconvert-cache-smq.sh
@@ -11,9 +11,9 @@
 
 # Exercise conversion of cache and cache pool
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 8 0 || skip
 
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 12b8dfe..ace4eb5 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -11,9 +11,9 @@
 
 # Exercise usage of stacked cache volume used in thin pool volumes
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 aux have_thin 1 0 0 || skip
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 3c94ee3..5a38d9c 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -11,9 +11,9 @@
 
 # Exercise conversion of cache and cache pool
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index f118d9c..01a71cb 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6529ee2..0b56fc3 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -10,12 +10,13 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # disable lvmetad logging as it bogs down test systems
+
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 get_image_pvs() {
 	local d
 	local images
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index 244a79e..aa8ceb1 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 0fb5a5b..8f2518c 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 2acf461..308ea4b 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext2 || skip
 aux mirror_recovery_works || skip
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index a5a7a53..be61618 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext3 || skip
 aux have_raid 1 3 0 || skip
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 580516e..f1460ab 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 73f2f88..67b58a9 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0' \
diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
index 04bc5c7..0eb80fa 100644
--- a/test/shell/lvconvert-repair-thin-raid.sh
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -12,9 +12,10 @@
 
 # Test repairing of broken thin pool on raid
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
 aux have_thin 1 0 0 || skip
 aux have_raid 1 4 0 || skip
 
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index c699e12..90f1480 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -12,9 +12,9 @@
 
 # Test repairing of broken thin pool metadata
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 30fd47c..17778fb 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_dmeventd
 aux mirror_recovery_works || skip
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 52e1825..ec17f92 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux mirror_recovery_works || skip
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index ad500e2..b4cb443 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -12,9 +12,9 @@
 
 # Test various supported conversion of snapshot
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 1
 
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 479d23c..4382f1a 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -12,12 +12,12 @@
 
 # Test conversion to thin external origin
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 which mkfs.ext2 || skip
 which fsck || skip
 
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index bd554b2..e9a5917 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -10,12 +10,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 aux have_raid 1 4 0 || skip
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index b4b3a72..12d4331 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,12 +10,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 prepare_lvs() {
 	lvremove -f $vg
 	lvcreate -L10M -n $lv1 $vg
diff --git a/test/shell/lvcreate-cache-raid.sh b/test/shell/lvcreate-cache-raid.sh
index 1c3c327..6e8b3cc 100644
--- a/test/shell/lvcreate-cache-raid.sh
+++ b/test/shell/lvcreate-cache-raid.sh
@@ -11,9 +11,9 @@
 
 # Exercise creation of cache and raids
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 aux have_raid 1 0 0 || skip
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index fce88f3..b3e9d00 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -14,9 +14,9 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index c59eded..46f76b9 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -11,9 +11,9 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 47dda2b..2bc1581 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -11,13 +11,12 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
-
 aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index e547fcc..f51c9b6 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -11,9 +11,9 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index 275c036..5739999 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 5 80
 aux lvmconf 'allocation/maximise_cling = 0' \
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index 012962f..baef6ff 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 3947bf8..bec8502 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -11,9 +11,9 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 cleanup_lvs() {
 	lvremove -ff $vg
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 99a7f07..2a60f69 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 3
 aux lvmconf 'allocation/maximise_cling = 0' \
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index f5e25c6..35cd867 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 884653b..0c8ae38 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 469bf39..4bcf782 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA	02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index d2d23c5..e4bfdb0 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -11,9 +11,9 @@
 
 # 'Exercise signature wiping during lvcreate'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 init_lv_() {
 	mkswap "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index b5610c7..e3f5189 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs
 
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index 776dbf7..090fb73 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 9
 
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index dbd0986..797bc5b 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -13,12 +13,12 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 # Test --poolmetadatasize range
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index e2f49c4..38b8a3d 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -12,12 +12,12 @@
 
 # Test unaligned size of external origin and thin pool chunk size
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 which cmp || skip
 
 #
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 8507836..c37a898 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -12,12 +12,12 @@
 
 # Test creation of thin snapshots using external origin
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 which mkfs.ext2 || skip
 which fsck || skip
 
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 4d3d175..c6bf4a0 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -13,12 +13,12 @@
 # test support for non-power-of-2 thin chunk size
 #
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 76929cc..66a815b 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -10,12 +10,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 check_lv_field_modules_()
 {
 	mod=$1
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 56d7e35..236bc27 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -13,12 +13,12 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 check_lv_field_modules_()
 {
 	mod=$1
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index ec98e59..0460fcb 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -11,9 +11,9 @@
 
 # 'Check extents percentage arguments'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 2 128
 vgcreate $vg $(cat DEVICES)
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index aeb18f1..7506fe5 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 extend() {
 	lvextend --use-policies --config "activation { snapshot_autoextend_threshold = $1 }" $vg/snap
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index c76e36e..6eb7dad 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 6b1b9e0..31ab729 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -13,12 +13,12 @@
 # play with thin-pool resize in corner cases
 #
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 9ecd5ae..030991f 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -11,12 +11,12 @@
 
 # Test autoextension of thin metadata volume
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
 }
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index a97e93b..ac78a88 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -9,12 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 aux prepare_vg 3
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index cfdd4cc..2e81d42 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -13,9 +13,9 @@
 # tests lvm initialization, and especially negative tests of error paths
 #
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index f0d3ee9..2c2be52 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 5
 
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index 0421c59..41d7543 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -14,9 +14,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_CLVMD || skip
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_vg 2
 aux prepare_lvmetad
 vgs -vv 2> errs
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 423c9ed..13d5aa4 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 333318a..b13bcb2 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index 4fe49f6..fe76340 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 398740e..8f9974a 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 3 22
 
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 090cb06..540dfe8 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -11,12 +11,12 @@
 
 # Test resize of thin volume with external origin
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 2 0 || skip
 
 # Pretend we miss the external_origin_extend feature
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 82ac898..c097db1 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -9,12 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 10 0 || skip
 
 aux prepare_pvs 3 1256
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 00bae14..a682a66 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 2 80
 
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 73706b7..072e767 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -14,9 +14,9 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 aux prepare_vg 5 8000
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index 5f348fb..80066c2 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 529e599..fda09ec 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -11,9 +11,9 @@
 
 # 'Test for proper escaping of strings in metadata (bz431474)'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # For udev impossible to create
 test "$LVM_TEST_DEVDIR" = "/dev" && skip
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 869297e..447b4e1 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 6
 
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index eed6512..04e483d 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 8e3503f..ebf341c 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 40a6503..36969ea 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -11,14 +11,13 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
+SKIP_WITH_LVMPOLLD=1
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 lv_is_on_ ()
 {
 	local lv=$vg/$1
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 6bdf4a1..c9609fe 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -9,13 +9,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
-
 # This test is not using any lvm command
 # so skip duplicate CLMVD and lvmetad test
-test -e LOCAL_CLVMD && skip
-test -e LOCAL_LVMETAD && skip
-test -e LOCAL_LVMPOLLD && skip
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
 
 CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#+-.:=@_"
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 39c2ac9..77e81eb 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -10,9 +10,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 9380c8d..39246dd 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index f4e18f4..6b2254e 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 2
 vgreduce $vg "$dev1" 2>&1 | not grep -i 'parse error'
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 70d5a64..395cd20 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -9,11 +9,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
-
 # lvmetad does not handle pool labels so skip test.
-test ! -e LOCAL_LVMETAD || skip
-test -e LOCAL_LVMPOLLD && skip
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
 
 env printf "" || skip # skip if printf is not available
 
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index f2b4765..90d3e23 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -6,11 +6,10 @@
 # of the GNU General Public License v.2.
 
 test_description='Test vgs with duplicate vg names'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 2
 
 pvcreate "$dev1"
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 52c97d4..8b69271 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise toollib process_each_lv'
+SKIP_WITH_LVMPOLLD=1
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index 972bb85..5919a76 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test process_each_pv with zero mda'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 13fddb3..6a42fee 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test process_each_pv with zero mda'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
index 426c3f1..886b600 100644
--- a/test/shell/process-each-pv.sh
+++ b/test/shell/process-each-pv.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise toollib process_each_pv'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index 493c24b..e3a03d4 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise toollib process_each_pv'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 14
 
 #
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 5940cc6..8f7f1db 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -13,12 +13,12 @@
 # test thin profile functionality
 #
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 DEV_SIZE=32
 
 # check we have thinp support compiled in
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 8187129..aaa1dcf 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -13,9 +13,9 @@
 # test basic profile functionality
 #
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 MSG_FAILED_TO_APPLY_CMD_PROFILE="Failed to apply command profile"
 MSG_IGNORING_INVALID_CMD_PROFILE="Ignoring invalid command profile"
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index 7b8b42e..6dbcc75 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -10,9 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test 'Found duplicate' is shown
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index ecd6125..99668ee 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -11,9 +11,9 @@
 
 # 'Exercise duplicate metadata diagnostics'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index eb62c73..d0b2c21 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # use small default size  - 512KB
 aux lvmconf 'devices/pv_min_size = 512'
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 8cffb06..ca78168 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -11,9 +11,9 @@
 
 # 'Test pvchange option values'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 check_changed_uuid_() {
 	test "$1" != "$(get pv_field "$2" uuid)" || die "UUID has not changed!"
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 68c0882..80e1b3b 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test pvcreate bootloader area support'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 1
 aux lvmconf 'global/suffix=0' 'global/units="b"'
 
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index 4ac5a61..2f620bd 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2
 pvcreate "$dev1"
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index 48ebc83..298edd0 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -15,9 +15,9 @@
 #
 # 'Test pvcreate without metadata on all pvs'
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2 128
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index db53216..78e6cc5 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # skip this test if mdadm or sfdisk (or others) aren't available
 which sfdisk || skip
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index 6593877..3181722 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -8,9 +8,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux lvmconf 'devices/md_component_detection = 1'
 
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index ed3b4f4..5b74ed3 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -10,12 +10,11 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test pvcreate option values'
+SKIP_WITH_LVMPOLLD=1
 PAGESIZE=$(getconf PAGESIZE)
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 4
 
 #COMM 'pvcreate rejects negative setphysicalvolumesize'
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 2f09596..69554ef 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure pvmove works with the cache segment types"
+SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
@@ -19,7 +20,6 @@ test_description="ensure pvmove works with the cache segment types"
 # This allows us to ensure that it is disallowed even when there are
 # stacking complications to consider.
 
-test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
 aux have_cache 1 3 0 || skip
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 0accf4a..69cef2d 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -10,10 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure pvmove works with raid segment types"
+SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
 aux have_raid 1 3 5 || skip
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 0070826..5bd0e45 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -14,6 +14,8 @@
 
 # 2 pvmove LVs in 2 VGs (1 per VG)
 
+SKIP_WITH_CLVMD=1
+
 . lib/inittest
 
 aux prepare_pvs 4 30
@@ -245,8 +247,6 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev2"
 }
 
-test -e LOCAL_CLVMD && skip
-
 test_pvmove_resume lvchange_single
 test_pvmove_resume lvchange_all
 test_pvmove_resume vgchange_single
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 7ae3721..ff3806f 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -14,6 +14,8 @@
 
 # Moving 2 LVs in VG variant
 
+SKIP_WITH_CLVMD=1
+
 . lib/inittest
 
 aux prepare_pvs 2 30
@@ -189,8 +191,6 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 }
 
-test -e LOCAL_CLVMD && skip
-
 test_pvmove_resume lvchange_single
 test_pvmove_resume lvchange_all
 test_pvmove_resume vgchange_single
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 713534f..c113252 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -14,6 +14,8 @@
 
 # Multisegment variant w/ 2 pvmoves LVs per VG
 
+SKIP_WITH_CLVMD=1
+
 . lib/inittest
 
 aux prepare_pvs 5 30
@@ -219,8 +221,6 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev3"
 }
 
-test -e LOCAL_CLVMD && skip
-
 test_pvmove_resume lvchange_single
 test_pvmove_resume lvchange_all
 test_pvmove_resume vgchange_single
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 33128d5..1d4e251 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -10,9 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description="ensure pvmove works with thin segment types"
+SKIP_WITH_CLVMD=1
 
 . lib/inittest
-test -e LOCAL_CLVMD && skip
+
 which md5sum || skip
 
 aux have_thin 1 8 0 || skip
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 2400ac5..cb97bc2 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -12,9 +12,9 @@
 # Checks we are not reading our own devices
 # https://bugzilla.redhat.com/show_bug.cgi?id=1064374
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg
 
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 5c55839..5ac79c2 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 pvcreate "$dev1"
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index f7ac95b..2361313 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -8,9 +8,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 322a527..82a0707 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -14,11 +14,10 @@
 #
 
 test_description='Test read-ahead functionality'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_vg 5
 
 #COMM "test various read ahead settings (bz450922)"
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index b859199..20d57c7 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 6 16
 
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index 4cabde1..7ea2852 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -9,12 +9,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 1 16
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 631c637..249d38b 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 4 12
 
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index e82a757..0cd3a20 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -11,9 +11,9 @@
 
 # no automatic extensions please
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
index 47c8d2e..2a156f3 100644
--- a/test/shell/snapshot-cluster.sh
+++ b/test/shell/snapshot-cluster.sh
@@ -12,9 +12,9 @@
 # Testing renaming snapshots in cluster
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 1
 
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index 0abba0c..4986835 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -12,9 +12,9 @@
 # regression test for lvmetad reporting error:
 # Internal error: LV snap_with_lvm1_meta (00000000000000000000000000000001) missing from preload metadata
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index a96bd7f..5adf3f5 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -12,9 +12,9 @@
 # Testing calculation of snapshot space
 # https://bugzilla.redhat.com/show_bug.cgi?id=1035871
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 1
 
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 9e9b4b7..eb3d686 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -15,9 +15,10 @@
 # is triggered by kernel 3.14-rc[1..5]
 # http://www.redhat.com/archives/dm-devel/2014-March/msg00005.html
 #
-. lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
 
 # Snapshot should remain unmodified
 check_s_() {
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 952a7bb..395fad1 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -11,14 +11,14 @@
 
 # check if 'dmsetup --noflush' will work properly for mounted snapshot
 
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 which mkfs.ext2 || skip
 
-test -e LOCAL_LVMETAD && skip
-test -e LOCAL_LVMPOLLD && skip
-test -e LOCAL_CLVMD && skip
-
 aux prepare_vg 5
 
 # Create stacked device
diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
index 47bf213..7450aec 100644
--- a/test/shell/snapshot-rename.sh
+++ b/test/shell/snapshot-rename.sh
@@ -12,9 +12,9 @@
 # Testing renaming snapshots (had problem in cluster)
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 1
 
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index 133014b..15634ba 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -12,9 +12,9 @@
 # Check very large device size (upto 15Exa bytes)
 # this needs 64bit arch
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux can_use_16T || skip
 
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index d15eee1..1abb239 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -11,9 +11,9 @@
 
 # no automatic extensions please
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 MKFS=mkfs.ext2
 which $MKFS || skip
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 09d9e75..a50015b 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 3
 cp -r "$dev1" "$DM_DEV_DIR/stray"
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 5bb5c3a..0218b95 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test system_id'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 1
 
 # with clvm enabled, vgcreate with no -c option creates a clustered vg,
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 37d738f..2823dc9 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index 0cdaa87..b6b9b20 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -15,12 +15,12 @@
 #
 
 
+SKIP_WITH_LVMPOLLD=1
+
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 which sfdisk || skip
 
 aux prepare_pvs 1 30
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index 5f1fc6b..9c5ce87 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -11,6 +11,8 @@
 
 # no automatic extensions, just umount
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 is_dir_mounted_()
@@ -20,8 +22,6 @@ is_dir_mounted_()
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 3e49390..432193a 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -11,12 +11,12 @@
 
 # test defaults entered through lvm.conf
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 3516e2d..578e0a7 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -11,12 +11,12 @@
 
 # test restore operation of thin pool metadata
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index c3dab25..9fc0ff2 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -11,12 +11,12 @@
 
 # test pool behaviour when volume_list masks activation
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 #
 # Main
 #
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index ebb7220..2b16cf6 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index a1d3696..c2148ba 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 76bf8a1..298b2a8 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 check_() {
 	# vgscan needs --cache option for direct scan if lvmetad is used
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index a3d1b9a..ac21772 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -6,11 +6,10 @@
 # of the GNU General Public License v.2.
 
 test_description='Test the vg name for an lv from env var'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 2
 
 pvcreate "$dev1"
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index b0faf38..b5c2d40 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 7b3d557..7cd7e42 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -10,9 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Check perfomance of activation and deactivation
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 # FIXME: lvmetad fails with i.e. 1500 device on memory failure...
 
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 613d985..886fa50 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_dmeventd
 aux prepare_pvs 3
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index f9c3ac0..2dc3da7 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 8450d63..a4f078c 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_CLVMD && skip
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 077b447..370dba8 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise some vgchange diagnostics'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_pvs 4
 
 pvcreate --metadatacopies 0 "$dev1"
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index a4930aa..dfabac5 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index bb78caf..c2f1ef3 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 #
 # Test to exercise larger number of PVs in a VG
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index df0094c..04d0daa 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise some vgcreate diagnostics'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index d8de96d..4bc2439 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 65665bc..e0c30cf 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -13,9 +13,9 @@
 # Exercise various vgextend commands
 #
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 53c8b00..8589f05 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 42976c2..136e56d 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test vgmerge operation'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_pvs 4 64
 
 # 'vgmerge succeeds with single linear LV in source VG'
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index 981a964..f344281 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # 'Test vgmerge command options for validity'
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_pvs 4
 
 # 'vgmerge normal operation'
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 1bea397..1023159 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -9,9 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMPOLLD=1
 
-exit 0
+. lib/inittest
 
 #
 # Snapshots of 'mirrors' are not supported.  They can no longer be created.
@@ -21,7 +22,7 @@ exit 0
 
 aux prepare_vg 5
 
-lvcreate --type mirror -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate --type mirror -m 3 -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 lvcreate -i 2 -L 2M $vg "$dev1" "$dev2" -n stripe
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 9f55395..a4faa16 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 4
 
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index dc3c9db..59cb9b7 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg -an --zero n
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 59c3397..92070e8 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 975e873..963f4c1 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -12,12 +12,12 @@
 # Test vgsplit operation, including different LV types
 
 # disable lvmetad logging as it bogs down test systems
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 COMM() {
 	LAST_TEST="$@"
 }
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 2fe734f..7da8eff 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -10,11 +10,10 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test vgsplit operation, including different LV types
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 COMM() {
 	LAST_TEST="$@"
 }
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 6a04f07..237a054 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 754f8ba..9d60cc7 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -11,12 +11,12 @@
 
 # Test vgsplit command options for validity
 
+SKIP_WITH_LVMPOLLD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux have_thin 1 0 0 || skip
 
 aux prepare_devs 5
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index b0422d5..2ca8dc7 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -11,9 +11,9 @@
 
 # Test vgsplit command options for validity
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index df90529..ee04aa1 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -11,9 +11,9 @@
 
 # Basic usage of zero target
 
-. lib/inittest
+SKIP_WITH_LVMPOLLD=1
 
-test -e LOCAL_LVMPOLLD && skip
+. lib/inittest
 
 which md5sum || skip
 


