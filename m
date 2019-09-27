From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 Sep 2019 13:52:53 -0400
Subject: master - tests: mdadm stop in test cleanup
Message-ID: <201909271752.x8RHqrT2018464@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd5b8b72da79e2f0a10785d055a27643d9eaaf19
Commit:        fd5b8b72da79e2f0a10785d055a27643d9eaaf19
Parent:        9680fd6d78dc9aede50ed797317ec579e4969522
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 27 12:51:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 27 12:51:34 2019 -0500

tests: mdadm stop in test cleanup

try to clear any existing md devs remaining after
a test
---
 test/lib/aux.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9c9e1fd..7b0ef22 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -421,9 +421,14 @@ teardown_devs() {
 	teardown_udev_cookies
 
 	test ! -f MD_DEV || cleanup_md_dev
+	udev_wait
+	mdadm --stop --scan || true
+	udev_wait
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
 	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
+	mdadm --stop --scan || true
+
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then


