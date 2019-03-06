From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Mar 2019 13:18:49 -0500
Subject: master - tests: check that pvscan --cache ignores certain PVs
Message-ID: <201903061818.x26IInLe015272@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98b7a3a42dd3adc13b87233846ae2e8e1f6b4bb0
Commit:        98b7a3a42dd3adc13b87233846ae2e8e1f6b4bb0
Parent:        4e20ebd6a1b993b1f04aa13f55b9c5d8ca2ff287
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 6 12:17:47 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 6 12:17:47 2019 -0600

tests: check that pvscan --cache ignores certain PVs

---
 test/shell/lvmlockd-lv-types.sh   |   14 ++++++++++++++
 test/shell/pvscan-autoactivate.sh |   37 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index b82f21b..44ff532 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -39,6 +39,20 @@ aux prepare_devs 5
 vgcreate --shared $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 
 #
+# pvscan autoactivation ignore shared PVs
+#
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+
+PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+pvscan --cache -aay "$dev1"
+not ls "$RUNDIR/lvm/pvs_online/$PVID1"
+pvscan --cache -aay
+not ls "$RUNDIR/lvm/pvs_online/$PVID1"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
+
+
+#
 # thin pool, thin lv, thin snap
 #
 
diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 419fb9b..20a0eeb 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -27,7 +27,7 @@ _clear_online_files() {
 
 . lib/inittest
 
-aux prepare_pvs 2
+aux prepare_pvs 3
 
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
@@ -153,3 +153,38 @@ check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
+
+
+# pvscan cache ignores pv that's not used
+
+pvcreate "$dev3"
+
+PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+echo $PVID3
+
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+
+pvscan --cache -aay "$dev3"
+
+ls "$RUNDIR/lvm/pvs_online"
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+
+
+# pvscan cache ignores pv in a foreign vg
+
+aux lvmconf "global/system_id_source = uname"
+
+vgcreate $vg2 "$dev3"
+lvcreate -an -n $lv1 -l1 $vg2
+pvscan --cache -aay "$dev3"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+check lv_field $vg2/$lv1 lv_active "active"
+lvchange -an $vg2
+rm "$RUNDIR/lvm/pvs_online/$PVID3"
+
+vgchange -y --systemid "asdf" "$vg2"
+
+pvscan --cache -aay "$dev3"
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+check lv_field $vg2/$lv1 lv_active "" --foreign
+


