From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Jun 2020 17:15:16 +0800
Subject: [PATCH v1 1/4] tests: Fix device mapping for global lock image
Message-ID: <20200625091519.30705-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When create the sanlock global image device mapping, it needs to
generate mapping table.  The shell script uses the wrong command thus
the mapping table is not created properly.

This patch fixes the device mapping table so allow the global image
can be mapped successfully.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/shell/aa-lvmlockd-sanlock-prepare.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 4d0f9fd94..931055a22 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -33,7 +33,7 @@ dmsetup remove GL_DEV || true
 rm -f "$GL_FILE"
 dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
 GL_LOOP=$(losetup -f "$GL_FILE" --show)
-echo "0 $(blockdev --getsize $GL_LOOP linear $GL_LOOP 0)" | dmsetup create GL_DEV
+echo "0 $(blockdev --getsize $GL_LOOP) linear $GL_LOOP 0" | dmsetup create GL_DEV
 
 aux prepare_sanlock
 aux prepare_lvmlockd
-- 
2.17.1


