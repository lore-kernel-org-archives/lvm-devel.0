From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 15 Aug 2017 08:17:58 -0400
Subject: master - test: pvcreate-bootloaderarea: pvcreate --restorefile --bootloaderarea not supported anymore
Message-ID: <201708151217.v7FCHw2o004209@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa75ca633285339a8be50ed5e5a661ea1654f8f7
Commit:        aa75ca633285339a8be50ed5e5a661ea1654f8f7
Parent:        3c978f7bcc8c7d7cb473ba718a8e44523a09d02e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 15 14:15:41 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 15 14:15:50 2017 +0200

test: pvcreate-bootloaderarea: pvcreate --restorefile --bootloaderarea not supported anymore

The fact that this combination is not supported anymore is tested
already in pvcreate-operation.sh test.
---
 test/shell/pvcreate-bootloaderarea.sh |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 1147a3b..f9e0929 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -55,7 +55,4 @@ check pv_field "$dev1" ba_start "262144"
 check pv_field "$dev1" ba_size "786432"
 check pv_field "$dev1" pe_start "1048576"
 
-# error out when restoring the PV and trying to use overlapping bootloader area
 pvremove -ff "$dev1"
-not pvcreate --restorefile "$TESTDIR/vg_with_ba_backup" --uuid "$pv_uuid" --bootloaderareasize 1m "$dev1" 2>err
-grep "Bootloader area would overlap data area" err


