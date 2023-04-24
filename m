From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:37 +0000 (GMT)
Subject: main - tests: try to retry remove of scsi_debug
Message-ID: <20230424221437.5F01F3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e42b56c31b71751bcd9d9cc9bae765433fa68027
Commit:        e42b56c31b71751bcd9d9cc9bae765433fa68027
Parent:        b8aea8ae7d000f972d2643a3f097b46c4dbb1fe7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 15:26:40 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

tests: try to retry remove of scsi_debug

Not quite sure if this helps anything, some of testing
machines can't reliably remove scsi_debug, reporting
they are in use - but it's not easily reproducible...
---
 test/lib/aux.sh | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d33a13882..6a0b9da93 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -457,7 +457,12 @@ teardown_devs() {
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
 		udev_wait
-		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || modprobe -r scsi_debug
+		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || {
+			if ! modprobe -r scsi_debug ; then
+				sleep 1
+				modprobe -r scsi_debug || true
+			fi
+		}
 	else
 		test ! -f LOOP || losetup -d "$(< LOOP)" || true
 		test ! -f LOOPFILE || rm -f "$(< LOOPFILE)"

