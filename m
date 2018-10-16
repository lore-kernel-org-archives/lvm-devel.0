From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 17:50:43 -0400
Subject: master - tests: better support for /var/run
Message-ID: <201810162150.w9GLoh5n017374@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=015231b11ffedc8e44d74ef3a5204f1e99fc6813
Commit:        015231b11ffedc8e44d74ef3a5204f1e99fc6813
Parent:        32f1afbe36f6cc804a8f4e669af7c90639389811
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 23:46:50 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 23:49:35 2018 +0200

tests: better support for /var/run

---
 test/shell/pvscan-autoactivate.sh |   52 ++++++++++++++++++++++---------------
 test/shell/pvscan-nomda-bg.sh     |    8 +++--
 2 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 85a08cf..5c5a3c6 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -19,11 +19,13 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
-mkdir /run/lvm/pvs_online || true
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
 
-# the first pvscan scans all devs 
-
-rm /run/lvm/pvs_online/*
+# the first pvscan scans all devs
+# FIXME: kills logic for running system
+rm -rf "$RUNDIR/lvm/pvs_online"
+mkdir "$RUNDIR/lvm/pvs_online" || true
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -32,7 +34,8 @@ lvchange -an $vg1
 # the first pvscan scans all devs even when
 # only one device is specified
 
-rm /run/lvm/pvs_online/*
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -41,8 +44,9 @@ lvchange -an $vg1
 # touch foo to disable first-pvscan case,
 # then check pvscan with no args scans all
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -52,8 +56,9 @@ lvchange -an $vg1
 # then check that vg is activated only after
 # both devs appear separately
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -65,8 +70,9 @@ lvchange -an $vg1
 # then check that vg is activated when both
 # devs appear together
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1" "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -86,8 +92,9 @@ lvcreate -n $lv1 -l 4 -a n $vg1
 # touch foo to disable first-pvscan case,
 # test case where dev with metadata appears first
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active ""
@@ -99,8 +106,9 @@ lvchange -an $vg1
 # test case where dev without metadata
 # appears first which triggers scanning all
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -111,7 +119,8 @@ lvchange -an $vg1
 # dev without metadata is scanned, but
 # first-pvscan case scans all devs
 
-rm /run/lvm/pvs_online/*
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -121,8 +130,9 @@ lvchange -an $vg1
 # is online without the -aay option to
 # activate until after they are online
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -134,12 +144,12 @@ lvchange -an $vg1
 
 # like previous
 
-rm /run/lvm/pvs_online/*
-touch /run/lvm/pvs_online/foo
+# FIXME: kills logic for running system
+rm "$RUNDIR/lvm/pvs_online/*"
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
-
diff --git a/test/shell/pvscan-nomda-bg.sh b/test/shell/pvscan-nomda-bg.sh
index d73f3da..1b6a176 100644
--- a/test/shell/pvscan-nomda-bg.sh
+++ b/test/shell/pvscan-nomda-bg.sh
@@ -24,10 +24,12 @@ lvcreate -n foo -l 1 -an --zero n $vg1
 
 check inactive $vg1 foo
 
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
 # create a file in pvs_online to disable the pvscan init
 # case which scans everything when the first dev appears.
-mkdir /run/lvm/pvs_online || true
-touch /run/lvm/pvs_online/foo
+mkdir "$RUNDIR/lvm/pvs_online" || true
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache --background "$dev2" -aay
 
@@ -37,5 +39,5 @@ pvscan --cache --background "$dev1" -aay
 
 check active $vg1 foo
 
-rm /run/lvm/pvs_online/foo
+rm "$RUNDIR/lvm/pvs_online/foo"
 vgremove -ff $vg1


