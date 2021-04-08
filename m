From: David Teigland <teigland@sourceware.org>
Date: Thu,  8 Apr 2021 21:09:23 +0000 (GMT)
Subject: main - tests: skip autoactivation-metadata with lvmlockd
Message-ID: <20210408210923.E2300385480A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01f108c4d03f848a84bff74104dd18b21c7a8e3f
Commit:        01f108c4d03f848a84bff74104dd18b21c7a8e3f
Parent:        0a28e3c44b05470061f15516e1c89a84fa2e8569
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 8 16:08:45 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 8 16:08:45 2021 -0500

tests: skip autoactivation-metadata with lvmlockd

shared vgs are not autoactivated
---
 test/shell/autoactivation-metadata.sh | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/test/shell/autoactivation-metadata.sh b/test/shell/autoactivation-metadata.sh
index 4ee2b75c0..3cdb5b315 100644
--- a/test/shell/autoactivation-metadata.sh
+++ b/test/shell/autoactivation-metadata.sh
@@ -1,5 +1,6 @@
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
@@ -24,7 +25,7 @@ aux prepare_devs 1
 #
 
 # default
-vgcreate $SHARED $vg "$dev1"
+vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 check vg_field $vg autoactivation "enabled"
 check lv_field $vg/$lv1 autoactivation "enabled"
@@ -84,7 +85,7 @@ vgremove -y $vg
 #
 
 # default
-vgcreate $SHARED $vg "$dev1"
+vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 
 # --aa=n
@@ -127,7 +128,7 @@ vgremove -y $vg
 # test vgcreate --setautoactivation, lvcreate --setautoactivation
 #
 
-vgcreate $SHARED $vg "$dev1"
+vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 lvcreate -n $lv2 -l1 --setautoactivation y -an $vg
 lvcreate -n $lv3 -l1 --setautoactivation n -an $vg
@@ -155,7 +156,7 @@ vgchange -an $vg
 vgremove -y $vg
 _clear_online_files
 
-vgcreate $SHARED --setautoactivation y $vg "$dev1"
+vgcreate --setautoactivation y $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 lvcreate -n $lv2 -l1 --setautoactivation y -an $vg
 lvcreate -n $lv3 -l1 --setautoactivation n -an $vg
@@ -183,7 +184,7 @@ vgchange -an $vg
 vgremove -y $vg
 _clear_online_files
 
-vgcreate $SHARED --setautoactivation n $vg "$dev1"
+vgcreate --setautoactivation n $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 lvcreate -n $lv2 -l1 --setautoactivation y -an $vg
 lvcreate -n $lv3 -l1 --setautoactivation n -an $vg
@@ -213,7 +214,7 @@ _clear_online_files
 # test combination of --aa and auto_activation_volume_list
 #
 
-vgcreate $SHARED $vg "$dev1"
+vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 lvcreate -n $lv2 -l1 --setautoactivation n -an $vg
 check vg_field $vg autoactivation "enabled"
@@ -290,7 +291,7 @@ _clear_online_files
 
 vgremove -y $vg
 
-vgcreate $SHARED --setautoactivation n $vg "$dev1"
+vgcreate --setautoactivation n $vg "$dev1"
 lvcreate -n $lv1 -l1 -an $vg
 lvcreate -n $lv2 -l1 --setautoactivation n -an $vg
 check vg_field $vg autoactivation ""


