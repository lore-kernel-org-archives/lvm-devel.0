From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:22 -0400
Subject: master - tests: aux fixes
Message-ID: <201805152005.w4FK5MKH001445@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=550380c1a48697d6c5bc63b4d63c4b1d772dd14a
Commit:        550380c1a48697d6c5bc63b4d63c4b1d772dd14a
Parent:        3b3ee66b1f86518ef39a1b88a868083f9d2fc4e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:53:05 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

tests: aux fixes

Properly check for kernel version.
Also detect sysfs throttling support.
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index de3f218..5b2aebf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -843,7 +843,7 @@ prepare_backing_dev() {
 		return 0
 	elif test "${LVM_TEST_PREFER_BRD-1}" = "1" && \
 	     test ! -d /sys/block/ram0 && \
-	     test kernel_at_least 4 16 && \
+	     kernel_at_least 4 16 && \
 	     test "$size" -lt 16384; then
 		# try to use ramdisk if possible, but for
 		# big allocs (>16G) do not try to use ramdisk
@@ -1067,6 +1067,7 @@ enable_dev() {
 # Throttle down performance of kcopyd when mirroring i.e. disk image
 throttle_sys="/sys/module/dm_mirror/parameters/raid1_resync_throttle"
 throttle_dm_mirror() {
+	test -e "$throttle_sys" || return
 	test -f THROTTLE || cat "$throttle_sys" > THROTTLE
 	echo ${1-1} > "$throttle_sys"
 }


