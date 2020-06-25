From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Jun 2020 17:15:17 +0800
Subject: [PATCH v1 2/4] tests: Specify global locking 'sanlock' for lvmlockd
In-Reply-To: <20200625091519.30705-1-leo.yan@linaro.org>
References: <20200625091519.30705-1-leo.yan@linaro.org>
Message-ID: <20200625091519.30705-2-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For sanlock locking scheme testing, it's good to specify the global
locking type option '-g sanlock' for lvmlockd.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 17e7935ee..214662f6e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -128,7 +128,7 @@ prepare_lvmlockd() {
 	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK"; then
 		# make check_lvmlockd_sanlock
 		echo "starting lvmlockd for sanlock"
-		lvmlockd -o 2
+		lvmlockd -o 2 -g sanlock
 
 	elif test -n "$LVM_TEST_LOCK_TYPE_DLM"; then
 		# make check_lvmlockd_dlm
-- 
2.17.1


