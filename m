From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:57 -0400
Subject: master - tests: enable lvmlockd for passing tests
Message-ID: <201805311414.w4VEEvu8031253@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=595196bc29e97cded7b4654db6824c5276f25eee
Commit:        595196bc29e97cded7b4654db6824c5276f25eee
Parent:        403c87c1aa7b759c95c0d3e86eb919229b4fc242
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 24 09:49:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: enable lvmlockd for passing tests

---
 test/lib/aux.sh                                    |    2 +-
 test/shell/000-basic.sh                            |    2 +-
 test/shell/activate-minor.sh                       |    2 +-
 test/shell/activate-missing-segment.sh             |    2 +-
 test/shell/activate-missing.sh                     |    2 +-
 test/shell/activate-partial.sh                     |    2 +-
 test/shell/activation-skip.sh                      |    2 +-
 test/shell/backup-read-only.sh                     |    2 +-
 test/shell/component-raid.sh                       |    2 +-
 test/shell/covercmd.sh                             |    4 +-
 test/shell/discards-thin.sh                        |    6 ++--
 test/shell/dmeventd-restart.sh                     |    2 +-
 test/shell/dmstats-create.sh                       |    2 +-
 test/shell/dmstats-report.sh                       |    2 +-
 test/shell/dumpconfig.sh                           |    2 +-
 test/shell/error-usage.sh                          |    2 +-
 test/shell/fsadm-crypt.sh                          |    2 +-
 test/shell/fsadm-renamed.sh                        |    2 +-
 test/shell/fsadm.sh                                |    2 +-
 test/shell/listings.sh                             |    9 +++----
 test/shell/lock-blocking.sh                        |    6 ++--
 test/shell/lock-parallel.sh                        |    2 +-
 test/shell/losetup-partscan.sh                     |    6 ++--
 test/shell/lv-ancestry.sh                          |    4 +-
 test/shell/lvchange-cache-syncaction-raid.sh       |    2 +-
 test/shell/lvchange-mirror.sh                      |    2 +-
 test/shell/lvchange-partial-raid10.sh              |    2 +-
 test/shell/lvchange-raid-transient-failures.sh     |    2 +-
 test/shell/lvchange-raid.sh                        |    2 +-
 test/shell/lvchange-raid1-writemostly.sh           |    2 +-
 test/shell/lvchange-rebuild-raid.sh                |    2 +-
 test/shell/lvchange-syncaction-raid.sh             |    2 +-
 test/shell/lvchange-thin.sh                        |    6 ++--
 test/shell/lvconvert-cache-chunks.sh               |    2 +-
 test/shell/lvconvert-m-raid1-degraded.sh           |    2 +-
 test/shell/lvconvert-mirror-basic.sh               |    2 +-
 test/shell/lvconvert-mirror-updown.sh              |    4 +-
 test/shell/lvconvert-mirror.sh                     |    4 +-
 test/shell/lvconvert-raid-regionsize.sh            |    2 +-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    1 -
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    2 +-
 test/shell/lvconvert-raid-takeover-thin.sh         |    2 +-
 test/shell/lvconvert-raid-takeover.sh              |    2 +-
 test/shell/lvconvert-raid.sh                       |    3 +-
 test/shell/lvconvert-raid0_to_raid10.sh            |    4 +-
 test/shell/lvconvert-raid10.sh                     |    4 +-
 test/shell/lvconvert-raid456.sh                    |    2 +-
 test/shell/lvconvert-repair-raid.sh                |    2 +-
 test/shell/lvconvert-repair-thin-raid.sh           |    2 +-
 test/shell/lvconvert-thin-raid.sh                  |    1 -
 test/shell/lvconvert-twostep.sh                    |    2 +-
 test/shell/lvcreate-cache-fail.sh                  |    4 +-
 test/shell/lvcreate-mirror.sh                      |    2 +-
 test/shell/lvcreate-missing.sh                     |    2 +-
 test/shell/lvcreate-operation.sh                   |    4 +-
 test/shell/lvcreate-raid-nosync.sh                 |    2 +-
 test/shell/lvcreate-raid-volume_list.sh            |    4 +-
 test/shell/lvcreate-raid.sh                        |    4 +-
 test/shell/lvcreate-raid10.sh                      |    2 +-
 test/shell/lvcreate-signature-wiping.sh            |    2 +-
 test/shell/lvcreate-small-snap.sh                  |    4 +-
 test/shell/lvcreate-striped-mirror.sh              |    2 +-
 test/shell/lvcreate-thin-big.sh                    |    4 +-
 test/shell/lvcreate-thin-external-size.sh          |    4 +-
 test/shell/lvcreate-thin-external.sh               |    4 +-
 test/shell/lvcreate-thin-power2.sh                 |    4 +-
 test/shell/lvcreate-thin-snap.sh                   |    4 +-
 test/shell/lvcreate-thin.sh                        |    4 +-
 test/shell/lvcreate-usage.sh                       |   10 ++++++--
 test/shell/lvextend-percent-extents.sh             |    4 +-
 test/shell/lvextend-snapshot-policy.sh             |    2 +-
 test/shell/lvextend-thin-data-dmeventd.sh          |    4 +-
 test/shell/lvextend-thin-raid.sh                   |    2 +-
 test/shell/lvextend-thin.sh                        |    2 +-
 test/shell/lvm-init.sh                             |    2 +-
 test/shell/lvmetad-pvs.sh                          |    2 +-
 test/shell/lvmlockd-hello-world.sh                 |    2 +-
 test/shell/lvrename-cache-thin.sh                  |    2 +-
 test/shell/lvresize-full.sh                        |    2 +-
 test/shell/lvresize-mirror.sh                      |    2 +-
 test/shell/lvresize-raid.sh                        |    4 +-
 test/shell/lvresize-raid10.sh                      |    2 +-
 test/shell/lvresize-rounding.sh                    |    6 ++--
 test/shell/lvresize-thin-metadata.sh               |    2 +-
 test/shell/lvresize-usage.sh                       |    2 +-
 test/shell/metadata-dirs.sh                        |   14 ++++++------
 test/shell/metadata.sh                             |    7 ++---
 test/shell/mirror-vgreduce-removemissing.sh        |    4 +-
 test/shell/name-mangling.sh                        |    2 +-
 test/shell/nomda-missing.sh                        |    4 +-
 test/shell/nomda-restoremissing.sh                 |    2 +-
 test/shell/orphan-ondisk.sh                        |    2 +-
 test/shell/pool-labels.sh                          |    2 +-
 test/shell/process-each-pv-nomda.sh                |    2 +-
 test/shell/process-each-pvresize.sh                |    8 +++---
 test/shell/process-each-vgreduce.sh                |   16 +++++++-------
 test/shell/profiles-thin.sh                        |    6 ++--
 test/shell/profiles.sh                             |    4 +-
 test/shell/pv-check-dev-size.sh                    |    8 +++---
 test/shell/pv-duplicate-uuid.sh                    |    2 +-
 test/shell/pv-ext-update.sh                        |    2 +-
 test/shell/pv-min-size.sh                          |    2 +-
 test/shell/pv-range-overflow.sh                    |    2 +-
 test/shell/pvchange-usage.sh                       |   10 ++++----
 test/shell/pvcreate-bootloaderarea.sh              |    4 +-
 test/shell/pvcreate-metadata0.sh                   |    4 +-
 test/shell/pvcreate-operation.sh                   |   16 +++++++-------
 test/shell/pvcreate-usage.sh                       |   18 ++++++++--------
 test/shell/pvremove-thin.sh                        |    2 +-
 test/shell/pvremove-usage.sh                       |    6 ++--
 test/shell/pvremove-warnings.sh                    |    4 +-
 test/shell/pvresize-mdas.sh                        |    2 +-
 test/shell/read-ahead.sh                           |    2 +-
 test/shell/relative-sign-options.sh                |    2 +-
 test/shell/report-fields.sh                        |    2 +-
 test/shell/report-hidden.sh                        |    2 +-
 test/shell/select-report.sh                        |    8 +++---
 test/shell/select-tools-thin.sh                    |    4 +-
 test/shell/select-tools.sh                         |    6 ++--
 test/shell/snapshot-autoumount-dmeventd.sh         |    2 +-
 test/shell/snapshot-cluster.sh                     |    2 +-
 test/shell/snapshot-maxsize.sh                     |    4 +-
 test/shell/snapshot-merge-stack.sh                 |    2 +-
 test/shell/snapshot-merge.sh                       |    2 +-
 test/shell/snapshot-reactivate.sh                  |    2 +-
 test/shell/snapshot-rename.sh                      |    2 +-
 test/shell/snapshots-of-mirrors.sh                 |    2 +-
 test/shell/stray-device-node.sh                    |    4 +-
 test/shell/system_id.sh                            |    2 +
 test/shell/tags.sh                                 |   16 +++++++-------
 test/shell/test-partition.sh                       |    2 +-
 test/shell/thin-autoumount-dmeventd.sh             |    2 +-
 test/shell/thin-defaults.sh                        |    2 +-
 test/shell/thin-dmeventd-warns.sh                  |    2 +-
 test/shell/thin-foreign-dmeventd.sh                |    2 +-
 test/shell/thin-merge.sh                           |    2 +-
 test/shell/thin-overprovisioning.sh                |    2 +-
 test/shell/thin-resize-match.sh                    |    2 +-
 test/shell/thin-restore.sh                         |    2 +-
 test/shell/thin-vglock.sh                          |    2 +-
 test/shell/thin-volume-list.sh                     |    2 +-
 test/shell/topology-support.sh                     |    8 +++---
 test/shell/unknown-segment.sh                      |    2 +-
 test/shell/vg-check-devs-used.sh                   |    4 +-
 test/shell/vg-name-from-env.sh                     |    6 ++--
 test/shell/vgcfgbackup-lvm1.sh                     |    4 +-
 test/shell/vgcfgbackup-usage.sh                    |    8 +++---
 test/shell/vgchange-many.sh                        |    4 +-
 test/shell/vgchange-maxlv.sh                       |    6 ++--
 test/shell/vgchange-partial.sh                     |    2 +-
 test/shell/vgchange-sysinit.sh                     |   10 ++++++--
 test/shell/vgck.sh                                 |    2 +-
 test/shell/vgcreate-many-pvs.sh                    |    6 ++--
 test/shell/vgextend-usage.sh                       |   22 ++++++++++----------
 test/shell/vgremove-corrupt-vg.sh                  |    2 +-
 test/shell/vgsplit-stacked.sh                      |    6 ++--
 test/shell/zero-usage.sh                           |    2 +-
 158 files changed, 294 insertions(+), 289 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b47ce1f..bd42f30 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1161,7 +1161,7 @@ prepare_vg() {
 	teardown_devs
 
 	prepare_devs "$@"
-	vgcreate -s 512K "$vg" "${DEVICES[@]}"
+	vgcreate $SHARED -s 512K "$vg" "${DEVICES[@]}"
 }
 
 extend_filter() {
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index c4a1f4a..1e511d1 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index e2db1c0..1b1ea8b 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 777a1bf..f066e58 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -17,7 +17,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 6b62115..c1c02d8 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -17,7 +17,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index be21d7c..70c50bc 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index 7aca44c..b0b3206 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/backup-read-only.sh b/test/shell/backup-read-only.sh
index f7033cb..331e846 100644
--- a/test/shell/backup-read-only.sh
+++ b/test/shell/backup-read-only.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/component-raid.sh b/test/shell/component-raid.sh
index 4ef9600..bff56d4 100644
--- a/test/shell/component-raid.sh
+++ b/test/shell/component-raid.sh
@@ -12,7 +12,7 @@
 
 # Exercise activation of raid component devices
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 711ca13..16b2e6c 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -15,7 +15,7 @@
 # to improve code coverage
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -29,7 +29,7 @@ pvcreate --metadatacopies 0 "$dev3"
 # FIXME takes very long time
 #pvck "$dev1"
 
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 lvcreate -aey -l 5 -n $lv1 $vg
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 92df211..f27d4c3 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -13,7 +13,7 @@
 # test support of thin discards
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -80,10 +80,10 @@ vgremove -ff $vg
 # device below does not support it, the kernel value
 # of discards actually used will be "nopassdown".
 # This is why we have "-o discards" and "-o kernel_discards".
-vgcreate -s 1m "${vg}_1" "${DEVICES[@]}"
+vgcreate $SHARED -s 1m "${vg}_1" "${DEVICES[@]}"
 lvcreate -l 10 -T ${vg}_1/pool --discards ignore
 lvcreate -V 9m -T ${vg}_1/pool -n device_with_ignored_discards
-vgcreate -s 1m ${vg}_2 "$DM_DEV_DIR/${vg}_1/device_with_ignored_discards"
+vgcreate $SHARED -s 1m ${vg}_2 "$DM_DEV_DIR/${vg}_1/device_with_ignored_discards"
 lvcreate -l 1 -T ${vg}_2/pool --discards passdown
 lvcreate -V 1 -T ${vg}_2/pool
 check lv_field ${vg}_1/pool discards "ignore"
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 58575fc..65f1655 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index 03406ae..e28c9ef 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index bd72f1a..965fca8 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index ae4028c..abd4b62 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index d75eacf..5950248 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -12,7 +12,7 @@
 
 # Basic usage of zero target
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 77bda35..d90413d 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise fsadm filesystem resize on crypt devices'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 # FIXME: cannot use brd (ramdisk)  - lsblk is NOT listing it
diff --git a/test/shell/fsadm-renamed.sh b/test/shell/fsadm-renamed.sh
index beec6be..3218939 100644
--- a/test/shell/fsadm-renamed.sh
+++ b/test/shell/fsadm-renamed.sh
@@ -11,7 +11,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise fsadm operation on renamed device'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 62eb7d3..fa9da35 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise fsadm filesystem resize'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 8de9490..0c614d0 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -14,7 +14,6 @@
 # tests functionality of lvs, pvs, vgs, *display tools
 #
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -40,7 +39,7 @@ pvdisplay
 #COMM pvs with segment attributes works even for orphans
 test "$(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all "${DEVICES[@]}" | wc -l)" -eq 5
 
-vgcreate $vg "${DEVICES[@]}"
+vgcreate $SHARED $vg "${DEVICES[@]}"
 
 check pv_field "$dev1" pv_uuid BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
 
@@ -202,17 +201,17 @@ vgremove -ff $vg
 # all LVs active - VG considered active
 pvcreate "$dev1" "$dev2" "$dev3"
 
-vgcreate $vg1 "$dev1"
+vgcreate $SHARED $vg1 "$dev1"
 lvcreate -l1 $vg1
 lvcreate -l1 $vg1
 
 # at least one LV active - VG considered active
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg2 "$dev2"
 lvcreate -l1 $vg2
 lvcreate -l1 -an -Zn $vg2
 
 # no LVs active - VG considered inactive
-vgcreate $vg3 "$dev3"
+vgcreate $SHARED $vg3 "$dev3"
 lvcreate -l1 -an -Zn $vg3
 lvcreate -l1 -an -Zn $vg3
 
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 85f7a10..5f69a1a 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='test some blocking / non-blocking multi-vg operations'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
@@ -19,7 +19,7 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 
 # if wait_for_locks set, vgremove should wait for orphan lock
 # flock process should have exited by the time first vgremove completes
@@ -33,7 +33,7 @@ test ! -f "$TESTDIR/var/lock/lvm/P_orphans"
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 flock -w 5 "$TESTDIR/var/lock/lvm/P_orphans" sleep 10 &
 
 while ! test -f "$TESTDIR/var/lock/lvm/P_orphans" ; do sleep .1 ; done
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 89fb397..5526b62 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -13,7 +13,7 @@
 # Test parallel use of lvm commands and check locks aren't dropped
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1049296
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/losetup-partscan.sh b/test/shell/losetup-partscan.sh
index df32b61..98b2677 100644
--- a/test/shell/losetup-partscan.sh
+++ b/test/shell/losetup-partscan.sh
@@ -12,7 +12,7 @@
 
 # Check how lvm2 handles partitions over losetup -P devices
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -37,7 +37,7 @@ aux extend_filter "a|$LOOP|"
 
 # creation should fail for 'partitioned' loop device
 not pvcreate -y "$LOOP"
-not vgcreate vg "$LOOP"
+not vgcreate $SHARED vg "$LOOP"
 
 aux teardown_devs
 
@@ -61,4 +61,4 @@ aux extend_filter "a|$LOOP|"
 # creation should pass for 'non-partitioned' loop device
 pvcreate -y "$LOOP"
 
-vgcreate vg "$LOOP"
+vgcreate $SHARED vg "$LOOP"
diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
index c36f366..b786d2e 100644
--- a/test/shell/lv-ancestry.sh
+++ b/test/shell/lv-ancestry.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
@@ -21,7 +21,7 @@ get_devs
 
 aux lvmconf "metadata/record_lvs_history=1"
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 lvcreate -l100%FREE -T ${vg}/pool
 
diff --git a/test/shell/lvchange-cache-syncaction-raid.sh b/test/shell/lvchange-cache-syncaction-raid.sh
index 206c750..bd4500d 100644
--- a/test/shell/lvchange-cache-syncaction-raid.sh
+++ b/test/shell/lvchange-cache-syncaction-raid.sh
@@ -12,7 +12,7 @@
 
 # test activation race for raid's --syncaction check
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 8120dbe..f21a0fa 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -12,7 +12,7 @@
 
 # FIXME RESYNC doesn't work in cluster with exclusive activation
 # seriously broken!
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index caec3a3..2c96108 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-raid-transient-failures.sh b/test/shell/lvchange-raid-transient-failures.sh
index 2ac14b0..35b4898 100644
--- a/test/shell/lvchange-raid-transient-failures.sh
+++ b/test/shell/lvchange-raid-transient-failures.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index e6626d1..1972a68 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 6e508c4..039429a 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 5579106..913a88d 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 84961ed..73270f0 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -12,7 +12,7 @@
 
 # test activation race for raid's --syncaction check
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 99215d9..992ed71 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -21,8 +21,8 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 3
 
-vgcreate -s 128k $vg  "$dev1" "$dev2"
-vgcreate -s 128k $vg2 "$dev3"
+vgcreate $SHARED -s 128k $vg  "$dev1" "$dev2"
+vgcreate $SHARED -s 128k $vg2 "$dev3"
 
 lvcreate -L10M -T $vg/pool
 
diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index 4046722..72a64de 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -13,7 +13,7 @@
 # Exercise number of cache chunks in cache pool
 # Skips creation of real cached device for older cache targets...
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-m-raid1-degraded.sh b/test/shell/lvconvert-m-raid1-degraded.sh
index f8a65d9..05c3e89 100644
--- a/test/shell/lvconvert-m-raid1-degraded.sh
+++ b/test/shell/lvconvert-m-raid1-degraded.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 06b3450..2378d48 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index d5059c2..fd7a45e 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -12,14 +12,14 @@
 
 # Demonstrate problem when upconverting and cutting leg in clvmd
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
 aux prepare_pvs 3 100
 get_devs
 
-vgcreate -s 64k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64k "$vg" "${DEVICES[@]}"
 
 # Use zero devices for big mirror legs
 aux zero_dev "$dev2" $(get first_extent_sector "$dev2"):
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 3fd4822..87993da 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
@@ -22,7 +22,7 @@ get_devs
 
 # proper DEVRANGE needs to be set according to extent size
 DEVRANGE="0-32"
-vgcreate -s 32k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 32k "$vg" "${DEVICES[@]}"
 
 # convert from linear to 2-way mirror ("mirror" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 893c158..cba04cc 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 0be8777..55d4c18 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 5230b2b..ed3769d 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
index e0e36cc..21d0511 100644
--- a/test/shell/lvconvert-raid-takeover-alloc-failure.sh
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-takeover-thin.sh b/test/shell/lvconvert-raid-takeover-thin.sh
index 580c1be..8bea244 100644
--- a/test/shell/lvconvert-raid-takeover-thin.sh
+++ b/test/shell/lvconvert-raid-takeover-thin.sh
@@ -13,7 +13,7 @@
 # check we may convert thin-pool to raid1/raid10 and back
 # RHBZ#1365286
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index c8591be..d1c5d30 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index c5e6159..ce60b6b 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -12,7 +12,6 @@
 
 # disable lvmetad logging as it bogs down test systems
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
@@ -36,7 +35,7 @@ aux prepare_pvs 9
 get_devs
 
 # vgcreate -s 256k "$vg" "${DEVICES[@]}"
-vgcreate -s 2m "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 2m "$vg" "${DEVICES[@]}"
 
 ###########################################
 # RAID1 convert tests
diff --git a/test/shell/lvconvert-raid0_to_raid10.sh b/test/shell/lvconvert-raid0_to_raid10.sh
index d1e1fa0..03c8d6d 100644
--- a/test/shell/lvconvert-raid0_to_raid10.sh
+++ b/test/shell/lvconvert-raid0_to_raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -22,7 +22,7 @@ aux have_raid 1 12 0 || skip
 # 8 PVs needed for RAID10 testing (4-stripes/2-mirror)
 aux prepare_pvs 8 64
 get_devs
-vgcreate -s 256k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 256k "$vg" "${DEVICES[@]}"
 
 lvcreate -y --ty raid0 -R32.00k -i 4 -n $lv1 -L 64M $vg
 lvcreate -y -i4 -l4 -n $lv2 $vg
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index e37d73a..c412935 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -34,7 +34,7 @@ aux have_raid 1 3 1 || skip
 aux prepare_pvs 9 80
 get_devs
 
-vgcreate -s 256k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 256k "$vg" "${DEVICES[@]}"
 
 lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 5797403..5198753 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index d29b72d..2f41760 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
index 3d89647..b97c5b4 100644
--- a/test/shell/lvconvert-repair-thin-raid.sh
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -12,7 +12,7 @@
 
 # Test repairing of broken thin pool on raid
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 8efafbc..c021e3b 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index cbdf862..44527f0 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/lvcreate-cache-fail.sh b/test/shell/lvcreate-cache-fail.sh
index dc7c53a..39a8273 100644
--- a/test/shell/lvcreate-cache-fail.sh
+++ b/test/shell/lvcreate-cache-fail.sh
@@ -13,7 +13,7 @@
 # Exercise creation of cache and cache pool volumes and failure path
 # https://bugzilla.redhat.com/1355923
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 aux have_cache 1 3 0 || skip
 
 #aux prepare_pvs 1 4707950
-#vgcreate $vg "$dev1"
+#vgcreate $SHARED $vg "$dev1"
 #lvcreate -L4T -n $lv1 $vg
 #lvcreate -H -L500G -n cache $vg/$lv1
 #fail lvcreate -H -l 127999 -n cache $vg/$lv1
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index e9ffd3e..0e9237d 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index fda62c6..18c979f 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 38d50cd..5faa39f 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -12,7 +12,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -27,7 +27,7 @@ aux prepare_pvs 2
 get_devs
 
 aux pvcreate --metadatacopies 0 "$dev1"
-aux vgcreate "$vg" "${DEVICES[@]}"
+aux vgcreate $SHARED "$vg" "${DEVICES[@]}"
 
 # ---
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index c0e23bb..dcc248e 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-raid-volume_list.sh b/test/shell/lvcreate-raid-volume_list.sh
index a47b961..052cf19 100644
--- a/test/shell/lvcreate-raid-volume_list.sh
+++ b/test/shell/lvcreate-raid-volume_list.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 # bz1161347 - When raid creation is aborted, left-over devices appear
@@ -24,7 +24,7 @@ aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 2 # 2 devices for RAID1
 get_devs
-vgcreate -s 512k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 512k "$vg" "${DEVICES[@]}"
 
 aux lvmconf "activation/volume_list = [ \"vg_not_exist\" ]"
 
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index f29e788..b605443 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -30,7 +30,7 @@ aux have_raid4 && RAID4=raid4
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 get_devs
 
-vgcreate -s 512k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 512k "$vg" "${DEVICES[@]}"
 
 ###########################################
 # Create, wait for sync, remove tests
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 4bb785d..39069af 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index d70d85a..73fea54 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -12,7 +12,7 @@
 
 # 'Exercise signature wiping during lvcreate'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index 08872fd..09237ec 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs
 get_devs
 
-vgcreate -s 4k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 4k "$vg" "${DEVICES[@]}"
 
 # 3 Chunks
 lvcreate -aey -n one -l 10 $vg
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index eb40bfa..b960522 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 46e017a..0625a59 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -13,7 +13,7 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -27,7 +27,7 @@ aux have_thin 1 0 0 || skip
 aux prepare_pvs 10 16500
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Size 0 is not valid
 invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index c744150..862dd15 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -12,7 +12,7 @@
 
 # Test unaligned size of external origin and thin pool chunk size
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -32,7 +32,7 @@ aux prepare_pvs 2 640
 get_devs
 
 # Use 8K extent size
-vgcreate -s 8K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 8K "$vg" "${DEVICES[@]}"
 
 # Prepare some numeric pattern with ~64K size
 seq -s ' ' -w 0 10922 > 64K
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index e94ffe3..20f0577 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -12,7 +12,7 @@
 
 # Test creation of thin snapshots using external origin
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -30,7 +30,7 @@ aux have_thin 1 3 0 || skip
 aux prepare_pvs 2 64
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Newer thin-pool target (>= 1.13) supports unaligned external origin
 # But this test is written to test and expect older behavior
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 18b2853..ec9755a 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -13,7 +13,7 @@
 # test support for non-power-of-2 thin chunk size
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -28,7 +28,7 @@ aux have_thin 1 4 0 || skip
 aux prepare_pvs 2 64
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # create non-power-of-2 pool
 lvcreate -l100 -c 192 -T $vg/pool
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index ac603d8..6e6410c 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -37,7 +37,7 @@ which mkfs.ext4 || skip
 aux prepare_pvs 2 64
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 27cce22..8e04c9e 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -13,7 +13,7 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -39,7 +39,7 @@ which mkfs.ext4 || skip
 aux prepare_pvs 2 64
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 # Create named pool only
 lvcreate -l1 -T $vg/pool1
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 4b5c2b6..6d42401 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -12,15 +12,13 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-SKIP_WITH_LVMLOCKD=1
-
 . lib/inittest
 
 aux prepare_pvs 4
 get_devs
 
 aux pvcreate --metadatacopies 0 "$dev1"
-aux vgcreate "$vg" "${DEVICES[@]}"
+aux vgcreate $SHARED "$vg" "${DEVICES[@]}"
 
 invalid lvcreate --type free -l1 -n $lv1 $vg 2>err
 grep "Invalid argument for --type" err
@@ -146,6 +144,10 @@ grep "Redundant" err
 check lv_field $vg/$lv1 segtype "linear"
 lvremove -ff $vg
 
+if test -n "$LVM_TEST_LVMLOCKD"; then
+echo "skip snapshot without origin"
+else
+
 # Old --type snapshot works with -s
 lvcreate --type snapshot -s -V64 -L32 -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "linear"
@@ -162,6 +164,8 @@ lvchange -a n $vg/$lv1
 lvremove -ff $vg/$lv1
 lvremove -ff $vg
 
+fi
+
 # readahead default (auto), none, #, auto
 lvcreate -L 8 -n $lv1 $vg
 check lv_field $vg/$lv1 lv_read_ahead "auto"
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index c737310..5d4946d 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -12,7 +12,7 @@
 
 # 'Check extents percentage arguments'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -20,7 +20,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2 128
 get_devs
 
-aux vgcreate "$vg" "${DEVICES[@]}"
+aux vgcreate $SHARED "$vg" "${DEVICES[@]}"
 
 lvcreate -L64 -n $lv $vg
 
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index 47def93..c49cbb3 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
index dce7e8c..7dfec4a 100644
--- a/test/shell/lvextend-thin-data-dmeventd.sh
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -12,7 +12,7 @@
 
 # Test autoextension of thin data volume
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -38,7 +38,7 @@ aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
 aux prepare_pvs 3 256
 get_devs
 
-vgcreate -s 256K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 256K "$vg" "${DEVICES[@]}"
 
 lvcreate -L1M -c 64k -T $vg/pool
 lvcreate -V1M $vg/pool -n $lv1
diff --git a/test/shell/lvextend-thin-raid.sh b/test/shell/lvextend-thin-raid.sh
index a623bb8..afbc630 100644
--- a/test/shell/lvextend-thin-raid.sh
+++ b/test/shell/lvextend-thin-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 82d8983..3e39ea3 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index 92e050b..7af3ef9 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -14,7 +14,7 @@
 # tests lvm initialization, and especially negative tests of error paths
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 4389528..dc4189d 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvmlockd-hello-world.sh b/test/shell/lvmlockd-hello-world.sh
index 194b997..43946a5 100644
--- a/test/shell/lvmlockd-hello-world.sh
+++ b/test/shell/lvmlockd-hello-world.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-test_description='Hello world for vgcreate with lvmlockd and sanlock'
+test_description='Hello world for vgcreate $SHARED with lvmlockd and sanlock'
 
 . lib/inittest
 
diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
index eb1b726..8e9bd78 100644
--- a/test/shell/lvrename-cache-thin.sh
+++ b/test/shell/lvrename-cache-thin.sh
@@ -12,7 +12,7 @@
 
 # Check rename of stacked  thin over cached LV
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index c497781..3cab522 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -13,7 +13,7 @@
 # Excersize resize of filesystem when size of LV already matches
 # https://bugzilla.redhat.com/1354396
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 8489b63..61e4491 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index fd210a0..4260de8 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -24,7 +24,7 @@ aux have_raid 1 7 0 && levels="0 0_meta $levels"
 aux prepare_pvs 6
 get_devs
 
-vgcreate -s 256K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 256K "$vg" "${DEVICES[@]}"
 
 for deactivate in true false; do
 
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index 5f400ac..e28b684 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 9a917ce..0cdce55 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 3 22
 get_devs
 
-vgcreate -s 32K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 32K "$vg" "${DEVICES[@]}"
 
 lvcreate -an -Zn -l4 -i3 -I64 $vg
 
@@ -55,7 +55,7 @@ check vg_field $vg vg_free_count 2
 lvreduce -f -l50%LV $vg/$lv1
 vgremove -f $vg
 
-vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED -s 4M $vg "$dev1" "$dev2" "$dev3"
 
 # Expect to play with 15 extents
 check vg_field $vg vg_free_count 15
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 54142ce..f27934b 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 23f73ae..a7e1544 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index d30e3c7..2a43340 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -19,30 +19,30 @@ aux prepare_devs 3
 get_devs
 
 pvcreate --metadatacopies 0 "${DEVICES[@]}"
-not vgcreate "$vg" "${DEVICES[@]}"
+not vgcreate $SHARED "$vg" "${DEVICES[@]}"
 
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
 
-vgcreate $vg "$dev1"
+vgcreate $SHARED $vg "$dev1"
 check vg_field $vg vg_mda_count 1
 vgremove -ff $vg
 
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 1
 vgremove -ff $vg
 
 pvcreate --metadatacopies 1 --metadataignore y "$dev1"
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
 
 pvcreate --metadatacopies 1 --metadataignore n "$dev1"
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
 
 pvcreate --metadatacopies 0 "$dev1"
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 9492bdc..aae749a 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -24,7 +23,7 @@ pvcreate --metadatacopies 0 "$dev3"
 pvcreate "$dev4"
 pvcreate --metadatacopies 0 "$dev5"
 
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
 pvchange -x n "$dev1"
@@ -38,7 +37,7 @@ vgremove -f $vg
 for mdacp in 1 0; do
 	pvcreate --metadatacopies "$mdacp" "${DEVICES[@]}"
 	pvcreate "$dev1"
-	vgcreate "$vg" "${DEVICES[@]}"
+	vgcreate $SHARED "$vg" "${DEVICES[@]}"
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -aey -n $lv2 --type mirror -m2 -l 2  $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
@@ -53,7 +52,7 @@ if test -n "$LVM_TEST_LVM1" ; then
 
 pvcreate -M1 "$dev1" "$dev2" "$dev3"
 pv3_uuid=$(get pv_field "$dev3" pv_uuid)
-vgcreate -M1 $vg "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED -M1 $vg "$dev1" "$dev2" "$dev3"
 pvchange --uuid "$dev1"
 
 # verify pe_start of all M1 PVs
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index c8f6411..69d9fe8 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -12,7 +12,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 # disable lvmetad logging as it bogs down test systems
@@ -104,7 +104,7 @@ rest_pvs_()
 aux prepare_pvs 5 80
 get_devs
 
-vgcreate -s 64k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64k "$vg" "${DEVICES[@]}"
 BLOCKS=0-7
 BLOCKS1=8-15
 # ---------------------------------------------------------------------
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 66c0aeb..8382ad1 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -12,7 +12,7 @@
 
 # This test is not using any lvm command
 # so skip duplicate CLMVD and lvmetad test
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index bb92fe7..dd57867 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3" "$dev4"
-vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 lvcreate -l1 -n linear1 $vg "$dev1"
 lvcreate -l1 -n linear2 $vg "$dev2"
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index a14f58d..fb3f930 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 4c8dabd..507b482 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index 7ae203d..3f9b942 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # lvmetad does not handle pool labels so skip test.
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 8f09129..2185ce4 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test process_each_pv with zero mda'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index 26b65d4..b2287b4 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise toollib process_each_pv'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -34,9 +34,9 @@ aux prepare_devs 14
 # dev1 matchines dev10,dev11,etc
 #
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
diff --git a/test/shell/process-each-vgreduce.sh b/test/shell/process-each-vgreduce.sh
index 3cec6c8..23584bf 100644
--- a/test/shell/process-each-vgreduce.sh
+++ b/test/shell/process-each-vgreduce.sh
@@ -12,7 +12,7 @@
 
 test_description='Exercise toollib process_each_pv with vgreduce'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -31,9 +31,9 @@ aux prepare_devs 14
 # dev1 matchines dev10,dev11,etc
 #
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
@@ -190,7 +190,7 @@ pvchange --addtag V2D45 "$dev5"
 not vgreduce -a $vg2
 # reset
 vgremove $vg2
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
 pvchange --addtag V2D45 "$dev4"
@@ -258,9 +258,9 @@ pvcreate "$dev14" --metadatacopies 0
 # dev12
 # dev13
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index df6fd73..40059be 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -13,7 +13,7 @@
 # test thin profile functionality
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -38,7 +38,7 @@ aux prepare_pvs 1 "$DEV_SIZE"
 SHOULD=""
 check sysfs "$dev1" queue/optimal_io_size "$EXPECT" || SHOULD=should
 
-vgcreate $vg "$dev1"
+vgcreate $SHARED $vg "$dev1"
 
 # By default, "generic" policy is used to
 # calculate chunk size which is 64KiB by default
@@ -68,7 +68,7 @@ fi
 
 # The profile must be also applied if using the profile
 # for the whole VG - any LVs inherit this profile then.
-vgcreate --profile thin-performance $vg "$dev1"
+vgcreate $SHARED --profile thin-performance $vg "$dev1"
 lvcreate -L8m -T $vg/pool_performance_inherited
 # ...the LV does not have the profile attached, but VG does!
 check vg_field $vg profile "thin-performance"
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index cecb6e8..be720c8 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -13,7 +13,7 @@
 # test basic profile functionality
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -100,7 +100,7 @@ not grep "$MSG_IGNORING_INVALID_MDA_PROFILE" msg
 # attaching/detaching profiles to VG/LV
 aux prepare_pvs 1 8
 pvcreate "$dev1"
-vgcreate $vg1 "$dev1"
+vgcreate $SHARED $vg1 "$dev1"
 check vg_field $vg1 vg_profile ""
 lvcreate -l 1 -n $lv1 $vg1
 check lv_field $vg1/$lv1 lv_profile ""
diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
index 58207c3..f9d31a1 100644
--- a/test/shell/pv-check-dev-size.sh
+++ b/test/shell/pv-check-dev-size.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -21,7 +21,7 @@ aux lvmconf 'metadata/check_pv_device_sizes = 1'
 
 CHECK_MSG="smaller than corresponding PV size"
 
-vgcreate "$vg" "$dev1" 2>err
+vgcreate $SHARED "$vg" "$dev1" 2>err
 not grep "$CHECK_MSG" err
 pvs 2>err
 not grep "$CHECK_MSG" err
@@ -29,7 +29,7 @@ vgremove -ff $vg
 
 # set PV size to 2x dev size
 pvcreate --yes --setphysicalvolumesize 16m "$dev1"
-vgcreate "$vg" "$dev1" 2>err
+vgcreate $SHARED "$vg" "$dev1" 2>err
 grep "$CHECK_MSG" err
 pvs 2>err
 grep "$CHECK_MSG" err
@@ -38,7 +38,7 @@ vgremove -ff $vg
 # should be quiet if requested
 aux lvmconf 'metadata/check_pv_device_sizes = 0'
 pvcreate --yes --setphysicalvolumesize 16m "$dev1"
-vgcreate "$vg" "$dev1" 2>err
+vgcreate $SHARED "$vg" "$dev1" 2>err
 not grep "$CHECK_MSG" err
 pvs 2>err
 not grep "$CHECK_MSG" err
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index 2c121d7..a076812 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Test 'Found duplicate' is shown
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-ext-update.sh b/test/shell/pv-ext-update.sh
index 44f301e..9059a22 100644
--- a/test/shell/pv-ext-update.sh
+++ b/test/shell/pv-ext-update.sh
@@ -12,7 +12,7 @@
 
 # lvmetad does not handle pool labels so skip test.
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index 3d3d5e9..574dce7 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index 08401db..f880a13 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -12,7 +12,7 @@
 
 # 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 383986e..1f1348d 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -12,7 +12,7 @@
 
 # 'Test pvchange option values'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -26,7 +26,7 @@ aux prepare_pvs 4
 # check 'allocatable' pv attribute
 pvcreate "$dev1"
 check pv_field "$dev1" pv_attr ---
-vgcreate $vg1 "$dev1"
+vgcreate $SHARED $vg1 "$dev1"
 check pv_field "$dev1" pv_attr a--
 pvchange --allocatable n "$dev1"
 check pv_field "$dev1" pv_attr u--
@@ -41,7 +41,7 @@ do
 # cannot change allocatability for orphan PVs
 	fail pvchange "$dev1" -x y
 	fail pvchange "$dev1" -x n
-	vgcreate $vg1 "$dev4" "$dev1"
+	vgcreate $SHARED $vg1 "$dev4" "$dev1"
 
 # "pvchange adds/dels tag to pvs with metadatacopies = $mda "
 	pvchange "$dev1" --addtag test$mda
@@ -72,7 +72,7 @@ done
 # "pvchange uuid"
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate --metadatacopies 2 "$dev2"
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 
 # Checking for different UUID after pvchange
 UUID1=$(get pv_field "$dev1" uuid)
@@ -117,7 +117,7 @@ fail pvchange "$dev1" --deltag test
 if test -n "$LVM_TEST_LVM1" ; then
 # cannot add PV tag to lvm1 format
 pvcreate -M1 "$dev1"
-vgcreate -M1 $vg1 "$dev1"
+vgcreate $SHARED -M1 $vg1 "$dev1"
 fail pvchange "$dev1" --addtag test
 fi
 
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index f9e0929..2e16a5f 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test pvcreate bootloader area support'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -45,7 +45,7 @@ grep "Bootloader area with data-aligned start must not exceed device size" err
 # restoring the PV should also restore the bootloader area correctly
 pvremove -ff "$dev1"
 pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
-vgcreate $vg "$dev1"
+vgcreate $SHARED $vg "$dev1"
 vgcfgbackup -f "$TESTDIR/vg_with_ba_backup" "$vg"
 pv_uuid=$(get pv_field "$dev1" pv_uuid)
 vgremove -ff $vg
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index ce29a5f..c732a2e 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -16,7 +16,7 @@
 #
 # 'Test pvcreate without metadata on all pvs'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -28,7 +28,7 @@ pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 
 # "check lv snapshot"
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 lvcreate -aey -n $lv -l 60%FREE $vg
 lvcreate -s -n $lv2 -l 10%FREE $vg/$lv
 vgremove -f $vg
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index af1c5a2..c449438 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -46,7 +46,7 @@ do
 
 # pvcreate (lvm$mdatype) fails when PV belongs to VG
 #   pvcreate -M$mdatype "$dev1"
-    vgcreate -M$mdatype $vg1 "$dev1"
+    vgcreate $SHARED -M$mdatype $vg1 "$dev1"
     not pvcreate -M$mdatype "$dev1"
 
     vgremove -f $vg1
@@ -55,7 +55,7 @@ do
 # pvcreate (lvm$mdatype) fails when PV1 does and PV2 does not belong to VG
     pvcreate -M$mdatype "$dev1"
     pvcreate -M$mdatype "$dev2"
-    vgcreate -M$mdatype $vg1 "$dev1"
+    vgcreate $SHARED -M$mdatype $vg1 "$dev1"
 
 # pvcreate a second time on $dev2 and $dev1
     not pvcreate -M$mdatype "$dev2" "$dev1"
@@ -77,7 +77,7 @@ done
 # pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate --metadatacopies 1 "$dev2"
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 not pvcreate "$dev1"
 vgremove -f $vg1
 pvremove -f "$dev2" "$dev1"
@@ -85,7 +85,7 @@ pvremove -f "$dev2" "$dev1"
 # pvcreate (lvm2) succeeds with -ff when PV with metadatacopies=0 belongs to VG
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate --metadatacopies 1 "$dev2"
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 pvcreate -ff -y "$dev1"
 vgreduce --removemissing $vg1
 vgremove -ff $vg1
@@ -129,7 +129,7 @@ not pvcreate --uuid $uuid2 --restorefile "$backupfile" "$dev2"
 # (use case: one PV in a VG used solely to keep metadata)
 size_mb=$(($(blockdev --getsz "$dev1") / 2048))
 pvcreate --metadatasize $size_mb "$dev1"
-vgcreate $vg1 "$dev1"
+vgcreate $SHARED $vg1 "$dev1"
 vgcfgbackup -f "$backupfile"
 vgcfgrestore -f "$backupfile" "$vg1"
 vgremove -f $vg1
@@ -139,7 +139,7 @@ pvremove -f "$dev1"
 # and check it's compatible with pe_start value being restored
 # X * dataalignment + dataalignmentoffset == pe_start
 pvcreate --norestorefile --uuid "$uuid1" --dataalignment 600k --dataalignmentoffset 32k "$dev1"
-vgcreate $vg1 "$dev1"
+vgcreate $SHARED $vg1 "$dev1"
 vgcfgbackup -f "$backupfile" "$vg1"
 vgremove -ff $vg1
 pvremove -ff "$dev1"
@@ -169,7 +169,7 @@ grep -- "Command does not accept option combination: --bootloaderareasize  with
 rm -f "$backupfile"
 
 pvcreate --norestorefile --uuid $uuid1 "$dev1"
-vgcreate --physicalextentsize 1m $vg1 "$dev1"
+vgcreate $SHARED --physicalextentsize 1m $vg1 "$dev1"
 vgcfgbackup -f "$backupfile" "$vg1"
 vgremove -ff "$vg1"
 pvremove -ff "$dev1"
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index f0e6ee6..4ece05f 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test pvcreate option values'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 PAGESIZE=$(getconf PAGESIZE)
 # MDA_SIZE_MIN defined in lib/format_text/layout.h
@@ -45,7 +45,7 @@ pvremove "$dev1"
 #Verify vg_mda_size is smaller pv_mda_size
 pvcreate --metadatasize 512k "$dev1"
 pvcreate --metadatasize 96k "$dev2"
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 pvs -o +pv_mda_size
 check compare_fields vgs $vg vg_mda_size pvs "$dev2" pv_mda_size
 vgremove $vg
@@ -108,8 +108,8 @@ fi
 pvcreate --dataalignment 512k "$dev1"
 check pv_field "$dev1" pe_start "512.00k"
 
-#COMM 'vgcreate/vgremove do not modify data offset of existing PV'
-vgcreate $vg "$dev1"  --config 'devices { data_alignment = 1024 }'
+#COMM 'vgcreate $SHARED/vgremove do not modify data offset of existing PV'
+vgcreate $SHARED $vg "$dev1"  --config 'devices { data_alignment = 1024 }'
 check pv_field "$dev1" pe_start "512.00k"
 vgremove $vg --config 'devices { data_alignment = 1024 }'
 check pv_field "$dev1" pe_start "512.00k"
@@ -147,7 +147,7 @@ check pv_field "$dev1" pv_mda_count 2
 #compatible == LVM1_PE_ALIGN == 64k
 if test -n "$LVM_TEST_LVM1" ; then
 pvcreate --dataalignment 256k "$dev1"
-vgcreate -s 1m $vg "$dev1"
+vgcreate $SHARED -s 1m $vg "$dev1"
 vgconvert -M1 $vg
 vgconvert -M2 $vg
 check pv_field "$dev1" pe_start 256.00k
@@ -157,7 +157,7 @@ fi
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
 if test -n "$LVM_TEST_LVM1" ; then
 pvcreate --dataalignment 10k "$dev1"
-vgcreate -s 1m $vg "$dev1"
+vgcreate $SHARED -s 1m $vg "$dev1"
 not vgconvert -M1 $vg
 vgremove $vg
 fi
@@ -167,7 +167,7 @@ fi
 #not that final cfg is usable...
 pvcreate --metadatacopies 0 "$dev1"
 pvcreate "$dev2"
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 vgcfgbackup -f backup.$$ $vg
 sed 's/pe_start = [0-9]*/pe_start = 0/' backup.$$ > backup.$$1
 vgcfgrestore -f backup.$$1 $vg
@@ -190,9 +190,9 @@ for ignore in y n; do
 		check pv_field "$dev1" pv_mda_used_count "$mdacp"
 		check pv_field "$dev2" pv_mda_used_count "$mdacp"
 	fi
-	echo "vgcreate has proper vg_mda_count and vg_mda_used_count"
+	echo "vgcreate $SHARED has proper vg_mda_count and vg_mda_used_count"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate $vg "$dev1" "$dev2"
+		vgcreate $SHARED $vg "$dev1" "$dev2"
 		check vg_field $vg vg_mda_count $(( mdacp * 2 ))
 		if [ $ignore = y ]; then
 			check vg_field $vg vg_mda_used_count "1"
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 9bb9d44..9859b6c 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -13,7 +13,7 @@
 # Checks we are not reading our own devices
 # https://bugzilla.redhat.com/show_bug.cgi?id=1064374
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index be51ce1..17d90e6 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -34,7 +34,7 @@ pvs -a -o+devices
 pvcreate  --metadatacopies 0 "$dev2"
 
 # check pvremove refuses to remove pv in a vg
-vgcreate $vg "$dev1" "$dev2"
+vgcreate $SHARED $vg "$dev1" "$dev2"
 not pvremove "$dev2" "$dev3"
 
 for mdacp in 0 1 2; do
@@ -53,7 +53,7 @@ for mdacp in 0 1 2; do
     vgremove -ff $vg
     pvcreate --metadatacopies $mdacp "$dev1"
     pvcreate "$dev2"
-    vgcreate $vg "$dev1" "$dev2"
+    vgcreate $SHARED $vg "$dev1" "$dev2"
 
     # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
     not pvremove -f "$dev1" 2>&1 | tee out
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index 57a376c..dc3178d 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -21,6 +21,6 @@ pvremove "$dev1" "$dev2" 2>&1 | tee pvremove.txt
 not grep "No physical" pvremove.txt
 
 pvcreate "$dev1" "$dev2"
-vgcreate bla "$dev1" "$dev2"
+vgcreate $SHARED bla "$dev1" "$dev2"
 pvremove -ff -y "$dev1" "$dev2" 2>&1 | tee pvremove.txt
 not grep "device missing" pvremove.txt
diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
index 3bed8bc..da4119c 100644
--- a/test/shell/pvresize-mdas.sh
+++ b/test/shell/pvresize-mdas.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 9045de8..60e5912 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -15,7 +15,7 @@
 #
 
 test_description='Test read-ahead functionality'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 2a36f1f..82a5ed2 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -12,7 +12,7 @@
 
 test_description='Exercise toollib process_each_lv'
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
index 0473a33..8260610 100644
--- a/test/shell/report-fields.sh
+++ b/test/shell/report-fields.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_CLVMD=1
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index fb70e60..24a11c8 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMETAD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index b879bf5..f404be5 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -23,9 +23,9 @@ aux prepare_pvs 6 16
 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
 # create $VGS with assorted tags
-vgcreate $vg1 --vgmetadatacopies 2 --addtag "vg_tag3" --addtag "vg_tag2" -s 4m "$dev1" "$dev2" "$dev3"
-vgcreate $vg2 --addtag "vg_tag2" -s 4m "$dev4" "$dev5"
-vgcreate $vg3 --addtag "vg_tag1" -s 4m "$dev6"
+vgcreate $SHARED $vg1 --vgmetadatacopies 2 --addtag "vg_tag3" --addtag "vg_tag2" -s 4m "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED $vg2 --addtag "vg_tag2" -s 4m "$dev4" "$dev5"
+vgcreate $SHARED $vg3 --addtag "vg_tag1" -s 4m "$dev6"
 
 # add PV assorted tags
 pvchange --addtag "pv_tag3" --addtag "pv_tag1" --addtag "pv_tag2" "$dev1"
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index aa43ef3..8fbe1b3 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -30,7 +30,7 @@ aux prepare_pvs 1 16
 # selecting on initial state (here, thin origin LV thin_orig is removed
 # first, but thin snap should be still selectable based on origin=thin_orig
 # condition even though thin_orig has just been removed)
-vgcreate -s 4m $vg1 "$dev1"
+vgcreate $SHARED -s 4m $vg1 "$dev1"
 lvcreate -l100%FREE -T $vg1/pool
 lvcreate -V4m -T $vg1/pool -n thin_orig
 lvcreate -s $vg1/thin_orig -n thin_snap
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index e0ceccc..0ca633c 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -10,15 +10,15 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
 aux prepare_pvs 4 12
 
-vgcreate -s 4m $vg1 "$dev1" "$dev2"
-vgcreate -s 4m $vg2 "$dev3" "$dev4"
+vgcreate $SHARED -s 4m $vg1 "$dev1" "$dev2"
+vgcreate $SHARED -s 4m $vg2 "$dev3" "$dev4"
 
 # vg1/lv1 mapped onto dev1
 lvcreate -l1 -n "lv1" $vg1 "$dev1"
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index e2702bb..7967e86 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -12,7 +12,7 @@
 
 # no automatic extensions please
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
index d6459d8..e6c9ab3 100644
--- a/test/shell/snapshot-cluster.sh
+++ b/test/shell/snapshot-cluster.sh
@@ -13,7 +13,7 @@
 # Testing renaming snapshots in cluster
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 9a1f4d7..9427566 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -13,7 +13,7 @@
 # Testing calculation of snapshot space
 # https://bugzilla.redhat.com/show_bug.cgi?id=1035871
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 1
 get_devs
 
-vgcreate -s 4K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 4K "$vg" "${DEVICES[@]}"
 
 lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index fe20865..b6763ca 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -12,7 +12,7 @@
 
 # Exercise snapshot merge also when stacked
 
-SKIP_WITH_LVMLOCKD=1
+
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 41e7b00..a50ffdc 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index fb6973a..4138e6e 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -17,7 +17,7 @@
 # http://www.redhat.com/archives/dm-devel/2014-March/msg00005.html
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
index a7eb54c..e8d77a3 100644
--- a/test/shell/snapshot-rename.sh
+++ b/test/shell/snapshot-rename.sh
@@ -13,7 +13,7 @@
 # Testing renaming snapshots (had problem in cluster)
 # https://bugzilla.redhat.com/show_bug.cgi?id=1136925
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index 7e3f736..48cadc5 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 2467a47..7ed2293 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -20,7 +20,7 @@ get_devs
 
 cp -r "$dev1" "$DM_DEV_DIR/stray"
 
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 aux disable_dev "$dev1"
 # FIXME:
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index b7e61a9..21c5bd0 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -11,6 +11,8 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Test system_id'
+
+# test does not apply to lvmlockd
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 2d8731e..fd1b332 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -10,23 +10,23 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
 aux prepare_pvs 4
 
-# vgcreate with --addtag
-vgcreate --addtag firstvg $vg1 "$dev1" "$dev2"
-vgcreate --addtag secondvg $vg2 "$dev3" "$dev4"
+# vgcreate $SHARED with --addtag
+vgcreate $SHARED --addtag firstvg $vg1 "$dev1" "$dev2"
+vgcreate $SHARED --addtag secondvg $vg2 "$dev3" "$dev4"
 check vg_field $vg1 tags "firstvg"
 check vg_field $vg2 tags "secondvg"
 vgremove -f $vg1 $vg2
 
 # vgchange with --addtag and --deltag
-vgcreate $vg1 "$dev1" "$dev2"
-vgcreate $vg2 "$dev3" "$dev4"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg2 "$dev3" "$dev4"
 vgchange --addtag firstvgtag1 $vg1
 # adding a tag multiple times is not an error
 vgchange --addtag firstvgtag2 $vg1
@@ -45,7 +45,7 @@ vgchange --deltag firstvgtag1 $vg2
 vgremove -f $vg1 $vg2
 
 # lvcreate with --addtag
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 lvcreate --addtag firstlvtag1 -l 4 -n $lv1 $vg1
 lvcreate --addtag secondlvtag1 -l 4 -n $lv2 $vg1
 check lv_field @firstlvtag1 tags "firstlvtag1"
@@ -55,7 +55,7 @@ not check lv_field $vg1/$lv1 tags "secondlvtag1"
 vgremove -f $vg1
 
 # lvchange with --addtag and --deltag
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv2 $vg1
 lvchange --addtag firstlvtag1 $vg1/$lv1
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index bcbf9f1..083cd98 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -16,7 +16,7 @@
 #
 
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index cee2f4c..7244333 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -12,7 +12,7 @@
 
 # no automatic extensions, just umount
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 89c0fa4..3f2db20 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -12,7 +12,7 @@
 
 # test defaults entered through lvm.conf
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index d874102..a8002ae 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -12,7 +12,7 @@
 
 # test if dmeventd produces multiple warnings when pools runs above 80%
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMETAD=1
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index 4e373ad..561cea8 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -12,7 +12,7 @@
 
 # test foreing user of thin-pool
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 457bd47..c0a022c 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -12,7 +12,7 @@
 
 # test merge of thin snapshot
 
-SKIP_WITH_LVMLOCKD=1
+
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
index 85d8577..d4ab63d 100644
--- a/test/shell/thin-overprovisioning.sh
+++ b/test/shell/thin-overprovisioning.sh
@@ -12,7 +12,7 @@
 
 # Test warns when thin pool is overprovisiong
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index 3bbf334..dda5573 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -12,7 +12,7 @@
 
 # ensure there is no data loss during thin-pool resize
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index afcbd7f..3682a8c 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -12,7 +12,7 @@
 
 # test restore operation of thin pool metadata
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 9664e30..b48ef25 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -13,7 +13,7 @@
 # Test locking works and doesn't update metadata
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1063542
 
-SKIP_WITH_LVMLOCKD=1
+
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index f4fb0a3..6caa720 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -12,7 +12,7 @@
 
 # test pool behaviour when volume_list masks activation
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 482205a..f8526ad 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -62,7 +62,7 @@ check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$LOGICAL_BLOCK_SIZE"
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 get_devs
 
-vgcreate $vg "${DEVICES[@]}"
+vgcreate $SHARED $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
@@ -77,7 +77,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate $vg "${DEVICES[@]}"
+vgcreate $SHARED $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
@@ -92,7 +92,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate $vg "${DEVICES[@]}"
+vgcreate $SHARED $vg "${DEVICES[@]}"
 test_snapshot_mount
 vgremove $vg
 
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index 42f1fd3..ef66447 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 9b99ef7..f62799e 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
@@ -20,7 +20,7 @@ aux driver_at_least 4 15 || skip
 
 aux prepare_devs 3 8
 
-vgcreate "$vg" "$dev1" "$dev2"
+vgcreate $SHARED "$vg" "$dev1" "$dev2"
 lvcreate -l100%FREE -n $lv $vg
 dd if="$dev1" of="$dev3" bs=1M
 pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index 9ba6b45..48e471c 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -7,7 +7,7 @@
 # of the GNU General Public License v.2.
 
 test_description='Test the vg name for an lv from env var'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -17,8 +17,8 @@ aux prepare_devs 2
 pvcreate "$dev1"
 pvcreate "$dev2"
 
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg1 "$dev1"
+vgcreate $SHARED $vg2 "$dev2"
 
 export LVM_VG_NAME=$vg1
 
diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
index e9738e8..a148ec1 100644
--- a/test/shell/vgcfgbackup-lvm1.sh
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -28,7 +28,7 @@ aux lvmconf "backup/backup = 0"
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
 
 pvcreate -M1 "${DEVICES[@]}"
-vgcreate -M1 -c n "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -M1 -c n "$vg" "${DEVICES[@]}"
 lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index c506a14..801f9ce 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -26,8 +26,8 @@ aux lvmconf "backup/backup = 0"
 # vgcfgbackup handles similar VG names (bz458941)
 vg1=${PREFIX}vg00
 vg2=${PREFIX}vg01
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg1 "$dev1"
+vgcreate $SHARED $vg2 "$dev2"
 
 # Enforces system backup
 test ! -e etc/backup/$vg1
@@ -58,7 +58,7 @@ vgremove -ff $vg1 $vg2
 # and vgcfgrestore able to restore them when device reappears
 pv1_uuid=$(get pv_field "$dev1" pv_uuid)
 pv2_uuid=$(get pv_field "$dev2" pv_uuid)
-vgcreate "$vg" "${DEVICES[@]}"
+vgcreate $SHARED "$vg" "${DEVICES[@]}"
 lvcreate -l1 -n $lv1 $vg "$dev1"
 lvcreate -l1 -n $lv2 $vg "$dev2"
 lvcreate -l1 -n $lv3 $vg "$dev3"
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 95bc868..debfdc4 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Check perfomance of activation and deactivation
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -26,7 +26,7 @@ test "$(aux total_mem)" -gt 524288 || TEST_DEVS=256
 aux prepare_pvs 1 400
 get_devs
 
-vgcreate -s 128K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 128K "$vg" "${DEVICES[@]}"
 
 vgcfgbackup -f data $vg
 
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 987fa9e..626128e 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -19,13 +19,13 @@ aux prepare_dmeventd
 aux prepare_pvs 3
 get_devs
 
-vgcreate -l 2 "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -l 2 "$vg" "${DEVICES[@]}"
 lvcreate -aey -n one -l 1 $vg
 lvcreate -n two -l 1 $vg
 not lvcreate -n three -l 1 $vg
 vgremove -ff $vg
 
-vgcreate -l 3 "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -l 3 "$vg" "${DEVICES[@]}"
 lvcreate -aey -n one -l 1 $vg
 lvcreate -n snap -s -l 1 $vg/one
 lvcreate -n two -l 1 $vg
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index b77ad1a..5f5920f 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index ec0a6cd..cea72f4 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_CLVMD=1
 SKIP_WITH_LVMPOLLD=1
 
@@ -30,8 +29,8 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg1 "$dev1"
+vgcreate $SHARED $vg2 "$dev2"
 
 lvcreate -l 1 -n $lv2 $vg2
 vgchange -an $vg2
@@ -54,7 +53,12 @@ test ! -b "$DM_DEV_DIR/$vg2/$lv2"
 
 vgchange --ignorelockingfailure -ay $vg2
 
+if test -n "$LVM_TEST_LVMLOCKD"; then
+vgremove --config 'global{locking_type=0}' -ff $vg2
+else
 # TODO maybe also support --ignorelockingfailure ??
 vgremove --config 'global{locking_type=0}' -ff $vg2
+fi
+
 umount "$mount_dir" || true
 vgremove -ff $vg1
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 186704c..c9d29bb 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index a75b3f3..9598f91 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -40,7 +40,7 @@ SKIP_WITH_LVMPOLLD=1
 LVM_TEST_PVS=${LVM_TEST_PVS:-100}
 
 #aux prepare_devs $LVM_TEST_PVS 8
-#vgcreate $vg $(< DEVICES)
+#vgcreate $SHARED $vg $(< DEVICES)
 
 # prepare_vg is now directly using steps above
 aux prepare_vg $LVM_TEST_PVS
@@ -62,5 +62,5 @@ vgremove -ff $vg
 # TODO Turn this into another test case:
 #
 #for i in $(seq 1 $LVM_TEST_PVS); do
-#	vgcreate ${vg}$i "$DM_DEV_DIR/mapper/${PREFIX}pv$i"
+#	vgcreate $SHARED ${vg}$i "$DM_DEV_DIR/mapper/${PREFIX}pv$i"
 #done
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 178df4d..3d5adfd 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -14,7 +14,7 @@
 # Exercise various vgextend commands
 #
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -32,30 +32,30 @@ do
 
 # Explicit pvcreate
 pvcreate -M$mdatype "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2"
 vgextend $vg1 "$dev3" "$dev4" "$dev5"
 vgremove -ff $vg1
 
 # Implicit pvcreate
 pvremove "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
+vgcreate $SHARED -M$mdatype $vg1 "$dev1" "$dev2"
 vgextend -M$mdatype $vg1 "$dev3" "$dev4" "$dev5"
 vgremove -ff $vg1
 pvremove "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
 done
 
-# Implicit pvcreate tests, test pvcreate options on vgcreate
+# Implicit pvcreate tests, test pvcreate options on vgcreate $SHARED
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
-vgcreate $vg "$dev2"
+vgcreate $SHARED $vg "$dev2"
 vgextend --force --yes --zero y $vg "$dev1"
 vgreduce $vg "$dev1"
 pvremove -f "$dev1"
 
 for i in 0 1 2 3
 do
-# vgcreate (lvm2) succeeds writing LVM label at sector $i
+# vgcreate $SHARED (lvm2) succeeds writing LVM label@sector $i
     vgextend --labelsector $i $vg "$dev1"
     dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgreduce $vg "$dev1"
@@ -87,15 +87,15 @@ vgremove -f $vg
 pvremove -f "$dev1"
 
 # vgextend fails if pv belongs to existing vg
-vgcreate $vg1 "$dev1" "$dev3"
-vgcreate $vg2 "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev3"
+vgcreate $SHARED $vg2 "$dev2"
 not vgextend $vg2 "$dev3"
 vgremove -f $vg1
 vgremove -f $vg2
 pvremove -f "$dev1" "$dev2" "$dev3"
 
 #vgextend fails if vg is not resizeable
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 vgchange --resizeable n $vg1
 not vgextend $vg1 "$dev3"
 vgremove -f $vg1
@@ -103,7 +103,7 @@ pvremove -f "$dev1" "$dev2"
 
 # all PVs exist in the VG after extended
 pvcreate "$dev1"
-vgcreate $vg1 "$dev2"
+vgcreate $SHARED $vg1 "$dev2"
 vgextend $vg1 "$dev1" "$dev3"
 check pv_field "$dev1" vg_name $vg1
 check pv_field "$dev2" vg_name $vg1
@@ -115,7 +115,7 @@ echo test vgextend --metadataignore
 for mdacp in 1 2; do
 for ignore in y n; do
 	echo vgextend --metadataignore has proper mda_count and mda_used_count
-	vgcreate $vg "$dev3"
+	vgcreate $SHARED $vg "$dev3"
 	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg "$dev1" "$dev2"
 	check pv_field "$dev1" pv_mda_count $mdacp
 	check pv_field "$dev2" pv_mda_count $mdacp
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index edc911b..1de77e4 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 1388e91..331ee8e 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -18,12 +18,12 @@ SKIP_WITH_LVMPOLLD=1
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
 
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 100%FREE $vg1
 
 #top VG
 pvcreate "$DM_DEV_DIR/$vg1/$lv1"
-vgcreate $vg "$DM_DEV_DIR/$vg1/$lv1" "$dev3"
+vgcreate $SHARED $vg "$DM_DEV_DIR/$vg1/$lv1" "$dev3"
 
 vgchange -a n $vg $vg1
 
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index 68afaaf..53ffbe4 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -11,7 +11,7 @@
 
 # Basic usage of zero target
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest


