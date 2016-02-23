From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Feb 2016 15:29:42 +0000 (UTC)
Subject: master - tests: add SKIP_WITH_LVMLOCKD
Message-ID: <20160223152942.140C360DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f54253d396d2f97d6f6a60185616523797364182
Commit:        f54253d396d2f97d6f6a60185616523797364182
Parent:        5d7e83c73cba507c4e5d798dbfe00314a4850b02
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 22 16:13:42 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 09:28:48 2016 -0600

tests: add SKIP_WITH_LVMLOCKD

to all tests that don't already used vgcreate $SHARED
---
 test/api/dbustest.sh                               |    1 +
 test/api/vgtest.sh                                 |    2 ++
 test/lib/inittest.sh                               |    2 ++
 test/shell/000-basic.sh                            |    1 +
 test/shell/activate-minor.sh                       |    1 +
 test/shell/activate-missing-segment.sh             |    1 +
 test/shell/activate-missing.sh                     |    1 +
 test/shell/activate-partial.sh                     |    1 +
 test/shell/activation-skip.sh                      |    1 +
 test/shell/backup-read-only.sh                     |    1 +
 test/shell/clvmd-restart.sh                        |    1 +
 test/shell/covercmd.sh                             |    1 +
 test/shell/discards-thin.sh                        |    1 +
 test/shell/dmeventd-restart.sh                     |    1 +
 test/shell/dumpconfig.sh                           |    1 +
 test/shell/error-usage.sh                          |    1 +
 test/shell/fsadm.sh                                |    1 +
 test/shell/inconsistent-metadata.sh                |    1 +
 test/shell/listings.sh                             |    1 +
 test/shell/lock-blocking.sh                        |    1 +
 test/shell/lock-parallel.sh                        |    1 +
 test/shell/lvchange-cache-old.sh                   |    1 +
 test/shell/lvchange-cache.sh                       |    1 +
 test/shell/lvchange-mirror.sh                      |    1 +
 test/shell/lvchange-partial-raid10.sh              |    1 +
 test/shell/lvchange-partial.sh                     |    1 +
 test/shell/lvchange-raid.sh                        |    1 +
 test/shell/lvchange-syncaction-raid.sh             |    1 +
 test/shell/lvchange-thin.sh                        |    1 +
 test/shell/lvconvert-cache-raid.sh                 |    1 +
 test/shell/lvconvert-cache-smq.sh                  |    1 +
 test/shell/lvconvert-cache-thin.sh                 |    1 +
 test/shell/lvconvert-cache.sh                      |    1 +
 test/shell/lvconvert-mirror-basic.sh               |    2 ++
 test/shell/lvconvert-mirror-updown.sh              |    2 ++
 test/shell/lvconvert-mirror.sh                     |    2 ++
 test/shell/lvconvert-raid-allocation.sh            |    1 +
 test/shell/lvconvert-raid.sh                       |    1 +
 test/shell/lvconvert-raid10.sh                     |    1 +
 test/shell/lvconvert-raid456.sh                    |    1 +
 test/shell/lvconvert-repair-dmeventd.sh            |    1 +
 test/shell/lvconvert-repair-policy.sh              |    2 ++
 test/shell/lvconvert-repair-raid-dmeventd.sh       |    1 +
 test/shell/lvconvert-repair-raid.sh                |    1 +
 test/shell/lvconvert-repair-replace.sh             |    2 ++
 test/shell/lvconvert-repair-snapshot.sh            |    1 +
 test/shell/lvconvert-repair-thin-raid.sh           |    1 +
 test/shell/lvconvert-repair-thin.sh                |    1 +
 test/shell/lvconvert-repair-transient-dmeventd.sh  |    1 +
 test/shell/lvconvert-repair-transient.sh           |    1 +
 test/shell/lvconvert-repair.sh                     |    2 ++
 test/shell/lvconvert-snapshot.sh                   |    1 +
 test/shell/lvconvert-thin-external.sh              |    1 +
 test/shell/lvconvert-thin-raid.sh                  |    1 +
 test/shell/lvconvert-thin.sh                       |    1 +
 test/shell/lvconvert-twostep.sh                    |    2 ++
 test/shell/lvcreate-cache-raid.sh                  |    1 +
 test/shell/lvcreate-cache.sh                       |    1 +
 test/shell/lvcreate-large-raid.sh                  |    1 +
 test/shell/lvcreate-large-raid10.sh                |    1 +
 test/shell/lvcreate-large.sh                       |    1 +
 test/shell/lvcreate-mirror.sh                      |    1 +
 test/shell/lvcreate-missing.sh                     |    1 +
 test/shell/lvcreate-operation.sh                   |    1 +
 test/shell/lvcreate-pvtags.sh                      |    1 +
 test/shell/lvcreate-raid.sh                        |    1 +
 test/shell/lvcreate-raid10.sh                      |    1 +
 test/shell/lvcreate-repair.sh                      |    1 +
 test/shell/lvcreate-signature-wiping.sh            |    1 +
 test/shell/lvcreate-small-snap.sh                  |    1 +
 test/shell/lvcreate-striped-mirror.sh              |    1 +
 test/shell/lvcreate-thin-big.sh                    |    1 +
 test/shell/lvcreate-thin-external-size.sh          |    1 +
 test/shell/lvcreate-thin-external.sh               |    1 +
 test/shell/lvcreate-thin-power2.sh                 |    1 +
 test/shell/lvcreate-thin-snap.sh                   |    1 +
 test/shell/lvcreate-thin.sh                        |    1 +
 test/shell/lvcreate-usage.sh                       |    2 ++
 test/shell/lvextend-percent-extents.sh             |    1 +
 test/shell/lvextend-snapshot-dmeventd.sh           |    1 +
 test/shell/lvextend-snapshot-policy.sh             |    1 +
 test/shell/lvextend-thin-data-dmeventd.sh          |    1 +
 test/shell/lvextend-thin-full.sh                   |    1 +
 test/shell/lvextend-thin-metadata-dmeventd.sh      |    1 +
 test/shell/lvextend-thin.sh                        |    1 +
 test/shell/lvm-init.sh                             |    1 +
 test/shell/lvmcache-exercise.sh                    |    1 +
 test/shell/lvmetad-ambiguous.sh                    |    1 +
 test/shell/lvmetad-autoshutdown.sh                 |    1 +
 test/shell/lvmetad-client-filter.sh                |    1 +
 test/shell/lvmetad-disabled.sh                     |    1 +
 test/shell/lvmetad-dump.sh                         |    1 +
 test/shell/lvmetad-lvm1.sh                         |    1 +
 test/shell/lvmetad-lvscan-cache.sh                 |    1 +
 test/shell/lvmetad-no-cluster.sh                   |    1 +
 test/shell/lvmetad-override.sh                     |    1 +
 test/shell/lvmetad-pvs.sh                          |    1 +
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    1 +
 test/shell/lvmetad-pvscan-cache.sh                 |    1 +
 test/shell/lvmetad-pvscan-filter.sh                |    1 +
 test/shell/lvmetad-pvscan-md.sh                    |    1 +
 test/shell/lvmetad-pvscan-nomda-bg.sh              |    1 +
 test/shell/lvmetad-pvscan-nomda.sh                 |    1 +
 test/shell/lvmetad-restart.sh                      |    1 +
 test/shell/lvmetad-test.sh                         |    1 +
 test/shell/lvmetad-warning.sh                      |    1 +
 test/shell/lvrename-cache-thin.sh                  |    1 +
 test/shell/lvresize-mirror.sh                      |    1 +
 test/shell/lvresize-raid.sh                        |    1 +
 test/shell/lvresize-raid10.sh                      |    1 +
 test/shell/lvresize-rounding.sh                    |    1 +
 test/shell/lvresize-thin-external-origin.sh        |    1 +
 test/shell/lvresize-thin-metadata.sh               |    1 +
 test/shell/lvresize-usage.sh                       |    1 +
 test/shell/lvs-cache.sh                            |    1 +
 test/shell/mda-rollback.sh                         |    1 +
 test/shell/mdata-strings.sh                        |    1 +
 test/shell/metadata-balance.sh                     |    1 +
 test/shell/metadata-dirs.sh                        |    1 +
 test/shell/metadata.sh                             |    1 +
 test/shell/mirror-names.sh                         |    2 ++
 test/shell/mirror-vgreduce-removemissing.sh        |    1 +
 test/shell/name-mangling.sh                        |    1 +
 test/shell/nomda-missing.sh                        |    1 +
 test/shell/nomda-restoremissing.sh                 |    1 +
 test/shell/orphan-ondisk.sh                        |    1 +
 test/shell/pool-labels.sh                          |    1 +
 test/shell/process-each-duplicate-pvs.sh           |    2 ++
 test/shell/process-each-duplicate-vgnames.sh       |    1 +
 test/shell/process-each-pv-nomda.sh                |    1 +
 test/shell/process-each-pvresize.sh                |    1 +
 test/shell/process-each-vgreduce.sh                |    2 ++
 test/shell/profiles-thin.sh                        |    1 +
 test/shell/profiles.sh                             |    1 +
 test/shell/pv-check-dev-size.sh                    |    1 +
 test/shell/pv-duplicate-uuid.sh                    |    1 +
 test/shell/pv-duplicate.sh                         |    1 +
 test/shell/pv-ext-flags.sh                         |    1 +
 test/shell/pv-min-size.sh                          |    1 +
 test/shell/pv-range-overflow.sh                    |    2 ++
 test/shell/pvchange-usage.sh                       |    1 +
 test/shell/pvcreate-bootloaderarea.sh              |    1 +
 test/shell/pvcreate-ff.sh                          |    1 +
 test/shell/pvcreate-metadata0.sh                   |    1 +
 test/shell/pvcreate-operation-md.sh                |    1 +
 test/shell/pvcreate-operation.sh                   |    1 +
 test/shell/pvcreate-restore.sh                     |    2 ++
 test/shell/pvcreate-usage.sh                       |    1 +
 test/shell/pvmove-abort-all.sh                     |    2 ++
 test/shell/pvmove-abort.sh                         |    2 ++
 test/shell/pvmove-all-segtypes.sh                  |    2 ++
 test/shell/pvmove-background.sh                    |    2 ++
 test/shell/pvmove-basic.sh                         |    2 ++
 test/shell/pvmove-cache-segtypes.sh                |    1 +
 test/shell/pvmove-raid-segtypes.sh                 |    1 +
 test/shell/pvmove-restart.sh                       |    2 ++
 test/shell/pvmove-resume-1.sh                      |    1 +
 test/shell/pvmove-resume-2.sh                      |    1 +
 test/shell/pvmove-resume-multiseg.sh               |    1 +
 test/shell/pvmove-thin-segtypes.sh                 |    1 +
 test/shell/pvremove-thin.sh                        |    1 +
 test/shell/pvremove-usage.sh                       |    1 +
 test/shell/pvremove-warnings.sh                    |    1 +
 test/shell/pvresize-mdas.sh                        |    1 +
 test/shell/read-ahead.sh                           |    1 +
 test/shell/report-fields.sh                        |    1 +
 test/shell/report-hidden.sh                        |    1 +
 test/shell/select-report.sh                        |    1 +
 test/shell/select-tools-thin.sh                    |    1 +
 test/shell/select-tools.sh                         |    1 +
 test/shell/snapshot-autoumount-dmeventd.sh         |    1 +
 test/shell/snapshot-cluster.sh                     |    1 +
 test/shell/snapshot-lvm1.sh                        |    1 +
 test/shell/snapshot-maxsize.sh                     |    1 +
 test/shell/snapshot-merge.sh                       |    2 ++
 test/shell/snapshot-reactivate.sh                  |    1 +
 test/shell/snapshot-remove-dmsetup.sh              |    1 +
 test/shell/snapshot-rename.sh                      |    1 +
 test/shell/snapshot-usage-exa.sh                   |    1 +
 test/shell/snapshot-usage.sh                       |    1 +
 test/shell/snapshots-of-mirrors.sh                 |    2 ++
 test/shell/stray-device-node.sh                    |    1 +
 test/shell/system_id.sh                            |    1 +
 test/shell/tags.sh                                 |    1 +
 test/shell/test-partition.sh                       |    1 +
 test/shell/thin-autoumount-dmeventd.sh             |    1 +
 test/shell/thin-defaults.sh                        |    1 +
 test/shell/thin-flags.sh                           |    1 +
 test/shell/thin-merge.sh                           |    2 ++
 test/shell/thin-overprovisioning.sh                |    2 ++
 test/shell/thin-resize-match.sh                    |    2 ++
 test/shell/thin-restore.sh                         |    1 +
 test/shell/thin-vglock.sh                          |    2 ++
 test/shell/thin-volume-list.sh                     |    1 +
 test/shell/topology-support.sh                     |    1 +
 test/shell/unknown-segment.sh                      |    1 +
 test/shell/unlost-pv.sh                            |    1 +
 test/shell/vg-name-from-env.sh                     |    1 +
 test/shell/vgcfgbackup-usage.sh                    |    1 +
 test/shell/vgchange-many.sh                        |    1 +
 test/shell/vgchange-maxlv.sh                       |    1 +
 test/shell/vgchange-partial.sh                     |    1 +
 test/shell/vgchange-sysinit.sh                     |    1 +
 test/shell/vgchange-usage.sh                       |    1 +
 test/shell/vgck.sh                                 |    1 +
 test/shell/vgcreate-many-pvs.sh                    |    1 +
 test/shell/vgcreate-usage.sh                       |    1 +
 test/shell/vgextend-restoremissing.sh              |    1 +
 test/shell/vgextend-usage.sh                       |    1 +
 test/shell/vgimportclone.sh                        |    1 +
 test/shell/vgmerge-operation.sh                    |    1 +
 test/shell/vgmerge-usage.sh                        |    1 +
 test/shell/vgreduce-removemissing-snapshot.sh      |    1 +
 test/shell/vgreduce-usage.sh                       |    1 +
 test/shell/vgremove-corrupt-vg.sh                  |    1 +
 test/shell/vgrename-usage.sh                       |    1 +
 test/shell/vgsplit-operation.sh                    |    1 +
 test/shell/vgsplit-raid.sh                         |    1 +
 test/shell/vgsplit-stacked.sh                      |    1 +
 test/shell/vgsplit-thin.sh                         |    1 +
 test/shell/vgsplit-usage.sh                        |    1 +
 test/shell/zero-usage.sh                           |    1 +
 222 files changed, 249 insertions(+), 0 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index f33add0..b4e3964 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -11,6 +11,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/api/vgtest.sh b/test/api/vgtest.sh
