From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 10:59:13 -0400
Subject: master - tests: dont try to use DAX based brd device
Message-ID: <201805151459.w4FExDV2030303@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0217c53b24db3b0d50d1088ecd7bfc3ad1ba3955
Commit:        0217c53b24db3b0d50d1088ecd7bfc3ad1ba3955
Parent:        2eba7c77557655cfbd19f191ec5d1ad1025897b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 16:07:13 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 16:07:13 2018 +0200

tests: dont try to use DAX based brd device

Unfortunatelly on kernels <4.16 lvm2 can't user brd ramdisks
for backend device as number of test is failing with this kernel
message:

device-mapper: ioctl: can't change device type after initial table load.

caused by DAX request-based handling, and lvm2 tries to replace device
with backend 'error' bio-based device and such table reload is being
rejected.

So ATM keep ramdisk only on most recent kernel to experiment a bit,
for older machines just stay safe and keep old slower loop backend.
---
 test/lib/aux.sh |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0f0967b..de3f218 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -841,9 +841,18 @@ prepare_backing_dev() {
 		BACKING_DEV=$LVM_TEST_BACKING_DEVICE
 		echo "$BACKING_DEV" > BACKING_DEV
 		return 0
-	elif test "${LVM_TEST_PREFER_BRD-1}" = "1" && test ! -d /sys/block/ram0 && test "$size" -lt 16384; then
+	elif test "${LVM_TEST_PREFER_BRD-1}" = "1" && \
+	     test ! -d /sys/block/ram0 && \
+	     test kernel_at_least 4 16 && \
+	     test "$size" -lt 16384; then
 		# try to use ramdisk if possible, but for
 		# big allocs (>16G) do not try to use ramdisk
+		# Also we can't use BRD device prior kernel 4.16
+		# since they were DAX based and lvm2 often relies
+		# in save table loading between exiting backend device
+		# and  bio-based 'error' device.
+		# However with request based DAX brd device we get this:
+		# device-mapper: ioctl: can't change device type after initial table load.
 		prepare_ramdisk "$size" "$@" && return
 		echo "(failed)"
 	fi


