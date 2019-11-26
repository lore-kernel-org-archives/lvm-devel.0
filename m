From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Nov 2019 04:36:52 -0500
Subject: master - tests: update to md dev name
Message-ID: <51331.119112604364500135@us-mta-147.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbd8badaef630c3534ccd1ae27602b66c37d5c6e
Commit:        bbd8badaef630c3534ccd1ae27602b66c37d5c6e
Parent:        b6902585187e9a7e29fb57d8415743db1bf80dab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 2 12:51:17 2019 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 26 10:34:51 2019 +0100

tests: update to md dev name

Restore WAIT_MD_DEV in teardown.

NOTE: The name of MD device may have changed.

(cherry picked from commit c2ff8876f97a5840cd9d6fcda1bec55ef6220dc3)
---
 test/lib/aux.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 19365cd..566e9b5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -421,13 +421,15 @@ teardown_devs() {
 	teardown_udev_cookies
 
 	test ! -f MD_DEV || cleanup_md_dev
+
+	test ! -f WAIT_MD_DEV || mddev=$(< WAIT_MD_DEV)
 	udev_wait
-	mdadm --stop --scan || true
+	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
 	udev_wait
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
-	mdadm --stop --scan || true
+	test ! -f WAIT_MD_DEV || mdadm --stop $mddev || true
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
@@ -792,6 +794,7 @@ wait_md_create() {
 			break
 		fi
 	done
+	echo "$md" > WAIT_MD_DEV
 }
 
 wipefs_a() {