index 227e156..a262c26 100644
--- a/test/api/vgtest.sh
+++ b/test/api/vgtest.sh
@@ -13,6 +13,8 @@
 # tests lvm2app library
 #
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_pvs 2
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 110bdd3..4531e66 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -37,6 +37,8 @@ test -n "$SKIP_WITH_LVMETAD" && test -n "$LVM_TEST_LVMETAD" && initskip
 
 test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && initskip
 
+test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
+
 unset CDPATH
 
 # grab some common utilities
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 2f04be1..d1c7dc8 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index d48616a..bb78c7f 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 0e62db0..7f26e11 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -16,6 +16,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 49d5cf8..3e34471 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -16,6 +16,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index 4ddfec1..e686ec6 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index d03b9b7..8935286 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/backup-read-only.sh b/test/shell/backup-read-only.sh
index 58209ed..178c49b 100644
--- a/test/shell/backup-read-only.sh
+++ b/test/shell/backup-read-only.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index 4c41e6b..39e4420 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -13,6 +13,7 @@
 export LVM_CLVMD_BINARY=clvmd
 export LVM_BINARY=lvm
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 73ca191..69ff8d6 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -14,6 +14,7 @@
 # to improve code coverage
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index c9fb2f4..f85b22c 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -13,6 +13,7 @@
 # test support of thin discards
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 5f036f8..9fad9a8 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index 9aa4d69..d62d28c 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 99d2c8a..3f6bf97 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -11,6 +11,7 @@
 
 # Basic usage of zero target
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 802a5af..ac43900 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise fsadm filesystem resize'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 67b96d0..808616b 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index cd36326..ad4ee15 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -13,6 +13,7 @@
 # tests functionality of lvs, pvs, vgs, *display tools
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 451749c..1a14d21 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='test some blocking / non-blocking multi-vg operations'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index eb985fd..4f4b340 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -12,6 +12,7 @@
 # Test parallel use of lvm commands and check locks aren't dropped
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1049296
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-cache-old.sh b/test/shell/lvchange-cache-old.sh
index 75d73ea..018d384 100644
--- a/test/shell/lvchange-cache-old.sh
+++ b/test/shell/lvchange-cache-old.sh
@@ -11,6 +11,7 @@
 
 # Exercise usage of older metadata which are missing some new settings
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index bd9e016..3fd326a 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 8c0b4a8..8875f05 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -11,6 +11,7 @@
 
 # FIXME RESYNC doesn't work in cluster with exclusive activation
 # seriously broken!
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index ddd23f9..125129b 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 5d52360..63ede22 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index dd7504a..4bc8855 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index f11d7ce..1997bc6 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -11,6 +11,7 @@
 
 # test activation race for raid's --syncaction check
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 2a11630..96c4b30 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index a7df89b..551c00f 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -11,6 +11,7 @@
 
 # Exercise usage of stacked cache volume using raid volume
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-cache-smq.sh b/test/shell/lvconvert-cache-smq.sh
index 20fac19..19daebf 100644
--- a/test/shell/lvconvert-cache-smq.sh
+++ b/test/shell/lvconvert-cache-smq.sh
@@ -11,6 +11,7 @@
 
 # Exercise conversion of cache and cache pool
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index a63563c..864ea7e 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -11,6 +11,7 @@
 
 # Exercise usage of stacked cache volume used in thin pool volumes
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 3bda5a5..8e38050 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -11,6 +11,7 @@
 
 # Exercise conversion of cache and cache pool
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 56fd818..530e6dd 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index b89b0aa..13c77ce 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -11,6 +11,8 @@
 
 # Demonstrate problem when upconverting and cutting leg in clvmd
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_pvs 3
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index c6554a2..078ebad 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 64b03fe..c5927a7 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 3de43c0..25bc4a8 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,6 +11,7 @@
 
 # disable lvmetad logging as it bogs down test systems
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index b707c7f..ceeaa55 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 079711c..f7e6e56 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 9d7d711..2856227 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 4fbc1cf..2ef5f1b 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 4
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index 97a7734..1a9e993 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index d708608..41d1cb9 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 26e02d8..9444417 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 6
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 72ced1e..269559d 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
index 3076081..a895e08 100644
--- a/test/shell/lvconvert-repair-thin-raid.sh
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -12,6 +12,7 @@
 
 # Test repairing of broken thin pool on raid
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 217ab57..8930894 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -12,6 +12,7 @@
 
 # Test repairing of broken thin pool metadata
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 8a9b16a..59c7648 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 8a60504..947ae45 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 4190f23..43a7ee9 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 recreate_vg_()
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 3eb5a0e..6e73563 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -12,6 +12,7 @@
 
 # Test various supported conversion of snapshot
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index f881938..712e368 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -12,6 +12,7 @@
 
 # Test conversion to thin external origin
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index f42b3fe..7fa8733 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 60aa849..1999d86 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index b58fc47..f202ae2 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 4
diff --git a/test/shell/lvcreate-cache-raid.sh b/test/shell/lvcreate-cache-raid.sh
index a2a5e97..df7be6b 100644
--- a/test/shell/lvcreate-cache-raid.sh
+++ b/test/shell/lvcreate-cache-raid.sh
@@ -11,6 +11,7 @@
 
 # Exercise creation of cache and raids
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 6e95562..8f35f93 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -14,6 +14,7 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 929b776..133e517 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 7cb0514..e249e77 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index d2ee21a..81c612a 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index c0d5ec9..0e9bd21 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index e4af260..c8add08 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index a32bd3c..9062d5d 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index a3e067b..59c2d75 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 11d27d6..19c8c61 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 27a819f..2cd5ac0 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index e5663b0..53a6fc1 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index ba8a937..6699832 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise signature wiping during lvcreate'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index c018bf9..43424de 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index adc5c25..35d8b05 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index c385586..9abc1fd 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -13,6 +13,7 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index a78ecfc..9a28591 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -12,6 +12,7 @@
 
 # Test unaligned size of external origin and thin pool chunk size
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 0f14abb..8a10c18 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -12,6 +12,7 @@
 
 # Test creation of thin snapshots using external origin
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 5456cd7..797bced 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -13,6 +13,7 @@
 # test support for non-power-of-2 thin chunk size
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index daebece..91de11b 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index ecf80bd..3fb1e73 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -13,6 +13,7 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 67501b8..f7b4704 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -11,6 +11,8 @@
 
 # 'Exercise some lvcreate diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_pvs 4
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index fd41ba1..e2666e9 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -11,6 +11,7 @@
 
 # 'Check extents percentage arguments'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 1cf8d6c..46f844a 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index be5abf4..ce8c46b 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
