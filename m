From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:44 -0400
Subject: master - tests: update pvscan-autoactivate for init change
Message-ID: <201904081539.x38Fdin6023029@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48e9f116ae5bc0d8444936ffc263542c80d6fa17
Commit:        48e9f116ae5bc0d8444936ffc263542c80d6fa17
Parent:        f58a70c168f8ac225b0e4e40c2f0e1d1c98357fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 5 13:20:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 14:04:42 2019 -0500

tests: update pvscan-autoactivate for init change

---
 test/shell/pvscan-autoactivate.sh |   56 +++++-------------------------------
 1 files changed, 8 insertions(+), 48 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index e48aeac..6f00b43 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -32,53 +32,29 @@ aux prepare_pvs 3
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
-# the first pvscan scans all devs
 test -d "$PVS_ONLINE_DIR" || mkdir -p "$PVS_ONLINE_DIR"
 test -d "$VGS_ONLINE_DIR" || mkdir -p "$VGS_ONLINE_DIR"
 _clear_online_files
 
+# check pvscan with no args scans and activates all
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
-# the first pvscan scans all devs even when
-# only one device is specified
-
 _clear_online_files
 
-pvscan --cache -aay "$dev1"
-check lv_field $vg1/$lv1 lv_active "active"
-lvchange -an $vg1
-
-# touch foo to disable first-pvscan case,
-# then check pvscan with no args scans all
-_clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
-
-pvscan --cache -aay
-check lv_field $vg1/$lv1 lv_active "active"
-lvchange -an $vg1
-
-# touch foo to disable first-pvscan case,
-# then check that vg is activated only after
-# both devs appear separately
-
-_clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
-
+# first dev leaves vg incomplete and inactive,
+# and second dev completes vg and activates
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
-# touch foo to disable first-pvscan case,
-# then check that vg is activated when both
-# devs appear together
-
 _clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
 
+# check that vg is activated when both devs
+# are scanned together
 pvscan --cache -aay "$dev1" "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
@@ -94,46 +70,31 @@ pvcreate --metadatacopies 1 "$dev2"
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
-# touch foo to disable first-pvscan case,
-# test case where dev with metadata appears first
 
 _clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
 
+# test case where dev with metadata is scanned first
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
-# touch foo to disable first-pvscan case,
-# test case where dev without metadata
-# appears first which triggers scanning all
+# test case where dev without metadata is scanned first
+# which triggers scanning all, which finds both
 
 _clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
-
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
-# dev without metadata is scanned, but
-# first-pvscan case scans all devs
-
-_clear_online_files
-
-pvscan --cache -aay "$dev1"
-check lv_field $vg1/$lv1 lv_active "active"
-lvchange -an $vg1
-
 # use the --cache option to record a dev
 # is online without the -aay option to
 # activate until after they are online
 
 _clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -146,7 +107,6 @@ lvchange -an $vg1
 # like previous
 
 _clear_online_files
-touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""


