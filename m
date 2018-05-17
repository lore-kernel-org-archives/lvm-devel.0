From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 17 May 2018 08:42:20 -0400
Subject: master - tests: fix kernal_at_least argument in aux.sh
Message-ID: <201805171242.w4HCgK3t026246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a39eaea27dcd2fd895740193e82ca6d0683eb3ad
Commit:        a39eaea27dcd2fd895740193e82ca6d0683eb3ad
Parent:        5052970da3bdf3ef702fa0f54a25cc2a44d0829e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu May 17 14:40:17 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu May 17 14:41:47 2018 +0200

tests: fix kernal_at_least argument in aux.sh

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5b2aebf..f6206ce 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -843,7 +843,7 @@ prepare_backing_dev() {
 		return 0
 	elif test "${LVM_TEST_PREFER_BRD-1}" = "1" && \
 	     test ! -d /sys/block/ram0 && \
-	     kernel_at_least 4 16 && \
+	     kernel_at_least 4 16 0 && \
 	     test "$size" -lt 16384; then
 		# try to use ramdisk if possible, but for
 		# big allocs (>16G) do not try to use ramdisk