index 03bd23d..ceb9088 100644
--- a/test/shell/lvextend-thin-data-dmeventd.sh
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -11,6 +11,7 @@
 
 # Test autoextension of thin data volume
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index 5780f9d..cd4705d 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -13,6 +13,7 @@
 # play with thin-pool resize in corner cases
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index bcb7f29..a892bd4 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -11,6 +11,7 @@
 
 # Test autoextension of thin metadata volume
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 7810e5f..c5bb2cf 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index d5fcae7..a5435fe 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -13,6 +13,7 @@
 # tests lvm initialization, and especially negative tests of error paths
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 19cfb21..af85b90 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 077cce9..ffcbdd3 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-autoshutdown.sh b/test/shell/lvmetad-autoshutdown.sh
index 019a634..d110bf0 100644
--- a/test/shell/lvmetad-autoshutdown.sh
+++ b/test/shell/lvmetad-autoshutdown.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
index 663a64c..51d25ff 100644
--- a/test/shell/lvmetad-client-filter.sh
+++ b/test/shell/lvmetad-client-filter.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 79aad05..60cd2ff 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index a1dd0ee..67ea01b 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 4fd4bb2..7a93f74 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index 1b1c7a8..3b6528e 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index d11a12d..7ac448f 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 7cf3881..0e56904 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 464633a..97cc205 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index 61cec63..34139df 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 
 . lib/inittest
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 469e9ef..22c9b5e 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 666add9..91bb930 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index 957a1b6..f5b91d7 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
index c0217b8..52c25ef 100644
--- a/test/shell/lvmetad-pvscan-nomda-bg.sh
+++ b/test/shell/lvmetad-pvscan-nomda-bg.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 4ad8e8c..59912ad 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index a1c9134..e40ad23 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 5f3b795..2fe06ba 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 5282935..e631f9c 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITHOUT_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
index bf5c2a3..33d0e34 100644
--- a/test/shell/lvrename-cache-thin.sh
+++ b/test/shell/lvrename-cache-thin.sh
@@ -11,6 +11,7 @@
 
 # Check rename of stacked  thin over cached LV
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index be3c749..cc86a35 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 8b5544c..98eef28 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index c91b6af..dc6e2fb 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index de92cfb..1f18ee5 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 049d79b..b864b81 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -11,6 +11,7 @@
 
 # Test resize of thin volume with external origin
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 1be5da5..2ef4fce 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 09672e3..13f4e1f 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 304ae8b..a06a023 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -14,6 +14,7 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index 1b61f3d..0fd095a 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 30b6f61..d3e831f 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -11,6 +11,7 @@
 
 # 'Test for proper escaping of strings in metadata (bz431474)'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 8da689e..29e9135 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index f4b209e..525f77f 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 7bbca8b..9f4aa1f 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 351356d..9c2868a 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -12,6 +12,8 @@
 
 test_description="check namings of mirrored LV"
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 # ---------------------------------------------------------------------
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 4f6acfa..eb51af6 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 # disable lvmetad logging as it bogs down test systems
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 6399e7b..049064e 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -11,6 +11,7 @@
 
 # This test is not using any lvm command
 # so skip duplicate CLMVD and lvmetad test
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index fad9d0e..f9c394e 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index cbb4412..e0d1da0 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 2c8ae6c..0d46cd6 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 3ac2b2f..86f5fec 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # lvmetad does not handle pool labels so skip test.
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 353b296..cf0ca2d 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -7,6 +7,8 @@
 
 test_description='Test duplicate PVs'
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_devs 2
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 90d3e23..532c669 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -6,6 +6,7 @@
 # of the GNU General Public License v.2.
 
 test_description='Test vgs with duplicate vg names'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 2fddbbf..d48da26 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test process_each_pv with zero mda'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index 24918f1..86c2a7d 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise toollib process_each_pv'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/process-each-vgreduce.sh b/test/shell/process-each-vgreduce.sh
