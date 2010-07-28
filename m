From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:49 +0200
Subject: [PATCH 03/14] Testsuit: create empty files
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <e5b439b0bc65424f55cf53f34c80449e861da5f2.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Using count=0 is sufficient for creation of zeroed files.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/test-utils.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/test-utils.sh b/test/test-utils.sh
index b3ee6f6..c044de0 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -187,7 +187,7 @@ prepare_loop() {
 	done
 
 	LOOPFILE="$PWD/test.img"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1))
 	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
 		return 0
 	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then
-- 
1.7.2


