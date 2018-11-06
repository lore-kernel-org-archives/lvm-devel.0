From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Nov 2018 09:08:37 -0500
Subject: master - tests: add wait for udev
Message-ID: <201811061408.wA6E8bIb031901@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad0268e239a2d8445813733b70ea54a546f8b627
Commit:        ad0268e239a2d8445813733b70ea54a546f8b627
Parent:        a1b1b3dbb620dd51123387828b4b936a47814853
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 6 15:01:52 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 6 15:05:44 2018 +0100

tests: add wait for udev

Since the test is currently directly working with live directory,
which can be getting updates from system's udev - add wait
for settling so removal of all known PVs happens after that.
But still this has major influce on behavior of running system,
so the test should never be executed on a user used box.
---
 test/shell/pvscan-autoactivate.sh |   59 +++++++++++++++---------------------
 1 files changed, 25 insertions(+), 34 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 5c5a3c6..b6db47a 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -12,6 +12,18 @@
 
 SKIP_WITH_LVMPOLLD=1
 
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+ONLINEDIR="$RUNDIR/lvm/pvs_online"
+
+# FIXME: kills logic for running system
+_clear_online() {
+	# wait till udev is finished
+	aux udev_wait
+	rm -f "$ONLINEDIR/*"
+	test -n "${1+varset}" || touch "$ONLINEDIR/foo"
+}
+
 . lib/inittest
 
 aux prepare_pvs 2
@@ -19,13 +31,9 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
-RUNDIR="/run"
-test -d "$RUNDIR" || RUNDIR="/var/run"
-
 # the first pvscan scans all devs
-# FIXME: kills logic for running system
-rm -rf "$RUNDIR/lvm/pvs_online"
-mkdir "$RUNDIR/lvm/pvs_online" || true
+test -d "$ONLINEDIR" || mkdir "$ONLINEDIR"
+_clear_online nofoo
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -34,8 +42,7 @@ lvchange -an $vg1
 # the first pvscan scans all devs even when
 # only one device is specified
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
+_clear_online nofoo
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -43,10 +50,7 @@ lvchange -an $vg1
 
 # touch foo to disable first-pvscan case,
 # then check pvscan with no args scans all
-
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -56,13 +60,11 @@ lvchange -an $vg1
 # then check that vg is activated only after
 # both devs appear separately
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
-pvscan --cache -aay "$dev1"
+pvscan -vvvv --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
-pvscan --cache -aay "$dev2"
+pvscan -vvvv --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
@@ -70,9 +72,7 @@ lvchange -an $vg1
 # then check that vg is activated when both
 # devs appear together
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache -aay "$dev1" "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -92,9 +92,7 @@ lvcreate -n $lv1 -l 4 -a n $vg1
 # touch foo to disable first-pvscan case,
 # test case where dev with metadata appears first
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active ""
@@ -106,9 +104,7 @@ lvchange -an $vg1
 # test case where dev without metadata
 # appears first which triggers scanning all
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -119,8 +115,7 @@ lvchange -an $vg1
 # dev without metadata is scanned, but
 # first-pvscan case scans all devs
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
+_clear_online nofoo
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -130,9 +125,7 @@ lvchange -an $vg1
 # is online without the -aay option to
 # activate until after they are online
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -144,9 +137,7 @@ lvchange -an $vg1
 
 # like previous
 
-# FIXME: kills logic for running system
-rm "$RUNDIR/lvm/pvs_online/*"
-touch "$RUNDIR/lvm/pvs_online/foo"
+_clear_online
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""


