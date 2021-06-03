From: Leo Yan <leo.yan@linaro.org>
Date: Thu,  3 Jun 2021 17:59:11 +0800
Subject: [PATCH v1 03/17] tests: Cleanup idm context when prepare devices
In-Reply-To: <20210603095925.510302-1-leo.yan@linaro.org>
References: <20210603095925.510302-1-leo.yan@linaro.org>
Message-ID: <20210603095925.510302-4-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For testing idm locking scheme, it's good to cleanup the idm context
before run the test cases.  This can give a clean environment for the
testing.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/lib/aux.sh | 29 +++++++++++++++++++++++------
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a592dad81..bb189f466 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -897,6 +897,20 @@ wipefs_a() {
 	udev_wait
 }
 
+cleanup_idm_context() {
+	local dev=$1
+
+	if [ -n "$LVM_TEST_LOCK_TYPE_IDM" ]; then
+		sg_dev=`sg_map26 ${dev}`
+		echo "Cleanup IDM context for drive ${dev} ($sg_dev)"
+		sg_raw -v -r 512 -o /tmp/idm_tmp_data.bin $sg_dev \
+			88 00 01 00 00 00 00 20 FF 01 00 00 00 01 00 00
+		sg_raw -v -s 512 -i /tmp/idm_tmp_data.bin $sg_dev \
+			8E 00 FF 00 00 00 00 00 00 00 00 00 00 01 00 00
+		rm /tmp/idm_tmp_data.bin
+	fi
+}
+
 prepare_backing_dev() {
 	local size=${1=32}
 	shift
@@ -989,12 +1003,15 @@ prepare_devs() {
 		return $?
 	fi
 
-	for d in "${BACKING_DEVICE_ARRAY[@]}"; do
-		cnt=$((`blockdev --getsize64 $d` / 1024 / 1024))
-		cnt=$(( cnt < 1000 ? cnt : 1000 ))
-		dd if=/dev/zero of="$d" bs=1MB count=$cnt
-		wipefs -a "$d" 2>/dev/null || true
-	done
+	if [ -n "$LVM_TEST_BACKING_DEVICE" ]; then
+		for d in "${BACKING_DEVICE_ARRAY[@]}"; do
+			cnt=$((`blockdev --getsize64 $d` / 1024 / 1024))
+			cnt=$(( cnt < 1000 ? cnt : 1000 ))
+			dd if=/dev/zero of="$d" bs=1MB count=$cnt
+			wipefs -a "$d" 2>/dev/null || true
+			cleanup_idm_context "$d"
+		done
+	fi
 
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP -o -f RAMDISK || for d in "${DEVICES[@]}"; do
-- 
2.25.1


