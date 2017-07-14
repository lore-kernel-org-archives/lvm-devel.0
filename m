From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Jul 2017 14:31:13 -0400
Subject: master - tests: add udev_wait before tearing scsi_debug
Message-ID: <201707141831.v6EIVDP5007929@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2154f30a996967fa192b33997704d47038b5f077
Commit:        2154f30a996967fa192b33997704d47038b5f077
Parent:        ac0945bc4a14dfe8def578f9132e7261f254a279
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 14 20:23:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 20:30:04 2017 +0200

tests: add udev_wait before tearing scsi_debug

Make less probably there will be some udev work going while we try
to remove scsi_debug target.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9a48689..b7a9ad6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -462,6 +462,7 @@ teardown_devs() {
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
+		udev_wait
 		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || modprobe -r scsi_debug
 	else
 		test ! -f LOOP || losetup -d "$(< LOOP)" || true


