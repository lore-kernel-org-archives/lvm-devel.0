From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:26 +0200
Subject: [PATCH 12/16] test: add helper to compute aligned lv size
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-13-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For test purposes add a helper function to compute lv size as it
would be done by lvm tools.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 test/lib/utils.sh |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 4c3cd93..c555e45 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -177,6 +177,29 @@ kernel_at_least() {
     return 1
 }
 
+align_size_up() {
+    size=$1
+    [ -z $2 ] && stripes=0
+    [ -z $3 ] && extent=4
+
+    [ -z $size ] || [ -z $stripes ] || [ -z $extent ] && exit 1
+
+    tmp=$((size%extent))
+    if [ $tmp -ne 0 ]; then
+        size=$(($size+($extent-$tmp)))
+    fi
+    if [ $stripes -eq 0 ]; then
+        echo "$size"
+        return 0
+    fi
+    extents=$(($size/$extent))
+    tmp=$(($extents%$stripes))
+    if [ $tmp -ne 0 ]; then
+        extents=$(($extents-$tmp+$stripes))
+    fi
+    echo "$(($extents*$extent))"
+}
+
 . lib/paths || { echo >&2 you must run make first; exit 1; }
 
 PATH=$abs_top_builddir/test/lib:$PATH
-- 
1.7.4.4


