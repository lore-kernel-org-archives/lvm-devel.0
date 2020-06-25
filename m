From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Jun 2020 17:15:19 +0800
Subject: [PATCH v1 4/4] tests: Cleanup device mapping for global lock LV
In-Reply-To: <20200625091519.30705-1-leo.yan@linaro.org>
References: <20200625091519.30705-1-leo.yan@linaro.org>
Message-ID: <20200625091519.30705-4-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Cleanup the device mapping for global locking LV before cleanup the
device mapping for GL device, otherwise sometimes it will fail due to
the dependency.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/aa-lvmlockd-sanlock-prepare.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 8a8c4a74b..3a20b4dec 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -29,6 +29,7 @@ test_description='Set up things to run tests with sanlock'
 
 GL_DEV="/dev/mapper/GL_DEV"
 GL_FILE="/tmp/gl_file.img"
+dmsetup remove glvg-lvmlock || true
 dmsetup remove GL_DEV || true
 rm -f "$GL_FILE"
 dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
-- 
2.17.1