index ade290e..6df8c56 100644
--- a/test/shell/process-each-vgreduce.sh
+++ b/test/shell/process-each-vgreduce.sh
@@ -11,6 +11,8 @@
 
 test_description='Exercise toollib process_each_pv with vgreduce'
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_devs 14
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 0c9f907..6b8bc6a 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -13,6 +13,7 @@
 # test thin profile functionality
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index b720710..037b306 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -13,6 +13,7 @@
 # test basic profile functionality
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
index 8e707fe..d3d1b53 100644
--- a/test/shell/pv-check-dev-size.sh
+++ b/test/shell/pv-check-dev-size.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index bb8cdb6..bd54f5f 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Test 'Found duplicate' is shown
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 02b5e72..9e78ae8 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -11,6 +11,7 @@
 
 # 'Exercise duplicate metadata diagnostics'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index 5b35aa4..cf2a8a1 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index f41b1ae..611fb3f 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index c775c56..37fd659 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -11,6 +11,8 @@
 
 # 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 2
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index ce44d84..efffe18 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -11,6 +11,7 @@
 
 # 'Test pvchange option values'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 8e84ac1..a7647d9 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test pvcreate bootloader area support'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index 8adb1ab..a259de7 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index 116a237..cfa98e1 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -15,6 +15,7 @@
 #
 # 'Test pvcreate without metadata on all pvs'
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 5a3c369..0e7835f 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index 9f451d5..e2895ad 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -8,6 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index 3474245..ac0469e 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 4
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 015f1e6..ef59639 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test pvcreate option values'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 PAGESIZE=$(getconf PAGESIZE)
 # MDA_SIZE_MIN defined in lib/format_text/layout.h
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index fcfcb2f..f18b863 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -11,6 +11,8 @@
 
 # Check pvmove --abort behaviour for all VGs and PVs
 
