From: Leo Yan <leo.yan@linaro.org>
Date: Wed, 16 Jun 2021 21:43:54 +0800
Subject: [PATCH] tests: stress: Change to use $SHARED for vgcreate
Message-ID: <20210616134354.337017-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the variable $SHARED to replace "--shared" for vgcreate commands.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/stress_multi_threads_1.sh | 4 ++--
 test/shell/stress_multi_threads_2.sh | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/stress_multi_threads_1.sh b/test/shell/stress_multi_threads_1.sh
index e76810bbb..c5695eb0b 100644
--- a/test/shell/stress_multi_threads_1.sh
+++ b/test/shell/stress_multi_threads_1.sh
@@ -22,8 +22,8 @@ get_devs
 
 pvcreate -M2 "${DEVICES[@]}"
 
-vgcreate --shared -M2 "$vg1" "$dev1" "$dev2" "$dev3"
-vgcreate --shared -M2 "$vg2" "$dev4" "$dev5" "$dev6"
+vgcreate $SHARED -M2 "$vg1" "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED -M2 "$vg2" "$dev4" "$dev5" "$dev6"
 
 test_vg_thread1()
 {
diff --git a/test/shell/stress_multi_threads_2.sh b/test/shell/stress_multi_threads_2.sh
index 4e72b7447..9b586a263 100644
--- a/test/shell/stress_multi_threads_2.sh
+++ b/test/shell/stress_multi_threads_2.sh
@@ -26,14 +26,14 @@ test_vg_thread1()
 {
 	for i in {1..1000}
 	do
-		vgcreate --shared -M2 "$vg1" "$dev1" "$dev2" "$dev3"
+		vgcreate $SHARED -M2 "$vg1" "$dev1" "$dev2" "$dev3"
 		vgremove -ff $vg1
 	done
 }
 
 test_vg_thread2()
 {
-	vgcreate --shared -M2 "$vg2" "$dev4" "$dev5" "$dev6"
+	vgcreate $SHARED -M2 "$vg2" "$dev4" "$dev5" "$dev6"
 
 	for i in {1..1000}
 	do
-- 
2.25.1


