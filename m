From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:18:24 -0500
Subject: master - tests: create whole path with mkdir
Message-ID: <201811191218.wAJCIOSa012484@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0747a6d0de8ccbf1586d392de29f4ab3b0fa7dbc
Commit:        0747a6d0de8ccbf1586d392de29f4ab3b0fa7dbc
Parent:        f7adcb5f6db7e7c1131b5dfb9114235a908292b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 18 21:42:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 18 22:03:50 2018 +0100

tests: create whole path with mkdir

Create also 'lvm' upper this if such one is missing in /run dir
and use '-p' with mkdir.
---
 test/shell/pvscan-autoactivate.sh |    2 +-
 test/shell/pvscan-nomda-bg.sh     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index c2fc36a..cd360e9 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -32,7 +32,7 @@ vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
 # the first pvscan scans all devs
-test -d "$ONLINEDIR" || mkdir "$ONLINEDIR"
+test -d "$ONLINEDIR" || mkdir -p "$ONLINEDIR"
 _clear_online nofoo
 
 pvscan --cache -aay
diff --git a/test/shell/pvscan-nomda-bg.sh b/test/shell/pvscan-nomda-bg.sh
index 1b6a176..42bd26f 100644
--- a/test/shell/pvscan-nomda-bg.sh
+++ b/test/shell/pvscan-nomda-bg.sh
@@ -28,7 +28,7 @@ RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 # create a file in pvs_online to disable the pvscan init
 # case which scans everything when the first dev appears.
-mkdir "$RUNDIR/lvm/pvs_online" || true
+mkdir -p "$RUNDIR/lvm/pvs_online" || true
 touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache --background "$dev2" -aay