+SKIP_WITH_LVMLOCKD=1
+
 # Ignore known failure when clvmd is processing sequences of commands for two VGs in parallel - 2015/07/17 agk
 # CLVMD: ioctl/libdm-iface.c:1940   Internal error: Performing unsafe table load while 3 device(s) are known to be suspended:  (253:19) 
 export DM_ABORT_ON_INTERNAL_ERRORS=0
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index d32292d..b7e3105 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -11,6 +11,8 @@
 
 # Check pvmove --abort behaviour when specific device is requested
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_pvs 3 60
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 4ca64ab..e5f3b74 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -11,6 +11,8 @@
 
 test_description="ensure pvmove works with all common segment types"
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 which md5sum || skip
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index d979d37..000de1c 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -11,6 +11,8 @@
 
 # Check pvmove behavior when it's progress and machine is rebooted
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 3
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e1055aa..e228b34 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -12,6 +12,8 @@
 
 test_description="ensure that pvmove works with basic options"
 
+SKIP_WITH_LVMLOCKD=1
+
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 106c949..679997f 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description="ensure pvmove works with the cache segment types"
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 40683a4..78f5f3e 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description="ensure pvmove works with raid segment types"
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 5326d19..e06ca7e 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -11,6 +11,8 @@
 
 # Check pvmove behavior when it's progress and machine is rebooted
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_pvs 3 60
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 63a0ac4..8e4b6a7 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -14,6 +14,7 @@
 
 # 2 pvmove LVs in 2 VGs (1 per VG)
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index f9109ad..374f4ff 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -14,6 +14,7 @@
 
 # Moving 2 LVs in VG variant
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index da952ad..3898f5b 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -14,6 +14,7 @@
 
 # Multisegment variant w/ 2 pvmoves LVs per VG
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 8eac726..e8fa26b 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description="ensure pvmove works with thin segment types"
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 
 . lib/inittest
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 4df83ef..5ae0e0a 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -12,6 +12,7 @@
 # Checks we are not reading our own devices
 # https://bugzilla.redhat.com/show_bug.cgi?id=1064374
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 08c8b24..4fd26d1 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index 1085a3a..4fb5eba 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -8,6 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
index 96d0381..f7fdfc2 100644
--- a/test/shell/pvresize-mdas.sh
+++ b/test/shell/pvresize-mdas.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 5ce18ca..6e4bd35 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -14,6 +14,7 @@
 #
 
 test_description='Test read-ahead functionality'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
