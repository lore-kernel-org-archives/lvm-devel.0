From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jul 2019 12:43:19 -0400
Subject: master - tests: pvscan-autoactivate test unmatching dev and PV size
Message-ID: <201907111643.x6BGhJmD028737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7230aa891c4186ab425f6821c25101d9049fadde
Commit:        7230aa891c4186ab425f6821c25101d9049fadde
Parent:        4eb0e65693a6e3d7f4fe406aff5fdc75c3ef9b87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 11 11:38:12 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 11 11:38:12 2019 -0500

tests: pvscan-autoactivate test unmatching dev and PV size

---
 test/shell/pvscan-autoactivate.sh |   28 +++++++++++++++++++++++++++-
 1 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index d674dc5..d79a7e3 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -27,7 +27,7 @@ _clear_online_files() {
 
 . lib/inittest
 
-aux prepare_pvs 8
+aux prepare_devs 8 16
 
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
@@ -209,3 +209,29 @@ pvscan --cache -aay
 check lv_field $vg3/$lv1 lv_active "active"
 lvchange -an $vg3
 
+# Test event activation when PV and dev size don't match
+
+vgremove -ff $vg3
+
+pvremove "$dev8"
+pvcreate -y --setphysicalvolumesize 8M "$dev8"
+
+PVID8=`pvs $dev8 --noheading -o uuid | tr -d - | awk '{print $1}'`
+echo $PVID8
+
+vgcreate $vg3 "$dev8"
+lvcreate -l1 -n $lv1 $vg3
+check lv_field $vg3/$lv1 lv_active "active"
+vgchange -an $vg3
+check lv_field $vg3/$lv1 lv_active ""
+
+_clear_online_files
+
+pvscan --cache -aay "$dev8"
+check lv_field $vg3/$lv1 lv_active "active"
+ls "$RUNDIR/lvm/pvs_online/$PVID8"
+ls "$RUNDIR/lvm/vgs_online/$vg3"
+vgchange -an $vg3
+
+vgremove -ff $vg3
+


