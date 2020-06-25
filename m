From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Jun 2020 17:15:18 +0800
Subject: [PATCH v1 3/4] tests: Fix test image issue
In-Reply-To: <20200625091519.30705-1-leo.yan@linaro.org>
References: <20200625091519.30705-1-leo.yan@linaro.org>
Message-ID: <20200625091519.30705-3-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the global lock's test image gl_test.img is placed under the folder
@TESTDIR, after execute the script aa-lvmlockd-sanlock-prepare.sh, the
folder @TESTDIR is a temporary folder so it will be removed after
running and thus gl_test.img will not be kept anymore.  So gl_test.img
cannot be used by any sequential test cases.

This patch changes to place gl_test.img in folder '/tmp' so it can be
used by all test cases.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/aa-lvmlockd-sanlock-prepare.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 931055a22..8a8c4a74b 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -28,7 +28,7 @@ test_description='Set up things to run tests with sanlock'
 # to remove this VG and device.
 
 GL_DEV="/dev/mapper/GL_DEV"
-GL_FILE="$PWD/gl_file.img"
+GL_FILE="/tmp/gl_file.img"
 dmsetup remove GL_DEV || true
 rm -f "$GL_FILE"
 dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
-- 
2.17.1