index ca1ecc0..5901198 100644
--- a/test/shell/report-fields.sh
+++ b/test/shell/report-fields.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_CLVMD=1
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index 80b11c9..2607444 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index 91712d5..b39ce54 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index 98e6e2f..b870191 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index f1a7ff8..3485f85 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index bf5cdaf..5567d53 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -11,6 +11,7 @@
 
 # no automatic extensions please
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
index 4accbfb..a4d5fb9 100644
--- a/test/shell/snapshot-cluster.sh
+++ b/test/shell/snapshot-cluster.sh
@@ -12,6 +12,7 @@
 # Testing renaming snapshots in cluster
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index ca7e81a..bc12113 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -12,6 +12,7 @@
 # regression test for lvmetad reporting error:
 # Internal error: LV snap_with_lvm1_meta (00000000000000000000000000000001) missing from preload metadata
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 672a8d6..e8e08b5 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -12,6 +12,7 @@
 # Testing calculation of snapshot space
 # https://bugzilla.redhat.com/show_bug.cgi?id=1035871
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index a76ed97..a301d22 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 # test if snapshot-merge target is available
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index ddaeaa2..5adf1f8 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -16,6 +16,7 @@
 # http://www.redhat.com/archives/dm-devel/2014-March/msg00005.html
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index e318a25..609df05 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -11,6 +11,7 @@
 
 # check if 'dmsetup --noflush' will work properly for mounted snapshot
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
index d5740c9..978debe 100644
--- a/test/shell/snapshot-rename.sh
+++ b/test/shell/snapshot-rename.sh
@@ -12,6 +12,7 @@
 # Testing renaming snapshots (had problem in cluster)
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index 4800397..edc1e50 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -12,6 +12,7 @@
 # Check very large device size (upto 15Exa bytes)
 # this needs 64bit arch
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index f501299..042b4bf 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -11,6 +11,7 @@
 
 # no automatic extensions please
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index b31461f..49cd476 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
+
 . lib/inittest
 
 aux prepare_vg 4
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index c2046a6..d4d9740 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 4d9c352..5d13547 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test system_id'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 551c561..3abf856 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index 0ee25cb..9e9366b 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -15,6 +15,7 @@
 #
 
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index d4485b5..dd0884e 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -11,6 +11,7 @@
 
 # no automatic extensions, just umount
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 32f23db..7e26bb7 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -11,6 +11,7 @@
 
 # test defaults entered through lvm.conf
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 95eafa0..966752a 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -11,6 +11,7 @@
 
 # test presence of various thin-pool/thin flags
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 198b14d..f044f57 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -11,6 +11,8 @@
 
 # test merge of thin snapshot
 
