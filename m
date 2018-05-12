From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:43 -0400
Subject: master - tests: crypt test cannot run on ramdisk
Message-ID: <201805121625.w4CGPhDK007802@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=842b3074b7b186815ee8a200598f2e97f08c54af
Commit:        842b3074b7b186815ee8a200598f2e97f08c54af
Parent:        6f48741062710fec2eb5c58dd8d4364194bdbf44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 16:00:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: crypt test cannot run on ramdisk

This test can't use brd (ramdisk) as backend since for some
weird reason  lsblk is not listing these device.

TODO: test could be probably rewritten to avoid using lsblk somehow??
---
 test/shell/fsadm-crypt.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 634fef3..68959e3 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -14,6 +14,10 @@ test_description='Exercise fsadm filesystem resize on crypt devices'
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
+# FIXME: cannot use brd (ramdisk)  - lsblk is NOT listing it
+# so lsblk usage should be replaced
+export LVM_TEST_PREFER_BRD=0
+
 . lib/inittest
 
 aux prepare_vg 1 300
@@ -119,7 +123,8 @@ check_missing()
 }
 
 get_crypt_kname() {
-	lsblk -r -n -o KNAME,NAME | grep "$1" | cut -d ' ' -f 1
+	lsblk -r -n -o KNAME,NAME | tee out
+	grep "$1" out | cut -d ' ' -f 1
 }
 
 


