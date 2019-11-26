From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Nov 2019 04:08:09 -0500
Subject: master - Partial revert "tests: update to md dev name"
Message-ID: <52653.119112604080500539@us-mta-176.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4757ce4c2a4d67ca7170fd25a5dc6e160fb7a788
Commit:        4757ce4c2a4d67ca7170fd25a5dc6e160fb7a788
Parent:        1e669ab315c32aba3f47c37771f26ab7c8e151dd
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Nov 25 09:23:02 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 25 09:23:02 2019 +0100

Partial revert "tests: update to md dev name"

This partially reverts commit c2ff8876f97a5840cd9d6fcda1bec55ef6220dc3.

Not all MD devices are stopped. Something is missing there...
---
 test/lib/aux.sh                 |    7 ++-----
 test/shell/duplicate-pvs-md0.sh |    2 ++
 test/shell/duplicate-pvs-md1.sh |    3 +++
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 566e9b5..19365cd 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -421,15 +421,13 @@ teardown_devs() {
 	teardown_udev_cookies
 
 	test ! -f MD_DEV || cleanup_md_dev
-
-	test ! -f WAIT_MD_DEV || mddev=$(< WAIT_MD_DEV)
 	udev_wait
-	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
+	mdadm --stop --scan || true
 	udev_wait
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
-	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
+	mdadm --stop --scan || true
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
@@ -794,7 +792,6 @@ wait_md_create() {
 			break
 		fi
 	done
-	echo "$md" > WAIT_MD_DEV
 }
 
 wipefs_a() {
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 21f1442..036f570 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -369,6 +369,7 @@ aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
+mdadm --stop --scan
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -434,6 +435,7 @@ aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
+mdadm --stop --scan
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index be223df..64d9b98 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -416,6 +416,7 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
+mdadm --stop --scan
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -480,6 +481,7 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
+mdadm --stop --scan
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -618,6 +620,7 @@ aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
+mdadm --stop --scan
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true