+SKIP_WITH_LVMLOCKD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
index 2c21f10..73accfe 100644
--- a/test/shell/thin-overprovisioning.sh
+++ b/test/shell/thin-overprovisioning.sh
@@ -11,6 +11,8 @@
 
 # Test warns when thin pool is overprovisiong
 
+SKIP_WITH_LVMLOCKD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index 6705879..047225b 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -11,6 +11,8 @@
 
 # ensure there is no data loss during thin-pool resize
 
+SKIP_WITH_LVMLOCKD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 3137f6f..270bae6 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -11,6 +11,7 @@
 
 # test restore operation of thin pool metadata
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 4cbbe69..e59636d 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -12,6 +12,8 @@
 # Test locking works and doesn't update metadata
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1063542
 
+SKIP_WITH_LVMLOCKD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index a5471ee..315353c 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -11,6 +11,7 @@
 
 # test pool behaviour when volume_list masks activation
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 145fe99..e8b1eae 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index db6f819..27cea88 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index f97f05b..f23b018 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index ac21772..be94406 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -6,6 +6,7 @@
 # of the GNU General Public License v.2.
 
 test_description='Test the vg name for an lv from env var'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index f785250..e763178 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 2c79176..f4fca78 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Check perfomance of activation and deactivation
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 1859e41..1509444 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index 782d0e7..4311b59 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 1d77b4d..4941ed6 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index a8faadc..9163741 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise some vgchange diagnostics'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 86e31ff..6092f12 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index 37df468..1052200 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index 4532624..5648675 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise some vgcreate diagnostics'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 08b3962..7346519 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 2ebddc2..18a7dce 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -13,6 +13,7 @@
 # Exercise various vgextend commands
 #
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 8d03d6e..b579e16 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 40d79ef..605d2c4 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test vgmerge operation'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index a2e6500..7369ad9 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # 'Test vgmerge command options for validity'
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 2f9e246..4ab60a7 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index dc54d3b..7feed2d 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index 156e226..4d325d9 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 62379a6..c052f97 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 1b335c5..d3c81d9 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -12,6 +12,7 @@
 # Test vgsplit operation, including different LV types
 
 # disable lvmetad logging as it bogs down test systems
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 29c7268..8db307c 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Test vgsplit operation, including different LV types
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index a7b319c..b09e336 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -9,6 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 266c230..6fc825d 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -11,6 +11,7 @@
 
 # Test vgsplit command options for validity
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index f2642a3..743a969 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -11,6 +11,7 @@
 
 # Test vgsplit command options for validity
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index c1c37e9..ee91bda 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -11,6 +11,7 @@
 
 # Basic usage of zero target
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest


